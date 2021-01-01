---
id: 3995
title: OpsMgr 2012 Data Warehouse Health Check Script
date: 2015-06-11T14:46:41+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=3995
permalink: /2015/06/11/opsmgr-2012-data-warehouse-health-check-script/
categories:
  - PowerShell
  - SCOM
tags:
  - Health Check
  - SCOM
---
<strong><span style="color: #ff0000;">Note (19/06/2015): This script has been updated to version 1.1. You can find the details of version 1.1 here: <a href="http://blog.tyang.org/2015/06/19/opsmgr-2012-data-warehouse-health-check-script-updated/">http://blog.tyang.org/2015/06/19/opsmgr-2012-data-warehouse-health-check-script-updated/</a>. The download link at the end of this post has been updated too.</span></strong>

I’m sure you all would agree with me that the OpsMgr database performance is a very common issue in many OpsMgr deployments – when it has not been designed and configured properly. The folks at Squared Up certainly feels the pain – when the OpsMgr Data Warehouse database is not performing at the optimal level, it would certainly impact the performance of Squared Up dashboard since Squared Up is heavily relied on the Data Warehouse database.

So Squared Up asked me to build a Health Check tool specific to OpsMgr data warehouse databases, in order to help customers identify and troubleshooting the performance related issues with the data warehouse DB. Over the last few weeks, I have been working on such a script, focusing on the data warehouse component, and produces a HTML report in the end.

<strong><u>We have decided to make this tool not only available to the Squared Up customers, but also to the broader community, free of charge. So on that, BIG Thank-You to Squared Up’s generosity.</u></strong>

Before I dive into the details,  I’d like to show you what the report looks like. You can access the sample report generated against my lab MG here:

<a href="http://blog.tyang.org/wp-content/uploads/2015/06/DWHealthCheckResult-2015-Jun-04.html" target="_blank">CLICK HERE TO LAUNCH THE HTML REPORT</a>

As shown in this sample, the report consists of the following sections:

<strong>Management Group Information</strong>
<ul>
	<li>Management group name and version</li>
	<li>server names for RMS Emulator, Operational DB SQL Server, Data Warehouse SQL server</li>
	<li>Operational DB name, Data Warehouse DB name</li>
	<li>Number of management servers, Windows agents, Unix agents, managed network devices and agentless managed computers</li>
	<li>Current SDK connection count (total among all management servers)</li>
</ul>
<strong>Data Warehouse SQL Server information</strong>
<ul>
	<li>Server hardware spec and OS version</li>
	<li>SQL server version and collation</li>
	<li>Minimum and Maximum assigned memory to the SQL server</li>
</ul>
<strong>Data Warehouse SQL DB information</strong>
<ul>
	<li>DB Name, creation date, collation, recovery mode</li>
	<li>Current state, is broker enabled, is auto-shrink enabled</li>
	<li>Current DB size (both data and logs), free space %</li>
	<li>Growth settings, last backup date and backup size</li>
</ul>
<strong>Temp DB configuration</strong>
<ul>
	<li>File size, max size and growth settings for each file used by Temp DB</li>
</ul>
<strong>SQL Service Account Configuration</strong>
<ul>
	<li>If the SQL Service account has "Perform volume maintenance tasks" and "Lock Pages in Memory" rights</li>
</ul>
<strong>Data Warehouse Dataset Configuration</strong>
<ul>
	<li>Dataset retention setting
<ul>
	<li>Retention setting for each dataset</li>
	<li>current row count, size and % of total size of each dataset</li>
</ul>
</li>
	<li>Dataset aggregation backlog</li>
	<li>Staging Table Row Count for the following tables:
<ul>
	<li>Alert.AlertStage</li>
	<li>Event.EventStage</li>
	<li>Perf.PerformanceStage</li>
	<li>State.StateStage</li>
	<li>ManagedEntityStage</li>
</ul>
</li>
</ul>
<strong>Key SQL and OS performance counters</strong>
<ul>
	<li>SQL performance counters
<ul>
	<li>SQLServer.Buffer.Manager\Buffer cache hit ratio</li>
	<li>SQLServer.Buffer.Manager\Page.Life.Expectancy</li>
</ul>
</li>
	<li>Operating System performance counters
<ul>
	<li>Logical Disk(_total)\Avg. disk sec/Read</li>
	<li>Logical Disk(_total)\Avg. disk sec/Write</li>
	<li>Processor Information (_total)\% Processor Time</li>
</ul>
</li>
</ul>
<strong>Collect Data Warehouse performance related events from each management server</strong>
<ul>
	<li>Event ID: 2115</li>
	<li>Event ID: 8000</li>
	<li>Event ID: 31550-21559</li>
