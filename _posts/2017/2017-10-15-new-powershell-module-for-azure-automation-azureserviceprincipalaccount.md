---
id: 6252
title: 'New PowerShell Module For Azure Automation: AzureServicePrincipalAccount'
date: 2017-10-15T16:54:02+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=6252
permalink: /2017/10/15/new-powershell-module-for-azure-automation-azureserviceprincipalaccount/
categories:
  - Azure
  - PowerShell
tags:
  - Azure
  - Azure Automation
  - PowerShell
---
I’m currently working on a project where there has been a lot of discussion on how to use Azure AD Service Principals in Azure Automation and other solutions that involves any automated processes (i.e. VSTS pipelines).

When signing in to Azure using a Service Principal, you can use either a key (password) or a certificate associated to the Service Principal. When using the Add-AzureRMAccount cmdlet, you can use one of the following parameter set:

**Key (password) based:**
 * Azure AD Tenant ID
 * Azure Subscription Name or ID
 * **PS Credential object**
   * **User name: Azure AD Application ID**
   * **Password: Service Principal key**

**Certificate based:**
 * Azure AD Tenant ID
 * Azure Subscription Name or ID
 * **Certificate (installed in the computer’s cert store)**
 * **Certificate Thumbprint**

With Azure Automation, you have the option to create an Azure RunAs account via the Azure portal (**Note:** this option is only available from the Azure portal, not available in ARM APIs and templates)

<a href="https://blog.tyang.org/wp-content/uploads/2017/10/image.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/10/image_thumb.png" alt="image" width="687" height="445" border="0" /></a>

When you create an Azure Run As Account using this wizard, the following objects get created:

* Azure AD Application
* Certificate based Service Principal for this Azure AD App that has contributor role to the Azure subscription where the automation account is located
* An Azure Automation Certificate asset for the SP certificate
* An Azure Automation connection asset that stores the following information:
  * Tenant ID
  * Subscription ID
  * Azure AD Application ID
  * Certificate Thumbprint

To be honest, I am not a big fan of using such RunAs account because of the following constraints:

**1. There is no automated way to create it outside of Azure Portal.**

These RunAs account looks pretty easy to create via the portal, but you cannot create them using an automated fashion (i.e. via ARM templates)

**2. When creating it manually (via a PowerShell script), you’d normally create a self signed certificate, which requires local admin privilege.**

When you create a self-signed cert using New-SelfSignedCertificate cmdlet, you must execute this command under a local admin (i.e. start a PowerShell window under local administrator). A workaround is to use an Azure Key Vault, generate a self-signed cert from the key vault then export it out. But obviously, you will need to provision a key vault prior to this step.

**3. This RunAs account cannot be used in runbooks executed on Hybrid Workers**

This is probably the biggest drawback. Since Azure Automation does not automatically deploy the certificate assets to Hybrid Workers, you will have to take care of this and manually deploy certificates to Hybrid Worker computers. However, since you cannot export any certificates from Azure Automation account’s certificate store, and the certificate created for the RunAs account is not exposed to you, there is no way you can deploy this certificate to the Hybrid Worker computers, therefore you cannot use this RunAs account on Hybrid workers (unless you manually create every components yourself outside of the Azure Portal and install the certificate to the Hybrid Worker computers).

**4. The wizard only allows you to create one RunAs account for the subscription where the Automation account is located. You cannot create additional ones for other Azure subscriptions.**

If you have runbooks that need to talk to other Azure subscriptions or AAD tenant, then you will have to manually create each required components and store them in your automation account.

**5. A certificate installed on Hybrid Worker computer gives anyone who has access admin privilege to the computer ability to sign in to the Azure subscription**

If you have access to the certificate, then you can easily obtain the cert thumbprint, as long as you know the Azure AD tenant ID and subscription Id (or name), you can sign in to the Azure subscription. This can be a potential security risk because server admins and Azure subscription admins can be 2 different groups of people. Also, if your Hybrid Worker computer is compromised, your Azure AD and subscriptions are also at risk.

Based on these reasons, I have been advising customers to use keys instead of certificates. To simplify the provisioning process and make everyone’s life easier, I have created a very simple PowerShell module called AzureServicePrincipalAccount. You can find this module in PowerShell Gallery and GitHub:

