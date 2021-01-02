---
id: 5651
title: Pushing PowerShell Modules From PowerShell Gallery to Your MyGet Feeds Directly
date: 2016-09-20T22:59:14+10:00
author: Tao Yang
#layout: post
excerpt: ""
header:
  overlay_image: /wp-content/uploads/2016/09/PSGallery-MyGet.png
  overlay_filter: 0.5 # same as adding an opacity of 0.5 to a black background
guid: http://blog.tyang.org/?p=5651
permalink: /2016/09/20/pushing-powershell-modules-from-powershell-gallery-to-your-myget-feeds-directly/
categories:
  - PowerShell
tags:
  - PowerShell
---
Recently I have started using a private MyGet feed and my <a href="http://blog.tyang.org/2016/09/15/powershell-dsc-resource-for-managing-repositories-and-modules/">cPowerShellPackageManagement</a> DSC Resource module to manage PowerShell modules on my lab servers.

When new modules are released in PowerShell Gallery (i.e. all the Azure modules), I’d normally use Install-Module to install on test machines, then publish the tested modules to my MyGet feed and then my servers would pick up the new modules.

Although I can use public-module cmdlet to upload the module located locally on my PC to MyGet feed, it can be really time consuming when the module sizes are big (i.e. some of the Azure modules). It only took me few minutes to figure out how do I push modules directly from PowerShell Gallery (or any NuGet feeds) to my MyGet feed.

To configure it, Under the MyGet feed, go to "Package Sources", and click "Add package source…"

<a href="http://blog.tyang.org/wp-content/uploads/2016/09/SNAGHTML6b70b9f.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML6b70b9f" src="http://blog.tyang.org/wp-content/uploads/2016/09/SNAGHTML6b70b9f_thumb.png" alt="SNAGHTML6b70b9f" width="420" height="309" border="0" /></a>

Then choose NuGet feed, fill out name and source

Name: **PowerShellGallery**

Source: <a title="https://www.powershellgallery.com/api/v2/" href="https://www.powershellgallery.com/api/v2/">**https://www.powershellgallery.com/api/v2/**</a>

<a href="http://blog.tyang.org/wp-content/uploads/2016/09/image-5.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/09/image_thumb-5.png" alt="image" width="418" height="280" border="0" /></a>

Once added, I can search PowerShell Gallery and add packages directly to MyGet.

<a href="http://blog.tyang.org/wp-content/uploads/2016/09/image-6.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/09/image_thumb-6.png" alt="image" width="345" height="216" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2016/09/image-7.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/09/image_thumb-7.png" alt="image" width="433" height="432" border="0" /></a>