---
title: Using Policy Metadata in Azure Policy Initiatives
date: 2023-01-28 17:00
author: Tao Yang
permalink: /2023/01/28/using-policy-metadata-in-azure-policy-initiatives
summary:
categories:
  - Azure
tags:
  - Azure
  - Azure Policy
---

When checking the Policy Compliance status on Azure Portal, if you click on an policy assignment for a Initiative, you may have noticed some of the policy initiatives have grouped individual policies based on the security control so it provided you an aggregated view on which security control is compliant or not compliant. i.e. the screenshot below is the compliance status for the Azure Security Benchmark initiative, which has grouped the individual policies based on the security requirements:

![1](../../../../assets/images/2023/01/policy-metadata-01.jpg)

When defining Azure Policy Initiative definitions, you have the ability to map individual member policies to the particular security controls from the security standard / framework that your organization has adopted, as long as the standard / framework is supported by Azure. This is done by defining the [Policy Metadata](https://learn.microsoft.com/en-us/azure/governance/policy/concepts/initiative-definition-structure#metadata-objects) in the Azure Policy Initiative definition.

It's pretty easy to add the policy metadata into the initiative definitions. Let's use the Azure Security Benchmark policy initiative as an example again, if you look at the definition in JSON, it contains a `policyDefinitionGroups` property which contains all the security control (policy metadata) that are used by the member policies:

![2](../../../../assets/images/2023/01/policy-metadata-02.jpg)

Also, for each member policy in the `policyDefinitions` property, you can map one or more groups defined in the `policyDefinitionGroups` property.

![3](../../../../assets/images/2023/01/policy-metadata-03.jpg)

>**NOTE:** A member policy can be a member of multiple groups. This is common if a single policy is used to address multiple security controls.

For each policy definition group, the `additionalMetadataId` is the unique identifier of the pre-defined security control. These objects are defined by Microsoft, I don't believe you can add your own controls to your environment if the security standard you are following is not supported by Azure.

You can find the detail of each metadata object using the [REST API](https://learn.microsoft.com/en-us/rest/api/policy/policy-metadata/get-resource?tabs=HTTP) `GET https://management.azure.com/providers/Microsoft.PolicyInsights/policyMetadata/{resourceName}?api-version=2019-10-01`

For example, if I want to look up the details for `Azure_Security_Benchmark_v3.0_NS-1`, I would invoke a `GET` request to `https://management.azure.com/providers/Microsoft.PolicyInsights/policyMetadata/Azure_Security_Benchmark_v3.0_NS-1?api-version=2019-10-01` (in this case, I'm using [Postman](https://www.postman.com/) to make the request):

![4](../../../../assets/images/2023/01/policy-metadata-04.jpg)

When creating Policy Initiative definitions, I would always use Postman to invoke this API to make sure the Policy Metadata is correctly defined the mapped to each member policy.

In addition to the REST API, an easier way is probably using Azure PowerShell to export all available policy metadata objects into a CSV file and then use Excel to search for the metadata object you are looking for:

```powershell
get-azpolicyMetadata | Export-Csv .\policy_metadata.csv
```

![5](../../../../assets/images/2023/01/policy-metadata-05.jpg)

I often get asked by customer's security team how to query all non-compliant resources for specific security control. As long as we have mapped correct Policy Metadata to each member policy in the initiative, and we follow the best practice that only assign policy initiatives instead of individual policies, this is pretty easy to do using Azure Resource Graph (ARG). For example, if I want to query all non-compliant resources for the security control `iso27001-2013_a.12.4.1`, I would use the following ARG query to get all non-compliant resources:

```OQL
policyresources
| where type == "microsoft.policyinsights/policystates"
| where properties.complianceState =~ "NonCompliant"
| project resourceId = properties.resourceId, subscriptionId = properties.subscriptionId, policyDefinitionId = properties.policyDefinitionId, policyDefinitionName=properties.policyDefinitionName, policyAssignmentId = properties.policyAssignmentId, policyDefinitionReferenceId=properties.policyDefinitionReferenceId, policyDefinitionGroupNames = properties.policyDefinitionGroupNames
| where policyDefinitionGroupNames contains "iso27001-2013_a.12.4.1"
```

![6](../../../../assets/images/2023/01/policy-metadata-06.jpg)

If you have not used Policy Metadata in your initiative definitions before, I strongly recommend you to give it a try. Your security team will thank you for that for sure!
