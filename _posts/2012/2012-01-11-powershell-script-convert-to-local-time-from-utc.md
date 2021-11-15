---
id: 850
title: 'PowerShell Script: Convert To Local Time From UTC'
date: 2012-01-11T17:20:59+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=850
permalink: /2012/01/11/powershell-script-convert-to-local-time-from-utc/
categories:
  - PowerShell
tags:
  - PowerShell
---
I wrote this function in the script from my previous post "<a href="https://blog.tyang.org/2012/01/05/scom-mp-authoring-example-generate-alerts-based-on-entries-from-sql-database-part-2-of-2/">SCOM MP Authoring Example: Generate alerts based on entries from SQL Database (Part 2 of 2)</a>". It comes handy sometimes so I thought I’ll blog it separately as well.

In PowerShell Datetime object, there is a ToUniversalTime() method that converts local time to UTC time.

<a href="https://blog.tyang.org/wp-content/uploads/2012/01/image25.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2012/01/image_thumb25.png" alt="image" width="532" height="303" border="0" /></a>

However, there isn’t a native way to convert FROM UTC To local time. So I wrote this function:
```powershell
Function Get-LocalTime($UTCTime)
{
$strCurrentTimeZone = (Get-WmiObject win32_timezone).StandardName
$TZ = [System.TimeZoneInfo]::FindSystemTimeZoneById($strCurrentTimeZone)
$LocalTime = [System.TimeZoneInfo]::ConvertTimeFromUtc($UTCTime, $TZ)
Return $LocalTime
}
```
<a href="https://blog.tyang.org/wp-content/uploads/2012/01/image26.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2012/01/image_thumb26.png" alt="image" width="580" height="263" border="0" /></a>