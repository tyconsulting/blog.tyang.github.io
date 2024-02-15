---
title: Azure Bicep Module for Network Security Groups
date: 2024-02-15 21:00
author: Tao Yang
permalink: /2024/02/15/bicep-module-for-nsg/
summary: A Bicep module for Network Security Groups based on Azure Verified Modules (AVM)
categories:
  - Azure
tags:
  - Azure
  - Azure Bicep

---

## Introduction

Most of my work over the last couple of years has been focused on Azure Bicep and more specifically, [CARML](https://aka.ms/carml)(Common Azure Resource Modules Library). I have presented this topic in various occasions (i.e. on the [AzureTar's YouTube Channel](https://blog.tyang.org/2023/07/11/azuretar-carml-series/), and at [Experts Live Australia 2023](https://github.com/tyconsulting/ExpertsLiveAU2023-CARML)). I have also made several contributions to the CARML project.

In the YouTube videos and the Experts Live talk, I have teamed up with Ahmad Abdalla ([@ahmadkabdalla](https://twitter.com/ahmadkabdalla)) and Jorge Arteiro ([@JorgeArteiro](https://twitter.com/JorgeArteiro)) and covered the concept of benefits of developing your own "overlay" Bicep modules based on CARML modules.

The CARML projects have been superseded by the new [Azure Verified Modules (AVM)](https://aka.ms/avm) initiative, and to date, 86 CARML modules have already been migrated to AVM. AVM is a collection of fully tested and verified Azure Bicep modules that can be used to deploy Azure resources. The source code of these modules are located in the [Azure Bicep Registry Modules GitHub repo](https://github.com/Azure/bicep-registry-modules/tree/main/avm/res).

Recently I have been working with the Microsoft AVM team to contribute to the AVM project.

Now having the AVM modules in the picture, it has become even easier to develop your own customized overlay modules with AVM because you do not need to locally host CARML modules in an Azure Container Registry (ACR) anymore - since all the AVM modules are hosted in the public Azure Bicep Registry.

## Bicep module for Network Security Groups

![01](../../../../assets/images/2024/02/nsg-module-01.jpg)

When comes to creating Network Security Group (NSG) rules, I actually think the Azure portal UI is pretty simple and easy to use.However, when it comes to creating them in Bicep / ARM or the API, it can be a bit tricky. There are many different parameters for the source and destination all depending on the use cases. Based on the [Bicep documentation for NSG](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/networksecuritygroups?pivots=deployment-language-bicep), the following parameters are available for the `securityRules` property:

* `sourceAddressPrefix` and `destinationAddressPrefix` - Used when the source or destination is a **single** IP address / CIDR range, or an Azure `Service Tag`.
* `sourceAddressPrefixes` and `destinationAddressPrefixes` - Used when the source or destination is **multiple** IP addresses / CIDR ranges, or a combination of both.
* `sourceApplicationSecurityGroups` and `destinationApplicationSecurityGroups` - Used when the source or destination is **one or more** Application Security Group(s).
* `sourcePortRange` and `destinationPortRange` - Used when the source or destination is a **single** port or a range of ports.
* `sourcePortRanges` and `destinationPortRanges` - Used when the source or destination is **multiple** ports or port ranges or a combination of both.

A lot of people find this annoying when creating NSG rules in code. Few years ago, few colleagues and I have created a simplified Terraform module for NSG rules leveraging Regular Expression (Regex) to determine the source and destination. I have been thinking about creating a similar module for Bicep for a while. Although it is not the same as what we did with Terraform (because Bicep doesn't support Regex at this stage), it is a lot simpler than the standard Bicep / ARM template.

For Example, This is how you can use the module to create a NSG rule:

```bicep
// ranges of addresses and ports
{
  name: 'inbound-rule-allow-1'
  access: 'Allow'
  description: 'Tests Ranges'
  destination: [
    '10.2.0.1'
    '10.3.0.0/16'
  ]
  destinationPort: [
    '90'
    '91'
  ]
  direction: 'Inbound'
  priority: 210
  protocol: '*'
  source: [
    '10.0.0.0/16'
    '10.1.0.0/16'
  ]
  sourcePort: [
    '80'
    '81'
  ]
}

// service tag and single port
{
  name: 'inbound-rule-allow-2'
  protocol: 'Tcp'
  sourcePort: [ '*' ]
  destinationPort: [ '6666' ]
  source: [ 'VirtualNetwork' ]
  destination: [ 'VirtualNetwork' ]
  access: 'Allow'
  priority: 210
  direction: 'Inbound'
  description: 'Allow Databricks TCP port 6666 inbound traffic between virtual networks'
}

// one or more ASGs and a single port
{
  name: 'outbound-rule-deny-1'
  access: 'Deny'
  description: 'Deny outbound access on TCP 8080'
  destination: [
    '/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/rgname/providers/Microsoft.Network/networkSecurityGroups/asg-01'
    '/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/rgname/providers/Microsoft.Network/networkSecurityGroups/asg-02'
    nestedDependencies.outputs.applicationSecurityGroup2ResourceId
  ]
  destinationPort: [ '8080' ]
  direction: 'Outbound'
  priority: 210
  protocol: '*'
  source: [
    '/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/rgname/providers/Microsoft.Network/networkSecurityGroups/asg-03'
  ]
  sourcePort: [ '*' ]
}
```

As you can see, I have consolidated several parameters:

* `source` = `sourceAddressPrefix` + `sourceAddressPrefixes` + `sourceApplicationSecurityGroups`
* `destination` = `destinationAddressPrefix` + `destinationAddressPrefixes` + `destinationApplicationSecurityGroups`
* `sourcePort` = `sourcePortRange` + `sourcePortRanges`
* `destinationPort` = `destinationPortRange` + `destinationPortRanges`

All of these consolidated parameters are arrays, so you can specify one or more values for each parameter. THe module will then determine the correct parameter to use based on the input.

The module can be found in my GitHub repo [HERE](https://github.com/tyconsulting/BlogPosts/tree/master/BicepModules/network-security-group).

## Conclusion

I hope you find this module useful.If you have any feedback or suggestions, please feel free to leave a comment below or reach out to me on Twitter ([@MrTaoYang](https://twitter.com/MrTaoYang)).
