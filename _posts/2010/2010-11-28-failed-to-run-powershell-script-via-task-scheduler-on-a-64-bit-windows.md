---
id: 324
title: Failed to run PowerShell script via Task Scheduler on a 64 bit Windows
date: 2010-11-28T11:19:05+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=324
permalink: /2010/11/28/failed-to-run-powershell-script-via-task-scheduler-on-a-64-bit-windows/
categories:
  - PowerShell
  - Windows
tags:
  - 32 bit Powershell
  - Powershell Execution Policy
  - Windows Scheduled Tasks
---
I came across a situation the other day that on a Windows Server 2008 R2 box, when I created a Scheduled Task to run a Powershell script, it runs OK using "C:\Windows\\**System32**\WindowsPowerShell\v1.0\Powershell.exe" (64 bit PowerShell).

But fails with error code (0x1) if I use "C:\Windows\\**SysWOW64**\WindowsPowerShell\v1.0\Powershell.exe" (32 bit Powershell)

I have done the following steps to help me troubleshoot the issue.

1. I have changed the scheduled task to "Run only when user is logged on" so a command prompt was shown when the task runs. I screen captured the output:

<a href="http://blog.tyang.org/wp-content/uploads/2010/11/image2.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2010/11/image_thumb2.png" border="0" alt="image" width="520" height="105" /></a>

It looks like the PowerShell Execution Policy is preventing the script to run.

2. I confirmed the execution policy setting is set to RemoteSigned – which is sufficient for the script to run.

<a href="http://blog.tyang.org/wp-content/uploads/2010/11/image3.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2010/11/image_thumb3.png" border="0" alt="image" width="293" height="84" /></a>

3. However, when I launched "<strong>Windows PowerShell (x86)</strong>", I got different setting!

<a href="http://blog.tyang.org/wp-content/uploads/2010/11/image4.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2010/11/image_thumb4.png" border="0" alt="image" width="294" height="79" /></a>

4. I didn’t know that we can have different Execution Policy for 64 Bit and 32 Bit PowerShell:

<a href="http://blog.tyang.org/wp-content/uploads/2010/11/image5.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2010/11/image_thumb5.png" border="0" alt="image" width="580" height="273" /></a>

5. So to fix the problem was fairly easy – Set Execution Policy to RemoteSigned on a 32 bit PowerShell console.

As we know that the PowerShell Execution Policy setting is stored in the registry  HKLM\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Micorosft.Powershell\ExecutionPolicy

<a href="http://blog.tyang.org/wp-content/uploads/2010/11/image6.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2010/11/image_thumb6.png" border="0" alt="image" width="580" height="107" /></a>

The 32 bit setting is stored in another location: HKLM\SOFTWARE\\**Wow6432Node**\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell

<a href="http://blog.tyang.org/wp-content/uploads/2010/11/image7.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2010/11/image_thumb7.png" border="0" alt="image" width="580" height="134" /></a>

If the value "ExecutionPolicy" is missing, the default setting is "Restricted". once I set the it to RemoteSigned, the ExecutionPolicy is created and set to RemoteSigned. If I delete it again, the execution policy is then changed back to "Restricted"

I don’t know what is the idea behind having 2 separate execution policies for 64 bit and 32 bit Powershell, maybe someone can share more information with us…