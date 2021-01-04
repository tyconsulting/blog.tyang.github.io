---
id: 2702
title: Management Pack for the SCOM 2012 Maintenance Mode Scheduler
date: 2014-05-22T19:15:58+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=2702
permalink: /2014/05/22/management-pack-scom-2012-maintenance-mode-scheduler/
categories:
  - SCOM
tags:
  - Featured
  - MP Authoring
  - SCOM
---
I’ve been working on a SCOM management pack during my spare time over the last couple of weeks. This management pack provides some basic monitoring for the SCOM 2012 Maintenance Mode Scheduler Version 2 developed by Tim McFadden (<a title="http://www.scom2k7.com/scom-2012-maintenance-mode-scheduler-2/" href="http://www.scom2k7.com/scom-2012-maintenance-mode-scheduler-2/">http://www.scom2k7.com/scom-2012-maintenance-mode-scheduler-2/</a>).

The purpose of this MP solution is to help this web-based maintenance mode scheduler integrate better within SCOM. The solution contains 2 management pack files. The following items are included:

<strong>Class definitions and discoveries for the SCOM 2012 Maintenance Mode Scheduler.</strong>

The monitoring MP defines 2 classes. a Microsoft.Windows.ComputerRole based class called "SCOM 2012 Maintenance Mode Scheduler", which has many properties defined representing various application settings.

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/image9.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/05/image_thumb9.png" alt="image" width="415" height="302" border="0" /></a>

There is also an unhosted class called "SCOM 2012 Maintenance Mode Scheduler Event Collector". This class runs an event collection rule which collects the new schedule jobs creation events even when the Maintenance Mode Scheduler computer is in maintenance mode.

<strong>Automatically delete any finished maintenance mode schedules</strong>

A rule runs once a day and executes a script to scan through all Windows Scheduled Tasks created by the maintenance mode scheduler and deletes any tasks that does not have a Next Run Time (i.e. tasks that only runs once and it has already be executed). For auditing purposes, when deleting each old (finished) task, an event is also written to both SCOM operational and Data Warehouse databases.

The purpose of this rule is to eliminate the needs for manual clean-up of old scheduled tasks created by the maintenance mode scheduler.

<strong>Event Collection rule for new schedule job creation events (Event ID 711)</strong>

When the Maintenance Mode Scheduler is configure to write auditing events to Windows event log, a event collection rule can be utilized to collect these events and store them in SCOM databases.

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/image10.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/05/image_thumb10.png" alt="image" width="244" height="243" border="0" /></a> <a href="http://blog.tyang.org/wp-content/uploads/2014/05/image11.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/05/image_thumb11.png" alt="image" width="329" height="232" border="0" /></a>

<strong>Monitor the credential of SCOM Data Access Account configured in the maintenance mode scheduler.</strong>

A monitor that checks if the credential of the SCOM Data Access Account configured in SCOM 2012 Maintenance Mode Scheduler is still valid. This is to ensure SCOM operators get notified if the Data Access account password has been changed, or the account has been locked out, disabled or deleted.

<strong>Monitor if the SCOM Data Access Account has local administrator privilege on the computer hosting the maintenance mode scheduler.</strong>

A monitor that checks if the SCOM Data Access Account configured in SCOM 2012 Maintenance Mode Scheduler has local administrator privilege on the computer hosting the scheduler. Windows local administrator access is required to create Windows Scheduled task.

<strong>Console task to launch the SCOM 2012 Maintenance Mode Scheduler web site using the default web browser.</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/image12.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/05/image_thumb12.png" alt="image" width="580" height="366" border="0" /></a>

<strong>New scheduler jobs event report</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/image13.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/05/image_thumb13.png" alt="image" width="553" height="611" border="0" /></a>

<strong>Maintenance Mode Scheduler dashboard (Provided by the SCOM 2012 Maintenance Mode Scheduler Dashboard management pack).</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/image14.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/05/image_thumb14.png" alt="image" width="580" height="426" border="0" /></a>

This dashboard contains:
<ul>
	<li>Maintenance Mode Scheduler state widget</li>
	<li>PowerShell Grid widget that lists new schedule jobs events</li>
	<li>PowerShell Web Browser widget that displays the Maintenance Mode Scheduler web page.</li>
</ul>
<strong>Maintenance Mode Scheduler State view</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML199224ed.png"><img style="display: inline; border: 0px;" title="SNAGHTML199224ed" src="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML199224ed_thumb.png" alt="SNAGHTML199224ed" width="580" height="321" border="0" /></a>

<strong>New Jobs Event View</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML1992f8d7.png"><img style="display: inline; border: 0px;" title="SNAGHTML1992f8d7" src="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML1992f8d7_thumb.png" alt="SNAGHTML1992f8d7" width="580" height="402" border="0" /></a>

<strong>Deleted Jobs Event view</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML19946112.png"><img style="display: inline; border: 0px;" title="SNAGHTML19946112" src="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML19946112_thumb.png" alt="SNAGHTML19946112" width="518" height="458" border="0" /></a>

<strong>Credit</strong>

I’d like to thank Tim McFadden for producing such a good maintenance mode tool for SCOM 2012, and also the valuable feedbacks and suggestions provided for this management pack.

<strong>Conclusion</strong>

For me, while I was writing this MP, I’ve accomplished few of my "firsts":
<ul>
	<li>First time writing scripts for IIS (as this is a web based application).</li>
	<li>First time writing reports in VSAE (I have to say for me, it is much easier than using old Authoring console)</li>
	<li>First time using the new PowerShell widgets from the SCOM 2012 R2 UR2 updates (well, they’ve only just come out).</li>
</ul>
So I was really enjoying it, although it took a lot longer than what I expected (due to the IIS scripting challenges I had).

I hope this management pack would help the community to better adopt and integrate the SCOM 2012 Maintenance Mode Scheduler into their SCOM 2012 environments.

The Management packs and documentation can be downloaded <strong><a href="http://blog.tyang.org/wp-content/uploads/2014/05/SCOM2012.Maintenance.Mode_.Scheduler.V.1.0.0.0.zip">HERE</a></strong>. Please make sure you read the documentation before importing the MPs. there are few pre-requisites for the MPs.

Lastly, as always, please feel free to contact me if you have issues / questions / suggestions.