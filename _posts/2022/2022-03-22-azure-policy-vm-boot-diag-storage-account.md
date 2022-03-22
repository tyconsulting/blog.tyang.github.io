---
title: Azure Policy for Virtual Machine Customer-Managed Boot Diagnostic Storage Accounts
date: 2022-03-22 19:00
author: Tao Yang
permalink: /2022/03/22/azure-policy-vm-boot-diag-storage-account/
summary: Azure policy definition for audit or deny Virtual Machines that are not using customer-managed storage accounts for boot diagnostics
categories:
  - Azure
tags:
  - Azure
  - Azure Policy
  - Azure VM
---

I wrote an Azure Policy definition today to audit or deny VMs that are not using customer-managed storage accounts for Boot Diagnostics. The default policy effect is `Deny` but can be changed to `Audit` when assigning the policy because it's parameterized.

This policy will block or generate audit log if the Virtual Machine has either disabled boot diagnostic or configured to use Microsoft-Managed storage account.

![01](../../../../assets/images/2022/03/vm-boot-diag-policy-01.jpg.jpg)

The policy definition can be found in my **AzurePolicy** GitHub repo [HERE](https://github.com/tyconsulting/azurepolicy/tree/master/policy-definitions/vm-without-customer-managed-boot-diag-storage-account).
