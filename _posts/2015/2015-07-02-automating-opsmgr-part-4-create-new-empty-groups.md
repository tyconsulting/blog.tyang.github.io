---
id: 4119
title: 'Automating OpsMgr Part 4: Create New Empty Groups'
date: 2015-07-02T22:29:18+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=4119
permalink: /2015/07/02/automating-opsmgr-part-4-create-new-empty-groups/
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
This is the 4th instalment of the Automating OpsMgr series. Previously on this series:
<ul>
	<li><a href="http://blog.tyang.org/2015/06/24/automating-opsmgr-part-1-introducing-opsmgrextended-powershell-sma-module/">Automating OpsMgr Part 1: Introducing OpsMgrExtended PowerShell / SMA Module</a></li>
	<li><a href="http://blog.tyang.org/2015/06/28/automating-opsmgr-part-2-sma-runbook-for-creating-configmgr-log-collection-rules/">Automating OpsMgr Part 2: SMA Runbook for Creating ConfigMgr Log Collection Rules</a></li>
	<li><a href="http://blog.tyang.org/2015/06/30/automating-opsmgr-part-3-new-management-pack-runbook-via-sma-and-azure-automation/" target="_blank">Automating OpsMgr Part 3: New Management Pack Runbook via SMA and Azure Automation</a></li>
</ul>
When developing management packs, it is very common to define various groups that contain objects discovered by the management pack. The groups can be used for overrides, maintenance modes, reports, scoping user access, etc.

Generally speaking, there are 2 types of groups in OpsMgr: instance groups and computer groups. As the names suggested, instance groups can contain any types of instances in OpsMgr, and computer groups can only contain computer objects.

In the OpsMgr console, the easiest way to identify the group type is by the icon. i.e.

<a href="http://blog.tyang.org/wp-content/uploads/2015/07/image1.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; margin: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/07/image_thumb1.png" alt="image" width="174" height="52" border="0" /></a>

As you can see, the computer group has an additional computer in the icon.

There are 2 steps when creating a group:

1. Class definition - A singleton, unhosted group class representing the group itself. i.e.

<a href="http://blog.tyang.org/wp-content/uploads/2015/07/image2.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/07/image_thumb2.png" alt="image" width="600" height="243" border="0" /></a>

2. A discovery workflow which uses A Data Source module type called "Microsoft.SystemCenter.GroupPopulator" to populate the group membership. i.e.

<a href="http://blog.tyang.org/wp-content/uploads/2015/07/image3.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/07/image_thumb3.png" alt="image" width="602" height="368" border="0" /></a>

The class definition and the discovery can be defined in the same management pack, or different packs (i.e. Class definition in a sealed MP, and discovery MP can reference the sealed class definition MP). As you can see, the class definition for groups are really simple, but the discovery can sometimes get very complicated - all depending on your requirements.

When I was developing the OpsMgrExtended module, I have created 2 functions for group creations:
<ul>
	<li>New-OMInstanceGroup</li>
	<li>New-OMComputerGroup</li>
</ul>
As the names suggest, these 2 functions create new instance groups and computer groups respectively. But because the group populations can sometimes be tricky and complicated, after careful consideration, I have decided to code these 2 functions to only create empty groups and users will have to either manually populate the groups via the operations console, or developing their own runbooks to update the group discovery workflow.

So what does an empty group mean?

I simply coded the group populator data source to always return nothing by using a simple expression where True equals False (which would never happen):

<a href="http://blog.tyang.org/wp-content/uploads/2015/07/image4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; margin: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/07/image_thumb4.png" alt="image" width="244" height="127" border="0" /></a>

