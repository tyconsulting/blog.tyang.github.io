---
id: 3509
title: Using Azure Automation to Build Your Own Microsoft OpsMgr MP Catalog on SharePoint Online
date: 2014-12-10T21:45:00+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=3509
permalink: /2014/12/10/using-azure-automation-build-microsoft-opsmgr-mp-catalog-sharepoint-online/
categories:
  - Azure
  - SCOM
tags:
  - Azure Automation
  - SCOM
  - SharePoint
---

## Background

Previously, I have posted how to <a href="https://blog.tyang.org/2014/12/09/using-sma-building-microsoft-opsmgr-management-pack-catalog-sharepoint-2013/">build your own Microsoft OpsMgr MP Catalog on SharePoint 2013 using SMA</a>. It is a solution that you can implement on-prem in your own environment if you have existing SharePoint 2013 and SMA infrastructure in place. As I mentioned at the end of the previous post, I have also developed a solution to populate this MP catalog on a Office 365 SharePoint Online site using Azure Automation – a 100% cloud based solution. Because of the differences in APIs between on-prem SharePoint 2013 and SharePoint online, one of the runbooks is completely different than the on-prem version. In this post, I will go through how I’ve setup the MP catalog on SharePoint Online using Azure Automation.

## 01. Create a List on the SharePoint Online site

The list creation and customization process is exactly the same as the On-Prem SharePoint 2013 version. I won’t go through this again. please refer to Step 1 and the customizing SharePoint List sections in my previous post.

## 02.  Create a Runbook to Retrieve Microsoft MP info

Again, this runbook is unchanged from the On-Prem version. Simply import it into your Azure Automation account.

**<a href="https://blog.tyang.org/wp-content/uploads/2014/12/Get-MSMPCatalog.zip">Download Get-MSMPCatalog</a>**

<a href="https://blog.tyang.org/wp-content/uploads/2014/12/SNAGHTML803890ed.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML803890ed" src="https://blog.tyang.org/wp-content/uploads/2014/12/SNAGHTML803890ed_thumb.png" alt="SNAGHTML803890ed" width="688" height="589" border="0" /></a>

## 03. Prepare the SMA Integration Module SharePointOnline

In order to authenticate to SharePoint Online sites, We must use a **SharePointOnlineCredentials **instance in the script. In my previously post, I wrote a runbook called Populate-OnPremMPCatalog. That runbook utilize Invoke-RestMethod PowerShell cmdlet to interact with SharePoint 2013’s REST API. Unfortunately, we cannot pass a SharePointOnlineCredentials object to this Cmdlet, therefore it cannot be used in this scenario.

Additionally, the SharePointOnlineCredentials class comes from the <a href="https://www.microsoft.com/en-us/download/details.aspx?id=35585">SharePoint Client Component SDK</a>. In order to create a SharePointOnlineCredentials object in PowerShell scripts, the script need to firstly load the assemblies from 2 DLLs that are part of the SDK. Because I can’t install this SDK in the Azure Automation runbook servers, I needed to figure out a way to be able to load these DLLs in my runbook.

As I have previously written SMA Integration Modules with DLLs embedded in. This time, I figured I can do the same thing – Creating a PowerShell / SMA Integration module that includes the required DLLs. Therefore, I’ve created a customised module in order to load the assemblies. But since the SDK also consists of other goodies, I have written few other functions to perform CRUD (Create, Read, Update, Delete) operations on SharePoint list items. These functions have made the runbook much simpler.

I called this module **SharePointOnline**, it consists of 5 files:

* **Microsoft.SharePoint.Client.dll** – One of required DLLs from the SDK
* **Microsoft.SharePoint.Client.Runtime.dll** – One of required DLLs from the SDK
* **SharePointOnline.psd1** – Module Manifest file
* **SharePointOnline.psm1** – PowerShell module file
* **SharePointOnline-Automation.json** – SMA Integration Module Meta File (where the connection asset is defined).

<a href="https://blog.tyang.org/wp-content/uploads/2014/12/image16.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/12/image_thumb16.png" alt="image" width="633" height="187" border="0" /></a>

