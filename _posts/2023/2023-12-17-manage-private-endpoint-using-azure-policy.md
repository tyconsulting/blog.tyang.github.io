---
title: Managing Azure Private Endpoints using Azure Policy
date: 2023-12-17 13:00
author: Tao Yang
permalink: /2023/12/17/manage-private-endpoint-using-azure-policy/
summary:
categories:
  - Azure
tags:
  - Azure
  - Azure Policy

---

Using Azure policies to manage the configuration of resources has become a very common practice and there are already many articles covering this topic. When it comes to Azure Private Endpoints (PE), Pretty much all my customers using Azure Policy to register the DNS records for Private Endpoints. This process is well documented here: [Private Link and DNS integration at scale](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/private-link-and-dns-integration-at-scale).

Few weeks ago, I had a requirement to restrict Private Endpoints of certain Azure resources must be created with manual approval. This is because Private Endpoints for certain resources must only be created under very specific circumstances. For example, the `Browser Authentication` Private Endpoint for Azure Databricks can only be created once per region per Private DNS zone. I could not find any existing policy definitions for enforcing private endpoints with manual approvals. Also the documentation I mentioned above only works for Private Endpoints created with automatic approvals.

So I created 2 policy definitions to cover my requirements.

## 1. Restrict Automatically Approved Private Endpoints for a given resource type

The definition of this policy can be found in my Azure Policy Github repo - [pol-deny-auto-approved-pe.json](https://github.com/tyconsulting/azurepolicy/blob/master/policy-definitions/private-endpoints/pol-deny-auto-approved-pe.json)

The logic is pretty simple. When [creating a Private Endpoint](https://learn.microsoft.com/en-us/rest/api/virtualnetwork/private-endpoints/create-or-update?view=rest-virtualnetwork-2023-05-01&tabs=HTTP), if it is intended to be automatically approved, the `privateLinkServiceConnections` property is used. Otherwise, when manual approval is required, the `manualPrivateLinkServiceConnections` property will be used. So this policy is using the `privateLinkServiceConnections` property to determine if the Private Endpoint is automatically approved or not. If the resource type and the PE sub-resource (aka `Group Id`) matches what's passed in from the parameters and the `privateLinkServiceConnections` property is not empty, the policy will apply the specified effect to the request (either `Deny` or `Audit`).

## 2 Updated policies for Private Endpoints DNS registration (including Manually Approved PEs)

I had to slightly modify the [sample policy definitions from above mentioned documentation](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/private-link-and-dns-integration-at-scale#second-deployifnotexists-policy---matching-on-groupid--privatelinkserviceid) to look for both the `privateLinkServiceConnections` and `manualPrivateLinkServiceConnections` properties.

Using Azure Databricks as example, Databricks has 2 Private Endpoint sub-resources (groupId): `databricks_ui_api` and `browser_authentication`. This policy can be used for both (the `groupId` is parameterised). This policy can be found my Azure Policy Github repo - [pol-deploy-adb-private-dns-zones.json](https://github.com/tyconsulting/azurepolicy/blob/master/policy-definitions/private-endpoints-dns-registration/pol-deploy-adb-private-dns-zones.json).

You can easily update it to cater for other resources, or even make a generic policy definition by parameterising the `privateLinkServiceId` and `groupId` properties.

>**NOTE**: This policy creates a `Microsoft.Network/privateEndpoints/privateDnsZoneGroups` child resource for the Private Endpoint, which essentially represents the Private DNS zone registration. When a Manually approved PE is created, although the policy will create the `privateDnsZoneGroups` resource as soon as the PE is created, the Private DNS zone registration will not be completed until the PE is approved. In another word, the DNS records for the PE will **NOT** be created until the PE is approved. This is by design.
