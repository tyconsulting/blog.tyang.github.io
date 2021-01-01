---
id: 1262
title: Using PowerShell Remote Sessions in a large SCOM environment
date: 2012-06-07T20:18:44+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=1262
permalink: /2012/06/07/using-powershell-remote-sessions-in-a-large-scom-environment/
categories:
  - PowerShell
  - SCOM
tags:
  - Powershell
  - Powershell Remoting
  - SCOM
---
I have previously blogged <a href="http://blog.tyang.org/2012/05/09/using-scom-powershell-snap-in-and-sdk-client-with-a-powershell-remote-session/">using SCOM PowerShell snap-in and SDK client in a PowerShell remote session</a> to avoid maintain a consistent SDK connection to RMS server.

I just found out there might be a potential issue when using this technique to run scripts against a reasonably large SCOM management group.

By default, the maximum amount of memory a PowerShell remote session can use is limited to 150MB. You can check this setting on your computer by using

```powershell
winrm get winrm/config
```

<a href="http://blog.tyang.org/wp-content/uploads/2012/06/image.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/06/image_thumb.png" alt="image" width="409" height="795" border="0" /></a>

Depending on how much data the remote session has to process, you might running into problems.

For example, compare these 2 scripts:

**Sample #1:**

```powershell
$me = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$RunAsCred = get-Credential ""
$RMS = ""
$AlertID = "8a5e738c-53d5-4a04-91af-cb8bc2d2e5d3"
$NewSession = new-pssession -ComputerName $env:COMPUTERNAME -Authentication Credssp -Credential (Get-Credential $me)
$alert = invoke-command  -session $NewSession -ScriptBlock {
  param($RMS,$AlertID,$RunAsCred)
  Add-PSSnapin Microsoft.EnterpriseManagement.OperationsManager.Client
  New-PSDrive -Name:Monitoring -PSProvider:OperationsManagerMonitoring -Root:\
  Set-Location "OperationsManagerMonitoring::"
  new-managementGroupConnection -ConnectionString:$RMS -credential $RunAsCred | Out-Null
  Set-Location $RMS
  $Alert = Get-Alert | Where-Object {$_.Id -imatch $AlertID}
  $Alert
} -ArgumentList $RMS, $AlertID, $RunAsCred

Remove-PSSession $NewSession

$alert
```

**Sample #2:**

```powershell
$me = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$RunAsCred = get-Credential ""
$RMS =  ""
$AlertID = "8a5e738c-53d5-4a04-91af-cb8bc2d2e5d3"
$NewSession = new-pssession -ComputerName $env:COMPUTERNAME -Authentication Credssp -Credential (Get-Credential $me)
$alert = invoke-command  -session $NewSession -ScriptBlock {
  param($RMS,$AlertID,$RunAsCred)
  Add-PSSnapin Microsoft.EnterpriseManagement.OperationsManager.Client
  New-PSDrive -Name:Monitoring -PSProvider:OperationsManagerMonitoring -Root:\
  Set-Location "OperationsManagerMonitoring::"
  new-managementGroupConnection -ConnectionString:$RMS -credential $RunAsCred | Out-Null
  Set-Location $RMS
  $Alert = Get-Alert -Id $AlertID
  $Alert
} -ArgumentList $RMS, $AlertID, $RunAsCred

Remove-PSSession $NewSession

$alert
```

The difference between these 2 scripts is, when using Get-Alert cmdlet,  #1 uses client side filtering and #2 uses server side filtering:

**#1:** 

```powershell
$Alert = Get-Alert | Where-Object {$_.Id -imatch $AlertID}
```
**#2:** 

```powershell
$Alert = Get-Alert -Id $AlertID
```

The management group my scripts connect to has just over 22,000 alerts still in the operational database. So when script #1 runs, because it uses client side filtering, it retrieves all 22,000+ alerts to the local remote session, Then filter out all the rest and retrieves ONE alert with that particular Alert ID. On the other hand, script #2 uses server side filtering, only ONE alert is returned from SCOM RMS server.

Here’s what happened when I tried to run both scripts:

**#1:**

<a href="http://blog.tyang.org/wp-content/uploads/2012/06/image1.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/06/image_thumb1.png" alt="image" width="580" height="270" border="0" /></a>

**#2:**

<a href="http://blog.tyang.org/wp-content/uploads/2012/06/image2.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/06/image_thumb2.png" alt="image" width="580" height="469" border="0" /></a>

