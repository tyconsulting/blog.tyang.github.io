---
id: 153
title: Get Powershell Execution Policy on remote machines
date: 2010-07-27T12:58:53+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=153
permalink: /2010/07/27/get-powershell-execution-policy-on-remote-machines/
categories:
  - PowerShell
tags:
  - PowerShell
  - remote execution policy
---
Today I've been asked how to inventory PowerShell execution policies on all servers in a domain. I originally thought I can ultilise RemoteIn as PowerShell V2 should be deployed on all servers. then I realised WSMan wasn't configured on the srevers so I couldn't use "New-PSSession" cmdlet...

Therefore, I wrote a function called <span style="color: #ff0000;"><strong><a href="http://blog.tyang.org/wp-content/uploads/2010/07/Get-RemoteExecutionPolicy.zip">Get-RemoteExecutionPolicy</a></strong></span>.  It retrieves the setting from the remote registry.

The usage is: <strong>Get-RemoteExecutionPolicy &lt;machine name&gt;</strong>.