---
id: 6252
title: 'New PowerShell Module For Azure Automation: AzureServicePrincipalAccount'
date: 2017-10-15T16:54:02+10:00
author: Tao Yang
layout: post
guid: https://blog.tyang.org/?p=6252
permalink: /2017/10/15/new-powershell-module-for-azure-automation-azureserviceprincipalaccount/
categories:
  - Azure
  - PowerShell
tags:
  - Azure
  - Azure Automation
  - Powershell
---
I’m currently working on a project where there has been a lot of discussion on how to use Azure AD Service Principals in Azure Automation and other solutions that involves any automated processes (i.e. VSTS pipelines).

When signing in to Azure using a Service Principal, you can use either a key (password) or a certificate associated to the Service Principal. When using the Add-AzureRMAccount cmdlet, you can use one of the following parameter set:

<strong>Key (password) based:</strong>
<ul>
 	<li>Azure AD Tenant ID</li>
 	<li>Azure Subscription Name or ID</li>
 	<li><span style="background-color: #ffff00;">PS Credential object</span>
<ul>
 	<li><span style="background-color: #ffff00;">User name: Azure AD Application ID</span></li>
 	<li><span style="background-color: #ffff00;">Password: Service Principal key</span></li>
</ul>
</li>
</ul>
<strong>Certificate based:</strong>
<ul><!--StartFragment-->
 	<li>Azure AD Tenant ID</li>
 	<li>Azure Subscription Name or ID</li>
 	<li><span style="background-color: #ffff00;">Certificate (installed in the computer’s cert store)</span></li>
 	<li><span style="background-color: #ffff00;">Certificate Thumbprint</span></li>
</ul>
With Azure Automation, you have the option to create an Azure RunAs account via the Azure portal (<strong>Note:</strong> this option is only available from the Azure portal, not available in ARM APIs and templates)

<a href="https://blog.tyang.org/wp-content/uploads/2017/10/image.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/10/image_thumb.png" alt="image" width="687" height="445" border="0" /></a>

When you create an Azure Run As Account using this wizard, the following objects get created:
<ul>
 	<li>Azure AD Application</li>
 	<li>Certificate based Service Principal for this Azure AD App that has contributor role to the Azure subscription where the automation account is located</li>
 	<li>An Azure Automation Certificate asset for the SP certificate</li>
 	<li>An Azure Automation connection asset that stores the following information:
<ul>
 	<li>Tenant ID</li>
 	<li>Subscription ID</li>
 	<li>Azure AD Application ID</li>
 	<li>Certificate Thumbprint</li>
</ul>
</li>
</ul>
To be honest, I am not a big fan of using such RunAs account because of the following constraints:

<strong>1. There is no automated way to create it outside of Azure Portal.</strong>

These RunAs account looks pretty easy to create via the portal, but you cannot create them using an automated fashion (i.e. via ARM templates)

2. <strong>When creating it manually (via a PowerShell script), you’d normally create a self signed certificate, which requires local admin privilege.</strong>

When you create a self-signed cert using New-SelfSignedCertificate cmdlet, you must execute this command under a local admin (i.e. start a PowerShell window under local administrator). A workaround is to use an Azure Key Vault, generate a self-signed cert from the key vault then export it out. But obviously, you will need to provision a key vault prior to this step.

<strong>3. This RunAs account cannot be used in runbooks executed on Hybrid Workers</strong>

This is probably the biggest drawback. Since Azure Automation does not automatically deploy the certificate assets to Hybrid Workers, you will have to take care of this and manually deploy certificates to Hybrid Worker computers. However, since you cannot export any certificates from Azure Automation account’s certificate store, and the certificate created for the RunAs account is not exposed to you, there is no way you can deploy this certificate to the Hybrid Worker computers, therefore you cannot use this RunAs account on Hybrid workers (unless you manually create every components yourself outside of the Azure Portal and install the certificate to the Hybrid Worker computers).

<strong>4. The wizard only allows you to create one RunAs account for the subscription where the Automation account is located. You cannot create additional ones for other Azure subscriptions.</strong>

If you have runbooks that need to talk to other Azure subscriptions or AAD tenant, then you will have to manually create each required components and store them in your automation account.

<strong>5. A certificate installed on Hybrid Worker computer gives anyone who has access admin privilege to the computer ability to sign in to the Azure subscription</strong>

If you have access to the certificate, then you can easily obtain the cert thumbprint, as long as you know the Azure AD tenant ID and subscription Id (or name), you can sign in to the Azure subscription. This can be a potential security risk because server admins and Azure subscription admins can be 2 different groups of people. Also, if your Hybrid Worker computer is compromised, your Azure AD and subscriptions are also at risk.

Based on these reasons, I have been advising customers to use keys instead of certificates. To simplify the provisioning process and make everyone’s life easier, I have created a very simple PowerShell module called AzureServicePrincipalAccount. You can find this module in PowerShell Gallery and GitHub:

PowerShell Gallery:  <a title="https://www.powershellgallery.com/packages/AzureServicePrincipalAccount" href="https://www.powershellgallery.com/packages/AzureServicePrincipalAccount">https://www.powershellgallery.com/packages/AzureServicePrincipalAccount</a>

GitHub: <a href="https://github.com/tyconsulting/AzureServicePrincipalAccount-PS">https://github.com/tyconsulting/AzureServicePrincipalAccount-PS</a>

By the default, the Azure AD Service Principal connection type provided by Azure Automation accounts only supports certificate-based Azure AD Service Principals. This module provides an additional connection type for key-based Service Principals:

<a href="https://blog.tyang.org/wp-content/uploads/2017/10/image-1.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/10/image_thumb-1.png" alt="image" width="368" height="582" border="0" /></a>

This module also provides a “proxy” function called <strong>Add-AzureRMServicePrincipalAccount</strong> to simplify the Sign-in process to Azure. This function allows you to pass either the built-in <strong>AzureServicePrincipal</strong> connection type or the <strong>Key Based AzureServicePrincipal</strong> type defined in this module, and it will determine the connection type automatically and sign in to Azure using the connection you have passed in. In another word, consider this as a universal sign-in function no matter if you are using the native certificate based SP connection, or a key based connection. Here’s a sample runbook:
<pre language="PowerShell" class="">[CmdletBinding()]
Param(
[String]$ConnectioNName
)

$AzureSPConnection = Get-AutomationConnection -Name $ConnectioNName

If ($AzureSPConnection)
{
$Login = Add-AzureRMServicePrincipalAccount -AzureServicePrincipalConnection $AzureSPConnection
$Login.Context
} else {
Write-Error "Connection asset '$ConnectionName' does not exist in this Automation account."
}
</pre>
Furthermore, you can also using this function without connection objects – by passing individual parameters for either the key or the certificate based Service Principals:

<a href="https://blog.tyang.org/wp-content/uploads/2017/10/image-2.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/10/image_thumb-2.png" alt="image" width="885" height="393" border="0" /></a>

Although by using a key-based Service Principal, you still need to manually create the AAD application and service principals, there is nothing you need to configure on the Hybrid Workers. There are already many PowerShell sample scripts on how to create an Azure AD Service Principal, just for your reference, here’s one I’ve been using in the past:

https://gist.github.com/tyconsulting/ec73a46113f53c2ad3b59ccaaa7502ce

If you are using a CI/CD tool such as VSTS, you can easily port this script to your pipeline and pass the Service Principal details to a ARM template that deploys the Module and connection object to an Automation account.