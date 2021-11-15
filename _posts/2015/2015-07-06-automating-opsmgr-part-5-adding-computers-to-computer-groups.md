---
id: 4156
title: 'Automating OpsMgr Part 5: Adding Computers to Computer Groups'
date: 2015-07-06T13:28:54+10:00
author: Tao Yang
#layout: post
excerpt: ""
header:
  overlay_image: /wp-content/uploads/2015/06/OpsMgrExnteded-banner.png
  overlay_filter: 0.5 # same as adding an opacity of 0.5 to a black background
guid: https://blog.tyang.org/?p=4156
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

## Introduction

This is the 5th instalment of the Automating OpsMgr series. Previously on this series:

* [Automating OpsMgr Part 1: Introducing OpsMgrExtended PowerShell / SMA Module](https://blog.tyang.org/2015/06/24/automating-opsmgr-part-1-introducing-opsmgrextended-powershell-sma-module/)
* [Automating OpsMgr Part 2: SMA Runbook for Creating ConfigMgr Log Collection Rules](https://blog.tyang.org/2015/06/28/automating-opsmgr-part-2-sma-runbook-for-creating-configmgr-log-collection-rules/)
* [Automating OpsMgr Part 3: New Management Pack Runbook via SMA and Azure Automation](https://blog.tyang.org/2015/06/30/automating-opsmgr-part-3-new-management-pack-runbook-via-sma-and-azure-automation/)
* [Automating OpsMgr Part 4:Creating New Empty Groups](https://blog.tyang.org/2015/07/02/automating-opsmgr-part-4-create-new-empty-groups/)

In the previous post (part 4), I have demonstrated a runbook creating new empty instance groups and computer groups using the **OpsMgrExtended** module. As I also mentioned in Part 4, I will dedicate few posts on creating and managing OpsMgr groups. So, this post is the 2nd one on this topic.

In OpsMgr, groups can be populated via Explicit memberships (static) or Dynamic Memberships (query based), or combination of both:

<a href="https://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTMLd397dca.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLd397dca" src="https://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTMLd397dca_thumb.png" alt="SNAGHTMLd397dca" width="466" height="206" border="0" /></a>

In this post, I will demonstrate how to use a runbook to add a Windows computer object to a computer group via Explicit membership.

## Runbook Add-ComputerToComputerGroup

```powershell
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
```

When using this runbook, you will need to update line 9 of the runbook, and replace the SMA connection name with the one you've used in your SMA environment:

<a href="https://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTMLd3cc63e.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLd3cc63e" src="https://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTMLd3cc63e_thumb.png" alt="SNAGHTMLd3cc63e" width="688" height="488" border="0" /></a>

This runbook requires 2 mandatory parameters:

* Windows computer principal name (FQDN) - which is the key property of the Windows Computer object

<a href="https://blog.tyang.org/wp-content/uploads/2015/07/image17.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/07/image_thumb17.png" alt="image" width="400" height="291" border="0" /></a>

* The group name - it's the internal name, not the display name. I did not use the display name because it is not unique. i.e.

<a href="https://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTMLd5db064.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLd5db064" src="https://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTMLd5db064_thumb.png" alt="SNAGHTMLd5db064" width="453" height="144" border="0" /></a>

**<span style="color: #ff0000; font-size: small;">Note:</span>**

If the group was created using the **New-OMComputerGroup** and <strong>New-OMInstanceGroup</strong> functions from the OpsMgrExtended module, these 2 functions would automatically prepend the management pack name in front of the group name specified by the user (if the management pack name is not already the prefix of the specified names). I forgot to mention this behaviour in my previous post (Part 4).

Since the OpsMgrExtended module does not (yet) have a function to add a computer to a computer group, I wrote this runbook to perform this task directly via OpsMgr SDK (therefore all within the inlinescript). The high level steps for this runbook is listed below:

1. Establish OpsMgr management group connection (and the SDK assemblies will be loaded automatically).
2. Get the Windows computer monitoring object
3. Get the computer group monitoring class (singleton class)
4. Check if the group object specified is indeed a computer group
5. Get the computer group instance
6. Get the computer group discovery
7. Make sure the discovery is defined in an unsealed management pack
8. Detect if any "MembershipRule" segments in discovery data source module contains existing static members
9. If there are existing static members in one of the membership rule, add the Windows computer as a static member in the membership rule.
10. If none of the membership rules contain static members, define a static member section ("<IncludeList>") in the first Membership Rule.
11. Update the unsealed management pack where the discovery is defined.

## Executing Runbook

Group membership before execution:

<a href="https://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTMLd56ca18.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLd56ca18" src="https://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTMLd56ca18_thumb.png" alt="SNAGHTMLd56ca18" width="437" height="152" border="0" /></a>

Executing runbook:

<a href="https://blog.tyang.org/wp-content/uploads/2015/07/image18.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/07/image_thumb18.png" alt="image" width="430" height="372" border="0" /></a>

<a href="https://blog.tyang.org/wp-content/uploads/2015/07/image19.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/07/image_thumb19.png" alt="image" width="429" height="415" border="0" /></a>

Group membership after execution:

<a href="https://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTMLd586a6a.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLd586a6a" src="https://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTMLd586a6a_thumb.png" alt="SNAGHTMLd586a6a" width="457" height="95" border="0" /></a>

## Conclusion

In this post, I have demonstrated how to use a runbook and OpsMgrExtended module to add a Windows computer object as a static member of a computer group.

I've also demonstrated even when an activity is not pre-defined in the OpsMgrExnteded module, we can still leverage OpsMgrExnteded module to perform the task because we can directly interact with OpsMgr management groups and SDKs via this module - by using the **Connect-OMManagementGroup** function, the SDK will be loaded automatically.

When I was writing this runbook few days ago, I have realised this is something I should have included in the OpsMgrExtended module because it could be very common and useful. Although I've published this as a rather complex runbook at this stage, I will probably included this as an additional function in the future release of OpsMgrExtended module.

I will demonstrate how to add a explicit member to an instance group in the Part 6 of this series.