</ul>
Since each environment is different, therefore I didn’t want to create a fix set of rules to flag any of above listed items good or bad. but instead, at the end of each section, I have included some articles that can help you to evaluate your environment and identify if there are any discrepancies.

<strong>Prerequisites</strong>

This script has the following pre-requisites:
<ul>
	<li>The user account that is running the script (or the alternative credential passed into the script) must have the following privileges:
<ul>
	<li>local administrator rights on the Data Warehouse SQL server and all Management servers</li>
	<li>A member of the OpsMgr Administrator role</li>
	<li>SQL sysadmin rights on the Data Warehouse SQL server</li>
</ul>
</li>
	<li>WinRM (PowerShell Remoting) must be enabled on the Data Warehouse SQL Server</li>
	<li>The OpsMgr SDK Assemblies must be available on the computer running the script:
<ul>
	<li>The script can be executed on a OpsMgr management server, web console server, or a computer that has OpsMgr operations console installed</li>
	<li>OR, manually copy the 3 DLLs from "&lt;management server install dir&gt;\SDK Binary" folder to the folder where the script is located.</li>
</ul>
</li>
</ul>
<strong>Executing the script</strong>

The only required parameter is –SDK &lt;OpsMgr Management Server name&gt;, where you need to specify one of your management server (doesn’t matter which one). Additionally, if you use the –OpenReport switch, the HTML report will be opened in your default browser in the end. <span style="color: #ff0000;">If you use -OutputDir to specify a directory, the reports will be saved to this directory instead of script root directory. If the directory you've specified is not valid, the script will save the reports to the script root directory instead (updated 19/06/2015).</span> You can also use –verbose switch to see the verbose output:

i.e.:

<strong>.\SCOMDWHealthCheck.ps1 –SDK "OpsMgrMS01" -OutputDir C:\Temp\Reports\ –OpenReport –Verbose</strong>

Or if you need to specify alternative credential:

<strong>$password = ConvertTo-SecureString –String "password12345" –AsPlainText –Force</strong>

<strong>.\SCOMDWHealthCheck.ps1 –SDK "OpsMgrMS01" –Username "domain\SCOM.Admin" –Password $Password –OpenReport –Verbose</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2015/06/SNAGHTML43ec987.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML43ec987" src="http://blog.tyang.org/wp-content/uploads/2015/06/SNAGHTML43ec987_thumb.png" alt="SNAGHTML43ec987" width="675" height="671" border="0" /></a>

The report outputs the following files:
<ul>
	<li>Main HTML report</li>
	<li>Main Report in XML format</li>
	<li>Windows Event export from each management server in a separate HTML page</li>
	<li>Windows Event export from each management server in a separate CSV file</li>
</ul>
<strong>Note:</strong> The XML file is produced so if anyone wants to develop another set of tool to analyse the data for their own environment, it would be very easy to read the data from the XML file.

The script writes the list of the file it generated as output:

<a href="http://blog.tyang.org/wp-content/uploads/2015/06/image8.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/06/image_thumb8.png" alt="image" width="561" height="197" border="0" /></a>

<del><strong>Possible Areas for Improvement</strong></del>

<del>Due to the limited environments that I have access to, I am unable to test this script in environments where Data Warehouse DB is installed on a named SQL instance or a SQL Always-On setup. So if your environment is setup this way, please contact me and let me know what’s working and what’s not.</del> <span style="color: #ff0000;">This issue is now fixed in version 1.1 (Updated 19.06/2015)</span>

<strong>Credit</strong>

I couldn’t have done this by myself. I’d like to thank the following people (in random order) who helped me in testing and provided feedbacks:

Folks from Squared Up: Glen Keech, Richard Benwell

SCCDM MVPs: Marnix Wolf, David Allen, Daniele Grandini, Cameron Fuller, Simon Skinner, Scott Moss, Fleming Riis

And, the legendary Kevin Holman

I'd also like to thank for all the people who has indirectly contributed to this tool (where I included links to their awesome articles and publications in the report). Some of them are already listed above, but here are few more: Paul Keely (Author for the SQL Server Guide for System Center 2012 whitepaper), Michel Kamp, Bob Cornelissen, Stefan Stranger and Oleg Kapustin.

<strong>Download</strong>

You can download the script from the link below. Please place the 2 files in the zip file in the same directory:

<a href="http://blog.tyang.org/wp-content/uploads/2015/06/image9.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/06/image_thumb9.png" alt="image" width="549" height="158" border="0" /></a>

[wpdm_package id='4002']

Lastly, as always, please feel free to contact me if you'd like to provide feedback.

&nbsp;

&nbsp;