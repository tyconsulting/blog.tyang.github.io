---
id: 5822
title: cPowerShellPackageManagement DSC Resource Updated to Version 1.0.1.0
date: 2016-12-30T12:39:04+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=5822
permalink: /2016/12/30/cpowershellpackagemanagement-dsc-resource-updated-to-version-1-0-1-0/
categories:
  - PowerShell
tags:
  - PowerShell
  - PowerShell DSC
---
Few days ago I found a bug in the cPowerShellPackageManagement DSC resource module that was caused by the previous update v1.0.0.1.

in version 1.0.0.1, I’ve added –AllowClobber switch to the Install-Module cmdlet, which was explained in my previous post: <a title="http://blog.tyang.org/2016/12/16/dsc-resource-cpowershellpackagemanagement-module-updated-to-version-1-0-0-1/" href="http://blog.tyang.org/2016/12/16/dsc-resource-cpowershellpackagemanagement-module-updated-to-version-1-0-0-1/">http://blog.tyang.org/2016/12/16/dsc-resource-cpowershellpackagemanagement-module-updated-to-version-1-0-0-1/</a>

However, I only just noticed that despite the fact that the pre-installed version of the PowerShellGet module on Windows Server 2016 and in WMF 5.0 for Windows Server 202 R2, the install-module cmdlet is sightly different. The pre-installed version of PowerShellGet module is 1.0.0.1, and in Windows 10 and Windows Server 2106, Install-Module cmdlet has the "AllowClobber" switch:

<a href="http://blog.tyang.org/wp-content/uploads/2016/12/image-15.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/12/image_thumb-15.png" alt="image" width="597" height="379" border="0" /></a>

In Windows Server 2012, the Install-module cmdlet does not have –AllowClobber switch:

<a href="http://blog.tyang.org/wp-content/uploads/2016/12/image-16.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/12/image_thumb-16.png" alt="image" width="626" height="385" border="0" /></a>

Therefore I had to update the DSC resource to detect the if AllowClobber switch exists.

Additionally, I have made few additional stability improvements, and added dependency to the PowerShellGet module in the module manifest file.

This updated version can be found on both GitHub and PowerShell Gallery:

Github: <a title="https://github.com/tyconsulting/PowerShellPackageManagementDSCResource/releases/tag/1.0.1.0" href="https://github.com/tyconsulting/PowerShellPackageManagementDSCResource/releases/tag/1.0.1.0">https://github.com/tyconsulting/PowerShellPackageManagementDSCResource/releases/tag/1.0.1.0</a>

PowerShell Gallery: <a title="https://www.powershellgallery.com/packages/cPowerShellPackageManagement/1.0.1.0" href="https://www.powershellgallery.com/packages/cPowerShellPackageManagement/1.0.1.0">https://www.powershellgallery.com/packages/cPowerShellPackageManagement/1.0.1.0</a>