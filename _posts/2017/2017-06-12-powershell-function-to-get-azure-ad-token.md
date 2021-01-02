---
id: 6101
title: PowerShell Function to Get Azure AD Token
date: 2017-06-12T18:46:54+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=6101
permalink: /2017/06/12/powershell-function-to-get-azure-ad-token/
categories:
  - Azure
  - PowerShell
tags:
  - Azure
  - Azure Resource Manager
  - PowerShell
  - REST API
---
When making Azure Resource Manager REST API calls, you will firstly need to obtain an Azure AD authorization token and use it to construct the authorization header for your HTTP requests.

My good friend Stanislav Zhelyazkov (<a href="https://twitter.com/StanZhelyazkov">@StanZhelyazkov</a>) has written a PowerShell function call Get-AADToken as part of the OMSSearch PowerShell module for this purpose. You can find it in the OMSSearch project’s GitHub repo: <a title="https://github.com/slavizh/OMSSearch/blob/master/OMSSearch.psm1" href="https://github.com/slavizh/OMSSearch/blob/master/OMSSearch.psm1">https://github.com/slavizh/OMSSearch/blob/master/OMSSearch.psm1</a>

I have been using this functions in many projects in the past and it served me well. However, the limitation for Stan’s function is that it only works with user principals – you can only generate such a token if you have an USER account. Today, I needed to make ARM REST API calls using an Azure AD application Service Principal. So I had to update Stan’s function in order to support AAD applications. Here’s the updated version:

https://gist.github.com/tyconsulting/6d2ac80d597273c342776bd83999db7f

By default, if you don’t specify the ‘AuthenticationType’, it defaults to ‘UserPrincipal’ and everything works just like before. But to generate AAD token for an Azure AD application, you will need to use the AAD Application Id (as user Id) and AAD Application password  (as password) to construct a pscredential object, then specify ‘ServicePrincipal’ as the ‘AuthenticationType’ parameter value.

Here are two examples how to use both UPN and SPN in a REST call to get all resource groups in your Azure subscription:

<strong>Using User Principals:</strong>
```powershell
$TenantId = 'your AAD tenant Id'
$subscriptionId = 'your azure sub id'
$userName = 'admin@yourcompany.onmicrosoft.com'
$pw = ConvertTo-SecureString -String 'password1234' -AsPlainText -Force
$AzureAdminCred = New-Object System.Management.Automation.PSCredential($userName, $pw)
$Token = Get-AADToken -TenantID $TenantId -Credential $AzureAdminCred
$RESTAPIHeaders = @{'Authorization'=$Token;'Accept'='application/json'}
$URI = "https://management.azure.com/subscriptions<a href="https://management.azure.com/subscriptions/">/</a>$subscriptionId/resourceGroups?api-version=2014-04-01"
$GetResourceGroupsRequest = Invoke-WebRequest -UseBasicParsing -Uri $URI -Method GET -Headers $RESTAPIHeaders

```
<strong>Using AAD Application Service Principals:</strong>
```powershell
$TenantId = 'your AAD tenant Id'
$subscriptionId = 'your azure sub id'
$AADAppId = 'Your Azure AD Application Id'
$AADAppPassword = ConvertTo-SecureString -String 'password1234' -AsPlainText -force
$Credential = New-Object System.Management.Automation.PSCredential($AADAppId, $AADAppPassword)
$Token = Get-AADToken -TenantID $TenantId -Credential $Credential -AuthenticationType ServicePrincipal
$RESTAPIHeaders = @{'Authorization'=$Token;'Accept'='application/json'}
$URI = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups?api-version=2014-04-01"
$GetResourceGroupsRequest = Invoke-WebRequest -UseBasicParsing -Uri $URI -Method GET -Headers $RESTAPIHeaders

```
The HTTP request returns a response that’s saved in the $GetResourceGroupsRequest variable. To access the result, you will need to convert the response content from JSON to PSobject. i.e.
```powershell
$ResourceGroups = ($GetResourceGroupsRequest.Content | ConvertFrom-Json).value

```
<a href="https://blog.tyang.org/wp-content/uploads/2017/06/image.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/06/image_thumb.png" alt="image" width="991" height="160" border="0" /></a>