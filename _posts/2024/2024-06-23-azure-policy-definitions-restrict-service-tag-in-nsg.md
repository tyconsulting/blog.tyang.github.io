---
title: Azure Policies for Restricting Service Tag in Network Security Groups
date: 2024-06-23 14:00
author: Tao Yang
permalink: /2024/06/23/azure-policy-definitions-restrict-service-tag-in-nsg
summary: Azure policy definitions for restricting service tags in network security groups
categories:
  - Azure
tags:
  - Azure
  - Azure Policy

---
Recently Tenable has reported a vulnerability on Azure Network Security Groups (NSG) related to the use of service tags in NSG rules You can read more about this vulnerability from [Tenable's blog post](https://www.tenable.com/blog/these-services-shall-not-pass-abusing-service-tags-to-bypass-azure-firewall-rules-customer) and Microsoft's response [HERE](https://msrc.microsoft.com/blog/2024/06/improved-guidance-for-azure-network-service-tags/).

The customer that I'm working for right now raised the concern and we were asked if we can use Azure policy to restrict certain service tags from being used in NSG rules.

My colleagues and I spent some time and came up with the policy definitions that can be used to restrict a specific service tag from being used as the value of either `sourceAddressPrefix` or `destinationAddressPrefix` properties of the NSG rules.

The logic is simple. When assigning the policy, you need to specify the `direction` of the rule (`outbound` or `inbound`). If the `direction` is set to `outbound`, then the policy will target the `destinationAddressPrefix` property. Alternatively, if the `direction` is `inbound`, the policy will target `sourceAddressPrefix` instead.

When dealing with ARM APIs for resources in `Microsoft.Network` resource provider, some resources can be created as a child resource of their parent, or as a property of the parent resource itself. For example, subnets in Virtual Networks, and NSG security rules in NSGs. This has always been challenging when creating Azure Policy definitions when targeting these types of resources.

As result, we had to create 2 Policy definitions, one targeting the parent resource NSG itself (`Microsoft.Network/networkSecurityGroups`) and another one targeting the child resource NSG security rules (`Microsoft.Network/networkSecurityGroups/securityRules`). When assigning the policies, you need to make sure you assign both policies to cover the both deployment scenario.

You can find find both policy definitions in my [azurepolicy GitHub repo](https://github.com/tyconsulting/azurepolicy):

- Policy Definition Targeting the NSG: [Restrict Use of Specific Service Tag in NSG](https://github.com/tyconsulting/azurepolicy/blob/master/policy-definitions/restrict-service-tags-in-nsgs/pol-deny-service-tag-in-nsg.json)
- Policy Definition Targeting the NSG rule: [Restrict Use of Specific Service Tag in NSG Security Rules](https://github.com/tyconsulting/azurepolicy/blob/master/policy-definitions/restrict-service-tags-in-nsgs/pol-deny-service-tag-in-nsg-rule.json)

I have also provided a [sample Policy Initiative](https://github.com/tyconsulting/azurepolicy/blob/master/policy-definitions/restrict-service-tags-in-nsgs/polset-nsg.json) that restricts 2 service tags (`Internet` and `Storage.AustraliaCentral`) in both inbound and outbound rules. So in total there are 8 member policies in the initiative (**2** policies per service tag per direction).

>**NOTE**: We have purposely designed the policy definition this way that only allow a single service tag per policy instance instead of a full array of disallowed service tags. It is easier this way when you need to create policy exemptions for a specific NSG to use a specific disallowed service tags.
