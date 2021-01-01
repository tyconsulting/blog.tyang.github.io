---
id: 4875
title: New Activity-Level Tracing Options for Azure Automation Graphical Runbooks
date: 2015-11-24T15:55:14+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=4875
permalink: /2015/11/24/new-active-level-tracing-options-for-azure-automation-graphical-runbooks/
categories:
  - OMS
tags:
  - Azure Automation
  - OMS
---
Nowadays, OMS / Azure Automation is full of surprises. almost every time I visit the OMS and Azure Automation portals, I’d notice new features being made available.

Today, I just noticed a new setting for graphical runbooks called <strong>Activity-level tracing</strong>:

<a href="http://blog.tyang.org/wp-content/uploads/2015/11/image3.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/11/image_thumb3.png" alt="image" width="409" height="563" border="0" /></a>

You can now configure additional verbose tracing for graphical runbooks. Please note in order to leverage this new capability, you must also turn on verbose logging for the particular graphical runbook.

<strong>Verbose Logging without Activity-level tracing:</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2015/11/image4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/11/image_thumb4.png" alt="image" width="678" height="297" border="0" /></a>

<strong>Detailed Activity-level Tracing Enabled:</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2015/11/image5.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/11/image_thumb5.png" alt="image" width="683" height="397" border="0" /></a>

As you can see, once turned on, you can see a lot more verbose logging activities (starts with ‘GraphTrace") for your runbook jobs.