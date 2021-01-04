---
id: 6332
title: Restricting Public-Facing Azure Storage Accounts Using Azure Resource Policy
date: 2018-01-08T23:17:28+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=6332
permalink: /2018/01/08/restricting-public-facing-azure-storage-accounts-using-azure-resource-policy/
categories:
  - Azure
tags:
  - Azure
  - Azure Resource Policy
---
 
## Background 

Back in September 2017, Microsoft has announced <a href="https://azure.microsoft.com/en-au/blog/announcing-virtual-network-integration-for-azure-storage-and-azure-sql/">Virtual Network Service Endpoints for Azure Storage and Azure SQL</a> at Ignite. This feature prevents Storage Accounts and Azure SQL Databases from being accessed from the public Internet.

A customer had a requirement to enforce all storage accounts to be attached to VNets as part of their security policies. The Azure Resource Policy seems to be the logical solution for this requirement. In order to make this possible, I have contacted the Azure Policy product team, and thanks for their prompt response, this is now possible – although at the time of writing, it is yet to be documented on the Microsoft documentation site. Therefore, I’m here sharing the [policy definition](https://gist.github.com/tyconsulting/9e004708f205c6fc84a6612d0dcaeb4a) and my experience on this blog post.
 
## Policy Definition 

```json
{
  "if": {
  "allOf": [
    {
    "field": "type",
    "equals": "Microsoft.Storage/storageAccounts"
    },
    {
    "field": "Microsoft.Storage/storageAccounts/networkAcls.defaultAction",
    "equals": "Allow"
    }
  ]
  },
  "then": {
    "effect": "deny"
  }
}
```

Once the policy is applied, you will not be able to create a Storage Account without attaching to a VNet：

<a href="https://blog.tyang.org/wp-content/uploads/2018/01/image-2.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/01/image_thumb-2.png" alt="image" width="387" height="915" border="0" /></a>

<a href="https://blog.tyang.org/wp-content/uploads/2018/01/image-3.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/01/image_thumb-3.png" alt="image" width="611" height="553" border="0" /></a>
 
## Limitations 

Even when you have attached the Storage Account to a VNet, the Network Security Group (NSG) that the VNet is associated to does not apply to the storage account. This is because, according to Microsoft’s <a href="https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-nsg">documentation</a>, NSG only applies to subnet, classic VMs and NICs attached to ARM VMs. For Storage Accounts, if you need to access it from an external network, you will need to configure the firewall rules for each storage account individually:

<a href="https://blog.tyang.org/wp-content/uploads/2018/01/image-4.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/01/image_thumb-4.png" alt="image" width="862" height="526" border="0" /></a>

<del>According to my own tests, at the time of writing this post, the firewall rules for storage accounts cannot be configured and enforced via Azure Resource Policy.</del>

<span style="color: #ff0000;"><strong>[Update: 21/09/2018]:</strong></span> to configure the firewall rules, please refer to my post: <a href="https://blog.tyang.org/2018/09/21/azure-policy-to-restrict-storage-account-firewall-rules/">https://blog.tyang.org/2018/09/21/azure-policy-to-restrict-storage-account-firewall-rules/</a>