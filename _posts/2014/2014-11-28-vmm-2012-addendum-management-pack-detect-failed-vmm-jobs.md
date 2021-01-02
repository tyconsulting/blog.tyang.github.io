---
id: 3402
title: 'VMM 2012 Addendum Management Pack: Detect Failed VMM Jobs'
date: 2014-11-28T21:23:13+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=3402
permalink: /2014/11/28/vmm-2012-addendum-management-pack-detect-failed-vmm-jobs/
categories:
  - SCOM
  - SCVMM
tags:
  - Management Pack
  - SCOM
  - VMM
---

## Background

My MVP friend <a href="http://flemmingriis.com/">Flemming Riis</a> needed OpsMgr to alert on failed VMM jobs. After discovering that the native VMM MPs don’t have a workflow for this, I have offered my help and built this addendum MP to alert failed and warning (Completed w/ Info) VMM jobs:

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/image22.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/11/image_thumb22.png" alt="image" width="684" height="307" border="0" /></a>

I thought it is going to be a quick task, turned out, I started writing this MP about 1 month ago and only able to release it now!

The actual MP is pretty simple, 2 rules sharing a same data source which executes a PowerShell script to detect any failed and warning jobs in VMM. I wrote the initial version in few hours and sent it to Flemming and <a href="http://www.systemcenter.ninja/">Steve Beaumont</a>  to test in their environments right before the MVP Summit. After the summit, we found out the MP didn’t work in their clustered VMM environments. We then spent a lot of time emailing back and forth trying to figure out what the issue was. In the end, I had to <a href="http://blog.tyang.org/2014/11/19/installing-vmm-2012-r2-cluster-lab/">build a VMM cluster in my lab</a> in order to test and troubleshoot it <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" src="http://blog.tyang.org/wp-content/uploads/2014/11/wlEmoticon-smile1.png" alt="Smile" />.

**So, BIG BIG "Thank You" to both Flemming and Steve for their time and effort on this MP. It is certainly a team effort!**

## MP Pre-Requisites

This MP has 2 pre-requisites:

* PowerShell script execution must be allowed on VMM servers and the VMM PowerShell module must be installed on the VMM server (It should by default).
* The VMM server must be fully integrated with OpsMgr (configure via VMM console). This integration is required because this integration creates RunAs account to run workflows in native VMM management pack. This Addendum management pack also utilise this RunAs account.

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/SNAGHTML42d92eab.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML42d92eab" src="http://blog.tyang.org/wp-content/uploads/2014/11/SNAGHTML42d92eab_thumb.png" alt="SNAGHTML42d92eab" width="575" height="475" border="0" /></a>

## Alert Rules:

This MP contains 2 alert rules:

* Virtual Machine Manager Completed w/ Info Job Alert Rule (Disabled by default)
* Virtual Machine Manager Failed Job Alert Rule (Enabled by default)

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/image23.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/11/image_thumb23.png" alt="image" width="551" height="207" border="0" /></a>

Both rules shares a same data source with same configuration parameters values (to utilise Cook Down). They are configured to run on a schedule and detects failed / warning jobs since the beginning of the rule execution cycle. i.e. by default, they run every 3 minutes, so they would detect any unsuccessful jobs since 3 minutes ago. An alert is generated for EVERY unsuccessful job:

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/SNAGHTML42e07b14.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML42e07b14" src="http://blog.tyang.org/wp-content/uploads/2014/11/SNAGHTML42e07b14_thumb.png" alt="SNAGHTML42e07b14" width="553" height="337" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/SNAGHTML42e1b950.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML42e1b950" src="http://blog.tyang.org/wp-content/uploads/2014/11/SNAGHTML42e1b950_thumb.png" alt="SNAGHTML42e1b950" width="556" height="338" border="0" /></a>

**<span style="font-size: medium;">Note:</span> **Please keep in mind, If you enable the "Completed w/ Info job alert rule", because we utilise Cook Down in these 2 rules, if you need to override the data source configuration parameters (IntervalSeconds, SyncTime, TimeoutSeconds), please override BOTH rules and assign same values to them so the script in the data source module only need to run once in every cycle and feed the output to both workflows.

## Download

Since it’s a really simple MP, I didn’t bother to write a proper documentation for this, it’s really straight forward, I think I have already provided enough information in this blog post.

Please test and tune it according to your requirements before implementing it in your production environments.

**<span style="font-size: medium;"><a href="http://blog.tyang.org/wp-content/uploads/2014/11/System.Center.VMM2012.Addendum.zip">Download Link</a></span>**

Lastly, I’d like to thank Steve and Flemming again for their time and effort on this MP. If you have any questions in regards to this MP, please feel free to send me an email.