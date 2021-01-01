---
id: 756
title: 'SCOM Management Pack: Detecting USB Storage Device Connect and Disconnect Events'
date: 2011-10-23T19:56:07+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=756
permalink: /2011/10/23/scom-management-pack-detecting-usb-storage-device-connect-and-disconnect-events/
categories:
  - SCOM
tags:
  - Management Pack
  - SCOM
---
There was a requirement at work that people need to be notified when a USB storage device (USB key or portable USB hard disks) is connected or disconnected from SCOM monitored Windows computers.

So I wrote a 2 very simple alert generating rules to detect USB Mass Storage Device creation and deletion WMI event. I set both rules to run every 60 seconds so within 60 seconds of the event, an Information alert is generated in SCOM:

<strong>Alert for USB Storage Device Connection Event:</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2011/10/image15.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/10/image_thumb15.png" alt="image" width="580" height="582" border="0" /></a>

<strong>Alert for USB Storage Device Removal Event:</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2011/10/image16.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/10/image_thumb16.png" alt="image" width="580" height="496" border="0" /></a>

I have also created a dynamic group called Virtual Windows Computers in the MP so I can disable both rules for virtual machines. This is how I defined the group:

<a href="http://blog.tyang.org/wp-content/uploads/2011/10/image17.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/10/image_thumb17.png" alt="image" width="580" height="256" border="0" /></a>

Please note this Virtual Machine discovery only detects virtual machines running on Microsoft’s virtual host platform. If you open System Center Internal Library MP in MPViewer and check the Raw XML for discovery “<strong>Discover if Windows Computer is a Virtual Machine</strong>”, you’ll see it the WQL:

<a href="http://blog.tyang.org/wp-content/uploads/2011/10/image18.png"><img style="border: 0px currentColor; padding-top: 0px; padding-right: 0px; padding-left: 0px; display: inline; background-image: none;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/10/image_thumb18.png" alt="image" width="740" height="519" border="0" /></a>

So if you have non-Microsoft virtual machines (i.e. VMware) in your environment and you want to disable these 2 rules for those virtual machines, you will need to modify my group or create your own group in my management pack.

<strong>Download: <a href="http://blog.tyang.org/wp-content/uploads/2011/10/USB.Storage.Device.Detection.zip">USB Storage Device Detection Management Pack</a></strong>