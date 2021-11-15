---
id: 5346
title: New PowerShell Module HybridWorkerToolkit
date: 2016-04-20T20:39:07+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=5346
permalink: /2016/04/20/new-powershell-module-hybridworkertoolkit/
categories:
  - Azure
  - OMS
  - PowerShell
tags:
  - Azure Automation
  - OMS
  - PowerShell
---
**<a href="https://blog.tyang.org/wp-content/uploads/2016/04/HybridWorkerToolkit.png"><img style="background-image: none; float: left; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px none;" title="HybridWorkerToolkit" src="https://blog.tyang.org/wp-content/uploads/2016/04/HybridWorkerToolkit_thumb.png" alt="HybridWorkerToolkit" width="172" height="171" align="left" border="0" /></a><span style="color: #ff0000;">23/04/2016 Update:</span>** released version 1.0.3 to GitHub and PowerShell gallery. New additions documented in <a href="https://blog.tyang.org/2016/04/23/hybridworkertoolkit-powershell-module-updated-to-version-1-0-3/">this blog post</a>.

<span style="color: #ff0000;">**21/04/2016 Update:**</span> updated GitHub and PowerShell gallery and released version 1.0.2 with minor bug fix and updated help file.

## Introduction

Over the last few days, I have been working on a PowerShell module for Azure Automation Hybrid Workers. I named this module **HybridWorkerToolkit**.

This module is designed to run within either a PowerShell runbook or a PowerShell workflow runbook on Azure Automation Hybrid Workers. It provides few functions that can be called within the runbook. These activities can assist gathering information about Hybrid Workers and the runbook runtime environment. It also provides a function to log **<u>structured</u>** events to the Hybrid Workers Windows Event Logs.

My good friend and fellow MVP Pete Zerger <a href="http://insidethecloudos.azurewebsites.net/centralized-logging-strategy-for-azure-automation-hybrid-worker-with-oms/">posted</a> a method he developed to use Windows event logs and OMS as a centralised logging solution for Azure Automation runbooks when executed on Hybrid Workers. Pete was using the PowerShell cmdlet Write-EventLog to log runbook related activities to Windows event log and then these events will be picked up by OMS. Log Analytics. This is a very innovative way of using Windows event logs and OMS. However, the event log entries written by Write-EventLog are not structured are lacking basic information about your environment and the job runtime.  Couple of weeks ago, another friend of mine, Mr. Kevin Holman from Microsoft also published a <a href="https://blogs.technet.microsoft.com/kevinholman/2016/04/02/writing-events-with-parameters-using-powershell/">PS script</a> that he used to write to Windows event logs with additional parameters.

So I combined Pete’s idea with Kevin’s script, as well as some code I’ve written in the past for Hybrid Workers, and developed this module.

Why do we want to use Windows Event logs combined with OMS for logging runbook activities on Hybrid workers? As Pete explained on this post, it provides a centralised solution where you can query and retrieve these activity logs for all your runbooks from a single location. Additionally, based on my experience (and also confirmed with few other friends), is that when you use Write-Verbose or Write-Output in your runbook and enabled verbose logging, the runbook execution time can increase significantly, especially when loading a module with a lot of activities. Based on my own experience, I’ve seen a runbook that would normally takes a minute or two to run with verbose logging turned off ended up ran over half an hour after I enabled verbose logging. This is another reason I’ve developed this module so it gives you an alternative option to log verbose, error, process and output messages.

## Functions

This module provides the following 3 functions:

 * Get-HybridWorkerConfiguration
 * Get-HybridWorkerJobRuntimeInfo
 * New-HybridWorkerRunbookLogEntry

**<span style="color: #ff0000;">Note:</span>** Although the job runtime are different between PowerShell runbooks and PowerShell Workflow runbooks, I have spent a lot of time together with Pete making sure we can use these activities exactly the same ways between PowerShell and PowerShell workflow runbooks.

### Get-HybridWorkerConfiguration

This function can be used to get the Hybrid Worker and Microsoft Monitoring Agent configuration. A hash table is returned the following configuration properties retrieved from Hybrid Worker and MMA agent:

 * Hybrid Worker Group name
 * Automation Account Id
 * Machine Id
 * Computer Name
 * MMA install root
 * PowerShell version
 * Hybrid Worker version
 * System-wide Proxy server address
 * MMA version
 * MMA Proxy URL
 * MMA Proxy user name
 * MMA connected OMS workspace Id


### Get-HybridWorkerJobRuntimeInfo

This function retrieves the following information about the Azure Automation runbook and the job run time. They are returned in a hashtable:

 * Runbook job ID
 * Sandbox Id
 * Process Id
 * Automation Asset End Point
 * PSModulePath environment variable
 * Current User name
 * Log Activity Trace
 * Current Working Directory
 * Runbook type
 * Runbook name
 * Azure Automation account name
 * Azure Resource Group name
 * Azure subscription Id
 * Time taken to start runbook in seconds


### New-HybridWorkerRunbookLogEntry

