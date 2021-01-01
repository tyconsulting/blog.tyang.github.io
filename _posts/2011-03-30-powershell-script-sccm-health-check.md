---
id: 407
title: 'PowerShell Script: SCCM Health Check'
date: 2011-03-30T10:37:07+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=407
permalink: /2011/03/30/powershell-script-sccm-health-check/
image: /wp-content/uploads/2011/03/healthCheck1.jpg
categories:
  - PowerShell
  - SCCM
tags:
  - Featured
  - Health Check
  - Powershell
  - SCCM
---
<span style="color: #ff0000;"><strong>30/01/2012:</strong></span> This script has been updated to version 3.5. Details can be found <a title="SCCM Health Check Script v3.5" href="http://blog.tyang.org/2012/01/31/sccm-health-check-script-updated-version-3-5/">HERE</a>. The download link on this article has also been updated to version 3.5.

<span style="color: #ff0000;"><strong><strong>26/05/2011:</strong> </strong><em><span style="color: #000000;">Version 3.3 has been posted <a href="http://blog.tyang.org/2011/05/26/sccm-health-check-powershell-script-updated-to-version-3-3/">here</a>. The download link to the script on this post is also updated to the new version 3.3.</span></em></span>

<span style="color: #ff0000;"><strong>21/04/2011:</strong></span> <em>Please be advised that I have posted a newer version of the script <a href="http://blog.tyang.org/2011/04/21/updated-sccm-health-check-powershell-script/">here</a>. The existing script download link on this page has also been updated to point to the newer version. For the chanages in newer version, please refer to my <a href="http://blog.tyang.org/2011/04/21/updated-sccm-health-check-powershell-script/">updated post</a>.</em>

Over the last few months, I have been working on a PowerShell script to perform some health check activities for a customer’s entire SCCM environment. This is to provide a snapshot of health state of some elements of SCCM environment at a point of time since there is no SCOM in that environment to monitor SCCM at this stage.

<strong><a href="http://blog.tyang.org/wp-content/uploads/2012/01/SCCM-Health-Check-v3.5.zip">Download the script here</a></strong>

<strong>The script checks the following:</strong>
<ol>
	<li>Ping check all servers in the SCCM infrastructure
<ul>
	<li>If first ping fails, wait for number of seconds (defined in XML file) then attempts to ping few more times (Number of retries defined in XML file).</li>
	<li>if returns any successful pings, ping test is classified as success.</li>
</ul>
</li>
	<li>DNS name resolution check for all servers in SCCM infrastructure
<ol>
	<li>forward lookup check</li>
	<li>reverse lookup check</li>
	<li>compare DNS A record with the FQDN that's set on the server</li>
</ol>
</li>
	<li>All site systems in warning or critical state</li>
	<li>All site components in warning or critical state</li>
	<li>All package distribution with issues</li>
	<li>Checks all Non-PXE boot image packages in PXE DP share</li>
	<li>Checks any inboxes that contain number of files that's over the threshold (threshold is set in the XML file)</li>
	<li>Checks availability of Inbox folders on all primary site servers</li>
	<li>Checks SCCM site backups on all primary sites within the "DaysToCheck" that's set in XML file.</li>
	<li>Checks any errors in SQL server and SQL agent logs</li>
	<li>Checks Application logs on SQL servers for any SQL related errors.</li>
</ol>
<strong>What’s included in this script:</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2011/03/image.png"><img style="display: block; float: none; margin-left: auto; margin-right: auto; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/03/image_thumb.png" alt="image" width="182" height="81" border="0" /></a>
<ol>
	<li><strong>SCCM-HealthCheck.ps1: </strong>the actual PowerShell script</li>
	<li><strong>Health-Check.xml:</strong> contains all configuration settings for the script. this file needs to be modified to suit your environment before running the script.</li>
	<li><strong>DIRUSE.exe:</strong> This is from Windows 2000 Resource Kit (<a title="http://support.microsoft.com/kb/927229" href="http://support.microsoft.com/kb/927229">http://support.microsoft.com/kb/927229</a>). it is used to retrieve SCCM inboxes information. I have chosen to use this rather than the native PowerShell cmdlet Get-ChildItem because DIRUSE.EXE retrieves the information much faster against remote servers than Get-ChildItem.</li>
</ol>
<strong>Configuring the script:</strong>

The health check script reads all the settings from Health-Check.xml which is located in the same folder as the script.

You’ll need to Configure the XML according to the following:<a href="http://blog.tyang.org/wp-content/uploads/2011/03/image1.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/03/image_thumb1.png" alt="image" width="885" height="441" border="0" /></a>

Note: If you are having trouble reading the text on above image, this image can be download <strong><a title="SCCM-HealthCheck XML Readme" href="http://blog.tyang.org/wp-content/uploads/2011/03/Health-Check-xml-ReadMe.jpg">here</a></strong>

<strong>Output:</strong>
<ol>
	<li>The script has the option to email out the health check report (can be switched on and off in XML file)</li>
	<li>The email body is in HTML format that contains the overall status of each check.</li>
	<li>The detailed report is in TXT format and it is attached to the email. it is also located in the same folder as the script with the timestamp. if emailing is turned off, the detailed report can be located there.</li>
</ol>
Below is a sample HTML email body generated from my test environment:

<a href="http://blog.tyang.org/wp-content/uploads/2011/03/emailreport.jpg"><img style="display: inline; border: 0px;" title="email report" src="http://blog.tyang.org/wp-content/uploads/2011/03/emailreport_thumb.jpg" alt="email report" width="786" height="1575" border="0" /></a>

<strong>Security Requirement:</strong>
<ol>
	<li>The PowerShell execution policy on the computer that's running the script needs to be set to at RemoteSigned or Unrestricted.</li>
	<li>The account used to run this script needs to have:
<ol>
	<li>local admin rights on Central site server, Central site provider server (if not the site server itself)</li>
	<li>In the SQL servers, sysadmin rights or at least access to the master DB on all SQL servers to be able to read SQL server and agent logs.</li>
	<li>SMS admin access on all primary sites</li>
	<li>NTFS read permission to "inboxes" folders on all primary site servers.</li>
</ol>
</li>
	<li>Scheduling the script in Windows Task Scheduler:
<ol>
	<li>"Allow log on as batch job" rights is required for the user account to run scheduled jobs.</li>
	<li>if scheduling in Windows 2008 or later, please make sure "Run with highest privileges" is ticked to bypass UAC (User Account Control)</li>
</ol>
</li>
</ol>
<strong>Other Requirements:</strong>
<ol>
	<li>The operating system for SQL servers has to be Windows 2008 or later. This is because <strong>Get-WinEvent</strong> is used to read event log rather than using <strong>Get-EventLog</strong> because Get-EventLog does not support server side filtering. Therefore Get-WinEvent is used to improve performance when reading remote event logs. However, Get-WinEvent only works on Vista and later version of Windows.</li>
	<li>PowerShell Version 2 is required to run the script.</li>
</ol>
<strong>What’s Next?</strong>

I’m planning to re-write some part of the script to give us an option to utilise PowerShell Remoting wherever is suitable. This will greatly improve the performance of the script (especially when gathering inboxes information across the WAN link). When this is done, Get-ChildItem can be used and executed locally on each site servers and eliminate the needs for DIRUSE.EXE.

I’ll get this done in the next few weeks and post it here once it’s done.