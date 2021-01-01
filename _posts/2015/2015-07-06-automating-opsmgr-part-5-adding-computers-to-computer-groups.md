---
id: 4156
title: 'Automating OpsMgr Part 5: Adding Computers to Computer Groups'
date: 2015-07-06T13:28:54+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=4156
permalink: /2015/07/06/automating-opsmgr-part-5-adding-computers-to-computer-groups/
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
This is the 5th instalment of the Automating OpsMgr series. Previously on this series:
<ul>
	<li><a href="http://blog.tyang.org/2015/06/24/automating-opsmgr-part-1-introducing-opsmgrextended-powershell-sma-module/">Automating OpsMgr Part 1: Introducing OpsMgrExtended PowerShell / SMA Module</a></li>
	<li><a href="http://blog.tyang.org/2015/06/28/automating-opsmgr-part-2-sma-runbook-for-creating-configmgr-log-collection-rules/">Automating OpsMgr Part 2: SMA Runbook for Creating ConfigMgr Log Collection Rules</a></li>
	<li><a href="http://blog.tyang.org/2015/06/30/automating-opsmgr-part-3-new-management-pack-runbook-via-sma-and-azure-automation/">Automating OpsMgr Part 3: New Management Pack Runbook via SMA and Azure Automation</a></li>
	<li><a href="http://blog.tyang.org/2015/07/02/automating-opsmgr-part-4-create-new-empty-groups/" target="_blank">Automating OpsMgr Part 4:Creating New Empty Groups</a></li>
</ul>
In the previous post (part 4), I have demonstrated a runbook creating new empty instance groups and computer groups using the <strong>OpsMgrExtended</strong> module. As I also mentioned in Part 4, I will dedicate few posts on creating and managing OpsMgr groups. So, this post is the 2nd one on this topic.

In OpsMgr, groups can be populated via Explicit memberships (static) or Dynamic Memberships (query based), or combination of both:

<a href="http://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTMLd397dca.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLd397dca" src="http://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTMLd397dca_thumb.png" alt="SNAGHTMLd397dca" width="466" height="206" border="0" /></a>

