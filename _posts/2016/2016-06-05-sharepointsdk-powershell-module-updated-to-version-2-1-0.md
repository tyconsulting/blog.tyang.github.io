---
id: 5408
title: SharePointSDK PowerShell Module Updated to Version 2.1.0
date: 2016-06-05T19:33:56+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=5408
permalink: /2016/06/05/sharepointsdk-powershell-module-updated-to-version-2-1-0/
categories:
  - Power BI
tags:
  - PowerShell
  - SharePoint
---
OK, this blog has been very quiet recently. Due to some work related requirements, I had to pass few Microsoft exams. so I have spent most of my time over the last couple of months on study. Firstly, I passed the MCSE Private Cloud Re-Certification exam, then I passed the 2 Azure exams: <em>70-532 Developing Microsoft Azure Solutions</em> and <em>70-533 Implementing Microsoft Azure Infrastructure Solutions</em>. Other than studying and taking exams, I have also been working on a new version of the SharePointSDK PowerShell module during my spare time. I have finished everything on my to-do list for this release last night, and I’ve just published version 2.1.0 on PowerShell Gallery and GitHub:
<ul>
 	<li>PowerShellGallery: <a title="https://www.powershellgallery.com/packages/SharePointSDK/2.1.0" href="https://www.powershellgallery.com/packages/SharePointSDK/2.1.0">https://www.powershellgallery.com/packages/SharePointSDK/2.1.0</a></li>
 	<li>Github: <a title="https://github.com/tyconsulting/SharePointSDK_PowerShellModule" href="https://github.com/tyconsulting/SharePointSDK_PowerShellModule">https://github.com/tyconsulting/SharePointSDK_PowerShellModule</a></li>
</ul>
This new release includes the following updates:

<strong>01. Fixed the "format-default : The collection has not been initialized." error when retrieving various SharePoint objects.</strong>

i.e. When retrieving the SharePoint list in previous versions using Get-SPList function, you will get this error:

<a href="http://blog.tyang.org/wp-content/uploads/2016/06/image.png"><img style="padding-top: 0px; padding-left: 0px; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/06/image_thumb.png" alt="image" width="665" height="62" border="0" /></a>

This error is fixed in version 2.1.0. now you will get a default view defined in the module:

<a href="http://blog.tyang.org/wp-content/uploads/2016/06/image-1.png"><img style="padding-top: 0px; padding-left: 0px; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/06/image_thumb-1.png" alt="image" width="675" height="57" border="0" /></a>

<strong>02. SharePoint client SDK DLLs are now automatically loaded with the module.</strong>

I have configured the module manifest to load the SharePoint Client SDK DLLs that are included in the module folder. As the result of this change, the Import-SPClientSDK function is no longer required and has been removed from the module completely.

In the past, the Import-SPClientSDK function will firstly try to load required DLLs from the Global Assembly Cache (GAC) and will only fall back to the DLLs located in the module folder if they don’t exist in GAC. Since the Import-SPClientSDK function has been removed, this behaviour is changed in this release. Starting from this release, the module will not try to load the DLLs from GAC, but ALWAYS use the copies in the module folder.

<strong>03. New-SPListLookupField function now supports adding additional lookup columns.</strong>

When adding a lookup field in a SharePoint list, you can specify including one or more additional columns. i.e.:

<a href="http://blog.tyang.org/wp-content/uploads/2016/06/image-2.png"><img style="padding-top: 0px; padding-left: 0px; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/06/image_thumb-2.png" alt="image" width="378" height="270" border="0" /></a>

The previous versions of this module did not support adding additional columns when creating a lookup field. In this version, you are able to add additional columns using the "-AdditionalSourceFields" parameter to achieve this goal.

<strong>04. Various minor bug fixes</strong>

Other than above mentioned updates, this version also included various minor bug fixes.

<strong>Special Thanks</strong>

I’d like to thank my friend and fellow CDM MVP Jakob Gottlieb Svendsen (<a href="https://twitter.com/JakobGSvendsen">@JakobGSvendsen</a>) for his feedback. Most of the items updated in this release were results of Jakob’s feedbacks.