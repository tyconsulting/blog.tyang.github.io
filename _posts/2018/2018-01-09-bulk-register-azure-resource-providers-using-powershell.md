---
id: 6340
title: Bulk Register Azure Resource Providers Using PowerShell
date: 2018-01-09T22:50:34+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=6340
permalink: /2018/01/09/bulk-register-azure-resource-providers-using-powershell/
categories:
  - Azure
  - PowerShell
tags:
  - Azure
  - PowerShell
---
Azure Resource Providers registration dictates what types of resources you allow users to provision within your Azure subscription. Although by default, some resource providers are automatically registered, the user must have required permission to register resource providers (<a title="https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-manager-supported-services" href="https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-manager-supported-services">https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-manager-supported-services</a>). I had to create a script to bulk-register resource providers for a subscription because normal users have not been given the permissions to do so.

In the following sample script, I am using regular expressions to match the resource provider names, and it is registering all Microsoft resource providers except for the classic (ASM) resource types.

https://gist.github.com/tyconsulting/30bf4907dbaa6391ac607e69bb43475f

This script requires the following two PowerShell modules:
<ul>
 	<li>AzureRM.Profile (<a title="https://www.powershellgallery.com/packages/AzureRM.profile" href="https://www.powershellgallery.com/packages/AzureRM.profile">https://www.powershellgallery.com/packages/AzureRM.profile</a>)</li>
 	<li>AzureServicePrincipalAccount (<a title="https://www.powershellgallery.com/packages/AzureServicePrincipalAccount" href="https://www.powershellgallery.com/packages/AzureServicePrincipalAccount">https://www.powershellgallery.com/packages/AzureServicePrincipalAccount</a>)</li>
</ul>
<strong>Syntax:</strong>

1. Using a Key Based AzureServicePrincipal connection (in Azure Automation as a runbook, explained in my <a href="https://blog.tyang.org/2017/10/15/new-powershell-module-for-azure-automation-azureserviceprincipalaccount/">previous post</a>):
<pre class="lang:ps decode:true ">Register-AzureResourceProviders.ps1 –AzureConnectionName ‘AzureConnectionName’</pre>
2. Using a key-based (not certificate based) Service Principal or an Azure AD user account without Multi-Factor Authentication (MFA) (for key based service principals, use the AAD Application Id as the user name and the key as the password when creating the PSCredential object):
<pre class="lang:ps decode:true ">Register-AzureResourceProviders.ps1 –TenantId ‘MyAADTenantID’ –SubscriptionId ‘MyAzureSubscriptionId’ –Credential $Credential</pre>
3. Using an AzureAD user account (with or without MFA, you will be prompted to enter the password and may be prompted for MFA if required) – this method only works when you are running this script interactively.
<pre class="lang:ps decode:true ">Register-AzureResourceProviders.ps1 –TenantId ‘MyAADTenantID’ –SubscriptionId ‘MyAzureSubscriptionId’ –UserName ‘my.name@mycompany.onmicrosoft.com’</pre>
<strong><span style="color: #ff0000;">Note:</span></strong> For most of scripts I’ve written for Azure, I intentionally avoid using the official AzureRM PowerShell modules (well, this is a topic for another day), but instead, I’m using Azure Resource Manager REST API. The only reason this script requires the AzureRM.Profile module is because my AzureServicePrincipalAccount module requires a DLL from the AzureRM.Profile module in order to obtain the Azure AD oAuth token (for the REST API calls). You may modify the script to suit your requirements by adding / removing the inclusion and exclusion regular expressions (line 103-104).