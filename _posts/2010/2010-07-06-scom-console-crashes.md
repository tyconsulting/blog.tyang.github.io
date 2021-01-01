---
id: 80
title: SCOM Console Crashes
date: 2010-07-06T11:28:10+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/2010/07/06/scom-console-crashes/
permalink: /2010/07/06/scom-console-crashes/
categories:
  - SCOM
tags:
  - Console Crash
  - SCOM
---
When I connect SCOM console to one of my clients SCOM 2007 R2 environment, under Authoring Pane, if I change the display scope of Monitors or Rules to "View all target" and select everything:

<a href="http://blog.tyang.org/wp-content/uploads/2010/07/image1.png"><img style="border: 0px;" src="http://blog.tyang.org/wp-content/uploads/2010/07/image_thumb1.png" border="0" alt="image" width="376" height="323" /></a>

the console crashes. – Maybe there are too many objects for it to handle.

<a href="http://blog.tyang.org/wp-content/uploads/2010/07/image2.png"><img style="border: 0px;" src="http://blog.tyang.org/wp-content/uploads/2010/07/image_thumb2.png" border="0" alt="image" width="326" height="146" /></a>

After the crash, when I re-launch the console, I cannot go back into Authoring Pane. It crashes everytime I click on "Authoring".

To fix it so I can go back to Authoring Pane, I had to delete this registry key:

<strong>HKEY_CURRENT_USER\Software\Microsoft\Microsoft Operations Manager\3.0\Console\Navigation\MonitoringConfigNavSettings\ScopedClasses</strong>

I started the console again after the deletion and I could go back in with the default setting!