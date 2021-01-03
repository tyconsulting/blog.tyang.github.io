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

In the following [sample script](https://gist.github.com/tyconsulting/30bf4907dbaa6391ac607e69bb43475f), I am using regular expressions to match the resource provider names, and it is registering all Microsoft resource providers except for the classic (ASM) resource types.

```powershell
#Requires -Modules AzureServicePrincipalAccount, AzureRM.Profile
<#
=======================================
AUTHOR:  Tao Yang 
DATE:    15/12/2017
Version: 0.1
Comment: register Azure Resource Providers
=======================================
#>
[CmdletBinding()]
[OutputType([string])]
PARAM (
  [Parameter(ParameterSetName='BySPConnection', Mandatory=$true)]
  [Alias('Con','Connection')]
  [String]$AzureConnectionName,

  [Parameter(ParameterSetName='ByCred', Mandatory=$true)]
  [Parameter(ParameterSetName='ByInteractiveSignIn', Mandatory=$true)]
  [ValidateScript({
    try 
    {
      [System.Guid]::Parse($_) | Out-Null
      $true
    } 
    catch 
    {
      $false
    }
  })]
  [String]$TenantID,

  [Parameter(ParameterSetName='ByCred', Mandatory=$true)]
  [Parameter(ParameterSetName='ByInteractiveSignIn', Mandatory=$true)]
  [ValidateScript({
    try 
    {
      [System.Guid]::Parse($_) | Out-Null
      $true
    } 
    catch 
    {
      $false
    }
  })]
  [String]$SubscriptionId,

  [Parameter(ParameterSetName = 'ByCred',Mandatory = $true,HelpMessage = 'Please specify the Azure AD credential')]
  [Alias('cred')]
  [ValidateNotNullOrEmpty()]
  [PSCredential]$Credential,

  [Parameter(ParameterSetName = 'ByInteractiveSignIn',Mandatory = $true,HelpMessage = 'Please specify the Azure AD user name for interactive sign-in')]
  [Alias('u')]
  [ValidateNotNullOrEmpty()]
  [string]$UserName
)

#region functions
Function Get-AllResourceProviders
{
  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][Hashtable]$headers,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$subscriptionId
  )
  $URI = "https://management.azure.com/subscriptions/$SubscriptionId/providers?api-version=2017-05-10"
  $Response = Invoke-WebRequest -UseBasicParsing -Uri $URI -Method Get -Headers $headers -ContentType 'application/json'
  $Result = (Convertfrom-json $Response.content).value
  $Result
}
Function Register-ResourceProvider
{
  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][Hashtable]$headers,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$subscriptionId,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$Namespace
  )
  $RegisterURI = "https://management.azure.com/subscriptions/$SubscriptionId/providers/$Namespace`/register?api-version=2017-05-10"
  $GetURI = "https://management.azure.com/subscriptions/$SubscriptionId/providers/$Namespace`?api-version=2017-05-10"
  Try {
    $Response = Invoke-WebRequest -UseBasicParsing -Uri $RegisterURI -Method POST -Headers $headers -ContentType 'application/json'
  } Catch {
    $Registered = $false
    Trow $_.Exception
  }
  
  If ($Response.StatusCode -ge 200 -and $Response.StatusCode -le 299)
  {
    $Registered = $true
  } else {
    $Registered = $false
  }
  $Registered
}
#endregion

#region variales
$arrExcludedResourceProvidersRegex = New-Object System.Collections.ArrayList
$arrIncludedResourceProvidersRegex = New-Object System.Collections.ArrayList
$arrRegisterResourceProviders = New-Object System.Collections.ArrayList
[void]$arrIncludedResourceProvidersRegex.Add('^[Mm]icrosoft\..+')
[void]$arrExcludedResourceProvidersRegex.Add('^[Mm]icrosoft.[Cc]lassic.+')

#endregion

