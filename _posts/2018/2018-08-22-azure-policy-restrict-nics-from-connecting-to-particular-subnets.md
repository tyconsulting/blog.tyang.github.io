---
id: 6522
title: 'Azure Policy&ndash;Restrict NICs From Connecting to Particular Subnets'
date: 2018-08-22T23:33:28+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=6522
permalink: /2018/08/22/azure-policy-restrict-nics-from-connecting-to-particular-subnets/
categories:
  - Azure
tags:
  - Azure
  - Azure Resource Policy
---
I wrote this policy definition for a customer few weeks ago – to restrict VMs from connecting to particular subnets. The customer has several subnets that should not be used by VMs, i.e. dedicated subnet for Azure ADDS (which is not associated to any NSGs), or subnets that are using different NSGs, which normal users should not be using. Since the intension is not restricting users from using the entire VNet, but only particular subnets, we could not apply such restrictions using custom role definitions.

Here’s the policy definition:

```json
{
  "properties": {
    "displayName": "Restrict subnet for VM network interfaces",
    "description": "This policy restrict VM network interfaces from using a particular subnet",
    "parameters": {
      "subnetId": {
        "type": "string",
        "metadata": {
          "description": "Resource Id for Subnet",
          "displayName": "Subnet Id"
        }
      }
    },
    "policyRule": {
      "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.Network/networkInterfaces"
          },
          {
            "field": "Microsoft.Network/networkInterfaces/ipconfigurations[*].subnet.id",
            "equals": "[parameters('subnetId')]"
          }
        ]
      },
      "then": {
        "effect": "deny"
      }
    }
  }
}
```
It is also located in my GitHub repo: <a title="https://github.com/tyconsulting/azurepolicy/tree/master/policy-definitions/restrict-vm-nic-from-connecting-to-subnet" href="https://github.com/tyconsulting/azurepolicy/tree/master/policy-definitions/restrict-vm-nic-from-connecting-to-subnet">https://github.com/tyconsulting/azurepolicy/tree/master/policy-definitions/restrict-vm-nic-from-connecting-to-subnet</a>. From this repo, you can download the policy definition, or deploy directly to your environment via Azure Portal. It’s documented in the README.md file.

When assigning this policy, you must specify the resource ID of the subnet that your want to restrict. The subnet resource ID can be easily obtained from the ARM resource explorer (<a href="https://resources.azure.com">https://resources.azure.com</a>):

<a href="https://blog.tyang.org/wp-content/uploads/2018/08/image-1.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/08/image_thumb-1.png" alt="image" width="983" height="477" border="0" /></a>

After the policy is assigned, you will get blocked when you try to connect the VM to the subnet:

<a href="https://blog.tyang.org/wp-content/uploads/2018/08/image-2.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/08/image_thumb-2.png" alt="image" width="973" height="634" border="0" /></a>

If you have more than one subnet to restrict, you can easily include multiple instance of this policy definition in an initiative and assign the initiative.