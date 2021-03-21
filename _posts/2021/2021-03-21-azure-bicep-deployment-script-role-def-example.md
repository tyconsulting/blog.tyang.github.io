---
title: Azure Bicep, Deployment Script and Role Definition Code Example
date: 2021-03-21 16:00
author: Tao Yang
permalink: /2021/03/21/azure-bicep-deployment-script-role-def-example/
summary: 
categories:
  - Azure
tags:
  - Azure
  - Azure Bicep
---

Firstly, apologies for not been too active in writing blog posts lately because I have been really busy with my current project. 

[Azure Bicep](https://github.com/azure/bicep) has recently reached an important millstone when version 0.3 was announced. v0.3 is now officially supported by Microsoft support plans and it's on parity with ARM templates.

[Azure Deployment script](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/deployment-script-template?WT.mc_id=DOP-MVP-5000997) has been on my to-do list for blogging for a long time. I have listed a number of valid use cases where Deployment Scripts makes perfect sense. Now that Azure Bicep is officially supported by Microsoft and the language syntax should be more stable from now on, I think it's logical for me to cover these use cases in Bicep.

The use case I want to cover today is deploying custom Role Definitions. A role definition is made up from the following parts:

* Name
* Id (GUID)
* Description
* Actions (allowed actions)
* NotActions (disallowed actions)
* **AssignableScopes**

A role definition can only have 1 instance in an AAD tenant. When you firstly deploy it, you will need to define where the role can be assigned (via the AssignableScopes property). After the role definition is deployed, if you need to make it available to other subscriptions or management groups, you must modify the Assignable Scope by adding additional scopes. Based on my experience with the latest API version for role definitions that is documented on the ARM API documentation (2018-01-01-preview), if I deploy a template containing the role definition with different AssignableScopes, it will overwrite the original definition. In another word, if I initially deployed a role definition and made it assignable in subscription A, then I deployed it again to subscription B (and assignable to subscription B), the role definition will no longer be assignable for subscription A.

This has been a pain for me in the past, I know a good workaround is making custom role definitions assignable on the management group levels so they are available for all subscriptions under the management group hierarchy, but in real life, for various reasons, there are still many cases where customers may not use management groups for certain role definitions. In the past, I was using CICD pipelines to deploy role definitions by creating scripts and detection logics to determine if a new definition should be created or an existing definition needs to be modified.

Now to do this natively using only ARM templates (or Bicep in this case), I was able to create 2 simple deployment scripts within my template to cover both new and existing scenarios.

>**NOTE:** the source code of this example solution is located in my [GitHub repo](https://github.com/tyconsulting/BlogPosts/tree/master/Azure-Bicep/role.definitions).

Here's the logical flow for my template:

pre-requisite: A user assigned managed identity with required permissions to create role definitions for all the subscriptions I want to manage. In my lab, I assigned this identity Owner role on the tenant Root management group level. This managed identity is required for the deployment scripts.

1. Create a resource group and a storage account within the RG (for deployment scripts)
2. Create a deployment script to discovery if the role definition already exists
3. If the definition doesn't exist, deploy it with the AssignableScopes set to the target subscription
4. If the definition already exists, create a deployment script to check the AssignableScopes of the existing definition, add the target subscription to the existing AssignableScopes if it's not already added.

To achieve what I need to do, I must use a subscription level template with nested templates due to the following reasons:

1. I'm deploying both subscription level resources (resource group, role definitions) and resource group level resources (storage account, deployment scripts)
2. I need to use the output of the role definition discovery deployment script as the conditions for the role definition and the role update deployment scripts. Since I cannot directly use the output of a resource in the condition for another resource because the outputs only becomes available during run time and this is not supported by ARM templates, I had to use nested templates so I can pass the discovery script output as an input parameter in other nested templates.

As you can imagine, this template can be really complicated to develop using ARM template. Luckily now that with the support of modules in Bicep, I can split them into different bicep files, and each nested template becomes a module in the main Bicep template. The overall authoring experience has become a lot more pleasant. My [main.bicep](https://github.com/tyconsulting/BlogPosts/blob/master/Azure-Bicep/role.definitions/main.bicep) file has only 70 lines:

![](../../../../assets/images/2021/03/image1.png)

The 1st deployment script (for existing role discovery) is defined in [role-discovery.bicep](https://github.com/tyconsulting/BlogPosts/blob/master/Azure-Bicep/role.definitions/role-discovery.bicep. ). 

The 2nd deployment script (for modifying existing role definition) is defined in [role-scope-update.bicep](https://github.com/tyconsulting/BlogPosts/blob/master/Azure-Bicep/role.definitions/role-scope-update.bicep). 

The actual role definition is defined in [role-definition.bicep](https://github.com/tyconsulting/BlogPosts/blob/master/Azure-Bicep/role.definitions/role-definition.bicep).

both scripts are using Azure PowerShell and connect to my Azure environment using the managed identity I created previously.

As you can see, the resource blocks in [role-definition.bicep](https://github.com/tyconsulting/BlogPosts/blob/master/Azure-Bicep/role.definitions/role-definition.bicep#L8) and [role-scope-update.bicep](https://github.com/tyconsulting/BlogPosts/blob/master/Azure-Bicep/role.definitions/role-scope-update.bicep#L11) both have a condition defined. They both use the an input parameter called *roleExists* in the condition, which is the passed in to the module with the value from the [output of the first role discovery deployment script](https://github.com/tyconsulting/BlogPosts/blob/master/Azure-Bicep/role.definitions/role-discovery.bicep#L49):

![](../../../../assets/images/2021/03/image2.png)

![](../../../../assets/images/2021/03/image3.png)

At the time of writing this article, I still find the Azure CLI support for Bicep is a little bit buggy. Somehow I got some exceptions when tried to directly deploy the bicep files, but the same template deployed successfully when I complied bicep to ARM template first (using ```bicep build main.bicep``` command). I am not sure if this is just me, but I ended up switched back to Azure PowerShell and deployed the ARM template that the ```bicep build``` command generated, it ran for few minutes, and when I tried to deploy the definition to a subscription which is already in the AssignableScopes, instead of overwriting the existing definition, the template deployment simply did not make any changes. This is the output I received from the template deployment:

![](../../../../assets/images/2021/03/image4.png)

This is all I have for today. I will try to cover more use cases for Azure Deployment Scripts in the future.

If you haven't used Azure Bicep, I strongly recommend you to give it a try. I can guarantee you that you will not want to go back to writing ARM templates once you've tried Bicep.
