---
id: 2859
title: SCOM 2012 Maintenance Mode Scheduler V3 from Tim McFadden
date: 2014-06-25T20:36:01+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=2859
permalink: /2014/06/25/scom-2012-maintenance-mode-scheduler-v3-tim-mcfadden/
categories:
  - SCOM
tags:
  - SCOM
---
Tim McFadden has just released the <a href="http://www.scom2k7.com/scom-2012-maintenance-mode-scheduler-v3/">SCOM 2012 Maintenance Mode Scheduler Version 3</a>.

<strong>New Dashboard</strong>

Tim and I updated the original management packs to cater for this release. The Dashboard MP has a new dashboard for version 3 which allows users to select a windows computer object from the state widget and create a maintenance mode schedule from the PowerShell contextual web browser widget:

<a href="http://blog.tyang.org/wp-content/uploads/2014/06/image6.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/06/image_thumb6.png" alt="image" width="580" height="590" border="0" /></a>

The new MPs are included in the msi. they are located in “C:\Program Files\SCOM 2012 Maintenance Mode Scheduler\Management Packs” folder once the msi is installed.

<strong>My Upgrade Experience</strong>

I upgraded all 4 instances at work today. While I was upgrading it, I noticed that after the in place upgrade, all the settings are gone. I had to re-enter the following information:
<ul>
	<li>Management Server address</li>
	<li>SQL Server Address</li>
	<li>Database Name</li>
	<li>SDK User name and password</li>
	<li>License Key</li>
	<li>various tick boxes from admin.aspx page.</li>
	<li>IIS .Net authorization rules</li>
</ul>
Therefore, to avoid unnecessary downtime, I’d recommend you to have all these information ready before the upgrade.

<strong>Tricks</strong>

Because we have multiple management groups at work, I have manually edited the WebHeader.png and WebHeader2.png files in “<strong>C:\inetpub\wwwroot\MMWeb\Content</strong>” and added a custom title on these image files so users can easily identify different instances for different management groups:

<a href="http://blog.tyang.org/wp-content/uploads/2014/06/SNAGHTML9f3c96.png"><img style="display: inline; border: 0px;" title="SNAGHTML9f3c96" src="http://blog.tyang.org/wp-content/uploads/2014/06/SNAGHTML9f3c96_thumb.png" alt="SNAGHTML9f3c96" width="532" height="288" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2014/06/SNAGHTMLa03202.png"><img style="display: inline; border: 0px;" title="SNAGHTMLa03202" src="http://blog.tyang.org/wp-content/uploads/2014/06/SNAGHTMLa03202_thumb.png" alt="SNAGHTMLa03202" width="520" height="410" border="0" /></a>