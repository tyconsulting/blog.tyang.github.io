---
id: 856
title: 'Run Batch File for SCOM Monitor&#8217;s Recovery Task'
date: 2012-01-25T10:59:36+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=856
permalink: /2012/01/25/run-batch-file-for-scom-monitors-recovery-task/
categories:
  - SCOM
tags:
  - SCOM
---
This is how I configured recovery task to run a batch file:

Actions Module Type: <strong>System.CommandExecuter</strong>

Module Configuration

Application Name: C:\Windows\System32\cmd.exe

Working Directory: C:\Windows\System32

CommandLine: /c &lt;Path to Batch file&gt; (i.e. /c C:\Apps\DelFile.bat)

TimeoutSeconds: &lt;i.e. 60&gt;

RequiredOutput: true

&nbsp;

&nbsp;