#region main
If ($PSCmdlet.ParameterSetName -eq 'BySPConnection')
{
  $AzureConnection = Get-AutomationConnection -Name $AzureConnectionName
  $token = Get-AzureADToken -AzureServicePrincipalConnection $AzureConnection
  $SubscriptionId = $AzureConnection.SubscriptionId
} elseif ($PSCmdlet.ParameterSetName -eq 'ByCred')  {
  $token = Get-AzureADToken -TenantID $TenantID -Credential $Credential
} else {
  $token = Get-AzureADToken -TenantID $TenantID -UserName $UserName
}

$headers = @{ 'Authorization' = $Token }

$ResourceProviders = Get-AllResourceProviders -headers $headers -subscriptionId $SubscriptionId
$UnregisteredNamespaces = ($ResourceProviders | Where-object {$_.registrationState -ieq 'notregistered' -or $_.registrationState -ieq 'unregistered'}).Namespace
Foreach ($namespace in $UnregisteredNamespaces)
{
  $bShouldRegister = $false
  Foreach ($item in $arrIncludedResourceProvidersRegex)
  {
    If ($namespace -imatch $item)
    {
      $bShouldRegister = $true
      break
    }
  }
  Foreach ($item in $arrExcludedResourceProvidersRegex)
  {
    If ($namespace -imatch $item)
    {
      $bShouldRegister = $false
      break
    }
  }
  If ($bShouldRegister)
  {
    [void]$arrRegisterResourceProviders.Add($namespace)
  }
}
Foreach ($RP in $arrRegisterResourceProviders)
{
  Write-output "Registering resource provider '$RP'"
  $RegistrationResult = Register-ResourceProvider -headers $headers -subscriptionId $SubscriptionId -Namespace $RP
  If ($RegistrationResult -eq $false)
  {
    Write-Error "Failed to register '$RP'."
    break
  }
}

Write-output "Done."
#endregion
```

This script requires the following two PowerShell modules:

* AzureRM.Profile (<a title="https://www.powershellgallery.com/packages/AzureRM.profile" href="https://www.powershellgallery.com/packages/AzureRM.profile">https://www.powershellgallery.com/packages/AzureRM.profile</a>)
* AzureServicePrincipalAccount (<a title="https://www.powershellgallery.com/packages/AzureServicePrincipalAccount" href="https://www.powershellgallery.com/packages/AzureServicePrincipalAccount">https://www.powershellgallery.com/packages/AzureServicePrincipalAccount</a>)

**Syntax:**

1. Using a Key Based AzureServicePrincipal connection (in Azure Automation as a runbook, explained in my <a href="https://blog.tyang.org/2017/10/15/new-powershell-module-for-azure-automation-azureserviceprincipalaccount/">previous post</a>):

```powershell
Register-AzureResourceProviders.ps1 –AzureConnectionName 'AzureConnectionName'
```

{:start="2"}
2. Using a key-based (not certificate based) Service Principal or an Azure AD user account without Multi-Factor Authentication (MFA) (for key based service principals, use the AAD Application Id as the user name and the key as the password when creating the PSCredential object):

```powershell
Register-AzureResourceProviders.ps1 –TenantId 'MyAADTenantID' –SubscriptionId 'MyAzureSubscriptionId' –Credential $Credential
```

{:start="3"}
3. Using an AzureAD user account (with or without MFA, you will be prompted to enter the password and may be prompted for MFA if required) – this method only works when you are running this script interactively.

```powershell
Register-AzureResourceProviders.ps1 –TenantId 'MyAADTenantID' –SubscriptionId 'MyAzureSubscriptionId' –UserName 'my.name@mycompany.onmicrosoft.com'
```

>**Note:** For most of scripts I've written for Azure, I intentionally avoid using the official AzureRM PowerShell modules (well, this is a topic for another day), but instead, I'm using Azure Resource Manager REST API. The only reason this script requires the AzureRM.Profile module is because my AzureServicePrincipalAccount module requires a DLL from the AzureRM.Profile module in order to obtain the Azure AD oAuth token (for the REST API calls). You may modify the script to suit your requirements by adding / removing the inclusion and exclusion regular expressions (line 103-104).