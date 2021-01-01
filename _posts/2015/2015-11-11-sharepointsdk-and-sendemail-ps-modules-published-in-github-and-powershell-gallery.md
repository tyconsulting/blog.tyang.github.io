---
id: 4849
title: SharePointSDK and SendEmail PS Modules Published in GitHub and PowerShell Gallery
date: 2015-11-11T13:44:38+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=4849
permalink: /2015/11/11/sharepointsdk-and-sendemail-ps-modules-published-in-github-and-powershell-gallery/
categories:
  - PowerShell
tags:
  - Powershell
---
I have recently published 2 PowerShell modules that I’ve written around a year ago on GitHub and PowerShell Gallery:
<h4>SharePointSDK:</h4>
Original Post: <a title="http://blog.tyang.org/2014/12/23/sma-integration-module-sharepoint-list-operations/" href="http://blog.tyang.org/2014/12/23/sma-integration-module-sharepoint-list-operations/">http://blog.tyang.org/2014/12/23/sma-integration-module-sharepoint-list-operations/</a>

Github Repository: <a title="https://github.com/tyconsulting/SharePointSDK_PowerShellModule" href="https://github.com/tyconsulting/SharePointSDK_PowerShellModule">https://github.com/tyconsulting/SharePointSDK_PowerShellModule</a>

PowerShell Gallery: <a title="https://www.powershellgallery.com/packages/SharePointSDK/" href="https://www.powershellgallery.com/packages/SharePointSDK/">https://www.powershellgallery.com/packages/SharePointSDK/</a>
<h4>SendEmail:</h4>
Original Post: <a href="http://blog.tyang.org/2014/10/31/simplified-way-send-emails-mobile-push-notifications-sma/">http://blog.tyang.org/2014/10/31/simplified-way-send-emails-mobile-push-notifications-sma/</a>

Github Repository: <a title="https://github.com/tyconsulting/SendEmail_PowerShellModule" href="https://github.com/tyconsulting/SendEmail_PowerShellModule">https://github.com/tyconsulting/SendEmail_PowerShellModule</a>

PowerShell Gallery: <a title="https://www.powershellgallery.com/packages/SendEmail/" href="https://www.powershellgallery.com/packages/SendEmail/">https://www.powershellgallery.com/packages/SendEmail/</a>

Please note the versions I published on Github and PowerShell Gallery are newer than the versions from my original blog posts. Originally, both modules take clear text user name and passwords as input parameters. This behaviour was flagged by the PowerShell Gallery administrators after they examined my modules using PowerShell Script Analyzer. I have just updated both modules today and replaced clear text user name and password parameters with PSCredential parameter. So if you are currently using old versions without using SMA / Azure Automation connection objects, you may need to update your scripts and runbooks after you upgrade.