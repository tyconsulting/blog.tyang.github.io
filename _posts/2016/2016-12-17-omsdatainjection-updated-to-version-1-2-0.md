---
id: 5809
title: OMSDataInjection Updated to Version 1.2.0
date: 2016-12-17T13:41:45+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=5809
permalink: /2016/12/17/omsdatainjection-updated-to-version-1-2-0/
categories:
  - OMS
  - PowerShell
tags:
  - OMS
  - PowerShell
---
The OMSDataInjection module was only updated to v1.1.1  less than 2 weeks ago. I had to update it again to reflect the cater for the changes in the OMS HTTP Data Collector API.

I only found out last night after been made aware people started getting errors using this module that the HTTP response code for a successful injection has changed from 202 to 200. The documentation for the API was updated few days ago (as I can see from GitHub):

<a href="https://blog.tyang.org/wp-content/uploads/2016/12/image-14.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/12/image_thumb-14.png" alt="image" width="712" height="376" border="0" /></a>

This is what’s been updated in this release:

* Updated injection result error handling to reflect the change of the OMS HTTP Data Collector API response code for successful injection.
* Changed the UTCTimeGenerated input parameter from mandatory to optional. When it is not specified, the injection time will be used for the TimeGenerated field in OMS log entry.

If you are using the OMSDataInjection module, I strongly recommend you to update to this release.

PowerShell Gallery: <a title="https://www.powershellgallery.com/packages/OMSDataInjection" href="https://www.powershellgallery.com/packages/OMSDataInjection">https://www.powershellgallery.com/packages/OMSDataInjection</a>

GitHub: <a title="https://github.com/tyconsulting/OMSDataInjection-PSModule/releases/tag/v1.2.0" href="https://github.com/tyconsulting/OMSDataInjection-PSModule/releases/tag/v1.2.0">https://github.com/tyconsulting/OMSDataInjection-PSModule/releases/tag/v1.2.0</a>