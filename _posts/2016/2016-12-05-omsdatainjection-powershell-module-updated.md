---
id: 5786
title: OMSDataInjection PowerShell Module Updated
date: 2016-12-05T09:52:44+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=5786
permalink: /2016/12/05/omsdatainjection-powershell-module-updated/
categories:
  - OMS
  - PowerShell
tags:
  - OMS
  - PowerShell
---
I’ve updated the OMSDataInjection PowerShell module to version 1.1.1. I have added support for bulk insert into OMS.

Now you can pass in an array of PSObject or plain JSON payload with multiple log entries. The module will check for the payload size and make sure it is below the supported limit of 30MB before inserting into OMS.

You can get the new version from both PowerShell Gallery and GitHub:

PowerShell Gallery: <a title="https://www.powershellgallery.com/packages/OMSDataInjection/1.1.1" href="https://www.powershellgallery.com/packages/OMSDataInjection/1.1.1">https://www.powershellgallery.com/packages/OMSDataInjection/1.1.1</a>

GitHub: <a title="https://github.com/tyconsulting/OMSDataInjection-PSModule/releases/tag/1.1.1" href="https://github.com/tyconsulting/OMSDataInjection-PSModule/releases/tag/1.1.1">https://github.com/tyconsulting/OMSDataInjection-PSModule/releases/tag/1.1.1</a>