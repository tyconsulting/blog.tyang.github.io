---
id: 2680
title: Microsoft Surface Has Been Discovered as Virtual Machine in OpsMgr
date: 2014-05-17T20:21:08+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=2680
permalink: /2014/05/17/microsoft-surface-discovered-virtual-machine-opsmgr/
categories:
  - SCOM
tags:
  - SCOM
---
I have my Surface Pro 2 being monitored by the OpsMgr management group in my lab. Today I noticed it has been discovered as a virtual machine in OpsMgr:

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML161a72.png"><img style="display: inline; border: 0px;" title="SNAGHTML161a72" src="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML161a72_thumb.png" alt="SNAGHTML161a72" width="580" height="438" border="0" /></a>

The discovery for this property uses a WMI query:

<strong>Select Name FROM Win32_BaseBoard WHERE Manufacturer = “Microsoft Corporation”</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/image7.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/05/image_thumb7.png" alt="image" width="510" height="419" border="0" /></a>

And I queried Win32_BaseBoard class on my surface:

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/image8.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/05/image_thumb8.png" alt="image" width="538" height="191" border="0" /></a>

If you also have Surface monitored by OpsMgr and there are groups being populated based on the “Virtual Machine” property of Windows Computer class, you may want to modify the group populator expression.