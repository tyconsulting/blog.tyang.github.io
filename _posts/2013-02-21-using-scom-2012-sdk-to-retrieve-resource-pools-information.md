---
id: 1720
title: Using SCOM 2012 SDK to Retrieve Resource Pools Information
date: 2013-02-21T20:12:49+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=1720
permalink: /2013/02/21/using-scom-2012-sdk-to-retrieve-resource-pools-information/
categories:
  - PowerShell
  - SCOM
tags:
  - Powershell
  - SCOM
  - SCOM SDK
---
Today I needed to retrieve information about SCOM 2012 resource pools in a PowerShell script, I needed to do this directly via SDK, rather than using the OperationsManager PowerShell module. I couldn’t find any existing scripts via Google, so I spent some time playing with SDK and finally found it. Since it seems no one has mentioned it on the web, here’s how I did it:

Firstly, load the SDK DLL’s. I always use below function:
```powershell
function Load-SDK()
{
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.EnterpriseManagement.OperationsManager.Common") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.EnterpriseManagement.OperationsManager") | Out-Null
}

Load-SDK
```
Secondly, connect to the management group. Since I’ll be running this script on a management server, I’m connecting to the management group via the SDK service on the local machine:
```powershell
$MGConnSetting = New-Object Microsoft.EnterpriseManagement.ManagementGroupConnectionSettings($env:computername)
$MG = New-Object Microsoft.EnterpriseManagement.ManagementGroup($MGConnSetting)
```
Then, get the management group administration
```powershell
$Admin = $MG.Administration
```
Finally, get all resource pools
```powershell
$ResourcePools = $admin.GetManagementServicePools()
```
<a href="http://blog.tyang.org/wp-content/uploads/2013/02/image.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/02/image_thumb.png" width="579" height="709" border="0" /></a>

In the past, I’ve been using the GetAdministration() method from the management group object to retrieve MG administration object. This time, When I did it, the MG administration object returned from the method does not contain a method for GetManagementServicePools. I then realised the management group contains a property called Administration. the object type is the same as what’s returned from GetAdministration() method.

<a href="http://blog.tyang.org/wp-content/uploads/2013/02/image1.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/02/image_thumb1.png" width="580" height="148" border="0" /></a>

But it looks like the object returned from the "Administration" property contains more members:

<a href="http://blog.tyang.org/wp-content/uploads/2013/02/image2.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/02/image_thumb2.png" width="580" height="114" border="0" /></a>

This is just a quick observation. In the future, I’ll remember to check both places.