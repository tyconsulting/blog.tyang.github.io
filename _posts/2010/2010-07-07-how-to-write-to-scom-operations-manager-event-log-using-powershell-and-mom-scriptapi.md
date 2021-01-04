---
id: 94
title: How To Write to SCOM Operations Manager Event Log Using PowerShell and MOM.ScriptAPI
date: 2010-07-07T10:38:03+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/2010/07/07/how-to-write-to-scom-operations-manager-event-log-using-powershell-and-mom-scriptapi/
permalink: /2010/07/07/how-to-write-to-scom-operations-manager-event-log-using-powershell-and-mom-scriptapi/
categories:
  - PowerShell
  - SCOM
tags:
  - PowerShell
  - SCOM
---
The following commands can be executed using the normal PowerShell console. SCOM PowerShell snapin is not required.

```powershell
$momapi = New-Object -comObject "MOM.ScriptAPI"
$momapi.LogScriptEvent("test",9999,2,"this is a test")
```

This is the log:

![](http://blog.tyang.org/wp-content/uploads/2010/07/image5.png)

Detailed documentation of MOM.ScriptAPI can be found on [MSDN](http://msdn.microsoft.com/en-us/library/bb437621.aspx)