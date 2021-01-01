---
id: 4650
title: 'Automating OpsMgr Part 15: Creating 2-State Event Monitors'
date: 2015-09-25T21:06:03+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=4650
permalink: /2015/09/25/automating-opsmgr-part-15-creating-2-state-event-monitors/
categories:
  - PowerShell
  - SCOM
  - SMA
tags:
  - Automating OpsMgr
  - Powershell
  - SCOM
  - SMA
---
<h3><a href="http://blog.tyang.org/wp-content/uploads/2015/06/OpsMgrExnteded.png"><img class="alignleft size-thumbnail wp-image-4038" src="http://blog.tyang.org/wp-content/uploads/2015/06/OpsMgrExnteded-150x150.png" alt="OpsMgrExnteded" width="150" height="150" /></a>Introduction</h3>
This is the 15th instalment of the Automating OpsMgr series. Previously on this series:
<ul>
	<li><a href="http://blog.tyang.org/2015/06/24/automating-opsmgr-part-1-introducing-opsmgrextended-powershell-sma-module/">Automating OpsMgr Part 1: Introducing OpsMgrExtended PowerShell / SMA Module</a></li>
	<li><a href="http://blog.tyang.org/2015/06/28/automating-opsmgr-part-2-sma-runbook-for-creating-configmgr-log-collection-rules/">Automating OpsMgr Part 2: SMA Runbook for Creating ConfigMgr Log Collection Rules</a></li>
	<li><a href="http://blog.tyang.org/2015/06/30/automating-opsmgr-part-3-new-management-pack-runbook-via-sma-and-azure-automation/">Automating OpsMgr Part 3: New Management Pack Runbook via SMA and Azure Automation</a></li>
	<li><a href="http://blog.tyang.org/2015/07/02/automating-opsmgr-part-4-create-new-empty-groups/">Automating OpsMgr Part 4:Creating New Empty Groups</a></li>
	<li><a href="http://blog.tyang.org/2015/07/06/automating-opsmgr-part-5-adding-computers-to-computer-groups/">Automating OpsMgr Part 5: Adding Computers to Computer Groups</a></li>
	<li><a href="http://blog.tyang.org/2015/07/13/automating-opsmgr-part-6-adding-monitoring-objects-to-instance-groups/">Automating OpsMgr Part 6: Adding Monitoring Objects to Instance Groups</a></li>
	<li><a href="http://blog.tyang.org/2015/07/17/automating-opsmgr-part-7-updated-opsmgrextended-module/">Automating OpsMgr Part 7: Updated OpsMgrExtended Module</a></li>
	<li><a href="http://blog.tyang.org/2015/07/17/automating-opsmgr-part-8-adding-management-pack-references/">Automating OpsMgr Part 8: Adding Management Pack References</a></li>
	<li><a href="http://blog.tyang.org/2015/07/17/automating-opsmgr-part-9-updating-group-discoveries/">Automating OpsMgr Part 9: Updating Group Discoveries</a></li>
	<li><a href="http://blog.tyang.org/2015/07/27/automating-opsmgr-part-10-deleting-groups/">Automating OpsMgr Part 10: Deleting Groups</a></li>
	<li><a href="http://blog.tyang.org/2015/07/29/automating-opsmgr-part-11-configuring-group-health-rollup/">Automating OpsMgr Part 11: Configuring Group Health Rollup</a></li>
	<li><a href="http://blog.tyang.org/2015/08/08/automating-opsmgr-part-12-creating-performance-collection-rules/">Automating OpsMgr Part 12: Creating Performance Collection Rules</a></li>
	<li><a href="http://blog.tyang.org/2015/08/24/automating-opsmgr-part-13-creating-2-state-performance-monitors/">Automating OpsMgr Part 13: Creating 2-State Performance Monitors</a></li>
	<li><a href="http://blog.tyang.org/2015/08/31/automating-opsmgr-part-14-creating-event-collection-rules/">Automating OpsMgr Part 14: Creating Event Collection Rules</a></li>
