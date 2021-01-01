---
id: 762
title: Run 64-bit PowerShell via SCCM 2007 Advertisement
date: 2011-11-08T20:16:53+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=762
permalink: /2011/11/08/run-64-bit-powershell-via-sccm-2007-advertisement/
categories:
  - PowerShell
  - SCCM
tags:
  - Powershell
  - SCCM
---
A colleague came across a problem today. He could run a SCDPM PowerShell script from PowerShell console successfully but could not run it when packaged it in SCCM.

We soon found out it’s because SCCM 2007 is a 32-bit app and DPM PowerShell snapin is only available for 64-bit PowerShell because we could not run the script from a 32-bit PowerShell console.

When a 32-bit application tries to access %WinDir%\system32, Windows redirects it to %WinDir%\SysWOW64. In order for the 32-bit app to access %WinDir%\System32 folder, we have to use <strong>%Windir%\sysnative</strong>.

So, we set the command line of the program in SCCM package to <strong>"%WinDir%\Sysnative\WindowsPowerShell\V1.0\Powershell.exe" –noprofile .\PowerShellScript.ps1</strong> as that’s where the 64-bit version of PowerShell is and the SCCM advertisement ran successfully on the client.

More reading regarding to file system redirection here: <a title="http://support.microsoft.com/kb/942589" href="http://support.microsoft.com/kb/942589">http://support.microsoft.com/kb/942589</a>