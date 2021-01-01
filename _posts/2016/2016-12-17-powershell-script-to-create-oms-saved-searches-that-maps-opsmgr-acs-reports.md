---
id: 5812
title: PowerShell Script to Create OMS Saved Searches that Maps OpsMgr ACS Reports
date: 2016-12-17T20:16:15+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=5812
permalink: /2016/12/17/powershell-script-to-create-oms-saved-searches-that-maps-opsmgr-acs-reports/
categories:
  - OMS
  - PowerShell
tags:
  - OMS
  - Powershell
---
Microsoft’s PFE Wei Hao Lim has published an awesome blog post that maps OpsMgr ACS reports to OMS search queries (<a title="https://blogs.msdn.microsoft.com/wei_out_there_with_system_center/2016/07/25/mapping-acs-reports-to-oms-search-queries/" href="https://blogs.msdn.microsoft.com/wei_out_there_with_system_center/2016/07/25/mapping-acs-reports-to-oms-search-queries/">https://blogs.msdn.microsoft.com/wei_out_there_with_system_center/2016/07/25/mapping-acs-reports-to-oms-search-queries/</a>)

There are 36 queries on Wei’s list, so it will take a while to manually create them all as saved searches via the OMS Portal. Since I can see that I will reuse these saved searches in many OMS engagements, I have created a script to automatically create them using the OMS PowerShell Module <a href="https://www.powershellgallery.com/packages/AzureRM.OperationalInsights">AzureRM.OperationalInsights</a>.

So here’s the script:
https://gist.github.com/tyconsulting/0c143b69c59bd4d2b4f96e1511ace0bf

You must run this script in PowerShell version 5 or later. Lastly, thanks Wei for sharing these valuable queries with the community!