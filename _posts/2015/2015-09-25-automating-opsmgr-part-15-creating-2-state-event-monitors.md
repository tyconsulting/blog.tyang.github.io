---
id: 4650
title: 'Automating OpsMgr Part 15: Creating 2-State Event Monitors'
date: 2015-09-25T21:06:03+10:00
author: Tao Yang
#layout: post
excerpt: ""
header:
  overlay_image: /wp-content/uploads/2015/06/OpsMgrExnteded-banner.png
  overlay_filter: 0.5 # same as adding an opacity of 0.5 to a black background
guid: http://blog.tyang.org/?p=4650
permalink: /2015/09/25/automating-opsmgr-part-15-creating-2-state-event-monitors/
categories:
  - PowerShell
  - SCOM
  - SMA
tags:
  - Automating OpsMgr
  - PowerShell
  - SCOM
  - SMA
---

## Introduction

This is the 15th instalment of the Automating OpsMgr series. Previously on this series:

* [Automating OpsMgr Part 1: Introducing OpsMgrExtended PowerShell / SMA Module](http://blog.tyang.org/2015/06/24/automating-opsmgr-part-1-introducing-opsmgrextended-powershell-sma-module/)
* [Automating OpsMgr Part 2: SMA Runbook for Creating ConfigMgr Log Collection Rules](http://blog.tyang.org/2015/06/28/automating-opsmgr-part-2-sma-runbook-for-creating-configmgr-log-collection-rules/)
* [Automating OpsMgr Part 3: New Management Pack Runbook via SMA and Azure Automation](http://blog.tyang.org/2015/06/30/automating-opsmgr-part-3-new-management-pack-runbook-via-sma-and-azure-automation/)
* [Automating OpsMgr Part 4:Creating New Empty Groups](http://blog.tyang.org/2015/07/02/automating-opsmgr-part-4-create-new-empty-groups/)
* [Automating OpsMgr Part 5: Adding Computers to Computer Groups](http://blog.tyang.org/2015/07/06/automating-opsmgr-part-5-adding-computers-to-computer-groups/)
* [Automating OpsMgr Part 6: Adding Monitoring Objects to Instance Groups](http://blog.tyang.org/2015/07/13/automating-opsmgr-part-6-adding-monitoring-objects-to-instance-groups/)
* [Automating OpsMgr Part 7: Updated OpsMgrExtended Module](http://blog.tyang.org/2015/07/17/automating-opsmgr-part-7-updated-opsmgrextended-module/)
* [Automating OpsMgr Part 8: Adding Management Pack References](http://blog.tyang.org/2015/07/17/automating-opsmgr-part-8-adding-management-pack-references/)
* [Automating OpsMgr Part 9: Updating Group Discoveries](http://blog.tyang.org/2015/07/17/automating-opsmgr-part-9-updating-group-discoveries/)
* [Automating OpsMgr Part 10: Deleting Groups](http://blog.tyang.org/2015/07/27/automating-opsmgr-part-10-deleting-groups/)
* [Automating OpsMgr Part 11: Configuring Group Health Rollup](http://blog.tyang.org/2015/07/29/automating-opsmgr-part-11-configuring-group-health-rollup/)
* [Automating OpsMgr Part 12: Creating Performance Collection Rules](http://blog.tyang.org/2015/08/08/automating-opsmgr-part-12-creating-performance-collection-rules/)
* [Automating OpsMgr Part 13: Creating 2-State Performance Monitors](http://blog.tyang.org/2015/08/24/automating-opsmgr-part-13-creating-2-state-performance-monitors/)
* [Automating OpsMgr Part 14: Creating Event Collection Rules](http://blog.tyang.org/2015/08/31/automating-opsmgr-part-14-creating-event-collection-rules/)

It’s been almost a month since the last post on this series, partially because I was working on the OpsMgr Self Maintenance MP v2.5. Previously on Part 14, I have demonstrated how to create an event collection rule using the OpsMgrExtended module. Today, I’ll show you how to create a 2-State event monitor using the New-OM2StateEventMonitor function from the OpsMgrExtended module.

Like all other functions in this module, it has been fully documented, with few examples, which can be accessed using Get-Help cmdlet:

**Get-Help New-OM2StateEventMonitor –Full**

![](http://blog.tyang.org/wp-content/uploads/2015/09/SNAGHTMLb9099e1.png)

## Runbook: New-2StateEventMonitor

```powershell
Workflow New-2StateEventMonitor
{
  Param(
    [Parameter(Mandatory=$true)][String]$MonitorName,
    [Parameter(Mandatory=$true)][String]$MonitorDisplayName,
    [Parameter(Mandatory=$true)][String]$ClassName,
    [Parameter(Mandatory=$true)][String]$ParentMonitor,
    [Parameter(Mandatory=$true)][String]$EventLog,
    [Parameter(Mandatory=$true)][String]$Publisher,
    [Parameter(Mandatory=$true)][Int]$UnhealthyEventID,
    [Parameter(Mandatory=$true)][Int]$HealthyEventID,
    [Parameter(Mandatory=$true)][String]$UnhealthyState,
    [Parameter(Mandatory=$true)][Boolean]$MonitorDisabled
  )

  #Get OpsMgrSDK connection object
  $OpsMgrSDKConn = Get-AutomationConnection -Name "OpsMgrSDK_HOME"

  #Hard code which MP to use
  $MPName = "TYANG.Test.Windows.Monitoring"

  #Make sure MP exists
  Write-Verbose "Getting management pack '$MPName'"
  $MP = Get-OMManagementPack -SDKConnection $OpsMgrSDKConn -Name $MPName -ErrorAction SilentlyContinue
  If ($MP -eq $null)
  {
    #MP doesn't exist, create it
    Write-Verbose "management pack '$MPName' does not exist. creating now."
    $CreateMP = New-OMManagementPack -SDKConnection $OpsMgrSDKConn -Name $MPName -DisplayName "TYANG Test Windows Monitoring" -Version "1.0.0.0"
  }

  #Create Event Monitor, MP Version will be increased by 0.0.0.1
  $MonitorCreated = InlineScript
  {
    #Validate Monitor Name
    If ($USING:MonitorName -notmatch "([a-zA-Z0-9]+\.)+[a-zA-Z0-9]+")
    {
      #Invalid Monitor name entered
      $ErrMsg = "Invalid monitor name specified. Please make sure it only contains alphanumeric charaters and only use '.' to separate words. i.e. 'Your.Company.Event.1234.Monitor'."
      Write-Error $ErrMsg
    } else {
      #Name is valid, creating the monitor
      New-OM2StateEventMonitor -SDKConnection $USING:OpsMgrSDKConn -MPName $USING:MPName -MonitorName $USING:MonitorName -MonitorDisplayName $USING:MonitorDisplayName -ClassName $USING:ClassName -ParentMonitor $USING:ParentMonitor -EventLog $USING:EventLog -Publisher $USING:Publisher -UnhealthyEventID $USING:UnhealthyEventID -HealthyEventID $USING:HealthyEventID -UnhealthyState $USING:UnhealthyState -Disabled $USING:MonitorDisabled -IncreaseMPVersion $true
    }
  }
  If ($MonitorCreated)
  {
    Write-Output "Monitor `"$MonitorName`" created."
  } else {
    Write-Error "Unable to create monitor `"$Monitorname`"."
  }
}
```
I have hardcoded the following parameters in the runbook:

* SMA OpsMgr connection object name (which you will need to change to suit your environment)
* (Unsealed) MP (where the rule  is going to be saved to) – "TYANG.Test.Windows.Monitoring"

Additionally, this runbook will firstly try to retrieve the management pack from the management group, if the MP deosn’t exist, it will create it first.

This runbook takes the following input parameters:

* **ClassName** – The name of the target monitoring class (i.e.Microsoft.Windows.Server.OperatingSystem)
* **UnhealthyEventID** – The Event ID for the unhealthy event.
* **HealthyEventID** – The Event ID for the healthy event.
* **UnhealthyState** – The unhealthy state of the monitor (either warning or error).
* **EventLog** –The name of the event log (i.e. Application, System, etc)
* **Publisher** – The event publisher
* **MonitorDisabled** – Boolean, whether the event monitor should be disabled by default
* **MonitorDisplayName** – Display name of the unit monitor
* **MonitorName** – The name of the unit monitor
* **ParentMonitor** – The parent dependency monitor for the event unit monitor

Runbook Execution Result:

![](http://blog.tyang.org/wp-content/uploads/2015/09/image24.png)

Monitor Properties from the OpsMgr operations console:

General:

![](http://blog.tyang.org/wp-content/uploads/2015/09/image25.png)

Unhealthy Event:

![](http://blog.tyang.org/wp-content/uploads/2015/09/image26.png)

![](http://blog.tyang.org/wp-content/uploads/2015/09/image27.png)

Healthy Event:

![](http://blog.tyang.org/wp-content/uploads/2015/09/image28.png)

![](http://blog.tyang.org/wp-content/uploads/2015/09/image29.png)

Alert Setting:

![](http://blog.tyang.org/wp-content/uploads/2015/09/image30.png)

## Conclusion

In this post, I’ve demonstrated how to create a 2-state event monitor using the OpsMgrExtended module. now that I have covered both even collection rules and even monitors, I will dedicate the next 2 posts on monitoring Windows services.