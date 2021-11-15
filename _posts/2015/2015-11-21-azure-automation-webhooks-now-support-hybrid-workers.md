---
id: 4857
title: Azure Automation Webhooks Now Support Hybrid Workers
date: 2015-11-21T17:00:09+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=4857
permalink: /2015/11/21/azure-automation-webhooks-now-support-hybrid-workers/
categories:
  - Azure
  - OMS
tags:
  - Azure Automation
  - OMS
---
My friend and fellow CDM MVP Pete Zerger just pinged me and told me he just spotted that Azure Automation webhooks now support targeting Hybrid Workers.

The webhook configuration used to look like this:

<a href="https://blog.tyang.org/wp-content/uploads/2015/11/image.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/11/image_thumb.png" alt="image" width="455" height="459" border="0" /></a>

(Source image from David O’Brien’s blog: <a title="http://www.david-obrien.net/2015/05/azure-automation-webhooks/" href="http://www.david-obrien.net/2015/05/azure-automation-webhooks/">http://www.david-obrien.net/2015/05/azure-automation-webhooks/</a>)

Currently, the webhook configuration looks like this:

<a href="https://blog.tyang.org/wp-content/uploads/2015/11/image1.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/11/image_thumb1.png" alt="image" width="455" height="402" border="0" /></a>

Few days ago when Pete and I delivered the Azure Automation session at Microsoft Ignite Australia, in one of our demos, we used Webhook to kick off a process to create AD user accounts on On-Prem Active Directory using Hybrid Workers. Because Webhook did not support Hybrid Workers back then, we had to use an workaround of kicking off an intermediary runbook that runs on Azure worker then start AD user creation runbook on runbook worker groups within the intermediary runbook.

Now with the new capability, we can further simplify our demo scenario by removing the intermediary runbook as we are now able to kick off runbooks on Hybrid Workers directly from webhooks!