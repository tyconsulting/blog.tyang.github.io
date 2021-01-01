---
id: 4709
title: 'Automating OpsMgr Part 17: Creating Windows Service Management Pack Template Instance'
date: 2015-10-04T16:35:18+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=4709
permalink: /2015/10/04/automating-opsmgr-part-17-creating-windows-service-management-pack-template-instance/
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
<a href="http://blog.tyang.org/wp-content/uploads/2015/06/OpsMgrExnteded.png"><img class="alignleft size-thumbnail wp-image-4038" src="http://blog.tyang.org/wp-content/uploads/2015/06/OpsMgrExnteded-150x150.png" alt="OpsMgrExnteded" width="150" height="150" /></a>This is the 17th instalment of the Automating OpsMgr series. Previously on this series:
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
	<li><a href="http://blog.tyang.org/2015/10/02/automating-opsmgr-part-16-creating-windows-service-monitors/">Automating OpsMgr Part 16: Creating Windows Service Monitors</a></li>
</ul>
Now that I have demonstrated how to create basic Windows service monitors using New-OMServiceMonitor, in this post, I’ll demonstrate how to use the OpsMgrExtended module to create an instance of the “Windows Service” management pack template:

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/image6.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; margin: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/10/image_thumb6.png" alt="image" width="244" height="218" border="0" /></a>

The OpsMgrExtedned module comes with a function called <strong>New-OMWindowsServiceTemplateInstance</strong>. Same as all other functions in this module, it is fully documented, you can access the help document using Get-Help cmdlet:

