---
id: 5171
title: A Major Update for the SharePointSDK PS Module
date: 2016-02-19T12:42:42+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=5171
permalink: /2016/02/19/a-major-update-for-the-sharepointsdk-ps-module/
categories:
  - Azure
  - OMS
  - PowerShell
  - SMA
tags:
  - Azure Automation
  - OMS
  - PowerShell
  - SharePoint
  - SMA
---
<h3><a href="http://blog.tyang.org/wp-content/uploads/2016/02/Sharepoint-2013-Logo.png"><img style="background-image: none; float: left; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="Sharepoint-2013-Logo" src="http://blog.tyang.org/wp-content/uploads/2016/02/Sharepoint-2013-Logo_thumb.png" alt="Sharepoint-2013-Logo" width="178" height="178" align="left" border="0" /></a>Introduction</h3>
This blog has been a bit quiet over the last few weeks. This is because I have been really really busy. I have spent a lot of time working on an updated version of the SharePointSDK PS module. Just in case you have not played with this module, here’s some background info:

Just over a year ago, I posted a PowerShell / SMA / Azure Automation module on <a href="http://blog.tyang.org/2014/12/23/sma-integration-module-sharepoint-list-operations/">this blog</a> called SharePointSDK. Few months ago, I have also published this module on <a href="https://github.com/tyconsulting/SharePointSDK_PowerShellModule">Github</a> and <a href="https://www.powershellgallery.com/packages/SharePointSDK">PowerShell Gallery</a>. This module was designed to help automate operations around SharePoint lists (i.e. CRUD operations for SharePoint list items). Coupling SharePoint (both On-prem version or SharePoint Online) with Azure Automation (or even SMA) is becoming more and more common in the community when designing automation solutions. This module provides ways for your automation runbooks to interact with SharePoint list items.

However, I believe the original 1.0 release was really basic, and there are still a lot I’d like to cover in this module. Now I’m pleased to announce the new major release (version 2.0.1) is now available on both Github and PowerShell Gallery.
<h3>What’s New?</h3>
I’ve included the following updates in version 2.0.1:
<ul>
	<li><strong>26 additional functions!</strong></li>
	<li>Updated the <a href="https://www.microsoft.com/en-au/download/details.aspx?id=35585">SharePoint CSOM (Client Component SDK)</a> DLLs to the latest version in the module.</li>
	<li>Created a separate help file for the module. Get-Help is now fully working</li>
	<li>Various bug fixes</li>
