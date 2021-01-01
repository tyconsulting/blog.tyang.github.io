---
id: 3611
title: A SMA Integration Module For SharePoint List Operations
date: 2014-12-23T14:38:49+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=3611
permalink: /2014/12/23/sma-integration-module-sharepoint-list-operations/
categories:
  - PowerShell
  - SMA
tags:
  - Powershell
  - SharePoint
  - SMA
---
<h3>Background</h3>
Many Microsoft System Center Orchestrator and Service Management Automation (SMA) users may agree with me, that these two automation platform does not have feature rich end user portals natively. Although System Center Service Manager can be used as a user portal for triggering SCORCH/SMA runbooks, Microsoft SharePoint is also a very good candidate for this purpose.

Integrating SharePoint with Orchestrator and SMA is not something new, many people have done this already. i.e.

<a href="http://channel9.msdn.com/Blogs/System-Center-Universe-America-2014/Master-Class-Orchestrating-Daily-Tasks-Like-a-Pro">System Center Universe America 2014 – Orchestrating Daily Tasks Like a Pro (by Pete Zerger and Anders Bengtsson)</a>

<a href="http://blogs.technet.com/b/systemcenter/archive/2014/01/14/service-management-automation-and-sharepoint-mvp.aspx">Service Management Automation and SharePoint (by Christian Booth and Ryan Andorfer)</a>

In my opinion, SharePoint (especially SharePoint lists) provides a quick and easy way to setup a web based end user portal for orchestration runbooks. I have also blogged my experiences in the past:

<a href="http://blog.tyang.org/2014/11/20/experience-manipulating-mdt-database-using-sma-scorch-sharepoint/">My Experience Manipulating MDT Database Using SMA, SCORCH and SharePoint</a>

<a href="http://blog.tyang.org/2014/08/30/sma-runbook-update-sharepoint-2013-list-item/">SMA Runbook: Update A SharePoint 2013 List Item</a>

To me, not only I am using SharePoint 2013 in my lab; SharePoint Online from my Office 365 subscription, I also have no choice but using SharePoint 2010 in real life.

In my opinion, it is complicated to write SMA runbooks to interact with SharePoint (Using SharePoint web based APIs), not to mention the different versions of SharePoint also dictates how the runbook should be written. It is easier to use Orchestrator as a middle man in between SMA and SharePoint so we can use Orchestrator’s SharePoint integration pack.

Earlier this month, I was developing solutions to use SMA and Azure Automation to create OpsMgr Management Packs catalog on SharePoint 2013 / SharePoint Online sites. I have blogged the 2 solutions here:

<a href="http://blog.tyang.org/2014/12/09/using-sma-building-microsoft-opsmgr-management-pack-catalog-sharepoint-2013/">On-Premise Solution (SMA + SharePoint 2013)</a>

<a href="http://blog.tyang.org/2014/12/10/using-azure-automation-build-microsoft-opsmgr-mp-catalog-sharepoint-online/">Cloud Based Solution (Azure Automation + SharePoint Online)</a>

As I mentioned in the previous posts, I had to write a separate SMA module to be used in Azure Automation to interact with SharePoint Online because SharePoint Online sites require a different type of credential (SharePointOnlineCredential) that the PowerShell cmdlet Invoke-RESTMethod does not support. I called that module SharePointOnline back in the previous post and it utilises assemblies from the SharePoint Client Component SDK. I think the SharePoint people also refer to this SDK as Client-Side Object Model (CSOM)

After the MP catalogs posts were published, I have decided to spend a bit more time on the SharePoint Client Component SDK and see if it can help me simplify the activities between SMA and SharePoint. I was really happy to find out, the <a href="https://www.microsoft.com/en-us/download/details.aspx?id=35585" target="_blank">SharePoint Client Component SDK</a> works for SharePoint 2013, SharePoint Online and SharePoint 2010 (limited). So I have decided to update and extend the original module, making it a generic module for all 3 flavours of SharePoint.

After couple of weeks of coding and testing, I’m pleased to announce the new module is now ready to be released. I have renamed this module to <strong>SharePointSDK</strong> (Sorry I’m not really creative with names <img class="wlEmoticon wlEmoticon-smilewithtongueout" style="border-style: none;" src="http://blog.tyang.org/wp-content/uploads/2014/12/wlEmoticon-smilewithtongueout.png" alt="Smile with tongue out" />).

