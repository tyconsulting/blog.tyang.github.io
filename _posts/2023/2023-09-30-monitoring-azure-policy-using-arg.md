---
title: Natively Monitoring Azure Policy Compliance States in Azure Monitor - 2023 Edition
date: 2023-09-30 20:00
author: Tao Yang
permalink: /2023/09/30/natively0monitoring-azure-policy-compliance-states-in-azure-monitor-2023-edition/
summary: How to natively monitor Azure Policy compliance states using Azure Monitor and Azure Resource Graph
categories:
  - Azure
tags:
  - Azure
  - Azure Policy
  - Azure Monitor
  - Azure Resource Graph
---

## Introduction

This is the 3rd time I'm talking about the topic of monitoring Azure Policy compliance states using Azure Monitor. Previously in 2021, I have created a custom solution using an Azure Function app to ingest policy compliance data into Log Analytics. You can find the blog post here [Monitoring Azure Policy Compliance States - 2021 Edition](https://blog.tyang.org/2021/12/06/monitoring-azure-policy-compliance-states-2021-edition/).

Over the last few years, I have spoken to the Azure governance product group numerous times on the topic of allowing people to query Azure Resource Graph (ARG) within Azure Monitor. Monitoring policy compliance state is a perfect use case for this capability.

Few days ago I came across this post from the Azure Observability Blog : [Query Azure Resource Graph from Azure Monitor](https://techcommunity.microsoft.com/t5/azure-observability-blog/query-azure-resource-graph-from-azure-monitor/ba-p/3918298). I got very excited because I have been waiting for this for years.

Today, I have spent few hours and created a native monitoring solution for Azure Policy compliance states leveraging this new capability using Azure Monitor and Azure Resource Graph. This solution is nothing more than a standard log query alert rule. It is a lot simpler than the solution I created 2 years ago using Azure EventGrid and Azure Function app.

I have codified the solution into an Azure Bicep template and published it to my GitHub repo here: [BlogPosts/Azure-Bicep
/policy.monitor](https://github.com/tyconsulting/BlogPosts/tree/master/Azure-Bicep/policy.monitor)

## Solution Overview

Before deploying the solution, here's a list of pre-requisites:

1. **An existing Log Analytics workspace**
2. **The identity you use to deploy this template must have either the owner or User Access Administrator role on the tenant root level.** This is because the template will create an User Assigned Managed Identity for the alert rule and this managed identity must have the reader role on the tenant root level to be able to query the Azure Resource Graph for all policy compliance states within the entire tenant. **You must assign the permission using Azure CLI or PowerShell. Role Assignments to tenant root cannot be created in the portal. You may use PowerShell command `Add-AzRoleAssignment -ObjectId <add-object-id> -scope / -RoleDefinitionName Owner`.***

The Bicep template creates the following resources:

 * One Azure Monitor action group with one or more email receivers.
 * One User Assigned Managed Identity for the alert rule
 * Tenant level reader role assignment for the managed identity
 * One Alert Rule to query Azure Resource Graph for policy compliance states

Essentially, this is the Kusto query used in the alert rule:

```kusto
arg("").PolicyResources
| where type =~ 'Microsoft.PolicyInsights/PolicyStates'
| extend
complianceState = tostring(properties.complianceState),
resourceId = tostring(properties.resourceId),
resourceType = tolower(tostring(properties.resourceType)),
resourceLocation = tostring(properties.resourceLocation),
policyAssignmentName = tostring(properties.policyAssignmentName),
policyAssignmentId = tostring(properties.policyAssignmentId),
policyDefinitionId = tostring(properties.policyDefinitionId),
policyDefinitionAction = tostring(properties.policyDefinitionAction),
policyDefinitionGroupNames = tostring(properties.policyDefinitionGroupNames),
policyDefinitionReferenceId = tostring(properties.policyDefinitionReferenceId),
policySetDefinitionId = tostring(properties.policySetDefinitioNId),
policySetDefinitionCategory = tostring(properties.policySetDefinitioNCategory),
dtTimeStamp = todatetime(tostring(properties.timestamp))
| where complianceState =~ 'noncompliant'
| where dtTimeStamp >= now(-{0}m)
| project complianceState, id, name, policyAssignmentName, resourceId, resourceType, policyAssignmentId, policyDefinitionId, policySetDefinitionId, policySetDefinitionCategory, policyDefinitionAction, policyDefinitionGroupNames, resourceGroup, resourceLocation,subscriptionId, tenantId, apiVersion, timeStamp=tostring(properties.timestamp)
```

>*Note*: the number in the line `where dtTimeStamp >= now(-{0}m)` is replaced by Bicep `format()` function depending on the alert frequency parameter value.

After the deployment, if there are non-compliant resources in the tenant, you will see alerts been triggered in Azure Monitor like this:

![01](../../../../assets/images/2023/09/alert-rule-arg-policy-compliance-01.jpg)

In the alert details, you will see the non-compliant resource Id, offending policy resource Id and policy assignment resource Id. You should be able to easily find the resource in the Policy Compliance blade in Azure Portal.

Lastly, you can find the official documentation here [Query data in Azure Data Explorer and Azure Resource Graph from Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/azure-monitor-data-explorer-proxy).