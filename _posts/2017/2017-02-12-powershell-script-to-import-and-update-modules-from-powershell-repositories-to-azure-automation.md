---
id: 5878
title: PowerShell Script to Import and Update Modules from PowerShell Repositories to Azure Automation
date: 2017-02-12T20:46:42+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=5878
permalink: /2017/02/12/powershell-script-to-import-and-update-modules-from-powershell-repositories-to-azure-automation/
categories:
  - Azure
  - OMS
  - PowerShell
tags:
  - Azure
  - Azure Automation
  - OMS
  - PowerShell
---
PowerShell Gallery has a very cool feature that allows you to import modules directly to your Azure Automation Account using the "Deploy to Azure Automation" button. However, if you want to automate the module deployment process, you most likely have to firstly download the module, zip it up and then upload to a place where the Azure Automation account can access via HTTP. This is very troublesome process.

I have written a PowerShell script that allows you to search PowerShell modules from ANY PowerShell Repositories that has been registered on your computer and deploy the module DIRECTLY to the Azure Automation account without having to download it first. You can use this script to import new modules or updating existing modules to your Automation account.

This script is designed to run interactively. You will be prompted to enter details such as module name, version, Azure credential, selecting Azure subscription and Azure Automation account etc.

<a href="https://blog.tyang.org/wp-content/uploads/2017/02/ImportModuleScript.png"><img class="size-large wp-image-5882 alignnone" src="https://blog.tyang.org/wp-content/uploads/2017/02/ImportModuleScript-1024x342.png" alt="" width="775" height="259" /></a>

The script works out the URI to the actual NuGet package for the module and import it directly to Azure Automation account. As you can see from above screenshot, Other than the PowerShell Gallery, I have also registered a private repository hosted on MyGet.org, and I am able to deploy modules directly from my private MyGet feed to my Azure Automation account.

If you want to automate this process, you can easily make a non-interactive version of this script and parameterize all required inputs.

So, here’s the [script](https://gist.github.com/tyconsulting/f8ff2642e6be9ee770a770f2eafb06a4), and feedback is welcome:

```powershell
#Requires -Modules AzureRM.Automation, AzureRM.Profile, PowerShellGet
#Requires -version 5.0
<#
=============================================================================================
AUTHOR:  Tao Yang 
DATE:    12/02/2017
Version: 1.0
Comment: deploy / update PowerShell modules from a PS Repository to Azure Automation Account
=============================================================================================
#>
Do 
{
  $ModuleName = Read-Host -Prompt 'Enter the PowerShell module name'
}
while ($ModuleName.Length -eq 0)

$ModuleVersion = Read-Host -Prompt 'Enter the required module version (Or hit enter to use the latest version from the repository)'

#Select PowerSHell repository
$PSRepositories = Get-PSRepository
if ($PSRepositories.count -gt 0)
{
  Write-Output -InputObject 'Select the PowerShell repository where you wan to search the module from:'
  $menu = @{}
  $PSRepositorySourceLocations = @{}
  for ($i = 1;$i -le $PSRepositories.count; $i++) 
  {
    Write-Host -Object "$i. $($PSRepositories[$i-1].Name)"
    $menu.Add($i,($PSRepositories[$i-1].Name))
    $PSRepositorySourceLocations.Add($i,($PSRepositories[$i-1].SourceLocation))
  }
  Do 
  {
    [int]$ans = Read-Host -Prompt "Enter selection (1 - $($i -1))"
  }
  while ($ans -le 0 -or $ans -gt $($i -1))

  $PSRepositoryName = $menu.Item($ans)
  $PSRepositorySourceLocation = $PSRepositorySourceLocations.Item($ans)
  if ($PSRepositorySourceLocation.Substring($PSRepositorySourceLocation.length -1, 1) -ne '/')
  {
    $PSRepositorySourceLocation = "$PSRepositorySourceLocation`/"
  }
}
#Login to Azure
Write-Output -InputObject 'Login to Azure.'
Disable-AzureRmDataCollection -WarningAction SilentlyContinue
$null = Add-AzureRmAccount

#Select Azure subscription
$subscriptions = Get-AzureRmSubscription -WarningAction SilentlyContinue
if ($subscriptions.count -gt 0)
{
  Write-Output -InputObject 'Select Azure Subscription of which the Automation Account is located'

  $menu = @{}
  for ($i = 1;$i -le $subscriptions.count; $i++) 
  {
    Write-Host -Object "$i. $($subscriptions[$i-1].SubscriptionName)"
    $menu.Add($i,($subscriptions[$i-1].SubscriptionId))
  }
  Do 
  {
    [int]$ans = Read-Host -Prompt "Enter selection (1 - $($i -1))"
  }
  while ($ans -le 0 -or $ans -gt $($i -1))

  $subscriptionID = $menu.Item($ans)
  $null = Set-AzureRmContext -SubscriptionId $subscriptionID
}
else 
{
  Write-Error -Message 'No Azure Subscription found. Unable to continue!'
  Exit -1
}

