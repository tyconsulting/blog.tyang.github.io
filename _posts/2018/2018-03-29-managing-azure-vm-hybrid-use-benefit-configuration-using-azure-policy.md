---
id: 6404
title: Managing Azure VM Hybrid Use Benefit Configuration Using Azure Policy
date: 2018-03-29T00:20:32+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=6404
permalink: /2018/03/29/managing-azure-vm-hybrid-use-benefit-configuration-using-azure-policy/
categories:
  - Azure
tags:
  - Azure
  - Azure Resource Policy
---
<a href="https://docs.microsoft.com/en-us/azure/azure-policy/azure-policy-introduction" target="_blank" rel="noopener">The Azure Policy</a> is a great tool to manage your standards and policies within your Azure subscriptions. In addition to the built-in policies from the Azure Portal, the product team also provides a public <a href="https://github.com/Azure/azure-policy" target="_blank" rel="noopener">GitHub repository</a> to share custom policy definitions to the community.

At the time of writing this post, there are already 2 policy definitions in this GitHub repo for managing the Hybrid Use Benefit (BYO license) for Windows VMs:

* Enforce Hybrid Use Benefit: <a title="https://github.com/Azure/azure-policy/tree/master/samples/Compute/enforce-hybrid-use-benefit" href="https://github.com/Azure/azure-policy/tree/master/samples/Compute/enforce-hybrid-use-benefit">https://github.com/Azure/azure-policy/tree/master/samples/Compute/enforce-hybrid-use-benefit</a>
* Deny Hybrid Use Benefit: <a title="https://github.com/Azure/azure-policy/tree/master/samples/Compute/deny-hybrid-use-benefit" href="https://github.com/Azure/azure-policy/tree/master/samples/Compute/deny-hybrid-use-benefit">https://github.com/Azure/azure-policy/tree/master/samples/Compute/deny-hybrid-use-benefit</a>

These 2 policy definitions are maturely exclusive.

If you apply the Enforce policy, you will not be able to create a VM if you have not enabled Hybrid Use Benefit as shown below:

<a href="https://blog.tyang.org/wp-content/uploads/2018/03/image-9.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/03/image_thumb-9.png" alt="image" width="873" height="915" border="0" /></a>

At the summary page of the wizard, you will receive an error:

<a href="https://blog.tyang.org/wp-content/uploads/2018/03/image-10.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/03/image_thumb-10.png" alt="image" width="588" height="350" border="0" /></a>

On the other hand, if you have apply the Deny Hybrid Use Benefit policy, you will also get an validation error if you have enabled Hybrid Use Benefit:

<a href="https://blog.tyang.org/wp-content/uploads/2018/03/image-11.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/03/image_thumb-11.png" alt="image" width="583" height="327" border="0" /></a>

These two policy definitions are great, but to me, none of them meets my requirements. I don’t want to educate my users on what settings should they use, and throwing an error at the summary page of the wizard is not very user friendly. I want my users to not worry about this setting, and automatically enable Hybrid Use Benefit for Windows server VMs. Therefore I created [new custom definition](https://gist.github.com/tyconsulting/14137eb880edf4397918a91f924b3b01) based on the above mentioned 2 existing definitions to append Hybrid Use Benefit for a Windows Server VM (automatically enable it):

```json
{
  "type": "Microsoft.Authorization/policyDefinitions",
  "name": "append-hybrid-use-benefit",
  "properties": {
    "displayName": "Append hybrid use benefit",
    "description": "This policy will automatically configure hybrid use benefit for Windows Servers.",
    "parameters": {},
    "policyRule": {
      "if": {
        "allOf": [
          {
            "field": "type",
            "in": [
              "Microsoft.Compute/virtualMachines",
              "Microsoft.Compute/VirtualMachineScaleSets"
            ]
          },
          {
            "field": "Microsoft.Compute/imagePublisher",
            "equals": "MicrosoftWindowsServer"
          },
          {
            "field": "Microsoft.Compute/imageOffer",
            "equals": "WindowsServer"
          },
          {
            "field": "Microsoft.Compute/imageSKU",
            "in": [
              "2008-R2-SP1",
              "2008-R2-SP1-smalldisk",
              "2012-Datacenter",
              "2012-Datacenter-smalldisk",
              "2012-R2-Datacenter",
              "2012-R2-Datacenter-smalldisk",
              "2016-Datacenter",
              "2016-Datacenter-Server-Core",
              "2016-Datacenter-Server-Core-smalldisk",
              "2016-Datacenter-smalldisk",
              "2016-Datacenter-with-Containers",
              "2016-Datacenter-with-RDSH"
            ]
          },
          {
            "field": "Microsoft.Compute/licenseType",
            "notEquals": "Windows_Server"
          }
        ]
      },
      "then": {
        "effect": "append",
        "details": [
          {
            "field": "Microsoft.Compute/licenseType",
            "value": "Windows_Server"
          }
        ]
      }
    }
  }
}
```

This policy will automatically enable Hybrid Use Benefit for Windows Server VMs if it is not enabled during the creation of the VM.

Unfortunately, I don’t believe (and please correct me if I am wrong) there is a way to automatically remove the Hybrid Use Benefit setting from a VM if it is enabled using Azure Policy. According to the Azure Policy definition documentation (<a title="https://docs.microsoft.com/en-us/azure/azure-policy/policy-definition" href="https://docs.microsoft.com/en-us/azure/azure-policy/policy-definition">https://docs.microsoft.com/en-us/azure/azure-policy/policy-definition</a>), the possible effects are: Deny, Audit, Append, AuditIfNotExists and DeployIfNotExists. There is no possible effects to remove a value if it exists