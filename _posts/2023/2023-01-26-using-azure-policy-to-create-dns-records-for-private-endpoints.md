---
title: Using Azure Policy to Create DNS Records for Private Endpoints
date: 2023-01-26 06:00
author: Tao Yang
permalink: /2023/01/26/using-azure-policy-to-create-dns-records-for-private-endpoints
summary:
categories:
  - Azure
tags:
  - Azure
  - Azure Policy
---

Azure Private Link allows you to access Azure PaaS services over a private endpoint in in your virtual network. To make your Azure PaaS resources accessible via Private links, you will need to:

1. Create one or more private endpoints for the Azure resource
2. Create a DNS record for the private endpoint on the specific Azure Private DNS Zone for the particular Private Link service

If you are operating within a Azure Enterprise Scale Landing Zone architecture, you may face the challenge of creating the DNS records for the private endpoints due to the limitation in security permissions. For example, the following diagram is copied from [Microsoft's Azure Enterprise Scale Landing Zone documentation](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/):

![1](../../../../assets/images/2023/01/pe-policy-01.jpg)

When you are creating Private Endpoints for resources in a Landing Zone subscription (or any subscriptions), to create the DNS record (`Microsoft.Network/privateEndpoints/privateDnsZoneGroups` resource) in the associated Private DNS Zone, the identity you are creating the Private Endpoints with will need to have required permissions (i.e. `Network Contributor`) to the Private DNS Zone hosted in the Connectivity subscription. From security point of view, this requirement could be a challenge, since you don't really want to start assigning this permission to everyone who needs to create private endpoints for their resources. If you are managing the Azure infrastructure for your organization, in addition to the security challenge, you would also want to simplify the process of creating Private Endpoints for the Azure PaaS resources for your end users, since your users may not know which Private DNS zones are required for which services, not to mention some services require separate Private DNS zones in each Azure region.

In the several previous engagements, we have implemented a solution to address the above challenges. The solution is to use Azure policy to automatically create the DNS records for the Private Endpoints to appropriate Private DNS zones using `DeployIfNotExists` (DINE) effect. Although you will need to create a policy definition for each Private Endpoint type, but for the most of the services, the policy definitions are mostly the same except for few lines. (Actually, I can probably create a generic policy definition for most of the common scenarios, but I have been lazy.)

* Here is the complete list of all available Private Endpoints: [https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resources](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resources)
* Here is the list of private DNS zone names for each Private Link resource type: [https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration)

I have created few sample policies for the following Azure PaaS services:

* Azure Key Vault
* Azure Databricks Workspace
* Azure Storage Account Blob Service
* Azure Storage Account File Service
* Azure Recovery Services Vault (Backup)

You can find them in my [Azure Policy Github repo](https://github.com/tyconsulting/azurepolicy/tree/master/policy-definitions/private-endpoints-dns-registration)

If you need to create a new policy definition for a service (for example Azure DataLake v2), other than the policy definition name and parameter display names, the only thing you need to modify is the following line:

![2](../../../../assets/images/2023/01/pe-policy-02.jpg)

Let's say you would copy the policy definition from the Azure Key Vault policy, then change the above highlighted line to `"equals": "dfs"` since the `groupId` property of the private endpoint for Azure DataLake v2 is `dfs`. You can find all supported values for the the `groupId` property in the `Subresources` column of the table in the following link: [https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource).

When assigning the policy, you will need to provide the resource Id of the Private DNS zone associated to the specific private link service. You will also need to create at least the `Network Contributor` role for the policy assignment Managed Identity to the Private DNS zone.

For most of the Azure services, one private endpoint requires only one private IP address and one DNS record on one private DNS zone, however, some resources require multiple private IP addresses and DNS records on multiple Private DNZ zones (i.e. Azure Cosmos DB, Azure Kubernetes Services, Azure Backup on Recovery Services Vault, etc.). For these resources, the policy definitions are more complicated. I will not be able to cover them all here in this post.

Since I have already developed a policy definition for Azure Backup on Recovery Services Vault, I have included it in above mentioned GitHub repo (direct link [HERE](https://github.com/tyconsulting/azurepolicy/blob/master/policy-definitions/private-endpoints-dns-registration/pol-deploy-rsv-backup-pe-dns-records.json)). With Azure Backup, you will need to create DNS records on Azure Storage blob service and queue service, as well as the **region-specific** DNS zone for Azure backup.

>**NOTE**: Azure Backup also creates additional DNS records and private IP addresses on-demand, you will also need to enable System Assigned Managed Identity for the RSV and assign permission to the RSV resource group as well as the VNet where the private endpoints are connected to. This requirement is documented [HERE](https://learn.microsoft.com/en-us/azure/backup/private-endpoints).

Lastly, I would also want to mention my colleague and friend [Ahmad Abdalla](https://github.com/ahmadabdalla) again, who have initially worked with me on some of these policy definitions in a customer engagement a while back.
