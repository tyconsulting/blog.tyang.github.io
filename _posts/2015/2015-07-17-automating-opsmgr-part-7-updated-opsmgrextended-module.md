---
id: 4225
title: 'Automating OpsMgr Part 7: Updated OpsMgrExtended Module'
date: 2015-07-17T15:11:31+10:00
author: Tao Yang
#layout: post
excerpt: ""
header:
  overlay_image: /wp-content/uploads/2015/06/OpsMgrExnteded-banner.png
  overlay_filter: 0.5 # same as adding an opacity of 0.5 to a black background
guid: http://blog.tyang.org/?p=4225
permalink: /2015/07/17/automating-opsmgr-part-7-updated-opsmgrextended-module/
categories:
  - PowerShell
  - SCOM
  - SMA
  - Uncategorized
tags:
  - Automating OpsMgr
  - PowerShell
  - SCOM
  - SMA
---

## Introduction

This is the 7th instalment of the Automating OpsMgr series. Previously on this series:

* [Automating OpsMgr Part 1: Introducing OpsMgrExtended PowerShell / SMA Module](http://blog.tyang.org/2015/06/24/automating-opsmgr-part-1-introducing-opsmgrextended-powershell-sma-module/)
* [Automating OpsMgr Part 2: SMA Runbook for Creating ConfigMgr Log Collection Rules](http://blog.tyang.org/2015/06/28/automating-opsmgr-part-2-sma-runbook-for-creating-configmgr-log-collection-rules/)
* [Automating OpsMgr Part 3: New Management Pack Runbook via SMA and Azure Automation](http://blog.tyang.org/2015/06/30/automating-opsmgr-part-3-new-management-pack-runbook-via-sma-and-azure-automation/)
* [Automating OpsMgr Part 4:Creating New Empty Groups](http://blog.tyang.org/2015/07/02/automating-opsmgr-part-4-create-new-empty-groups/)
* [Automating OpsMgr Part 5: Adding Computers to Computer Groups](http://blog.tyang.org/2015/07/06/automating-opsmgr-part-5-adding-computers-to-computer-groups/)
* [Automating OpsMgr Part 6: Adding Monitoring Objects to Instance Groups](http://blog.tyang.org/2015/07/13/automating-opsmgr-part-6-adding-monitoring-objects-to-instance-groups/)

I dedicated part 4-6 on creating and managing groups using the OpsMgrExtended module. I was going to continue on this topic and demonstrate how to update group discovery in part 7 (this post), but unfortunately there is a change of plan. While I was preparing for the group discovery update runbook, I noticed I had to firstly cover how to add reference MPs before I can talk about updating group discoveries. I then realised there was a small bug in the New-OMManagementPackReference. Therefore, I have decided to update the OpsMgrExtended module first, before continuing the topics of managing groups.

## What's New?

In this release (version 1.1), I have made the following updates:

* Bug fix: **New-OMTCPPortMonitoring** fails when not using the the SMA connection object.
* Bug fix: **New-OMManagementPackReference** returned incorrect result when the alias is already used
* Additional Function / Activity: **New-OMComputerGroupExplicitMember**
* Additional Function / Activity: **New-OMInstanceGroupExplicitMember**
* Additional Function / Activity: **Update-OMGroupDiscovery**

In Part 5 and 6, I demonstrated 2 runbooks to add explicit members to computer groups and instance groups. As I mentioned in those posts, I would make those 2 runbooks as native functions within the module, hence the new functions New-OMComputerGroupExplicitMember and OMInstanceGroupExplicitMember. So instead of using the long and complicated runbooks from Part 5 and 6, with this updated version, you can now use very simple runbooks as shown below:
  
### Runbook: Add-ComputerToComputerGroup

```powershell
Workflow Add-ComputerToComputerGroup
{
  Param(
    [Parameter(Mandatory=$true)][String]$GroupName,
    [Parameter(Mandatory=$true)][String]$ComputerPrincipalName,
    [Parameter(Mandatory=$true)][Boolean]$IncreaseMPVersion
  )

  #Get OpsMgrSDK connection object
  $OpsMgrSDKConn = Get-AutomationConnection -Name "OpsMgrSDK_TYANG"
  $bComputerAdded =New-OMComputerGroupExplicitMember -SDKConnection $OpsMgrSDKConn -GroupName $GroupName -ComputerPrincipalName $ComputerPrincipalName -IncreaseMPVersion $IncreaseMPVersion
  If ($bComputerAdded -eq $true)
  {
    Write-Output "Done."
  } else {
    throw "Unable to add '$ComputerPrincipalName' to group '$GroupName'."
    exit
  }
}
```
  
### Runbook: Add-ObjectToInstanceGroup  

```powershell
Workflow Add-ObjectToInstanceGroup
{
  Param(
    [Parameter(Mandatory=$true)][String]$GroupName,
    [Parameter(Mandatory=$true)][String]$MonitoringObjectID,
    [Parameter(Mandatory=$true)][Boolean]$IncreaseMPVersion
  )

  #Get OpsMgrSDK connection object
  $OpsMgrSDKConn = Get-AutomationConnection -Name "OpsMgrSDK_TYANG"
  $bInstanceAdded = New-OMInstanceGroupExplicitMember -SDKConnection $OpsMgrSDKConn -MonitoringObjectID $MonitoringObjectID -GroupName $GroupName -IncreaseMPVersion $IncreaseMPVersion
  If ($bInstanceAdded -eq $true)
  {
    Write-Output "Done."
  } else {
    throw "Unable to add monitoring object '$MonitoringObjectID' to group '$GroupName'."
    exit
  }
}
```

## How to Download Updated version?

I have updated the original link, so you can download this updated version at TY Consulting's web site: <a title="http://www.tyconsulting.com.au/portfolio/opsmgrextended-powershell-and-sma-module/" href="http://www.tyconsulting.com.au/portfolio/opsmgrextended-powershell-and-sma-module/">http://www.tyconsulting.com.au/portfolio/opsmgrextended-powershell-and-sma-module/</a>

## Conclusion

With the updated module in place, I will continue my discussion on managing groups. In the next part of this series, I will demonstrate how to add a management pack reference to an unsealed management pack.