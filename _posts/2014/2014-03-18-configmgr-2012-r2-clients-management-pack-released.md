---
id: 2400
title: ConfigMgr 2012 (R2) Clients Management Pack Released
date: 2014-03-18T21:42:20+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=2400
permalink: /2014/03/18/configmgr-2012-r2-clients-management-pack-released/
categories:
  - SCCM
  - SCOM
tags:
  - Featured
  - MP Authoring
  - SCCM
  - SCOM
---
<a href="https://blog.tyang.org/wp-content/uploads/2013/08/SCCM-Client-Monitor.png"><img class="alignleft  wp-image-2124" alt="ConfigMgr 2012 Client MP Icon" src="https://blog.tyang.org/wp-content/uploads/2013/08/SCCM-Client-Monitor.png" width="215" height="215" /></a>Time flies, I can’t believe it’s been over 7 months since I posted the <a href="https://blog.tyang.org/2013/08/31/management-pack-configmgr-2012-clients-testers-wanted/">beta version of the ConfigMgr 2012 client MP</a> for testing. I haven’t forgotten about this MP (because it’s one of the deliverables for the System Center 2012 upgrade project that I’ve been working on for the last 12 months or so). Today, I finally managed to finish updating this MP, it is ready for final release (Version 1.0.1.0).

I didn’t manage to get many feedbacks since the beta version was released. so it’s either a good thing that everyone’s happy about it, or it’s really bad that no one bothered to use it :smiley: . I would hope it’s because that everyone’s happy about it :smiley:

Anyways, below is a list of what’s changed.

<strong>Display Name for the ConfigMgr 2012 Client Agents are changed.</strong>

in beta version, the display names various client agents(DCM agents, Hardware Inventory agents, etc.) were hardcoded to the client agent name:

<a href="https://blog.tyang.org/wp-content/uploads/2014/03/image.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2014/03/image_thumb.png" width="573" height="165" border="0" /></a>

I don’t believe it is too user friendly when working in the Operations Console, so in this version, I’ve changed them to be the actual computer name:

<a href="https://blog.tyang.org/wp-content/uploads/2014/03/image1.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2014/03/image_thumb1.png" width="580" height="153" border="0" /></a>

<strong>Bug Fix: Incorrect Member Monitors for various client agents dependency monitors.</strong>

I made a mistake when writing the client agents dependency monitor’s snippet template in VSAE. As the result, all dependency monitors (for availability, performance, configuration and security health) had client agents availability health aggregate monitors as member monitors.

<a href="https://blog.tyang.org/wp-content/uploads/2014/03/image2.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2014/03/image_thumb2.png" width="378" height="403" border="0" /></a>

This is now fixed. the correct member monitor is assigned to each dependency monitor.

<a href="https://blog.tyang.org/wp-content/uploads/2014/03/image3.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2014/03/image_thumb3.png" width="376" height="462" border="0" /></a>

<strong>ConfigMgr 2012 Client object is no longer discovered on cluster instances.</strong>

When I was working on the beta version, the development management group that I was using did not have any failover clusters. I didn’t realise the ConfigMgr 2012 Client object is being discovered on cluster instances (virtual nodes) until I imported the MPs into our proper test environment. So this is something that has been overlooked. It is fixed now, it will not discover ConfigMgr 2012 Client (and any client agents) on clusters.

<strong>The "ConfigMgr 2012 Client All Programs Service Window Monitor" is now disabled by default.</strong>

I’m not too sure how many environments will have a maintenance window (service window) created for all clients. Therefore I’ve disabled this monitor. this is to ensure it will not flood SCOM by generating an alert for each ConfigMgr client. If it is required for all or a subset of ConfigMgr clients, it can be enabled via overrides.

<strong>Few spelling mistakes in alerts descriptions are corrected.</strong>

Finally, since the beta version was released prior to System Center 2012 R2 release, I have also tested the this MP on ConfigMgr 2012 R2 environment, it is 100% compatible without any modifications.

It can be downloaded <a href="https://blog.tyang.org/wp-content/uploads/2014/03/ConfigMgr-2012-Client-MP-V1.0.1.0.zip"><strong>HERE</strong></a>. As always, please feel free to contact me if you have any issues or suggestions.

<span style="color: #ff0000;"><strong>12th April, 2014 Update:</strong></span> <a href="http://cloudadministrator.wordpress.com/">Stanislav Zhelyazkov</a> found the override MP packed in the zip file is not correct. It did not have any references to other sealed MP. Not sure what happened when I preparing the zip file. Anyways, If you intend to use the unsealed override MP, please use <a href="https://blog.tyang.org/wp-content/uploads/2014/04/ConfigMgr.2012.Client.Overrides.zip">this one</a> instead.