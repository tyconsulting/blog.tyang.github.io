---
title: Script to Create Azure Purview Integration Runtimes
date: 2023-03-11 09:00
author: Tao Yang
permalink: /2023/03/11/purview-integration-runtime-script
summary:
categories:
  - Azure
  - PowerShell
tags:
  - Azure
  - Azure Purview
---

I needed to create Azure Purview with a Self-Hosted Integration Runtime (SHIR) as part of a Infrastructure as Code (IaC) pipeline. Having previously created Azure Data Factory (ADF) with SHIR and I was told by our data engineers the creation process is pretty much the same, I thought it would be fairly easy, just an Integration Runtime resource in my Bicep template. But it turned out although the portal experience is almost identical to ADF, unlike ADF, Purview Integration Runtimes (IR) is not a resource type in Azure Resource Manager.

In the Azure REST API documentation, it is under a category called "Scanning Data Plane". The API endpoint for creating the Purview IRs is `PUT {Endpoint}/scan/integrationruntimes/{integrationRuntimeName}?api-version=2022-07-01-preview`

I was not able to find any commands from Azure CLI and Azure PowerShell to create the Purview IRs. So I create a PowerShell script to invoke this REST API directly. It can be used to create either an Azure (Managed) or Self-Hosted IR. The script is available on my [BlogPost GitHub repo](https://github.com/tyconsulting/BlogPosts/blob/master/Azure/CreatePurviewIR.ps1).

I used this script as part of my IaC pipeline. It checks if the IR already exists before creating it. So it can be executed as many times as needed without causing any errors.

To run the script:

```PowerShell
#firstly login to Azure (You don't need to set the az context to the subscription where the Purview account is)
Add-AzAccount

#script parameters
$params = @{
    purviewAccountName = 'myPurviewAccount'
    resourceGroupName = 'myResourceGroup'
    subscriptionId = 'mySubscriptionId'
    integrationRuntimeName = 'myIntegrationRuntime'
    kind = 'SelfHosted' #or 'Managed'
    integrationRuntimeDescription = 'optional description for the IR'
}

.\CreatePurviewIR.ps1 @params
```

![1](../../../../assets/images/2023/03/purview-ir-01.jpg)

Notice the Azure Resource ID for the IR is from a subscription not in my tenant. Since Purview is a SaaS service, looks like the IR is hosted in one of Microsoft's subscriptions.

Once the IR is created, I can see it in the Purview portal. Since I have created a Self-Hosted IR, It is showing Unavailable because I haven't had any Virtual Machines registered to it yet.

![2](../../../../assets/images/2023/03/purview-ir-02.jpg)

After the SHIR is created for the Purview account, the next task would be registering the VMs to it. that part is pretty much identical to ADF (Except for the way to retrieve the IR keys). I will not cover that in this post, but the API to retrieve the keys for the SHIR is documented [here](https://learn.microsoft.com/en-us/rest/api/purview/scanningdataplane/integration-runtimes/list-auth-keys?tabs=HTTP).