#Select Azure Automation account
$AAAccounts = Get-AzureRmAutomationAccount
if ($AAAccounts.count -gt 0)
{
  Write-Output -InputObject 'Select the Azure Automation account:'
  $menu = @{}
  $AAResourceGroups = @{}
  for ($i = 1;$i -le $AAAccounts.count; $i++) 
  {
    Write-Host -Object "$i. $($AAAccounts[$i-1].AutomationAccountName)"
    $menu.Add($i,($AAAccounts[$i-1].AutomationAccountName))
    $AAResourceGroups.Add($i,($AAAccounts[$i-1].ResourcegroupName))
  }
  Do 
  {
    [int]$ans = Read-Host -Prompt "Enter selection (1 - $($i -1))"
  }
  while ($ans -le 0 -or $ans -gt $($i -1))

  $AzureAutomationAccountName = $menu.Item($ans)
  $AAAccountResourceGroup = $AAResourceGroups.Item($ans)
}
else 
{
  Write-Error -Message 'No Azure Automation account found the selected Azure subscription. Unable to continue.'
  Exit -1
}

$bImported = $false
If ($ModuleVersion.length -ne 0)
{
  Write-Output -InputObject "Searching for version '$ModuleVersion' of module '$ModuleName' in the repository '$PSRepositoryName'."
  $ModuleSearchResult = Find-Module -Name $ModuleName -RequiredVersion $ModuleVersion -Repository $PSRepositoryName -ErrorAction SilentlyContinue
}
else 
{
  Write-Output -InputObject "Searching for the latest version of module '$ModuleName' in the repository '$PSRepositoryName'."
  $ModuleSearchResult = Find-Module -Name $ModuleName -Repository $PSRepositoryName -ErrorAction SilentlyContinue
}

If ($ModuleSearchResult)
{
  $verModuleVersionFromSeachResult = $ModuleSearchResult.Version
  $ModuleVersionFromSearchResult = $verModuleVersionFromSeachResult.tostring()
  $ModuleNameFromSearchResult = $ModuleSearchResult.Name
  $NugetPackageURI = $PSRepositorySourceLocation + "package/$ModuleNameFromSearchResult/$ModuleVersionFromSearchResult/"
  Write-Output -InputObject "Module source URI: '$NugetPackageURI'" 

  #Check Azure Automation acocunt for existing module
  $ExistingAAModule = Get-AzureRmAutomationModule -Name $ModuleNameFromSearchResult -ResourceGroupName $AAAccountResourceGroup -AutomationAccountName $AzureAutomationAccountName -ErrorAction SilentlyContinue
  If ($ExistingAAModule -ne $null)
  {
    Write-Output -InputObject "Module '$ModuleNameFromSearchResult' is already imported in the Azure Automation account. the current module version is '$($ExistingAAModule.Version)'."
    $verExistingModuleVersion = [version]::Parse($($ExistingAAModule.Version))
    if ($verModuleVersionFromSeachResult -gt $verExistingModuleVersion)
    {
      Write-Output -InputObject "The module version located in PowerShell Gallery is '$ModuleVersionFromSearchResult', which is greater than the existing version in the Automation Account. Updating now."
      $ImportJob = New-AzureRmAutomationModule -Name $ModuleNameFromSearchResult -ContentLink $NugetPackageURI -AutomationAccountName $AzureAutomationAccountName -ResourceGroupName $AAAccountResourceGroup
      $bImported = $true
    }
    elseif ($verModuleVersionFromSeachResult -eq $verExistingModuleVersion) 
    {
      Write-Output -InputObject "The version in the PowerShell Gallery is '$ModuleVersionFromSearchResult', which is the same as the existing version in the Automation Account. Update is not required."
    }
    else 
    {
      Write-Output -InputObject "The version in the PowerShell Gallery is '$ModuleVersionFromSearchResult', which is the lower the existing version in the Automation Account. Update is not required."
    }
  }
  else 
  {
    Write-Output -InputObject "Importing module '$ModuleNameFromSearchResult' version '$ModuleVersionFromSearchResult' to Automation Account '$AzureAutomationAccountName' now."
    $ImportJob = New-AzureRmAutomationModule -Name $ModuleNameFromSearchResult -ContentLink $NugetPackageURI -AutomationAccountName $AzureAutomationAccountName -ResourceGroupName $AAAccountResourceGroup
    $bImported = $true
  }
}
else 
{
  Write-Error -Message "Module '$ModuleName' not found in repository '$PSRepositoryName'."
}

#Check import progress
If ($bImported -eq $true)
{
  Write-Output -InputObject 'Extracting module activities. Please wait.'
  $bImportCompleted = $false
  Do 
  {
    Start-Sleep -Seconds 5
    $AAModule = Get-AzureRmAutomationModule -Name $ModuleNameFromSearchResult -ResourceGroupName $AAAccountResourceGroup -AutomationAccountName $AzureAutomationAccountName
    If ($AAModule.ProvisioningState -eq 'Succeeded')
    {
      Write-Output -InputObject 'Module import completed.'
      $bImportCompleted = $true
    }
    elseif ($AAModule.ProvisioningState -eq 'Failed') 
    {
      Write-Error -Message 'Module import failed. Please manually check the error details in the Azure Portal.'
      $bImportCompleted = $true
    }
  }
  Until ($bImportCompleted -eq $true)
}

Write-Output -InputObject 'Done!'
```