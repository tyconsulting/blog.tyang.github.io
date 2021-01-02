---
id: 3258
title: 'Use of ConfigMgr 2012 Client MP: Real Life Examples'
date: 2014-10-16T13:53:51+10:00
author: Tao Yang
#layout: post
excerpt: ""
header:
  overlay_image: /wp-content/uploads/2014/10/Compliance.png
  overlay_filter: 0.5 # same as adding an opacity of 0.5 to a black background
guid: http://blog.tyang.org/?p=3258
permalink: /2014/10/16/use-configmgr-2012-client-mp-real-life-examples/
categories:
  - SCCM
  - SCOM
tags:
  - SCCM
  - SCOM
---

Last week, while I was assisting with few production issues in a ConfigMgr 2012 environment, I had to quickly implement some monitoring for some ConfigMgr 2012 site systems. By utilising the most recent release of ConfigMgr 2012 Client management pack (version 1.2.0.0) and few DCM baselines, I managed to achieve the goals in a short period of time. The purpose of this post is to share my experience and hopefully someone can pick few tips and tricks from it.

## Background

We are in the process of rebuilding few hundreds sites from Windows Server 2008 R2 / System Center 2007 R2 to Windows Server 2012 R2 / System Center 2012 R2. Last week, the support team has identified few issues during the conversion process. I have been asked to assist. In this post, I will go through 2 particular issues, and also how I setup monitoring so support team and management have a clearer picture of the real impact.

<strong>Issue 1:</strong> WinRM connectivity issues caused by duplicate computer accounts in AD.

The conversion process involves rebuilding some physical and virtual servers from Windows Server 2008 R2 to Windows Server 2012 R2. When they’ve been rebuilt, they’ve also been moved from Domain A to Domain B (in the same forest) while the computer name remains the same. the support team found they cannot establish WinRM connections to some servers after the rebuild. They got some Kerberos related errors. I had a quick look and found the issue was caused by not having old computer account removed from Domain A, so WinRM using just the NetBIOS name would fail but using FQDN is OK. Although the entire conversion process is automated using Service Manager and Orchestrator, and there is an activity in one of the runbooks deletes old computer accounts, somehow this did not happen to everyone. Moving forward, the support team needs to be notified via SCOM when duplicate computer accounts exists for any computers.

<strong>Issue 2:</strong> WDS service on ConfigMgr 2012 Distribution Points been mysteriously uninstalled

It took us and Microsoft Premier support few days to identify the cause, I won’t go into the details. But we need to be able to identify from the Distribution Point itself if it is still a PXE enabled DP.

To achieve both goals, I created 2 DCM baselines and targeted them to appropriate collections in ConfigMgr.

## Duplicate AD Computer Account Baseline

This baseline contains only 1 Configuration Item (CI). the CI uses a script to detect if the computer account exists in other domains. Here’s the script (note the domain names need to be modified in the first few lines):

```powershell
#list of domains to check
$arrDomains = new-object System.Collections.Arraylist
[void]$arrDomains.Add('DoaminA.ForestName')
[void]$arrDomains.Add('DoaminB.ForestName')
[void]$arrDomains.Add('ForestName')

#region functions
Function Search-ADComputer
{
  param
  (
    [String]$domain,
    [String]$ComputerName
  )

  #Get Domain DN
  If ($DomainDN)
  {
    Remove-Variable DomainDN
  }
  $DomainSplit = $domain.split('.')
  For ($i=0; $i -lt $DomainSplit.count; $i++)
  {
    $DC = $DomainSplit[$i]
    $DomainDN = $DomainDN + ",DC=$DC"
  }
  $DomainDN = $($DomainDN.TrimEnd(',')).TrimStart(',')
  $DomainDN = "LDAP://$DomainDN"
  $Searcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher
  $Searcher.SearchRoot = $DomainDN
  $Searcher.Filter = "(&(objectCategory=Computer)(name=$ComputerName))"
  Try {
    FOREACH ($Computer in $($Searcher.FindAll()))
    {
      $DN = $($Computer.properties.distinguishedname)
    }
  } Catch {
    $DN = $NULL
  }
  $DN
}
#endregion

#Get computer name and domain
$objCS = Get-WmiObject Win32_ComputerSystem
$ComputerName = $objCS.DNSHostName
$Domain = $objCS.domain.tolower()

#Remove the current domain from arraylist
if ($arrDomains.contains($Domain)){
  $arrDomains.Remove($Domain)
}

#Search other domains
$bDuplicateFound = $false
Foreach ($domain in $arrDomains)
{
  $SearchResult = Search-ADComputer $domain $ComputerName
  If ($SearchResult)
  {
    $bDuplicateFound = $true
  }
}
$bDuplicateFound
```
In order for the CI to be compliant, the return value from the script needs to be "False" (no duplicate accounts found).

