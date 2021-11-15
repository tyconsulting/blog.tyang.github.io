---
id: 80
title: SCOM Console Crashes
date: 2010-07-06T11:28:10+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/2010/07/06/scom-console-crashes/
permalink: /2010/07/06/scom-console-crashes/
categories:
  - SCOM
tags:
  - Console Crash
  - SCOM
---
When I connect SCOM console to one of my clients SCOM 2007 R2 environment, under Authoring Pane, if I change the display scope of Monitors or Rules to "View all target" and select everything:

![](https://blog.tyang.org/wp-content/uploads/2010/07/image1.png)


the console crashes. – Maybe there are too many objects for it to handle.

![](https://blog.tyang.org/wp-content/uploads/2010/07/image2.png)

After the crash, when I re-launch the console, I cannot go back into Authoring Pane. It crashes everytime I click on "Authoring".

To fix it so I can go back to Authoring Pane, I had to delete this registry key:

**HKEY_CURRENT_USER\Software\Microsoft\Microsoft Operations Manager\3.0\Console\Navigation\MonitoringConfigNavSettings\ScopedClasses**

I started the console again after the deletion and I could go back in with the default setting!