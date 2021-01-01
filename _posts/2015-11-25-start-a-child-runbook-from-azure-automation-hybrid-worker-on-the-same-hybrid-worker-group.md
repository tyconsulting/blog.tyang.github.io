---
id: 4880
title: Start A Child Runbook From Azure Automation Hybrid Worker on the Same Hybrid Worker Group
date: 2015-11-25T15:03:15+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=4880
permalink: /2015/11/25/start-a-child-runbook-from-azure-automation-hybrid-worker-on-the-same-hybrid-worker-group/
categories:
  - Azure
  - OMS
tags:
  - Azure Automation
  - OMS
---
Today I was writing a PowerShell runbook (let’s call it Runbook A) that’s designed to run on on-prem hybrid workers. At the end of Runbook A, I needed to kick off another runbook (let’s call it Runbook B) that must run on the same Hybrid Worker group. Because I don’t want to hardcode the Hybrid Worker group name in the script (or using an Automation variable), I wrote a very simple function that returns the Hybrid Worker configuration (including the Hybrid Worker group name) from registry if runs on a Hybrid Worker.

To use it, simply place the function shown below in the parent runbook (Runbook A in this case), and call this function to retrieve the Hybrid Worker configuration.

<strong>Function:</strong>
<pre language="PowerShell">Function Get-HybridWorkerConfig
{
    $RegKeyPath = "HKLM:\SOFTWARE\Microsoft\HybridRunbookWorker"
    If (Test-Path $RegKeyPath)
    {
        Get-ItemProperty $RegKeyPath
    } else {
        $null
    }
}
</pre>
<a href="http://blog.tyang.org/wp-content/uploads/2015/11/SNAGHTML2f76e97b.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML2f76e97b" src="http://blog.tyang.org/wp-content/uploads/2015/11/SNAGHTML2f76e97b_thumb.png" alt="SNAGHTML2f76e97b" width="709" height="324" border="0" /></a>

<strong>Code Sample:</strong>
<pre language="PowerShell">#Get the Hybrid Worker group name
$HybridWorkerGroup = (Get-HybridWorkerConfig).RunbookWorkerGroup

#Preparing input parameters for Runbook B
$params = @{
    "Parameter1" = 'Value1';
    "Parameter2" = 'Value2';
    "Parameter3" = 'Value3'
	}

#Log on the Azure using Login-AzureRmAccount cmdlet
Login-AzureRmAccount -Credential $AzureCred -SubscriptionName $SubscriptionName

#Start Runbook B using Start-AzureRmAutomationRunbook cmdlet
Start-AzureRmAutomationRunbook -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name "RunbookB" -Parameters $params -RunOn $HybridWorkerGroup

</pre>
<strong>Note:</strong>

The Get-HybridWorkerConfig function would return $null value if the computer is not a Hybrid Worker.