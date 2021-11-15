---
id: 3138
title: 'SMA Runbook: Update A SharePoint 2013 List Item'
date: 2014-08-30T21:48:44+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=3138
permalink: /2014/08/30/sma-runbook-update-sharepoint-2013-list-item/
categories:
  - PowerShell
  - SMA
tags:
  - PowerShell
  - SharePoint
  - SMA
---

## Background

This blog hasn’t been too active lately. I’ve been spending a lot of time learning the new member in System Center family: Service Management Automation.

Yesterday, I needed a SMA runbook to update SharePoint 2013 list items, I found a sample from a <a href="http://blogs.technet.com/b/systemcenter/archive/2014/01/14/service-management-automation-and-sharepoint-mvp.aspx">blog post</a> by <a href="https://twitter.com/ChBooth">Christian Booth</a>, which contains a SMA runbook written by <a href="https://twitter.com/Randorfer">Ryan Andorfer</a>, a System Center Cloud and Datacenter MVP.  Looks Ryan’s code was written for SharePoint 2010, which does not work for SharePoint 2013 because the SharePoint REST API has been updated. So I have spent some time, learned a bit more about SharePoint 2013’s REST API, and developed a new runbook for SharePoint 2013 based on Ryan’s code.

## PowerShell Code

Here’s the finished work:
```powershell
Workflow Update-SharePointListItem
{
  Param(
    [Parameter(Mandatory=$true)][String]$SharepointSiteURL,
    [Parameter(Mandatory=$true)][String]$SavedCredentialName,
    [Parameter(Mandatory=$true)][String]$ListName,
    [Parameter(Mandatory=$true)][String]$ListItemID,
    [Parameter(Mandatory=$true)][String]$PropertyName,
    [Parameter(Mandatory=$true)][String]$PropertyValue
  )

  Function Update-SP2013ListItem
  {
    Param([String]$SiteUri, [String]$itemURI, [String]$PropertyName, [String]$PropertyValue, [string]$ListItemEntityTypeFullName, [PSCredential]$credential)

    $ContextInfoUri = "$SiteUri`/_api/contextinfo"
    $RequestDigest = (Invoke-RestMethod -Method Post -Uri $ContextInfoUri -Credential $credential).GetContextWebInformation.FormDigestValue
    $body = "{ '__metadata': { 'type': '$ListItemEntityTypeFullName' }, $PropertyName`: '$PropertyValue'}"
    $header = @{
    "accept" = "application/json;odata=verbose"
    "X-RequestDigest" = $RequestDigest
    "If-Match"="*"
    }
    Try {
      Invoke-RestMethod -Method MERGE -Uri $itemURI -Body $body -ContentType "application/json;odata=verbose" -Headers $header -Credential $credential
      $Updated = $true
    } Catch {
      $Updated = $false
    }
    $Updated
  }

  # Get the credential to authenticate to the SharePoint List with

  $credential = Get-AutomationPSCredential -Name $SavedCredentialName

  # combined uri

  #SharePoint 2013
  $ListItemsUri = [System.String]::Format("{0}/_api/web/lists/getbytitle('{1}')/items",$SharepointSiteURL, $ListName)
  $ListUri = [System.String]::Format("{0}/_api/web/lists/getbytitle('{1}')",$SharepointSiteURL, $ListName)

  #Get ListItemEntityTypeFullName
  $List = Invoke-RestMethod -uri $ListUri -credential $Credential
  $ListItemEntityTypeFullName = $list.entry.content.properties.ListItemEntityTypeFullName
  $ListItemEntityTypeFullName

  #Translating Field display name (title) to the internal name
  $FieldFilter = "Title eq '$PropertyName'"
  $ListFieldUri = "$ListUri`/Fields?`$Filter=$FieldFilter"
  $ListField = Invoke-RestMethod -Uri $ListFieldUri -Credential $credential
  $FieldInternalName = $ListField.Content.properties.InternalName

  #Get list items
  $listItemURI = inlinescript {
    $listItems = Invoke-RestMethod -Uri $Using:ListItemsUri -Credential $Using:credential
    foreach($li in $listItems)
    {
      $ItemId = $li.Id.split("/")[2].replace("Items", "")
      $ItemId = $ItemId.replace("(","")
      $ItemId = $ItemId.replace(")","")
      If ($ItemId -eq $USING:ListItemID)
      {
        #This is the item URI for the specific list item that we are looking for.
        $itemUri = [System.String]::Format("{0}/_api/{1}",$USING:SharepointSiteURL, $li.id)
      }
    }
    $itemUri
  }
  #Update the list property
  If ($listItemURI)
  {
    Write-Output "Updating $listItemURI. Setting $PropertyName to '$PropertyValue'"
    $Updated = Update-SP2013ListItem -SiteUri $SharepointSiteURL -itemURI $listItemURI -PropertyName $FieldInternalName -PropertyValue $PropertyValue -ListItemEntityTypeFullName $ListItemEntityTypeFullName -credential $credential
  }

  If ($Updated -eq $true)
  {
    Write-OutPut "List item $listItemURI successfully updated."
  } else {
    Write-Error "Failed to update the list item $listItemURI."
  }
}