In this post, I will demonstrate how to use a runbook to add a Windows computer object to a computer group via Explicit membership.
<h3>Runbook Add-ComputerToComputerGroup</h3>
<pre language="PowerShell" class="">
Workflow Add-ComputerToComputerGroup
{
	Param(
    [Parameter(Mandatory=$true)][String]$GroupName,
    [Parameter(Mandatory=$true)][String]$ComputerPrincipalName
    )

	#Get OpsMgrSDK connection object
    $OpsMgrSDKConn = Get-AutomationConnection -Name "OpsMgrSDK_TYANG"
	$bComputerAdded = Inlinescript {
		#Connecting to the management group
		$MG = Connect-OMManagementGroup -SDKConnection $USING:OpsMgrSDKConn
        
		#Get the windows computer object
		Write-Verbose "Getting the Windows computer monitoring object for '$USING:ComputerPrincipalName'"
		$WinComputerObjectCriteria = New-Object Microsoft.EnterpriseManagement.Monitoring.MonitoringObjectGenericCriteria("FullName = 'Microsoft.Windows.Computer:$USING:ComputerPrincipalName'")
		$WinComputer = $MG.GetMonitoringObjects($WinComputerObjectCriteria)[0]
		If ($WinComputer -eq $null)
		{
			Write-Error "Unable to find the Microsoft.Windows.Computer object for '$USING:ComputerPrincipalName'."
			Return $false
		}
		$WinComputerID = $WinComputer.Id.ToString()
		Write-Verbose "Monitoring Object ID for '$USING:ComputerPrincipalName': '$WinComputerID'"

		#Get the group
		Write-Verbose "Getting the computer group '$USING:GroupName'."
		$ComputerGroupClassCriteria = New-Object Microsoft.EnterpriseManagement.Configuration.MonitoringClassCriteria("Name='$USING:GroupName'")
		$ComputerGroupClass = $MG.GetMonitoringClasses($ComputerGroupClassCriteria)[0]
		If ($ComputerGroupClass -eq $null)
		{
			Write-Error "$Using:GroupName is not found."
			Return $false
		}
		#Check if this monitoring class is actually a computer group
		Write-Verbose "Check if the group '$USING:GroupName' is a computer group"
		$ComputerGroupBaseTypes = $ComputerGroupClass.GetBaseTypes()
		$bIsComputerGroup = $false
		Foreach ($item in $ComputerGroupBaseTypes)
		{
			If ($item.Id.Tostring() -eq '0c363342-717b-5471-3aa5-9de3df073f2a')
			{
				$bIsComputerGroup = $true
			}
		}
		If ($bIsComputerGroup -eq $false)
		{
			Write-Error "$Using:GroupName is not a computer group"
			Return $false
		}

		#Get Group object
		$ComputerGroupObject = $MG.GetMonitoringObjects($ComputerGroupClass)[0]

		#Get Group population discovrey
		Write-Verbose "Getting the group discovery rule"
		$ComputerGroupDiscoveries = $ComputerGroupObject.GetMonitoringDiscoveries()
		$iGroupPopDiscoveryCount = 0
		$GroupPopDiscovery = $null
		Foreach ($Discovery in $ComputerGroupDiscoveries)
		{
			$DiscoveryDS = $Discovery.DataSource
			#Microsft.SystemCenter.GroupPopulator ID is 488000ef-e20b-1ac4-d3b1-9d679435e1d7
			If ($DiscoveryDS.TypeID.Id.ToString() -eq '488000ef-e20b-1ac4-d3b1-9d679435e1d7')
			{
				#This data source module is using Microsft.SystemCenter.GroupPopulator
				$iGroupPopDiscoveryCount = $iGroupPopDiscoveryCount + 1
				$GroupPopDiscovery = $Discovery
				Write-Verbose "Group Populator discovery found: '$($GroupPopDiscovery.Name)'"
			}
		}
		If ($iGroupPopDiscoveryCount.count -eq 0)
		{
			Write-Error "No group populator discovery found for $Group."
			Return $false
		}

		If ($iGroupPopDiscoveryCount.count -gt 1)
		{
			Write-Error "$Group has multiple discoveries using Microsft.SystemCenter.GroupPopulator Module type."
			Return $false
		}
		#Get the MP of where the group populator discovery is defined
		$GroupPopDiscoveryMP = $GroupPopDiscovery.GetManagementPack()
		Write-Verbose "The group populator discovery '$($GroupPopDiscovery.Name)' is defined in management pack '$($GroupPopDiscoveryMP.Name)'."

		#Write Error and exit if the MP is sealed
		If ($GroupPopDiscoveryMP.sealed -eq $true)
		{
			Write-Error "Unable to update the group discovery because it is defined in a sealed MP: '$($GroupPopDiscoveryMP.DisplayName)'."
			Return $false
		}
		Write-Verbose "Updating the discovery data source configuration"
		$GroupDSConfig = $GroupPopDiscovery.Datasource.Configuration
		$GroupDSConfigXML = [XML]"<Configuration>$GroupDSConfig</Configuration>"

		#Detect if any MembershipRule segment contains existing static members
		$bComputerAdded = $false
		Foreach ($MembershipRule in $GroupDSConfigXML.Configuration.MembershipRules.MembershipRule)
		{
			If ($MembershipRule.IncludeList -ne $Null -and $bComputerAdded -eq $false)
			{
				#Add the monitoroing object ID of the Windows computer to the <IncludeList> node
				Write-Verbose "Adding '$USING:ComputerPrincipalName' monitoring Object ID '$WinComputerID' to the <IncludeList> node in the group populator configuration"
				$NewMOId = $MembershipRule.IncludeList.AppendChild($GroupDSConfigXML.CreateElement("MonitoringObjectId"))
				$NewMOId.InnerText = $WinComputerID
				$bComputerAdded = $true
			}
		}
		#If none of the MembershipRule has <IncludeList segment>, create it in the first MembershipRule
		If ($bComputerAdded -eq $false)
		{
			If ($GroupDSConfigXML.Configuration.MembershipRules.MembershipRule -Is [System.Array])
            {
                Write-Verbose "Multiple Membership rules. creating <IncludeList> within the first <MembershipRule>"
                $IncludeListNode = $GroupDSConfigXML.Configuration.MembershipRules.MembershipRule[0].AppendChild($GroupDSConfigXML.CreateElement("IncludeList"))
            } else {
                Write-Verbose "There is only one Membership rule. creating <IncludeList> in it."
                $IncludeListNode = $GroupDSConfigXML.Configuration.MembershipRules.MembershipRule.AppendChild($GroupDSConfigXML.CreateElement("IncludeList"))
            }
			$NewMOId = $IncludeListNode.AppendChild($GroupDSConfigXML.CreateElement("MonitoringObjectId"))
			$NewMOId.InnerText = $WinComputerID
		}
		$UpdatedGroupPopConfig = $GroupDSConfigXML.Configuration.InnerXML
		#Updating the discovery
		Write-Verbose "Updating the group discovery"
		Try {
			$GroupPopDiscovery.Datasource.Configuration = $UpdatedGroupPopConfig
			$GroupPopDiscovery.Status = [Microsoft.EnterpriseManagement.Configuration.ManagementPackElementStatus]::PendingUpdate
			$GroupPopDiscoveryMP.AcceptChanges()
			$bComputerAdded = $true
		} Catch {
			$bComputerAdded = $false
		}
		$bComputerAdded
	}
	If ($bComputerAdded -eq $true)
	{
		Write-Output "Done."
	} else {
		throw "Unable to add '$ComputerPrincipalName' to group '$GroupName'."
		exit
	}
}
</pre>
When using this runbook, you will need to update line 9 of the runbook, and replace the SMA connection name with the one you've used in your SMA environment:

