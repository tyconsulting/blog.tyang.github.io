---
id: 563
title: 'SCCM 2012 Beta 2 Installation error &quot;Failed to write string -T8295 to registry on SQL Server&quot;'
date: 2011-06-19T22:14:08+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=563
permalink: /2011/06/19/sccm-2012-beta-2-installation-error-failed-to-write-string-t8295-to-registry-on-sql-server/
categories:
  - SCCM
tags:
  - SCCM 2012 Beta 2 Installation
---
Today I started installing SCCM 2012 Beta 2 in my test environment. while I was installing the Central Admin Site, the installation wizard got stuck at “<strong>Evaluating Setup Environmen</strong>t” step and the following errors were logged in C:\ConfigMgrSetup.log:

<strong> ERROR: Failed to write string -T8295 to registry on SQL Server </strong>

<strong>ERROR: Failed to write string "-T4199" to registry on SQL Server</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2011/06/image2.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/06/image_thumb2.png" border="0" alt="image" width="580" height="62" /></a>

This is because the SQL Server service is not running under Local System. After I changed the SQL Server service to run under Local System, restarted SQL Server service, the SCCM 2012 setup went successful!

This is documented in “<a href="http://download.microsoft.com/download/5/4/5/54508737-EB00-4B65-8DB3-F0D810FA3A9F/Configuration%20Manager%202012%20Beta%202%20Supported%20Configuration.pdf">Configuration Manager 2012 Beta 2 Supported Configuration</a>”.