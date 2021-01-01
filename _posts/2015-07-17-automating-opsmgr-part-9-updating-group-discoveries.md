---
id: 4257
title: 'Automating OpsMgr Part 9: Updating Group Discoveries'
date: 2015-07-17T22:54:10+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=4257
permalink: /2015/07/17/automating-opsmgr-part-9-updating-group-discoveries/
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
This is the 9th instalment of the Automating OpsMgr series. Previously on this series:
<ul>
	<li><a href="http://blog.tyang.org/2015/06/24/automating-opsmgr-part-1-introducing-opsmgrextended-powershell-sma-module/">Automating OpsMgr Part 1: Introducing OpsMgrExtended PowerShell / SMA Module</a></li>
	<li><a href="http://blog.tyang.org/2015/06/28/automating-opsmgr-part-2-sma-runbook-for-creating-configmgr-log-collection-rules/">Automating OpsMgr Part 2: SMA Runbook for Creating ConfigMgr Log Collection Rules</a></li>
	<li><a href="http://blog.tyang.org/2015/06/30/automating-opsmgr-part-3-new-management-pack-runbook-via-sma-and-azure-automation/">Automating OpsMgr Part 3: New Management Pack Runbook via SMA and Azure Automation</a></li>
	<li><a href="http://blog.tyang.org/2015/07/02/automating-opsmgr-part-4-create-new-empty-groups/">Automating OpsMgr Part 4:Creating New Empty Groups</a></li>
	<li><a href="http://blog.tyang.org/2015/07/06/automating-opsmgr-part-5-adding-computers-to-computer-groups/">Automating OpsMgr Part 5: Adding Computers to Computer Groups</a></li>
	<li><a href="http://blog.tyang.org/2015/07/13/automating-opsmgr-part-6-adding-monitoring-objects-to-instance-groups/">Automating OpsMgr Part 6: Adding Monitoring Objects to Instance Groups</a></li>
	<li><a href="http://blog.tyang.org/2015/07/17/automating-opsmgr-part-7-updated-opsmgrextended-module/">Automating OpsMgr Part 7: Updated OpsMgrExtended Module</a></li>
	<li><a href="http://blog.tyang.org/2015/07/17/automating-opsmgr-part-8-adding-management-pack-references/" target="_blank">Automating OpsMgr Part 8: Adding Management Pack References</a></li>
</ul>
OK, now I've got all the darts lined up (as per part 7 and 8), I can talk about how to update group discovery configurations.

Often when you create groups, the groups are configured to have dynamic memberships. for example, as I previously blogged <a href="http://blog.tyang.org/2015/01/18/creating-opsmgr-instance-group-computers-running-application-health-service-watchers/" target="_blank">Creating OpsMgr Instance Groups for All Computers Running an Application and Their Health Service Watchers</a>.

In this post, I will demonstrate once you've created an empty group (as shown in Part 4), how can you use OpsMgrExtended module to modify the group discovery data source, so the group will dynamically include all objects that meet the criteria (Membership rules).

Because this is not something you'd use as a standalone solution, I will not provide sample runbooks, but instead, just walk through the PowerShell code.
<h3>Example Walkthrough</h3>
In this demonstration, I have firstly created a blank management pack, and then use the runbook demonstrated in Part 4, and created an empty instance group. At this stage, the management pack looks like this:

<a href="http://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTML236ed3d.png"><img class="" style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML236ed3d" src="http://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTML236ed3d_thumb.png" alt="SNAGHTML236ed3d" width="740" height="933" border="0" /></a>

My goal is to update this group to include all objects of the Hyper-V host class that is defined in the VMM 2012 discovery MP ("Microsoft.SystemCenter.VirtualMachineManager.2012.Discovery"). The configuration for the group discovery data source module would need to be something like this:

<a href="http://blog.tyang.org/wp-content/uploads/2015/07/image32.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/07/image_thumb32.png" alt="image" width="720" height="174" border="0" /></a>

