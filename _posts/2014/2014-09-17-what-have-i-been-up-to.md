---
id: 3149
title: What Have I Been Up To
date: 2014-09-17T19:58:02+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=3149
permalink: /2014/09/17/what-have-i-been-up-to/
categories:
  - Others
---
This blog has been a bit quiet lately. This is because I have been very busy, and it’s just all the things I’ve been working on have not been eventuated yet. I just want to quickly post a short update here to share some information with everyone.

## ConfigMgr 2012 Client Management Pack Update

I have spent the last couple of weeks updating the ConfigMgr 2012 Client Management Pack. I thought it would only take me few days but it turned out it has taken a lot longer than what I expected (2 solid weeks with over 10 hours each day including weekends). Having said that, there has been a lot of changes and bug fixes in the new release. I have completed the beta version last night and I’m currently testing it with my fellow SCCDM MVP <a href="https://cloudadministrator.wordpress.com/">Stanislav Zhelyazkov</a>. I’ll let the beta version running in the test environments for few more days, so hopefully if nothing goes wrong, it will be released in the coming days.

## A Custom OpsMgr PowerShell Module for SMA

I started writing a number of OpsMgr PowerShell functions that directly interact with OpsMgr SDK. These functions can be used to create management packs, various rules and monitors. I then transformed these functions into a standalone PowerShell module which can be imported into SMA as Integration Modules. Unlike the built-in OpsMgr module in SMA, this is not a portable module, it does not require SMA runbook workers to install the native OpsMgr 2012 module.

I will be presenting this module in the <a href="http://mscsig.azurewebsites.net/">Melbourne System Center, Security & Infrastructure group</a> next Thursday night (25th September 2014) at Microsoft’s Melbourne office in Southbank with Dan Kregor. We will demonstrate how to automate OpsMgr management packs creation using this module, alone with SMA, Orchestrator and Sharepoint 2013.

To date, I have spent over 2 months working on this project and have already written around 2000 lines of code. I’m really excited with what this solution does and I think it’s pretty cool. If you live in Melbourne and interested in attending, the RSVP detail can be found on the user group website: <a title="http://mscsig.azurewebsites.net/" href="http://mscsig.azurewebsites.net/">http://mscsig.azurewebsites.net/</a>

After the user group meeting, I will also document this solution and make it available to the community.