---
id: 4693
title: 'Automating OpsMgr Part 16: Creating Windows Service Monitors'
date: 2015-10-02T13:35:53+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=4693
permalink: /2015/10/02/automating-opsmgr-part-16-creating-windows-service-monitors/
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
<h3><a href="http://blog.tyang.org/wp-content/uploads/2015/06/OpsMgrExnteded.png"><img class="alignleft size-thumbnail wp-image-4038" src="http://blog.tyang.org/wp-content/uploads/2015/06/OpsMgrExnteded-150x150.png" alt="OpsMgrExnteded" width="150" height="150" /></a>Introduction</h3>
This is the 16th instalment of the Automating OpsMgr series. Previously on this series:
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
	<li><a href="http://blog.tyang.org/2015/09/25/automating-opsmgr-part-15-creating-2-state-event-monitors/">Automating OpsMgr Part 15: Creating 2-State Event Monitors</a></li>
</ul>
I will dedicate this post and the next post to creating monitoring solutions for Windows services. In this post, I will demonstrate how to create a basic Windows service monitor using the <strong>New-OMServiceMonitor</strong> function from the <strong>OpsMgrExtended</strong> module.

You can access the help document for this function using the Get-Help cmdlet:

<strong>Get-Help New-OMServiceMonitor –Full</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/SNAGHTMLb42d9c.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLb42d9c" src="http://blog.tyang.org/wp-content/uploads/2015/10/SNAGHTMLb42d9c_thumb.png" alt="SNAGHTMLb42d9c" width="387" height="320" border="0" /></a>
<h3>Sample Runbook: New-ServiceMonitor</h3>
<pre language="PowerShell">Workflow New-ServiceMonitor
{
Param(
[Parameter(Mandatory=$true)][String]$MonitorName,
[Parameter(Mandatory=$true)][String]$MonitorDisplayName,
[Parameter(Mandatory=$true)][String]$ClassName,
[Parameter(Mandatory=$true)][String]$ParentMonitor,
[Parameter(Mandatory=$true)][String]$ServiceName,
[Parameter(Mandatory=$true)][Boolean]$IgnoreStartupType,
[Parameter(Mandatory=$true)][Boolean]$UnhealthyWhenRunning,
[Parameter(Mandatory=$true)][String]$UnhealthyState,
[Parameter(Mandatory=$false)][Boolean]$MonitorDisabled
)

#Get OpsMgrSDK connection object
$OpsMgrSDKConn = Get-AutomationConnection -Name "OpsMgrSDK_Home"

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

#Create Service Monitor, MP Version will be increased by 0.0.0.1
$MonitorCreated = InlineScript
{

#Validate Monitor Name
If ($USING:MonitorName -notmatch "([a-zA-Z0-9]+\.)+[a-zA-Z0-9]+")
{
#Invalid Monitor name entered
$ErrMsg = "Invalid monitor name specified. Please make sure it only contains alphanumeric charaters and only use '.' to separate words. i.e. 'Your.Company.Windows.Time.Service.Monitor'."
Write-Error $ErrMsg
} else {
#Name is valid, creating the monitor
Write-Output "Creating the servivce monitor `"$MonitorName`"..."

New-OMServiceMonitor -SDKConnection $USING:OpsMgrSDKConn -MPName $USING:MPName -MonitorName $USING:MonitorName -MonitorDisplayName $USING:MonitorDisplayName -ClassName $USING:ClassName -ParentMonitor $USING:ParentMonitor -ServiceName $USING:ServiceName -UnhealthyState $USING:UnhealthyState -IgnoreStartupType $USING:IgnoreStartupType -UnhealthyWhenRunning $USING:UnhealthyWhenRunning -Disabled $USING:MonitorDisabled -IncreaseMPVersion $true
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
	<li><strong>UnhealthyState</strong>– The unhealthy state of the monitor (either warning or error).</li>
	<li><strong>ServiceName</strong>–The name of the Windows service (i.e. w32time)</li>
	<li><strong>IgnoreStartupType</strong>– Set this Boolean parameter to True if you want the monitor to become unhealthy and generate alerts even when the service startup type is not set to "Automatic". More details about this parameter can be found from Kevin Holman’s blog post <a href="http://blogs.technet.com/b/kevinholman/archive/2010/11/07/monitoring-windows-services-automatic-manual-and-disabled-using-checkstartuptype.aspx">Monitoring Windows Services – Automatic, Manual, and Disabled, using CheckStartupType</a></li>
	<li><strong>UnhealthyWhenRunning – </strong>Set this Boolean parameter to True when you want the monitor to become unhealthy and generate alert when the service is running (instead of stopped)</li>
	<li><strong>MonitorDisabled</strong>– Boolean, whether the event monitor should be disabled by default</li>
	<li><strong>MonitorDisplayName</strong>– Display name of the unit monitor</li>
	<li><strong>MonitorName</strong> – The name of the unit monitor</li>
	<li><strong>ParentMonitor</strong> – The parent dependency monitor for the event unit monitor</li>
</ul>
<h3>Runbook Execution Result:</h3>
<a href="http://blog.tyang.org/wp-content/uploads/2015/10/image1.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/10/image_thumb.png" alt="image" width="515" height="587" border="0" /></a>
<h3>Monitor Properties from OpsMgr Console:</h3>
<a href="http://blog.tyang.org/wp-content/uploads/2015/10/image2.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/10/image_thumb1.png" alt="image" width="439" height="454" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/image3.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/10/image_thumb3.png" alt="image" width="439" height="454" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/image4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/10/image_thumb4.png" alt="image" width="441" height="456" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/image5.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/10/image_thumb5.png" alt="image" width="440" height="455" border="0" /></a>
<h3>Conclusion</h3>
In this post, I have shown how to create a basic windows service monitor using a simple SMA / Azure Automation runbook with New-OMServiceMonitor function in the OpsMgrExtended module. In the next post, I will show you how to create an instance of the Windows Service management pack template using the OpsMgrExtended module.