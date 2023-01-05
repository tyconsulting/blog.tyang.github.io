---
title: Bicep Template for VNet Isolated CloudShell
date: 2023-01-06 00:00
author: Tao Yang
permalink: /2023/01/06/bicep-template-for-vnet-isolated-cloudshell
summary:
categories:
  - Azure
tags:
  - Azure
  - Azure Bicep

---

## Introduction

![1](https://learn.microsoft.com/en-us/azure/cloud-shell/media/private-vnet/data-diagram.png)

Based on what I have seen over the past few years, the use of Azure CloudShell is actively discouraged by most of my customers. Customers would normally have an Azure Policy assigned to restrict the public access of Storage Accounts. Since by default, when you firstly initiated the CloudShell, it creates a public facing storage account for you, it's not possible to use CloudShell in this case.

Few months ago, I bumped into a blog post from Thomas Maurer [Connect Azure Cloud Shell to Virtual Network vNet](https://www.thomasmaurer.ch/2020/08/connect-azure-cloud-shell-to-virtual-network-vnet/), I found it was really interesting, and can potentially help me overcome a problem I had at that time. Thomas' blog post was written over 2 years ago and at that time, the VNet Isolated CloudShell was still in preview. Now this feature is already GA'd.

I gave it a try, but I felt the [documentation](https://learn.microsoft.com/en-us/azure/cloud-shell/private-vnet) was not very clear to me, the sample code provided by Microsoft does not satisfy many security requirements from my customer (and also written in ARM, not Bicep). So I ended up spent few days trying to figure out how to deploy this solution in a more secured way. I finally managed to create a Bicep template for this solution, and I'm sharing it here.

You can find my Bicep template in my [GitHub repo](https://github.com/tyconsulting/BlogPosts/tree/master/Azure-Bicep/vnet-isolated-cloud-shell)

In my environment, I have a hub-spoke network, I have deployed the CloudShell in the hub network, and I have a few spokes networks, I am able to connect to the resources connected to the spoke networks via their Private Endpoints using the Cloud Shell from the hub network.

## Prerequisites

I have the following existing resources deployed in the connectivity subscription where the hub Virtual Network is located:

* A Resource Group for the Hub VNet. In this RG, I have the following resources:
  * A Virtual Network (Hub VNet)
    * A subnet for Private Endpoints
  * A private DNS zone for the Azure relay Private Endpoint (`privatelink.servicebus.windows.net`) and it's linked to all hub and spoke VNets

The Azure Container Instance Resource Provider must be registered in the subscription where the CloudShell is deployed. Once this RP is registered for at least 1 subscription in your tenant, you will be able to get the Service Principal object Id for the Azure AD application 'Azure Container Instance'. You can use the following command to get the Service Principal object Id. This Id needs to be specified in the Bicep parameter file (`azureContainerInstanceOID` parameter).

```powershell
Get-AzADServicePrincipal -DisplayNameBeginsWith 'Azure Container Instance' | select-object Id
```

## Bice Template

The Bicep template I have created deploys the following resources into the same Resource Group as the Hub VNet:

* Network profile for container instance (required for the CloudShell)
* Required Role Assignments the Azure Container Instance Service Principal
* An additional subnet for the CloudShell container in the hub VNet with Storage account Service Endpoint enabled
* Service Endpoint Policy for the CloudShell subnet that only allows storage accounts from the same resource group. This Service Endpoint Policy is linked to the CloudShell subnet.
* A Storage Account for the CloudShell
  * Connected to the Service Endpoint in the CloudShell subnet
  * Configured the Storage Account with a the following properties:
    * `requireInfrastructureEncryption`: true
    * `allowBlobPublicAccess`: false
    * `allowSharedKeyAccess`: true (required for CloudShell)
    * `allowCrossTenantReplication`: false
    * `publicNetworkAccess`: 'Enabled' (required to be Enabled to leverage Service Endpoint)
    * `minimumTlsVersion`: 'TLS1_2'
    * `isHnsEnabled`: false
    * `isLocalUserEnabled`: false
    * `isSftpEnabled`: false
    * `supportsHttpsTrafficOnly`: true
* Azure Relay Namespace with Private Endpoint connected to the existing Private Endpoint subnet in the Hub VNet
* Private DNS Zone record for the Azure Relay Private Endpoint in the existing Private DNS Zone in the Hub VNet

As you can see, the only 2 less-secure configurations for the Storage Account are `allowedSharedKeyAccess` (as opposed to using Azure AD authentication) and `publicNetworkAccess` (as opposed to using Private Endpoint). The Storage Account with only Private Endpoint cannot be used for CloudShell, and CloudShell cannot create the file share in the Storage Account if Shared Key Access is disabled (as shown below). I have not found a way to use Azure AD authentication for the CloudShell Storage Account.

![02](../../../../assets/images/2023/01/cloudshell-01.jpg)

>**NOTE**: In a previous test, I was also able to configure the Storage Account to use Custom-Managed Key (CMK) Encryption using an Azure Key Vault which is also connected to the VNet using Private Endpoint. I have not included this feature in the Bicep template since it will make the template significantly more complex.

## Post Deployment Configuration

Once the Bicep template is successfully deployed, you can configure the CloudShell to leverage the VNet isolation feature. Once you have selected the correct subscription, region, and VNet resource group, the rest of the fields should be automatically populated. You will need to specify the name of File Share, it will be automatically created if it does not exist.

![03](../../../../assets/images/2023/01/cloudshell-02.jpg)

![04](../../../../assets/images/2023/01/cloudshell-03.jpg)

## Test

The initiation time for VNet isolated CloudShell is significantly longer than the public facing CloudShell. It took me about 5 minutes whenever I started the CloudShell. Once started, I can connect to resources that are not exposed to the public Internet from the CloudShell. For demonstration, I have created a Storage Account in another subscription connected to a spoke VNet using Private Endpoint. I have enabled SFTP feature for this Storage Account. I cannot create any folders in the SFTP blob container from the Azure Portal because public access is disabled, but I was able to do it via the CloudShell once I have connected to the Storage Account using SFTP.

**CloudShell**

![05](../../../../assets/images/2023/01/cloudshell-04.jpg)

**Azure Portal**

![06](../../../../assets/images/2023/01/cloudshell-05.jpg)

## Conclusion

I don't believe this solution is perfect, the initiation time is too long, and lack of the support for Storage Account Private Endpoints and Azure AD authentication could be a show stopper for some customers. But it offers a way to allow users to access resources that are not exposed to the public Internet from the Azure Portal, which can be very useful in some scenarios.
