---
id: 5878
title: PowerShell Script to Import and Update Modules from PowerShell Repositories to Azure Automation
date: 2017-02-12T20:46:42+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=5878
permalink: /2017/02/12/powershell-script-to-import-and-update-modules-from-powershell-repositories-to-azure-automation/
categories:
  - Azure
  - OMS
  - PowerShell
tags:
  - Azure
  - Azure Automation
  - OMS
  - Powershell
---
PowerShell Gallery has a very cool feature that allows you to import modules directly to your Azure Automation Account using the “Deploy to Azure Automation” button. However, if you want to automate the module deployment process, you most likely have to firstly download the module, zip it up and then upload to a place where the Azure Automation account can access via HTTP. This is very troublesome process.

I have written a PowerShell script that allows you to search PowerShell modules from ANY PowerShell Repositories that has been registered on your computer and deploy the module DIRECTLY to the Azure Automation account without having to download it first. You can use this script to import new modules or updating existing modules to your Automation account.

This script is designed to run interactively. You will be prompted to enter details such as module name, version, Azure credential, selecting Azure subscription and Azure Automation account etc.

<a href="http://blog.tyang.org/wp-content/uploads/2017/02/ImportModuleScript.png"><img class="size-large wp-image-5882 alignnone" src="http://blog.tyang.org/wp-content/uploads/2017/02/ImportModuleScript-1024x342.png" alt="" width="775" height="259" /></a>

The script works out the URI to the actual NuGet package for the module and import it directly to Azure Automation account. As you can see from above screenshot, Other than the PowerShell Gallery, I have also registered a private repository hosted on MyGet.org, and I am able to deploy modules directly from my private MyGet feed to my Azure Automation account.

If you want to automate this process, you can easily make a non-interactive version of this script and parameterize all required inputs.

So, here’s the script, and feedback is welcome:

https://gist.github.com/tyconsulting/f8ff2642e6be9ee770a770f2eafb06a4