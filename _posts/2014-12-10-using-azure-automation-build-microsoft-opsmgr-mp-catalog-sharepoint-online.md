---
id: 3509
title: Using Azure Automation to Build Your Own Microsoft OpsMgr MP Catalog on SharePoint Online
date: 2014-12-10T21:45:00+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=3509
permalink: /2014/12/10/using-azure-automation-build-microsoft-opsmgr-mp-catalog-sharepoint-online/
categories:
  - Azure
  - SCOM
tags:
  - Azure Automation
  - SCOM
  - SharePoint
---
<h3>Background</h3>
Previously, I have posted how to <a href="http://blog.tyang.org/2014/12/09/using-sma-building-microsoft-opsmgr-management-pack-catalog-sharepoint-2013/">build your own Microsoft OpsMgr MP Catalog on SharePoint 2013 using SMA</a>. It is a solution that you can implement on-prem in your own environment if you have existing SharePoint 2013 and SMA infrastructure in place. As I mentioned at the end of the previous post, I have also developed a solution to populate this MP catalog on a Office 365 SharePoint Online site using Azure Automation – a 100% cloud based solution. Because of the differences in APIs between on-prem SharePoint 2013 and SharePoint online, one of the runbooks is completely different than the on-prem version. In this post, I will go through how I’ve setup the MP catalog on SharePoint Online using Azure Automation.
<h3>01. Create a List on the SharePoint Online site</h3>
The list creation and customization process is exactly the same as the On-Prem SharePoint 2013 version. I won’t go through this again. please refer to Step 1 and the customizing SharePoint List sections in my previous post.
<h3>02.  Create a Runbook to Retrieve Microsoft MP info</h3>
Again, this runbook is unchanged from the On-Prem version. Simply import it into your Azure Automation account.

<strong><a href="http://blog.tyang.org/wp-content/uploads/2014/12/Get-MSMPCatalog.zip">Download Get-MSMPCatalog</a></strong>

<a href="http://blog.tyang.org/wp-content/uploads/2014/12/SNAGHTML803890ed.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML803890ed" src="http://blog.tyang.org/wp-content/uploads/2014/12/SNAGHTML803890ed_thumb.png" alt="SNAGHTML803890ed" width="688" height="589" border="0" /></a>
<h3></h3>
<h3>03. Prepare the SMA Integration Module SharePointOnline</h3>
In order to authenticate to SharePoint Online sites, We must use a <strong>SharePointOnlineCredentials </strong>instance in the script. In my previously post, I wrote a runbook called Populate-OnPremMPCatalog. That runbook utilize Invoke-RestMethod PowerShell cmdlet to interact with SharePoint 2013’s REST API. Unfortunately, we cannot pass a SharePointOnlineCredentials object to this Cmdlet, therefore it cannot be used in this scenario.

Additionally, the SharePointOnlineCredentials class comes from the <a href="https://www.microsoft.com/en-us/download/details.aspx?id=35585">SharePoint Client Component SDK</a>. In order to create a SharePointOnlineCredentials object in PowerShell scripts, the script need to firstly load the assemblies from 2 DLLs that are part of the SDK. Because I can’t install this SDK in the Azure Automation runbook servers, I needed to figure out a way to be able to load these DLLs in my runbook.

As I have previously written SMA Integration Modules with DLLs embedded in. This time, I figured I can do the same thing – Creating a PowerShell / SMA Integration module that includes the required DLLs. Therefore, I’ve created a customised module in order to load the assemblies. But since the SDK also consists of other goodies, I have written few other functions to perform CRUD (Create, Read, Update, Delete) operations on SharePoint list items. These functions have made the runbook much simpler.

I called this module <strong>SharePointOnline</strong>, it consists of 5 files:
<ul>
	<li><strong>Microsoft.SharePoint.Client.dll</strong> – One of required DLLs from the SDK</li>
	<li><strong>Microsoft.SharePoint.Client.Runtime.dll</strong> – One of required DLLs from the SDK</li>
	<li><strong>SharePointOnline.psd1</strong> – Module Manifest file</li>
	<li><strong>SharePointOnline.psm1</strong> – PowerShell module file</li>
	<li><strong>SharePointOnline-Automation.json</strong> – SMA Integration Module Meta File (where the connection asset is defined).</li>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2014/12/image16.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/12/image_thumb16.png" alt="image" width="633" height="187" border="0" /></a>

