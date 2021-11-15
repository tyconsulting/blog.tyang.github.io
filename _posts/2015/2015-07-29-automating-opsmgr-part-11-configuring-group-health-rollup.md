---
id: 4305
title: 'Automating OpsMgr Part 11: Configuring Group Health Rollup'
date: 2015-07-29T14:07:45+10:00
author: Tao Yang
#layout: post
excerpt: ""
header:
  overlay_image: /wp-content/uploads/2015/06/OpsMgrExnteded-banner.png
  overlay_filter: 0.5 # same as adding an opacity of 0.5 to a black background
guid: https://blog.tyang.org/?p=4305
permalink: /2015/07/29/automating-opsmgr-part-11-configuring-group-health-rollup/
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

This is the 11th instalment of the Automating OpsMgr series. Previously on this series:

* [Automating OpsMgr Part 1: Introducing OpsMgrExtended PowerShell / SMA Module](https://blog.tyang.org/2015/06/24/automating-opsmgr-part-1-introducing-opsmgrextended-powershell-sma-module/)
* [Automating OpsMgr Part 2: SMA Runbook for Creating ConfigMgr Log Collection Rules](https://blog.tyang.org/2015/06/28/automating-opsmgr-part-2-sma-runbook-for-creating-configmgr-log-collection-rules/)
* [Automating OpsMgr Part 3: New Management Pack Runbook via SMA and Azure Automation](https://blog.tyang.org/2015/06/30/automating-opsmgr-part-3-new-management-pack-runbook-via-sma-and-azure-automation/)
* [Automating OpsMgr Part 4:Creating New Empty Groups](https://blog.tyang.org/2015/07/02/automating-opsmgr-part-4-create-new-empty-groups/)
* [Automating OpsMgr Part 5: Adding Computers to Computer Groups](https://blog.tyang.org/2015/07/06/automating-opsmgr-part-5-adding-computers-to-computer-groups/)
* [Automating OpsMgr Part 6: Adding Monitoring Objects to Instance Groups](https://blog.tyang.org/2015/07/13/automating-opsmgr-part-6-adding-monitoring-objects-to-instance-groups/)
* [Automating OpsMgr Part 7: Updated OpsMgrExtended Module](https://blog.tyang.org/2015/07/17/automating-opsmgr-part-7-updated-opsmgrextended-module/)
* [Automating OpsMgr Part 8: Adding Management Pack References](https://blog.tyang.org/2015/07/17/automating-opsmgr-part-8-adding-management-pack-references/)
* [Automating OpsMgr Part 9: Updating Group Discoveries](https://blog.tyang.org/2015/07/17/automating-opsmgr-part-9-updating-group-discoveries/)
* [Automating OpsMgr Part 10: Deleting Groups](https://blog.tyang.org/2015/07/27/automating-opsmgr-part-10-deleting-groups/)

Since I have already covered how to create, update and delete OpsMgr groups using the **OpsMgrExtended** module, the last thing I want to cover on this topic is how to configure health rollup for the groups.

The runbook I'm demonstrating today was based on the PowerShell script in the <a href="https://blog.tyang.org/2015/07/28/opsmgr-group-health-rollup-configuration-task-management-pack/" target="_blank">OpsMgr Group Health Rollup Configuration Task MP</a> which I published yesterday. As I explained in the previous post, because instance groups do not inherit any dependency monitors for their base class, when OpsMgr admins creating groups in the console (which can only be instance groups), they are shown as "Not monitored":

<a href="https://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTMLaf5f001.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLaf5f001" src="https://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTMLaf5f001_thumb.png" alt="SNAGHTMLaf5f001" width="626" height="198" border="0" /></a>

By creating an agent task to create health rollup dependency monitors (in the OpsMgr Group Health Rollup Configuration Task MP), I have provided a more user friendly way for OpsMgr users to configure health rollup for groups, but this task won't help us when we are designing an automation solution. Therefore, I have written a SMA runbook based on the script I developed for the MP.

## Runbook: Configure-GroupHealthRollup

```powershell
Workflow Configure-GroupHealthRollup
{
  PARAM (
    [Parameter(Mandatory=$true,HelpMessage='Please enter the group name')][Alias('g','group')][String]$GroupName,
    [Parameter(Mandatory=$true,HelpMessage='Please specify the algorithm to use for determining health state')][Alias('a')][ValidateSet('BestOf','WorstOf','Percentage')][String]$Algorithm,
    [Parameter(Mandatory=$false,HelpMessage='Please specify the percentage value (required when algorithm is Percentage).')][Alias('percent')][ValidateScript({if ($Algorithm -ieq 'percentage'){$_ -gt 0}})][Int]$Percentage=60,
    [Parameter(Mandatory=$false,HelpMessage='Please specify the health state when the member is unavailable.')][Alias('unavailable')][ValidateSet('Uninitialized','Success ','Warning','Error')][String]$MemberUnavailable = "Error",
    [Parameter(Mandatory=$false,HelpMessage='Please specify the health state when the member is in maintenance mode.')][Alias('maintenancemode')][ValidateSet('Uninitialized','Success ','Warning','Error')][String]$MemberInMaintenance,
    [Parameter(Mandatory=$false,HelpMessage='Please enter the Management Pack name of which the monitors going to be saved. This is only going to be used when the group is defined in a sealed MP.')][Alias('mp','ManagementPack')][String]$ManagementPackName,
    [Parameter(Mandatory=$false,HelpMessage='Increase MP version by 0.0.0.1')][Boolean]$IncreaseMPVersion
  )

  #Get OpsMgrSDK connection object
  $OpsMgrSDKConn = Get-AutomationConnection -Name "OpsMgrSDK_HOME"

  $bRollupConfigured = InlineScript {
  #Connect to MG
  $MG = Connect-OMManagementGroup -SDKConnection $USING:OpsMgrSDKConn

  #Get the group class
  Write-Verbose "Getting the group class '$USING:GroupName'."
  $GroupClassCriteria = New-Object Microsoft.EnterpriseManagement.Configuration.MonitoringClassCriteria("Name='$USING:GroupName'")
  $GroupClass = $MG.GetMonitoringClasses($GroupClassCriteria)[0]
  If ($GroupClass -eq $null)
  {
    Write-Error "$USING:GroupName is not found."
    Return $false
  }

  If ($GroupClass.DisplayName -ne $null)
  {
    $GroupDisplayName = $GroupClass.DisplayName
  } else {
    $GroupDisplayName = $USING:GroupName
  }
  Write-Verbose "Group Display Name: '$GroupDisplayName'"
  #Check if this monitoring class is actually an instance group, computer group or the base group system.group
  Write-Verbose "Check if the group '$USING:GroupName' is an instance group."
  $GroupBaseTypes = $GroupClass.GetBaseTypes()
  $bIsGroup = $false
  Foreach ($item in $GroupBaseTypes)
  {
    $GroupBaseTypeID = $item.Id.Tostring()
    Switch ($GroupBaseTypeID)
    {
      #Instance Group
      '4ce499f1-0298-83fe-7740-7a0fbc8e2449'
      {
        $bIsGroup = $true
        $GroupType = "InstanceGroup"
      }
      #Computer Group
      '0c363342-717b-5471-3aa5-9de3df073f2a'
      {
        Write-Warning "Computer groups already have dependency monitors created out of the box. These monitors may be redundent. Please check after the task is completed."
        $bIsGroup = $true
        $GroupType = "ComputerGroup"
      }
      #None of above, then check the base type System.Group
      'd0b32736-5344-2fcc-74b3-f72dc64ef572'
      {
        $bIsGroup = $true
        If ($GroupType -eq $null)
        {
          $GroupType = "SystemGroup"
        }
      }
    }
    If ($bIsGroup -eq $false)
    {
      Write-Error "$USING:GroupName is not a group."
      Return $false
    }

    Write-Verbose "Group Type: '$GroupType'"

    #Get the group MP
    $GroupMP = $GroupClass.GetManagementPack()
    $GroupMPName = $GroupMP.Name
    If ($GroupMP.Sealed -eq $true)
    {
      Write-verbose "The group '$USING:GroupName' is defined in a sealed MP. Getting the desintation MP '$USING:ManagementPackName'."
      if ($USING:ManagementPackName -eq $null)
      {
        Write-Error "Unable to continue because the `$ManagementPack parameter is not specified and the group is defined in a sealed management pack. Please specify an unsealed MP to store the dependency monitors."
        Return $false
      } else {
        #Get the destination MP
        $DestinationMPCriteria = New-Object Microsoft.EnterpriseManagement.Configuration.ManagementPackCriteria("Name='$USING:ManagementPackName'")
        $DestinationMP = $MG.GetManagementPacks($DestinationMPCriteria)[0]

        If ($DestinationMP -eq $null)
        {
          Write-Error "Unable to find the management pack '$USING:ManagementPackName' in the management group. Unable to continue."
          Return $false
        } else {
          If ($DestinationMP.Sealed -eq $true)
          {
            Write-Error "The specified management pack '$USING:ManagementPackName' is a sealed MP. Unable to save dependency monitors to a sealed MP. Please specify an unsealed MP."
            Return $false
          }
        }
      }
    } else {
      Write-Verbose "The group '$USING:GroupName' is defined in an unsealed MP '$GroupMPName'. the dependency monitors will be stored in the same MP."
      $DestinationMP = $GroupMP
    }

    #Destination MP Name
    $DestinationMPName = $DestinationMP.Name
    Write-Verbose "The dependency monitors will be created in management pack '$DestinationMPName'."

    #Create the dependecy monitors
    #Monitor names
    Write-Verbose "Determining depdency monitor names."
    $AvailabilityDependencyMonitorName = "$USING:GroupName`.Availability.Dependency.Monitor"
    $ConfigurationDependencyMonitorName = "$USING:GroupName`.Configuration.Dependency.Monitor"
    $PerformanceDependencyMonitorName = "$USING:GroupName`.Performance.Dependency.Monitor"
    $SecurityDependencyMonitorName = "$USING:GroupName`.Security.Dependency.Monitor"

    #Parent Monitors
    Write-Verbose "Getting parent monitors."
    $AvailabilityParentMonitorCriteria = New-Object Microsoft.EnterpriseManagement.Configuration.MonitorCriteria("Name ='System.Health.AvailabilityState'")
    $ConfigurationParentMonitorCriteria = New-Object Microsoft.EnterpriseManagement.Configuration.MonitorCriteria("Name ='System.Health.ConfigurationState'")
    $PerformanceParentMonitorCriteria = New-Object Microsoft.EnterpriseManagement.Configuration.MonitorCriteria("Name ='System.Health.PerformanceState'")
    $SecurityParentMonitorCriteria = New-Object Microsoft.EnterpriseManagement.Configuration.MonitorCriteria("Name ='System.Health.SecurityState'")

    $AvailabilityParentMonitor = $MG.GetMonitors($AvailabilityParentMonitorCriteria)[0]
    $ConfigurationParentMonitor = $MG.GetMonitors($ConfigurationParentMonitorCriteria)[0]
    $PerformanceParentMonitor = $MG.GetMonitors($PerformanceParentMonitorCriteria)[0]
    $SecurityParentMonitor = $MG.GetMonitors($SecurityParentMonitorCriteria)[0]

    #Relationship Types
    Write-Verbose "Getting relationship type."
    If ($GroupType -ieq "instancegroup")
    {
      $RelationshipMPCriteria = New-Object Microsoft.EnterpriseManagement.Configuration.ManagementPackCriteria("Name='Microsoft.SystemCenter.InstanceGroup.Library'")
      $RelationshipMP = $MG.GetManagementPacks($RelationshipMPCriteria)[0]
      $RelationshipClass = $MG.GetMonitoringRelationshipClass("Microsoft.SystemCenter.InstanceGroupContainsEntities", $RelationshipMP)
    } elseif ($GroupType -ieq "computergroup") {
      $RelationshipMPCriteria = New-Object Microsoft.EnterpriseManagement.Configuration.ManagementPackCriteria("Name='Microsoft.SystemCenter.Library'")
      $RelationshipMP = $MG.GetManagementPacks($RelationshipMPCriteria)[0]
      $RelationshipClass = $MG.GetMonitoringRelationshipClass("Microsoft.SystemCenter.ComputerGroupContainsComputer", $RelationshipMP)
    } elseif ($GroupType -ieq "systemgroup") {
      $RelationshipMPCriteria = New-Object Microsoft.EnterpriseManagement.Configuration.ManagementPackCriteria("Name='System.Library'")
      $RelationshipMP = $MG.GetManagementPacks($RelationshipMPCriteria)[0]
      $RelationshipClass = $MG.GetMonitoringRelationshipClass("System.Containment", $RelationshipMP)
    }

    #Availability Dependecy Monitor
    Write-Verbose "Creating Availability Dependency monitor '$AvailabilityDependencyMonitorName'."
    $AvailabilityDependencyMonitor = New-Object Microsoft.EnterpriseManagement.Configuration.ManagementPackDependencyMonitor($DestinationMP,$AvailabilityDependencyMonitorName,[Microsoft.EnterpriseManagement.Configuration.ManagementPackAccessibility]::Public)
    $AvailabilityDependencyMonitor.DisplayName = "$GroupDisplayName Availability Dependency Monitor"
    $AvailabilityDependencyMonitor.Category = [Microsoft.EnterpriseManagement.Configuration.ManagementPackCategoryType]::AvailabilityHealth
    $AvailabilityDependencyMonitor.ParentMonitorID = $AvailabilityParentMonitor
    $AvailabilityDependencyMonitor.RelationshipType = $RelationshipClass
    $AvailabilityDependencyMonitor.Target = $GroupClass
    $AvailabilityDependencyMonitor.Enabled = [Microsoft.EnterpriseManagement.Configuration.ManagementPackMonitoringLevel]::true
    $AvailabilityDependencyMonitor.Remotable = $true
    $AvailabilityDependencyMonitor.Priority = [Microsoft.EnterpriseManagement.Configuration.ManagementPackWorkflowPriority]::Normal
    #Member monitor is same as parrent monitor
    $AvailabilityDependencyMonitor.MemberMonitor = $AvailabilityParentMonitor
    $AvailabilityDependencyMonitor.MemberUnAvailable = [Microsoft.EnterpriseManagement.Configuration.HealthState]::$USING:MemberUnavailable
    $AvailabilityDependencyMonitor.Algorithm = [Microsoft.EnterpriseManagement.Configuration.ManagementPackDependencyMonitorAlgorithm]::$USING:Algorithm
    If ($USING:Algorithm -ieq 'percentage')
    {
      $AvailabilityDependencyMonitor.AlgorithmParameter = $USING:Percentage
    }
    If ($USING:MemberInMaintenance)
    {
      $AvailabilityDependencyMonitor.MemberInMaintenance = [Microsoft.EnterpriseManagement.Configuration.HealthState]::$USING:MemberInMaintenance
    }

    #Configuration Dependency Monitor
    Write-Verbose "Creating Configuration Dependency monitor '$ConfigurationDependencyMonitorName'."
    $ConfigurationDependencyMonitor = New-Object Microsoft.EnterpriseManagement.Configuration.ManagementPackDependencyMonitor($DestinationMP,$ConfigurationDependencyMonitorName,[Microsoft.EnterpriseManagement.Configuration.ManagementPackAccessibility]::Public)
    $ConfigurationDependencyMonitor.DisplayName = "$GroupDisplayName Configuration Dependency Monitor"
    $ConfigurationDependencyMonitor.Category = [Microsoft.EnterpriseManagement.Configuration.ManagementPackCategoryType]::ConfigurationHealth
    $ConfigurationDependencyMonitor.ParentMonitorID = $ConfigurationParentMonitor
    $ConfigurationDependencyMonitor.RelationshipType = $RelationshipClass
    $ConfigurationDependencyMonitor.Target = $GroupClass
    $ConfigurationDependencyMonitor.Enabled = [Microsoft.EnterpriseManagement.Configuration.ManagementPackMonitoringLevel]::true
    $ConfigurationDependencyMonitor.Remotable = $true
    $ConfigurationDependencyMonitor.Priority = [Microsoft.EnterpriseManagement.Configuration.ManagementPackWorkflowPriority]::Normal
    #Member monitor is same as parrent monitor
    $ConfigurationDependencyMonitor.MemberMonitor = $ConfigurationParentMonitor
    $ConfigurationDependencyMonitor.MemberUnAvailable = [Microsoft.EnterpriseManagement.Configuration.HealthState]::$USING:MemberUnavailable
    $ConfigurationDependencyMonitor.Algorithm = [Microsoft.EnterpriseManagement.Configuration.ManagementPackDependencyMonitorAlgorithm]::$USING:Algorithm
    If ($USING:Algorithm -ieq 'percentage')
    {
      $ConfigurationDependencyMonitor.AlgorithmParameter = $USING:Percentage
    }
    If ($USING:MemberInMaintenance)
    {
      $ConfigurationDependencyMonitor.MemberInMaintenance = [Microsoft.EnterpriseManagement.Configuration.HealthState]::$USING:MemberInMaintenance
    }

    #Performance Dependency Monitor
    Write-Verbose "Creating Performance Dependency monitor '$PerformanceDependencyMonitorName'."
    $PerformanceDependencyMonitor = New-Object Microsoft.EnterpriseManagement.Configuration.ManagementPackDependencyMonitor($DestinationMP,$PerformanceDependencyMonitorName,[Microsoft.EnterpriseManagement.Configuration.ManagementPackAccessibility]::Public)
    $PerformanceDependencyMonitor.DisplayName = "$GroupDisplayName Performance Dependency Monitor"
    $PerformanceDependencyMonitor.Category = [Microsoft.EnterpriseManagement.Configuration.ManagementPackCategoryType]::PerformanceHealth
    $PerformanceDependencyMonitor.ParentMonitorID = $PerformanceParentMonitor
    $PerformanceDependencyMonitor.RelationshipType = $RelationshipClass
    $PerformanceDependencyMonitor.Target = $GroupClass
    $PerformanceDependencyMonitor.Enabled = [Microsoft.EnterpriseManagement.Configuration.ManagementPackMonitoringLevel]::true
    $PerformanceDependencyMonitor.Remotable = $true
    $PerformanceDependencyMonitor.Priority = [Microsoft.EnterpriseManagement.Configuration.ManagementPackWorkflowPriority]::Normal
    #Member monitor is same as parrent monitor
    $PerformanceDependencyMonitor.MemberMonitor = $PerformanceParentMonitor
    $PerformanceDependencyMonitor.MemberUnAvailable = [Microsoft.EnterpriseManagement.Configuration.HealthState]::$USING:MemberUnavailable
    $PerformanceDependencyMonitor.Algorithm = [Microsoft.EnterpriseManagement.Configuration.ManagementPackDependencyMonitorAlgorithm]::$USING:Algorithm
    If ($USING:Algorithm -ieq 'percentage')
    {
      $PerformanceDependencyMonitor.AlgorithmParameter = $USING:Percentage
    }
    If ($USING:MemberInMaintenance)
    {
      $PerformanceDependencyMonitor.MemberInMaintenance = [Microsoft.EnterpriseManagement.Configuration.HealthState]::$USING:MemberInMaintenance
    }

    #Security Dependency Monitor
    Write-Verbose "Creating Security Dependency monitor '$SecurityDependencyMonitorName'."
    $SecurityDependencyMonitor = New-Object Microsoft.EnterpriseManagement.Configuration.ManagementPackDependencyMonitor($DestinationMP,$SecurityDependencyMonitorName,[Microsoft.EnterpriseManagement.Configuration.ManagementPackAccessibility]::Public)
    $SecurityDependencyMonitor.DisplayName = "$GroupDisplayName Security Dependency Monitor"
    $SecurityDependencyMonitor.Category = [Microsoft.EnterpriseManagement.Configuration.ManagementPackCategoryType]::SecurityHealth
    $SecurityDependencyMonitor.ParentMonitorID = $SecurityParentMonitor
    $SecurityDependencyMonitor.RelationshipType = $RelationshipClass
    $SecurityDependencyMonitor.Target = $GroupClass
    $SecurityDependencyMonitor.Enabled = [Microsoft.EnterpriseManagement.Configuration.ManagementPackMonitoringLevel]::true
    $SecurityDependencyMonitor.Remotable = $true
    $SecurityDependencyMonitor.Priority = [Microsoft.EnterpriseManagement.Configuration.ManagementPackWorkflowPriority]::Normal
    #Member monitor is same as parrent monitor
    $SecurityDependencyMonitor.MemberMonitor = $SecurityParentMonitor
    $SecurityDependencyMonitor.MemberUnAvailable = [Microsoft.EnterpriseManagement.Configuration.HealthState]::$USING:MemberUnavailable
    $SecurityDependencyMonitor.Algorithm = [Microsoft.EnterpriseManagement.Configuration.ManagementPackDependencyMonitorAlgorithm]::$USING:Algorithm
    If ($USING:Algorithm -ieq 'percentage')
    {
      $SecurityDependencyMonitor.AlgorithmParameter = $USING:Percentage
    }
    If ($USING:MemberInMaintenance)
    {
      $SecurityDependencyMonitor.MemberInMaintenance = [Microsoft.EnterpriseManagement.Configuration.HealthState]::$USING:MemberInMaintenance
    }

    #Increase MP version
    If ($USING:IncreaseMPVersion)
    {
      $CurrentVersion = $DestinationMP.Version.Tostring()
      $vIncrement = $CurrentVersion.Split('.')
      $vIncrement[$vIncrement.Length - 1] = ([System.Int32]::Parse($vIncrement[$vIncrement.Length - 1]) + 1).ToString()
      $NewVersion = ([System.String]::Join('.', $vIncrement))
      $DestinationMP.Version = $NewVersion
    }

    #Verify and save the monitor
    Try {
      $DestinationMP.verify()
      $DestinationMP.AcceptChanges()
      $Result = $true
      Write-Verbose "Group dependency monitors created in Management Pack '$DestinationMPName'($($DestinationMP.Version))."
    } Catch {
      $Result = $false
      $DestinationMP.RejectChanges()
      Write-Error $_.Exception.InnerException
      Write-Error "Unable to dependency monitors for group '$USING:GroupName' in management pack $DestinationMPName."
    }
    $Result
  }
  }
  If ($bRollupConfigured -eq $true)
  {
    Write-Output "Done"
  } else {
    Write-Error "Unable to configure health rollup for group '$GroupName'."
  }
}
```
This runbook requires the following input parameters:

* **GroupName:** Required parameter. Name of the group (note, this is not the display name you see in the OpsMgr console)
* **Algorithm:** Required parameter. The algorithm to use for determining health state. Possible values: 'BestOf','WorstOf','Percentage'.
* **Percentage:** The worst state of the specified percentage of members in good health state. This parameter is only required when the specified algorithm is 'Percentage'. Optional parameter, default value is 60 if not specified.
* **MemberUnavailable:** The health state when the member is unavailable. Possible Values: 'Uninitialized', 'Success ','Warning', 'Error'. Optional parameter. If not specified, the default value is "Error".
* **MemberInMaintenance:** The health state when the member is in maintenance mode. Possible Values: 'Uninitialized', 'Success ', 'Warning', 'Error'. Optional Parameter. If not specified, members in maintenance mode will be ignored.
* **ManagementPackName:** The Management Pack name of which the monitors going to be saved. This is only going to be used when the group is defined in a sealed MP.'
* **IncreaseMPVersion:** Boolean optional parameter. Specify if the management pack version should be increased by 0.0.0.1.

Before executing the runbook:

<a href="https://blog.tyang.org/wp-content/uploads/2015/07/image44.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/07/image_thumb44.png" alt="image" width="329" height="233" border="0" /></a>

Executing the runbook:

<a href="https://blog.tyang.org/wp-content/uploads/2015/07/image45.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/07/image_thumb45.png" alt="image" width="447" height="395" border="0" /></a>

After runbook execution:

<a href="https://blog.tyang.org/wp-content/uploads/2015/07/image46.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/07/image_thumb46.png" alt="image" width="409" height="474" border="0" /></a>

Dependency monitor health rollup policy:

<a href="https://blog.tyang.org/wp-content/uploads/2015/07/image47.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/07/image_thumb47.png" alt="image" width="398" height="426" border="0" /></a>

## Conclusion

In this post, I have demonstrated how to configure OpsMgr group health rollup by creating dependency monitors using a SMA runbook. As I mentioned in <a href="https://blog.tyang.org/2015/07/02/automating-opsmgr-part-4-create-new-empty-groups/" target="_blank">part 4</a>, I was going to dedicate few post for a creating and managing groups mini series. This post would be the last post for this managing groups mini series. To summarise, on managing groups, I have covered the following aspects:

* Creating new empty groups (Part 4)
* Adding Computers to computer groups (Part 5)
* Adding monitoring objects to instance groups (Part 6)
* Incorporated the runbooks from part 5 and 6 into the new version of the OpsMgrExtended module (part 7)
* Updating group discoveries (Part 9)
* Deleting Groups (Part 10)
* Configure Group Health Rollup (Part 11, this post)

Starting from next post, I will start talking about how to create monitors, rules, etc. So it should only get more interesting from now on.

This is all I'm going to share for today. Until next post, happy automating OpsMgr!