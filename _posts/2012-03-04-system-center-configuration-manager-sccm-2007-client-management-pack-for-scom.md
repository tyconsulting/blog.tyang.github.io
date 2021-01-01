---
id: 1057
title: System Center Configuration Manager (SCCM) 2007 Client Management Pack for SCOM
date: 2012-03-04T20:58:44+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=1057
permalink: /2012/03/04/system-center-configuration-manager-sccm-2007-client-management-pack-for-scom/
categories:
  - SCCM
  - SCOM
tags:
  - Featured
  - SCCM
  - SCOM
---
<h1><a href="http://blog.tyang.org/wp-content/uploads/2012/03/systemcenter1.png"><img class="alignleft wp-image-1059" title="systemcenter" src="http://blog.tyang.org/wp-content/uploads/2012/03/systemcenter1.png" alt="" width="201" height="150" /></a></h1>
<strong><span style="color: #ff0000;">12/08/2012:</span></strong> This MP has been updated. Please refer to <a title="SCCM 2007 Client Management Pack Updated" href="http://blog.tyang.org/2012/08/12/sccm-2007-client-management-pack-updated/">this post</a> for more details of the update. The download link in this post has also been updated.
<h1>Background</h1>
Over the time, I have seen some issues and challenges for SCCM administrators to effectively and proactively managing SCCM clients.  I have personally seen and experienced some challenging issues. For example:
<ul>
	<li>Silent clients due to the SMS agent host service not running.</li>
	<li>SCCM Clients are reporting to the incorrect site due to the combination of overlapping boundaries and auto site assignment.</li>
	<li>SCCM Clients missing new functionalities due to Missing SCCM hotfixes (i.e. Power Management in SCCM 2007 R3)</li>
	<li>Advertisement executions failures</li>
	<li>SCCM clients unable to connect to Management Points</li>
	<li>BDP configurations inconsistent (A SCCM client is listed as a BDP on the site server but it is not actually configured as BDP)</li>
	<li>Newly installed software are not promptly updated in SCCM site database as the hardware inventory only runs weekly by default.</li>
</ul>
During last year’s Christmas period, some of my employers production servers were assigned to an incorrect SCCM site and as a result, some applications were pushed out to these servers during a change freeze period. We only founded it out after the fact and realised some of these servers were reporting to the wrong SCCM sites for months!

This has triggered me to implement a solution so we can proactively monitor the configurations and activities of SCCM 2007 clients so we are alerted before anything bad happens!

I started writing a SCOM management pack for SCCM 2007 clients. It took me few weeks to cover all the issues that my team is facing. Over the last couple of weekends, I have spent a lot of time to re-write / re-brand it and document it so I can actually post this management pack in my blog.

This management pack provides some proactive monitoring and automations for all of above mentioned issues /challenges. Does this sound interesting to you? If so, please continue reading. The documentation and the management pack download link is at the bottom of this article.

So here are some details of the management pack.
<h1><a name="_Toc318657956"></a>Introduction</h1>
System Center Configuration Manager (SCCM) 2007 Client Management Packs 2.0.0.0 provides basic monitoring of SCCM 2007 clients.

This set of management packs is intended fill the gap of the official Microsoft System Center Configuration Manager 2007 management pack and focus monitoring the SCCM clients in SCCM infrastructures. These managements pack also provides ability to implement customised monitors to monitor the configurations and baselines of SCCM clients in your organisation’s SCCM infrastructures according to your organisation’s standard. i.e.

· Monitors SCCM site assignment, make sure SCCM clients are assigned to the correct primary site in a multi-sites environment.

· Monitors SCCM client versions to make sure all required SCCM client hotfixes are applied.

· Monitors and make sure any SCCM clients that should be configured as Branch Distribution Points (BDP) are actually configured as BDP.

· Make sure SCCM Client cache size is configured according to your company’s standard.

There are 2 separate sealed management packs (.MP) in this set:

· <strong>TYANG System Center Configuration Manager 2007 Library</strong>
<ul>
	<li>Custom Data Source, Probe Action and Write Action modules</li>
	<li>Custom monitor types</li>
	<li>SCOM console actions for SCCM clients</li>
	<li>SCCM client object discovery</li>
</ul>
· <strong>TYANG System Center Configuration Manager 2007 Monitoring</strong>
<ul>
	<li>Pre-Configured monitors and rules</li>
	<li>Folders and Views</li>
</ul>
<h1>Management Pack Overview</h1>
The System Center Configuration Manager 2007 Client Management Packs not only provides various out-of-box preconfigured monitors / rules, but also provides some custom modules / workflows which allow you to build your own monitors to suit your System Center Configuration Manager 2007 environments. These management packs extends what <a href="http://www.microsoft.com/download/en/details.aspx?id=20463"><em>Microsoft System Center Minotoring Pack For Configuration Manager 2007 SP2 v6.0.6000.3</em></a> has to offer for SCCM client monitoring. This includes:
<h2><a name="_Toc318657961"></a>Pre-Configured Monitors and Rules:</h2>
· Recreated the SMS Agent Host service monitor and included diagnostic and recovery task to automatically restart the service when it has stopped.

· Checks the availability of Management Point of which the SCCM client connects to via HTTP response. The SCCM Management Point HTTP Response Monitor runs hourly to check the HTTP response of the active MP for the SCCM client and generates alerts if HTTP error responses received over 2 consecutive times.

· Checks the version of SCCM clients and generates alert if the version number is lower than 4.00.6487.2157 (<a href="http://support.microsoft.com/kb/977384">KB977384</a>, prerequisite for SCCM 2007 R3)

