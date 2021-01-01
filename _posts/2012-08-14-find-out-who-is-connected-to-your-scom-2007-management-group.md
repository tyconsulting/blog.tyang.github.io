---
id: 1354
title: Find out who is connected to your SCOM 2007 management group
date: 2012-08-14T23:02:34+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=1354
permalink: /2012/08/14/find-out-who-is-connected-to-your-scom-2007-management-group/
categories:
  - PowerShell
  - SCOM
tags:
  - Powershell
  - SCOM
---
As we all know, we can see how many concurrent SDK connections have been established on the RMS by looking at the Client Connections counter in OpsMgr SDK Service:

<img src="http://blog.tyang.org/wp-content/uploads/2012/08/A23CDB7BE13C99777004EC4B5DF9D9BC0A89F30C.png" alt="" width="791" height="270" border="0" />

To find out who are actually connected, you can use the SDK:

```powershell
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.EnterpriseManagement.OperationsManager.Common") 
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.EnterpriseManagement.OperationsManager")
$RootMS = "SCOM01"
$MGConnSetting = New-Object Microsoft.EnterpriseManagement.ManagementGroupConnectionSettings($RootMS)
$ManagementGroup = New-Object Microsoft.EnterpriseManagement.ManagementGroup($MGConnSetting)
$ManagementGroup.GetConnectedUserNames()
```

<img src="http://blog.tyang.org/wp-content/uploads/2012/08/976C42E93C0BBC0844673E4D7235562E5684C405.png" alt="" width="486" height="170" border="0" />