This function can be used to log event log entries. By default, other than the event message itself, the following information is also logged as part of the event (placed under the <EventData> XML tag:

 * Azure Automation Account Name
 * Hybrid Worker Group Name
 * Azure Automation Account Resource Group Name
 * Azure Subscription Id
 * Azure Automation Job Id
 * Sandbox Id
 * Process Id
 * Current Working Directory ($PWD)
 * Runbook Type
 * Runbook Name
 * Time Taken To Start Running in Seconds

This function also has an optional Boolean parameter called ‘-LogHybridWorkerConfig’ When this parameter is set to $true, the event created by this function will also contain the following information about the Hybrid Worker and MMA:

 * Hybrid Worker Version
 * Microsoft Monitoring Agent Version
 * Microsoft Monitoring Agent Install Path
 * Microsoft Monitoring Agent Proxy URL
 * Hybrid Worker server System-wide Proxy server address
 * Microsoft OMS Workspace ID


## Sample Runbooks

**Sample PowerShell Runbook:**

```powershell
Get-HybridWorkerConfiguration  | out-file C:\temp\HybridWorkerConfiguration.txt

Get-HybridWorkerJobRuntimeInfo | out-file C:\temp\HybridWorkerJobRuntimeInfo.txt

New-HybridWorkerRunbookLogEntry -Id 886 -Message "This is the first test message logged from hybrid worker within a PowerShell runbook."

New-HybridWorkerRunbookLogEntry -Id 887 -Message "This is the second test message logged from hybrid worker within a PowerShell runbook." -Level Error -LogHybridWorkerConfig $true

```
**Sample PowerShell Workflow Runbook**

```powershell
workflow Test-HybridWorkerOutput-PSW
{
#Write-Output "Exporting Hybrid Worker config"
Get-HybridWorkerConfiguration  | out-file C:\temp\HybridWorkerConfiguration.txt

#Write-Output "Exporting Job Runtime info"
Get-HybridWorkerJobRuntimeInfo | out-file C:\temp\HybridWorkerJobRuntimeInfo.txt

#Write-Output "Logging first event log entry."
New-HybridWorkerRunbookLogEntry -Id 888 -Message "This is the first test message logged from hybrid worker within a PowerShell Workflow runbook."

#Write-Output "Logging second event log entry."
New-HybridWorkerRunbookLogEntry -Id 889 -Message "This is the second test message logged from hybrid worker within a PowerShell Workflow runbook." -Level Warning -LogHybridWorkerConfig $true
}
```
As you can see, the way to call these functions between PowerShell and PowerShell Workflow runbooks are exactly the same.

Hybrid Worker Configuration output:

<a href="https://blog.tyang.org/wp-content/uploads/2016/04/SNAGHTML40e35ad.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML40e35ad" src="https://blog.tyang.org/wp-content/uploads/2016/04/SNAGHTML40e35ad_thumb.png" alt="SNAGHTML40e35ad" width="449" height="199" border="0" /></a>

Hybrid Worker Job Runtime Info output:

<a href="https://blog.tyang.org/wp-content/uploads/2016/04/SNAGHTML40f4d28.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML40f4d28" src="https://blog.tyang.org/wp-content/uploads/2016/04/SNAGHTML40f4d28_thumb.png" alt="SNAGHTML40f4d28" width="455" height="179" border="0" /></a>

Event generated (with basic information / without setting –LogHybridWorkerConfig to $true):

<a href="https://blog.tyang.org/wp-content/uploads/2016/04/SNAGHTML4159a604.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML4159a60[4]" src="https://blog.tyang.org/wp-content/uploads/2016/04/SNAGHTML4159a604_thumb.png" alt="SNAGHTML4159a60[4]" width="624" height="342" border="0" /></a>

Event generated (whensetting –LogHybridWorkerConfig to $true):

<a href="https://blog.tyang.org/wp-content/uploads/2016/04/SNAGHTML4150515.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML4150515" src="https://blog.tyang.org/wp-content/uploads/2016/04/SNAGHTML4150515_thumb.png" alt="SNAGHTML4150515" width="620" height="381" border="0" /></a>

## Consuming collected events in OMS

Once you have collected these events in OMS, you can use search queries to find them, and you can also create OMS alerts to notify you using your preferred methods.

### Searching Events in OMS

i.e. I can use this query to get all events logged by a particular runbook:

```text
Type=Event "RunbookName: Test-HybridWorkerOutput-PSW"
```

<a href="https://blog.tyang.org/wp-content/uploads/2016/04/image.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/04/image_thumb.png" alt="image" width="555" height="346" border="0" /></a>

or use this query to get all events for a particular job:

```text
Type=Event "JobId: 73A3827D-73F8-4ECC-9DE1-B9340FB90744"
```

<a href="https://blog.tyang.org/wp-content/uploads/2016/04/image-1.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/04/image_thumb-1.png" alt="image" width="567" height="366" border="0" /></a>

### OMS Alerts

i.e. if I want to create an OMS alert for any Error events logged by New-HybridWorkerRunbookLogEntry, I can use a query like this one:

```text
Type=Event Source=AzureAutomation?Job* EventLevelName=Error
```

<a href="https://blog.tyang.org/wp-content/uploads/2016/04/image-2.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/04/image_thumb-2.png" alt="image" width="606" height="423" border="0" /></a>

<a href="https://blog.tyang.org/wp-content/uploads/2016/04/image-3.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/04/image_thumb-3.png" alt="image" width="483" height="369" border="0" /></a>

## Download / Deploy this module

I have published this module on Github as well as PowerShell Gallery:

GitHub Repository: <a title="https://github.com/tyconsulting/HybridWorkerToolkit" href="https://github.com/tyconsulting/HybridWorkerToolkit">https://github.com/tyconsulting/HybridWorkerToolkit</a>

PowerShell Gallery:  <a title="http://www.powershellgallery.com/packages/HybridWorkerToolkit/1.0.1" href="http://www.powershellgallery.com/packages/HybridWorkerToolkit/1.0.3">http://www.powershellgallery.com/packages/HybridWorkerToolkit/1.0.3</a>

## Credit

I’d like to thank Pete and Kevin for the ideas in the first place, also I’d like to thank <a href="https://twitter.com/pzerger">Pete</a>, <a href="https://twitter.com/JakobGSvendsen">Jakob Svendsen</a>, <a href="https://twitter.com/DanieleGrandini">Daniele Grandini</a> and <a href="https://twitter.com/kjacobsen">Kieran Jacobsen</a> for the testing and feedback!