</ul>
It’s been almost a month since the last post on this series, partially because I was working on the OpsMgr Self Maintenance MP v2.5. Previously on Part 14, I have demonstrated how to create an event collection rule using the OpsMgrExtended module. Today, I’ll show you how to create a 2-State event monitor using the New-OM2StateEventMonitor function from the OpsMgrExtended module.

Like all other functions in this module, it has been fully documented, with few examples, which can be accessed using Get-Help cmdlet:

<strong>Get-Help New-OM2StateEventMonitor –Full</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2015/09/SNAGHTMLb9099e1.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLb9099e1" src="http://blog.tyang.org/wp-content/uploads/2015/09/SNAGHTMLb9099e1_thumb.png" alt="SNAGHTMLb9099e1" width="364" height="266" border="0" /></a>
<h3>Runbook: New-2StateEventMonitor</h3>
<pre language="PowerShell">Workflow New-2StateEventMonitor
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
</pre>
I have hardcoded the following parameters in the runbook:
<ul>
	<li>SMA OpsMgr connection object name (which you will need to change to suit your environment)</li>
	<li>(Unsealed) MP (where the rule  is going to be saved to) – "TYANG.Test.Windows.Monitoring"</li>
</ul>
Additionally, this runbook will firstly try to retrieve the management pack from the management group, if the MP deosn’t exist, it will create it first.

This runbook takes the following input parameters:
<ul>
	<li><strong>ClassName</strong> – The name of the target monitoring class (i.e.Microsoft.Windows.Server.OperatingSystem)</li>
	<li><strong>UnhealthyEventID </strong>– The Event ID for the unhealthy event.</li>
	<li><strong>HealthyEventID </strong>– The Event ID for the healthy event.</li>
	<li><strong>UnhealthyState</strong>– The unhealthy state of the monitor (either warning or error).</li>
	<li><strong>EventLog</strong> –The name of the event log (i.e. Application, System, etc)</li>
	<li><strong>Publisher</strong>– The event publisher</li>
	<li><strong>MonitorDisabled</strong>– Boolean, whether the event monitor should be disabled by default</li>
	<li><strong>MonitorDisplayName</strong>– Display name of the unit monitor</li>
	<li><strong>MonitorName</strong> – The name of the unit monitor</li>
	<li><strong>ParentMonitor</strong> – The parent dependency monitor for the event unit monitor</li>
</ul>
Runbook Execution Result:

<a href="http://blog.tyang.org/wp-content/uploads/2015/09/image24.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/09/image_thumb24.png" alt="image" width="517" height="611" border="0" /></a>

Monitor Properties from the OpsMgr operations console:

General:

<a href="http://blog.tyang.org/wp-content/uploads/2015/09/image25.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/09/image_thumb25.png" alt="image" width="376" height="389" border="0" /></a>

Unhealthy Event:

<a href="http://blog.tyang.org/wp-content/uploads/2015/09/image26.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/09/image_thumb26.png" alt="image" width="377" height="390" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2015/09/image27.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/09/image_thumb27.png" alt="image" width="378" height="391" border="0" /></a>

Healthy Event:

<a href="http://blog.tyang.org/wp-content/uploads/2015/09/image28.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/09/image_thumb28.png" alt="image" width="380" height="393" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2015/09/image29.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/09/image_thumb29.png" alt="image" width="381" height="394" border="0" /></a>

Alert Setting:

<a href="http://blog.tyang.org/wp-content/uploads/2015/09/image30.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/09/image_thumb30.png" alt="image" width="382" height="395" border="0" /></a>
<h3>Conclusion</h3>
In this post, I’ve demonstrated how to create a 2-state event monitor using the OpsMgrExtended module. now that I have covered both even collection rules and even monitors, I will dedicate the next 2 posts on monitoring Windows services.