---
id: 4472
title: 'Automating OpsMgr Part 14: Creating Event Collection Rules'
date: 2015-08-31T19:50:34+10:00
author: Tao Yang
#layout: post
excerpt: ""
header:
  overlay_image: /wp-content/uploads/2015/06/OpsMgrExnteded-banner.png
  overlay_filter: 0.5 # same as adding an opacity of 0.5 to a black background
guid: https://blog.tyang.org/?p=4472
permalink: /2015/08/31/automating-opsmgr-part-14-creating-event-collection-rules/
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

This is the 14th installment of the Automating OpsMgr series. Previously on this series:

* [Automating OpsMgr Part 1: Introducing OpsMgrExtended PowerShell / SMA Module](https://blog.tyang.org/2015/06/24/automating-opsmgr-part-1-introducing-opsmgrextended-powershell-sma-module/)
* [Automating OpsMgr Part 2: SMA Runbook for Creating ConfigMgr Log Collection Rules](https://blog.tyang.org/2015/06/28/automating-opsmgr-part-2-sma-runbook-for-creating-configmgr-log-collection-rules/)
* [Automating OpsMgr Part 3: New Management Pack Runbook via SMA and Azure Automation](https://blog.tyang.org/2015/06/30/automating-opsmgr-part-3-new-management-pack-runbook-via-sma-and-azure-automation/)
* [Automating OpsMgr Part 4:Creating New Empty Groups](https://blog.tyang.org/2015/07/02/automating-opsmgr-part-4-create-new-empty-groups/)
* [Automating OpsMgr Part 5: Adding Computers to Computer Groups](https://blog.tyang.org/2015/07/06/automating-opsmgr-part-5-adding-computers-to-computer-groups/)
* [Automating OpsMgr Part 6: Adding Monitoring Objects to Instance Groups](https://blog.tyang.org/2015/07/13/automating-opsmgr-part-6-adding-monitoring-objects-to-instance-groups/)
* [Automating OpsMgr Part 7: Updated OpsMgrExtended Module](https://blog.tyang.org/2015/07/17/automating-opsmgr-part-7-updated-opsmgrextended-module/)
* [Automating OpsMgr Part 8: Adding Management Pack References](https://blog.tyang.org/2015/07/17/automating-opsmgr-part-8-adding-management-pack-references/)
* [Automating OpsMgr Part 9: Updating Group Discoveries](https://blog.tyang.org/2015/07/17/automating-opsmgr-part-9-updating-group-discoveries/)
* [Automating OpsMgr Part 10: Deleting Groups](https://blog.tyang.org/2015/07/27/automating-opsmgr-part-10-deleting-groups/)
* [Automating OpsMgr Part 11: Configuring Group Health Rollup](https://blog.tyang.org/2015/07/29/automating-opsmgr-part-11-configuring-group-health-rollup/)
* [Automating OpsMgr Part 12: Creating Performance Collection Rules](https://blog.tyang.org/2015/08/08/automating-opsmgr-part-12-creating-performance-collection-rules/)
* [Automating OpsMgr Part 13: Creating 2-State Performance Monitors](https://blog.tyang.org/2015/08/24/automating-opsmgr-part-13-creating-2-state-performance-monitors/)

Previously in part 12 and 13, I have demonstrated how to create performance related workflows using the OpsMgrExtended module. Today, I will start discussing event data, in this post, I will demonstrate how to create an event collection rule.

In the **OpsMgrExtended** module, there is a function called <strong>New-OMEventCollectionRule</strong>, which can be used to create event collection rules. It has been fully documented, you can access the documentation by using the Get-Help cmdlet:

**Get-Help New-OMEventCollectionRule**

<a href="https://blog.tyang.org/wp-content/uploads/2015/08/SNAGHTML8b917c0.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML8b917c0" src="https://blog.tyang.org/wp-content/uploads/2015/08/SNAGHTML8b917c0_thumb.png" alt="SNAGHTML8b917c0" width="585" height="338" border="0" /></a>

A side note here, Last week, I received an email asked me if the OpsMgrExtended module can be used outside of SMA and Azure Automation. The answer is yes, it can be used as a normal PowerShell module. for all the functions included in the module, you can access the examples by using the Get-Help cmdlet with –Full or –Example switch:

<a href="https://blog.tyang.org/wp-content/uploads/2015/08/image43.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/08/image_thumb43.png" alt="image" width="674" height="520" border="0" /></a>

## Runbook: New-EventCollectionRule

```powershell
Workflow New-EventCollectionRule
{
  Param(
  [Parameter(Mandatory=$true)][String]$RuleName,
  [Parameter(Mandatory=$true)][String]$RuleDisplayName,
  [Parameter(Mandatory=$true)][String]$EventLog,
  [Parameter(Mandatory=$true)][String]$Publisher,
  [Parameter(Mandatory=$false)][Int]$EventID,
  [Parameter(Mandatory=$true)][String]$ClassName,
  [Parameter(Mandatory=$true)][Boolean]$RuleDisabled
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
  #Hard code frequency (900 seconds)
  $Frequency = 900

  #Create Event Collection Rule, MP Version will be increased by 0.0.0.1
  $RuleCreated = InlineScript
  {

    #Validate rule Name
    If ($USING:RuleName -notmatch "([a-zA-Z0-9]+\.)+[a-zA-Z0-9]+")
    {
      #Invalid rule name entered
      $ErrMsg = "Invalid rule name specified. Please make sure it only contains alphanumeric charaters and only use '.' to separate words. i.e. 'Your.Company.Application.Log.EventID.1234.Collection.Rule'."
      Write-Error $ErrMsg
    } else {
      #Name is valid, creating the rule
      New-OMEventCollectionRule -SDKConnection $USING:OpsMgrSDKConn -MPName $USING:MPName -RuleName $USING:RuleName -RuleDisplayName $USING:RuleDisplayName -ClassName $USING:ClassName -EventLog $USING:EventLog -Publisher $USING:Publisher -EventID $USING:EventID -Disabled $USING:RuleDisabled -IncreaseMPVersion $true
    }
  }

  If ($RuleCreated)
  {
    Write-Output "Rule `"$RuleName`" created."
  } else {
    Write-Error "Unable to create rule `"$RuleName`"."
  }
}
```
I have hardcoded the following parameters in the runbook:

* SMA OpsMgr connection object name (which you will need to change to suit your environment)
* Frequency – 900 seconds
* (Unsealed) MP (where the rule  is going to be saved to) – "TYANG.Test.Windows.Monitoring"

Additionally, this runbook will firstly try to retrieve the management pack from the management group, if the MP deosn’t exist, it will create it first.

This runbook takes the following input parameters:

* **ClassName** – The name of the target monitoring class (i.e.Microsoft.Windows.Server.OperatingSystem)
* **EventID **– Optional. the Event ID to be collected by the rule.
* **EventLog** –The name of the event log to be collected by the rule
* **Publisher**– The event publisher
* **RuleDisabled**– Boolean, whether the event collection rule should be disabled by default
* **RuleDisplayName**– Display name of the rule
* **RuleName** – The name of the rule

Runbook Execution Result:

<a href="https://blog.tyang.org/wp-content/uploads/2015/08/image44.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/08/image_thumb44.png" alt="image" width="517" height="552" border="0" /></a>

Viewing the rule properties in OpsMgr operations console:

<a href="https://blog.tyang.org/wp-content/uploads/2015/08/image45.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/08/image_thumb45.png" alt="image" width="398" height="417" border="0" /></a>

<a href="https://blog.tyang.org/wp-content/uploads/2015/08/image46.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/08/image_thumb46.png" alt="image" width="402" height="421" border="0" /></a>

<a href="https://blog.tyang.org/wp-content/uploads/2015/08/image47.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/08/image_thumb47.png" alt="image" width="403" height="418" border="0" /></a>

<a href="https://blog.tyang.org/wp-content/uploads/2015/08/image48.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/08/image_thumb48.png" alt="image" width="404" height="419" border="0" /></a>

## What if I don’t want to use SMA or Azure Automation?

Like I mentioned before, you don’t have to if you don’t want to. You can simply modify the runbook demonstrated above to run in a standalone PowerShell console by changing the PowerShell workflow to pass the OpsMgr management server name to the OpsMgrExtended functions (instead of SMA connection objects):

<a href="https://blog.tyang.org/wp-content/uploads/2015/08/image49.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/08/image_thumb49.png" alt="image" width="640" height="385" border="0" /></a>

After updated the script (which contains the PS Workflow), firstly run the workflow in PowerShell, then call / execute the workflow:

Load the workflow:

<a href="https://blog.tyang.org/wp-content/uploads/2015/08/SNAGHTML93cdde2.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML93cdde2" src="https://blog.tyang.org/wp-content/uploads/2015/08/SNAGHTML93cdde2_thumb.png" alt="SNAGHTML93cdde2" width="675" height="542" border="0" /></a>

Execute the workflow:

<a href="https://blog.tyang.org/wp-content/uploads/2015/08/image50.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/08/image_thumb50.png" alt="image" width="695" height="212" border="0" /></a>

## Conclusion

In this post, I have demonstrated how to create an event collection rule using OpsMgrExtended module, with and without automation engines such as SMA and Azure Automation. I will demonstrate how to create a 2-state event monitor in the next post of the Automating OpsMgr series. Until next time, happy automating!