**<a href="https://blog.tyang.org/wp-content/uploads/2014/12/SharePointOnline.zip">Download SharePointOnline Module</a>**

### <span style="color: #ff0000;"><span style="font-size: medium;">Note:</span> </span>

The zip file you’ve downloaded from the link above **DOES NOT** contain the 2 DLL files. I am not sure if Microsoft is OK with 3rd party distributing their software / intellectual properties. So, just to cover myself, you will need to download the SDK (64-bit version) from Microsoft directly (<a title="https://www.microsoft.com/en-us/download/details.aspx?id=35585" href="https://www.microsoft.com/en-us/download/details.aspx?id=35585">https://www.microsoft.com/en-us/download/details.aspx?id=35585</a>), install it on a 64-bit computer, and copy above mentioned 2 DLLs into the SharePointOnline module folder.

Once the SDK is installed, you can find these 2 files in **"C:\Program Files\Common Files\microsoft shared\Web Server Extensions\15\ISAPI\"** folder.

Once the DLLs are placed into the folder, zip the SharePointOnline folder to SharePointOnline.zip file again, and the integration module is ready.

<a href="https://blog.tyang.org/wp-content/uploads/2014/12/image17.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/12/image_thumb17.png" alt="image" width="405" height="134" border="0" /></a>

I’d like to also briefly go through this SharePointOnline module. This module contains the following functions:

* **Import-SharePointClientSDK:** Load the Assemblies from the 2 DLLs included in the module
* **New-SPOCredential:** Create a new SharePointOnlineCredentials object from the username and password provided.
* **Get-SPOListFields:** Get all fields from a SharePoint Online list (return an array object)
* **Add-SPOListItem:** Add an item to the SharePoint Online list (by passing in a hash table containing the value for each field)
* **Get-SPOListItems:** Get all items from a SharePoint Online list (return an array object)
* **Remove-SPOListItem:** Remove a list item from a SharePoint Online list (by providing the ID of the item)
* **Update-SPOListItem:** Update a list item (by providing the list Item ID and a hash table containing updated values)

This module is made to be re-used for SharePoint Online operations that involves list items. I will write a separate post to go through this in details. But for now, all we need to do is to import it into Azure Automation.

## 04. Import SharePointOnline Module into Azure Automation and Create SharePoint Online Connection

Now that the integration module is ready, it needs to be imported into your Azure Automation account. This is done via the Import Module button under Assets tab.

Once the module is imported, a connection object must also be created.

<a href="https://blog.tyang.org/wp-content/uploads/2014/12/SNAGHTML806ea00a.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML806ea00a" src="https://blog.tyang.org/wp-content/uploads/2014/12/SNAGHTML806ea00a_thumb.png" alt="SNAGHTML806ea00a" width="618" height="531" border="0" /></a>

<a href="https://blog.tyang.org/wp-content/uploads/2014/12/image18.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/12/image_thumb18.png" alt="image" width="446" height="286" border="0" /></a>

You must provide the following information when creating the SharePointOnline connection object:

1. **SharePointSiteURL** – The URL to your SharePoint Online site (i.e. https//yourcompany.sharepoint.com)
2. **UserName** – a User how should be part of the site members role (members group have contribute access). This username <strong>MUST</strong> be in the email address format. (i.e. <a href="mailto:yourname@yourcompany.com">yourname@yourcompany.com</a>). I believe this account must be an account created in the Office 365 subscription. I have tried using an outlook.com account (added as a SharePoint site member), it didn’t work.
3. **Password** – Password for the username you’ve specified.

i.e.

<a href="https://blog.tyang.org/wp-content/uploads/2014/12/SNAGHTML80731611.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML80731611" src="https://blog.tyang.org/wp-content/uploads/2014/12/SNAGHTML80731611_thumb.png" alt="SNAGHTML80731611" width="460" height="464" border="0" /></a>

## 05. Create a Runbook to Populate SharePoint List

This is equivalent to the previous runbook Populate-OnPremMPCatalog. I have named it **Populate-SPOnlineMPCatalog**.

**<a href="https://blog.tyang.org/wp-content/uploads/2014/12/Populate-SPOnlineMPCatalog.zip">Download Populate-SPOnlineMPCatalog Runbook</a>**

<a href="https://blog.tyang.org/wp-content/uploads/2014/12/SNAGHTML8093a11f.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML8093a11f" src="https://blog.tyang.org/wp-content/uploads/2014/12/SNAGHTML8093a11f_thumb.png" alt="SNAGHTML8093a11f" width="597" height="511" border="0" /></a>

This runbook is expecting 4 parameters:

* **SPOConnection:** The <strong>name</strong> of the SharePointOnline connection that you’ve created earlier.
* **ListName: **The list name of your MP catalog list.
* **NotifyByEmail:** Specify if you’d like an email notification when new MPs have been added to the catalog.
* **ContactName:** If NotifyByEmail is set to "true", specify the <a href="https://blog.tyang.org/2014/10/31/simplified-way-send-emails-mobile-push-notifications-sma/">SMAAddressBook</a> connection name for the email notification recipient.

**<span style="color: #ff0000;">Note:</span>** If you’d like to receive email notifications, you also need to import and configure the <a href="https://blog.tyang.org/2014/10/31/simplified-way-send-emails-mobile-push-notifications-sma/">SendEmail and SendPushNotification modules</a> from my blog. Once the SMTP server connection and the Address book connection are created, please modify line 111 of the runbook with the name of your SMTP server connection:

<a href="https://blog.tyang.org/wp-content/uploads/2014/12/image19.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/12/image_thumb19.png" alt="image" width="666" height="238" border="0" /></a>

**<span style="color: #ff0000;">Note:</span> **I have previously blogged the issues I have experienced using the SendEmail module in Azure Automation. You may find this post useful: <a href="https://blog.tyang.org/2014/12/07/using-sendemail-sma-integration-module-azure-automation/">Using the SendEmail SMA Integration Module in Azure Automation</a>.

&nbsp;

## 06. Executing Runbook Populate-SPOnlineMPCatalog

When executing the runbook, you need to fill out the parameters listed above:

<a href="https://blog.tyang.org/wp-content/uploads/2014/12/image20.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/12/image_thumb20.png" alt="image" width="472" height="408" border="0" /></a>

<a href="https://blog.tyang.org/wp-content/uploads/2014/12/image21.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/12/image_thumb21.png" alt="image" width="472" height="144" border="0" /></a>

Result:

<a href="https://blog.tyang.org/wp-content/uploads/2014/12/image22.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/12/image_thumb22.png" alt="image" width="442" height="600" border="0" /></a>

Same as the On-Prem version using SMA, you can create a schedule to run this on a regular basis to keep the catalog in sync with Microsoft. I won’t go through the schedule creation again.

## Azure Automation Fairshare

Currently, Azure Automation has a "Fairshare" feature, where the maximum allowed execution time for a job is 30 minutes. Fortunately, based on my multiple test runs against multiple Office 365 SharePoint online sites, the first executions of this runbook always complete JUST under 30 minutes. However, if you found your job in Azure Automation is terminated after 30 minutes, you should be able to just run it again to top up the list. But any subsequent runs should only take few minutes.

## Conclusion

To me, this post completes the circle. I’m happy that I am able to provide solutions for people who wants to host the catalog On-Premise (by using SharePoint 2013 and SMA), as well as who’d like to hosted in on the cloud (Office 365 and Azure Automation).

The 2 different runbooks (and the additional integration module) are 100% based on what SharePoint are you going to use. There is also a 3rd possible combination: Using SMA to populate SharePoint Online list. In this scenario, the steps are the same as what I described in this post. I have also tested in my lab. it is working as expected.

Additionally, I am also working with my fellow System Center MVP Dan Kregor to make this MP Catalog publicly available for everyone on Sparq Consulting’s public SharePoint Online site. We will make a separate announcement once it is ready. – So even if you can’t setup one up on-prem or on the cloud, we’ve got you covered <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" src="https://blog.tyang.org/wp-content/uploads/2014/12/wlEmoticon-smile1.png" alt="Smile" />.

## Credit

Thanks for all the System Center MVPs who have provided feedback and input into this solution. <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" src="https://blog.tyang.org/wp-content/uploads/2014/12/wlEmoticon-smile1.png" alt="Smile" />