<strong>Get-Help New-OMWindowsServiceTemplateInstance –Full</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/SNAGHTML2e5dc32.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML2e5dc32" src="http://blog.tyang.org/wp-content/uploads/2015/10/SNAGHTML2e5dc32_thumb.png" alt="SNAGHTML2e5dc32" width="609" height="433" border="0" /></a>
<h3>Sample Runbook New-WindowsServiceTemplateInstance</h3>
<pre language="PowerShell">Workflow New-WindowsServiceTemplateInstance
{
Param(
[Parameter(Mandatory=$true)][String]$InstanceDisplayName,
[Parameter(Mandatory=$false)][String]$InstanceDescription,
[Parameter(Mandatory=$true)][String]$TargetGroupName,
[Parameter(Mandatory=$true)][String]$ServiceName,
[Parameter(Mandatory=$false)][String]$LocaleId,
[Parameter(Mandatory=$true)][Boolean]$CheckStartupType,
[Parameter(Mandatory=$false)][Int]$CPUPercent,
[Parameter(Mandatory=$false)][Int]$MemoryUsageMB,
[Parameter(Mandatory=$false)][Int]$ConsecutiveSampleCount,
[Parameter(Mandatory=$false)][Int]$PollIntervalInSeconds
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
#parameters

#Create Service Monitor, MP Version will be increased by 0.0.0.1
$result = InlineScript
{
$SDK = $USING:OpsMgrSDKConn.ComputerName
Write-Verbose "OpsMgr management server name: $SDK"
$UserName = $USING:OpsMgrSDKConn.Username
$password = ConvertTo-SecureString -AsPlainText $USING:OpsMgrSDKConn.Password -force

$parms = @{
SDKConnection = $USING:OpsMgrSDKConn
MPName = $USING:MPName
DisplayName = $USING:InstanceDisplayName
Description = $USING:InstanceDescription
ServiceName = $USING:ServiceName
TargetGroupName = $USING:TargetGroupName
CheckStartupType = $USING:CheckStartupType
IncreaseMPVersion = $true
}
if ($USING:LocaleId -ne $null)
{
$parms.Add('LocaleId', $USING:LocaleId)
}
if ($USING:CPUPercent -gt 0)
{
$parms.Add('PercentCPU', $USING:CPUPercent)
}
if ($USING:MemoryUsageMB -gt 0)
{
$parms.Add('MemoryUsage', $USING:MemoryUsageMB)
}
if ($USING:ConsecutiveSampleCount -gt 0)
{
$parms.Add('ConsecutiveSampleCount', $USING:ConsecutiveSampleCount)
}
if ($USING:PollIntervalInSeconds -gt 0)
{
$parms.Add('PollIntervalInSeconds', $USING:PollIntervalInSeconds)
}

Write-Verbose "Calling New-OMWindowsServiceTemplateInstance with the following parameters:"
Write-Verbose ($parms | out-string)
New-OMWindowsServiceTemplateInstance @parms
}

If ($result)
{
Write-Output "The Windows Service monitoring template instance `"$InstanceDisplayName`" is created."
} else {
Write-Error "Unable to create the Windows Service monitoring template instance `"$InstanceDisplayName`"."
}

}
</pre>
I have hardcoded the following parameters in the runbook:
<ul>
	<li>SMA OpsMgr connection object name (which you will need to change to suit your environment)</li>
	<li>(Unsealed) MP (where the rule  is going to be saved to) – “TYANG.Test.Windows.Monitoring”</li>
</ul>
Additionally, this runbook will firstly try to retrieve the management pack from the management group, if the MP deosn’t exist, it will create it first.

This runbook takes the following input parameters:
<ul>
	<li><strong>InstanceDisplayName</strong>– The Display name of the template instance.</li>
	<li><strong>InstanceDescription</strong>– This is an optional parameter. The description of the template instance.</li>
	<li><strong>TargetGroupName</strong>– The name of the target group</li>
	<li><strong>ServiceName</strong>–The name of the Windows service (i.e. w32time)</li>
	<li><strong>LocaleId– </strong>The 3-letter MP language pack locale ID. This is an optional parameter, if not specified, it will be set to “ENU”.</li>
	<li><strong>CheckStartupType</strong>– Set this Boolean parameter to True if you only want to monitor automatic service. More details about this parameter can be found from Kevin Holman’s blog post <a href="http://blogs.technet.com/b/kevinholman/archive/2010/11/07/monitoring-windows-services-automatic-manual-and-disabled-using-checkstartuptype.aspx">Monitoring Windows Services – Automatic, Manual, and Disabled, using CheckStartupType</a></li>
	<li><strong>CPUPercent</strong>– Specify the threshold for CPU Usage Percentage. This is an optional parameter, if not specifiied, the CPU Usage will not be monitored or collected.</li>
	<li><strong>MemoryUsageMB</strong>– Specify the threshold for Memory Usage (MB). This is an optional parameter, if not specifiied, the Memory Usage will not be monitored or collected.</li>
	<li><strong>ConsecutiveSampleCount</strong>– Specify the the number of (consecutive) samples for the CPU and Memory counters, This is an optional parameter. if not specified, the value is set to 2 (which is the default value when using the wizard in the OpsMgr console).</li>
	<li><strong>PollingIntervalInSeconds-</strong> Specify sample polling interval (in seconds). This is an optional parameter, if not specifiied, the value is set to 300 (which is the default value when using the wizard in the OpsMgr console).</li>
</ul>
To help you visualise what are these parameters mean, I’ve mapped them to the fields in the GUI wizard:

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/image7.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/10/image_thumb7.png" alt="image" width="480" height="438" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/image8.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/10/image_thumb8.png" alt="image" width="483" height="441" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/image9.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/10/image_thumb9.png" alt="image" width="486" height="444" border="0" /></a>
<h3>Runbook Execution Result:</h3>
<a href="http://blog.tyang.org/wp-content/uploads/2015/10/image10.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/10/image_thumb10.png" alt="image" width="592" height="523" border="0" /></a>
<h3>A Known Issue</h3>
When I was writing the sample runbook, I found a small bug in the OpsMgrExtended module. You may noticed from the screenshots above, that the description field is not populated. I have found the cause of this issue and fixed it in my lab. This fix will be shipped with the next release. So please just be aware of this issue, I don’t think it’s too critical.
<h3>Conclusion</h3>
In this post, I have demonstrated how to create Windows Service MP template instances using the OpsMgrExtended module. This concludes the topics of monitoring Windows services. In the next module, I will demonstrate how to create any types of generic rules by specifying the configuration of each member module (Data Source, Condition Detection and Write Action) using the New-OMRule function. Until next time, happy automating!