&nbsp;
<h3>SharePointSDK Module Introduction</h3>
The SharePointSDK module contains the following functions:

<a href="http://blog.tyang.org/wp-content/uploads/2014/12/image40.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/12/image_thumb40.png" alt="image" width="707" height="678" border="0" /></a>

<strong>CRUD Operations for SharePoint List items:</strong>
<table style="color: #000000;" border="0" width="400" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td valign="top" width="133"><strong>Function</strong></td>
<td valign="top" width="133"><strong>Description</strong></td>
<td valign="top" width="133"><strong>Compatible SharePoint Version</strong></td>
</tr>
<tr>
<td valign="top" width="133">Add-SPListItem</td>
<td valign="top" width="133">Add an item to a SharePoint list</td>
<td valign="top" width="133">2010, 2013 and SP Online</td>
</tr>
<tr>
<td valign="top" width="133">Get-SPListFields</td>
<td valign="top" width="133">Get all fields of a SharePoint list</td>
<td valign="top" width="133">2010, 2013 and SP Online</td>
</tr>
<tr>
<td valign="top" width="133">Get-SPListItem</td>
<td valign="top" width="133">Get all list items of a SharePoint list or a specific item by specifying the List Item ID</td>
<td valign="top" width="133">2010, 2013 and SP Online</td>
</tr>
<tr>
<td valign="top" width="133">Remove-SPListItem</td>
<td valign="top" width="133">Delete an item from a SharePoint list</td>
<td valign="top" width="133">2010, 2013 and SP Online</td>
</tr>
<tr>
<td valign="top" width="133">Update-SPListItem</td>
<td valign="top" width="133">Update one or more field values of a SharePoint list item</td>
<td valign="top" width="133">2010, 2013 and SP Online</td>
</tr>
</tbody>
</table>
The functions listed above are the core functionalities this module provides. it provides simplified ways to manipulate SharePoint list items (Create, Read, Update, Delete).

<strong>Miscellaneous Functions</strong>
<table style="color: #000000;" border="0" width="400" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td valign="top" width="133"><strong>Function</strong></td>
<td valign="top" width="133"><strong>Description</strong></td>
<td valign="top" width="133"><strong>Compatible SharePoint Version</strong></td>
</tr>
<tr>
<td valign="top" width="133">Import-SPClientSDK</td>
<td valign="top" width="133">Load SharePoint Client Component SDK DLLs</td>
<td valign="top" width="133">2010, 2013 and SP Online</td>
</tr>
<tr>
<td valign="top" width="133">New-SPCredential</td>
<td valign="top" width="133">Based on the type of SharePoint site (On-Prem vs SP Online), create an appropriate credential object to authenticate to the Sharepoint site.</td>
<td valign="top" width="133">2010, 2013 and SP Online</td>
</tr>
<tr>
<td valign="top" width="133">Get-SPServerVersion</td>
<td valign="top" width="133">Get SharePoint server version</td>
<td valign="top" width="133">2010, 2013 and SP Online</td>
</tr>
</tbody>
</table>
These functions are called by other functions in the modules. It is unlikely that runbook authors will need to use them directly.

<strong>SharePoint List Attachments Operations</strong>
<table style="color: #000000;" border="0" width="400" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td valign="top" width="133"><strong>Function</strong></td>
<td valign="top" width="133"><strong>Description</strong></td>
<td valign="top" width="133"><strong>Compatible SharePoint Version</strong></td>
</tr>
<tr>
<td valign="top" width="133">Add-SPListItemAttachment</td>
<td valign="top" width="133">Add an attachment to a SharePoint list item</td>
<td valign="top" width="133">2013 and SP Online</td>
</tr>
<tr>
<td valign="top" width="133">Get-SPListItemAttachments</td>
<td valign="top" width="133">Download all attached files from a SharePoint list item</td>
<td valign="top" width="133">2013 and SP Online</td>
</tr>
<tr>
<td valign="top" width="133">Remove-SPListItemAttachment</td>
<td valign="top" width="133">Delete an attached file (based on file name) from a SharePoint list item</td>
<td valign="top" width="133">2013 and SP Online</td>
</tr>
</tbody>
</table>
As the names suggest, these functions can be used to manage attachments for SharePoint list items.

