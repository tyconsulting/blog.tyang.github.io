---
id: 1955
title: Finding OpsMgr Management Group Installation Date Using PowerShell
date: 2013-06-07T14:47:29+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=1955
permalink: /2013/06/07/finding-opsmgr-management-group-installation-date-using-powershell/
categories:
  - SCOM
tags:
  - Powershell
  - SCOM
---
As part of what I’m working on at the moment, I need to find out when the OpsMgr 2012 management group was initially installed using PowerShell (the installation time of the first management server).

To do so, I can either use the OpsMgr SDK or the OperationsManager PowerShell module. I’ve developed below scripts to run locally on a management server:

<strong>Using SDK:</strong>

```powershell
$MgmtServer = $Env:COMPUTERNAME
#Connect to SCOM management group
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.EnterpriseManagement.OperationsManager.Common") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.EnterpriseManagement.OperationsManager") | Out-Null
$MGConnSetting = New-Object Microsoft.EnterpriseManagement.ManagementGroupConnectionSettings($MgmtServer)
$MG = New-Object Microsoft.EnterpriseManagement.ManagementGroup($MGConnSetting)
$MG.GetManagementGroupMonitoringObject()
```


<strong>TimeAdded</strong> property indicates the MG initial installation date.

<a href="http://blog.tyang.org/wp-content/uploads/2013/06/image.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/06/image_thumb.png" width="580" height="316" border="0" /></a>

<strong>Using OperationsManager PowerShell module:</strong>

```powershell
import-module OperationsManager
$mg = Get-SCOMManagementGroup
$mg.GetManagementGroupMonitoringObject() | format-list
```

<a href="http://blog.tyang.org/wp-content/uploads/2013/06/image1.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/06/image_thumb1.png" width="580" height="359" border="0" /></a>