```
Unlike Ryan’s code, which also monitors the SP list, my runbook **ONLY** updates a specific list item.

## Pre-Requisite and Parameters

Prior to using this runbook, you will need to save a credential in SMA which has  access to the SharePoint site

<a href="https://blog.tyang.org/wp-content/uploads/2014/08/SNAGHTML7ebadf0.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML7ebadf0" src="https://blog.tyang.org/wp-content/uploads/2014/08/SNAGHTML7ebadf0_thumb.png" alt="SNAGHTML7ebadf0" width="299" height="411" border="0" /></a>

The runbook is expecting the following parameters:

* **SharePointSiteURL:** The URL to the sharepoint site. i.e. <a href="http://SharepointServer/Sites/DemoSite">http://SharepointServer/Sites/DemoSite</a>
* **SavedCredentialName:** name of the saved credential to connect to SharePoint site
* **ListName:** Name of the list. i.e. "Test List"
* **ListItemID:** the ID for the list item that the runbook is going to update
* **PropertyName:** the field / property of the item that is going to be updated.
* **PropertyValue:** the new value that is going to be set to the list item property.

Note: The list Item ID is the reference number for the item within the list. If you point the mouse cursor to the item, you will find the list item ID in the URL.

<a href="https://blog.tyang.org/wp-content/uploads/2014/08/SNAGHTML90254b7.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML90254b7" src="https://blog.tyang.org/wp-content/uploads/2014/08/SNAGHTML90254b7_thumb.png" alt="SNAGHTML90254b7" width="671" height="393" border="0" /></a>

## Putting it into Test

To test, I’ve created a new list as shown in the above screenshot, I have kicked off the runbook with the the following parameters:

<a href="https://blog.tyang.org/wp-content/uploads/2014/08/image8.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/08/image_thumb8.png" alt="image" width="379" height="354" border="0" /></a>

<a href="https://blog.tyang.org/wp-content/uploads/2014/08/image9.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/08/image_thumb9.png" alt="image" width="383" height="389" border="0" /></a>

Here’s the result:

<a href="https://blog.tyang.org/wp-content/uploads/2014/08/SNAGHTML8fd5d4a.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML8fd5d4a" src="https://blog.tyang.org/wp-content/uploads/2014/08/SNAGHTML8fd5d4a_thumb.png" alt="SNAGHTML8fd5d4a" width="588" height="406" border="0" /></a>

<a href="https://blog.tyang.org/wp-content/uploads/2014/08/SNAGHTML8fed515.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML8fed515" src="https://blog.tyang.org/wp-content/uploads/2014/08/SNAGHTML8fed515_thumb.png" alt="SNAGHTML8fed515" width="580" height="383" border="0" /></a>


## Using It Together With Orchestrator SharePoint IP

Since this SMA runbook requires the List Item ID to locate the specific list item, when you design your solution, you will need to find a way to retrieve this parameter prior to calling this runbook.

If you are also using SC Orchestrator and have deployed the SharePoint IP, you can use the "Monitor List Items" activity, and the List Item ID is published by this activity:

<a href="https://blog.tyang.org/wp-content/uploads/2014/08/image10.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/08/image_thumb10.png" alt="image" width="385" height="333" border="0" /></a>

## Conclusion

Although I’m still a newbie when comes to SMA, it got me really excited. Before its time, when I design Orchestrator runbooks, I often ended up just write the entire solution in PowerShell and then chopped up my PowerShell scripts into many "Run .Net Script" activities. I thought, wouldn’t it be nice if there is an automation engine that only uses PowerShell? Well, looks like SMA is the solution. I wish I have started using it sooner.

If you are like me and want to learn more about this product, i **<span style="color: #ff0000;">highly</span>** recommend you to read the <a href="http://gallery.technet.microsoft.com/systemcenter/Service-Management-fcd75828">Service Management Automation Whitepaper</a> (currently version 1.0.4) from my fellow SCCDM MVP Michael Rueefli. I have read it page by page like a bible!