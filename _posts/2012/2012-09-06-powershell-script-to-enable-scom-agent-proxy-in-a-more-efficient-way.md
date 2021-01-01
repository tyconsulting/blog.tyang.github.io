---
id: 1412
title: PowerShell Script To Enable SCOM Agent Proxy in a More Efficient Way
date: 2012-09-06T23:56:57+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=1412
permalink: /2012/09/06/powershell-script-to-enable-scom-agent-proxy-in-a-more-efficient-way/
categories:
  - PowerShell
  - SCOM
tags:
  - PowerShell
  - SCOM
---
if you search on how to enable SCOM agent proxy for all your SCOM agents using PowerShell, you’ll get lots of posts and scripts that shows you how to do it in SCOM 2007 or 2012. In fact, I have written few back in the days.

However, no matter if the script uses SCOM 2007 PowerShell Snap-in, or SCOM 2012 PowerShell module, or even SCOM SDK, there is one limitation: the "ProxyingEnabled" property of the agent class is not one of the search criteria that you can use when retrieving the agent:

<a href="http://blog.tyang.org/wp-content/uploads/2012/09/image2.png"><img style="padding-left: 0px;padding-right: 0px;padding-top: 0px;border: 0px" src="http://blog.tyang.org/wp-content/uploads/2012/09/image_thumb2.png" alt="image" width="512" height="279" border="0" /></a>

If you use the SCOM SDK, there are only 4 property names that can be used in the search criteria expression:
<ul>
	<li>Id</li>
	<li>Name</li>
	<li>LastModified</li>
	<li>DisplayName</li>
</ul>
ref: <a href="http://msdn.microsoft.com/en-us/library/microsoft.enterprisemanagement.administration.agentmanagedcomputercriteria.aspx">http://msdn.microsoft.com/en-us/library/microsoft.enterprisemanagement.administration.agentmanagedcomputercriteria.aspx</a>

So in order to retrieve the agents that are not ProxyingEnabled, we can only client-side filtering, which retrieves ALL agents in the management group and then filter-out the ones that ProxyingEnabled is set to False.

i.e.

<strong>Using SCOM 2007 PowerShell Snap-in:</strong>

```powershell
Get-agent | where-object {$_.ProxyingEnabled -match "false"}| foreach {$_.ProxyingEnabled = $true; $_.applyChanges()}
```

<strong>Using SCOM 2012 PowerShell Module:</strong>

```powershell
Get-SCOMAgent | where-object {$_.ProxyingEnabled –match "false"} | Enable-SCOMAgentProxy
```

<strong>Using SCOM SDK in PowerShell:</strong>

```powershell
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.EnterpriseManagement.OperationsManager.Common") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.EnterpriseManagement.OperationsManager") | Out-Null

$RMS = "RMS SERVER NAME"

$MGConnSetting = New-Object Microsoft.EnterpriseManagement.ManagementGroupConnectionSettings(RMS )
$MG = New-Object Microsoft.EnterpriseManagement.ManagementGroup($MGConnSetting)

#Get MG Admin
$Admin = $MG.GetAdministration()

#Search agents
$Agents = $Admin.GetAllAgentManagedComputers()
Foreach ($Agent in $Agents)
{
	If (!($Agent.ProxyingEnabled.Value))
	{
    Write-Host "Enabling Agent Proxy for $($Agent.Name)`..."
    $Agent.ProxyingEnabled = $true
    $Agent.ApplyChanges()
	}
}
```

Imagine in a large management group with few thousands agents or more and there are only couple of agents that don’t have Agent Proxy enabled. the script / cmdlet will take a long time and a lot of system resources to run because it needs to retrieve information of ALL agents first!

So I wrote a PowerShell script to perform this task a bit differently:

* Firstly run a SQL query against SCOM operational database to retrieve a list of agents that do not have agent proxy enabled
* connect to SCOM SDK and for each agent retrieved from the database, turn on agent proxy.

This is much more efficient as it only retrieves agents that do not have agent proxy enabled, not the whole lot!

The script uses SCOM SDK, it works on both 2007 and 2012 environments.

Syntax:

To run it on a SCOM management server, no other parameters need to be specified.

<a href="http://blog.tyang.org/wp-content/uploads/2012/09/image3.png"><img style="padding-left: 0px;padding-right: 0px;padding-top: 0px;border: 0px" src="http://blog.tyang.org/wp-content/uploads/2012/09/image_thumb3.png" alt="image" width="522" height="84" border="0" /></a>

To run it on a SCOM agent, you will need to specify a management server in the management group that you wish to connect to (does not have to be RMS or RMSE)

<a href="http://blog.tyang.org/wp-content/uploads/2012/09/image4.png"><img style="padding-left: 0px;padding-right: 0px;padding-top: 0px;border: 0px" src="http://blog.tyang.org/wp-content/uploads/2012/09/image_thumb4.png" alt="image" width="580" height="93" border="0" /></a>

Additionally, the default SQL query timeout is set to 120 seconds, you can specify a different value by using the<strong> –SQLQueryTimeout</strong> parameter

<a href="http://blog.tyang.org/wp-content/uploads/2012/09/image5.png"><img style="padding-left: 0px;padding-right: 0px;padding-top: 0px;border: 0px" src="http://blog.tyang.org/wp-content/uploads/2012/09/image_thumb5.png" alt="image" width="580" height="93" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2012/09/Enable-AgentProxy-v2.5.zip">DOWNLOAD Enable-AgentProxy.ps1</a>

By the way, I also tried to run below SQL command to directly change the ProxyingEnabled attribute in the database (similar to <a href="http://blogs.technet.com/b/kevinholman/archive/2010/02/20/how-to-get-your-agents-back-to-remotely-manageable-in-opsmgr-2007-r2.aspx">Kevin Holman’s query to change all agents to remote manageable</a>):

```sql
Update MT_HealthService Set ProxyingEnabled = 1 where ProxyingEnabled = 0
```

After I ran this SQL command, the agent proxy setting did get updated in the SCOM console, but I’m not sure if this is supported or not, thus I wrote this script instead.