---
id: 2517
title: 'PowerShell Functions: Get OpsMgr Alert Generating Rules and Monitors'
date: 2014-04-12T23:35:37+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=2517
permalink: /2014/04/12/powershell-functions-get-opsmgr-alert-generating-rules-monitors/
categories:
  - PowerShell
  - SCOM
tags:
  - PowerShell
  - SCOM
---
This is my second post today. Bad weather, both wife and daughter have got flu. So I’m sitting home catching up with blogs…

I wrote 2 functions as part of a PowerShell script I’ve been working on: **Get-AlertRules** and **Get-AlertMonitors**.

As the names suggest, these two functions get all Rules / Monitors of a particular monitoring class **that generate alerts**.

I didn’t end up using these 2 functions in my script, but I thought they are too good to be trashed. so I thought I’ll put them here for future reference.

**Get-AlertRules:**

```powershell
Function Get-AlertRules
{
  PARAM (
    [Parameter(Mandatory=$true,HelpMessage="OpsMgr Management Group Connection" )][Microsoft.EnterpriseManagement.ManagementGroup] $ManagementGroup,
    [Parameter(Mandatory=$false,HelpMessage="Monitoring Class Name" )][string] $MonitoringClassName = $null
  )
  $arrAlertRules = New-object System.Collections.ArrayList
  #Get GenerateAlert WriteAction module
  $HealthMPId = [guid]"0abff86f-a35e-b08f-da0e-ff051ab2840c" #this is unique
  $HealthMP = $MG.GetManagementPack($HealthMPId)
  $AlertWA = $HealthMP.GetModuleType("System.Health.GenerateAlert")
  $AlertWAId = $AlertWA.Id
  #firstly get all monitoring classes
  #Populate Search criteria
  If ($MonitoringClassName)
  {
    $strClassCriteria = "Name = '$MonitoringClassName'"
  } else {
    $strClassCriteria = "Name LIKE '%'"
  }
    $ClassCriteria = New-Object Microsoft.EnterpriseManagement.Configuration.MonitoringClassCriteria($strClassCriteria)
    $MonitoringClasses = $MG.GetMonitoringClasses($ClassCriteria)
  Foreach ($MC in $MonitoringClasses)
  {
    $MCId = $MC.Id
    $strRuleCriteria = "TargetMonitoringClassId = '$MCId'"
    $RuleCriteria = New-Object Microsoft.EnterpriseManagement.Configuration.MonitoringRuleCriteria($strRuleCriteria)
    $Rules = $MG.GetMonitoringRules($RuleCriteria)
    Foreach ($rule in $Rules)
    {
      #Unfortunately, we cannot use a member module name/id in MonitoringRUleCriteria.
      #So we have to manually filter out the rules with GenerateAlert Write Action Module
      #Check if it has a GenerateAlert WriteAction module
      $bAlertRule = $false
      Foreach ($WAModule in $Rule.WriteActionCollection)
      {
        if ($WAModule.TypeId.Id -eq $AlertWAId)
        {
          #this rule generates alert
          $bAlertRule = $true
        } else {
          #need to detect if it's using a customized WA which the GenerateAlert WA is a member of
          $WAId = $WAModule.TypeId.Id
          $WASource = $MG.GetMonitoringModuleType($WAId)
          #Check each write action member modules in the customized write action module...
          Foreach ($item in $WASource.WriteActionCollection)
          {
            $itemId = $item.TypeId.Id
            If ($ItemId -eq $AlertWAId)
            {
              $bAlertRule = $true
            }
          }
        }

        if ($bAlertRule)
        {
          #Add to arraylist
          [void]$arrAlertRules.Add($rule)
        }
      }
    }
  }
  ,$arrAlertRules
}
```

**Get-AlertMonitors:**

