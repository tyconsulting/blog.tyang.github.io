---
id: 351
title: 'Incorrect description in SCCM Report License 03B &#8211; Computers with a specific license status (Report ID 350)'
date: 2011-01-13T13:51:52+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=351
permalink: /2011/01/13/incorrect-description-in-sccm-report-license-03b-computers-with-a-specific-license-status-report-id-350/
categories:
  - SCCM
tags:
  - Asset Intelligence
  - SCCM
  - SCCM Reporting
---
On the SCCM Report “<strong>License 03B – Computers with a specific license status</strong>” (Report ID 350, category Asset Intelligence), the description states there are 5 possible values for license status:

<a href="http://blog.tyang.org/wp-content/uploads/2011/01/image.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/01/image_thumb.png" border="0" alt="image" width="562" height="286" /></a>

This is incorrect. SCCM collects licensing data from client’s WMI class SoftwareLicensingProduct in root\cimv2 namespace and regarding to below MSDN article, there are 7 possible values for LicenseStatus:

<a href="http://msdn.microsoft.com/en-us/library/cc534596(VS.85).aspx">http://msdn.microsoft.com/en-us/library/cc534596(VS.85).aspx</a>

<a href="http://blog.tyang.org/wp-content/uploads/2011/01/image1.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/01/image_thumb1.png" border="0" alt="image" width="456" height="413" /></a>

Below is an example of a server with license status 5 showing up in the SCCM report:

<a href="http://blog.tyang.org/wp-content/uploads/2011/01/image2.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/01/image_thumb2.png" border="0" alt="image" width="681" height="329" /></a>