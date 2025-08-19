---
title: Enhanced Azure Bicep Modules for Azure Policy Resources
date: 2024-03-06 18:00
author: Tao Yang
permalink: /2024/03/06/enhanced-bicep-modules-for-azure-policy/
summary: A collection of enhanced Azure Bicep modules for Azure Policy resources based on CARML.
categories:
  - Azure
tags:
  - Azure
  - Azure Bicep
---

## Introduction

I have used the [Common Azure Resource Modules Library (CARML)](https://aka.ms/carml) modules for Azure Policies in several projects. I have seen few customers ran into limitations with the policy modules, especially the modules for policy [definition](https://github.com/TY-Consulting/ResourceModules/tree/main/modules/authorization/policy-definition) and [initiatives](https://github.com/TY-Consulting/ResourceModules/tree/main/modules/authorization/policy-set-definition).

When using the CARML modules for policy definitions and initiatives to deploy custom policy definitions, in your Bicep template, you would call the module for every single definition. As we all know, in Bicep, every time when you call a module, it becomes a nested deployment. This means if you have 100 policy definitions to deploy, you will end up with at least 100 nested deployments.

Although custom policy definitions and initiatives can be deployed to subscriptions or management groups, it's most commonly deployed management groups.

As we all know, the deployment limit for management groups is 800 per location ([reference](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits#management-group-limits)). Unlike the subscription level deployments, when you reach the limit on a management group, the older deployments are not automatically deleted. This means you will need to manually delete the older deployments to make room for new deployments.

This has become a real issue for customers who have a large number of custom policy definitions and initiatives to deploy. I have seen customers' policy pipelines frequently fail due to the deployment limit being reached. One of my customers was even thinking about moving away from the existing Bicep pipeline and adopting Terraform for the policy deployment so it is not restricted by the management group deployment limit.

To reproduce this issue, I have created a pipeline that deploys around 150 custom policies to a management group using the CARML policy definition module for the management group scope. The pipeline also runs a what-if template validation before the actual deployment. My pipeline actually failed at the what-if validation stage due to the ARM throttling limit being reached.

![01](../../../../assets/images/2024/03/policy-modules-01.jpg)

To work around this issue, I had to significantly reduced the number of policies deployed from the Bicep template and I was able to pass the what-if validation stage and managed to have all the policies deployed. In the Azure portal, there is a separate deployment for each policy definition:

![02](../../../../assets/images/2024/03/policy-modules-02.jpg)

This issue is actually pretty easy to fix. Instead of calling the module for each policy definition, we can simply update the policy definition and initiative modules to support deploying multiple resources. It means the `for loop` takes place within the module instead when calling the module (in the Bicep template).

## Enhanced Policy Definition and Initiative Modules

I have updated the policy definition and initiative modules to support deploying multiple definitions. The updated modules are available in my GitHub repo [HERE](https://github.com/tyconsulting/BlogPosts/tree/master/BicepModules/authorization):

* [Policy Definition Module](https://github.com/tyconsulting/BlogPosts/tree/master/BicepModules/authorization/policy-definition)
* [Policy Initiative Module](https://github.com/tyconsulting/BlogPosts/tree/master/BicepModules/authorization/policy-set-definition)

These modules are based on the original CARML modules, with the following enhancements:

1. Support deploying multiple policy definitions or initiatives in a single module call (by passing an array of policy definitions or initiatives to the module and added a `for loop` for each resource).
2. Created respective [User-Defined Types](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/user-defined-data-types) for the policy definitions and policy initiative definitions. So the array of definitions are strongly typed.

To test the updated modules, I have updated the existing templates to deploy the same 150 policy definitions, not only I was able to pass the what-if validation stage, but also the deployment was successful. There were only 3 deployments created in the management group:

![03](../../../../assets/images/2024/03/policy-modules-03.jpg)

There are 3 deployments because I have called the wrapper "all scope" module, which then called the management group scoped child module. all 150 policy definitions were created from the module call for the child management group scoped module:

![04](../../../../assets/images/2024/03/policy-modules-04.jpg)

## How to use the updated modules

I have also included the Bicep templates I have used in my lab environments for the policy definition and initiative deployments in the GitHub repo. You can find the templates here:

* [policy-definitions](https://github.com/tyconsulting/BlogPosts/tree/master/Azure-Bicep/policy-definitions)
* [policy-initiatives](https://github.com/tyconsulting/BlogPosts/tree/master/Azure-Bicep/policy-initiatives)

### Policy Definition Template

As the standard, the Azure policy definitions are defined in JSON files. I have included few sample policy definition JSON files in the same directory of the policy definition Bicep template.

I firstly import the JSON content of each policy file into an array variable using the [`loadJsonContent()` funciton](https://github.com/tyconsulting/BlogPosts/blob/master/Azure-Bicep/policy-definitions/main.bicep#L4-L20) in Bicep.

```terraform
var policyDefinitions = [
  loadJsonContent('relative-path-to-the-json-file-1.json')
  loadJsonContent('relative-path-to-the-json-file-2.json')

]
```

Then I created another array variable to format the json object into the user-defined type for the policy definition which is defined in the module. This is done using the [lambda function `map()`](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-functions-lambda#map):

```terraform
var mappedPolicyDefinitions = map(range(0, length(policyDefinitions)), i => {
    name: policyDefinitions[i].name
    displayName: contains(policyDefinitions[i].properties, 'displayName') ? policyDefinitions[i].properties.displayName : null
    description: contains(policyDefinitions[i].properties, 'description') ? policyDefinitions[i].properties.description : null
    metadata: contains(policyDefinitions[i].properties, 'metadata') ? policyDefinitions[i].properties.metadata : null
    mode: contains(policyDefinitions[i].properties, 'mode') ? policyDefinitions[i].properties.mode : 'All'
    parameters: contains(policyDefinitions[i].properties, 'parameters') ? policyDefinitions[i].properties.parameters : null
    policyRule: policyDefinitions[i].properties.policyRule
  })
```

Lastly, I simply [called the Policy Definition module](https://github.com/tyconsulting/BlogPosts/blob/master/Azure-Bicep/policy-definitions/main.bicep#L34-L39) using the formatted array `mappedPolicyDefinitions` as the parameter:

```terraform
module policyDefs '../../BicepModules/authorization/policy-definition/main.bicep' = {
  name: take('policyDef-${deploymentNameSuffix}', 64)
  params: {
    policyDefinitions: mappedPolicyDefinitions
  }
}
```

### Policy Initiative Template

The policy initiative template is very similar to the policy definition template, but a little bit more complicated because the policy initiatives are depended on the policy definitions. In my lab (and my customers environments), I have been creating the custom policy definitions and initiatives in a same management group.

Normally when referencing a policy definition in an initiative, you will need to specify the resource Ids of the policy definitions that are part of the initiative. I didn't want to hardcode the resource Ids because they are different in each environment. I had to keep the template as generic as possible. Therefore I have placed a token string in all the policy initiative definition JSON files and then replaced the token in the Bicep template using the Bicep `replace()` function.

I have included couple of sample policy initiatives that are made up using some of the policies deployed by the policy definition template. These policy initiative definitions are also defined as the standard Initiative JSON format in json files. they are placed in the same directory as the policy initiative Bicep template.

Again, I firstly load the json content of all the policy initiative files into an array variable using the [`loadJsonContent()` function](https://github.com/tyconsulting/BlogPosts/blob/master/Azure-Bicep/policy-initiatives/main.bicep#L8-L11):

```terraform
var policySetDefinitions = [
  loadJsonContent('relative-path-to-the-json-file-1.json')
  loadJsonContent('relative-path-to-the-json-file-2.json')
]
```

then following the same practice, I used the lambda function `map()` to format the json object into the user-defined type for the policy initiative which is defined in the module. However, in this case, I had to [nest another `map()` function](https://github.com/tyconsulting/BlogPosts/blob/master/Azure-Bicep/policy-initiatives/main.bicep#L20-L25) to replace the token string `{policyLocationResourceId}` with the management group Id in the policy initiative definitions:

```terraform
var mappedPolicySetDefinitions = map(range(0, length(policySetDefinitions)), i => {
    name: policySetDefinitions[i].name
    displayName: contains(policySetDefinitions[i].properties, 'displayName') ? policySetDefinitions[i].properties.displayName : null
    description: contains(policySetDefinitions[i].properties, 'description') ? policySetDefinitions[i].properties.description : null
    metadata: contains(policySetDefinitions[i].properties, 'metadata') ? policySetDefinitions[i].properties.metadata : null
    parameters: contains(policySetDefinitions[i].properties, 'parameters') ? policySetDefinitions[i].properties.parameters : null
    policyDefinitionGroups: contains(policySetDefinitions[i].properties, 'policyDefinitionGroups') ? policySetDefinitions[i].properties.policyDefinitionGroups : null
    policyDefinitions: map(range(0, length(policySetDefinitions[i].properties.policyDefinitions)), c => {
        policyDefinitionReferenceId: contains(policySetDefinitions[i].properties.policyDefinitions[c], 'policyDefinitionReferenceId') ? policySetDefinitions[i].properties.policyDefinitions[c].policyDefinitionReferenceId : null
        policyDefinitionId: replace(policySetDefinitions[i].properties.policyDefinitions[c].policyDefinitionId, '{policyLocationResourceId}', managementGroupId)
        parameters: contains(policySetDefinitions[i].properties.policyDefinitions[c], 'parameters') ? policySetDefinitions[i].properties.policyDefinitions[c].parameters : null
        groupNames: contains(policySetDefinitions[i].properties.policyDefinitions[c], 'groupNames') ? policySetDefinitions[i].properties.policyDefinitions[c].groupNames : null
      })
  })
```

Lastly, same as the policy definition template, I called the [Policy Initiative module](https://github.com/tyconsulting/BlogPosts/blob/master/Azure-Bicep/policy-initiatives/main.bicep#L29-L34) using the formatted array `mappedPolicySetDefinitions` as the parameter:

```terraform
module policyInitiatives '../../BicepModules/authorization/policy-set-definition/main.bicep' = {
  name: take('policySetDef-${deploymentNameSuffix}', 64)
  params: {
    policySetDefinitions: mappedPolicySetDefinitions
  }
}
```

## Conclusion

I have decided to publish these 2 updated modules in my own GitHub repo instead of trying to contributing back to the [CARML](https://aka.ms/carml) or [AVM](https://aka.ms/avm) projects because I am not sure if CARML team will accept this non-standard change. And since CARML is being transitioned to AVM at the moment, the policy related modules have not been transitioned or planned for AVM according to the AVM website. From the website, I was not able to find if an AVM module owner has been identified for the policy modules (and I cannot put my hand up to own these modules because the module owners for AVM must be Microsoft FTEs).

I hope these updated modules will help you to deploy custom policy definitions and initiatives more efficiently. Feel free to reach out to me if you have any questions or feedback.
