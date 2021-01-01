---
id: 449
title: 'Updated: SCCM Health Check PowerShell Script'
date: 2011-04-21T20:55:17+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=449
permalink: /2011/04/21/updated-sccm-health-check-powershell-script/
categories:
  - PowerShell
  - SCCM
tags:
  - Health Check
  - Powershell
  - SCCM
---
<div>I have updated the SCCM Health Check Script that I have originally posted <a href="http://blog.tyang.org/2011/03/30/powershell-script-sccm-health-check/">here</a>.</div>
<div>
<div><a href="http://blog.tyang.org/wp-content/uploads/2011/04/SCCM-Health-Check-v3.1.zip">Download Version 3.1 Here</a>.</div>
<div>
<div><strong>Changes:</strong></div>
<ul><strong>1.</strong> The script can now utilise Powershell Remoting to check inboxes sizes. It requires PS-Remoting to be enabled on all SCCM Site Servers. This dramatically reduced the execution time of the script in a multi-tier environment. In a production environment that I support, it reduced the execution time from 1.5 – 2 hours to around 35 minutes!  You can configure which method to use via XML file. To enable, set &lt;PSRemoting&gt;&lt;Value&gt; to Enabled. Or Disabled if you want to use the old Diruse.exe method.</ul>
</div>
<div><strong>2.</strong> Used another method instead of System.Net.DNS to perform DNS check (<a href="http://blog.tyang.org/2011/04/15/problem-with-dns-name-resolution-when-using-system-net-dns-class/">http://blog.tyang.org/2011/04/15/problem-with-dns-name-resolution-when-using-system-net-dns-class/</a>) as System.Net.DNS does not provide accurate DNS lookup result.</div>
<div><strong>3.</strong> Checks if DNS Host record exists in multiple domains (Domain suffixes are entered in XML file under &lt;Configuration&gt;&lt;DNSCheck&gt;&lt;Suffix&gt;).</div>
<div><a href="http://blog.tyang.org/wp-content/uploads/2011/04/image.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/04/image_thumb.png" border="0" alt="image" width="545" height="67" /></a></div>
<div>– This might not be a requirement in your environment but I had to perform this check in the production environment that I support. If this is not required, Just leave it blank. The script will skip DNS Suffix check if &lt;suffix&gt; is left blank.</div>
<div><a href="http://blog.tyang.org/wp-content/uploads/2011/04/image1.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/04/image_thumb1.png" border="0" alt="image" width="545" height="47" /></a></div>
<div><strong>4.</strong> DNS check can be pretty time consuming because it connects to each site system’s WMI to check FQDN registered on the machine and it may not be a requirement in your environment. So I made an option to turn it off in the XML file (Under &lt;Configuration&gt;&lt;DNSCheck&gt;&lt;Value&gt;). To enable or disable it, set it to “Enabled” or Disabled” respectively.</div>
<div><strong>5.</strong> Checks if there are multiple IPs registered in DNS (again, this is a requirement for me at work).</div>
<div><strong>6.</strong> As requested by my friend <a href="http://blog.danovich.com.au/">Mr. Danovich</a>, I’ve added an option to disable SQL checks (SQL Server logs, SQL Agent logs and SQL related warning and error logs in Windows Application event log). This is configured via &lt;Configuration&gt;&lt;SQLLogsCheck&gt;&lt;Value&gt; in the xml file.</div>
<div><strong>7.</strong> Fixed a bug where if using .NET (System.Net.Mail) to send emails, the attachment is locked even after the script has ended. PowerShell console needs to be closed to remove the file handler.(This bug does not have any impact when you are using Windows Scheduler to run it because powershell.exe is terminated when the script is finished).</div>
<div><strong>8.</strong> Fixed a bug where .NET framwork is not automatically loaded into PowerShell when PowerShell starts. The script now checks and load the assembly at the start of the script. It will terminate if fail to load .NET framework. So please make sure it is installed (enabled in Windows 2008).</div>
</div>