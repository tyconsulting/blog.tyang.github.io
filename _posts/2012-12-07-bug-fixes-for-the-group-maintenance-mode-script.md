---
id: 1669
title: Bug Fixes for the Group Maintenance Mode Script
date: 2012-12-07T21:32:59+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=1669
permalink: /2012/12/07/bug-fixes-for-the-group-maintenance-mode-script/
categories:
  - SCOM
tags:
  - SCOM
---
I got a message from a LinkedIn Powershell group in regards to the <a href="http://blog.tyang.org/2012/11/22/group-maintenance-mode-powershell-script-updated/">SCOM Group Maintenance Mode PowerShell script</a> that I’ve posted couple of weeks ago in this blog.

Apparently the script contained 2 bugs:
<ol>
	<li>The script could not evaluate existing maintenance mode’s end time.</li>
	<li>The script did not use"Recursive" option when calling <a href="http://msdn.microsoft.com/en-us/library/bb424617.aspx">ScheduleMaintenanceMode</a> method. Which means, in this case, only the group itself were put into maint. mode, none of its  members were entered maint. mode.</li>
</ol>
I’ve updated the script in the <a href="http://blog.tyang.org/2012/11/22/group-maintenance-mode-powershell-script-updated/">original post</a> and these 2 bugs are fixed.