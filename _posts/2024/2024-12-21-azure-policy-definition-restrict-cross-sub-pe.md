---
title: Azure Policies for Restricting Cross-Subscription Private Endpoints
date: 2024-12-21 21:00
author: Tao Yang
permalink: /2024/12/21/azure-policy-definitions-restrict-cross-sub-pe
summary: Azure policy definitions for restricting cross-subscription private endpoints
categories:
  - Azure
tags:
  - Azure
  - Azure Policy
---

Some SaaS products provide the ability to privately connect the service to your Azure environment using Azure Private Endpoints. In this scenario, often the SaaS provider would provide you an Private Link alias so you can create a Private Endpoint in your Azure subscription and connect resource hosted by the SaaS provider to your Azure Virtual Network (i.e.[Snowflake](https://docs.snowflake.com/en/user-guide/privatelink-azure) and [Confluent Cloud](https://docs.confluent.io/cloud/current/networking/private-links/azure-privatelink.html)).

![01](../../../../assets/images/2024/12/cross-sub-pe-01.jpg)

This introduces a potential data exfiltration risk if you are allowing the users to connect to any SaaS instances in their Azure environment. You will definitely want to have a way to ensure only the legitimate SaaS service instances are allowed to be connected to your Azure environment.

I have developed a Azure Policy definition to provide control to this scenario. It can be used to restrict cross-subscription (and cross-tenant) Private endpoint connections when an Azure Private Endpoint is created in your Azure environment.

The policy definition can be found at my GitHub `azurepolicy` repo [HERE](https://github.com/tyconsulting/azurepolicy/blob/master/policy-definitions/restrict-cross-subscription-pe/azurepolicy.json).

This policy can also be used to restrict users from creating a Private Endpoint for a resource in another subscription (cross-subscription but same tenant) except for resource Ids or aliases defined in the `allowedCrossSubPrivateLinkResources` parameter. This allows your security and cloud governance team to examine each connection and verify they are legitimate before allowing the connection.

Since this policy is targeting the Private Endpoint resource, it can be used to control what external resources can be connected to your Azure virtual network. The other piece of the puzzle is that you may also want to ensure your Azure resources are not connected to an external Azure Virtual Network that's outside of your control (i.e. someone's personal MSDN subscription or subscriptions controlled by attackers). I was going to develop some policies to close the loop but looks like there are already some existing policies in the Azure Policy Community repo. To name a few:

* [Prevent cross tenant Private Link for aks](https://github.com/Azure/Community-Policy/blob/main/policyDefinitions/Network/prevent-cross-tenant-private-link-for-aks/azurepolicy.json)
* [Prevent cross tenant Private Link for acr](https://github.com/Azure/Community-Policy/blob/main/policyDefinitions/Network/prevent-cross-tenant-private-link-for-acr/azurepolicy.json)
* [Prevent cross tenant Private Link for key vault](https://github.com/Azure/Community-Policy/blob/main/policyDefinitions/Network/prevent-cross-tenant-private-link-for-key-vault/azurepolicy.json)

These rules are pretty similar, the only thing different is the resource type it's targeting to. If you can't find the ones you need in the Community Policy repo, you should be able to create one based on the examples above.
