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
Prerequisite: SQL Management Studio needs to be installed
<div id="_mcePaste">[sourcecode language="powershell"]
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo') | Out-Null

$Sql = New-Object ('Microsoft.SqlServer.Management.Smo.Server'&lt;strong&gt;)”&lt;SQL Instance Name&gt;”&lt;/strong&gt;

$SQLAgent = $Sql.JobServer

$SQLAgent.ReadErrorLog() | format-list *

[/sourcecode]
<a href="http://blog.tyang.org/wp-content/uploads/2011/03/image4.png"><img class="alignleft size-full wp-image-396" title="image4" src="http://blog.tyang.org/wp-content/uploads/2011/03/image4.png" alt="" width="459" height="480" /></a></pre>
&nbsp;

</div>