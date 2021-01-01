---
id: 2092
title: Using OpsMgr to Detect SMB (Shared Folders) Connections to Windows Computers
date: 2013-08-22T21:10:33+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=2092
permalink: /2013/08/22/using-opsmgr-to-detect-smb-shared-folders-connections-to-windows-computers/
categories:
  - SCOM
tags:
  - MP Authoring
  - SCOM
---
I wrote this simple management pack couple of weeks ago to detect new SMB (Shared Folders) connection as well as disconnection events on OpsMgr agents.

The MP contains two (2) WMI event rules, one for new connection event and one for disconnection event. Each rule generates a Informational alert:

New Connection alert:

<a href="http://blog.tyang.org/wp-content/uploads/2013/08/image18.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/08/image_thumb18.png" width="580" height="186" border="0" /></a>

Disconnection Alert:

<a href="http://blog.tyang.org/wp-content/uploads/2013/08/image19.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/08/image_thumb19.png" width="580" height="203" border="0" /></a>

I’ve used the Microsoft.Windows.WmiEventProvider.EventProvider module as the data source module for both rules. The WMI queries used for these rules are:

<strong>New Connection Rule:</strong>

[sourcecode language="SQL"]
Select * from __InstanceCreationEvent within 1 where TargetInstance ISA 'Win32_ServerConnection' and TargetInstance.ShareName !='IPC$'
[/sourcecode]

&nbsp;

<strong>Disconnection Rule:</strong>

[sourcecode language="SQL"]
Select * from __InstanceDeletionEvent within 1 where TargetInstance ISA 'Win32_ServerConnection' and TargetInstance.ShareName !='IPC$'
[/sourcecode]


Both rules are disabled by default, you will need to enable them via overrides:

<a href="http://blog.tyang.org/wp-content/uploads/2013/08/image20.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/08/image_thumb20.png" width="580" height="102" border="0" /></a>

I left this running on my laptop at work. It was pretty funny yesterday a colleague of mine connected to my C$ to check few ConfigMgr client log files. I found out straightaway and forwarded the alert notification email that OpsMgr sent to me and asked him what was he looking for on my C drive. <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" alt="Smile" src="http://blog.tyang.org/wp-content/uploads/2013/08/wlEmoticon-smile.png" />

<strong><span style="color: #ff0000;">Please be very cautious on which computers you are enabling these rules on. Please try not to enable them on servers like domain controllers, file &amp; print servers, ConfigMgr servers etc. if you are not prepared to deal with the large number of alerts these rules may generate!</span></strong>

The unsealed MP can be downloaded <strong><a href="http://blog.tyang.org/wp-content/uploads/2013/08/SMB.Connection.Detection.zip">HERE</a></strong>.