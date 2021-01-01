---
id: 1278
title: Hyper-V Cluster Virtual Machines Current Cluster Node SCOM Monitor
date: 2012-07-14T13:35:41+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=1278
permalink: /2012/07/14/hyper-v-cluster-virtual-machines-current-cluster-node-scom-monitor/
categories:
  - SCOM
tags:
  - MP Authoring
  - SCOM
---
<a href="http://blog.tyang.org/wp-content/uploads/2012/07/HyperV.jpg"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; float: left; padding-top: 0px; border: 0px;" title="HyperV" src="http://blog.tyang.org/wp-content/uploads/2012/07/HyperV_thumb.jpg" alt="HyperV" width="244" height="101" align="left" border="0" /></a>First of all, apologies for not updating this blog for over a months. Life has been pretty busy outside of work. My wife gave birth to our first child a months ago and I’ve been flat out looking after our little girl Rosie <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" src="http://blog.tyang.org/wp-content/uploads/2012/07/wlEmoticon-smile.png" alt="Smile" />.

Apart from enjoying every moment with the little one while I’m at home, At work, I have been asked to provide a solution to an issue that bothers our infrastructure support team on daily basis.

<span style="font-size: medium;"><strong>Background</strong></span>

Windows 2008 R2 Hyper-V Clusters are heavily utilised in my employer’s infrastructure. There are over 700 2-node Hyper-V clusters operating in the environment. For more information about how the System Center suite operates in the environment, please refer to the Case Study from Microsoft <a href="http://www.microsoft.com/casestudies/Case_Study_Detail.aspx?CaseStudyID=710000000220">HERE</a>.

DPM 2010 is installed on each Hyper-V cluster node to back up each other and virtual machines. Support teams get many SCOM alerts from DPM management pack everyday complaining about failed virtual machine backups because the virtual machines are not located on the host. Therefore, we need to make sure virtual machines are hosted on the right host before DPM backups start.

<span style="font-size: medium;"><strong>Analysis</strong></span>

Initially, we thought this is going to be an easy fix. we could just set the preferred nodes for each VM in Failover Cluster manager and configure auto failback before backups start. However, we then realise auto failback does not <strong>live migrate</strong> VM’s. the VM’s are paused and therefore been taken offline during the migration process. So I implemented the fix via SCOM instead.

<span style="font-size: medium;"><strong>Outcome</strong></span>

Basically, I have created a monitor targeting Hyper-V clusters to run daily at 1:00am to detect if any virtual machine cluster resources are not hosted by (one of) their preferred nodes. If so, a diagnostic task runs to check if all cluster nodes are up (to make sure cluster is in a healthy state before live migrations). then based on the outcome of diagnostic task, a recovery task runs to migrate any VMs that are not on preferred host to the preferred host.

<span style="font-size: medium;"><strong>Management Pack Details</strong></span>

<strong>Class Definition</strong>
<ul>
	<li>Hyper-V Cluster (Base Class: Microsoft.Windows.Server.Computer)</li>
</ul>
<strong>Discovery:</strong>
<ul>
	<li>Hyper-V Cluster Discovery
<ul>
	<li>Script discovery. Any Windows Server Computers that meets following criteria:
<ol>
	<li>Windows Server Computer property “IsVirtualNode” = true (Windows cluster)</li>
	<li>service “vmms” (Hyper-V Virtual Machine Management service) exists</li>
	<li>The cluster contains “Virtual Machine” as a resource type.</li>
</ol>
</li>
</ul>
</li>
</ul>
<strong>Monitor:</strong>
<ul>
	<li>Hyper-V Virtual Machine Current Cluster Node Monitor
<ol>
	<li>Checks if virtual machines are hosted by one of their preferred hosts.</li>
	<li>Generates a critical alert when at least one virtual machine is not on preferred hosts.</li>
	<li>diagnostic task to check the status of each cluster node.</li>
	<li>if all cluster nodes are up, recovery task runs to live migrate virtual machines that are not on preferred host to (one of) their preferred hosts.</li>
</ol>
</li>
</ul>
<strong>Other Considerations:</strong>

I have created a custom probe action module to detect:
<ul>
	<li>Any VM’s on wrong hosts (not on preferred hosts)</li>
	<li>Any VM’s that are current on preferred hosts</li>
	<li>Any VM’s that do not have preferred hosts configured</li>
	<li>Are all VMs on preferred hosts (Boolean)</li>
	<li>Are all VMs have preferred hosts configured (Boolean)</li>
</ul>
This probe action module is then wrapped into a data source module and also been used in the monitor type for the  Hyper-V Virtual Machine Current Cluster Node Monitor. If later on we need to be alerted if any VM’s on those 700+ clusters don’t have preferred nodes configured, I can use the same probe action and data source module for the new monitor.

During the development of this Management Pack, this TechNet blog post really helped:

<a href="http://blogs.technet.com/b/authormps/archive/2011/03/13/your-mp-discoveries-and-clustering.aspx">Your MP Discoveries and Clustering</a>

<span style="font-size: medium;"><strong>Management Pack Download:</strong></span>

Download Both sealed and unsealed versions <a title="Hyper-V Cluster Management Pack" href="http://blog.tyang.org/wp-content/uploads/2012/07/HyperV.zip">HERE</a>.