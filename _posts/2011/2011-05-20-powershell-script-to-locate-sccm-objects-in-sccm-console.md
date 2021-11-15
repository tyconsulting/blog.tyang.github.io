---
id: 517
title: PowerShell Script to locate SCCM objects in SCCM console
date: 2011-05-20T16:24:44+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=517
permalink: /2011/05/20/powershell-script-to-locate-sccm-objects-in-sccm-console/
categories:
  - PowerShell
  - SCCM
tags:
  - PowerShell
  - SCCM
---
There are many object types in SCCM that supports folders in the console. Even though the object can be easily located using the search function, often we need to find out which folder does a particular object (i.e. package, advertisement, etc) reside.  At work, we use folders to separate objects for different business units and differnet IT service providers. Therefore, there are many times I need to find out where exactly is the object located.

I wrote this script today called <a href="https://blog.tyang.org/wp-content/uploads/2011/05/Locate-SCCMObject.zip">Locate-SCCMObject.PS1</a>

<strong>Syntax</strong>: .\Locate-SCCMObject &lt;SCCM Central Site Server&gt; &lt;SCCM Object ID&gt;:

<strong>Example</strong>:

Using the script:

<a href="https://blog.tyang.org/wp-content/uploads/2011/05/image3.png"><img style="display: inline; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2011/05/image_thumb3.png" border="0" alt="image" width="796" height="67" /></a>

From SCCM Console:

<a href="https://blog.tyang.org/wp-content/uploads/2011/05/image4.png"><img style="display: inline; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2011/05/image_thumb4.png" border="0" alt="image" width="878" height="151" /></a>

The output of the script shows the object type and the path in the console, in this case, it’s a software package located under <strong>Application\Microsoft Office folder</strong>.

<strong>Source Code:</strong>

```powershell
#======================================================================================================================
# AUTHOR:	Tao Yang
# DATE:		20/05/2011
# Name:		Locate-SCCMObject.PS1
# Version:	1.0
# COMMENT:	Use this script to locate a SCCM object in SCCM Console. Please note it does not work for SCCM collections.
# Usage:	.\Locate-SCCMObject.ps1 &lt;SCCM Central Site Server&gt; &lt;SCCM Object ID&gt;
#======================================================================================================================

param([string]$CentralSiteServer,[string[]]$ObjID)

Function Get-SCCMObjectType ($ObjType)
{
	Switch ($objType)
	{
		2 {$strObjType = "Package"}
		3 {$strObjType = "Advertisement"}
		7 {$strObjType = "Query"}
		8 {$strObjType = "Report"}
		9 {$strObjType = "Metered Product Rule"}
		11 {$strObjType = "ConfigurationItem"}
		14 {$strObjType = "Operating System Install Package"}
		17 {$strObjType = "State Migration"}
		18 {$strObjType = "Image Package"}
		19 {$strObjType = "Boot Image Package"}
		20 {$strObjType = "TaskSequence Package"}
		21 {$strObjType = "Device Setting Package"}
		23 {$strObjType = "Driver Package"}
		25 {$strObjType = "Driver"}
		1011 {$strObjType = "Software Update"}
		2011 {$strObjType = "Configuration Item (Configuration baseline)"}
		default {$strObjType = "Unknown"}
	}
	Return $strObjType
}

Function Get-ConsolePath ($CentralSiteProvider, $CentralSiteCode, $SCCMObj)
{
	$ContainerNodeID = $SCCMObj.ContainerNodeID
	$strConsolePath = $null
	$bIsTopLevel = $false
	$objContainer = Get-WmiObject -Namespace root\sms\site_$CentralSiteCode -Query "Select * from SMS_ObjectContainerNode Where ContainerNodeID = '$ContainerNodeID'" -ComputerName $CentralSiteProvider
	$strConsolePath = $objContainer.Name
	$ParentContainerID = $objContainer.ParentContainerNodeID
	if ($ParentContainerID -eq 0)
	{
		$bIsTopLevel = $true
	} else {
		Do
		{
			$objParentContainer = Get-WmiObject -Namespace root\sms\site_$CentralSiteCode -Query "Select * from SMS_ObjectContainerNode Where ContainerNodeID = '$ParentContainerID'" -ComputerName $CentralSiteProvider
			$strParentContainerName = $objParentContainer.Name
			$strConsolePath = $strParentContainerName +"`\"+$strConsolePath
			$ParentContainerID = $objParentContainer.ParentContainerNodeID
			Remove-Variable objParentContainer, strParentContainerName
			if ($ParentContainerID -eq 0) {$bIsTopLevel = $true}

		} until ($bIsTopLevel -eq $true)
	}
	Return $strConsolePath
}
$objSite = Get-WmiObject -ComputerName $CentralSiteServer -Namespace root\sms -query "Select * from SMS_ProviderLocation WHERE ProviderForLocalSite = True"
$CentralSiteCode= $objSite.SiteCode
$CentralSiteProvider = $objSite.Machine
$SCCMObj = Get-WmiObject -Namespace root\sms\site_$CentralSiteCode -Query "Select * from SMS_ObjectContainerItem Where InstanceKey = '$objID'" -ComputerName $CentralSiteProvider
If ($SCCMObj -eq $null)
{
	Write-Host "SCCM Object with ID $objID cannot be found!" -ForegroundColor Red
} else {
$strObjType = Get-SCCMObjectType $SCCMObj.ObjectType
$strConsolePath = Get-ConsolePath $CentralSiteProvider $CentralSiteCode $SCCMObj
Write-Host "Object Type`: $strObjType" -ForegroundColor Yellow
Write-Host "Console Path`: $strConsolePath" -ForegroundColor Yellow
}
```

<strong>This script should work for all objects that support folders. However, it does not work for collections. Collections do not support folders, but you can have sub collections and linked collections. I have written another script to locate collections. It is posted <a title="Get-CollectionPath" href="https://blog.tyang.org/2011/01/23/how-to-locate-sccm-collection-object-based-on-the-collection-id/">here</a>.</strong>