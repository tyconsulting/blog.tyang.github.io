---
title: How To Restrict Event Hub Public Network Access via Azure Policy
date: 2023-01-06 06:00
author: Tao Yang
permalink: /2023/01/06/how-to-restrict-event-hub-public-network-access-via-azure-policy
summary:
categories:
  - Azure
tags:
  - Azure
  - Azure Policy
  - Azure Event Hub
---

Yesterday I [published a policy definition](https://blog.tyang.org/2023/01/05/azure-policy-definitions-event-hub-tls-version-public-access) to [restrict Event Hub public network access](https://github.com/tyconsulting/azurepolicy/blob/master/policy-definitions/event-hub-restrict-public-network-access/azurepolicy.json). After reading my blog post, my friend and colleague [Ahmad Abdalla](https://github.com/ahmadabdalla) told me there is a gap in my policy definition. Although once assigned, the policy will deny the creation of a **NEW** Event Hub namespaces with public network access enabled, but if you are enabling public network access on an **EXISTING** Event Hub namespace via the Azure portal, the policy does not deny the operation.

![1](../../../../assets/images/2023/01/event-hub-public-network-access-01.jpg)

After some investigation, I found that in the Activity Log that my update on the Azure portal was actually targeted the `Microsoft.EventHub/Namespace/NetworkRuleSets` instead of the `Microsoft.EventHub/Namespace resource` type.

![2](../../../../assets/images/2023/01/event-hub-public-network-access-02.jpg)

After the successful operation, the property `Microsoft.EventHub/Namespace/publicNetworkAccess` was set to `Enabled` and policy did not block it.

In order to cater for this behaviour, I had to create an additional policy definition targeting the `Microsoft.EventHub/Namespace/NetworkRuleSets` resource type. The policy definition is available in my [Azure Policy GitHub Repo](https://github.com/tyconsulting/azurepolicy/blob/master/policy-definitions/event-hub-network-ruleset-restrict-public-network-access/azurepolicy.json).

In Summary, to completely restrict public network access for Event Hub, you need to assign both policies:

 * [Azure Event Hub namespaces should disable public network access](https://github.com/tyconsulting/azurepolicy/blob/master/policy-definitions/event-hub-restrict-public-network-access/azurepolicy.json)
 * [Azure Event Hub Namespace Network Rule Set should disable public network access](https://github.com/tyconsulting/azurepolicy/blob/master/policy-definitions/event-hub-network-ruleset-restrict-public-network-access/azurepolicy.json)

Once both policies are assigned, I was able to fill the gap of updating the existing Event Hub namespace via the Azure portal. When I tried to enable public network access, the policy blocked the operation:

![3](../../../../assets/images/2023/01/event-hub-public-network-access-03.jpg)
