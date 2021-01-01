---
id: 765
title: 'SCOM: Using PowerShell to update SMTP server address in SMTP notification Channels'
date: 2011-12-10T20:37:10+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=765
permalink: /2011/12/10/scom-using-powershell-to-update-smtp-server-address-in-smtp-notification-channels/
categories:
  - SCOM
tags:
  - Powershell
  - SCOM
---
I've been asked a question on how to bulk update SMTP server addresses in SMTP notification channels using PowerShell.

Here’s the script to run in OpsMgr Command Shell:

```powershell
$newSMTP = "name of your new SMTP server";
$SMTPChannels = Get-NotificationAction |Where-Object {$_.Name –imatch "smtp"}
Foreach ($item in $SMTPChannels)
{
  $item.Endpoint.PrimaryServer.Address = $newSMTP
  $item.Endpoint.update()
}
```