</ul>
The table below lists all the functions that are shipped in the current release (version 2.0.1):
<table style="color: #000000;" border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td valign="bottom" width="275"><b>Function</b></td>
<td valign="bottom" width="355"><b>Description</b></td>
<td valign="bottom" width="136"><b>Released on Version</b></td>
</tr>
<tr>
<td valign="bottom" width="275">Import-SPClientSDK</td>
<td valign="bottom" width="355">Load SharePoint Client SDK DLLs</td>
<td valign="bottom" width="136">1.0</td>
</tr>
<tr>
<td valign="bottom" width="275">New-SPCredential</td>
<td valign="bottom" width="355">Create a SharePoint credential that can be used authenticating to a SharePoint (online or On-Premise) site.</td>
<td valign="bottom" width="136">1.0</td>
</tr>
<tr>
<td valign="bottom" width="275">Get-SPServerVersion</td>
<td valign="bottom" width="355">Get SharePoint server version.</td>
<td valign="bottom" width="136">1.0</td>
</tr>
<tr>
<td valign="bottom" width="275">Get-SPListFields</td>
<td valign="bottom" width="355">Get all fields from a list on a SharePoint site.</td>
<td valign="bottom" width="136">1.0</td>
</tr>
<tr>
<td valign="bottom" width="275">Add-SPListItem</td>
<td valign="bottom" width="355">Add a list item to the SharePoint site.</td>
<td valign="bottom" width="136">1.0</td>
</tr>
<tr>
<td valign="bottom" width="275">Get-SPListItem</td>
<td valign="bottom" width="355">Get all items from a list on a SharePoint site or a specific item by specifying the List Item ID.</td>
<td valign="bottom" width="136">1.0</td>
</tr>
<tr>
<td valign="bottom" width="275">Remove-SPListItem</td>
<td valign="bottom" width="355">Delete a list item to the SharePoint site.</td>
<td valign="bottom" width="136">1.0</td>
</tr>
<tr>
<td valign="bottom" width="275">Update-SPListItem</td>
<td valign="bottom" width="355">Update a list item to the SharePoint site.</td>
<td valign="bottom" width="136">1.0</td>
</tr>
<tr>
<td valign="bottom" width="275">Get-SPListItemAttachments</td>
<td valign="bottom" width="355">Download all attachments from a SharePoint list item.</td>
<td valign="bottom" width="136">1.0</td>
</tr>
<tr>
<td valign="bottom" width="275">Add-SPListItemAttachment</td>
<td valign="bottom" width="355">Upload a file as a SharePoint list item attachment.</td>
<td valign="bottom" width="136">1.0</td>
</tr>
<tr>
<td valign="bottom" width="275">Remove-SPListItemAttachment</td>
<td valign="bottom" width="355">Remove a SharePoint list item attachment.</td>
<td valign="bottom" width="136">1.0</td>
</tr>
<tr>
<td valign="bottom" width="275"><span style="background-color: #ffff00;">New-SPList</span></td>
<td valign="bottom" width="355"><span style="background-color: #ffff00;">Create a new list on the SharePoint site.</span></td>
<td valign="bottom" width="136"><span style="background-color: #ffff00;">2.1</span></td>
</tr>
<tr>
<td valign="bottom" width="275"><span style="background-color: #ffff00;">Remove-SPList</span></td>
<td valign="bottom" width="355"><span style="background-color: #ffff00;">Remove a list from the SharePoint site.</span></td>
<td valign="bottom" width="136"><span style="background-color: #ffff00;">2.1</span></td>
</tr>
<tr>
<td valign="bottom" width="275"><span style="background-color: #ffff00;">Get-SPList</span></td>
<td valign="bottom" width="355"><span style="background-color: #ffff00;">Get a list from the SharePoint site.</span></td>
<td valign="bottom" width="136"><span style="background-color: #ffff00;">2.1</span></td>
</tr>
<tr>
<td valign="bottom" width="275"><span style="background-color: #ffff00;">New-SPListLookupField</span></td>
<td valign="bottom" width="355"><span style="background-color: #ffff00;">Create a new lookup Field for a SharePoint list.</span></td>
<td valign="bottom" width="136"><span style="background-color: #ffff00;">2.1</span></td>
</tr>
<tr>
<td valign="bottom" width="275"><span style="background-color: #ffff00;">New-SPListCheckboxField</span></td>
<td valign="bottom" width="355"><span style="background-color: #ffff00;">Create a new checkbox Field for a SharePoint list.</span></td>
<td valign="bottom" width="136"><span style="background-color: #ffff00;">2.1</span></td>
</tr>
<tr>
<td valign="bottom" width="275"><span style="background-color: #ffff00;">New-SPListSingleLineTextField</span></td>
<td valign="bottom" width="355"><span style="background-color: #ffff00;">Create a new single line text Field for a SharePoint list.</span></td>
<td valign="bottom" width="136"><span style="background-color: #ffff00;">2.1</span></td>
</tr>
<tr>
<td valign="bottom" width="275"><span style="background-color: #ffff00;">New-SPListMultiLineTextField</span></td>
<td valign="bottom" width="355"><span style="background-color: #ffff00;">Create a new Multi-line text Field for a SharePoint list.</span></td>
<td valign="bottom" width="136"><span style="background-color: #ffff00;">2.1</span></td>
</tr>
<tr>
<td valign="bottom" width="275"><span style="background-color: #ffff00;">New-SPListNumberField</span></td>
<td valign="bottom" width="355"><span style="background-color: #ffff00;">Create a new number Field for a SharePoint list.</span></td>
<td valign="bottom" width="136"><span style="background-color: #ffff00;">2.1</span></td>
</tr>
<tr>
<td valign="bottom" width="275"><span style="background-color: #ffff00;">New-SPListChoiceField</span></td>
<td valign="bottom" width="355"><span style="background-color: #ffff00;">Create a new choice Field for a SharePoint list.</span></td>
<td valign="bottom" width="136"><span style="background-color: #ffff00;">2.1</span></td>
</tr>
<tr>
<td valign="bottom" width="275"><span style="background-color: #ffff00;">New-SPListDateTimeField</span></td>
<td valign="bottom" width="355"><span style="background-color: #ffff00;">Create a new date time Field for a SharePoint list.</span></td>
<td valign="bottom" width="136"><span style="background-color: #ffff00;">2.1</span></td>
</tr>
<tr>
<td valign="bottom" width="275"><span style="background-color: #ffff00;">New-SPListHyperLinkField</span></td>
<td valign="bottom" width="355"><span style="background-color: #ffff00;">Create a new Hyperlink or Picture Field for a SharePoint list.</span></td>
<td valign="bottom" width="136"><span style="background-color: #ffff00;">2.1</span></td>
</tr>
<tr>
<td valign="bottom" width="275"><span style="background-color: #ffff00;">New-SPListPersonField</span></td>
<td valign="bottom" width="355"><span style="background-color: #ffff00;">Create a new Person or Group Field for a SharePoint list.</span></td>
<td valign="bottom" width="136"><span style="background-color: #ffff00;">2.1</span></td>
</tr>
<tr>
<td valign="bottom" width="275"><span style="background-color: #ffff00;">Remove-SPListField</span></td>
<td valign="bottom" width="355"><span style="background-color: #ffff00;">Remove a Field from a SharePoint list.</span></td>
<td valign="bottom" width="136"><span style="background-color: #ffff00;">2.1</span></td>
</tr>
<tr>
<td valign="bottom" width="275"><span style="background-color: #ffff00;">Update-SPListField</span></td>
<td valign="bottom" width="355"><span style="background-color: #ffff00;">Update a SharePoint list field.</span></td>
<td valign="bottom" width="136"><span style="background-color: #ffff00;">2.1</span></td>
</tr>
<tr>
<td valign="bottom" width="275"><span style="background-color: #ffff00;">Set-SPListFieldVisibility</span></td>
<td valign="bottom" width="355"><span style="background-color: #ffff00;">Set the visibility of a SharePoint list field.</span></td>
<td valign="bottom" width="136"><span style="background-color: #ffff00;">2.1</span></td>
</tr>
<tr>
<td valign="bottom" width="275"><span style="background-color: #ffff00;">Get-SPGroup</span></td>
<td valign="bottom" width="355"><span style="background-color: #ffff00;">Get a single group or all groups from the SharePoint site.</span></td>
<td valign="bottom" width="136"><span style="background-color: #ffff00;">2.1</span></td>
</tr>
<tr>
<td valign="bottom" width="275"><span style="background-color: #ffff00;">New-SPGroup</span></td>
<td valign="bottom" width="355"><span style="background-color: #ffff00;">Create a new SharePoint group.</span></td>
<td valign="bottom" width="136"><span style="background-color: #ffff00;">2.1</span></td>
</tr>
<tr>
<td valign="bottom" width="275"><span style="background-color: #ffff00;">New-SPGroupMember</span></td>
<td valign="bottom" width="355"><span style="background-color: #ffff00;">Add an user to a SharePoint group.</span></td>
<td valign="bottom" width="136"><span style="background-color: #ffff00;">2.1</span></td>
</tr>
<tr>
<td valign="bottom" width="275"><span style="background-color: #ffff00;">Remove-SPGroupMember</span></td>
<td valign="bottom" width="355"><span style="background-color: #ffff00;">Remove an user from a SharePoint group.</span></td>
<td valign="bottom" width="136"><span style="background-color: #ffff00;">2.1</span></td>
</tr>
<tr>
<td valign="bottom" width="275"><span style="background-color: #ffff00;">Clear-SPSiteRecycleBin</span></td>
<td valign="bottom" width="355"><span style="background-color: #ffff00;">Empty the SharePoint site recycle bin.</span></td>
<td valign="bottom" width="136"><span style="background-color: #ffff00;">2.1</span></td>
</tr>
<tr>
<td valign="bottom" width="275"><span style="background-color: #ffff00;">Get-SPSiteTemplate</span></td>
<td valign="bottom" width="355"><span style="background-color: #ffff00;">Get avaialble Site Template(s) from the SharePoint site.</span></td>
<td valign="bottom" width="136"><span style="background-color: #ffff00;">2.1</span></td>
</tr>
<tr>
<td valign="bottom" width="275"><span style="background-color: #ffff00;">New-SPSubSite</span></td>
<td valign="bottom" width="355"><span style="background-color: #ffff00;">Create a new SharePoint sub site.</span></td>
<td valign="bottom" width="136"><span style="background-color: #ffff00;">2.1</span></td>
</tr>
<tr>
<td valign="bottom" width="275"><span style="background-color: #ffff00;">Get-SPSubSite</span></td>
<td valign="bottom" width="355"><span style="background-color: #ffff00;">Get all SharePoint sub sites from a root site.</span></td>
<td valign="bottom" width="136"><span style="background-color: #ffff00;">2.1</span></td>
</tr>
<tr>
<td valign="bottom" width="275"><span style="background-color: #ffff00;">Remove-SPSubSite</span></td>
<td valign="bottom" width="355"><span style="background-color: #ffff00;">Delete a SharePoint sub site.</span></td>
<td valign="bottom" width="136"><span style="background-color: #ffff00;">2.1</span></td>
</tr>
<tr>
<td valign="bottom" width="275"><span style="background-color: #ffff00;">Add-SPListFieldToDefaultView</span></td>
<td valign="bottom" width="355"><span style="background-color: #ffff00;">Add a SharePoint list field to the list default view.</span></td>
<td valign="bottom" width="136"><span style="background-color: #ffff00;">2.1</span></td>
</tr>
<tr>
<td valign="bottom" width="275"><span style="background-color: #ffff00;">Remove-SPListFieldFromDefaultView</span></td>
<td valign="bottom" width="355"><span style="background-color: #ffff00;">Remove a SharePoint list field to the list default view.</span></td>
<td valign="bottom" width="136"><span style="background-color: #ffff00;">2.1</span></td>
</tr>
</tbody>
</table>
As you can see, the previous version has shipped 11 functions, and <span style="background-color: #ffff00;">26 additional functions</span> have been added to the current release (2.0.1). With this release, other than the SharePoint list items, we are also able to manage SharePoint lists, list fields, groups, group members, and even subsites. I have included functions to create what I believe the most common list fields (as highlighted below):

