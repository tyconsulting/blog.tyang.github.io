---
id: 6354
title: Generating Azure AD oAuth Token in PowerShell
date: 2018-02-04T21:19:09+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=6354
permalink: /2018/02/04/generating-azure-ad-oauth-token-in-powershell/
categories:
  - Azure
  - PowerShell
tags:
  - Azure
  - PowerShell
---
Recently in a project that I’m currently working on, myself and other colleagues have been spending a lot of time dealing with Azure AD oAuth tokens when developing code for Azure.

There are so many scenarios and variations when trying to generate the token, and you have probably seen a lot of samples on the Internet already. I have spent a lot of time trying to develop a common method that the project team can use in all the scenarios. To summarise, you can generate oAuth tokens for the following security principals (and different configurations):

* Azure AD Application Service Principals
  * Certificate-based Service Principals
  * Key-based Service Principals
* Azure AD User Accounts
  * User accounts that do not require Multi-Factor Authentication (MFA)
  * User accounts that requires MFA
  * User accounts that are managed in Azure AD Privileged Identity Management (PIM)
  * Generating the token unattended in the script vs interactively by entering credential in Azure AD sign-in window
    * Enforcing users to use specific account when signing in interactively…
* oAuth token used to access ARM REST API resource endpoints (<a href="https://management.azure.com">https://management.azure.com</a>)
* oAuth token used to access other resource endpoints (i.e. key vault endpoints <a href="https://vault.azure.net">https://vault.azure.net</a>, or Microsoft Graph API)

I began my work by starting creating a PowerShell module that defines an Azure Automation connection type for key-based service principals and provided functions that allows users to generate Azure AD oAuth tokens using either user principals or service principals. I named this module <a href="https://github.com/tyconsulting/AzureServicePrincipalAccount-PS" target="_blank" rel="noopener">AzureServicePrincipalAccount</a> because initially the only intention was to create an Azure Automation connection object for the key-based service principals. I then expanded the scope to providing the ability to generate oAuth tokens.

You can find this module in PowerShell Gallery and GitHub:

* PS Gallery: <a title="https://www.powershellgallery.com/packages/AzureServicePrincipalAccount" href="https://www.powershellgallery.com/packages/AzureServicePrincipalAccount">https://www.powershellgallery.com/packages/AzureServicePrincipalAccount</a>
* GitHub: <a title="https://github.com/tyconsulting/AzureServicePrincipalAccount-PS" href="https://github.com/tyconsulting/AzureServicePrincipalAccount-PS">https://github.com/tyconsulting/AzureServicePrincipalAccount-PS</a>

With this module, you can generate oAuth token for ARM REST API (default) or any other resource (with different API endpoints) supported by Azure AD (such as key vault, Graph API, etc.) using any of the following scenarios:

* Azure AD user - unattended by passing a PS credential object to the function (MFA not being used)
* Azure AD user with MFA enabled – interactive login and manually approve MFA request
* Azure AD user – interactive login by manually entering the user name and password (No MFA)
* Azure AD user – interactive login but restrict username and Tenant Id (prevent users from changing the user name)
* Azure AD key-based service principal
* Azure AD certificate-based service principal – by specifying the path to the pfx certificate file and password
* Azure AD certificate-based service principal – by specifying the certificate thumbprint when the certificate is installed in Local Computer’s ‘Personal" cert store.
* Azure AD service principal – within an Azure Automation runbook and the SP details are stored as a connection object in Azure Automation

So far, I have included 10 examples for the Get-AzureADToken function from this module, this should have all scenarios covered. You can simply read them all using command:

```powershell
Get-Help Get-AzureADToken –Full
```
I hope you will find this module useful when dealing with Azure AD oAuth tokens in PowerShell. Feel free to drop me a note or fork the GitHub repo if you want to see any improvements.