I’d like to point out  that the <strong>Add-SPListItemAttachment</strong> function not only support uploading an existing file to the SharePoint list item. it can also be used to create an attachment file directly using a byte array. This function can be used in 3 scenarios:
<ul>
	<li>Uploading an existing file from the file system</li>
	<li>Directly creating a text based file with some contents as a list item attachment.</li>
	<li>Read the content of an existing binary (or text)  file, save it as a attachment with a different name</li>
</ul>
&nbsp;
<h3>Configuration Requirements</h3>
<strong>Download and Prepare the module</strong>

The module zip file should consist the following 5 files:

<a href="http://blog.tyang.org/wp-content/uploads/2014/12/image41.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/12/image_thumb41.png" alt="image" width="574" height="291" border="0" /></a>
<ul>
	<li><strong>Microsoft.SharePoint.Client.dll</strong> – One of required DLLs from the SDK</li>
	<li><strong>Microsoft.SharePoint.Client.Runtime.dll</strong> – One of required DLLs from the SDK</li>
	<li><strong>SharePointSDK.psd1</strong> – Module Manifest file</li>
	<li><strong>SharePointSDK.psm1</strong> – PowerShell module file</li>
	<li><strong>SharePointSDK-Automation.json</strong> – SMA Integration Module Meta File (where the connection asset is defined).</li>