· Checks SCCM Clients Advertisement Execution history every 30 minutes. If there were any advertisements have been executed over the last 30 minutes, trigger Hardware Inventory so any newly installed applications will be inventoried and stored in SCCM site database. Additionally, if any failed advertisement executions are found, a Critical alert is generated.
<h2><a name="_Toc318657962"></a>Custom Modules and Monitor Types:</h2>
<strong>1. SCCM Client Property Value Check 2-State Monitor Type</strong>. This monitor type can be used to build monitors to monitor SCCM client properties. (i.e. Monitor any SCCM clients that are not assigned to the correct site or Cache Size is not configured according to your organisation’s standard, etc..)

This monitor type Supports the following Properties:
<ul>
	<li>SiteCode (SCCM Client Site Code)</li>
	<li>Version (SCCM Client version)</li>
	<li>GUID (SCCM client GUID)</li>
	<li>ManagementPoint (MP that SCCM client is connected to)</li>
	<li>ProxyMP (Proxy MP that SCCM client is connected to)</li>
	<li>InternetMP (Internet MP that SCCM client is connected to)</li>
	<li>LogsLocation (path to SCCM client log files)</li>
	<li>CacheLocation (path to SCCM client cache)</li>
	<li>CacheSize (The maximum size of SCCM client cache folder in MB)</li>
	<li>HTTPPort (The HTTP Port for SCCM Client)</li>
	<li>EnableAutoAssignment (if auto site assignment is enabled (true or false)</li>
	<li>AllowLocalAdminOverride (if the SCCM client allows local admin override (true or false))</li>
	<li>IsBDP (If the client is a branch distribution point (true or false))</li>
</ul>
This monitor type Supports the following Comparison Operators:
<ul>
	<li>eq (Equal to)</li>
	<li>ne (Not equal to)</li>
	<li>gt (Greater-than)</li>
	<li>lt (Less-than)</li>
	<li>ge (Greater-than or equal to)</li>
	<li>le (Less-than or equal to)</li>
	<li>IsNull (Is Null value)</li>
	<li>NotNull (Not Null value)</li>
</ul>
<strong>2. Write Action module to initiate SCCM client actions</strong>

<strong>3. Write Action module to repair SCCM client</strong>

<strong>4. Other Probe Action modules and Data Source modules that were used by pre-configured monitors and rules.</strong>
<h2><a name="_Toc318657963"></a>More Comprehensive Object Discoveries</h2>
This SCCM client object discovery in this management pack discovers pretty much every SCCM client properties that are visible in the industry well-known utility <a href="http://sourceforge.net/projects/smsclictr/">SCCM Client Center</a>.

Below is a comparison of the properties that SCCM Client Center can check VS. SCCM Client properties been discovered by this management pack VS. what are been discovered from Microsoft’s official management pack:

<strong>SCCM Client Center 2.0.4.0:</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2012/03/image.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/03/image_thumb.png" alt="image" width="580" height="376" border="0" /></a>

<strong>System Center Configuration Manager 2007 Client Management Pack v2.0.0.0:</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2012/03/image1.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/03/image_thumb1.png" alt="image" width="580" height="369" border="0" /></a>

<strong>Microsoft Official Configuration Manager 2007 SP2 Management Pack v6.0.6000.3:</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2012/03/image2.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/03/image_thumb2.png" alt="image" width="474" height="200" border="0" /></a>
<h2><a name="_Toc318657964"></a>SCOM Agent Actions for SCCM Clients</h2>
A number of SCCM Client actions have been built into this management pack. The following SCCM client actions can be initiated via SCOM Operations Console and Web Console:

· Discovery Data Collection

· File Collection

· Hardware Inventory

· Machine Policy Retrieval Evaluation

· Software Inventory

· Software Metering Usage Report

· Software Updates Agent Assignment Evaluation Cycle

· Software Updates Scan

· SCCM Client Repair
<h1>More information</h1>
The detailed guide for this MP can be downloaded <strong><span style="font-size: medium;"><a title="SCCM 2007 Client Management Pack Guide" href="http://blog.tyang.org/wp-content/uploads/2012/03/System-Center-Configuration-Manager-2007-Client-MP.pdf">HERE</a></span></strong>.

Management Pack Downloads:

From below link, you can download a zip file which contains:
<ol>
	<li>Sealed version of TYANG System Center Configuration Manager 2007 Library  management pack(.mp)</li>
	<li>Sealed version of TYANG System Center Configuration Manager 2007 Monitoring management pack(.mp)</li>
	<li>Unsealed version of TYANG System Center Configuration Manager 2007 Monitoring management pack(.xml)</li>
</ol>
The reason I’m offering the unsealed version of TYANG System Center Configuration Manager 2007 Monitoring management pack is that if you wish to create additional monitors / rules using the workflows in the library MP, you can just build them into the unsealed MP without creating a separate MP (and saves you time to unseal it).

Management Pack Download <span style="font-size: medium;"><strong><a title="SCCM 2007 Client Management Pack Download" href="http://blog.tyang.org/wp-content/uploads/2012/08/TYANG.System.Center.Configuration.Manager.2007.Client.MP_.zip">HERE</a></strong></span>.

As always, if you have any issues / questions / concerns or suggestions, email me! I’ll try to get back to you as soon as I can (even though recently I’ve been pretty busy at work and in my personal life. And that’s why it took me so long to write a blog article for this management pack!)