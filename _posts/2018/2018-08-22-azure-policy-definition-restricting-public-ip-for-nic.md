---
id: 6507
title: 'Azure Policy Definition &ndash; Restricting Public IP for NIC'
date: 2018-08-22T14:45:32+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=6507
permalink: /2018/08/22/azure-policy-definition-restricting-public-ip-for-nic/
categories:
  - Azure
tags:
  - Azure
  - Azure Resource Policy
---
It has been a while since my last blog post. There were a lot going on outside of work, I couldn’t find time to write, and my blog to-do list is getting longer. Finally things are settled down a little bit. I will try to tackle my list in the coming days. To get started, I will target the easiest ones first.

Few weeks ago, I had to write several custom Azure Policy definitions for a customer. One of them is to restrict Public IPs being provisioned for VMs in particular resource groups. I found a similar definition from the Azure Policy GitHub repo that restrict PIP except for one subnet (<a title="https://github.com/Azure/azure-policy/tree/master/samples/Network/no-public-ip-except-for-one-subnet" href="https://github.com/Azure/azure-policy/tree/master/samples/Network/no-public-ip-except-for-one-subnet">https://github.com/Azure/azure-policy/tree/master/samples/Network/no-public-ip-except-for-one-subnet</a>). I removed the subnet component from this example, and made it to restrict PIP being associated to a NIC:

Here’s the policy definition:

```json
"policyRule": {
  "if": {
    "allOf": [
      {
        "field": "type",
        "equals": "Microsoft.Network/networkInterfaces"
      },
      {
        "field": "Microsoft.Network/networkInterfaces/ipconfigurations[*].publicIpAddress.id",
        "exists": true
      }
    ]
  },
  "then": {
    "effect": "deny"
  }
}
```

It is located in my GitHub repo, where you can download or deploy directly to your environment via Azure portal:<a title="https://github.com/tyconsulting/azurepolicy/tree/master/policy-definitions/restrict-public-ips" href="https://github.com/tyconsulting/azurepolicy/tree/master/policy-definitions/restrict-public-ips">https://github.com/tyconsulting/azurepolicy/tree/master/policy-definitions/restrict-public-ips</a>

Once the policy is assigned (ideally to a resource group), you will be blocked if you are trying to create a VM with public IP:

<a href="https://blog.tyang.org/wp-content/uploads/2018/08/image.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/08/image_thumb.png" alt="image" width="1002" height="503" border="0" /></a>