Since populating groups can get complicated, and I think it will be very useful for people to use the <strong>OpsMgrExtended</strong> module to create and manage groups, I will dedicate this post and the next few posts in this blog series on creating and managing groups. So, please consider this as the first episode of the "sub series". In this post, I will demonstrate a simple runbook that you can use to create instance groups and computer groups.
<h3>Runbook: New-Group</h3>
```powershell

Workflow New-Group
{
Param(
[Parameter(Mandatory=$true)][String]$GroupName,
[Parameter(Mandatory=$true)][String]$GroupDisplayName,
[Parameter(Mandatory=$true)][ValidateSet('InstanceGroup', 'Computergroup')][String]$GroupType,
[Parameter(Mandatory=$true)][String]$MPName
)

#Get OpsMgrSDK connection object
$OpsMgrSDKConn = Get-AutomationConnection -Name "OpsMgrSDK_TYANG"

#Validate MP
$ValidMP = InlineScript
{
$MP = Get-OMManagementPack -SDKConnection $USING:OpsMgrSDKConn -Name $USING:MPName
if ($MP.sealed)
{
$bValidMP = $false
Write-Error "Unable to create the group in a sealed management pack."
} else {
$bValidMP = $true
}
$bValidMP
}

If ($ValidMP)
{
$newGroup = InlineScript
{
if ($USING:GroupType -ieq "InstanceGroup")
{
New-OMInstanceGroup -SDKConnection $USING:OpsMgrSDKConn -MPName $USING:MPName -InstanceGroupName $USING:GroupName -InstanceGroupDisplayName $USING:GroupDisplayName -IncreaseMPVersion $true
} elseif ($USING:GroupType -ieq "ComputerGroup") {
New-OMComputerGroup -SDKConnection $USING:OpsMgrSDKConn -MPName $USING:MPName -ComputerGroupName $USING:GroupName -ComputerGroupDisplayName $USING:GroupDisplayName -IncreaseMPVersion $true
}
}
}

If ($newGroup)
{
Write-Output "Group `"$GroupName`" created."
} else {
Write-Error "Unable to create group `"$GroupName`"."
}
}

```
<h3>Executing Runbook</h3>
Creating Instance Group:

<a href="http://blog.tyang.org/wp-content/uploads/2015/07/image5.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/07/image_thumb5.png" alt="image" width="548" height="554" border="0" /></a>

Creating Computer Group:

<a href="http://blog.tyang.org/wp-content/uploads/2015/07/image6.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/07/image_thumb6.png" alt="image" width="491" height="598" border="0" /></a>
<h3>Results:</h3>
In Operations Console:

<a href="http://blog.tyang.org/wp-content/uploads/2015/07/image7.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/07/image_thumb7.png" alt="image" width="591" height="202" border="0" /></a>

Management Pack - Class Definition:

<a href="http://blog.tyang.org/wp-content/uploads/2015/07/image8.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/07/image_thumb8.png" alt="image" width="577" height="153" border="0" /></a>

Management Pack - Instance Group Discovery:

<a href="http://blog.tyang.org/wp-content/uploads/2015/07/image9.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/07/image_thumb9.png" alt="image" width="585" height="435" border="0" /></a>

Management Pack - Computer Group Discovery:

<a href="http://blog.tyang.org/wp-content/uploads/2015/07/image10.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/07/image_thumb10.png" alt="image" width="580" height="422" border="0" /></a>

Management Pack - Language Pack:

<a href="http://blog.tyang.org/wp-content/uploads/2015/07/image11.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/07/image_thumb11.png" alt="image" width="534" height="273" border="0" /></a>
<h3>Additional Readings</h3>
Over the years I've been working with OpsMgr, I've booked mark the following great blog articles on creating groups in OpsMgr. You might find some of them useful:
<ul>
	<li><a href="http://blogs.technet.com/b/jonathanalmquist/archive/2010/04/28/how-to-create-a-computer-group-in-the-r2-authoring-console.aspx" target="_blank">How to create a computer group in the R2 Authoring Console</a> - by Jonathan Almquist</li>
	<li><a href="http://blogs.technet.com/b/jonathanalmquist/archive/2010/05/08/how-to-create-an-instance-group-in-the-r2-authoring-console.aspx" target="_blank">How to create an instance group in the R2 Authoring Console</a> - by Jonathan Almquist</li>
	<li><a href="http://blogs.technet.com/b/kevinholman/archive/2010/07/27/authoring-groups-from-simple-to-complex.aspx" target="_blank">Authoring groups - from simple to complex</a> - by Kevin Holman</li>
	<li><a href="http://blogs.technet.com/b/kevinholman/archive/2014/01/13/creating-groups-of-computers-based-on-time-zone.aspx" target="_blank">Creating Groups of Computers based on Time Zone</a> - by Kevin Holman</li>
	<li><a href="http://blogs.technet.com/b/kevinholman/archive/2010/09/09/how-to-create-a-group-of-objects-that-are-contained-by-some-other-group.aspx" target="_blank">How to create a group of objects, that are CONTAINED by some other group</a> - by Kevin Holman</li>
	<li><a href="http://blogs.technet.com/b/brianwren/archive/2008/11/18/programmatically-creating-groups.aspx" target="_blank">Programmatically Creating Groups</a> - by Brian Wren</li>
	<li><a href="http://blogs.technet.com/b/brianwren/archive/2008/01/26/dynamically-populating-component-groups-in-distributed-applications.aspx" target="_blank">Dynamically populating component groups in Operations Manager 2007 Distributed Applications</a> - by Brian Wren</li>
	<li><a href="https://rburri.wordpress.com/2009/01/14/dynamic-group-membership-authoring-and-performance-impact-on-rms/" target="_blank">Dynamic group Membership authoring and performance impact on RMS</a> - by Raphael Burri</li>
	<li><a href="http://www.systemcentercentral.com/scom-advanced-group-population-formula-development-groupcalc-for-the-xml-impaired/" target="_blank">SCOM: Advanced Group Population Formula Development (GroupCalc) for the XML Impaired</a> - by Pete Zerger</li>
	<li><a href="http://blogs.msdn.com/b/jakuboleksy/archive/2007/05/22/more-on-group-membership-and-calculations.aspx" target="_blank">More on Group Membership and Calculations</a> - by Jakub Oleksy</li>
</ul>
Also, few previous posts from this blog:
<ul>
	<li><a href="http://blog.tyang.org/2015/01/18/creating-opsmgr-instance-group-computers-running-application-health-service-watchers/" target="_blank">Creating OpsMgr Instance Group for All Computers Running an Application and Their Health Service Watchers</a></li>
	<li><a href="http://blog.tyang.org/2014/04/23/using-computers-health-service-watchers-groups-management-group-containing-clusters/" target="_blank">Using Computers And Health Service Watchers Groups in a Management Group containing Clusters</a></li>
</ul>
<h3>Conclusion</h3>
In this post, I have demonstrated how to create computer groups and instance groups without any members. In the next post, I will demonstrate a runbook to add an explicit member to a computer group.