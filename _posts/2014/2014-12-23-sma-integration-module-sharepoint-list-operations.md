---
id: 3611
title: A SMA Integration Module For SharePoint List Operations
date: 2014-12-23T14:38:49+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=3611
permalink: /2014/12/23/sma-integration-module-sharepoint-list-operations/
categories:
  - PowerShell
  - SMA
tags:
  - PowerShell
  - SharePoint
  - SMA
---
## Background

Many Microsoft System Center Orchestrator and Service Management Automation (SMA) users may agree with me, that these two automation platform does not have feature rich end user portals natively. Although System Center Service Manager can be used as a user portal for triggering SCORCH/SMA runbooks, Microsoft SharePoint is also a very good candidate for this purpose.

Integrating SharePoint with Orchestrator and SMA is not something new, many people have done this already. i.e.

[System Center Universe America 2014 – Orchestrating Daily Tasks Like a Pro (by Pete Zerger and Anders Bengtsson)](http://channel9.msdn.com/Blogs/System-Center-Universe-America-2014/Master-Class-Orchestrating-Daily-Tasks-Like-a-Pro)

[Service Management Automation and SharePoint (by Christian Booth and Ryan Andorfer)](http://blogs.technet.com/b/systemcenter/archive/2014/01/14/service-management-automation-and-sharepoint-mvp.aspx)

In my opinion, SharePoint (especially SharePoint lists) provides a quick and easy way to setup a web based end user portal for orchestration runbooks. I have also blogged my experiences in the past:

[My Experience Manipulating MDT Database Using SMA, SCORCH and SharePoint](https://blog.tyang.org/2014/11/20/experience-manipulating-mdt-database-using-sma-scorch-sharepoint/)

[SMA Runbook: Update A SharePoint 2013 List Item](https://blog.tyang.org/2014/08/30/sma-runbook-update-sharepoint-2013-list-item/)

To me, not only I am using SharePoint 2013 in my lab; SharePoint Online from my Office 365 subscription, I also have no choice but using SharePoint 2010 in real life.

In my opinion, it is complicated to write SMA runbooks to interact with SharePoint (Using SharePoint web based APIs), not to mention the different versions of SharePoint also dictates how the runbook should be written. It is easier to use Orchestrator as a middle man in between SMA and SharePoint so we can use Orchestrator’s SharePoint integration pack.

Earlier this month, I was developing solutions to use SMA and Azure Automation to create OpsMgr Management Packs catalog on SharePoint 2013 / SharePoint Online sites. I have blogged the 2 solutions here:

[On-Premise Solution (SMA + SharePoint 2013)](https://blog.tyang.org/2014/12/09/using-sma-building-microsoft-opsmgr-management-pack-catalog-sharepoint-2013/)

[Cloud Based Solution (Azure Automation + SharePoint Online)](https://blog.tyang.org/2014/12/10/using-azure-automation-build-microsoft-opsmgr-mp-catalog-sharepoint-online/)

As I mentioned in the previous posts, I had to write a separate SMA module to be used in Azure Automation to interact with SharePoint Online because SharePoint Online sites require a different type of credential (SharePointOnlineCredential) that the PowerShell cmdlet Invoke-RESTMethod does not support. I called that module SharePointOnline back in the previous post and it utilises assemblies from the SharePoint Client Component SDK. I think the SharePoint people also refer to this SDK as Client-Side Object Model (CSOM)

After the MP catalogs posts were published, I have decided to spend a bit more time on the SharePoint Client Component SDK and see if it can help me simplify the activities between SMA and SharePoint. I was really happy to find out, the [SharePoint Client Component SDK](https://www.microsoft.com/en-us/download/details.aspx?id=35585) works for SharePoint 2013, SharePoint Online and SharePoint 2010 (limited). So I have decided to update and extend the original module, making it a generic module for all 3 flavours of SharePoint.

After couple of weeks of coding and testing, I’m pleased to announce the new module is now ready to be released. I have renamed this module to **SharePointSDK** (Sorry I’m not really creative with names :stuck_out_tongue:).

## SharePointSDK Module Introduction
The SharePointSDK module contains the following functions:

![](https://blog.tyang.org/wp-content/uploads/2014/12/image40.png)

**CRUD Operations for SharePoint List items:**

| Function          | Description                                                                               | Compatible SharePoint Version |
| ----------------- | ----------------------------------------------------------------------------------------- | ----------------------------- |
| Add-SPListItem    | Add an item to a SharePoint list                                                          | 2010, 2013 and SP Online      |
| Get-SPListFields  | Get all fields of a SharePoint list                                                       | 2010, 2013 and SP Online      |
| Get-SPListItem    | Get all list items of a SharePoint list or a specific item by specifying the List Item ID | 2010, 2013 and SP Online      |
| Remove-SPListItem | Delete an item from a SharePoint list                                                     | 2010, 2013 and SP Online      |
| Update-SPListItem | Update one or more field values of a SharePoint list item                                 | 2010, 2013 and SP Online      |


The functions listed above are the core functionalities this module provides. it provides simplified ways to manipulate SharePoint list items (Create, Read, Update, Delete).

**Miscellaneous Functions**

| Function            | Description                                                                                                                                  | Compatible SharePoint Version |
| ------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| Import-SPClientSDK  | Load SharePoint Client Component SDK DLLs                                                                                                    | 2010, 2013 and SP Online      |
| New-SPCredential    | Based on the type of SharePoint site (On-Prem vs SP Online), create an appropriate credential object to authenticate to the Sharepoint site. | 2010, 2013 and SP Online      |
| Get-SPServerVersion | Get SharePoint server version                                                                                                                | 2010, 2013 and SP Online      |

These functions are called by other functions in the modules. It is unlikely that runbook authors will need to use them directly.

**SharePoint List Attachments Operations**


| Function                    | Description                                                              | Compatible SharePoint Version |
| --------------------------- | ------------------------------------------------------------------------ | ----------------------------- |
| Add-SPListItemAttachment    | Add an attachment to a SharePoint list item                              | 2013 and SP Online            |
| Get-SPListItemAttachments   | Download all attached files from a SharePoint list item                  | 2013 and SP Online            |
| Remove-SPListItemAttachment | Delete an attached file (based on file name) from a SharePoint list item | 2013 and SP Online            |

As the names suggest, these functions can be used to manage attachments for SharePoint list items.

I’d like to point out  that the **Add-SPListItemAttachment** function not only support uploading an existing file to the SharePoint list item. it can also be used to create an attachment file directly using a byte array. This function can be used in 3 scenarios:

* Uploading an existing file from the file system
* Directly creating a text based file with some contents as a list item attachment.
* Read the content of an existing binary (or text)  file, save it as a attachment with a different name


## Configuration Requirements
**Download and Prepare the module**

The module zip file should consist the following 5 files:

![](https://blog.tyang.org/wp-content/uploads/2014/12/image41.png)

* **Microsoft.SharePoint.Client.dll** – One of required DLLs from the SDK
* **Microsoft.SharePoint.Client.Runtime.dll** – One of required DLLs from the SDK
* **SharePointSDK.psd1** – Module Manifest file
* **SharePointSDK.psm1** – PowerShell module file
* **SharePointSDK-Automation.json** – SMA Integration Module Meta File (where the connection asset is defined).

[**Download SharePointSDK Module**](https://blog.tyang.org/wp-content/uploads/2014/12/SharePointSDK.zip)

> **Note:** The zip file you’ve downloaded from the link above **<em>DOES NOT</em>** contain the 2 DLL files. I am not sure if Microsoft is OK with me distributing their software / intellectual properties. So, just to cover myself, you will need to download the SDK (64-bit version) from Microsoft directly ([https://www.microsoft.com/en-us/download/details.aspx?id=35585](https://www.microsoft.com/en-us/download/details.aspx?id=35585)), install it on a 64-bit computer, and copy above mentioned 2 DLLs into the SharePointOnline module folder.

Once the SDK is installed, you can find these 2 files in **"C:\Program Files\Common Files\microsoft shared\Web Server Extensions\15\ISAPI\"** folder.

Once the DLLs are placed into the folder, zip the SharePointSDK folder to SharePointSDK.zip file again, and the integration module is ready.

![](ttp://blog.tyang.org/wp-content/uploads/2014/12/image81.png)

**Import Module**

Once the DLLs are zipped into the module zip file, import the module into SMA by using the Import Module button under Assets tab

![](https://blog.tyang.org/wp-content/uploads/2014/12/image111.png)

**Create a Connection object to the SharePoint site**

After the module has been successfully, a connection to SharePoint Site must be created. The Connection type is "SharePointSDK"

![](https://blog.tyang.org/wp-content/uploads/2014/12/image42.png)

The following fields must be filled out:

* **Name:** Name of the connection.
* **SharePointSiteURL:** URL to your sharepoint site
* **UserName** : a User who should be part of the site members role (members group have contribute access).
  * If the site is a SharePoint Onine site, this username **MUST** be in the email address format. (i.e. *yourname@yourcompany.com*). I believe this account must be an account created in the Office 365 subscription. I have tried using an outlook.com account (added as a SharePoint site member), it didn’t work.
  * When connecting to a On-Prem SharePoint site, you can use the Domain\UserName format (As shown in the screenshot below)
* **Password:** Password for the username you’ve specified.
* **IsSharePointOnlineSite:** Boolean field (TRUE or FALSE), specify if it is a SharePoint Online site.

i.e. the connection to a SharePoint site in my lab:

![](https://blog.tyang.org/wp-content/uploads/2014/12/image43.png)

## Sample Runbooks
In order to better demonstrate this module, I have also created 10 sample runbooks:

<a href="https://blog.tyang.org/wp-content/uploads/2014/12/image44.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/12/image_thumb44.png" alt="image" width="704" height="290" border="0" /></a>

[**Download Sample runbooks**](https://blog.tyang.org/wp-content/uploads/2014/12/Sample-Runbooks.zip)

I’ll now go through each sample runbook.

**Runbook: Sample-SPNewUserRequestList**

This sample runbook creates a brand new dummy new users requests list on your SharePoint site. The list created by this runbook will then be used by other sample runbooks (for demonstration purposes).

This runbook is expecting 2 input parameters:

* ListName: The Display Name that you’d like to name the new users requests list (i.e. New Users OnBoarding Requests).
* SPConnection: The name of the SharePointSDK connection that you’ve created previously (i.e. Based on the connection I’ve created in my lab as shown previously, it is "RequestsSPSite"

![](https://blog.tyang.org/wp-content/uploads/2014/12/image45.png)

This runbook creates a list with the following fields:

![](https://blog.tyang.org/wp-content/uploads/2014/12/image46.png)

**Runbook: Sample-SPGetListFields**

This runbook demonstrates how to retrieve all the fields of a particular list.

![](https://blog.tyang.org/wp-content/uploads/2014/12/image47.png)

**Runbook: Sample-SPAddListItem**

This runbook adds an item to the New Users Requests list the previous runbook created. It also demonstrates how to create a text file attachment directly to the list item (without having the need for an existing file on the file system).

It is expecting the following inputs:

* Title (New users title, i.e. Mr. Dr. Ms, etc)
* FirstName (New user’s first name)
* LastName (New user’s last name)
* Gender (New user’s Gender: Male / Female)
* UserName (New user’s user vname)
* AttachmentFileName (file name of the text based attachment)
* TextAttachmentContent (content of the text file attachment)
* NewUserListName (display name of the new users requests list. i.e. New Users OnBoarding Requests)
* SPConnection (The name of the SharePointSDK connection that you’ve created previously (i.e. Based on the connection I’ve created in my lab as shown previously, it is "RequestsSPSite")

i.e.

![](https://blog.tyang.org/wp-content/uploads/2014/12/image48.png)

The list item is created on SharePoint:

![](https://blog.tyang.org/wp-content/uploads/2014/12/SNAGHTML1d5a6df8.png)

Attachment content:

![](https://blog.tyang.org/wp-content/uploads/2014/12/image49.png)

**Runbook: Sample-SPUpdateListItem**

This runbook can be used to update fields of an existing list item on the New Users Requests list.

**Runbook: Sample-SPGetAllListItems**

This runbook can be used to retrieve ALL items from a list. Each list item are presented as a hash table.

![](https://blog.tyang.org/wp-content/uploads/2014/12/image50.png)

**Runbook: Sample-SPGetListItem**

This runbook can be used to retrieve a single item from a list.

![](https://blog.tyang.org/wp-content/uploads/2014/12/image51.png)

**Runbook: Sample-SPDeleteListItem**

This runbook deletes a single list item by specifying the List Item ID.

**Runbook: Sample-SPAddListItemAttachment**

This runbook demonstrates 2 scenarios:

* Directly attaching a file to a list item
* attach and rename a file to a list item

![](ttp://blog.tyang.org/wp-content/uploads/2014/12/image52.png)

![](https://blog.tyang.org/wp-content/uploads/2014/12/image53.png)

**Runbook: Sample-SPDeleteListItemAttachments**

This runbook demonstrates how to delete an attachment from a list item (by specifying the file name).

**Runbook: Sample-SPDownloadListItemAttachments**

This runbook demonstrates how to download all files attached to a list item:

![](https://blog.tyang.org/wp-content/uploads/2014/12/image54.png)

Files downloaded to the destination folder:

![](https://blog.tyang.org/wp-content/uploads/2014/12/image55.png)

## Benefit of Using the SharePointSDK Module

**Using as a Regular PowerShell Module**

As we all know, SMA modules are simply PowerShell modules (sometimes with optional SMA module meta file .json for creating connections). Although this module is primarily written for SMA, it can also be used in other environments such as a regular PowerShell module or in Azure Automation. When using it as a normal PowerShell module, instead of passing the SMA connection name into the functions inside the module, you may provide each individual value separately (Username, password, SharePoint Site URL, IsSharePointOnlineSite).

**Simplified scripts to interact with SharePoint**

When using this module, most of the operations around the list item only takes very few lines of code.

i.e. Retrieving a list item:

Using PowerShell:

```powershell
$ListItem = Get-SPListItem -SiteUrl "https://yourcompany.sharepoint.com" -UserName "you@yourcompany.com" -Password "password1234" -IsSPO $true -ListName "Test List" -ListItemID 1
```

Using PowerShell Workflow (in SMA):

```powershell
$Conn = Get-AutomationConnection -Name $SPConnection
$ListItem = InlineScript
{
	Import-Module SharePointSDK
	$ListItem = Get-SPListItem -SPConnection $USING:Conn -ListName Test List" -ListItemID 1
	$ListItem
}
```
If you use SharePoint 2013’s REST API, the script will be much longer than what I’ve shown above.

**Same Code for Different SharePoint Versions**

The SharePoint REST API has been updated in SharePoint 2013. Therefore, if we are to use the REST API, the code for Share Point 2013 would look different than SharePoint 2010. Additionally, when throwing SharePoint Online into the mix, as I mentioned previously, it requires different type of credential for authentication, it further complicates the situation if we are to use the REST API. This makes our scripts and runbooks less generic.

By using this SharePointSDK module, I am able to use the same runbooks on SharePoint 2010, 2013 and SharePoint Online sites.

## Limitations
During testing, I noticed the 3 attachments related functions in the SharePointSDK module would not work on SharePoint 2010 sites. These functions are:

* Add-SPListItemAttachment
* Remove-SPListItemAttachment
* Get-SPListItemAttachments

After a bit of research, looks like it is a known issue. I didn’t think it too much a big deal because all the core functions (CRUD operations for the list items) work with SharePoint 2010. Therefore, in these 3 functions, I’ve coded a validation step to exit if the SharePoint Server version is below version 15 (SharePoint 2013):

![](https://blog.tyang.org/wp-content/uploads/2014/12/image56.png)

## Conclusion
If you are using SMA and SharePoint together, I strongly recommend you to download this module and the sample runbooks and give it a try. If you have a look at the sample runbooks, I’m sure you will realise how easy it is to write PowerShell code interacting with SharePoint.

In case you didn’t see the download links, you can download them here:

[**Download SharePointSDK Module**](https://blog.tyang.org/wp-content/uploads/2014/12/SharePointSDK.zip)

[**Download Sample Runbooks**](https://blog.tyang.org/wp-content/uploads/2014/12/Sample-Runbooks.zip)

Lastly, I’m not a SharePoint specialist. If you believe I’ve made any mistakes in my code, or there is room for improvement, I’d like to hear from you. Please feel free to drop me an email :smiley:.