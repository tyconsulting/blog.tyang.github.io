---
title: Azure Private Endpoints with Static IP Addresses
date: 2023-01-04 00:00
author: Tao Yang
permalink: /2023/01/04/azure-private-endpoint-with-static-ip-addresses
summary:
categories:
  - Azure
tags:
  - Azure
  - Azure Bicep

---

In my current project, we have a requirement that all Private Endpoint (PE) connections must use static IP addresses. All Private Endpoint IP addresses must be pre-allocated so that we can streamline the process of raising firewall requests to integrate with customer's on-premises network. This post will show you how to create Private Endpoint with static IP addresses using Azure Bicep.

Static IP assignments for Private Endpoints is supported by the Azure `Microsoft.Network` resource provider since API version `2021-03-01`. You can define the static IP in the `ipConfigurations` property for the Private Endpoint resource ([reference](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/privateendpoints?pivots=deployment-language-bicep#privateendpointipconfiguration)). Most of the resources only require 1 IP address per Private Endpoint (for example, key vault, Azure SQL, etc.), some resources require multiple IP addresses per Private Endpoints (i.e. Azure Cosmos DB). You can define one or more static IP Addresses within the `ipConfigurations` property since it is an array.

I have created a sample Bicep template to create an Azure Storage Account, a Private Endpoint for the blob service, and another Private Endpoint for the Azure Data Lake (ADLS) Gen2 service. The Private Endpoints are configured with static IP addresses. The Bicep template can be found in my [GitHub repo](https://github.com/tyconsulting/BlogPosts/tree/master/Azure-Bicep/private.endpoint.static.ip).

In this template, I have defined 2 separate Private Endpoint resources for the same Storage Account. The static IP addresses for each PE are passed in as parameters (as shown in the code sample below).

>**NOTE**: Private Endpoints have a unique `groupId` for each resource type. For example, the `groupId` for the Storage Account blob service is `blob`, ADLS Gen2 is `dfs`, and Azure Key Vault is `vault`, etc. You can find the full list [HERE](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource).

```hcl
resource blobPe 'Microsoft.Network/privateEndpoints@2022-07-01' = {
  name: blobPrivateEndpointName
  location: location
  tags: tags
  properties: {
    customNetworkInterfaceName: blobPrivateEndpointNicName
    ipConfigurations:  [
      {
        name: 'ipconfig1'
        properties: {
          groupId: 'blob'
          memberName: 'blob'
          privateIPAddress: blobPrivateEndpointIP
        }
      }
    ]
    privateLinkServiceConnections: [
      {
        name: blobPrivateEndpointName
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
    subnet: {
      id: subnetId
    }
  }
}
```

Generally, the `memberName` value is the same as `groupId` for most of the resources, if you are not sure, you can always try to create a PE manually via the portal, export the template and check the `memberName` value.

In my sample template, I have configured the blob PE to use the static IP of `10.101.2.10` and ADLS PE to use `10.101.2.11`.

You can verify the IP address via the Azure portal by checking the IP Configuration for the NIC of the Private Endpoint.

**blob PE**

![01](../../../../assets/images/2023/01/pe-static-ip-01.jpg)

**ADLS PE**

![01](../../../../assets/images/2023/01/pe-static-ip-02.jpg)

By using this approach, I was able to satisfy the requirement for most of the resources that I need to deploy. The only exception I have encountered so far is the Azure Recovery Services Vault (RSV). When creating Private Endpoints for RSVs, the RSV dynamically allocates IP addresses for the PE. In this case, I had to create a dedicated subnet for RSV Private Endpoints, so that I can pre-allocate the IP addresses for the RSVs.

P.S. The [Private Endpoint module in Microsoft Azure CARML module library](https://github.com/Azure/ResourceModules/blob/main/modules/Microsoft.Network/privateEndpoints/deploy.bicep) already supports the static IP allocations by using the `ipConfigurations` parameter.