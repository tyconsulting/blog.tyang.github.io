---
id: 5634
title: Scripting Azure Automation Module Imports Directly from MyGet or PowerShell Gallery
date: 2016-09-18T21:23:15+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=5634
permalink: /2016/09/18/scripting-azure-automation-module-imports-directly-from-myget-or-powershell-gallery/
categories:
  - Azure
  - PowerShell
tags:
  - Azure Automation
  - PowerShell
---
There are few ways to add PowerShell modules to Azure Automation accounts:

**1. Via the Azure Portal by uploading the module zip file from local computer.**

<a href="https://blog.tyang.org/wp-content/uploads/2016/09/image-2.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/09/image_thumb-2.png" alt="image" width="277" height="229" border="0" /></a>

**2. If the module is located in PowerShell Gallery, you can push it to your Automation Account directly from PowerShell Gallery.**

<a href="https://blog.tyang.org/wp-content/uploads/2016/09/image-3.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/09/image_thumb-3.png" alt="image" width="260" height="202" border="0" /></a>

**3. Use PowerShell cmdlet <a href="https://msdn.microsoft.com/en-us/library/mt603494.aspx">New-AzureRmAutomationModule</a> from the AzureRM.Automation module.**

One of the limitation of using New-AzureRMAutomationModule cmdlet is, the module must be zipped and located somewhere online that Azure has access to. You will need to specify the location by using the –ContentLink parameter. In the past, in order to script the module deployment, even when the module is located in PowerShell Gallery, I had to save the module to a place where my Automation Account has access to (such as an Azure blob storage, or creating a release in a public Github repo).

Tonight, I was writing a script and I wanted to see if I can deploy modules to my Automation Account directly from a package repository of my choice – other than PowerShell Gallery, I also have a private <a href="https://www.myget.org">MyGet</a> feed that I use for storing my PowerShell modules.

It turned out to be really easy to do so, only took me few minutes to figure out how. I’ll use a module I wrote in the past called "SendEmail" as an example. It is published in both PowerShell Gallery, and my private MyGet feed.

## **Importing from PowerShell Gallery**

the URL for this module in PowerShell Gallery is: <a title="https://www.powershellgallery.com/packages/SendEmail/1.3" href="https://www.powershellgallery.com/packages/SendEmail/1.3">https://www.powershellgallery.com/packages/SendEmail/1.3</a>

The –ContentLink URI that we need to pass to the Add-AzureRmAutomationModule cmdlet would be:

<a href="https://www.powershellgallery.com/api/v2/package/SendEmail/1.3">https://www.powershellgallery.com/**<span style="color: #ff0000;">api/v2/</span>**package/SendEmail/1.3</a>.

As you can see, all you need to do is to add "api/v2/" in the URI. The PowerShell command would be something like this:

```powershell
New-AzureRmAutomationModule -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name 'SendEmail' -ContentLink 'https://www.powershellgallery.com/api/v2/package/SendEmail/1.3'
```

## **Importing from a private MyGet feed**

For a private MyGet feed, you can access it by embedding the API key into the URL:

<a href="https://blog.tyang.org/wp-content/uploads/2016/09/image-4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/09/image_thumb-4.png" alt="image" width="662" height="577" border="0" /></a>

The URL for my module would be: **"http://www.myget.org/F/\<Your MyGet feed name\>/auth/\<MyGet API Key\>/api/v2/package/\<Module Name\>\<Module Version\>"**

i.e. for my SendEmail module, the PowerShell command would be something like this:

```powershell
$MyGetFeedName = 'SampleMyGetFeed'
$MyGetAPIKey = '89c2d7b8-2d76-4274-a5b7-bcb1f186502c'
$PackageURI = "https://www.myget.org/F/$MyGetFeedName/auth/$MyGetAPIKey/api/v2/package/SendEmail/1.3"
New-AzureRmAutomationModule -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name 'SendEmail' -ContentLink $PackageURI
```

## **Importing from a public MyGet feed**

If the module is located in a public MyGet feed, then the API key is not required. the URI for the module would be very similar to PowerShell Gallery, you will just need to embed "**api/v2/**" in to the original URI:

**'https://www.myget.org/F/\<MyGet Public Feed Name\>api/v2/package/\<Module Name\>\<Module Version\>'**

the PowerShell script would be something like this:

```powershell
$MyGetPublicFeedName = 'SampleMyGetPublicFeed'
New-AzureRmAutomationModule -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name 'SendEmail' -ContentLink "https://www.myget.org/F/$MyGetPublicFeedName/api/v2/package/SendEmail/1.3"
```