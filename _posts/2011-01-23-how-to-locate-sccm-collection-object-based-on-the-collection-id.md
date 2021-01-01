---
id: 367
title: How to locate SCCM Collection Object based on the Collection ID
date: 2011-01-23T21:07:45+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=367
permalink: /2011/01/23/how-to-locate-sccm-collection-object-based-on-the-collection-id/
categories:
  - PowerShell
  - SCCM
tags:
  - Collections
  - Powershell
  - SCCM
---
<a href="http://blog.tyang.org/wp-content/uploads/2011/01/path.jpg"><img class="alignleft size-thumbnail wp-image-368" title="path" src="http://blog.tyang.org/wp-content/uploads/2011/01/path-150x150.jpg" alt="" width="150" height="150" /></a>Often, I found it’s hard to locate the Collection object in the SCCM console if you only know the Collection ID. Couple of weeks ago I ran into a situation where I need to modify the settings of a bunch of collection objects and all I knew was the Collection ID.

I wrote a script called <strong>Get-CollectionPath</strong> that identifies all possible paths to a particular collection (as a collection can be linked to multiple places).

The Syntax is: .\Get-CollectionPath &lt;SCCM Central Site Server Name&gt; &lt;Collection ID&gt;

<a href="http://blog.tyang.org/wp-content/uploads/2011/01/image5.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/01/image_thumb5.png" border="0" alt="image" width="580" height="38" /></a>

Download the script <a title="Get-CollectionPath" href="http://blog.tyang.org/wp-content/uploads/2011/01/Get-CollectionPath.zip">here</a>.

[sourcecode language="powershell"]
param([string]$CentralSiteServer,[string[]]$CollectionID)
	Function Get-CollectionName ($CollectionID)
	{
		$CollectionName = (Get-WmiObject -ComputerName $CentralSiteProvider -Namespace root\sms\site_$CentralSiteCode -Query &quot;Select * from SMS_Collection where CollectionID = '$CollectionID'&quot;).name
		Return $CollectionName
	}
	Function Get-ParentCollectionID ($subCollectionID)
	{
		$arrParentCollectionID =@()
		$objCollectToSubCollect = Get-WmiObject -ComputerName $CentralSiteProvider -Namespace root\sms\site_$CentralSiteCode -Query &quot;Select * from SMS_CollectToSubCollect where SubCollectionID = '$subCollectionID'&quot;
		if (($objCollectToSubCollect.GetType()).IsArray -eq $true)
		{
			Foreach ($item in $objCollectToSubCollect)
			{
				$arrParentCollectionID += $item.ParentCollectionID
			}
		} else {
			$arrParentCollectionID += $objCollectToSubCollect.ParentCollectionID
		}
		Return $arrParentCollectionID
	}

	Function Get-CollectionPathObject ($strBaseCollectionPath, $CollectionID)
	{
		$CollectionName = Get-CollectionName $CollectionID
		if ($strBaseCollectionPath -eq $null) {$strBaseCollectionPath = &quot;$CollectionName($CollectionID)&quot;}
		$arrParentID = Get-ParentCollectionID $CollectionID
		$arrObjPath = @()
		Foreach ($CollectionID in $arrParentID)
		{
			$ParentCollectionName = Get-CollectionName $CollectionID
			$strCollectionPath = &quot;$ParentCollectionName($CollectionID)\&quot;+$strBaseCollectionPath
			$objCollectionPath = New-Object psobject
			Add-Member -InputObject $objCollectionPath -membertype noteproperty -name CollectionPath -value $strCollectionPath
			Add-Member -InputObject $objCollectionPath -MemberType NoteProperty -Name ParentCollectionID -Value $CollectionID
			$arrObjPath += $objCollectionPath
		}
		Return $arrObjPath
	}

	$objSite = Get-WmiObject -ComputerName $CentralSiteServer -Namespace root\sms -query &quot;Select * from SMS_ProviderLocation WHERE ProviderForLocalSite = True&quot;
	$CentralSiteCode= $objSite.SiteCode
	$CentralSiteProvider = $objSite.Machine

	$arrObjCollectionPath = new-object System.Collections.ArrayList
	$bFinished = $false
	$arrPath = Get-CollectionPathObject $strCollectionPath $CollectionID

	Foreach ($item in $arrPath) {$arrObjCollectionPath.Add($item) | Out-Null}
	Remove-Variable arrPath
	Do{
		$arrObjTempNew = @()
		$arrObjTempOld = @()
		Foreach ($item in $arrObjCollectionPath)
		{
				$objCollectionPath = Get-CollectionPathObject $item.CollectionPath $item.ParentCollectionID
				Foreach ($objPath in $objCollectionPath) {$arrObjTempNew += $objPath}
				$arrObjTempNew += $objCollectionPath
				$arrObjTempOld += $item
		}
		Foreach ($OldItem in $arrObjTempOld) {$arrObjCollectionPath.Remove($OldItem)}
		Foreach ($NewItem in $arrObjTempNew) {If (!($arrObjCollectionPath.Contains($NewItem))) {$arrObjCollectionPath.Add($NewItem) | Out-Null}}
		Remove-Variable arrObjTempOld
		Remove-Variable arrObjTempNew

		$AllReachedTop = $true
		Foreach ($item in $arrObjCollectionPath)
		{
			if ($($item.ParentCollectionID) -ne &quot;COLLROOT&quot;) {$AllReachedTop = $false}
		}
		IF ($AllReachedTop -eq $true) {$bFinished = $true}
	} While ($bFinished -ne $true)
$arrOutput = @()
Foreach ($item in $arrObjCollectionPath) {$arrOutput += $item.CollectionPath}
$arrOutput | fl *
[/sourcecode]