```powershell
Function Get-AlertMonitors
{
  PARAM (
    [Parameter(Mandatory=$true,HelpMessage="OpsMgr Management Group Connection" )][Microsoft.EnterpriseManagement.ManagementGroup] $ManagementGroup,
    [Parameter(Mandatory=$false,HelpMessage="Monitoring Class Name" )][string] $MonitoringClassName = $null
  )
  $arrAlertMonitors = New-object System.Collections.ArrayList
  #firstly get all monitoring classes
  #Populate Search criteria
  If ($MonitoringClassName)
  {
    $strClassCriteria = "Name = '$MonitoringClassName'"
  } else {
    $strClassCriteria = "Name LIKE '%'"
  }
  $ClassCriteria = New-Object Microsoft.EnterpriseManagement.Configuration.MonitoringClassCriteria($strClassCriteria)
  $MonitoringClasses = $MG.GetMonitoringClasses($ClassCriteria)
  Foreach ($MC in $MonitoringClasses)
  {
    $MCId = $MC.Id
    $strMonitorCriteria = "TargetMonitoringClassId = '$MCId' AND AlertOnState IS NOT NULL"
    $MonitorCriteria = New-Object Microsoft.EnterpriseManagement.Configuration.MonitorCriteria($strMonitorCriteria)
    $Monitors = $MG.getmonitors($MonitorCriteria)
    Foreach ($Monitor in $Monitors)
    {
      #Add to arraylist
      [void]$arrAlertMonitors.Add($Monitor)
    }
  }
  ,$arrAlertMonitors
}
```

Both functions are expecting an OpsMgr management group connection and the name (not the display name, but the Class ID from the management pack where the class is defined). so in order to use these 2 functions, I’ll need 2 other functions:

**Load-SDK:**

```powershell
function Load-SDK()
{
  [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.EnterpriseManagement.OperationsManager.Common") | Out-Null
  [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.EnterpriseManagement.OperationsManager") | Out-Null
}
```

**Get-MonitoringClass:**

```powershell
Function Get-MonitoringClass
{
PARAM (
  [Parameter(Mandatory=$true,HelpMessage="OpsMgr Management Group Connection" )][Microsoft.EnterpriseManagement.ManagementGroup] $ManagementGroup,
  [Parameter(Mandatory=$true,HelpMessage="Monitoring Class Display Name" )][string] $MonitoringClassDisplayName
)
#Populate Search criteria
$strClassCriteria = "DisplayName = '$MonitoringClassDisplayName'"
$ClassCriteria = New-Object Microsoft.EnterpriseManagement.Configuration.MonitoringClassCriteria($strClassCriteria)
#Search monitoring class
$MonitoringClasses = $MG.GetMonitoringClasses($ClassCriteria)
$MonitoringClasses
}
```

as the name suggests, **Load-SDK** function loads OpsMgr SDK, when can then create the connection to the management group. **Get-MonitoringClass** function gets the Monitoring Class object based on it’s display name (the name you see in the Operations Console), such as this one:

![](https://blog.tyang.org/wp-content/uploads/2014/04/SNAGHTML1f11d89.png)

Here’s an example of how to these functions:

```powershell
#Load SDK DLL's
Load-SDK

#Connect to the management group via management server "OpsMgrMS01":
$MGConnSetting = New-Object Microsoft.EnterpriseManagement.ManagementGroupConnectionSettings("OPSMGRMS01")
$MG = New-Object Microsoft.EnterpriseManagement.ManagementGroup($MGConnSetting)

#Get the monitoring class
$MonitoringClassDisplayName = "Data Access Service"
$MonitoringClass = Get-MonitoringClass $MG $MonitoringClassDisplayName
$MonitoringClassName = $MonitoringClass.Name

#Display Monitoring Class Name
$MonitoringClassName

#Get Alert rules
$AlertRules = Get-AlertRules $MG $MonitoringClassName

#Rule Count
$alertRules.count

#Alert Monitors
$AlertMonitors = Get-AlertMonitors $MG $MonitoringClassName

#Monitor Count
$AlertMonitors.Count
```

![](https://blog.tyang.org/wp-content/uploads/2014/04/SNAGHTML1f339a2.png)

**Logics in these 2 functions:**

Get-AlertRules:

Searching for rules either have the "System.Health.GenerateAlert" module from System.Health.Library MP as a Write Action member module, or one of the rule’s Write Action member modules has "System.Health.GenerateAlert" as its member.

Get-AlertMonitors:

This function is much easier to write than Get-AlertRules. I’ simply search for monitors that "AlertOnState" property is not NULL. Please keep in mind this function does not only return unit monitors, but also aggregate and dependency monitors.

Both functions return a "System.Collections.ArrayList" containing the rules / monitors. Since I used the OpsMgr SDK directly, instead of it's PowerShell snapin or module. these functions should work in both 2007 and 2012. - And this is one of the reasons why I always just use SDK, hardly use the snapin or the module :smiley:

I've also zipped up all the code used in this article. You can download them [**HERE**](https://blog.tyang.org/wp-content/uploads/2014/04/GetAlertRulesAndMonitors.zip). I know it's a bit hard to read the code on this post :smiley: