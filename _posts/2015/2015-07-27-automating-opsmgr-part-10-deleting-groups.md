---
id: 4272
title: 'Automating OpsMgr Part 10: Deleting Groups'
date: 2015-07-27T16:02:54+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=4272
permalink: /2015/07/27/automating-opsmgr-part-10-deleting-groups/
categories:
  - PowerShell
  - SCOM
  - SMA
tags:
  - Automating OpsMgr
  - PowerShell
  - SCOM
  - SMA
---
<h3><a href="http://blog.tyang.org/wp-content/uploads/2015/06/OpsMgrExnteded.png"><img class="alignleft size-thumbnail wp-image-4038" src="http://blog.tyang.org/wp-content/uploads/2015/06/OpsMgrExnteded-150x150.png" alt="OpsMgrExnteded" width="150" height="150" /></a>Introduction</h3>
This is the 10th instalment of the Automating OpsMgr series. Previously on this series:
<ul>
	<li><a href="http://blog.tyang.org/2015/06/24/automating-opsmgr-part-1-introducing-opsmgrextended-powershell-sma-module/">Automating OpsMgr Part 1: Introducing OpsMgrExtended PowerShell / SMA Module</a></li>
	<li><a href="http://blog.tyang.org/2015/06/28/automating-opsmgr-part-2-sma-runbook-for-creating-configmgr-log-collection-rules/">Automating OpsMgr Part 2: SMA Runbook for Creating ConfigMgr Log Collection Rules</a></li>
	<li><a href="http://blog.tyang.org/2015/06/30/automating-opsmgr-part-3-new-management-pack-runbook-via-sma-and-azure-automation/">Automating OpsMgr Part 3: New Management Pack Runbook via SMA and Azure Automation</a></li>
	<li><a href="http://blog.tyang.org/2015/07/02/automating-opsmgr-part-4-create-new-empty-groups/">Automating OpsMgr Part 4:Creating New Empty Groups</a></li>
	<li><a href="http://blog.tyang.org/2015/07/06/automating-opsmgr-part-5-adding-computers-to-computer-groups/">Automating OpsMgr Part 5: Adding Computers to Computer Groups</a></li>
	<li><a href="http://blog.tyang.org/2015/07/13/automating-opsmgr-part-6-adding-monitoring-objects-to-instance-groups/">Automating OpsMgr Part 6: Adding Monitoring Objects to Instance Groups</a></li>
	<li><a href="http://blog.tyang.org/2015/07/17/automating-opsmgr-part-7-updated-opsmgrextended-module/">Automating OpsMgr Part 7: Updated OpsMgrExtended Module</a></li>
	<li><a href="http://blog.tyang.org/2015/07/17/automating-opsmgr-part-8-adding-management-pack-references/">Automating OpsMgr Part 8: Adding Management Pack References</a></li>
	<li><a href="http://blog.tyang.org/2015/07/17/automating-opsmgr-part-9-updating-group-discoveries/" target="_blank">Automating OpsMgr Part 9: Updating Group Discoveries</a></li>
</ul>
As I have previously demonstrated how to create and update OpsMgr groups using the <strong>OpsMgrExtended</strong> module, it's now the time cover how to delete groups in OpsMgr.

Deleting groups that are defined in unsealed management packs can be easily accomplished using the <strong>Remove-OMGroup</strong> function from the OpsMgrExtended module. This function deletes the group class definition and discoveries from the unsealed MP. However, since it's very common for OpsMgr administrators to also create dependency monitors for groups (for group members health rollup), you cannot simply use Remove-OMGroup function to delete groups when there are also monitors targeting this group. Therefore, I have written  a sample runbook to delete the group as well as monitors targeting the group (if there are any).
<h3>Runbook Delete-OpsMgrGroup</h3>
```powershell

Workflow Delete-OpsMgrGroup
{
	Param(
	[Parameter(Mandatory=$true)][String]$GroupName,
	[Parameter(Mandatory=$true)][Boolean]$IncreaseMPVersion
	)
 
	#Get OpsMgrSDK connection object
	$OpsMgrSDKConn = Get-AutomationConnection -Name "OpsMgrSDK_HOME"

	#Firstly, make sure the monitors targeting this group is deleted (i.e dependency monitors for health rollup)
	Write-Verbose "Checking dependency monitors targeting the group '$GroupName'."
	$bDeleteMonitors = InlineScript {
		#Connect to MG
		$MG = Connect-OMManagementGroup -SDKConnection $USING:OpsMgrSDKConn
		$Group = $MG.GetMonitoringClasses($USING:GroupName)
		$GroupMP = $Group.GetManagementPack()
		If ($GroupMP.Sealed  -eq $true)
		{
			Write-Error "The group is defined in a sealed MP, unable to continue."
			Return $false
		}
		$GroupID = $Group.Id.ToString()
		$MonitorCriteria = New-Object Microsoft.EnterpriseManagement.Configuration.ManagementPackMonitorCriteria("Target='$GroupID'")
		$Monitors = $MG.GetMonitors($MonitorCriteria)
		Foreach ($Monitor in $Monitors)
		{
			Write-Verbose "Deleting '$($Monitor.Name)'..."
			$MonitorMP = $Monitor.GetManagementPack()
			$Monitor.Status = "PendingDelete"
			Try {
				$MonitorMP.Verify()
				$MonitorMP.AcceptChanges()
			} Catch {
				Write-Error $_.Exception.InnerException.Message
				Return $false
			}
		}
		Return $true
	}
	If ($bDeleteMonitors -eq $true)
	{
		$bGroupDeleted =Remove-OMGroup -SDKConnection $OpsMgrSDKConn -GroupName $GroupName -IncreaseMPVersion $IncreaseMPVersion
	}
	If ($bGroupDeleted -eq $true)
	{
	Write-Output "Done."
	} else {
	throw "Unable to delete group '$GroupName'."
	exit
	}
}

```
In order to use this runbook, you will need to update Line 9, with the name of your SMA connection object.

<a href="http://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTML1591389.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML1591389" src="http://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTML1591389_thumb.png" alt="SNAGHTML1591389" width="600" height="404" border="0" /></a>

This runbook takes 2 parameters:

<a href="http://blog.tyang.org/wp-content/uploads/2015/07/image37.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/07/image_thumb37.png" alt="image" width="383" height="329" border="0" /></a>

<strong>GroupName:</strong> the name of the group you are deleting. Please note you can only delete groups defined in unsealed MPs.

<strong>IncreaseMPVersion:</strong> Boolean variable, specify if the unsealed MP version should be increased by 0.0.0.1

Runbook Result:

<a href="http://blog.tyang.org/wp-content/uploads/2015/07/image38.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/07/image_thumb38.png" alt="image" width="462" height="486" border="0" /></a>

Verbose Messages (deleting dependency monitors):

<a href="http://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTML14fa1a1.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML14fa1a1" src="http://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTML14fa1a1_thumb.png" alt="SNAGHTML14fa1a1" width="678" height="467" border="0" /></a>

&nbsp;
<h3>Conclusion</h3>
This post is rather short comparing to some of the previous ones in this series. I have few ideas for the next post, but haven't decided which one am I going to write first. Anyways, until next time, happy automating!