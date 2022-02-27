---
title: Azure Bicep Module for Management Group Hierarchy
date: 2022-02-27 16:00
author: Tao Yang
permalink: /2022/02/27/management-group-bicep-module
summary:
categories:
  - Azure
tags:
  - Azure
  - Azure Bicep

---

Few years ago, I published a solution to create Azure Management Group hierarchy using a [PowerShell script and Azure Pipeline](https://blog.tyang.org/2019/09/08/configuring-azure-management-group-hierarchy-using-azure-devops/). Back then, I couldn't configure Management Group hierarchy natively using ARM templates because it wasn't possible to deploy tenant level resources via ARM templates.

Since tenant level deployments are possible now with ARM template / Bicep, I have created a new Bicep module to create the Management Group hierarchy in an Azure tenant. This module can be used to create:

1. One or more management groups in a hierarchy
2. Configure default management group for new subscriptions([doc](https://docs.microsoft.com/en-au/azure/governance/management-groups/how-to/protect-resource-hierarchy#setting---default-management-group))
3. Configure permissions for creating new management groups([doc](https://docs.microsoft.com/en-au/azure/governance/management-groups/how-to/protect-resource-hierarchy#setting---require-authorization))

The module and the sample template can be found from my BlogPost GitHub repo **[HERE](https://github.com/tyconsulting/BlogPosts/tree/master/Azure-Bicep/management.group)**.

Since there is a hard limit of maximum 6 tiers in the management group hierarchy (excluding the tenant root management group), I have coded the module to take each tier as an [optional parameter](https://github.com/tyconsulting/BlogPosts/blob/master/Azure-Bicep/management.group/module/managementGroupHierarchy.bicep#L3-L19) (```tier1MgmtGroups```...```tier6MgmtGroups```). Each parameter is an array of object that looks for the following properties:

* **id**: The Id / name of the Management Group
* **displayName**: The display name of the Management Group
* **parentId**: The Id of the parent Management Group (not required for ```tier1MgmtGroups``` parameter)

The sample template and parameter file below deploys a reference Management Group hierarchy from the Microsoft Azure Enterprise-Scale framework. It also creates an additional management group called "Quarantine" which becomes the default management group for any new subscriptions (if the management group is not specified when creating the subscription).

### Template

```hcl
targetScope = 'tenant'

@description('Tier 1 management groups')
param tier1MgmtGroups array = []

@description('Tier 2 management groups')
param tier2MgmtGroups array = []

@description('Tier 3 management groups')
param tier3MgmtGroups array = []

@description('Tier 4 management groups')
param tier4MgmtGroups array = []

@description('Tier 5 management groups')
param tier5MgmtGroups array = []

@description('Tier 6 management groups')
param tier6MgmtGroups array = []

@description('Optional. Default Management group for new subscriptions.')
param defaultMgId string = ''

@description('Optional. Indicates whether RBAC access is required upon group creation under the root Management Group. Default value is true')
param authForNewMG bool = true

@description('Optional. Indicates whether Settings for default MG for new subscription and permissions for creating new MGs are configured. This configuration is applied on Tenant Root MG.')
param configMGSettings bool = false

module mg_hierarchy './module/managementGroupHierarchy.bicep' = {
  name: 'management_groups'
  params: {
    tier1MgmtGroups: tier1MgmtGroups
    tier2MgmtGroups: tier2MgmtGroups
    tier3MgmtGroups: tier3MgmtGroups
    tier4MgmtGroups: tier4MgmtGroups
    tier5MgmtGroups: tier5MgmtGroups
    tier6MgmtGroups: tier6MgmtGroups
    defaultMgId: defaultMgId
    authForNewMG: authForNewMG
    configMGSettings: configMGSettings
  }
}

output managementGroups array = mg_hierarchy.outputs.managementGroups
output root_mg_settings object = mg_hierarchy.outputs.root_mg_settings
output tier_1_mgs array = mg_hierarchy.outputs.tier_1_mgs
output tier_2_mgs array = mg_hierarchy.outputs.tier_2_mgs
output tier_3_mgs array = mg_hierarchy.outputs.tier_3_mgs
output tier_4_mgs array = mg_hierarchy.outputs.tier_4_mgs
output tier_5_mgs array = mg_hierarchy.outputs.tier_5_mgs
output tier_6_mgs array = mg_hierarchy.outputs.tier_6_mgs
```

### Template Parameter file

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "metadata": {
    "template": "./main.json"
  },
  "parameters": {
    "tier1MgmtGroups": {
      "value": [
        {
          "id": "TYANG",
          "displayName": "TYANG MGMT Root"
        }
      ]
    },
    "tier2MgmtGroups": {
      "value": [
        {
          "id": "TYANG-Platform",
          "displayName": "Platform Management",
          "parentId": "TYANG"
        },
        {
          "id": "TYANG-LandingZones",
          "displayName": "Landing Zones",
          "parentId": "TYANG"
        },
        {
          "id": "TYANG-Sandbox",
          "displayName": "Sandbox",
          "parentId": "TYANG"
        },
        {
          "id": "TYANG-Quarantine",
          "displayName": "Quarantine",
          "parentId": "TYANG"
        },
        {
          "id": "TYANG-Decommissioned",
          "displayName": "Decommissioned",
          "parentId": "TYANG"
        }
      ]
    },
    "tier3MgmtGroups": {
      "value": [
        {
          "id": "TYANG-Platform-Connectivity",
          "displayName": "Connectivity",
          "parentId": "TYANG-Platform"
        },
        {
          "id": "TYANG-Platform-Identity",
          "displayName": "Identity",
          "parentId": "TYANG-Platform"
        },
        {
          "id": "TYANG-Platform-Management",
          "displayName": "Management",
          "parentId": "TYANG-Platform"
        },
        {
          "id": "TYANG-LandingZones-Corp",
          "displayName": "Corp",
          "parentId": "TYANG-LandingZones"
        },
        {
          "id": "TYANG-LandingZones-Online",
          "displayName": "Online",
          "parentId": "TYANG-LandingZones"
        }
      ]
    },
    "authForNewMG": {
      "value": true
    },
    "defaultMgId": {
      "value": "TYANG-Quarantine"
    },
    "configMGSettings": {
      "value": true
    }
  }
}
```

This template deploys a Management Group hierarchy and settings as show below:

![01](../../../../assets/images/2022/02/mgmt-group-01.jpg)

![02](../../../../assets/images/2022/02/mgmt-group-02.jpg)