</ul>
<strong><a href="http://blog.tyang.org/wp-content/uploads/2014/12/SharePointSDK.zip">Download SharePointSDK Module</a></strong>
<h4><span style="color: #ff0000;">Note:</span></h4>
The zip file you’ve downloaded from the link above <strong><em>DOES NOT</em></strong> contain the 2 DLL files. I am not sure if Microsoft is OK with me distributing their software / intellectual properties. So, just to cover myself, you will need to download the SDK (64-bit version) from Microsoft directly (<a href="https://www.microsoft.com/en-us/download/details.aspx?id=35585">https://www.microsoft.com/en-us/download/details.aspx?id=35585</a>), install it on a 64-bit computer, and copy above mentioned 2 DLLs into the SharePointOnline module folder.

Once the SDK is installed, you can find these 2 files in <strong>“C:\Program Files\Common Files\microsoft shared\Web Server Extensions\15\ISAPI\”</strong> folder.

Once the DLLs are placed into the folder, zip the SharePointSDK folder to SharePointSDK.zip file again, and the integration module is ready.

<a href="http://blog.tyang.org/wp-content/uploads/2014/12/image81.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/12/image8_thumb.png" alt="image" width="552" height="221" border="0" /></a>

<strong>Import Module</strong>

Once the DLLs are zipped into the module zip file, import the module into SMA by using the Import Module button under Assets tab

<a href="http://blog.tyang.org/wp-content/uploads/2014/12/image111.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/12/image11_thumb.png" alt="image" width="675" height="406" border="0" /></a>

<strong>Create a Connection object to the SharePoint site</strong>

After the module has been successfully, a connection to SharePoint Site must be created. The Connection type is “SharePointSDK”

<a href="http://blog.tyang.org/wp-content/uploads/2014/12/image42.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/12/image_thumb42.png" alt="image" width="526" height="332" border="0" /></a>

The following fields must be filled out:
<ul>
	<li><strong>Name: </strong>Name of the connection.</li>
	<li><strong>SharePointSiteURL:</strong> URL to your sharepoint site</li>
	<li><strong>UserName</strong> : a User who should be part of the site members role (members group have contribute access).
<ul>
	<li>If the site is a SharePoint Onine site, this username <strong>MUST</strong> be in the email address format. (i.e. <a href="mailto:yourname@yourcompany.com">yourname@yourcompany.com</a>). I believe this account must be an account created in the Office 365 subscription. I have tried using an outlook.com account (added as a SharePoint site member), it didn’t work.</li>
	<li>When connecting to a On-Prem SharePoint site, you can use the Domain\UserName format (As shown in the screenshot below)</li>
</ul>
</li>
	<li><strong>Password:</strong> Password for the username you’ve specified.</li>
	<li><strong>IsSharePointOnlineSite:</strong> Boolean field (TRUE or FALSE), specify if it is a SharePoint Online site.</li>
</ul>
i.e. the connection to a SharePoint site in my lab:

<a href="http://blog.tyang.org/wp-content/uploads/2014/12/image43.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/12/image_thumb43.png" alt="image" width="534" height="804" border="0" /></a>
<h3>Sample Runbooks</h3>
In order to better demonstrate this module, I have also created 10 sample runbooks:

<a href="http://blog.tyang.org/wp-content/uploads/2014/12/image44.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/12/image_thumb44.png" alt="image" width="704" height="290" border="0" /></a>

<strong><a href="http://blog.tyang.org/wp-content/uploads/2014/12/Sample-Runbooks.zip">Download Sample runbooks</a></strong>

I’ll now go through each sample runbook.

<strong>Runbook: Sample-SPNewUserRequestList</strong>

This sample runbook creates a brand new dummy new users requests list on your SharePoint site. The list created by this runbook will then be used by other sample runbooks (for demonstration purposes).

This runbook is expecting 2 input parameters:
<ul>
	<li>ListName: The Display Name that you’d like to name the new users requests list (i.e. New Users OnBoarding Requests).</li>
	<li>SPConnection: The name of the SharePointSDK connection that you’ve created previously (i.e. Based on the connection I’ve created in my lab as shown previously, it is “RequestsSPSite”</li>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2014/12/image45.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/12/image_thumb45.png" alt="image" width="454" height="302" border="0" /></a>

This runbook creates a list with the following fields:

<a href="http://blog.tyang.org/wp-content/uploads/2014/12/image46.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/12/image_thumb46.png" alt="image" width="561" height="192" border="0" /></a>

<strong>Runbook: Sample-SPGetListFields</strong>

This runbook demonstrates how to retrieve all the fields of a particular list.

<a href="http://blog.tyang.org/wp-content/uploads/2014/12/image47.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/12/image_thumb47.png" alt="image" width="358" height="471" border="0" /></a>

<strong>Runbook: Sample-SPAddListItem</strong>

This runbook adds an item to the New Users Requests list the previous runbook created. It also demonstrates how to create a text file attachment directly to the list item (without having the need for an existing file on the file system).

It is expecting the following inputs:
<ul>
	<li>Title (New users title, i.e. Mr. Dr. Ms, etc)</li>
	<li>FirstName (New user’s first name)</li>
	<li>LastName (New user’s last name)</li>
	<li>Gender (New user’s Gender: Male / Female)</li>
	<li>UserName (New user’s user vname)</li>
	<li>AttachmentFileName (file name of the text based attachment)</li>
	<li>TextAttachmentContent (content of the text file attachment)</li>
	<li>NewUserListName (display name of the new users requests list. i.e. New Users OnBoarding Requests)</li>
	<li>SPConnection (The name of the SharePointSDK connection that you’ve created previously (i.e. Based on the connection I’ve created in my lab as shown previously, it is “RequestsSPSite”)</li>
</ul>
i.e.

<a href="http://blog.tyang.org/wp-content/uploads/2014/12/image48.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/12/image_thumb48.png" alt="image" width="537" height="818" border="0" /></a>

The list item is created on SharePoint:

<a href="http://blog.tyang.org/wp-content/uploads/2014/12/SNAGHTML1d5a6df8.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML1d5a6df8" src="http://blog.tyang.org/wp-content/uploads/2014/12/SNAGHTML1d5a6df8_thumb.png" alt="SNAGHTML1d5a6df8" width="460" height="306" border="0" /></a>

Attachment content:

<a href="http://blog.tyang.org/wp-content/uploads/2014/12/image49.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/12/image_thumb49.png" alt="image" width="572" height="132" border="0" /></a>

<strong>Runbook: Sample-SPUpdateListItem</strong>

This runbook can be used to update fields of an existing list item on the New Users Requests list.

<strong>Runbook: Sample-SPGetAllListItems</strong>

This runbook can be used to retrieve ALL items from a list. Each list item are presented as a hash table.

<a href="http://blog.tyang.org/wp-content/uploads/2014/12/image50.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/12/image_thumb50.png" alt="image" width="530" height="532" border="0" /></a>

<strong>Runbook: Sample-SPGetListItem</strong>

This runbook can be used to retrieve a single item from a list.

<a href="http://blog.tyang.org/wp-content/uploads/2014/12/image51.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/12/image_thumb51.png" alt="image" width="528" height="519" border="0" /></a>

<strong>Runbook: Sample-SPDeleteListItem</strong>

This runbook deletes a single list item by specifying the List Item ID.

<strong>Runbook: Sample-SPAddListItemAttachment</strong>

This runbook demonstrates 2 scenarios:
<ul>
	<li>Directly attaching a file to a list item</li>
	<li>attach and rename a file to a list item</li>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2014/12/image52.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/12/image_thumb52.png" alt="image" width="374" height="285" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2014/12/image53.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/12/image_thumb53.png" alt="image" width="404" height="264" border="0" /></a>

<strong>Runbook: Sample-SPDeleteListItemAttachments</strong>

This runbook demonstrates how to delete an attachment from a list item (by specifying the file name).

<strong>Runbook: Sample-SPDownloadListItemAttachments</strong>

This runbook demonstrates how to download all files attached to a list item:

<a href="http://blog.tyang.org/wp-content/uploads/2014/12/image54.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/12/image_thumb54.png" alt="image" width="429" height="461" border="0" /></a>

Files downloaded to the destination folder:

<a href="http://blog.tyang.org/wp-content/uploads/2014/12/image55.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/12/image_thumb55.png" alt="image" width="529" height="179" border="0" /></a>
<h3>Benefit of Using the SharePointSDK Module</h3>
<strong>Using as a Regular PowerShell Module</strong>

As we all know, SMA modules are simply PowerShell modules (sometimes with optional SMA module meta file .json for creating connections). Although this module is primarily written for SMA, it can also be used in other environments such as a regular PowerShell module or in Azure Automation. When using it as a normal PowerShell module, instead of passing the SMA connection name into the functions inside the module, you may provide each individual value separately (Username, password, SharePoint Site URL, IsSharePointOnlineSite).

<strong>Simplified scripts to interact with SharePoint</strong>

When using this module, most of the operations around the list item only takes very few lines of code.

i.e. Retrieving a list item:

Using PowerShell:
<pre language="PowerShell">$ListItem = Get-SPListItem -SiteUrl "https://yourcompany.sharepoint.com" -UserName "you@yourcompany.com" -Password "password1234" -IsSPO $true -ListName "Test List" -ListItemID 1
</pre>
Using PowerShell Workflow (in SMA):
<pre language="PowerShell">$Conn = Get-AutomationConnection -Name $SPConnection
$ListItem = InlineScript
{
Import-Module SharePointSDK
$ListItem = Get-SPListItem -SPConnection $USING:Conn -ListName Test List" -ListItemID 1
$ListItem
}
</pre>
If you use SharePoint 2013’s REST API, the script will be much longer than what I’ve shown above.

<strong>Same Code for Different SharePoint Versions</strong>

The SharePoint REST API has been updated in SharePoint 2013. Therefore, if we are to use the REST API, the code for Share Point 2013 would look different than SharePoint 2010. Additionally, when throwing SharePoint Online into the mix, as I mentioned previously, it requires different type of credential for authentication, it further complicates the situation if we are to use the REST API. This makes our scripts and runbooks less generic.

By using this SharePointSDK module, I am able to use the same runbooks on SharePoint 2010, 2013 and SharePoint Online sites.
<h3>Limitations</h3>
During testing, I noticed the 3 attachments related functions in the SharePointSDK module would not work on SharePoint 2010 sites. These functions are:
<ul>
	<li>Add-SPListItemAttachment</li>
	<li>Remove-SPListItemAttachment</li>
	<li>Get-SPListItemAttachments</li>
</ul>
After a bit of research, looks like it is a known issue. I didn’t think it too much a big deal because all the core functions (CRUD operations for the list items) work with SharePoint 2010. Therefore, in these 3 functions, I’ve coded a validation step to exit if the SharePoint Server version is below version 15 (SharePoint 2013):

<a href="http://blog.tyang.org/wp-content/uploads/2014/12/image56.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/12/image_thumb56.png" alt="image" width="693" height="246" border="0" /></a>
<h3>Conclusion</h3>
If you are using SMA and SharePoint together, I strongly recommend you to download this module and the sample runbooks and give it a try. If you have a look at the sample runbooks, I’m sure you will realise how easy it is to write PowerShell code interacting with SharePoint.

In case you didn’t see the download links, you can download them here:

<strong><a href="http://blog.tyang.org/wp-content/uploads/2014/12/SharePointSDK.zip">Download SharePointSDK Module</a></strong>

<strong><a href="http://blog.tyang.org/wp-content/uploads/2014/12/Sample-Runbooks.zip">Download Sample Runbooks</a></strong>

Lastly, I’m not a SharePoint specialist. If you believe I’ve made any mistakes in my code, or there is room for improvement, I’d like to hear from you. Please feel free to drop me an email <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" src="http://blog.tyang.org/wp-content/uploads/2014/12/wlEmoticon-smile4.png" alt="Smile" />.