<a href="http://blog.tyang.org/wp-content/uploads/2016/02/image.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/02/image_thumb.png" alt="image" width="373" height="324" border="0" /></a>
<h3>Future Plans</h3>
At this stage, there are still few things I’d like to cover in this module but I simply do not have time. Since I think I have reached another milestone at this stage, I have decided to release this version now and roll other ideas into the future release.

In the second week of March, I will be presenting at SCU APAC (<a href="systemcenteruniverse.asia/malaysia/">Kuala Lumpur, Malaysia</a>) and Australia (<a href="systemcenteruniverse.asia/australia/">Melbourne</a>).  I am presenting 2 identical sessions at both locations:
<ul>
	<li>Be a hero and save the day with OMS and Power BI (Co-present with CDM MVP <a href="https://twitter.com/AlexVerkinderen">Alex Verkinderen</a>)</li>
	<li>Automation for IT Ops with OMS and Azure Automation (Co-present with CDM MVP <a href="https://twitter.com/pzerger">Pete Zerger</a>)</li>
</ul>
As part of the demos I have prepared for the Azure Automation session with Pete, I will cover how I’m using this module as part of my automation solutions.

After SCU, I am planning to write another blog post for my <a href="http://blog.tyang.org/tag/automating-opsmgr/">Automating OpsMgr series</a> which will cover one of the our SCU demos (I know, it has been a long time since my last post for that series). I will also cover this module in more details in this upcoming blog post.
<h3>Download the Module</h3>
So for now, if you’d like to give this module a try, you can find it from both <a href="https://github.com/tyconsulting/SharePointSDK_PowerShellModule/releases/tag/2.0.1">GitHub</a> and <a href="https://www.powershellgallery.com/packages/SharePointSDK/2.0.1">PowerShell Gallery</a>. All functions are fully documented in the help file. <strong>You can access the help document as well as code examples using Get-Help with –Full switch</strong>.

Lastly, if you have any feedback, or suggestions for future releases, please feel free to drop me an email.

This is all I have to share for today, until next time, happy automating <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" src="http://blog.tyang.org/wp-content/uploads/2016/02/wlEmoticon-smile.png" alt="Smile" />.