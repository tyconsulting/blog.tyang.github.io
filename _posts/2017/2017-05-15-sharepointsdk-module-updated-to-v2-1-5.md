---
id: 6002
title: SharePointSDK Module Updated to v2.1.5
date: 2017-05-15T11:36:55+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=6002
permalink: /2017/05/15/sharepointsdk-module-updated-to-v2-1-5/
categories:
  - PowerShell
  - SharePoint
tags:
  - PowerShell
  - SharePoint
---
I’ve just released SharePointSDK module version 2.1.5 with a minor bug fix within the New-SPListDateTimeField function. In the old versions, the New-SPListDateTimeField function would fail if the parameter ‘UseTodayAsDefaultValue’ is set to $false. This bug is fixed in v2.1.5.

You can find version 2.1.5 at:

* PowerShell Gallery: [https://www.powershellgallery.com/packages/SharePointSDK/2.1.5](https://www.powershellgallery.com/packages/SharePointSDK/2.1.5)
* GitHub: [https://github.com/tyconsulting/SharePointSDK_PowerShellModule/releases/tag/v2.1.5](https://github.com/tyconsulting/SharePointSDK_PowerShellModule/releases/tag/v2.1.5)