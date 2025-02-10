---
title: Updated Azure Policy Definition for Storage Account Minimum TLS Version
date: 2025-02-10 12:00
author: Tao Yang
permalink: /2025/02/10/updated-azure-policy-for-storage-minimum-tls-ver
summary: Updated Azure Policy Definition for Storage Account Minimum TLS Version to support multiple TLS versions.
categories:
  - Azure
tags:
  - Azure
  - Azure Policy
---

Transport Layer Security (TLS) version 1.3 has been [supported by Azure Storage Accounts since January 2024](https://techcommunity.microsoft.com/blog/azurestorageblog/tls-1-3-requests-are-supported-for-azure-storage-ability-to-set-min-tls-version-/4034014/replies/4180182). The ARM API for storage account now accepts `TLS1_3` as a valid value for the `minimumTlsVersion` property of the storage account.

In this announcement, it stated the portal support and other client tools are coming.

It is now February 2025, I still don't see the portal support for TLS 1.3.

![01](../../../../assets/images/2025/02/storage-tls-policy-01.jpg)

Also, at the time of writing this post, the [Terraform AzureRM provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) also doesn't support TLS v1.3.

![02](../../../../assets/images/2025/02/storage-tls-policy-02.jpg)

So now, we are at a stage that we can set the `minimumTlsVersion` property of a storage account to `TLS1_3` using ARM API, Bicep or using [AVM Storage Account module](https://github.com/Azure/bicep-registry-modules/blob/main/avm/res/storage/storage-account/README.md#parameter-minimumtlsversion) but portal or 3rd party tooling support (i.e. Terraform) is still missing.

The [Built-In Azure policy for storage account minimum TLS version](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Storage/StorageAccountMinimumTLSVersion_Audit.json) only supports up tp TLS v1.2 at the time of writing this post. This is understandable because if the policy sets the `minimumTlsVersion` to `TLS1_3`, people will not be able to use portal or Terraform to deploy storage accounts.

The built-in policy is simply checking the string of the `minimumTlsVersion` property of the storage account and compare it with the policy parameter. It requires the `minimumTlsVersion` value to be exactly the same as the policy parameter (two strings must be identical):

![03](../../../../assets/images/2025/02/storage-tls-policy-03.jpg)

You cannot use numeric comparison such as `greater` or `less` to compare the version number because the `minimumTlsVersion` property value such as `TLS1_2` is a string.

For my current customer, security policy requires TLS v1.3 is preferred wherever is possible. We cannot discriminate users that use portal or Terraform for resource deployments, but we also don't want to compromise the security policy by forcing customers to be less secure if they choose to use TLS v1.3 as the minimum requirement for their storage accounts.

So I have created an updated version of the Azure Policy definition for storage account minimum TLS version that supports multiple TLS versions. The policy definition can be found in my Azure Policy GitHub repo - [enforce-storage-minimum-tls-version](https://github.com/tyconsulting/azurepolicy/blob/master/policy-definitions/enforce-storage-minimum-tls-version/azurepolicy.json). In this policy, if you create a storage account with minimum TLS version that's set to higher than what the policy is configured for, the policy will not block your deployment. i.e. if the policy is set to `TLS1_2`, you can still create a storage account with `TLS1_3` as the minimum TLS version.

I wanted to be able to allow customers to easily swap out the built-in policy with this updated policy without breaking changes, so I have not changed the parameters or the effect of the policy. The only change is adding the `TLS1_3` as the allowed value for the minimum TLS version and logic of the `policyRule` section of the policy definition.

```json
"policyRule": {
  "if": {
    "allOf": [
      {
        "field": "type",
        "equals": "Microsoft.Storage/storageAccounts"
      },
      {
        "anyOf": [
{
            "value": "[replace(replace(field('Microsoft.Storage/storageAccounts/minimumTlsVersion'),'TLS', ''),'_', '.')]",
            "less": "[replace(replace(parameters('minimumTlsVersion'),'TLS',''),'_','.')]"
          },
          {
            "field": "Microsoft.Storage/storageAccounts/minimumTlsVersion",
            "exists": "false"
          }
        ]
      }
    ]
  },
  "then": {
    "effect": "[parameters('effect')]"
  }
}
```

As you can see, basically what I have done is converting string such as `TLS1_2` to a proper version number `1.2` and then compare the version number of the storage account with the version number of the policy parameter. If the storage account version is less than the policy parameter, the policy will apply the effect.

To test, I have set the policy to `TLS1_2` and created a storage account with `TLS1_3` minimum TLS version.

![04](../../../../assets/images/2025/02/storage-tls-policy-04.jpg)

The What-If result shows the policy is not blocking the deployment.

![05](../../../../assets/images/2025/02/storage-tls-policy-05.jpg)
