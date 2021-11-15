---
id: 3269
title: Using PowerShell and OpsMgr SDK to Get and Set Management Group Default settings
date: 2014-10-21T14:44:46+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=3269
permalink: /2014/10/21/using-powershell-opsmgr-sdk-get-set-management-group-default-settings/
categories:
  - PowerShell
  - SCOM
tags:
  - PowerShell
  - SCOM
---
Over the last couple of days, I have written few additional functions in the OpsMgrSDK PowerShell / SMA module that I’ve been working on over the last few months. Two of these functions are:

* **Get-MGDefaultSettings** – Get <strong><span style="text-decoration: underline;">ALL</span></strong> default settings of an OpsMgr 2012 (R2) management group
* **Set-MGDefaultSetting** – Set any particular MG default setting

Since I haven’t seen anything similar to these on the net before, although they will be part of the module when I release it to the public later, I thought they are pretty cool and I’ll publish the code here now.

## Get-MGDefaultSettings

```powershell
Function Get-MGDefaultSettings
{
  <# 
  .Synopsis
  Get OpsMgr management group default settings

  .Description
  Get OpsMgr management group default settings via OpsMgr SDK

  .Parameter -SDK
  Management Server name

  .Parameter -UserName
  Alternative user name to connect to the management group (optional).

  .Parameter -Password
  Alternative password to connect to the management group (optional).

  .Example
  # Connect to OpsMgr management group via management server "OpsMgrMS01" using alternative credentials and retrieve all the settings:
  Get-MGDefaultSettings -SDK "OpsMgrMS01" -Username "domain\SCOM.Admin" -Password "password1234"
  #>
  [CmdletBinding()]
  PARAM (
    [Parameter(Mandatory=$true,HelpMessage='Please enter the Management Server name')][Alias('DAS','Server','s')][String]$SDK,
    [Parameter(Mandatory=$false,HelpMessage='Please enter the user name to connect to the OpsMgr management group')][Alias('u')][String]$Username = $null,
    [Parameter(Mandatory=$false,HelpMessage='Please enter the password to connect to the OpsMgr management group')][Alias('p')][String]$Password = $null
  )

  #Connect to MG
  #Load OpsMgr 2012 SDK DLLs
  [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.EnterpriseManagement.OperationsManager.Common') | Out-Null
  [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.EnterpriseManagement.OperationsManager') | Out-Null

  Write-Verbose "Connecting to Management Group via SDK $SDK`..."
  $MGConnSetting = New-Object Microsoft.EnterpriseManagement.ManagementGroupConnectionSettings($SDK)
  If ($Username -and $Password)
  {
    $MGConnSetting.UserName = $Username
    $MGConnSetting.Password = ConvertTo-SecureString -AsPlainText $Password -Force
  }

  $MG = New-Object Microsoft.EnterpriseManagement.ManagementGroup($MGConnSetting)

  $Admin = $MG.GetAdministration()
  $Settings = $Admin.Settings

  #Get Setting Types
  Write-Verbose 'Get all nested setting types'
  $arrRumtimeTypes = New-Object System.Collections.ArrayList
  $assembly = [Reflection.Assembly]::LoadWithPartialName('Microsoft.EnterpriseManagement.OperationsManager')
  $SettingType = $assembly.definedtypes | Where-Object{$_.name -eq 'settings'}
  $TopLevelNestedTypes = $SettingType.GetNestedTypes()
  Foreach ($item in $TopLevelNestedTypes)
  {
    if ($item.DeclaredFields.count -gt 0)
    {
      [void]$arrRumtimeTypes.Add($item)
    }
    $NestedTypes = $item.GetNestedTypes()
    foreach ($NestedType in $NestedTypes)
    {
      [void]$arrRumtimeTypes.Add($NestedType)
    }
  }

  #Get Setting Values
  Write-Verbose 'Getting setting values'
  $arrSettingValues = New-Object System.Collections.ArrayList
  Foreach ($item in $arrRumtimeTypes)
  {
    Foreach ($field in $item.DeclaredFields)
    {
      $FieldSetting = $field.GetValue($field.Name)
      $SettingValue = $Settings.GetDefaultValue($FieldSetting)
      $hash = @{
        FieldName = $Field.Name
        Value = $SettingValue
        AllowOverride = $FieldSetting.AllowOverride
        SettingName = $item.Name
        SettingFullName = $item.FullName
      }
      $objSettingValue = New-object psobject -Property $hash
      [void]$arrSettingValues.Add($objSettingValue)
    }
  }
  Write-Verbose "Total number of Management Group default value found: $($arrSettingValues.count)."
  $arrSettingValues
}

