---
title: Azure Bicep Modules for Azure Policy Resources
date: 2022-12-11 00:00
author: Tao Yang
permalink: /2022/12/11/azure-bicep-modules-for-azure-policy/
summary: Azure Bicep modules and sample templates for Azure Policy resources
categories:
  - Azure
tags:
  - Azure
  - Azure Policy
  - Azure Governance
  - Azure Bicep

---

Although I'm a big fan of Microsoft [CARML](https://aka.ms/carml) Bicep module repo, and have used many of their modules in my projects, Sometimes I still prefer using the modules I have created myself. I created 3 Bicep modules a while back for Azure Policy Definitions, Initiatives and Assignments. They are all created for management-group scoped deployments because I have not had requirements for subscription scoped deployments to date. I have used these modules in several projects now. I thought I'd share with the community, gives you an alternative to the CARML modules.

You can find the modules coupled with sample templates in my [Azure Policy Github repository](https://github.com/tyconsulting/azurepolicy/tree/master/bicep)

## Policy Definition Module

Azure policy definitions are written in JSON format. With the [Policy Definition module](https://github.com/tyconsulting/azurepolicy/tree/master/bicep/modules/policyDefinitions) takes a JSON payload as an input and parses it to get all attributes that Bicep requires. When deploying multiple policy definitions in bulk, you can also use the `@batchsize` decorator to control the concurrent deployments. I was able to use this module to deploy 100+ policy definitions in a single deployment in a timely manner.

For example:

```hcl
targetScope = 'managementGroup'

//specify th relative path to the policy definition JSON files in the loadTextContent function
var PolicyDefinitions = [
  loadTextContent('pol-control-preview-api.json')
  loadTextContent('pol-required-minimum-api-version.json')
  loadTextContent('pol-restrict-to-specific-api-version.json')
  loadTextContent('pol-inherit-tags-from-sub.json')
]

//use the @batchSize decorator to control the concurrent deployments
@batchSize(15)
module policyDefs '../../modules/policyDefinitions/main.bicep' = [for (definition, i) in PolicyDefinitions: {
  name: 'policy_definitions_${i}'
  params: {
    policyDefinition: definition
  }
}]

//outputs
output policyDefNames array = [for (definition, i) in PolicyDefinitions: json(definition).name]
output policies array = [for (definition, i) in PolicyDefinitions: {
  resourceId: policyDefs[i].outputs.resourceId
  name: policyDefs[i].outputs.name
}]

```

>**NOTE**: This sample template above is located [here](https://github.com/tyconsulting/azurepolicy/tree/master/bicep/templates/policyDefinitions)

## Policy Initiative (Policy Set) Module

Similar to the Policy Definition module, the [Policy Initiative module](https://github.com/tyconsulting/azurepolicy/tree/master/bicep/modules/policySetDefinitions) can be used together with the `loadTextContent()` bicep function so you can easily deploy existing Policy initiative definition JSON files.

For example:

```hcl
targetScope = 'managementGroup'

@description('Policy Definition Source Management Group Id')
param managementGroupId string = managementGroup().id

// ------Read policy initiative definitions from json files------
var tagPolicySetDefinitionFromFile = json(loadTextContent('polset-tags.json'))

// ------replace resource Ids in policy set definitions------
var tagPolicyDefinitions = [for policy in tagPolicySetDefinitionFromFile.properties.policyDefinitions: {
  policyDefinitionId: replace(policy.policyDefinitionId, '{policyLocationResourceId}', managementGroupId)
  policyDefinitionReferenceId: policy.policyDefinitionReferenceId
  parameters: policy.parameters
  groupNames: policy.groupNames
}]

// ------Construct payload for the Policy Initiative bicep module------
var tagPolicySetDefinition = {
  name: tagPolicySetDefinitionFromFile.name
  properties: {
    displayName: tagPolicySetDefinitionFromFile.properties.displayName
    description: tagPolicySetDefinitionFromFile.properties.description
    metadata: tagPolicySetDefinitionFromFile.properties.metadata
    parameters: tagPolicySetDefinitionFromFile.properties.parameters
    policyDefinitionGroups: tagPolicySetDefinitionFromFile.properties.policyDefinitionGroups
    policyDefinitions: tagPolicyDefinitions
  }
}

//------Deploy Policy Initiatives------

module tagPolicyInitiative '../../modules/policySetDefinitions/main.bicep' = {
  name: tagPolicySetDefinitionFromFile.name
  params: {
    policySetDefinition: tagPolicySetDefinition
  }
}

//------ Outputs ------
output tagPolicySetDefinition object = tagPolicySetDefinition

```

In this example, I'm deploying a policy initiative defined in the [`polset-tags.json`](https://github.com/tyconsulting/azurepolicy/blob/master/bicep/templates/policySetDefinitions/polset-tags.json) file. The `loadTextContent()` function is used to read the JSON file.

In the Policy Initiative definition JSON file, I have defined the member policy location as below:

`"policyDefinitionId": "{policyLocationResourceId}/providers/Microsoft.Authorization/policyDefinitions/pol-inherit-tags-from-sub",`

The Bicep template uses the `replace()` function to replace the `{policyLocationResourceId}` placeholder with the management group Id (in this example, assuming the member policies are located at the same management group as the policy initiative).

>**NOTE**: The sample template above is located [here](https://github.com/tyconsulting/azurepolicy/blob/master/bicep/templates/policySetDefinitions/main.bicep)

## Policy Assignment Module

The [policy assignment module](https://github.com/tyconsulting/azurepolicy/tree/master/bicep/templates/PolicyAssignments) is used to assign policy definitions or policy initiatives to a management group scope. It can also create role assignments for Policy Assignments Managed Identity, which is required for policies with `DeployIfNotExists` and `Modify` effects.

For example:

```hcl
targetScope = 'managementGroup'

@sys.description('Optional. Location for all resources.')
param location string = deployment().location

@sys.description('Managed identity type. Managed identity is required for policies with DeployIfNotExists or Modify effects. Possible values are "UserAssigned", "systemAssigned" and "None". Default value is "None".')
@allowed([
  'SystemAssigned'
  'UserAssigned'
  'None'
])
param assignmentIdentityType string = 'SystemAssigned'

@description('Optional. Policy Definition Source Management Group Id. Default to the target management group')
param definitionSourceManagementGroupId string = managementGroup().id

@sys.description('Optional. Policy Assignment Scope. Default to the target management group')
param assignmentScope string = managementGroup().id

//--------- Tagging Parameters ---------
@sys.description('Required. Tagging Policy Assignment Name')
@maxLength(24)
param tagAssignmentName string

@sys.description('Tagging Initiative definition Id')
param tagPolicyDefinitionId string

@sys.description('Tagging Policy Assignment Parameters')
param tagAssignmentParameters object

@sys.description('Required. The display name of the Tagging policy assignment. Maximum length is 128 characters.')
@maxLength(128)
param tagAssignmentDisplayName string

@sys.description('Optional. The IDs Of the Azure Role Definition list that is used to assign permissions to the Tagging policy assignment identity. You need to provide either the fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'.. See https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles for the list IDs for built-in Roles. They must match on what is on the policy definition')
param tagAssignmentRoleDefinitionIds array = []

@sys.description('The Tagging policy assignment enforcement mode. Possible values are Default and DoNotEnforce.')
@allowed([
  'Default'
  'DoNotEnforce'
])
param tagAssignmentEnforcementMode string = 'Default'

@sys.description('Tagging Policy assignment metadata')
param tagAssignmentMetadata object = {}

@sys.description('Optional. The Tagging policy assignment excluded scopes')
param tagAssignmentNotScopes array = []


//--------- variables ---------
var assignedByMetadata = {
  assignedBy: 'TYANG Policy Assignment Pipeline'
}
//--------- policy assignments ---------


module tagAssignment '../../modules/policyAssignments/main.bicep' = {
  name: tagAssignmentName
  params: {
    name: tagAssignmentName
    description: 'Implement resource tagging requirements'
    displayName: tagAssignmentDisplayName
    policyDefinitionId: replace(tagPolicyDefinitionId, '{policyLocationResourceId}', definitionSourceManagementGroupId)
    parameters: tagAssignmentParameters
    scope: assignmentScope
    location: location
    identityType: assignmentIdentityType
    roleDefinitionIds: tagAssignmentRoleDefinitionIds
    enforcementMode: tagAssignmentEnforcementMode
    metadata: union(tagAssignmentMetadata, assignedByMetadata)
    notScopes: tagAssignmentNotScopes
    nonComplianceMessage: 'The resource configuration is not aligned with resource tagging requirements.'
  }
}

//--------- outputs ---------

@sys.description('Tagging Policy Assignment resource ID')
output tagAssignmentResourceId string = tagAssignment.outputs.resourceId
```

This sample bicep template requires parameter inputs, which can be defined in a parameter file. It adds the `assignedBy` metadata to existing assignment metadata, and similar to the Policy Initiative sample, it replaces the `{policyLocationResourceId}` token with the `definitionSourceManagementGroupId` parameter.

>**NOTE**: The sample template above is located [here](https://github.com/tyconsulting/azurepolicy/blob/master/bicep/templates/PolicyAssignments/main.bicep)

## Conclusion

I was able to use these modules in Azure DevOps pipelines to deploy policy resources in scale. Since Policy definitions will need to be in place before creating Policy Initiatives and assignments, the order of deployments would be:

1. Deploy Policy Definitions
2. Deploy Policy Initiatives
3. Deploy Policy Assignments
4. Optionally create policy remediation tasks to remediate non-compliant existing resources