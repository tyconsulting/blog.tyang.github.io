---
title: Azure Policy Definitions for Event Hub Minimum TLS Version and Public Network Access
date: 2023-01-05 00:00
author: Tao Yang
permalink: /2023/01/05/azure-policy-definitions-event-hub-tls-version-public-access
summary:
categories:
  - Azure
tags:
  - Azure
  - Azure Policy
  - Azure Event Hub
---

Azure Event Hub Namespace has added support for 2 additional properties in the latest API version `2022-01-01-preview`:

* **minimumTlsVersion**: the minimum TLS version that the Event Hub Namespace supports.
* **publicNetworkAccess**: 	This determines if traffic is allowed over public network. By default it is enabled.

![01](../../../../assets/images/2023/01/eventhub-policies-01.jpg)

Since Microsoft has not released any built-in policies for controlling these 2 properties, I have created 2 custom policies to enforce the minimum TLS version and restrict public network access. You can find the policy definitions in my [Azure Policy GitHub repo](https://github.com/tyconsulting/azurepolicy)

* [Enforce Event Hub minimum TLS version](https://github.com/tyconsulting/azurepolicy/blob/master/policy-definitions/event-hub-minimum-tls-version/azurepolicy.json)
* [Restrict Event Hub Public Network Access](https://github.com/tyconsulting/azurepolicy/blob/master/policy-definitions/event-hub-restrict-public-network-access/azurepolicy.json)