<a href="http://blog.tyang.org/wp-content/uploads/2014/10/image7.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/10/image_thumb7.png" alt="image" width="431" height="447" border="0" /></a>

## Distribution Point Configuration Baseline

This baseline also only contain 1 CI. Since it contains application setting, I used a very simple script to detect the existence of the ConfigMgr DP:

<a href="http://blog.tyang.org/wp-content/uploads/2014/10/image8.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/10/image_thumb8.png" alt="image" width="485" height="480" border="0" /></a>

The compliant condition for the CI is set to:
<ul>
	<li>Reg value "HKLM\SOFTWARE\Microsoft\SMS\DP\IsPXE" must exist and set to 1</li>
	<li>Reg value "HKLM\SOFTWARE\Microsoft\SMS\DP\PXEInstalled" must exist and set to 1</li>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2014/10/SNAGHTML62e005e.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML62e005e" src="http://blog.tyang.org/wp-content/uploads/2014/10/SNAGHTML62e005e_thumb.png" alt="SNAGHTML62e005e" width="498" height="235" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2014/10/SNAGHTML62e9fb8.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML62e9fb8" src="http://blog.tyang.org/wp-content/uploads/2014/10/SNAGHTML62e9fb8_thumb.png" alt="SNAGHTML62e9fb8" width="499" height="223" border="0" /></a>

## Alerting through OpsMgr

Once I’ve setup and deployed these 2 baselines to appropriate collections, everything has been setup in ConfigMgr. I can now take the ConfigMgr admin hat off.

So what do I need to configure now in OpsMgr for the alerts to go through? The answer is: Nothing! Since the ConfigMgr 2012 Client MP (version 1.2.0.0) has already been implemented in the OpsMgr management group, I don’t need to put on the OpsMgr admin hat because there’s nothing else I need to do. Within few hours, the newly created baselines will be discovered in OpsMgr, and start being monitored:

<a href="http://blog.tyang.org/wp-content/uploads/2014/10/SNAGHTML635de7c.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML635de7c" src="http://blog.tyang.org/wp-content/uploads/2014/10/SNAGHTML635de7c_thumb.png" alt="SNAGHTML635de7c" width="558" height="367" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2014/10/SNAGHTML6373dbb.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML6373dbb" src="http://blog.tyang.org/wp-content/uploads/2014/10/SNAGHTML6373dbb_thumb.png" alt="SNAGHTML6373dbb" width="554" height="302" border="0" /></a>

## Conclusion

By utilising the DCM baseline monitoring capability in ConfigMgr 2012 Client MP can greatly simply the processes of monitoring configuration items of targeted endpoints. As showed in these 2 examples, there is no requirement of having OpsMgr administrators involved. Additionally, it is much simpler to create collections for deploying DCM baselines than defining target classes and discoveries in OpsMgr (in order to target the monitors / rules). I encourage you (both ConfigMgr admins and OpsMgr admins) to give it a try, and hopefully you will find it beneficial.