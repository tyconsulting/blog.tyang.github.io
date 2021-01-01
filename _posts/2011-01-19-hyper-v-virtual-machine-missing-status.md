---
id: 360
title: 'Hyper-V virtual machines with &#8220;Missing&#8221; status'
date: 2011-01-19T21:10:05+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=360
permalink: /2011/01/19/hyper-v-virtual-machine-missing-status/
categories:
  - Hyper-V
tags:
  - Hyper-V
---
I’m currently running Hyper-V R2 on a machine with 24GB of memory at home. It hosts most of my test machines such as SCCM, SCOM, Exchange, etc. System Center Virtual Machine Manager 2008 R2 (VMM) is installed on a separate box to manage this Hyper-V Host.

Few days ago the Hyper-V machine was powered off unexpectly and when it powered back online, in VMM, the status of 2 virtual machines showed as "Missing".

I checked the location where virtual machines are stored and without doubt, the vhd, xml and other files for each virtual machine are still there.

I Checked the Event Log and found a lot of Event ID 16310 events in Hyper-V-VMMS logs:

<a href="http://blog.tyang.org/wp-content/uploads/2011/01/image3.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/01/image_thumb3.png" border="0" alt="image" width="576" height="402" /></a>

The virtual machine ID in above event belongs to my SCOM server, one of the "Missing" virtual machines.

I googled it and some people somewhere had similar issues and it was because the VM configuration XML file was missing the closing tag "&lt;/Configuration&gt;" or there were few additional lines after "&lt;/Configuration&gt;".

In my case, the XML file looks perfectly fine, BUT there is an additional space(" ") after &lt;/Configuration&gt;:

<a href="http://blog.tyang.org/wp-content/uploads/2011/01/image4.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/01/image_thumb4.png" border="0" alt="image" width="580" height="134" /></a>

After removing the additional space and restarted Hyper-V Virtual Machine Management service (net stop vmms && net start vmms), the status of my SCOM server is "Stopped" and I was able to successfully start it!