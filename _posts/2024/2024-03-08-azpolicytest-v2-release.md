---
title: PowerShell Module AzPolicyTest V2.0 Released
date: 2024-03-08 13:00
author: Tao Yang
permalink: /2024/03/08/azpolicytest-v2-release
summary:
categories:
  - Azure
tags:
  - Azure
  - Azure Policy
  - PowerShell
  - Pester

---

## Introduction
I created the PowerShell module AzPolicyTest ([GitHub](https://github.com/tyconsulting/AzPolicyTest), [PowerShellGallery](https://www.powershellgallery.com/packages/AzPolicyTest)) back in 2019. This module provides a list of Pester tests can be used to validate the Azure Policy and Initiative definitions. It can also be used in your IaC pipelines. I have previously blogged about this tool in the blog post [Deploying Azure Policy Definitions via Azure DevOps (Part 2)](https://blog.tyang.org/2019/05/19/deploying-azure-policy-definitions-via-azure-devops-part-2/).

The initial version 1.0 was developed using Pester v4. It has been 5 years and it has stopped working long time ago due to the breaking changes introduced in Pester v5. On the other hand, a lot of new capabilities have been introduced in Azure Policy since 2019. I have been wanting to update this module for a long time, but I just never got around to it.

My intention for creating this module is to collect all the best practices and lesson learned from the field and put them into a set of Pester tests. I wanted to make it easy for anyone to validate their policy definitions and initiatives before deploying them (the shift-left approach). Some of these tests addressed issues that a normal Bicep template validation would not catch and are can only be identified during the deployment phase (for example, the `mode` value is case sensitive and it must be using the `pascaleCase` format? `All` and `Indexed` are accepted but `all` or `indexed` are not?).

I have manage to spend a day to update the module to use Pester v5 and also added a few new tests to cover some of the new Azure Policy capabilities. The new version 2.0 has been released to PowerShell Gallery. You can install it using the following command:

```powershell
Install-Module -Name AzPolicyTest -Force
```

You can use the following commands to run the tests:

Invoke tests for Policy Definitions:

```powershell
#import the module if required
import-module AzPolicyTest

# Test a single policy definition file without generating the test results output file
Test-AzPolicyDefinition -Path "path-to-policy-definition-json-file.json" -OutputFile "C:\Temp\MyTestResult.xml"

# Test all policy definition json files in the directory and sub directories and store the test results in a file
Test-AzPolicyDefinition -Path "directory-path" -OutputFile "./policy.tests.xml"

```

Invoke tests for Policy Initiatives:

```powershell
#import the module if required
import-module AzPolicyTest

# Test a single policy initiative file without generating the test results output file
Test-AzPolicySetDefinition -Path "path-to-policy-definition-json-file.json" -OutputFile "C:\Temp\MyTestResult.xml"

# Test all policy initiative json files in the directory and sub directories and store the test results in a file
Test-AzPolicySetDefinition -Path "directory-path" -OutputFile "./policy.tests.xml"

```

![01](../../../../assets/images/2024/03/azpolicytest-01.jpg)

## What's Included in AzPolicyTest v2.0

The following Tests are included in the module:

**Policy Definition Tests:**

* Policy definition `name` element should exist
* Policy definition `properties` element should exist
* `name` value must not be null
* `name` value must not contain spaces
* `displayName` element should exist
* `displayName` value must not be null
* `description` element should exist
* `description` value must not be null
* `metadata` element should exist
* `metadata` must contain `Category` element
* `metadata` must contain `version` element
* `version` value must be a valid semver version
* `mode` element should exist
* `mode` element must have a valid value
* `parameters` element should exist
* `parameters` element must have at least one item
* `policyRule` element should exist
* `policyRule` element must have a `if` and `then` child element
* The type for each parameter must be a valid data type
* Each parameter must have a display name and description
* The policy effect must be parameterised
* The parameterised policy effect should only contain valid effects
* The parameterised policy effect should contain `Disabled` effect as one of the allowed values
* If the parameterised policy effect contains `Audit`, then it should also contain `Deny` and vice versa
* The parameterised policy effect should have a default value
* `DeployIfNotExists`, `Modify` and `AuditIfNotExists` policy definitions should contain a `details` element
* `DeployIfNotExists` and `AuditIfNotExists` policy definitions should contain a `existenceCondition` element
* `DeployIfNotExists` and `AuditIfNotExists` policy definitions should contain a `evaluationDelay` element
* `DeployIfNotExists` policy definition should contain a `deployment` element
* `DeployIfNotExists` policy should set the deployment mode to `Incremental`
* `DeployIfNotExists` and `Modify` policies should contain a `roleDefinitionIds` element
* At least one role definition ID should be specified for the `DeployIfNotExists` and `Modify` policies
* The ARM template embedded in the `DeployIfNotExists` policy should have a valid schema
* The ARM template embedded in the `DeployIfNotExists` policy should have a valid contentVersion
* The ARM template embedded in the `DeployIfNotExists` policy should have a `parameters`, `variables`, `resources` and `outputs` elements
* `Modify` policies should contain a `conflictEffect` element and it must have a valid value
* `Modify` policies must have an `operations` element

**Policy Set Definition (Initiative) Tests:**

* Policy Initiative definition `name` element should exist
* Policy Initiative definition `properties` element should exist
* `name` value must not be null
* `name` value must not contain spaces
* `displayName` element should exist
* `displayName` value must not be null
* `description` element should exist
* `description` value must not be null
* `metadata` element should exist
* `metadata` must contain `Category` element
* `metadata` must contain `version` element
* `version` value must be a valid semver version
* `policyDefinitions` element must exist and must contain at least one item
* `policyDefinitionGroups` element must exist and must contain at least one item
* The type for each parameter must be a valid data type
* Each parameter must have a display name and description
* Each member policy must have the `policyDefinitionId` and `policyDefinitionReferenceId` elements
* The `policyDefinitionId` and `policyDefinitionReferenceId` elements for each member policy must have a valid value
* Each member policy must have a `parameters` element
* Each member policy must have a `groupNames` element
* The `groupNames` element for each member policy must have at least one item

**Json File Tests:**

* The specified value for the `path` parameter must contain at least one Json file
* The Json file can be correctly parsed

## Conclusion

I have also bumped the minimum required PowerShell version to v7.0.0 and Pester module version to v5.5.0. Therefore you will no longer be able to use this module in the legacy Windows PowerShell (v5) environment (and if you are still using Windows PowerShell, you should really stop doing that!).

I have in included few policy and initiative definitions that I used for testing the PowerShell module. you can find them in the GitHub repo under the [test_definitions](https://github.com/tyconsulting/AzPolicyTest/tree/master/test_definitions) folder.


Lastly, I wanted to mention that I was thinking about adding additional tests to validate the policy definition json file against the official JSON schema for Azure policy definitions. However I quickly scrapped the idea due to few limitations:

1. The [latest official schema I was able to find](https://github.com/Azure/azure-resource-manager-schemas/blob/main/schemas/2020-10-01/policyDefinition.json) was dated back to Oct 2020, and it was created using Json schema draft-4 format. Starting for the most recent PowerShell release (v7.4.1), the `Test-Json` cmdlet has been updated to use the latest Json schema draft-7 format ([breaking changes in PowerShell 7.4.1](https://learn.microsoft.com/en-us/powershell/scripting/whats-new/what-s-new-in-powershell-74?view=powershell-7.4#breaking-changes)). Therefore the official schema for Azure policy definitions is no longer compatible with the latest `Test-Json` cmdlet.
2. The official schema only covered the `policyRule` section of the policy definition, and there is no schema for the policy initiatives.
3. The Json schema is useless when you have parameterised values (such as policy effects). For example, the effect value `[parameters('effect')]` is not a valid value according to the schema, but it is a valid in the policy definition as long as the respective parameter is correctly defined.

If you have any suggestions or feedback, please feel free to raise an issue in the GitHub repo or each out to me on social media. I hope you find this module useful.
