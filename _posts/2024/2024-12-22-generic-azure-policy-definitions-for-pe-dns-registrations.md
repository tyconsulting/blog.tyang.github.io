---
title: Generic Azure Policy Definitions for Private Endpoint DNS Registrations
date: 2024-12-22 22:00
author: Tao Yang
permalink: /2024/12/21/generic-azure-policy-definitions-for-pe-dns-registrations
summary: Generic Azure Policy Definitions for Private Endpoint DNS Registrations
categories:
  - Azure
tags:
  - Azure
  - Azure Policy
---

I have previously blogged [Using Azure Policy to create DNS records for Private Endpoints.](https://blog.tyang.org/2023/01/26/using-azure-policy-to-create-dns-records-for-private-endpoints). The problem with these policies are they are largely the same. If you create individual policy definitions for each Azure service that supports Private Endpoints, you will end up with a lot of policy definitions that are almost identical.

I have created a set of generic Azure Policy definitions that can be used to create DNS records for Private Endpoints for any Azure service that supports Private Endpoints. The policy definitions are available in my GitHub `azurepolicy` repo [HERE](TBD).

After examining the use cases, I came to conclusion that other than the resource types, group IDs and Private DNS Zone names, which can be easily parameterised, the only other differences between the Private Endpoint's DNS settings are:

1. Number of Private DNS zones required for the Private Endpoints
2. Region-specific or region-agnostic DNS zones (if a region name is embedded in the DNS zone name)

I have categorised the following scenarios and created generic policy definition for each scenario:

1. [Private Endpoints require a single DNS zone that is region agnostic](https://github.com/tyconsulting/azurepolicy/blob/master/policy-definitions/private-endpoint-dns-registration-generic/pol-deploy-pe-dns-records-single-dns-zone-all-locations.json). For example, all supported Private Endpoints for Storage Accounts, Azure SQL Database, etc.
2. [Private Endpoints require a single DNS zone that is region-specific](https://github.com/tyconsulting/azurepolicy/blob/master/policy-definitions/private-endpoint-dns-registration-generic/pol-deploy-pe-dns-records-single-dns-zone-single-location.json). For example, Azure Container Apps,etc.
3. [Private Endpoints require multiple DNS zones that are region-specific](https://github.com/tyconsulting/azurepolicy/blob/master/policy-definitions/private-endpoint-dns-registration-generic/pol-deploy-pe-dns-records-multiple-dns-zones-single-location.json). For example, Azure Data Explorer, Azure Recovery Services (Azure Backup and Site Recovery), etc.
4. [Private Endpoints require multiple DNS zones that are region agnostic](https://github.com/tyconsulting/azurepolicy/blob/master/policy-definitions/private-endpoint-dns-registration-generic/pol-deploy-pe-dns-records-single-dns-zone-all-locations.json). For example, PowerBI, Azure Monitor Private Link Scope (AMPLS), etc.

I have also created a [sample Policy initiative](https://github.com/tyconsulting/azurepolicy/blob/master/initiative-definitions/sample-private-endpoint-dns-registration-initiative/polset-deploy-pe-dns-records.json) that uses these definitions.To minimise the input parameters for this policy initiative (i.e. there is no need to specify the resource Id of each Private DNS zone), in my environment, I have placed all the Private DNS zones for Private Links in a single resource group, I only needed to specify the resource group Id in this initiative.

The sample initiative included Private Endpoint DNS registration for the following resources:

- Azure Storage Account (blob, file, dfs) - Scenario 1
- Azure Key Vault - Scenario 1
- Azure App Service (website) - scenario 1
- Azure EventHub Namespace - Scenario 1
- Azure Databricks browser_authentication PE - Scenario 1
- Azure Databricks databricks_ui_api PE - Scenario 1
- Azure Container Registry for AustraliaEast region - Scenario 1
- Azure Container App Managed Environment PE for AustraliaEast region - Scenario 2
- Azure Recovery Services Vault AzureBackup PE for AustraliaEast region - Scenario 3
- Azure Data Explorer for AustraliaEast region - Scenario 3
- Azure Monitor Private Link Scope (AMPLS) - Scenario 4
- Azure Healthcare Data Services workspace - Scenario 4

What I like about this initiative is you can keep adding more and more Private Endpoint resources to the initiative without creating additional policy definitions and without having to hardcode Private DNS Zone resource Ids as default values as long as all the DNS zones are kept in the same resource group.

To create your own Initiative, use this article as a reference on what Private DNS zones are required for each Private Link resource type: [Azure Private Endpoint private DNS zone values](https://learn.microsoft.com/azure/private-link/private-endpoint-dns).