<a href="http://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTMLd3cc63e.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLd3cc63e" src="http://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTMLd3cc63e_thumb.png" alt="SNAGHTMLd3cc63e" width="688" height="488" border="0" /></a>

This runbook requires 2 mandatory parameters:
<ul>
	<li>Windows computer principal name (FQDN) - which is the key property of the Windows Computer object</li>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2015/07/image17.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/07/image_thumb17.png" alt="image" width="400" height="291" border="0" /></a>
<ul>
	<li>The group name - it's the internal name, not the display name. I did not use the display name because it is not unique. i.e.</li>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTMLd5db064.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLd5db064" src="http://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTMLd5db064_thumb.png" alt="SNAGHTMLd5db064" width="453" height="144" border="0" /></a>

<strong><span style="color: #ff0000; font-size: small;">Note:</span></strong>

If the group was created using the <strong>New-OMComputerGroup</strong> and <strong>New-OMInstanceGroup</strong> functions from the OpsMgrExtended module, these 2 functions would automatically prepend the management pack name in front of the group name specified by the user (if the management pack name is not already the prefix of the specified names). I forgot to mention this behaviour in my previous post (Part 4).

Since the OpsMgrExtended module does not (yet) have a function to add a computer to a computer group, I wrote this runbook to perform this task directly via OpsMgr SDK (therefore all within the inlinescript). The high level steps for this runbook is listed below:
<ol>
	<li>Establish OpsMgr management group connection (and the SDK assemblies will be loaded automatically).</li>
	<li>Get the Windows computer monitoring object</li>
	<li>Get the computer group monitoring class (singleton class)</li>
	<li>Check if the group object specified is indeed a computer group</li>
	<li>Get the computer group instance</li>
	<li>Get the computer group discovery</li>
	<li>Make sure the discovery is defined in an unsealed management pack</li>
	<li>Detect if any "MembershipRule" segments in discovery data source module contains existing static members</li>
	<li>If there are existing static members in one of the membership rule, add the Windows computer as a static member in the membership rule.</li>
	<li>  If none of the membership rules contain static members, define a static member section ("&lt;IncludeList&gt;") in the first Membership Rule.</li>
	<li>Update the unsealed management pack where the discovery is defined.</li>
</ol>
&nbsp;
<h3>Executing Runbook</h3>
Group membership before execution:

<a href="http://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTMLd56ca18.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLd56ca18" src="http://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTMLd56ca18_thumb.png" alt="SNAGHTMLd56ca18" width="437" height="152" border="0" /></a>

Executing runbook:

<a href="http://blog.tyang.org/wp-content/uploads/2015/07/image18.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/07/image_thumb18.png" alt="image" width="430" height="372" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2015/07/image19.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/07/image_thumb19.png" alt="image" width="429" height="415" border="0" /></a>

Group membership after execution:

<a href="http://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTMLd586a6a.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLd586a6a" src="http://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTMLd586a6a_thumb.png" alt="SNAGHTMLd586a6a" width="457" height="95" border="0" /></a>
<h3>Conclusion</h3>
In this post, I have demonstrated how to use a runbook and OpsMgrExtended module to add a Windows computer object as a static member of a computer group.

I've also demonstrated even when an activity is not pre-defined in the OpsMgrExnteded module, we can still leverage OpsMgrExnteded module to perform the task because we can directly interact with OpsMgr management groups and SDKs via this module - by using the <strong>Connect-OMManagementGroup</strong> function, the SDK will be loaded automatically.

When I was writing this runbook few days ago, I have realised this is something I should have included in the OpsMgrExtended module because it could be very common and useful. Although I've published this as a rather complex runbook at this stage, I will probably included this as an additional function in the future release of OpsMgrExtended module.

I will demonstrate how to add a explicit member to an instance group in the Part 6 of this series.