PowerShell Gallery:  [https://www.powershellgallery.com/packages/AzureServicePrincipalAccount](https://www.powershellgallery.com/packages/AzureServicePrincipalAccount)

GitHub: [https://github.com/tyconsulting/AzureServicePrincipalAccount-PS](https://github.com/tyconsulting/AzureServicePrincipalAccount-PS)

By the default, the Azure AD Service Principal connection type provided by Azure Automation accounts only supports certificate-based Azure AD Service Principals. This module provides an additional connection type for key-based Service Principals:

<a href="https://blog.tyang.org/wp-content/uploads/2017/10/image-1.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/10/image_thumb-1.png" alt="image" width="368" height="582" border="0" /></a>

This module also provides a "proxy" function called **Add-AzureRMServicePrincipalAccount** to simplify the Sign-in process to Azure. This function allows you to pass either the built-in <strong>AzureServicePrincipal</strong> connection type or the <strong>Key Based AzureServicePrincipal</strong> type defined in this module, and it will determine the connection type automatically and sign in to Azure using the connection you have passed in. In another word, consider this as a universal sign-in function no matter if you are using the native certificate based SP connection, or a key based connection. Here’s a sample runbook:

```powershell
[CmdletBinding()]
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
```

Furthermore, you can also using this function without connection objects – by passing individual parameters for either the key or the certificate based Service Principals:

<a href="https://blog.tyang.org/wp-content/uploads/2017/10/image-2.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/10/image_thumb-2.png" alt="image" width="885" height="393" border="0" /></a>

Although by using a key-based Service Principal, you still need to manually create the AAD application and service principals, there is nothing you need to configure on the Hybrid Workers. There are already many PowerShell sample scripts on how to create an Azure AD Service Principal, just for your reference, [here’s one I’ve been using in the past](https://gist.github.com/tyconsulting/ec73a46113f53c2ad3b59ccaaa7502ce):

```powershell
#Requires -Version 5.0
#Requires -Modules AzureRM.Resources, AzureRM.Profile

<#
  ============================================================================
  AUTHOR:  Tao Yang 
  DATE:    09/10/2017
  Version: 1.0
  Comment: Create Azure AD Application and key phrase based Service Principal
  ============================================================================
#>
[CmdletBinding()]
Param (
  [Parameter(Mandatory = $true)][PSCredential]$AzureCredential,

  [Parameter(Mandatory = $true)]
  [ValidateScript({
    try {
      [System.Guid]::Parse($_) | Out-Null
      $true
    } catch {
      $false
    }
  })]
  [String]$SubscriptionId,

  [Parameter(Mandatory = $false)][ValidateNotNullOrEmpty()][String]$AADAppName = 'Automation_' + $([GUID]::NewGuid().Tostring()) -replace('-', ''),

  [Parameter(Mandatory = $false)][ValidateNotNullOrEmpty()][string]$Role = 'Contributor',
  [Parameter(Mandatory = $false)][int]$PasswordLength = 44
)

#region functions
Function New-Password
{
  param(
    [UInt32][ValidateScript({$_ -ge 8 -and $_ -le 128})] $Length=10,
    [Switch] $LowerCase=$TRUE,
    [Switch] $UpperCase=$FALSE,
    [Switch] $Numbers=$FALSE,
    [Switch] $Symbols=$FALSE
  )

  if (-not ($LowerCase -or $UpperCase -or $Numbers -or $Symbols)) {
    throw "You must specify one of: -LowerCase -UpperCase -Numbers -Symbols"
    return $null
  }
  # Specifies bitmap values for character sets selected.
  $CHARSET_LOWER = 1
  $CHARSET_UPPER = 2
  $CHARSET_NUMBER = 4
  $CHARSET_SYMBOL = 8

  # Creates character arrays for the different character classes,
  # based on ASCII character values.
  $charsLower = 97..122 | foreach-object { [Char] $_ }
  $charsUpper = 65..90 | foreach-object { [Char] $_ }
  $charsNumber = 48..57 | foreach-object { [Char] $_ }
  $charsSymbol = 35,36,42,43,44,45,46,47,58,59,61,63,64,
    91,92,93,95,123,125,126 | foreach-object { [Char] $_ }
  # Contains the array of characters to use.
  $charList = @()
  # Contains bitmap of the character sets selected.
  $charSets = 0
  if ($LowerCase) {
    $charList += $charsLower
    $charSets = $charSets -bor $CHARSET_LOWER
  }
  if ($UpperCase) {
    $charList += $charsUpper
    $charSets = $charSets -bor $CHARSET_UPPER
  }
  if ($Numbers) {
    $charList += $charsNumber
    $charSets = $charSets -bor $CHARSET_NUMBER
  }
  if ($Symbols) {
    $charList += $charsSymbol
    $charSets = $charSets -bor $CHARSET_SYMBOL
  }

  # Returns True if the string contains at least one character
  # from the array, or False otherwise.

    # Loops until the string contains at least
    # one character from each character class.
  do {
    # No character classes matched yet.
    $flags = 0
    $output = ""
    # Create output string containing random characters.
    1..$Length | foreach-object {
      $output += $charList[(get-random -maximum $charList.Length)]
    }
    # Check if character classes match.
    if ($LowerCase) {
      foreach ($char in $output.ToCharArray()) {If ($charsLower -contains $char) {$flags = $flags -bor $CHARSET_LOWER; break }}
    }
    if ($UpperCase) {
      foreach ($char in $output.ToCharArray()) {If ($charsUpper -contains $char) {$flags = $flags -bor $CHARSET_UPPER; break }}
    }
    if ($Numbers) {
      foreach ($char in $output.ToCharArray()) {If ($charsNumber -contains $char) {$flags = $flags -bor $CHARSET_NUMBER; break }}
    }
    if ($Symbols) {
      foreach ($char in $output.ToCharArray()) {If ($charsSymbol -contains $char) {$flags = $flags -bor $CHARSET_SYMBOL; break }}
    }
  }
  until ($flags -eq $charSets)
  # Output the string.
  $output
}
#endregion

#Login to Azure
$null = Add-AzureRmAccount -Credential $AzureCredential -SubscriptionId $SubscriptionId
$Context = Get-AzureRmContext
$CurrentAccount = $Context.Account.Id
$TenantDomainName = $Context.Tenant.Directory
$TenantId = $Context.Tenant.Id

#Validating role
Write-Output '', "Validating AAD role '$Role'..."
If (Get-AzureRMRoleDefinition $Role)
{
  Write-Output " - AAD role '$Role' validated."
} else {
  Write-Error "Azure AD role '$Role' not found. Unable to continue."
  Exit -1
}

#Create AAD App and service principal
$ApplicationPassword = New-Password -Length $PasswordLength -LowerCase -UpperCase -Numbers
Write-output '', 'Creating Azure AD application...'
Write-Output " - Azure AD Application name: '$AADAppName'"
$Application = New-AzureRmADApplication -DisplayName $AADAppName -HomePage ("http://$TenantDomainName/$AADAppName") -IdentifierUris ("http://$TenantDomainName/$AADAppName") -Password $ApplicationPassword
Write-Output '', 'Creating Azure AD Application Service Principal.'
$ApplicationServicePrincipal = New-AzureRmADServicePrincipal -ApplicationId $Application.ApplicationId

Write-output " - Assigning the '$Role' role to the application Service Principal. Please wait..."
$NewRole = $null
$Retries = 0
While ($NewRole -eq $null -and $Retries -le 5)
{
  # Sleep here for a few seconds to allow the service principal application to become active (should only take a couple of seconds normally)
  Start-Sleep -Seconds 10
  $RoleAssignment = New-AzureRmRoleAssignment -RoleDefinitionName $Role -ServicePrincipalName $Application.ApplicationId -ErrorAction SilentlyContinue
  Start-Sleep -Seconds 10
  $NewRole = Get-AzureRmRoleAssignment -ServicePrincipalName $Application.ApplicationId -ErrorAction SilentlyContinue
  $Retries++
}
Write-Output '', "The Azure AD Application and service principal is created:"
Write-Output " - Azure AD Tenant Domain: '$TenantDomainName'"
Write-Output " - Azure AD Tenant Id: '$TenantId'"
Write-Output " - Application name: '$AADAppName'"
Write-Output " - Application Id: '$($Application.ApplicationId)'"
Write-Output " - Application password: '$ApplicationPassword'"
Write-Output " - Azure Subscription Id: '$SubscriptionId'"
Write-Output " - Azure AD Role: '$Role'"

Write-Output '', "Done!"
```

If you are using a CI/CD tool such as VSTS, you can easily port this script to your pipeline and pass the Service Principal details to a ARM template that deploys the Module and connection object to an Automation account.