---
title: Policy Restriction REST API for Azure Policy
date: 2024-12-24 00:00
author: Tao Yang
permalink: /2024/12/24/2024-12-24-azure-policy-restriction-rest-api
summary: How to use Azure Policy Restriction API to check restrictions for resource configuration
categories:
  - Azure
  - Azure Policy
  - PowerShell
tags:
  - Azure
  - Azure Policy
  - PowerShell
---

A common question about Azure Policy I frequently get asked during customer engagements is how can a user find out what restrictions are applied for a given resource in their landing zones.

Customers often find it hard to make their resource configurations working with Azure policies, due to the lack of visibility to the assigned policies, and lack of knowledge about Azure Policy in general so even when they have access to the policy code, it's can still be difficult to understand what restrictions are applied.

In the past, I have always recommended customers to leverage the Azure Resource Manager `What-If` feature to simulate the deployment of resources and see what policies are applied. However, there are many limitations with this approach, to name a few:

- What-If only works with ARM / Bicep. There is no Terraform equivalent. Last time I checked, `terraform plan` does not evaluate Azure Policies.
- WHat-If supports `Deny` policy effect but it does not work with `Audit` / `AuditIfNotExists` policies.
- What-If results are not 100% correct and it can generate a lot of noise.
- What-If does not work well with Bicep modules. Resources created by modules (nested resource deployments) can be a hit and miss.

The other day when I was checking the REST API documentation in the `Microsoft.PolicyInsights` resource provider, I noticed an API that I didn't know about: [Policy Restrictions](https://learn.microsoft.com/rest/api/policy/policy-restrictions?view=rest-policy-2023-03-01).

There are 3 similar APIs, one for each deployment scope ([Management Group](https://learn.microsoft.com/rest/api/policy/policy-restrictions/check-at-management-group-scope?view=rest-policy-2023-03-01&tabs=HTTP), [Subscription](https://learn.microsoft.com/rest/api/policy/policy-restrictions/check-at-subscription-scope?view=rest-policy-2023-03-01&tabs=HTTP) and [Resource Group](https://learn.microsoft.com/rest/api/policy/policy-restrictions/check-at-resource-group-scope?view=rest-policy-2023-03-01&tabs=HTTP)). These APIs can be used to check what restrictions Azure Policy will place on resources within the deployment scope.

I got pretty excited when I saw these APIs, and also surprised they are not offered as commands in Azure PowerShell `az` module or `Azure CLI`. At the time of writing this post (December 2024), I have checked PowerShell `az` module version `13.0.0` and `Azure CLI` version `2.67.0`.

I have spent some time playing with these APIs today and managed to create a PowerShell Function that can help people invoking these APIs.

You can find my PowerShell function `Get-AzPolicyRestriction` at my `BlogPost` GitHub repo [HERE](https://github.com/tyconsulting/BlogPosts/blob/master/Scripts/Azure/AzPolicyRestriction.ps1).

Based on What I was able to find by testing, you can pass the following of parameters via the request body:

- `pendingFields`: The list of fields (name, location, tags and type) and values that should be evaluated for potential restrictions.
  - When specifying `name` and `location` fields, the values must be specified for these fields as an array.
  - When specifying the `type` field, the values are optional for the `type` field. This is the only field supported for the Management Group level API and it must not contain a value.
  - When specifying the `tags` field, no values are required.
- `resourceDetails`: The information about the resource that will be evaluated. `resourceDetails` is only supported for Subscription and Resource Group level APIs. You can specify the following in this section:
  - `apiVersion`:  The api-version of the resource content.
  - `resourceContent`: The resource content. This should include whatever properties are already known and can be a partial set of all resource properties.
  - `scope`: The scope where the resource is being created. For example, if the resource is a child resource this would be the parent resource's resource ID.
- `includeAuditEffect`: Whether to include policies with the 'audit' effect in the results. `includeAuditEffect` is only supported for Subscription and Resource Group level APIs.

This API provides a quick way for users to check if a set of specific configuration in their resource is going to be allowed / denied by Azure Policy.

For example, I invoked the Resource Group level API using the PowerShell function with the following parameters:

- resource name
- location
- resource type: 'Microsoft.Storage/StorageAccounts' (Azure Storage Account)
- property to check: `minimumTlsVersion` with value `TLS1_1`

This request will check if this specific storage account created in the list of given regions in a given resource group can have the Minimum TLS version set to `1.1`.

![01](../../../../assets/images/2024/12/policy-restriction-01.jpg)

To make the result more readable, I have convert it to Json:

![02](../../../../assets/images/2024/12/policy-restriction-02.jpg)

The result shows the evaluation failed due to the target value should be `TLS1_2`, as well as the details of the offending policy.

Here's another example, i'm invoking the subscription level API to check what tags are required when creating a storage account

![03](../../../../assets/images/2024/12/policy-restriction-03.jpg)

The result suggests there is one mandatory tag called `dataClass` is required and the value must be configured in one of the three allowed values

![04](../../../../assets/images/2024/12/policy-restriction-04.jpg)

I can also check what resource types are not allowed in a management group scope. This is the only supported scenario for the Management Group level API.

![05](../../../../assets/images/2024/12/policy-restriction-05.jpg)

The result shows there are a list of resources that are not allowed to be deployed under this specific management group.

These APIs gives users a quick way to validate one or more specific resource configuration before creating the resources. However, as the name suggested, it is only checking the policy restrictions. In terms of Policy Effect, only `Deny` and `Audit` are supported. Other effects such as `DeployIfNotExists` and `Modify` are not supported.

I hope one day these APIs end up in the Azure CLI and PowerShell modules as I can see them being used to solve the problem I mentioned in the beginning of this post.
