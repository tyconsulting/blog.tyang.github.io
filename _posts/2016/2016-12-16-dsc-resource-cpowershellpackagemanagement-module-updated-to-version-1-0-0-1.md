---
id: 5804
title: DSC Resource cPowerShellPackageManagement Module Updated to Version 1.0.0.1
date: 2016-12-16T15:45:33+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=5804
permalink: /2016/12/16/dsc-resource-cpowershellpackagemanagement-module-updated-to-version-1-0-0-1/
categories:
  - PowerShell
tags:
  - Powershell
---
Back in September this year, I published a PowerShell DSC resource called cPowerSHellPackageManagement. This DSC resource allows you to manage PowerShell repositories and modules on any Windows machines running PowerShell version 5 and later. you can read more about this module from my previous post here: <a title="http://blog.tyang.org/2016/09/15/powershell-dsc-resource-for-managing-repositories-and-modules/" href="http://blog.tyang.org/2016/09/15/powershell-dsc-resource-for-managing-repositories-and-modules/">http://blog.tyang.org/2016/09/15/powershell-dsc-resource-for-managing-repositories-and-modules/</a>

Couple of weeks ago my MVP buddy Alex Verkinderen had some issue using this DSC resource in Azure Automation DSC. After some investigation, I found there was a minor bug in the DSC resource. When you use this DSC resource to install modules, sometimes you may get an error like this:

<a href="http://blog.tyang.org/wp-content/uploads/2016/12/image-13.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/12/image_thumb-13.png" alt="image" width="711" height="72" border="0" /></a>

Basically, it is complaining that a cmdlet from the module you are trying to install already exists. In order to fix it, I had to update the DSC resource and added –AllowClobber switch to the Install-Module cmdlet.

I have published the updated version to both PowerShell Gallery (<a title="https://www.powershellgallery.com/packages/cPowerShellPackageManagement/1.0.0.1" href="https://www.powershellgallery.com/packages/cPowerShellPackageManagement/1.0.0.1">https://www.powershellgallery.com/packages/cPowerShellPackageManagement/1.0.0.1</a>) and GitHub (<a title="https://github.com/tyconsulting/PowerShellPackageManagementDSCResource/releases/tag/1.0.0.1" href="https://github.com/tyconsulting/PowerShellPackageManagementDSCResource/releases/tag/1.0.0.1">https://github.com/tyconsulting/PowerShellPackageManagementDSCResource/releases/tag/1.0.0.1</a>)

If you are using this DSC resource at the moment, make sure you check out the update.