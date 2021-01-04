---
id: 962
title: Command Line Parameters for SCOM Command Notification Channel
date: 2012-01-29T16:53:17+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=962
permalink: /2012/01/29/command-line-parameters-for-scom-command-notification-channel/
categories:
  - PowerShell
  - SCOM
tags:
  - Command Notification
  - SCOM
---
Few years ago, I wrote the Enhanced SCOM Alert Notification script and I blogged it <a href="http://blog.tyang.org/2010/07/19/enhanced-scom-alerts-notification-emails/">here</a>.

In all the environments that I implemented this script in command notification channel, there were always some random alerts not been processed.

Few months ago, I was working on another PowerShell script to be used in command notification channel to update a custom field when alerts are created. While I was testing it, I found it has exactly the same problem, the subscription randomly skips alerts and left them not processed.

In the end, I found the cause of the problem: the command line parameters are not configured properly! The details can be found in Steve Rachui’s blog article here: <a href="http://blogs.msdn.com/b/steverac/archive/2010/08/17/updating-custom-alert-fields-using-subscriptions-and-powershell.aspx">Updating custom alert fields using subscriptions and powershell</a>. Steve explained in the article:
<blockquote>There are several quotation marks in the command line so I’ve listed the text again below in case you want to copy/paste in your environment. Note the highlights above – these are single quotes that go around alert ID as it’s passed to the script. Make sure you include these because if you don’t the alert ID won’t be handled correctly in all cases and the script will not run consistently.

Full path of the command file: <em>c:\windows\system32\windowspowershell\v1.0\powershell.exe
</em><strong>Command line parameters: </strong><em><strong>-Command "& '"C:\alertupdater.ps1"'" '$Data/Context/DataItem/AlertId$'
</strong></em>Startup folder for the command line: <em>c:\windows\system32\windowspowershell\v1.0\</em></blockquote>
So to fix my problem with my Ehanced SCOM Alert Nofication Script, the command line parameter should be:

<strong><span style="color: #ff0000;">-Command "& '"D:\Scripts\SCOMEnhancedEmailNotification.ps1"'" -alertID '$Data/Context/DataItem/AlertId$' -Recipients @('Tao Yang;Tao.Yang@xxxx.com’,John Smith;John.Smith@xxxx.com‘)</span></strong>

<strong>I’ve updated the original Enhanced SCOM Alerts Notification EMails blog article to reflect this change.</strong>