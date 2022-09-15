---
title: Azure policy to Audit Storage Account without Lifecycle Management Rule
date: 2022-09-16 00:00
author: Tao Yang
permalink: /2022/09/16/azure-policy-audit-storage-account-lifecycle-management-rule/
summary: Azure policy to audit storage account without lifecycle management rule
categories:
  - Azure
tags:
  - Azure
  - Azure Policy
  - Azure Storage
---

I created a new Azure Policy definition today to audit storage accounts that do not have lifecycle management rules.

![01](../../../../assets/images/2022/09/storage_lifecycle_mgmt_rule_01.jpg)

The policy definition can be found in my **AzurePolicy** GitHub repo [HERE](https://github.com/tyconsulting/azurepolicy/blob/master/policy-definitions/audit-storage-account-without-lifecycle-mgmt-policy/azurepolicy.json)
