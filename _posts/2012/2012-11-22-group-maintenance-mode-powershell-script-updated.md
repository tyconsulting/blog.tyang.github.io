---
id: 1652
title: Group Maintenance Mode PowerShell Script Updated
date: 2012-11-22T13:41:47+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=1652
permalink: /2012/11/22/group-maintenance-mode-powershell-script-updated/
categories:
  - PowerShell
  - SCOM
tags:
  - SCOM
---
<em><span style="color: #ff0000;"><strong>Update</strong></span> - 07, Dec, 2012: the script in this post has been updated to address 2 bugs explained here: <a href="https://blog.tyang.org/2012/12/07/bug-fixes-for-the-group-maintenance-mode-script/">Bug Fixes for the Group Maintenance Mode Script</a></em>

Steve Rachui has posted a wonderful PowerShell script to place a group into maintenance mode in SCOM: <a href="http://blogs.msdn.com/b/steverac/archive/2010/08/09/place-a-group-in-maintenance-mode-with-powershell.aspx">Place a Group in Maintenance Mode with PowerShell</a> back in 2010.

I’ve updated the script today to use SDK rather than SCOM 2007 PS Snap-in so the script works on both SCOM 2007 and OM12.

I’ve also made few other changes including change the duration from number of hours to number of minutes to suit my needs.

Here’s the script:

```powershell
#===========================================================================================
# AUTHOR: Tao Yang
# Script Name: GroupMaintenanceMode.ps1
# DATE: 20/11/2012
# Version: 1.1
# COMMENT: - Script to place a group into maintenance mode (at once) using SDK
# - Update History:
# 1.1 - Bug fix when the group is already in maint. mode condition
# - Added Recursive switch when creating maint. mode to ensure
# group members are also placed into maint. mode.
#===========================================================================================
Param (
  [Parameter(Mandatory=$true)]
  [string]$RMS,
  [Parameter(Mandatory=$true)]
  [string]$GroupName,
  [Parameter(Mandatory=$true)]
  [int]$DurationInMinutes,
  [Parameter(Mandatory=$true)]
  [string]$Comments
)

#Region FunctionLibs
function Load-SDK()
{
 [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.EnterpriseManagement.OperationsManager.Common") | Out-Null
 [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.EnterpriseManagement.OperationsManager") | Out-Null
}
#EndRegion

#Firstly validate input
#duration has to be between 5 minutes and 2 years
IF ($DurationInMinutes -lt 5 -or $DurationInMinutes -gt 1051200)
{
 Write-Host "Invalid Duration entered. the duration has to be between 5 minutes and 2 years!"
 $host.setShouldExit(1)
}

#Connection to management group
Load-SDK
$MGConnSetting = New-Object Microsoft.EnterpriseManagement.ManagementGroupConnectionSettings($RMS)
$MG = New-Object Microsoft.EnterpriseManagement.ManagementGroup($MGConnSetting)
$query = "DisplayName= '$GroupName'"
$MonitoringClassCriteria = New-Object Microsoft.EnterpriseManagement.Configuration.MonitoringClassCriteria($query)
$GroupMonitoringClasses = $MG.GetMonitoringClasses($MonitoringClassCriteria)

If ($GroupMOnitoringClasses)
{
  Foreach ($Group in $GroupMonitoringClasses)
  {
    $StartTime = ([DateTime]::Now).ToUniversalTime()
    $EndTime = $StartTime.AddMinutes($DurationInMinutes)
    $MonitoringGUID = $Group.Id
    $MonitoringObject = $MG.GetMonitoringObject($MonitoringGUID)
    Write-Host "Monitoring Object GUID: $MonitoringGUID"
    Write-Host "Monitoring Object DisplayName: $($MonitoringObject.DisplayName)"
    If (!$MonitoringObject.InMaintenanceMode)
    {
      $Reason = "PlannedOther"
      Write-Host "Placing $($MonitoringObject.Displayname) into Maintenance Mode..." -ForegroundColor Green
      $MonitoringObject.ScheduleMaintenanceMode($StartTime, $EndTime, $Reason, $Comments, "Recursive")
    } else {
      $CurrentMaintWindow = $MonitoringObject.GetMaintenanceWindow()
      $CurrentEndTime = $CurrentMaintWindow.ScheduledEndTime
      $CurrentReason = $CurrentMaintWindow.Reason
      $CurrentComments = $CurrentMaintWindow.Comments
      If ($CurrentEndTime -lt $EndTime)
      {
        Write-Host "Updating existing maintenance mode for $($MonitoringObject.DisplayName)`..." -ForegroundColor Yellow
        $MonitoringObject.UpdateMaintenanceMode($EndTime, $CurrentReason, $CurrentComments)
      } else {
        Write-Host "The end time of the existing Maintenance mode on $($MonitoringObject.DisplayName) is later than specified end time. The existing maintenance mode will not be updated`!" -ForegroundColor Yellow
      }
    }
  }
} else {
  Write-Host "Unable to find the monitoring object with the name `"$GroupName`"!" -ForegroundColor Red
}
```

Or download the script <a href="https://blog.tyang.org/wp-content/uploads/2012/12/GroupMaintenanceMode.zip">HERE</a>.