As I explained in the previous post (Part 8), because the Hyper-V Host class is defined in the VMM MP, in order to build our discovery data source, the unsealed MP of which the group discovery is defined must reference the VMM discovery MP. As you can see from the management pack XML screenshot, the VMM discovery MP is not currently referenced there. As I've also shown in the new group discovery data source configuration that I'm about to put in, the VMM discovery MP need to be referenced as alias "MSV2D" (as highlighted). of course you can pick another alias name, but the group discovery data source config must align with whatever alias you've chosen.

So, in order to achieve my goal, I must firstly create a MP reference for the VMM discovery MP, then I will be able to update the group discovery data source.

Here's the PowerShell script:
<pre language="Powershell" class="">#Group Name
$GroupName = "Group.Creation.Demo.Demo.Instance.Group"

#Define New group discovery data source configuration (MUST use single quote)
$NewConfiguration = @'
<RuleId>$MPElement$</RuleId>
<GroupInstanceId>$MPElement[Name="Group.Creation.Demo.Demo.Instance.Group"]$</GroupInstanceId>
<MembershipRules>
<MembershipRule>
<MonitoringClass>$MPElement[Name="MSV2D!Microsoft.SystemCenter.VirtualMachineManager.2012.HyperVHost"]$</MonitoringClass>
<RelationshipClass>$MPElement[Name="SCIG!Microsoft.SystemCenter.InstanceGroupContainsEntities"]$</RelationshipClass>
</MembershipRule>
</MembershipRules>
'@

#Firstly add the MP reference for VMM Discovery MP
$AddMPRef = New-OMManagementPackReference -SDK OpsMgrMS01 -ReferenceMPName "Microsoft.SystemCenter.VirtualMachineManager.2012.Discovery" -Alias "MSV2D" -UnsealedMPName “Group.Creation.Demo” -Verbose

#Updating the discovery DS using the Update-OMGroupDiscovery function
$UpdateResult = Update-OMGroupDiscovery -SDK OpsMgrMS01 -GroupName $GroupName -NewConfiguration $NewConfiguration -IncreaseMPVersion $true -verbose

#Display the result (True = updated successful
$UpdateResult
</pre>
Please note, I'm specifying the management server name instead of the SMA connection object in this example, if you are using it in SMA or Azure Automation, you can also switch -SDK to -SDKConnection and pass a connection object to the functions.

The script is very self explanatory, with 2 catches:
<ul>
	<li>the group discovery DS configuration is defined in a multi-line string variable, you <strong>MUST</strong> use single quotation marks (@<strong><span style="color: #ff0000;">'</span> </strong>and <strong><span style="color: #ff0000;">'</span></strong>@) for this variable, because the dollar sign ($) is a reserved character in PowerShell, if you use double quotes, you must also place an escape character ("`") in front of every dollar sign, with can be very time consuming.</li>
	<li>You must use the version 1.1 of the OpsMgrExtended module (published in part 7 earlier today). The Update-OMGroupDiscovery function is a new addition in version 1.1, and New-OMManagementPackReference had a small bug that was also fixed in version 1.1.</li>
</ul>
Since I've added -Verbose switch when calling both functions, I can also see some verbose output:

<a href="http://blog.tyang.org/wp-content/uploads/2015/07/image33.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/07/image_thumb33.png" alt="image" width="732" height="177" border="0" /></a>

And now, if I check the group I've just updated, the MP reference is added:

<a href="http://blog.tyang.org/wp-content/uploads/2015/07/image34.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/07/image_thumb34.png" alt="image" width="595" height="601" border="0" /></a>

and the original empty discovery rule was replaced with what I specified in the script:

<a href="http://blog.tyang.org/wp-content/uploads/2015/07/image35.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/07/image_thumb35.png" alt="image" width="713" height="202" border="0" /></a>

Now when I check the group membership in the console, I can see all the Hyper-V hosts in my lab:

<a href="http://blog.tyang.org/wp-content/uploads/2015/07/image36.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/07/image_thumb36.png" alt="image" width="488" height="214" border="0" /></a>
<h3>Conclusion</h3>
In this post, I have demonstrated how to use OpsMgrExnteded module to update a group discovery data source configuration. Although I've only provided 1 example, for an instance group, the process for updating computer groups are pretty much the same. In next post, I will demonstrate how to delete a group using the OpsMgrExtended module.