```
This function returns an arraylist which contains **ALL** the default settings of the management group.

**Usage:**

$DefaultSettings = Get-MGDefaultSettings -SDK "OpsMgrMS01" –verbose

![](https://blog.tyang.org/wp-content/uploads/2014/10/image9.png)

As you can see, this function retrieves ALL default settings of a management group. It returns the following properties:

* **SettingFullName:** The full name of the assembly type of the setting. This is required when using the Set-MGDefaultSetting function to set the value.
* **SettingName:** The name of the assembly type of the setting. consider it as the setting category
* **FieldName:** The actual name of the setting. It is required when using the Set-MGDefaultSetting function.
* **Value:** The current default value of the setting.
* **AllowOverride:** When it’s true, this value can be overridden to a particular instance (differ from the default value).

If you want to retrieve a particular setting, you can always use pipe ("\|") and where-object to filter to the particular setting:

![](https://blog.tyang.org/wp-content/uploads/2014/10/image10.png)

## Set-MGDefaultSetting

```powershell
Function Set-MGDefaultSetting
{
  <# 
  .Synopsis
  Set OpsMgr management group default settings

  .Description
  Set OpsMgr management group default settings via OpsMgr SDK

  .Parameter -SDK
  Management Server name

  .Parameter -UserName
  Alternative user name to connect to the management group (optional).

  .Parameter -Password
  Alternative password to connect to the management group (optional).

  .Parameter -SettingType
  Full name of the setting type (can be retrieved from Get-MGDefaultSettings).

  .Parameter -FieldName
  Field name of the setting type (can be retrieved from Get-MGDefaultSettings).

  .Parameter -Value
  Desired value that the field should be set to.

  .Example
  # Connect to OpsMgr management group via management server "OpsMgrMS01" using alternative credentials and set ProxyingEnabled default setting to TRUE:
  Set-MGDefaultSetting -SDK "OpsMgrMS01" -Username "domain\SCOM.Admin" -Password "password1234" -SettingType Microsoft.EnterpriseManagement.Administration.Settings+HealthService -FieldName ProxyingEnabled -Value $TRUE
  #>
  [CmdletBinding()]
  PARAM (
    [Parameter(Mandatory=$true,HelpMessage='Please enter the Management Server name')][Alias('DAS','Server','s')][String]$SDK,
    [Parameter(Mandatory=$false,HelpMessage='Please enter the user name to connect to the OpsMgr management group')][Alias('u')][String]$Username = $null,
    [Parameter(Mandatory=$false,HelpMessage='Please enter the password to connect to the OpsMgr management group')][Alias('p')][String]$Password = $null,
    [Parameter(Mandatory=$true,HelpMessage='Please enter the Setting Type name')][Alias('Setting')][String]$SettingType,
    [Parameter(Mandatory=$true,HelpMessage='Please enter the Field name')][Alias('Field')][String]$FieldName,
    [Parameter(Mandatory=$true,HelpMessage='Please enter the new value for the field name')][Alias('v')]$Value
  )
    #Connect to MG
    #Load OpsMgr 2012 SDK DLLs
    [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.EnterpriseManagement.OperationsManager.Common') | Out-Null
    [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.EnterpriseManagement.OperationsManager') | Out-Null
 
    #Connect to MG
    Write-Verbose "Connecting to Management Group via SDK $SDK`..."
    $MGConnSetting = New-Object Microsoft.EnterpriseManagement.ManagementGroupConnectionSettings($SDK)
    If ($Username -and $Password)
    {
      $MGConnSetting.UserName = $Username
      $MGConnSetting.Password = ConvertTo-SecureString -AsPlainText $Password -Force
    }

    $MG = New-Object Microsoft.EnterpriseManagement.ManagementGroup($MGConnSetting)

    $Admin = $MG.GetAdministration()
    $Settings = $Admin.Settings

    #Get Setting Types
    $assembly = [Reflection.Assembly]::LoadWithPartialName('Microsoft.EnterpriseManagement.OperationsManager')
    Write-Verbose "Getting $FieldName Field Type"
    $objSettingType = (New-object -TypeName $SettingType).GetType()
    $objField = $objSettingType.GetDeclaredField($FieldName)
    $FieldSetting = $objField.GetValue($objField.Name)

    #Get current value - required to get value type
    $CurrentValue = $Settings.GetDefaultValue($FieldSetting)

    #Convert data type
    $ConvertedValue = $Value -as $CurrentValue.Gettype()
    If (!$ConvertedValue)
    {
      Write-Error "Unable to convert value $Value with type $($Value.gettype()) to type $($CurrentValue.Gettype())."
    } else {
      #Set default value
      Write-Verbose "Setting default value of $FieldName to $Value"
      $Settings.SetDefaultValue($FieldSetting, $ConvertedValue)
      $Settings.ApplyChanges()

      Write-Output 'Done.'
    }
}

```
**Usage:**

```powershell
Set-MGDefaultSetting -SDK "OpsMgrMS01" -SettingType Microsoft.EnterpriseManagement.Administration.Settings+ManagementGroup+AlertResolution -FieldName AlertAutoResolveDays -Value 3 –verbose
```

![](https://blog.tyang.org/wp-content/uploads/2014/10/image11.png)

I think these two functions are particularly useful when managing multiple management groups. they can be used in automation products such as SC Orchestrator and SMA, to synchronise settings among multiple management groups (i.e. Test vs Dev vs Prod).