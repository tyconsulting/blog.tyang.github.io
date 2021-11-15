---
id: 1761
title: OpsMgr 2012 App Advisor Web Console Failed To Run Reports After DW Database Move
date: 2013-03-12T20:12:14+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=1761
permalink: /2013/03/12/opsmgr-2012-app-advisor-web-console-failed-to-run-reports-after-dw-database-move/
categories:
  - SCOM
tags:
  - APM
  - SCOM
  - SCOM Reporting
---
Previously I’ve blogged my experience in <a href="https://blog.tyang.org/2013/01/08/migrating-opsmgr-2012-rtm-to-opsmgr-2012-sp1/">migrating from OpsMgr 2012 RTM to SP1</a> which involved moving all databases to a new database server running SQL 2012. Since then, I’ve noticed the instruction in moving Operational DB published in TechNet is actually missing a step, which I’ve blogged <a href="https://blog.tyang.org/2013/01/25/eventid-28001-and-29112-on-scom-2012-management-server-after-operational-database-move/">here</a>.

Over the last few days, since it was the long weekend down here in Victoria, I spent some time setting up the Talking Heads web application to explorer APM in OpsMgr 2012. I was following the instructions in Chapter 9 in the <a href="http://kevingreeneitblog.blogspot.com.au/2012/10/available-now-mastering-system-center.html">Mastering System Center 2012 Operations Manager</a> book. The instructions in this chapter is exactly the same (almost word to word) as the 3-part series in Kevin Greene’s blog (<a href="http://kevingreeneitblog.blogspot.com.au/2012/07/scom-2012-apm-consoles-part-1.html">Part 1</a>, <a href="http://kevingreeneitblog.blogspot.com.au/2012/07/scom-2012-apm-csm-vs-gsm-and-web.html">Part 2</a>, <a href="http://kevingreeneitblog.blogspot.com.au/2012/03/scom-2012-configuring-application_49.html">Part 3</a>). – Looks like we know who’s the author for this chapter. - Thanks Kevin <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" alt="Smile" src="https://blog.tyang.org/wp-content/uploads/2013/03/wlEmoticon-smile.png" />

Anyways, I’ve learnt a lot from this chapter as I’ve never dealt with Avicode in 2007 or APM in 2012. While I was exploring the App Diagnostic and App Advisor consoles, I’ve noticed my App Advisor console won’t run any reports! No matter which reports I tried to run, I always get this error:

<a href="https://blog.tyang.org/wp-content/uploads/2013/03/image6.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2013/03/image_thumb5.png" width="580" height="290" border="0" /></a>

and as suggested, I got this warning event (EventID 1309) from Windows Application log:

<a href="https://blog.tyang.org/wp-content/uploads/2013/03/image7.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2013/03/image_thumb6.png" width="543" height="435" border="0" /></a>

In the exception stack, it shows I cannot connect to the SQL server:

<em><span style="color: #ff0000;">Exception message: An error has occurred during report processing. ---&gt; Microsoft.ReportingServices.ReportProcessing.ProcessingAbortedException: An error has occurred during report processing. ---&gt; Microsoft.ReportingServices.ReportProcessing.ReportProcessingException: <strong>Cannot create a connection to data source 'AppMonitoringSource'. ---&gt; System.Data.SqlClient.SqlException: A network-related or instance-specific error occurred while establishing a connection to SQL Server. The server was not found or was not accessible. Verify that the instance name is correct and that SQL Server is configured to allow remote connections.</strong> (provider: Named Pipes Provider, error: 40 - Could not open a connection to SQL Server)
at System.Web.Services.Protocols.SoapHttpClientProtocol.ReadResponse(SoapClientMessage message, WebResponse response, Stream responseStream, Boolean asyncCall)
</span></em>

After spending time trying to fix this issue, I created a DNS Alias record with my old OpsMgr SQL server name pointing to the new SQL server, and it fixed the problem! By doing this, I knew there is one place that I haven’t updated the SQL server name yet. I went through the Technet instructions for moving Operational DB, DW DB and Reporting Server again, I couldn’t find which step was I missing.

Today, I had a second look in the SSRS instance for OpsMgr reporting, I noticed there is an additional data source called <strong>AppMonitoringSource</strong> under <strong>Application Monitoring –&gt;.Net Monitoring</strong>. the connection string for this data source was still pointing to the old SQL server:

<a href="https://blog.tyang.org/wp-content/uploads/2013/03/image8.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2013/03/image_thumb7.png" width="469" height="417" border="0" /></a>

According to the Technet guide <a href="http://technet.microsoft.com/en-us/library/hh268492.aspx">"How to Move the Data Warehouse Database"</a>, as per step 8, only the Data Warehouse Main data source needs to be updated (and of course, if we’ve manually created another data source for operational DB, which is very common and lots of community report MPs requires this datasource, we’d also update it too.). The AppMonitoringSource was not mentioned in the instructions – which I found interesting because step 10 actually covered changing the DB server name in <strong>dbo. MT_Microsoft$SystemCenter$DataWarehouse$AppMonitoring</strong>, table, we can tell by name is used for APM.

As result, after I’ve changed the connection string in this data source, deleted the DNS alias and flushed DNS cache on my web console server, the problem is now fixed.

So, not sure if the AppMonitoringSource was overlooked by the author of the Technet guide. For anyone who has moved the DW DB in OpsMgr 2012, it’s probably worth checking this data source (by going to http://&lt;reporting server&gt;/reports). I only found out now only because I’ve started using APM in my environment.