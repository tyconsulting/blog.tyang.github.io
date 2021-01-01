---
id: 678
title: Event ID 29104 on SCOM RMS cluster
date: 2011-09-30T21:59:20+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=678
permalink: /2011/09/30/event-id-29104-on-scom-rms-cluster/
categories:
  - SCOM
tags:
  - SCOM; RMS Cluster
---
First of all, apologies for not been able to blog for over a month. I changed jobs. I started my new job 4 weeks ago, with all the things going on, I couldn’t find time to sit down and write blog articles. I am now working in a large “System Center Shop” which consists of SCCM, SCOM, SCVMM, Opalis, SCDPM and Hyper-V that spread over Australia national wide. so hopefully, my future blogs will have posts related to other System Center products as I get my hands on these products, not just SCCM and SCOM.

Anyways, in the last couple of days, I noticed on the 2-Node RMS cluster at work, when RMS is running on Node B, Event ID 29104 is logged in Operations Manager event log:

<strong><em>“OpsMgr Config Service failed to send the dirty state notifications to the dirty OpsMgr Health Services. This may be happening because the Root OpsMgr Health Service is not running.”</em></strong>

<a href="http://blog.tyang.org/wp-content/uploads/2011/09/image.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/09/image_thumb.png" alt="image" width="580" height="333" border="0" /></a>

This event was only generated when RMS was running on Node B, also, when Node B was the active node, RMS health state was greyed out in SCOM console. If I fail over RMS to Node A, everything is fine.

After spent some time troubleshooting the issue, I have found there are some registry keys mismatch between 2 nodes, they are under <strong>HKLM\SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Server Management Groups\<em>&lt;Management Group Name&gt;</em>\</strong>

On node B, “IsRootHealthService” is set to 0, Node A is set to “1”

<a href="http://blog.tyang.org/wp-content/uploads/2011/09/image1.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/09/image_thumb1.png" alt="image" width="580" height="158" border="0" /></a>

Also on node B, there is a set of sub keys “Parent Health Services”. this set of keys should not exist in RMS:

<a href="http://blog.tyang.org/wp-content/uploads/2011/09/image2.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/09/image_thumb2.png" alt="image" width="580" height="170" border="0" /></a>

So, to fix the issue, I firstly failed over RMS to node A, then changed “IsRootHealthService” on node B to “1” and deleted “Parent Health Services” key from node B. After that, I failed RMS back to node B, the 29104 events were no longer been logged and the RMS health state is not grey anymore.

<span style="color: #ff0000;">Again, I did not consult Microsoft on this one, please take a back up of the registry keys before you change it and I am not responsible for any damages it may cause.</span>