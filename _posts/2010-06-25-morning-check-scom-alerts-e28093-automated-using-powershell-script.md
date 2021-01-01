---
id: 12
title: Morning Check SCOM Alerts – Automated using PowerShell Script
date: 2010-06-25T11:47:18+10:00
author: Tao Yang
excerpt: A Powershell script to assist server BAU team to perform morning check using SCOM...
layout: post
guid: http://blog.tyang.org/?p=12
permalink: '/2010/06/25/morning-check-scom-alerts-%e2%80%93-automated-using-powershell-script/'
categories:
  - SCOM
tags:
  - Alerts
  - Morning Check
  - Powershell
  - SCOM
---
One of my clients has a centralised SCOM management group for different segments of the business. The BAU team's support hours are 8am-6pm Monday - Friday. They are also required to perform a morning check Monday - Friday and manually log service desk calls based on the SCOM alerts generated after hours.

I wanted to automate the process (at least to generate a list of alerts that were raised since 6:00pm previous night). We firstly had a look at the Alerts report from SCOM Generic Reports library but it did not meet our requirements as it does not include the alert resolution state in the report.

We have the following requirements to accomplish:
<ol>
	<li>Include any warning and critical alerts generated between 6:00pm previous BUSINESS day and 7:30 present day.</li>
	<li>Only include alerts that are still open (resolution state not equals to 255)</li>
	<li>Only include production servers from a specific domain</li>
	<li>Time Raised is displayed as the local time, not GMT standard time</li>
	<li>List is emailed out every morning</li>
</ol>
As my knowledge in SQL reporting is very limited, I achieved the task using below PowerShell script. It is scheduled in Task Scheduler of the SCOM RMS server to run Monday – Friday.

Note: a SCOM group is required to include all servers in the scope (in this case, all production servers from the particular domain).

Here’s the <a title="Script" href="http://blog.tyang.org/wp-content/uploads/2010/06/SCOM-MorningCheck.zip" target="_blank">script</a>.