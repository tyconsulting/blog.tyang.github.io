---
id: 5938
title: Be Cautious When Designing Your Automation Solution that Involves Azure Automation Azure Runbook Workers
date: 2017-03-20T12:40:57+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=5938
permalink: /2017/03/20/be-cautious-when-designing-your-automation-solution-that-involves-azure-automation-azure-runbook-workers/
categories:
  - Azure
  - OMS
tags:
  - Azure
  - Azure Automation
---
<a href="http://blog.tyang.org/wp-content/uploads/2017/03/caution-sign.jpg"><img style="background-image: none; float: left; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="caution-sign" src="http://blog.tyang.org/wp-content/uploads/2017/03/caution-sign_thumb.jpg" alt="caution-sign" width="244" height="163" align="left" border="0" /></a>Over the last few weeks, it occurred to me twice that I had to change my original design of the automation solutions I was working on because of the limitations of Azure Automation Azure Runbook Workers. Last month, my fellow CDM MVP Michael Rueefli has published an article and explained <a href="http://www.miru.ch/why-deploying-hybrid-runbook-workers-on-azure-makes-sense/">Why deploying Hybrid Runbook Workers on Azure makes sense</a>. In Michael’s article, he listed some infrastructural differences between Azure runbook workers and the Hybrid runbook workers. However, the issues that I faced that made me to change my design were caused by the functional limitations in Azure runbook workers. Therefore I thought I’d post a supplement post to document my findings. Since these limitations are not documented in Microsoft’s official documentation site,<span style="color: #ff0000;"> **please DO NOT assume this is the complete list, and it is still valid by the time you read it. I will try my best to keep this post up-to-date over the time.**</span> So, there are the limitations I found:

**01. Windows Event Log Service is missing**

Few months ago, I wrote a runbook that reads event log export .evt files and inject the records to OMS (<a title="http://blog.tyang.org/2016/12/05/injecting-event-log-export-from-evtx-files-to-oms-log-analytics/" href="http://blog.tyang.org/2016/12/05/injecting-event-log-export-from-evtx-files-to-oms-log-analytics/">http://blog.tyang.org/2016/12/05/injecting-event-log-export-from-evtx-files-to-oms-log-analytics/</a>). This runbook uses a .NET class System.Diagnostics.Eventing.Reader.EventLogQuery to read events from the evt files. Few days ago, when I tried to implement a version of this runbook for a solution that I was initially planned to use Azure runbook workers, the runbook job failed when configured to run on Azure and I got a "RPC Server is unavailable" error.

<a href="http://blog.tyang.org/wp-content/uploads/2017/03/image-8.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2017/03/image_thumb-8.png" alt="image" width="631" height="122" border="0" /></a>

After some troubleshooting, I found the cause of this error. The .NET class EventLogQuery relies on the Windows Event Log service to read the evt files, but in the Azure runbook worker’s sandbox environment, Windows Event Log service does not exist. Therefore, I have no choice but changing the design the having this runbook to be executed on the Hybrid runbook worker.

**02. Unable to Map Network Drives**

In a runbook, I have a code block that maps a network drive to an Azure storage File Share and read some files. When ran it on the Azure runbook worker, I found it was not possible to map the network drive. Luckily I could use the Azure.Storage PowerShell module to access the files in the Azure File Share, so I had to update the runbook to accommodate this limitation.

**03. Disk Size Limitation**

In a runbook, I needed to extract a 2GB zip file. It failed to run on Azure runbook worker because of the insufficient disk space and I couldn’t even copy the 2GB file to the Azure runbook worker. I attempted to find the size of the system drive on the Azure runbook workers by using Get-PSDrive cmdlet but it did not return the disk size.

**04. Unable to use Service Principals and Credentials to Login to Azure**

In a solution that I was working on, I designed to use Service Principals (Azure AD applications) and credentials to login to Azure. This method worked perfectly when the runbook was executed on the Hybrid runbook worker, but does not work when running on Azure. After some researching, I found someone had the same issue and posted on Stack Overflow: <a title="http://stackoverflow.com/questions/37619377/login-azurermaccount-credential-immediately-expiring" href="http://stackoverflow.com/questions/37619377/login-azurermaccount-credential-immediately-expiring">http://stackoverflow.com/questions/37619377/login-azurermaccount-credential-immediately-expiring</a>. Basically, using credentials with service principals is not supported when the runbook is executed on Azure runbook workers.

Based on my experiences so far, I’ve come to a conclusion that I should not automatically assume everything is going to work on Azure runbook workers when designing my solution. In future, I will make sure that I’ll test early and every step along the way if I am planning to have the runbook executed on Azure runbook workers.

If you have experienced limitations that are not listed here, please let me know and I’m happy to add them onto this post.