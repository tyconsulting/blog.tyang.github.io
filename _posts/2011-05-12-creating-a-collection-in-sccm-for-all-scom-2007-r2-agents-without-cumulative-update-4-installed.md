---
id: 507
title: 'Creating a collection in SCCM for &#8220;all SCOM 2007 R2 agents without Cumulative Update 4 installed&#8221;'
date: 2011-05-12T17:59:27+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=507
permalink: /2011/05/12/creating-a-collection-in-sccm-for-all-scom-2007-r2-agents-without-cumulative-update-4-installed/
categories:
  - SCCM
  - SCOM
tags:
  - SCCM
  - SCOM
  - SCOM Cumulative Update Install
---
Recently I’ve been working on deploying a SCOM environment to monitor SCCM infrastructure.

Initially we used SCCM to deploy SCOM agents out to all SCCM servers as it is our preferred method to deploy any apps. By doing so, SCOM agents are considered “Manually Installed” in SCOM, therefore I cannot simply approve updates in SCOM console and get it pushed out in SCOM.

I needed to make a collection for all computers that have SCOM 2007 R2 agents installed but without CU4 so it can be used to deploy CU4 to SCOM agents.

Here’s the query:

<strong>Description:</strong> All computers that has “System Center Operations Manager 2007 R2 Agent” installed AND MonitoringHost.exe version is not 6.1.7221.61

<strong>Requirement:</strong>

1. Hardware inventory includes Win32Reg_AddRemovePrograms and Win32_AddRemovePrograms64 classes (This is enabled by default)

2. Software inventory includes monitoringhost.exe (by default, *.exe is included)

<strong>Query:</strong>

<em><span style="font-size: xx-small;">
[sourcecode language="SQL"]
select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_ADD_REMOVE_PROGRAMS_64 on SMS_G_System_ADD_REMOVE_PROGRAMS_64.ResourceID = SMS_R_System.ResourceId inner join SMS_G_System_ADD_REMOVE_PROGRAMS on SMS_G_System_ADD_REMOVE_PROGRAMS.ResourceID = SMS_R_System.ResourceId inner join SMS_G_System_SoftwareFile on SMS_G_System_SoftwareFile.ResourceId = SMS_R_System.ResourceId where (SMS_G_System_ADD_REMOVE_PROGRAMS_64.DisplayName = &quot;System Center Operations Manager 2007 R2 Agent&quot; or SMS_G_System_ADD_REMOVE_PROGRAMS.DisplayName = &quot;System Center Operations Manager 2007 R2 Agent&quot;) and (SMS_G_System_SoftwareFile.FileName = &quot;MonitoringHost.exe&quot; and SMS_G_System_SoftwareFile.FileVersion != &quot;6.1.7221.61&quot;)
[/sourcecode]
</span></em>

Below is the result in my test environment:

<strong>Collection Membership in SCCM:</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2011/05/image1.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/05/image_thumb1.png" border="0" alt="image" width="383" height="159" /></a>

<strong>State View of Agent List with Patch List from SCOM:</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2011/05/image2.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/05/image_thumb2.png" border="0" alt="image" width="580" height="213" /></a>

&nbsp;

<strong>Note</strong>: By default, software inventory occurs every 7 days, the SCCM collection membership may not be 100% accurate because it relies on agent hardware and software inventory to feed the data.