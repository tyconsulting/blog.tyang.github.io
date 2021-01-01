---
id: 389
title: How to read SQL Agent logs using Windows PowerShell
date: 2011-02-28T13:53:47+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=389
permalink: /2011/02/28/how-to-read-sql-agent-logs-using-windows-powershell/
categories:
  - PowerShell
  - SQL Server
tags:
  - SQL Agent Logs
---
Prerequisite: SQL Management Studio needs to be installed.

```powershell
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo') | Out-Null
$Sql = New-Object ('Microsoft.SqlServer.Management.Smo.Server')"SQL_Instance_Name"
$SQLAgent = $Sql.JobServer
$SQLAgent.ReadErrorLog() | format-list *
```

![1](../../../../wp-content/uploads/2011/03/image4.png)
