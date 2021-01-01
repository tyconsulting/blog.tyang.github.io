---
id: 32
title: 'Windows Scheduled Tasks inventory &#8211; Using PowerShell'
date: 2010-06-25T14:28:07+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=32
permalink: /2010/06/25/windows-scheduled-tasks-inventory-using-powershell/
categories:
  - PowerShell
tags:
  - Inventory
  - Powershell
  - Windows Scheduled Tasks
---
I originally posted this script <a href="http://powershell.com/cs/media/p/2611.aspx">here</a>. It is to audit and inventory all scheduled tasks created for all windows computers under a specific OU in AD.

It has become useful for me again this week while I was working on a client's SCOM environment. This particular client had no control over scheduled server reboots and they are not using SCOM Maintenance mode at all. Therefore there are a lot of SCOM alerts generated...

This script came in handy and it's a good starting point to get all scheduled tasks and find out which ones are causing servers to reboot so we can start putting them into maintenance mode during reboot.