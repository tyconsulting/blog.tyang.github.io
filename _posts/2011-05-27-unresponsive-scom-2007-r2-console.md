---
id: 547
title: Unresponsive SCOM 2007 R2 Console
date: 2011-05-27T19:18:25+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=547
permalink: /2011/05/27/unresponsive-scom-2007-r2-console/
categories:
  - SCOM
tags:
  - SCOM
  - SCOM console
  - Windows Firewall
---
Over the last few weeks, I’ve been configuring a brand new SCOM environment at work to monitor the SCCM infrastructure.

This is a very small SCOM implementation, it only consists 1 RMS (SCOM 2007 R2 with Cumulative Update 4) and 1 SQL server hosting OperationsManager DB (SCOM Reporting is yet to be implemented). Both RMS and SQL servers are running on Windows 2008 R2 RTM.

Currently, there is only 1 SCOM console installed, which is running locally on the RMS server. From very beginning, I noticed the SCOM console randomly became unresponsive and hang when I create /modify objects (i.e. groups, overrides, subscriptions, etc). When it happens, I normally had to restart SCOM services or even reboot the RMS server to get it going again (thankfully it’s not in production yet).

Today, the issue became very extreme. after reboot, the SCOM console hang on start up. I have tried using different user account and removed my Windows profile from the RMS server, but it did not help.

After a bit digging around I noticed there are some messeges logged in the event logs of the RMS server:

<strong>From Security Log</strong>:

<a href="http://blog.tyang.org/wp-content/uploads/2011/05/image6.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/05/image_thumb6.png" border="0" alt="image" width="655" height="456" /></a>

Windows Filtering Platform is blocking SQL traffic from RMS to SQL server.

<strong>From Operations Manager log:</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2011/05/image7.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/05/image_thumb7.png" border="0" alt="image" width="682" height="474" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2011/05/image8.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/05/image_thumb8.png" border="0" alt="image" width="689" height="476" /></a>

After googling around “Windows Filtering Platform”, I found this post: <a href="http://social.msdn.microsoft.com/Forums/en-US/wfp/thread/774026e6-a771-418a-b531-22183ef399f8/">http://social.msdn.microsoft.com/Forums/en-US/wfp/thread/774026e6-a771-418a-b531-22183ef399f8/</a>

There is one response in this post:

<em>“If you decide to turn off the Windows Firewall, you need to make sure you disable it  in the proper manner, otherwise you will have persistent filters affecting your traffic.  In the Windows Firewall control panel (firewall.cpl), make sure you select 'Turn Windows Firewall on or off' and select 'Off (Not Recommended)'.  Alternatively you can use netsh.exe and run</em>

<em>'Netsh.exe AdvFirewall Set CurrentProfile State Off'.</em>

<em>MPSSvc is a required service for IPsec Policy to continue to function.  It also just happens to house Windows Firewall functionality as well.  If using IPsec, do<strong>not </strong>turn off this service.  Additionally if you do not turn off Windows Firewall, and just stop this service, you will be hit with Windows Firewall's persistent policy (hence the reason to disable the firewall as stated above).”</em>

<em> </em>

My problem was that the Windows Firewall Service is disabled:

<a href="http://blog.tyang.org/wp-content/uploads/2011/05/image9.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/05/image_thumb9.png" border="0" alt="image" width="704" height="244" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2011/05/image10.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/05/image_thumb10.png" border="0" alt="image" width="699" height="66" /></a>

<strong>This is what I did to fix the issue</strong>:
<ol>
	<li>Set Windows Firewall service to Auto start and start it up.</li>
	<li>run “<strong>Netsh.exe AdvFirewall Set CurrentProfile State Off</strong>” command in an <strong>elevated</strong> command prompt to disable all firewalls.</li>
</ol>
After that, the SCOM console is running smoothly like never before!