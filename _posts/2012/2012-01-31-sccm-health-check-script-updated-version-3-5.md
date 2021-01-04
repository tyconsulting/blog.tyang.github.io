---
id: 973
title: 'SCCM Health Check Script Updated: Version 3.5'
date: 2012-01-31T19:55:11+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=973
permalink: /2012/01/31/sccm-health-check-script-updated-version-3-5/
categories:
  - SCCM
tags:
  - Health Check
  - PowerShell
  - SCCM
---
I have just updated the <a title="SCCM Health Check Script" href="http://blog.tyang.org/2011/03/30/powershell-script-sccm-health-check/">SCCM Health Check Script </a>to from version 3.3 to 3.5

Version 3.4 was finished a while back but I never got time to publish it in this blog. I only emailed 3.4 to few people who contacted me from my blog. Now that I’ve updated it again to 3.5, I thought I’ll just publish version 3.5.
<h2><span style="color: #ff0000;">What’s Changed Since 3.3?</span></h2>
<ol>
	<li>Added site system name under 'site systems with issues' section</li>
	<li>Detect site components that are missing heartbeats.</li>
	<li>Changed function Validate-DNSRecord to use Win32_ComputerSystem.caption rather than DNSHostname to retrieve computer name as DNSHostName is not available on computers before Windows 2008.</li>
</ol>
<h2><span style="color: #ff0000;">Update Instruction</span></h2>
A new item has been added to the configuration XML (Health-Check.xml):
<span style="color: #ff0000;">   &lt;MaxMissingHeartBeatTolerance&gt;
&lt;Hours&gt;24&lt;/Hours&gt;
&lt;/MaxMissingHeartBeatTolerance&gt;</span>

As the name suggest, the script raises any site systems as problematic if it has not sent heartbeat for over the X number of hours that you configured in XML (in my example, it’s 24 hours).

You may keep the old XML that you have already configured for your environment as long as you add the following lines in the Health-Check.XML:

&nbsp;

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image62.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb62.png" alt="image" width="532" height="314" border="0" /></a>

You can download version 3.5 <span style="font-size: medium;"><strong><a href="http://blog.tyang.org/wp-content/uploads/2012/01/SCCM-Health-Check-v3.5.zip">HERE</a></strong></span>.