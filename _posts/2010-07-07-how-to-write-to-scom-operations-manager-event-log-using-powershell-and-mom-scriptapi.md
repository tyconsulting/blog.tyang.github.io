---
id: 94
title: How To Write to SCOM Operations Manager Event Log Using PowerShell and MOM.ScriptAPI
date: 2010-07-07T10:38:03+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/2010/07/07/how-to-write-to-scom-operations-manager-event-log-using-powershell-and-mom-scriptapi/
permalink: /2010/07/07/how-to-write-to-scom-operations-manager-event-log-using-powershell-and-mom-scriptapi/
categories:
  - PowerShell
  - SCOM
tags:
  - Powershell
  - SCOM
---
<p>The following commands can be executed using the normal PowerShell console. SCOM PowerShell snapin is not required.</p>  <p><font color="#ff0000">$momapi = New-Object -comObject &quot;MOM.ScriptAPI&quot;</font></p>  <p><font color="#ff0000">$momapi.LogScriptEvent(&quot;test&quot;,9999,2,&quot;this is a test&quot;)</font></p>  <p>&#160;</p>  <p>This is the log:</p>  <p><a href="http://blog.tyang.org/wp-content/uploads/2010/07/image5.png"><img style="border-bottom: 0px;border-left: 0px;border-top: 0px;border-right: 0px" border="0" alt="image" src="http://blog.tyang.org/wp-content/uploads/2010/07/image_thumb5.png" width="413" height="458" /></a> </p>  <p>&#160;</p>  <p>Detailed documentation of MOM.ScriptAPI can be found on <a href="http://msdn.microsoft.com/en-us/library/bb437621.aspx">MSDN</a>.</p>