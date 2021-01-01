---
id: 5870
title: Command Launching Microsoft Monitoring Agent Control Panel Applet
date: 2017-01-17T20:56:54+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=5870
permalink: /2017/01/17/command-launching-microsoft-monitoring-agent-control-panel-applet/
categories:
  - OMS
  - SCOM
tags:
  - OMS
  - SCOM
---
I have been refreshing my lab servers to Windows Server 2016. I’m using the Non GUI version (Server Core) wherever is possible.

When working on Server Core servers, I found it is troublesome that I can’t access the Microsoft Monitoring Agent applet in Control Panel:

<a href="http://blog.tyang.org/wp-content/uploads/2017/01/image-8.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2017/01/image_thumb-8.png" alt="image" width="348" height="314" border="0" /></a>

Although I can use PowerShell and the MMA agent COM object AgentConfigManager.MgmtSvcCfg, Sometime it is easier to use the applet.

After some research, I found the applet can be launched using command line:
<pre language="batch">C:\Program Files\Microsoft Monitoring Agent\Agent\AgentControlPanel.exe
</pre>
<a href="http://blog.tyang.org/wp-content/uploads/2017/01/image-9.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2017/01/image_thumb-9.png" alt="image" width="500" height="428" border="0" /></a>