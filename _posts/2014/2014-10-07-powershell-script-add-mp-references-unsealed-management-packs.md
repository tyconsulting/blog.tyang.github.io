---
id: 3235
title: PowerShell Script to Add MP References to Unsealed Management Packs
date: 2014-10-07T09:54:00+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=3235
permalink: /2014/10/07/powershell-script-add-mp-references-unsealed-management-packs/
categories:
  - PowerShell
  - SCOM
tags:
  - PowerShell
  - SCOM
---

## Background

Few months ago, I have written a <a href="http://blog.tyang.org/2014/06/24/powershell-script-remove-obsolete-references-unsealed-opsmgr-management-packs/">script</a> to remove obsolete MP references from unsealed management packs and have also built this into the OpsMgr Self Maintenance MP. Last week, I needed to write a script to do the opposite: creating obsolete MP references in unsealed MPs.

In the past, some of the MPs I have released had issues with creating overrides in the OpsMgr operational console. i.e. the OpsMgr 2012 Self Maintenance MP and the ConfigMgr 2012 Client MP. Both of them have one thing in common: the phrase "2012" is a part of the MP namespace, and if someone tries to create an override for these MPs in the operational console, he / she will get an "Alias atribute is invalid" error:

<a href="http://blog.tyang.org/wp-content/uploads/2014/10/image6.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/10/image_thumb6.png" alt="image" width="484" height="268" border="0" /></a>

When I was testing the latest release ConfigMgr 2012 Client MP (version 1.2.0.0) last week, I also got this error when assigning a RunAs account to the RunAs profile defined in the MP – because the assignment is basically a Secure Reference Override, and a MP reference to the ConfigMgr 2012 Client Library MP needs to be created in the Microsoft.SystemCenter.SecureReferenceOverride MP.

Although we can easily workaround this issue by exporting the unsealed MP, add the MP reference in by manually editing the XML, I thought I’ll write a PowerShell script to do this to make everyone’s life easier.

## Script

To make it a bit easier for the users, this PowerShell function <strong><span style="text-decoration: underline;">CAN ONLY</span></strong> be used on a OpsMgr management server.

```powershell
Function Add-MPRef
{
  <#
  .Synopsis
  Add a management pack reference to an unsealed management pack

  .Description
  Add a sealed MP reference to an unsealed management pack using OpsMgr SDK. This function CAN ONLY be used on a OpsMgr management server.

  .Parameter -ReferenceMPName
  Name of the referenced sealed management pack.

  .Parameter -Alias
  Reference Alias for the referenced sealed management pack.

  .Parameter -UnsealedMPName
  Name of the unsealed MP where the reference is going to be added to.

  .Example
  # Add a reference of sealed MP 'Microsoft.Windows.Server.2008.Monitoring' to the unsealed management pack YourCompany.Windows.Overrides:
  Referencing Sealed MP Name: "Microsoft.Windows.Server.2008.Monitoring"
  Alias: "Win2K8Mon"
  Unsealed destination Management Pack name: YourCompany.Windows.Overrides
  Add-MPRef -ReferenceMPName "Microsoft.Windows.Server.2008.Monitoring" -Alias "Win2K8Mon" -UnsealedMPName "YourCompany.Windows.Overrides"

  #>
  [CmdletBinding()]
  PARAM (
    [Parameter(Mandatory=$true,HelpMessage="Please enter referenced sealed MP name")][String]$ReferenceMPName,
    [Parameter(Mandatory=$true,HelpMessage="Please enter preferred alias for the referenced sealed MP")][String]$Alias,
    [Parameter(Mandatory=$true,HelpMessage="Please enter the destination unsealed MP name")][String]$UnsealedMPName
  )

  #Load OpsMgr 2012 SDK DLLs
  [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.EnterpriseManagement.OperationsManager.Common") | Out-Null
  [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.EnterpriseManagement.OperationsManager") | Out-Null

  #Connect to MG
  $SDK = $Env:COMPUTERNAME
  Write-Verbose "Connecting to Management Group via SDK $SDK`..."
  $MGConnSetting = New-Object Microsoft.EnterpriseManagement.ManagementGroupConnectionSettings($SDK)
  $MG = New-Object Microsoft.EnterpriseManagement.ManagementGroup($MGConnSetting)

  #Get the Reference MP
  Write-Verbose "Getting Reference MP $ReferenceMPName`..."
  $strMPquery = "Name = '$ReferenceMPName' AND Sealed = 'TRUE'"
  $mpCriteria = New-Object  Microsoft.EnterpriseManagement.Configuration.ManagementPackCriteria($strMPquery)
  $RefMP = $MG.GetManagementPacks($mpCriteria)[0]
  If (!$RefMP)
  {
    Write-Error "Unable to find the Reference Sealed MP with the name '$ReferenceMPName'."
    Exit
  } else {
    $Version = $RefMP.Version
    $KeyToken = $RefMP.KeyToken
    Write-Verbose "Reference MP Version: $Version"
    Write-Verbose "Reference MP Key Token: $KeyToken"
  }

  #Get the destination unsealed MP
  Write-Verbose "Getting Unsealed MP $UnsealedMPName`..."
  $strMPquery = "Name = '$UnsealedMPName' AND Sealed = 'FALSE'"
  $mpCriteria = New-Object  Microsoft.EnterpriseManagement.Configuration.ManagementPackCriteria($strMPquery)
  $DestMP = $MG.GetManagementPacks($mpCriteria)[0]
  If (!$DestMP)
  {
    Write-Error "Unable to find the unsealed MP with the name '$UnsealedMPName'."
  } else {
    Write-Verbose "Adding reference for $ReferenceMPName`..."
    $objMPRef = New-object Microsoft.EnterpriseManagement.Configuration.ManagementPackReference($DestMP, $ReferenceMPName, $KeyToken, $Version)
    $DestMP.References.Add($Alias, $objMPRef)

    #Verify and save the override
    Write-Verbose "Verifying $UnsealedMPName and save changes..."
    Try {
      $DestMP.verify()
      $DestMP.AcceptChanges()
      Write-Output $Result
    } Catch {
      $Result = "Unable to add MP Reference for $ReferenceMPName (Alias: $Alias; KeyToken: $KeyToken; Version: $Version) to $UnsealedMPName."
      Write-Error $Result
    }
  }
}
```

## Usage Example:

```powershell
Add-MPRef -ReferenceMPName "ConfigMgr.2012.Client.Library" -Alias "C2CL" -UnsealedMPName "Microsoft.SystemCenter.SecureReferenceOverride" –Verbose
```
## Conclusion

By using this script, we can pick the alias name that we prefer. Although this script is already included in the ConfigMgr 2012 Client MP package, I’d also like to share this script on this blog. For me, it’s a rare scenario that I had to do this, but I hope this can also help someone out there.