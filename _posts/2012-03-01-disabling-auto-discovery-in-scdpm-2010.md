---
id: 1043
title: Disabling Auto Discovery in SCDPM 2010
date: 2012-03-01T19:28:34+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=1043
permalink: /2012/03/01/disabling-auto-discovery-in-scdpm-2010/
categories:
  - SCDPM
tags:
  - Powershell
  - SCDPM
  - SQL
---
System Center Data Protection Manager is not something I normally play with. Recently, I’ve been dobbed in to troubleshoot an issue with remote sites network performance at work and the issue ended up was caused by Auto Discovery in DPM 2010.

So basically, DPM has this built-in function called “Auto Discovery” which queries the domain controller of its’ own home domain and stores every single domain member servers in its database. This job runs once a day, you can choose the time window of this job, but you can’t really disable it.

One of my colleagues has posted this issue in DPM TechNet forum: <a title="http://social.technet.microsoft.com/Forums/en-US/dpmsetup/thread/df3dc4ae-200a-4778-8a91-1d7e68d564f2/" href="http://social.technet.microsoft.com/Forums/en-US/dpmsetup/thread/df3dc4ae-200a-4778-8a91-1d7e68d564f2/">http://social.technet.microsoft.com/Forums/en-US/dpmsetup/thread/df3dc4ae-200a-4778-8a91-1d7e68d564f2/</a> and I also logged a premier support call with Microsoft. We got 2 very different solutions from TechNet forum and the Microsoft support engineer in China. After evaluating both solutions, I have decided to go with the solution from the TechNet forum since it’s more robust, but make some modifications.

I have made 3 modifications from the original SQL scripts from TechNet forum:
<ol>
	<li>The solution from TechNet forum involves creating a custom SQL agent job called ‘Cancel DPM Auto Discovery’ that runs once a day, prior to the DPM Auto Discovery job. I noticed if you manually change the Auto Discovery start time from DPM console, a new SQL agent job for Auto Discovery is created. So I can’t really guarantee that the original schedule for ‘Cancel DPM Auto Discovery’ job is still valid. Therefore, I changed the schedule from daily to hourly, and runs at the 55th minutes of each hour(i.e. 12:55am, 1:55am, 2:55am, etc.). Because the Auto Discovery job can only run at the full hour (1:00am, 2:00am, 3:00am), by changing the schedule, I can make sure no matter what time the Auto Discovery is scheduled to run, the SQL agent job that I have created will always disable it 5 minutes prior to it.</li>
	<li>As I mentioned in the forum thread, I had to change the SQL job category to something other than DPM otherwise DPM will delete my job.</li>
	<li>Since we have over 2000 DPM servers in the environment, manually running the SQL script on each DPM server is impossible. Therefore I created a PowerShell script to run the SQL scripts and use SCCM to push it out. During testing, I found the SQL script works if I manually run it from SQL management studio, but when running in PowerShell using either System.Data.SqlClient.SqlConnection object or COM ADO object, the script complained about not able to find @owner_sid at the step of creating the job. I fixed it by changing the job owner from “MICROSOFT$DPM$Acct” to “sa”.</li>
</ol>
Below is the SQL Script and the PowerShell script after my modifications.

<a title="SQL Script" href="http://blog.tyang.org/wp-content/uploads/2012/03/DPM.zip">SQL Script</a>

<a title="PowerShell Script" href="http://blog.tyang.org/wp-content/uploads/2012/03/Create-DisableDPMAutoDiscoverySQLJob.zip">PowerShell Script</a>

<strong><span style="color: #ff0000; font-size: small;">Note:</span></strong> Both SQL script and Powershell script assume the DPM database is configured as default (which is located locally on the DPM server and the SQL instance name is left as default of ‘MSDPM2010’). If your DPM server is located elsewhere, please modify the SQL script and the SQL connection string in the Powershell script accordingly.