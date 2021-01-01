---
id: 6166
title: OpsMgr 2016 Agent Crashes SharePoint 2016 Site
date: 2017-07-29T22:58:04+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=6166
permalink: /2017/07/29/opsmgr-2016-agent-crashes-sharepoint-2016-site/
categories:
  - SCOM
tags:
  - SCOM 2016
---
Today I pushed the SCOM 2016 agent to my newly installed SharePoint 2016 server via the SCOM console. My SCOM management group is on 2016 RTM UR 3.

Once the SCOM agent was installed, I could not launch SharePoint Central Admin site after a reboot. After turned off the custom error in web.config, I could see the exception:

<a href="https://blog.tyang.org/wp-content/uploads/2017/07/image-10.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/07/image_thumb-10.png" alt="image" width="958" height="517" border="0" /></a>

This is caused by the known issue with SCOM 2016 agent APM component (Application Performance Monitoring). My good friend Kevin Greene has already blogged this: <a title="http://kevingreeneitblog.blogspot.com.au/2017/03/scom-2016-agent-crashing-legacy-iis.html" href="http://kevingreeneitblog.blogspot.com.au/2017/03/scom-2016-agent-crashing-legacy-iis.html">http://kevingreeneitblog.blogspot.com.au/2017/03/scom-2016-agent-crashing-legacy-iis.html</a>

So to fix my issue, I followed Kevin’s instruction – reinstalled the SCOM agent using MOMAgent.msi with the “NOAPM=1” parameter.

Until the SCOM product group fixes this issue, please keep in mind this can be a potential issue when rolling out SCOM agent to IIS servers.