As you can see, script #2 worked as expected but script #1 throws an exception:

<span style="color: #ff0000;">Processing data for a remote command failed with the following error message: The WSMan provider host process did not return a proper response.  A provider in the host process may have behaved improperly. For more information, see the about_Remote_Troubleshooting Help topic.</span>

<span style="color: #ff0000;">    + CategoryInfo          : OperationStopped: (System.Manageme...pressionSyncJob:PSInvokeExpressionSyncJob) [], PSRemotingTransportException</span>

<span style="color: #ff0000;">    + FullyQualifiedErrorId : JobFailure</span>

So now we know that we should use server side filtering because it is more efficient and there are less data returned.  However, not all SCOM cmdlets supports server side filtering. this statement is also true when talking about PowerShell cmdlets in general. not all cmdlets supports server side filtering. Sometimes, I have to use client side filering. For example, when working with **Get-agent** cmdlet, I have to use client side filtering.

Below script is very similar to script #1, I’ve changed a little bit to retrieve information of a particular SCOM agent:

```powershell
$me = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$RunAsCred = get-Credential ""
$RMS = ""
$AgentName = ""
$NewSession = new-pssession -ComputerName $env:COMPUTERNAME -Authentication Credssp -Credential (Get-Credential $me)
$agent = invoke-command  -session $NewSession -ScriptBlock {
  param($RMS,$AgentName,$RunAsCred)
  Add-PSSnapin Microsoft.EnterpriseManagement.OperationsManager.Client
  New-PSDrive -Name:Monitoring -PSProvider:OperationsManagerMonitoring -Root:\
  Set-Location "OperationsManagerMonitoring::"
  new-managementGroupConnection -ConnectionString:$RMS -credential $RunAsCred | Out-Null
  Set-Location $RMS
  $Agent = Get-Agent | Where-Object {$_.PrincipalName -imatch $AgentName}
  $Agent
} -ArgumentList $RMS, $AgentName, $RunAsCred

Remove-PSSession $NewSession

$agent
```

The management group I have connected to has around 5000 agents at the moment, so it’s a reasonable size. Below is what happened:

<a href="http://blog.tyang.org/wp-content/uploads/2012/06/image3.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/06/image_thumb3.png" alt="image" width="580" height="302" border="0" /></a>

PowerShell threw an exception:

<span style="color: #ff0000;">Processing data for a remote command failed with the following error message:</span> <span style="color: #ff0000;">&lt;f:WSManFault xmlns:f="</span><a href="http://schemas.microsoft.com/wbem/wsman/1/wsmanfault"><span style="color: #ff0000;">http://schemas.microsoft.com/wbem/wsman/1/wsmanfault</span></a><span style="color: #ff0000;">" Code="3762507597" Machine="computername"&gt;&lt;f:Message&gt;&lt;f:ProviderFault provider="microsoft.powershell" path="C:\Windows\system32\pwrshplugin.dll"&gt;&lt;/f:ProviderFault&gt;&lt;/f:Message&gt;&lt;/f:WSManFault&gt; For more information, see the about_Remote_Troubleshooting Help topic.</span>

<span style="color: #ff0000;">    + CategoryInfo          : OperationStopped: (System.Manageme...pressionSyncJob:PSInvokeExpressionSyncJob) [], PSRemotingTransportException</span>

<span style="color: #ff0000;">    + FullyQualifiedErrorId : JobFailure</span>

To make the script run, I had to increase the maximum allowed memory for PowerShell Remote session. In this case, I increased from 150MB to 512MB. I used this command to increase it:

```powershell
winrm set winrm/config/winrs `@`{MaxMemoryPerShellMB=`"512`"`}
```

After the increase, my get-agent script ran successfully:

<a href="http://blog.tyang.org/wp-content/uploads/2012/06/image41.png"><img class="alignleft size-full wp-image-1271" title="image4" src="http://blog.tyang.org/wp-content/uploads/2012/06/image41.png" alt="" width="929" height="768" /></a>

**Conclusion:**

When writing a script, we normally test it against a development or test environment. generally speaking, these environments are much much small than production environments. scripts may run perfectly in dev / test environments but because of the size of environments, we may run into situations like this. Depending on the size of the production environments, we will have to adjust the **"MaxMemoryPerShellMB"** setting for PowerShell remote sessions accordingly.