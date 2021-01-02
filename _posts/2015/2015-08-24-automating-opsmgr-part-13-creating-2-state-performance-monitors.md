---
id: 4431
title: 'Automating OpsMgr Part 13: Creating 2-State Performance Monitors'
date: 2015-08-24T21:56:23+10:00
author: Tao Yang
#layout: post
excerpt: ""
header:
  overlay_image: /wp-content/uploads/2015/06/OpsMgrExnteded-banner.png
  overlay_filter: 0.5 # same as adding an opacity of 0.5 to a black background
guid: http://blog.tyang.org/?p=4431
permalink: /2015/08/24/automating-opsmgr-part-13-creating-2-state-performance-monitors/
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

This is the 13th instalment of the Automating OpsMgr series. Previously on this series:

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

In the previous post (Part 12), I have demonstrated how to create performance collection rules using the **OpsMgrExtended** module. In this post, I will demonstrate how to create a 2-State performance monitor.

OpsMgrExtended module provides a function called **New-OM2StatePerformanceMonitor**. It has been documented in the embedded help within the module. you can access it via the Get-Help cmdlet:

<a href="http://blog.tyang.org/wp-content/uploads/2015/08/image31.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/08/image_thumb31.png" alt="image" width="670" height="212" border="0" /></a>

Same as the previous posts, I’m going to show a sample runbook which utilise this function.

## Runbook New-2StatePerformanceMonitor

```powershell
Workflow New-2StatePerformanceMonitor
{
  Param(
    [Parameter(Mandatory=$true)][String]$MonitorName,
    [Parameter(Mandatory=$true)][String]$MonitorDisplayName,
    [Parameter(Mandatory=$true)][String]$CounterName,
    [Parameter(Mandatory=$true)][String]$ObjectName,
    [Parameter(Mandatory=$false)][String]$InstanceName,
    [Parameter(Mandatory=$true)][String]$ClassName,
    [Parameter(Mandatory=$true)][String]$Threshold,
    [Parameter(Mandatory=$true)][String]$UnhealthyState,
    [Parameter(Mandatory=$true)][Boolean]$UnhealthyWhenUnder
  )

  #Get OpsMgrSDK connection object
  $OpsMgrSDKConn = Get-AutomationConnection -Name "OpsMgrSDK_HOME"

  #Hard code which MP to use
  $MPName = "TYANG.SMA.Automation.Perf.Monitor.Demo"

  #Hard code frequency (900 seconds)
  $Frequency = 900

  #Create Performance Monitor, MP Version will be increased by 0.0.0.1
  $MonitorCreated = InlineScript
  {
    #Validate Monitor Name
    If ($USING:MonitorName -notmatch "([a-zA-Z0-9]+\.)+[a-zA-Z0-9]+")
    {
      #Invalid Monitor name entered
      $ErrMsg = "Invalid monitor name specified. Please make sure it only contains alphanumeric charaters and only use '.' to separate words. i.e. 'Your.Company.Windows.Free.Memory.Percentage.Monitor'."
      Write-Error $ErrMsg
    } else {
      #Name is valid, creating the monitor
      New-OM2StatePerformanceMonitor -SDKConnection $USING:OpsMgrSDKConn -MPName $USING:MPName -MonitorName $USING:MonitorName -MonitorDisplayName $USING:MonitorDisplayName -ClassName $USING:ClassName -CounterName $USING:CounterName -ObjectName $USING:ObjectName -InstanceName $USING:InstanceName -Threshold $USING:Threshold -UnhealthyWhenUnder $USING:UnhealthyWhenUnder -Frequency $USING:Frequency -UnhealthyState $USING:UnhealthyState -IncreaseMPVersion $true
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

As you can see, I have hardcoded the following parameters in the runbook:

  * Frequency – 900 seconds
  * (Unsealed) MP (where the monitor is going to be saved to) - "TYANG.SMA.Automation.Perf.Monitor.Demo"
  * Increase MP Version – true

So, before I can kick off this runbook, I need to firstly create the MP. This can be easily done using a one-liner on a machine where OpsMgrExtended is loaded:

```powershell
New-OMManagementPack -SDK OMMS01 -Name "TYANG.SMA.Automation.Perf.Monitor.Demo" -DisplayName "TYANG SMA Automation Perf Monitor Demo" –Verbose

```
<a href="http://blog.tyang.org/wp-content/uploads/2015/08/image32.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/08/image_thumb32.png" alt="image" width="613" height="192" border="0" /></a>

After the test MP is created, I can then execute the runbook. This runbook takes the following input parameters:

  * **ClassName** – The name of the target monitoring class (i.e.Microsoft.Windows.Server.OperatingSystem)
  * **CounterName** – Name of the perf counter
  * **InstanceName** (Optional) –The Name of the instance of the counter. if not specified, the monitor will use All Instances.
  * **MonitorDisplayName** – The Display Name of the monitor.
  * **MonitorName** – The name of the monitor
  * **ObjectName** - Name of the object where the counter belongs to (i.e. memory, logical disk, etc.)
  * **Threshold** – The numeric threshold used by the monitor
  * **UnhealthState** – The unhealthy state of the monitor (Error or Warning)
  * **UnhealthyWhenUnder** (Boolean) – Specify if the monitor is unhealthy when the perf counter is under the threshold (or over the threshold).

Runbook Execution Result:

<a href="http://blog.tyang.org/wp-content/uploads/2015/08/image33.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/08/image_thumb33.png" alt="image" width="643" height="655" border="0" /></a>

Monitor created by the runbook:

<a href="http://blog.tyang.org/wp-content/uploads/2015/08/image34.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/08/image_thumb34.png" alt="image" width="364" height="376" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2015/08/image35.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/08/image_thumb35.png" alt="image" width="366" height="378" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2015/08/image36.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/08/image_thumb36.png" alt="image" width="367" height="380" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2015/08/image37.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/08/image_thumb37.png" alt="image" width="368" height="380" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2015/08/image38.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/08/image_thumb38.png" alt="image" width="368" height="380" border="0" /></a>

## Conclusion

In this post, I have demonstrated a SMA / Azure Automation runbook to create 2-state performance monitors in OpsMgr. Now that I have covered both aspect of the performance  data (perf collection rule and monitor), I will move on to the event data in the next post.