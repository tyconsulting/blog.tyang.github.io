---
title: Azure Policy for Allowed Service Tags in Network Security Groups
date: 2024-09-21 11:00
author: Tao Yang
permalink: /2024/09/21/azure-policy-definition-allowed-nsg-service-tags
summary: Azure policy definitions for allowed service tags in NSG rules
categories:
  - Azure
tags:
  - Azure
  - Azure Policy
---

Previously, I have published a blog post about [Azure Policies for Restricting Service Tag in Network Security Groups](/2024/06/23/azure-policy-definitions-restrict-service-tag-in-nsg). In that post, I shared the policy definitions that can be used to restrict a specific service tag in either inbound or outbound Azure NSG rules. These policies were designed to prevent the use of specific service tags in NSG rules. But when there are too many tags to restrict, this approach may not be practical and introduces a lot of admin overhead.

Since then, I have been asked to create another definition that works the opposite way, instead of creating a denied list, it's more practical to create an allowed list for the project I'm working on right now. As the result, I have create a policy definition that only allows an array of specific service tags in NSG rules.

You can find the policy definition and the sample policy initiative in my [azurepolicy](https://github.com/tyconsulting/azurepolicy/tree/master/policy-definitions/allowed-service-tags-in-nsgs)

When using this Policy definition, you will need to specify the allowed list of service tags as well as the traffic direction (inbound or outbound). The logic is the same as the previous policy definitions, if it's inbound traffic, the policy will check the source service tag, if it's outbound traffic, the policy will check the destination service tag.

Obviously, the requirements will be different between your network connectivity subscriptions and application landing zone subscriptions. You can assign the same [policy initiative](https://github.com/tyconsulting/azurepolicy/blob/master/policy-definitions/allowed-service-tags-in-nsgs/polset-nsg.json) with different parameters to different management groups or subscriptions to meet the different requirements.

For example, in my lab, I have assigned the policy initiative with the following parameters:

```json
"nsgAllowedInboundServiceTagsEffect": {
  "value": "Deny"
},
"nsgAllowedInboundServiceTags": {
  "value": [
    "VirtualNetwork",
    "AzureLoadBalancer",
    "Internet",
    "GatewayManager",
    "*"
  ]
},
"nsgAllowedOutboundServiceTagsEffect": {
  "value": "Deny"
},
"nsgAllowedOutboundServiceTags": {
  "value": [
    "VirtualNetwork",
    "AzureLoadBalancer",
    "AzureCloud.australiaeast",
    "Internet",
    "AzureCloud",
    "AzureDatabricks",
    "Sql",
    "Storage",
    "EventHub",
    "*"
  ]
}
```

The challenge I had when developing this policy definition was the lack of Regular Expression (regex) support in Azure Policy. Since `sourceAddressPrefix` and `destinationAddressPrefix` in NSG rules are used for both service tags as well as IP addresses or CIDR. There was no easy way to differentiate between service tags and IP addresses in the policy definition. As a result, I had to use a workaround by checking the first character of the value. if the first character is `1-9`, then it's an IP or CIDR and it will be excluded from the policy evaluation (and yes, I did not include `0` because `0.0.0.0` should not be used in NSG rules). This is why you will see a lot of conditions similar to `"NotLike": "1*"` in the policy definition.

I hope this policy definition will be useful for you. If you have any feedback or suggestions, please feel free to leave a comment or reach me on social media.
