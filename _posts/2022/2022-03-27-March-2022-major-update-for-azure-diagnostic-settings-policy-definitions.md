---
title: March 2022 Major Update for Azure Diagnostic Settings Policy Definitions
date: 2022-03-27 18:30
author: Tao Yang
permalink: /2022/03/27/march-2022-major-update-for-azure-diagnostic-settings-policy-definitions/
summary:
categories:
  - Azure
tags:
  - Azure
  - Azure Policy
---

I haven't revisited the [Resource Diagnostics Settings policy definitions](https://github.com/tyconsulting/azurepolicy/tree/master/policy-definitions/resource-diagnostics-settings) since October 2020. A lot has changed since then. An update is long-overdue.

I have updated this set of policy definitions in my [azurepolicy](https://github.com/tyconsulting/azurepolicy/tree/master/policy-definitions/resource-diagnostics-settings) GitHub repo.

Here's the **Change Log**:

### Added

- Parameterized the policy effect
- Parameterized the enablement for logs and metrics by adding parameters `LogsEnabled` and `MetricsEnabled`
- Added a parameter for [EvaluationDelay](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/effects#deployifnotexists-properties) (Default to `AfterProvisioning`)
- Added support for Logs [Category Groups](https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings?tabs=CMD#resource-logs) for all applicable resources
- Added metadata fields
  - category: Monitoring
  - version: 2.0.0
  - preview: false
  - depreciated: false
- Added support for dedicated table in Log Analytics ([Resource-specific](https://docs.microsoft.com/en-us/azure/azure-monitor/reference/tables/azurediagnostics#azure-diagnostics-mode-or-resource-specific-mode)) for the following applicable resource types:
  - API Management
  - Cosmos DB
  - Data Factory V2
  - IoT Hub
  - Recovery Services Vault
- Added new resource types
  - Recovery Services Vault
  - Azure Data Bricks (Premium SKU)
  - EventGrid System Topic
  - Azure Front Door
  - Function App
  - MariaDB
  - Machine Learning Workspace
  - Azure Subscription
  - Synapse Analytics
  - Virtual Machine
  - Virtual Machine Scale Set

### Changed

- Renamed parameter `DiagnosticSettingNameToUse` to `profileName`
- Updated metrics and logs category for various resource types
- Updated role definitions for policies for sending metrics and logs to Log Analytics workspaces
- Updated API version to `2021-05-01-preview` for diagnostic settings

### Fixed

- Various bug fixes

### Removed

- removed obsolete resource types
  - Azure Backup
  - Azure Site Recovery (ASR)
  - Azure Synapse Pool (consolidated with Azure SQL Database)
  - LogicApp Integration Service Environment

### Known Issues

#### Azure App Service (Microsoft.Web/sites)

The log category for Azure App Service is different between `Standard` and `Premium` tiers. The logs cannot be accurately covered based on the App Service SKU due to the following reasons:

1. At the time of writing, there is no `Policy Alias` for App Service SKU
2. At the time of writing, the Log Category Groups are not supported for the Azure App Service Diagnostic Settings

Due to these limitations, only the common logs that are available for both `Standard` and `Premium` SKUs are selected.

**[2022-03-30 Update]:** Jorge Arteiro ([@JorgeArteiro](https://twitter.com/JorgeArteiro)), Bernie White ([@BernieAWhite](https://twitter.com/BernieAWhite)) and I have produced a video for PSRule, and published on his [@AzureTar](https://twitter.com/azuretar) YouTube Channel:

<iframe src="//www.youtube.com/embed/3697rG8tkOI" height="375" width="640" allowfullscreen="" frameborder="0"></iframe>