<strong><a href="http://blog.tyang.org/wp-content/uploads/2014/12/SharePointOnline.zip">Download SharePointOnline Module</a></strong>
<h4><span style="color: #ff0000;"><span style="font-size: medium;">Note:</span> </span></h4>
The zip file you’ve downloaded from the link above <strong><em>DOES NOT</em></strong> contain the 2 DLL files. I am not sure if Microsoft is OK with 3rd party distributing their software / intellectual properties. So, just to cover myself, you will need to download the SDK (64-bit version) from Microsoft directly (<a title="https://www.microsoft.com/en-us/download/details.aspx?id=35585" href="https://www.microsoft.com/en-us/download/details.aspx?id=35585">https://www.microsoft.com/en-us/download/details.aspx?id=35585</a>), install it on a 64-bit computer, and copy above mentioned 2 DLLs into the SharePointOnline module folder.

Once the SDK is installed, you can find these 2 files in <strong>"C:\Program Files\Common Files\microsoft shared\Web Server Extensions\15\ISAPI\"</strong> folder.

Once the DLLs are placed into the folder, zip the SharePointOnline folder to SharePointOnline.zip file again, and the integration module is ready.

<a href="http://blog.tyang.org/wp-content/uploads/2014/12/image17.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/12/image_thumb17.png" alt="image" width="405" height="134" border="0" /></a>

I’d like to also briefly go through this SharePointOnline module. This module contains the following functions:
<ul>
	<li><strong>Import-SharePointClientSDK:</strong> Load the Assemblies from the 2 DLLs included in the module</li>
	<li><strong>New-SPOCredential:</strong> Create a new SharePointOnlineCredentials object from the username and password provided.</li>
	<li><strong>Get-SPOListFields:</strong> Get all fields from a SharePoint Online list (return an array object)</li>
	<li><strong>Add-SPOListItem:</strong> Add an item to the SharePoint Online list (by passing in a hash table containing the value for each field)</li>
	<li><strong>Get-SPOListItems:</strong> Get all items from a SharePoint Online list (return an array object)</li>
	<li><strong>Remove-SPOListItem:</strong> Remove a list item from a SharePoint Online list (by providing the ID of the item)</li>
	<li><strong>Update-SPOListItem:</strong> Update a list item (by providing the list Item ID and a hash table containing updated values)</li>
</ul>
This module is made to be re-used for SharePoint Online operations that involves list items. I will write a separate post to go through this in details. But for now, all we need to do is to import it into Azure Automation.

&nbsp;
<h3>04. Import SharePointOnline Module into Azure Automation and Create SharePoint Online Connection</h3>
Now that the integration module is ready, it needs to be imported into your Azure Automation account. This is done via the Import Module button under Assets tab.

Once the module is imported, a connection object must also be created.

<a href="http://blog.tyang.org/wp-content/uploads/2014/12/SNAGHTML806ea00a.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML806ea00a" src="http://blog.tyang.org/wp-content/uploads/2014/12/SNAGHTML806ea00a_thumb.png" alt="SNAGHTML806ea00a" width="618" height="531" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2014/12/image18.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/12/image_thumb18.png" alt="image" width="446" height="286" border="0" /></a>

You must provide the following information when creating the SharePointOnline connection object:
<ol>
	<li><strong>SharePointSiteURL</strong> – The URL to your SharePoint Online site (i.e. https//yourcompany.sharepoint.com)</li>
	<li><strong>UserName</strong> – a User how should be part of the site members role (members group have contribute access). This username <strong>MUST</strong> be in the email address format. (i.e. <a href="mailto:yourname@yourcompany.com">yourname@yourcompany.com</a>). I believe this account must be an account created in the Office 365 subscription. I have tried using an outlook.com account (added as a SharePoint site member), it didn’t work.</li>
	<li><strong>Password</strong> – Password for the username you’ve specified.</li>
</ol>
i.e.

<a href="http://blog.tyang.org/wp-content/uploads/2014/12/SNAGHTML80731611.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML80731611" src="http://blog.tyang.org/wp-content/uploads/2014/12/SNAGHTML80731611_thumb.png" alt="SNAGHTML80731611" width="460" height="464" border="0" /></a>

&nbsp;
<h3>05. Create a Runbook to Populate SharePoint List</h3>
This is equivalent to the previous runbook Populate-OnPremMPCatalog. I have named it <strong>Populate-SPOnlineMPCatalog</strong>.

<strong><a href="http://blog.tyang.org/wp-content/uploads/2014/12/Populate-SPOnlineMPCatalog.zip">Download Populate-SPOnlineMPCatalog Runbook</a></strong>

<a href="http://blog.tyang.org/wp-content/uploads/2014/12/SNAGHTML8093a11f.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML8093a11f" src="http://blog.tyang.org/wp-content/uploads/2014/12/SNAGHTML8093a11f_thumb.png" alt="SNAGHTML8093a11f" width="597" height="511" border="0" /></a>

This runbook is expecting 4 parameters:
<ul>
	<li><strong>SPOConnection:</strong> The <strong>name</strong> of the SharePointOnline connection that you’ve created earlier.</li>
	<li><strong>ListName: </strong>The list name of your MP catalog list.</li>
	<li><strong>NotifyByEmail:</strong> Specify if you’d like an email notification when new MPs have been added to the catalog.</li>
	<li><strong>ContactName:</strong> If NotifyByEmail is set to "true", specify the <a href="http://blog.tyang.org/2014/10/31/simplified-way-send-emails-mobile-push-notifications-sma/">SMAAddressBook</a> connection name for the email notification recipient.</li>
</ul>
<strong><span style="color: #ff0000;">Note:</span></strong> If you’d like to receive email notifications, you also need to import and configure the <a href="http://blog.tyang.org/2014/10/31/simplified-way-send-emails-mobile-push-notifications-sma/">SendEmail and SendPushNotification modules</a> from my blog. Once the SMTP server connection and the Address book connection are created, please modify line 111 of the runbook with the name of your SMTP server connection:

<a href="http://blog.tyang.org/wp-content/uploads/2014/12/image19.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/12/image_thumb19.png" alt="image" width="666" height="238" border="0" /></a>

<strong><span style="color: #ff0000;">Note:</span> </strong>I have previously blogged the issues I have experienced using the SendEmail module in Azure Automation. You may find this post useful: <a href="http://blog.tyang.org/2014/12/07/using-sendemail-sma-integration-module-azure-automation/">Using the SendEmail SMA Integration Module in Azure Automation</a>.

&nbsp;
<h3>06. Executing Runbook Populate-SPOnlineMPCatalog</h3>
When executing the runbook, you need to fill out the parameters listed above:

<a href="http://blog.tyang.org/wp-content/uploads/2014/12/image20.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/12/image_thumb20.png" alt="image" width="472" height="408" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2014/12/image21.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/12/image_thumb21.png" alt="image" width="472" height="144" border="0" /></a>

Result:

<a href="http://blog.tyang.org/wp-content/uploads/2014/12/image22.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/12/image_thumb22.png" alt="image" width="442" height="600" border="0" /></a>

Same as the On-Prem version using SMA, you can create a schedule to run this on a regular basis to keep the catalog in sync with Microsoft. I won’t go through the schedule creation again.
<h3>Azure Automation Fairshare</h3>
Currently, Azure Automation has a "Fairshare" feature, where the maximum allowed execution time for a job is 30 minutes. Fortunately, based on my multiple test runs against multiple Office 365 SharePoint online sites, the first executions of this runbook always complete JUST under 30 minutes. However, if you found your job in Azure Automation is terminated after 30 minutes, you should be able to just run it again to top up the list. But any subsequent runs should only take few minutes.
<h3>Conclusion</h3>
To me, this post completes the circle. I’m happy that I am able to provide solutions for people who wants to host the catalog On-Premise (by using SharePoint 2013 and SMA), as well as who’d like to hosted in on the cloud (Office 365 and Azure Automation).

The 2 different runbooks (and the additional integration module) are 100% based on what SharePoint are you going to use. There is also a 3rd possible combination: Using SMA to populate SharePoint Online list. In this scenario, the steps are the same as what I described in this post. I have also tested in my lab. it is working as expected.

Additionally, I am also working with my fellow System Center MVP Dan Kregor to make this MP Catalog publicly available for everyone on Sparq Consulting’s public SharePoint Online site. We will make a separate announcement once it is ready. – So even if you can’t setup one up on-prem or on the cloud, we’ve got you covered <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" src="http://blog.tyang.org/wp-content/uploads/2014/12/wlEmoticon-smile1.png" alt="Smile" />.
<h3>Credit</h3>
Thanks for all the System Center MVPs who have provided feedback and input into this solution. <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" src="http://blog.tyang.org/wp-content/uploads/2014/12/wlEmoticon-smile1.png" alt="Smile" />