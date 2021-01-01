---
id: 4630
title: Small Bug Fix in OpsMgr Self Maintenance MP V2.5.0.0
date: 2015-09-18T10:48:08+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=4630
permalink: /2015/09/18/small-bug-fix-in-opsmgr-self-maintenance-mp-v2-5-0-0/
categories:
  - SCOM
tags:
  - Management Pack
  - MP Authoring
  - SCOM
---
Last night, someone left a comment on the my <a href="http://blog.tyang.org/2015/09/16/opsmgr-self-maintenance-management-pack-2-5-0-0/">post for the OpsMgr Self Maintenance MP V2.5.0.0</a> and advised a configuration in the Data Warehouse staging tables row count performance collection rules is causing issues with the Exchange Correlation service – which is a part of the Exchange MP. This issue was previously identified for other MPs: <a title="https://social.technet.microsoft.com/Forums/en-US/f724545d-90a3-42e6-950e-72e14ac0bd9d/exchange-correlation-service-cannot-connect-to-rms?forum=operationsmanagermgmtpacks" href="https://social.technet.microsoft.com/Forums/en-US/f724545d-90a3-42e6-950e-72e14ac0bd9d/exchange-correlation-service-cannot-connect-to-rms?forum=operationsmanagermgmtpacks">https://social.technet.microsoft.com/Forums/en-US/f724545d-90a3-42e6-950e-72e14ac0bd9d/exchange-correlation-service-cannot-connect-to-rms?forum=operationsmanagermgmtpacks</a>

In a nutshell, looks like the Exchange Correlation service does not like rules that have category set to "None".

I would have never picked it up in my environment because I don’t have Exchange in my lab therefore no Exchange MP configured.

Anyways, I have updated the category for these rules in both the Self Maintenance MP as well as the OMS Add-On MP, changed them from "None" to "PerformanceCollection". I have updated the download from TY Consulting’s website. The current version is now 2.5.0.1. So if you are have already downloaded v.2.5.0.0 and you are using Exchange MP in your environment, you might want to download the updated version again from the same spot <a href="http://www.tyconsulting.com.au/portfolio/opsmgr-self-maintenance-management-pack-v-2-5-0-0/">HERE</a>.