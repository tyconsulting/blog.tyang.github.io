---
id: 524
title: SCCM Health Check PowerShell Script Updated to Version 3.3
date: 2011-05-26T16:40:40+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=524
permalink: /2011/05/26/sccm-health-check-powershell-script-updated-to-version-3-3/
categories:
  - SCCM
tags:
  - Health Check
  - Powershell
  - SCCM
---
I have updated the <a href="http://blog.tyang.org/2011/03/30/powershell-script-sccm-health-check/">SCCM Health Check Script </a>again. The latest version is now <strong>3.3</strong>.

Below is what’s been updated since my last post for version 3.1:
<ol>
	<li>Fixed the bug where when using DOTNET sending emails to multiple recipients, it only sends to the first recipient from the list.</li>
	<li>It now zip the txt attachment to zip file before sending it. this is to improve the performance and avoid sending large attachments.</li>
	<li>Added functionality to check all current active package distribution</li>
	<li>Able to create exemptions for DNS suffix check. This can be configured in the XML. (this is required at work as there a HOST record is created for central site server in another forest because there’s no forwarders setup between 2 forests.)</li>
	<li>Improved DNS checks</li>
	<li>Fixed the bug when SQL DB is not running under default instance. The script now reads SQL DB location from primary site server's registry.</li>
</ol>
The script package now contains an additional file <a href="http://sharpdevelop.net/OpenSource/SharpZipLib/">ICSharpCode.SharpZipLib.dll</a> This is an open source project from sharpdevelop.net. This file is used to zip txt attachment.

The script now contains the following files:

<a href="http://blog.tyang.org/wp-content/uploads/2011/05/image5.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/05/image_thumb5.png" border="0" alt="image" width="407" height="269" /></a>

I’ve also been told the DNS check does not work well when SQL DB is on a cluster. I don’t have access to a SQL cluster where I can diagnose the problem. So please just be aware.

The script can be downloaded <a href="http://blog.tyang.org/wp-content/uploads/2011/05/SCCM-Health-Check-v3.3.zip"><strong>here</strong></a>. Please remember to customise the “Health-Check.XML” file before running it.