---
id: 4173
title: 'OMSSearch Module Sample Runbook: Invoke-OMSSavedSearch'
date: 2015-07-10T22:38:00+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=4173
permalink: /2015/07/10/omssearch-module-sample-runbook-invoke-omssavedsearch/
categories:
  - OMS
  - PowerShell
  - SMA
tags:
  - Azure Automation
  - OMS
  - PowerShell
  - SMA
---
Over the last few days, I've been playing with the <a href="https://github.com/slavizh/OMSSearch" target="_blank">OMSSearch PowerShell / SMA / Azure Automation Module</a> my friend and fellow SCCDM MVP Stanislav Zhelyazkov has <a href="https://cloudadministrator.wordpress.com/2015/06/05/programmatically-search-operations-management-suite/" target="_blank">created</a>.

I am now part of this project on Github and have become the 3rd contributor (after Stan and Stefan Stranger). The module was updated yesterday (version 5.1.1) with some of my updates.

Today, I have written a sample runbook: **Invoke-OMSSavedSearch**. As the name suggests, it performs a **<u>user defined</u>** saved search.

>**Note:** due to the limitation of the OMS Search API, we can only retrieve the user defined saved searches. Therefore you cannot use this runbook for any built-in saved searches in OMS.

**Runbook:**

```powershell
workflow Invoke-OMSSavedSearch
{
  Param(
    [Parameter(Mandatory=$true)][String]$OMSConnectionName,
    [Parameter(Mandatory=$true)][String]$SavedSearchCategory,
    [Parameter(Mandatory=$true)][String]$SavedSearchName
  )
  #Retrieve OMS connection details
  $OMSConnection = Get-AutomationConnection -Name $OMSConnectionName
  $Token = Get-AADToken -OMSConnection $OMSConnection
  $SubscriptionID = $OMSConnection.SubscriptionID
  $ResourceGroupName = $OMSConnection.ResourceGroupName
  $WorkSpaceName = $OMSConnection.WorkSpaceName

  $SavedSearches = Get-OMSSavedSearches -SubscriptionID $SubscriptionID -ResourceGroupName $ResourceGroupName -OMSWorkspaceName $WorkSpaceName -Token $Token
  if ($SavedSearches -ne $null)
  {
    $arrSavedSearches = $SavedSearches.Properties
  }

  $bFound = $false
  Foreach ($item in $arrSavedSearches)
  {
    if ($item.DisplayName -ieq $SavedSearchName)
    {
      $objSavedSearch = $item
      $bFound = $true
    }
  }
  #Exit if the saved search is not found
  if ($bFound -eq $false)
  {
    Write-Error "Unable to find the saved search with name '$SavedSearchName' in category '$SavedSearchCategory'."
    Exit
  }

  $SearchQuery = $objSavedSearch.Query
  Write-Verbose "Execting search query `"$SearchQuery`"."
  $SearchResult = Invoke-OMSSearchQuery -SubscriptionID $SubscriptionID -ResourceGroupName $ResourceGroupName -OMSWorkspaceName $WorkSpaceName -Query $SearchQuery -Token $Token
  $SearchResult
}
```

This runbook expects 3 input parameters:

<a href="https://blog.tyang.org/wp-content/uploads/2015/07/image20.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/07/image_thumb20.png" alt="image" width="473" height="409" border="0" /></a>

* **OMSConnectionName:** the name of the OMS Connection object defined in SMA or Azure Automation
* **SavedSearchCategory:** the saved search category you specified when you saved the search query
* **SavedSearchName:** the display name of the saved search you specified when you saved the search query

<a href="https://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTML23f6a166.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML23f6a166" src="https://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTML23f6a166_thumb.png" alt="SNAGHTML23f6a166" width="501" height="375" border="0" /></a>

Runbook Result in SMA:

<a href="https://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTML23f938da.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML23f938da" src="https://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTML23f938da_thumb.png" alt="SNAGHTML23f938da" width="680" height="578" border="0" /></a>

Same event in OMS:

<a href="https://blog.tyang.org/wp-content/uploads/2015/07/image21.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/07/image_thumb21.png" alt="image" width="986" height="646" border="0" /></a>

**Pre-Requisite:**

This runbook is written based on version 5.1.1 of the OMSSearch Module. It will not work with the previous versions because I have added few additional paramters in the OMSConnection object which are used by this runbook.