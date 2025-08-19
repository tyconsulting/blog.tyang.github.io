---
title: Using Hidden Tags For Managing Azure Bicep Modules
date: 2025-08-19 00:00
author: Tao Yang
permalink: /2025/08/19/using-hidden-tags-for-managing-azure-bicep-modules
summary:
categories:
  - Azure
tags:
  - Azure
  - Azure Bicep

---

## Background
Many customers have gone down the route of developing, publishing and sharing internally developed Azure IaC modules within the organization. The modules can be written in Bicep, or Terraform or other IaC languages.

The process is typically as follows:

1. Develop the module locally.
2. Publish a “beta” or preview version of the module into a registry.
3. Test the module in a staging environment before promoting it to production.
4. Bump the version number and publish the final module.

We have implemented internal Bicep module libraries leveraging existing now retired [Azure CARML](https://aka.ms/carml) and it's successor [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/) (AVM) library for several customers over the last few years.

Some common questions asked by the customers include:

1. **Module usage tracking** - How do we know where the modules are being used? if we update or retire a module, we need to know who's going to be impacted.
2. **Module versioning control** - How do we ensure only production-ready versions are being used in production environments? In another word, how do we prevent the use of `beta` or `pre-release` versions in production?

To answer these questions and address the concern, we have come up with a pattern that involves the use of `hidden-` tags in the Bicep modules.

As you may know, if you create a tag with the `hidden-` prefix, the Azure Portal hides the tag (but it is still viewable via the ARM REST API). For example, this Storage Account has 2 hidden tags as you can see in the resource JSON view

![01](../../../../assets/images/2025/08/bicep-hidden-tags-01.jpg)

But they are hidden from the portal view:

![02](../../../../assets/images/2025/08/bicep-hidden-tags-02.jpg)

We created two hidden tags for every resource module. The `hidden-module_name` tag indicates the name of the module and the `hidden-module_version` tag indicates the complete semantic version of the module (major.minor.patch). If the module consumers don't look close enough, they won't notice these tags because they are hidden from the portal view.

To implement this in the bicep modules, we added the following code to the module (using storage account as an example):

```bicep
//tags parameter
@description('Optional. Tags of the resource.')
param tags object?

//external version.json file that stores the version number (as a common pattern in AVM and CARML)
var moduleVersion = loadJsonContent('./version.json').version

//combine the existing tags and hidden tags
var mergedTags = union(tags, {
    'hidden-module_name': 'storage/storage-account'
    'hidden-module_version': moduleVersion
  })

//pass the combined tags to the resource
resource storageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' = {
  name: 'mystorageaccount'
  location: 'eastus'
  tags: mergedTags
  ...
  ...
}
```

## Module Usage Tracking

After these hidden tags are embedded in each module, we can start tracking the usage of these modules across your organization using Azure Resource Graph.

Here are some sample queries you can use:

**Get all module usage**

```OQL
resources
| where tags['hidden-module_name'] matches regex '.'
| extend module_name = tostring(tags['hidden-module_name'])
| extend module_version = tostring(tags['hidden-module_version'])
| summarize resource_count = count() by type, module_name, module_version
```

![03](../../../../assets/images/2025/08/bicep-hidden-tags-03.jpg)

>Note: repeat this query for other Azure Resource Graph tables because not everything is stored in the `resources` table. Refer to [this article](https://learn.microsoft.com/en-us/azure/governance/resource-graph/reference/supported-tables-resources) for the details on ARG tables.

**List all storage accounts deployed by the storage module with module version, `owner` and `environment` tag values**

```OQL
resources
| where type =~ "microsoft.storage/storageAccounts"
| where tags['hidden-module_name'] contains 'storage'
| extend module_name = tostring(tags['hidden-module_name'])
| extend owner=tostring(tags['owner'])
| extend environment=tostring(tags['environment'])
| project name, tags, module_name, environment, owner
| mvexpand tags
| extend tagKey = tostring(bag_keys(tags)[0])
| extend tagValue = tostring(tags[tagKey])
| distinct name, tagKey, tagValue, module_name, owner, environment
| where tagKey =~ "hidden-module_version"
| project resourceName = name, module_name, module_version = tagValue, owner, environment
```

![04](../../../../assets/images/2025/08/bicep-hidden-tags-04.jpg)

## Module Versioning Control

If the AVM / CARML pattern is being used, we need to firstly understand how the module version numbers are constructed.

In AVM / CARML, each module has a `version.json` file in the same directory of the module bicep file which contains the `major.minor` version number.

The patch version is generated by the pipeline at the module publish time. The pipeline then combines the `major.minor` version from the `version.json` file with the patch number it generated. When a module is published from the `main` or `master` branches, the final version number is the one this combined version number.

When the module is published from another branch (i.e. a feature branch for adding new features or a bugfix branch for fixing a bug), the pipeline appends `-prerelease` to the version number.

The purpose of the `-prerelease` versions are for you to conduct integration testing in staging environments. These version have not gone through the code review and PR process, the code has not been merged to the main branch, therefore they are not production ready.

To block the use of `-prerelease` versions in production, We have created an Azure Policy definition and assigned it to the management group represents the top of the hierarchy for the production environment. The policy simply blocks any resources that has `hidden-module_version` tag with the value that matches the pattern `*-prerelease`:

```json
{
  "name": "pol-restrict-prerelease-overlay-module-versions",
  "properties": {
    "displayName": "Restrict resources to be deployed using prerelease overlay module versions",
    "description": "Prerelease module versions are published for testing purposes only. They are not intended for production use and they have not gone through code review and validation. This policy restricts resources from being deployed using prerelease overlay module versions.",
    "metadata": {
      "category": "Code Vulnerability",
      "version": "1.0.0",
      "preview": false,
      "deprecated": false
    },
    "mode": "Indexed",
    "parameters": {
      "effect": {
        "type": "String",
        "metadata": {
          "displayName": "Effect",
          "description": "Enable or disable the execution of the policy"
        },
        "allowedValues": [
          "Audit",
          "Deny",
          "Disabled"
        ],
        "defaultValue": "Deny"
      }
    },
    "policyRule": {
      "if": {
        "allOf": [
          {
            "field": "tags[hidden-module_version]",
            "exists": true
          },
          {
            "field": "tags[hidden-module_version]",
            "like": "*-prerelease"
          }
        ]
      },
      "then": {
        "effect": "[parameters('effect')]"
      }
    }
  }
}
```

>Note: This policy works very well for the resources that support tags. Obviously, not all resources in Azure support tags, and this is a limitation.

Our hidden tag is important because Bicep modules can be consumed in two ways:

1. When a module is pulled from a registry (either public or private Azure Container Registry), the Bicep template compiles it as a “nested deployment” with all module contents embedded into the ARM payload. In this scenario the module’s version is not discoverable.

2. When a module is used as a TemplateSpec, the compiled template uses a linked reference that points to the TemplateSpec version. However, Azure Policy does not evaluate `Microsoft.Resources/deployments` resource used by nested or linked deployments. Azure Policy skips anything coming from the Microsoft.Resources resource provider (except for subscriptions and resource groups).

Because of both these issues, we decided to “mark” our modules by storing a hidden version tag in the ARM payload.

## Update Module Pipelines

If you are using the CARML / AVM pipeline patterns for your internal Bicep modules, there is one update to the Pipeline code that you need to be aware of.

As I have shown above, the module version number is retrieved from the `version.json` file. However this file only contains the `major.minor` version numbers.

We need to update the pipeline to write back the full version number to this file before the module publish task.

This is what we have done:

Firstly updated the [Get-ModulesToPublish.ps1](https://github.com/Azure/ResourceModules/blob/main/utilities/pipelines/resourcePublish/Get-ModulesToPublish.ps1) and added a new function and placed it before the `Get-ModulesToPublish` function::

```PowerShell
function Set-ModuleVersionFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $TemplateFilePath,

        [Parameter(Mandatory)]
        [string] $Version
    )

    $ModuleFolder = Split-Path -Path $TemplateFilePath -Parent
    $VersionFilePath = Join-Path $ModuleFolder 'version.json'
    $VersionFileContent = Get-ChildItem -Path $VersionFilePath | Get-Content | ConvertFrom-Json
    $VersionFileContent.version = $Version
    $VersionFileContent | ConvertTo-Json | Set-Content $VersionFilePath
    Write-Verbose "Updated module '$($ModuleFolder.Replace('\','/').Split('modules')[-1])' version metadata content: `n$($VersionFileContent | Out-String)"-Verbose
}

```

Then added a step to call this function and update the `version.json` file before returning the `$modulesToPublish` variable in the `Get-ModulesToPublish` function at the end of the file:

```PowerShell
foreach ($TemplateFileToPublish in $TemplateFilesToPublish) {
    $ModuleVersion = Get-NewModuleVersion -TemplateFilePath $TemplateFileToPublish.FullName -Verbose
    Set-ModuleVersionFile -TemplateFilePath $TemplateFileToPublish -Version $ModuleVersion -Verbose
}
```

![05](../../../../assets/images/2025/08/bicep-hidden-tags-05.jpg)

## Conclusion

Over time I’ve raised a [feature request](https://github.com/Azure/bicep-registry-modules/issues/2503) so that the AVM team might support similar functionality natively. It has been a while since I raised the request and the AVM team have not committed to implementing this.

Therefore I have decided to document this pattern so that if we fork the AVM or CARML modules for our internal use, we can "inject" our own hidden tags (both the module name and version) into the ARM payload.

Although the sample code above is specific to Bicep modules and our AVM/CARML fork, the same concept can be applied – for example, in Terraform modules when you need to track which version of a module was deployed.
