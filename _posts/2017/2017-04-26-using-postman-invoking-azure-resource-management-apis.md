---
id: 5992
title: Using Postman Invoking Azure Resource Management APIs
date: 2017-04-26T22:09:49+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=5992
permalink: /2017/04/26/using-postman-invoking-azure-resource-management-apis/
categories:
  - Azure
tags:
  - Azure
  - OMS
  - PowerShell
---
<a href="https://blog.tyang.org/wp-content/uploads/2017/04/SNAGHTML21e56dff.png"><img style="background-image: none; float: left; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML21e56dff" src="https://blog.tyang.org/wp-content/uploads/2017/04/SNAGHTML21e56dff_thumb.png" alt="SNAGHTML21e56dff" width="168" height="168" align="left" border="0" /></a>When working with REST APIs, Postman (<a href="https://getpostman.com">https://getpostman.com</a>) is a popular tool that needs no further introductions. This week, I’ve been pretty busy working on the upcoming Inside OMS V2 book, and I’m currently focusing on the various OMS REST APIs for the Custom Solutions chapter. I want to use Postman to test and demonstrate how to use the OMS REST APIs. Since most of the ARM based APIs requires oAuth token in the authorization header, I needed to configure Postman to contact Microsoft Graph API in order to generate the token for the API calls.

Initially, I thought this would be very straightforward and should have been done by other people in the past. I did find several posts via my favourite search engine, which were good enough to get me started, but I was not able to find one that explains how to configure Postman to request for the token natively without using external processes to generate the token. Therefore, I’m going to document what I have done here so I can reference this post in the Inside OMS book :smiley:.

**Note:** I’m using the Windows desktop version of Postman, the UI may be slightly different than the Chrome extension version.

**Step 1: Create an Azure AD application and service principal for Postman.**

I have automated the creation process using a [PowerShell script](https://gist.github.com/tyconsulting/a42acbaea669d4aa4e696776a5a3b939) shown below:

```powershell
#Requires -Modules AzureRM.Resources, AzureRM.Profile
#Modify below variables
$SubscriptionName = "Tao Playground"
$ApplicationDisplayName = "Postman"

#region functions
Function New-Passowrd
{
  [CmdletBinding()]
  PARAM (
    [Parameter(Mandatory = $true)][int]$Length,
    [Parameter(Mandatory = $true)][int]$NumberOfSpecialCharacters
  )
  Add-Type -AssemblyName System.Web
  [Web.Security.Membership]::GeneratePassword($Length,$NumberOfSpecialCharacters)
}
#endregion

#region main
#Variables
$SignOnUrl = "https://www.getpostman.com"
$ReplyUrl = "https://www.getpostman.com/oauth2/callback" #Do not change this one

Write-Output "Loging to Azure"
Add-AzureRMAccount
#Add-AzureRMAccount -Credential $AADCred
$Context = Set-AzureRmContext -SubscriptionName $SubscriptionName
$SubscriptionId = $Context.Subscription.SubscriptionId
$TenantId = $Context.Tenant.TenantId


$ApplicationPassword = New-Passowrd -Length 16 -NumberOfSpecialCharacters 0
$Application = New-AzureRmADApplication -DisplayName $ApplicationDisplayName -HomePage $SignOnUrl -IdentifierUris "http://$ApplicationDisplayName" -ReplyUrls $ReplyUrl -Password $ApplicationPassword
Write-OUtput "Creating Azure AD Application Service Principal."
$ApplicationServicePrincipal = New-AzureRmADServicePrincipal -ApplicationId $Application.ApplicationId

Write-Output "Assigning the Contributor role to the application Service Principal..."
$NewRole = $null
$Retries = 0
While ($NewRole -eq $null -and $Retries -le 5)
{
  # Sleep here for a few seconds to allow the service principal application to become active (should only take a couple of seconds normally)
  Start-Sleep -Seconds 10
  New-AzureRmRoleAssignment -RoleDefinitionName Contributor -ServicePrincipalName $Application.ApplicationId -ErrorAction SilentlyContinue
  Start-Sleep -Seconds 10
  $NewRole = Get-AzureRmRoleAssignment -ServicePrincipalName $Application.ApplicationId -ErrorAction SilentlyContinue
  $Retries++
}

Write-Output "Save below information for future use:"
Write-Output "Azure Subscription Id: '$SubscriptionId'"
Write-Output "'$ApplicationDisplayName' application client ID: '$($Application.ApplicationId.ToString())'"
Write-Output "'$ApplicationDisplayName' application client secret: '$ApplicationPassword'"
Write-Output ""
Write-Output "Now go to https://manage.windowsazure.com and grant postman applicaiton access to the Windows Azure Service Management API (Delegated Permission: Access Azure Service Management as Organization users"
#endregion
```

<a href="https://blog.tyang.org/wp-content/uploads/2017/04/image-2.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/04/image_thumb-2.png" alt="image" width="658" height="227" border="0" /></a>

**Step 2: Grant ‘Postman’ application permission to the Windows Azure Service Management API.**

Note: steps demonstrated below MUST be completed in the Azure classical portal. Based on my experience, I was not able to give the Azure AD application permission to "Windows Azure Service Management API" from the new ARM portal.

Once the ‘Postman’ Azure AD application is created, logon to the Azure classical portal (<a href="https://manage.windowsazure.com">https://manage.windowsazure.com</a>), browse to Azure AD, select the directory of where the application is created, then go to Applications, show "Applications my company owns", locate the "Postman" application.

<a href="https://blog.tyang.org/wp-content/uploads/2017/04/image-3.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/04/image_thumb-3.png" alt="image" width="477" height="424" border="0" /></a>

Click the "Postman" application, go to "Configure" tab, and click "Add Application".

<a href="https://blog.tyang.org/wp-content/uploads/2017/04/image-4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/04/image_thumb-4.png" alt="image" width="402" height="243" border="0" /></a>

Add "Windows Azure Service Management API"

<a href="https://blog.tyang.org/wp-content/uploads/2017/04/image-5.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/04/image_thumb-5.png" alt="image" width="306" height="186" border="0" /></a>

Tick "Access Azure Service Management as Organization users" under the "Delegated Permissions" drop down list and then click on "Save".

<a href="https://blog.tyang.org/wp-content/uploads/2017/04/image-6.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/04/image_thumb-6.png" alt="image" width="369" height="197" border="0" /></a>

**Step 3: Configure Authorization in Postman.**

In Postman, enter an URI for an ARM REST API call, in this example, I’ll use the OMS REST API to retrieve a list of workspaces. Here’s the URI I’m using: **https://management.azure.com/subscriptions/_{subscription id}_/providers/microsoft.operationalinsights/workspaces?api-version=2015-03-20**

Make sure the HTTP method is set to "GET", and then click on Authorization. For the "Type" drop down list, select OAuth 2.0

<a href="https://blog.tyang.org/wp-content/uploads/2017/04/image-7.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/04/image_thumb-7.png" alt="image" width="478" height="301" border="0" /></a>

Click on "Get New Access Token".

<a href="https://blog.tyang.org/wp-content/uploads/2017/04/image-8.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/04/image_thumb-8.png" alt="image" width="306" height="134" border="0" /></a>

Enter the following information in the "Get New Access Token" popup window:

* Token Name: **<span style="background-color: #ffff00;">AAD Token</span>**
* Auth URL: <span style="background-color: #ffff00;">**https://login.microsoftonline.com/common/oauth2/authorize?resource=https%3A%2F%2Fmanagement.azure.com%2F**</span>
* Access Token URL: **<span style="background-color: #ffff00;">https://login.microsoftonline.com/common/oauth2/token</span>**
* Client ID: **<span style="background-color: #ffff00;"><output from the script in Step 1></span>**
* Client Secret: **<span style="background-color: #ffff00;"><output from the script in Step 1></span>**
* Grant Type: **<span style="background-color: #ffff00;">Authorization Code</span>**
* Make sure "Request access token locally" checkbox is unchecked.

<a href="https://blog.tyang.org/wp-content/uploads/2017/04/image-9.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/04/image_thumb-9.png" alt="image" width="283" height="342" border="0" /></a>

Click on "Request Token", you will get the Azure AD sign-in page, enter the credential of an **Organization account**, – based on my experience, Microsoft accounts (i.e. @outlook.com) do not always work.

<a href="https://blog.tyang.org/wp-content/uploads/2017/04/image-10.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/04/image_thumb-10.png" alt="image" width="307" height="193" border="0" /></a>

If everything goes as planned, you will see a new token been generated. you need to select the token, and add it to the request header:

<a href="https://blog.tyang.org/wp-content/uploads/2017/04/image-11.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/04/image_thumb-11.png" alt="image" width="447" height="238" border="0" /></a>

Now, go to the "Headers" tab, you should see the Authorization header:

<a href="https://blog.tyang.org/wp-content/uploads/2017/04/image-12.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/04/image_thumb-12.png" alt="image" width="444" height="130" border="0" /></a>

You may need to add additional headers for the request depending on the requirements of the API, but in this case, I don’t need any, I can just call the API by clicking on Send button.

Now I can see all my OMS workspaces in this particular subscription listed in the response body.

<a href="https://blog.tyang.org/wp-content/uploads/2017/04/image-13.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/04/image_thumb-13.png" alt="image" width="482" height="426" border="0" /></a>

This concludes the work through, please do let me know if you are running into issues.

Lastly, This post has been a great help for me (although it’s for Dynamic CRM, not for Azure, it did point me to the right direction): <a title="https://blogs.msdn.microsoft.com/devkeydet/2016/03/22/using-postman-with-azure-ad/" href="https://blogs.msdn.microsoft.com/devkeydet/2016/03/22/using-postman-with-azure-ad/">https://blogs.msdn.microsoft.com/devkeydet/2016/03/22/using-postman-with-azure-ad/</a>