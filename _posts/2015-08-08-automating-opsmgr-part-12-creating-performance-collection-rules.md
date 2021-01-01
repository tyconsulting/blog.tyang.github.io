---
id: 4336
title: 'Automating OpsMgr Part 12: Creating Performance Collection Rules'
date: 2015-08-08T13:13:00+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=4336
permalink: /2015/08/08/automating-opsmgr-part-12-creating-performance-collection-rules/
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
This is the 12th instalment of the Automating OpsMgr series. Previously on this series:
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
</ul>
From now on, I will start concentrating on creating various monitoring workflows (rules, monitors, template instances, etc) using the <strong>OpsMgrExtended</strong> module. I will dedicate at least 6-7 posts on this topic. Since OpsMgr is a monitoring solution, I am now getting to the core offering of this module – providing ways for OpsMgr professionals to automate the creation of their monitoring requirements. In this post, I will demonstrate a runbook utilising <strong>New-OMPerformanceCollectionRule</strong> activity from the OpsMgrExtended module, to create performance collection rules in OpsMgr.
<h3>Runbook New-PerfCollectionRule</h3>
<pre class="" language="PowerShell">Workflow New-PerfCollectionRule
{
Param(
[Parameter(Mandatory=$true)][String]$RuleName,
[Parameter(Mandatory=$true)][String]$RuleDisplayName,
[Parameter(Mandatory=$true)][String]$CounterName,
[Parameter(Mandatory=$true)][String]$ObjectName,
[Parameter(Mandatory=$false)][String]$InstanceName,
[Parameter(Mandatory=$true)][String]$ClassName,
[Parameter(Mandatory=$false)][Boolean]$RuleDisabled
)

#Get OpsMgrSDK connection object
$OpsMgrSDKConn = Get-AutomationConnection -Name "OpsMgrSDK_HOME"

#Hard code which MP to use
$MPName = "TYANG.Test.Windows.Monitoring"

#Hard code frequency (900 seconds)
$Frequency = 900

#Create Performance Collection Rule, MP Version will be increased by 0.0.0.1
$RuleCreated = InlineScript
{

#Validate rule Name
If ($USING:RuleName -notmatch "([a-zA-Z0-9]+\.)+[a-zA-Z0-9]+")
{
#Invalid rule name entered
$ErrMsg = "Invalid rule name specified. Please make sure it only contains alphanumeric charaters and only use '.' to separate words. i.e. 'Your.Company.Percentage.Processor.Time.Performance.Collection.Rule'."
Write-Error $ErrMsg
} else {
#Name is valid, creating the rule
New-OMPerformanceCollectionRule -SDKConnection $USING:OpsMgrSDKConn -MPName $USING:MPName -RuleName $USING:RuleName -RuleDisplayName $USING:RuleDisplayName -ClassName $USING:ClassName -CounterName $USING:CounterName -ObjectName $USING:ObjectName -InstanceName $USING:InstanceName -Frequency $USING:Frequency -Disabled $USING:RuleDisabled -IncreaseMPVersion $true
}
}

If ($RuleCreated)
{
Write-Output "Rule `"$RuleName`" created."
} else {
Throw "Unable to create rule `"$RuleName`"."
}
}
</pre>
In order to use this runbook, you firstly need to modify line 14 with the name of the SMA connection to your OpsMgr management group:

<a href="http://blog.tyang.org/wp-content/uploads/2015/08/image.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/08/image_thumb.png" alt="image" width="585" height="79" border="0" /></a>

I have also hardcoded few other parameters in the runbook:

<a href="http://blog.tyang.org/wp-content/uploads/2015/08/image1.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/08/image_thumb1.png" alt="image" width="510" height="156" border="0" /></a>

<strong>$MPName</strong> is the name of the unsealed MP where the rule is going to be saved to, and <strong>$Frequency</strong> is the interval in seconds on how often does this perf collection rule need to run. You also need to modify these 2 variables, especially the $MPName – the unsealed MP must exist in your management group already.

This runbook requires the following input parameters:

<strong>$RuleName</strong> – name of the perf collection rule

<strong>$RuleDisplayName</strong> – The display name of the perf collection rule

<strong>$CounterName</strong> – name of the perf counter you need to collect

<strong>$ObjectName</strong> – name of the object where the counter belongs to (i.e. memory, logical disk, etc.)

<strong>$InstanceName</strong> (optional) – name of the instance of the counter. if not specified, the rule will collect All Instances.

<strong>$ClassName</strong> – name of the OpsMgr monitoring class of which the perf collection rule is targeting

<strong>$RuleDisabled</strong> – Boolean variable (true or false). specify if the rule should be left disabled by default

Runbook execution result:

<a href="http://blog.tyang.org/wp-content/uploads/2015/08/image2.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/08/image_thumb2.png" alt="image" width="547" height="542" border="0" /></a>

Rule configuration (from the console):

<a href="http://blog.tyang.org/wp-content/uploads/2015/08/image3.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/08/image_thumb3.png" alt="image" width="310" height="324" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2015/08/image4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/08/image_thumb4.png" alt="image" width="626" height="331" border="0" /></a>

Accessing Perf data collected by this rule in a Perf view:

<a href="http://blog.tyang.org/wp-content/uploads/2015/08/SNAGHTMLb5a869e.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLb5a869e" src="http://blog.tyang.org/wp-content/uploads/2015/08/SNAGHTMLb5a869e_thumb.png" alt="SNAGHTMLb5a869e" width="590" height="446" border="0" /></a>
<h3>Conclusion</h3>
In this post, I have demonstrated how to use a runbook to create a performance collection rule in OpsMgr. In the next post, I will demonstrate how to create a 2-state performance monitor.