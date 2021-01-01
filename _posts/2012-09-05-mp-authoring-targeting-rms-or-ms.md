---
id: 1397
title: 'MP Authoring: Targeting RMS or MS?'
date: 2012-09-05T23:43:32+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=1397
permalink: /2012/09/05/mp-authoring-targeting-rms-or-ms/
categories:
  - SCOM
tags:
  - MP Authoring
  - SCOM
---
I’m writing a write action module for a management pack that I’m currently working on. This module contains a PowerShell script that connects to SCOM SDK service and interacts with agent computers. I originally wrote the script and planed to target the workflow to the RMS. which I thought it would make sense because SDK service runs on it no matter whether the management group version is 2007 or 2012 (RMS Emulator).

My initial PowerShell code in the write action module looked something like this:

```powershell
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.EnterpriseManagement.OperationsManager.Common") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.EnterpriseManagement.OperationsManager") | Out-Null

$MGConnSetting = New-Object Microsoft.EnterpriseManagement.ManagementGroupConnectionSettings($Env:COMPUTERNAME)
$MG = New-Object Microsoft.EnterpriseManagement.ManagementGroup($MGConnSetting)
```

As you can see, I wrote the script to connect to the SDK on the local machine.

I was talking to a Microsoft SCOM PFE yesterday, and he asked me why not target the workflow to the Management Server class since in 2012, SDK runs on all management servers. Because I want this module to work on both 2007 and 2012, Initially I thought it’s not going to work on 2007 if I target the workflow to the management server class because the SDK only runs on RMS in 2007.

Anyways, I had another thought tonight, it would be nice if I could target MS instead of RMS to take the load off RMS and get each MS to only interact with the agents that are reporting to itself. This probably makes more sense and would be more efficient in 2012 rather than 2007.

So in order to make this script run on both 2007 and 2012, I changed the script to:

```powershell
#Locate SDK service machine
$MachineRegKeyPath = "HKLM:\software\Microsoft\Microsoft Operations Manager\3.0\Machine Settings"
$MachineRegValueName = "DefaultSDKServiceMachine"
$regValue = Get-ItemProperty -path:$MachineRegKeyPath -name:$MachineRegValueName -ErrorAction:SilentlyContinue;

if ($regValue -ne $null)
{
$SDKServiceMachine = $regValue.DefaultSDKServiceMachine;
} else {
#cannot determine which SDK to connect
Exit
}

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.EnterpriseManagement.OperationsManager.Common") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.EnterpriseManagement.OperationsManager") | Out-Null

$MGConnSetting = New-Object Microsoft.EnterpriseManagement.ManagementGroupConnectionSettings($SDKServiceMachine)
$MG = New-Object Microsoft.EnterpriseManagement.ManagementGroup($MGConnSetting)
```

Basically, the script now reads the default SDK service computer name from the registry of each management server and connect to this SDK machine instead of local computer. in 2007, this registry value points to RMS and in 2012, it points to the management server itself.

Of course, now that the script runs on multiple management servers, I had to rewrite the rest of it so it only interact with the agents on the local management server rather than the whole lot as if it’s running on the RMS.

The only concern I have with 2007 is, because my workflow runs on a schedule, when all management servers run this workflow at the same time, it will consume a large number of concurrent SDK connections on the RMS, which could be an issue in a large environment. to work around the issue, I would make sure that I make the <strong>SyncTime</strong> parameter overridable for the scheduler data source module so I can then create overrides for each management servers to run the workflow on different time window.