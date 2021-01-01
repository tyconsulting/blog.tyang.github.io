---
id: 6388
title: Creating Azure Monitor Alerts using Azure Log Analytics Query Language Based On Azure Automation Runbook Job Output
date: 2018-03-18T21:55:34+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=6388
permalink: /2018/03/18/creating-azure-monitor-alerts-using-azure-log-analytics-query-language-based-on-azure-automation-runbook-job-output/
categories:
  - Azure
  - OMS
  - PowerShell
tags:
  - Azure
  - Azure Automation
  - OMS
  - PowerShell
---
Well, this post has such a long title – but I've tried my best. It is based on an idea I had – We all have many "Health Check" PowerShell scripts in our collections, why not use them in OMS without too much modification and generate meaningful alerts based on the outputs of these scripts? I have been meaning to write this post for at least 4 months, I finally found some spare time this weekend so I can work on this.

In the past, when I was still working on System Center Operations Manager, I always get requests from various support teams like "Could you write a monitor in SCOM to monitor xxx? I’ve already got a script, all you need is to add it into a Management Pack." Well, it may sound pretty easy, but in most cases, these tasks are not as straight forward as you may think. In order to create a monitor or a rule in SCOM, you will need to define the monitoring class, health rollup model, object discoveries to begin with, then when you have a script, you will need to understand how to use property bags, how to leverage cook down within the script, where do you get input parameters from, and then it comes to the actual alert (and maybe alert suppression too), then how do people want to get notified? Furthermore, based on my experience, these scripts I got from the support teams generally do more than one things. so most of the time, I ended up re-writing the scripts for the Management Packs. As you can see, this is a very complicated task, not something you’d expect an average System Admin could do. I personally believe the complexity of SCOM management packs, and the lack of available training / knowledge in the market has really limited the adoption of SCOM (to a degree).

So, wouldn’t it be nice if we can leverage an existing script you wrote or found on the Internet, and turn it into something that you can actually use for alerting in production environments? This was doable in OMS, but still a bit complicated before the <a href="https://blogs.technet.microsoft.com/msoms/2017/10/17/azure-log-analytics-workspace-upgrades-in-progress/" target="_blank" rel="noopener">update of the Azure Log Analytics search language</a>. Before the update, in v1 of the search language, in order to retrieve structured information from the search result, you have to either use the <a href="https://blog.tyang.org/2016/12/17/omsdatainjection-updated-to-version-1-2-0/" target="_blank" rel="noopener">Log Analytics HTTP injection API</a> to inject structured logs into Log Analytics, or create <a href="https://docs.microsoft.com/en-us/azure/log-analytics/log-analytics-data-sources-custom-logs" target="_blank" rel="noopener">custom logs</a> to create additional fields after the logs have been injected. This is still too complicated, and can be very time consuming. I don’t think many of us would go down this path too often.

Luckily, with the new v2 of the Log Analytics search language (a.k.a Kusto, which is also used in Azure Application Insights), we are able to extract information from a log field on the fly using the <a href="https://docs.loganalytics.io/docs/Language-Reference/Tabular-operators/parse-operator" target="_blank" rel="noopener">parse() operator</a>. The parse() operator supports simple expressions or regex so you can pretty much do anything when extracting required information from any given fields. To demonstrate how I can quickly setup alerts from a very basic PowerShell script, I will use a demo script (scroll down to the bottom of this post to view the source code) that checks the last backup date and free space of all SQL databases on a group of SQL servers. The SQL servers are located On-prem (in my home lab), and I am going to use Azure Automation to run this script (as a PowerShell runbook) on a Hybrid Worker computer also located in my home lab. The script simply writes the result in standard output (stdout) using Write-Output cmdlet. it looks like this (when running on my desktop):

<a href="https://blog.tyang.org/wp-content/uploads/2018/03/image.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/03/image_thumb.png" alt="image" width="1002" height="433" border="0" /></a>

As you can see, the script produces 2 lines for each database. The first line lists the SQL server name, database name, and the last backup finished date, and the second line lists the server name, database name, current size, free space size and free space % in a human readable format.

In order to use this script as the alert source, we need to make some once-off initial configurations (assuming you already have an Azure Log Analytics workspace and an Azure Automation account):
<ol>
 	<li>Link the Azure Automation Account to the Log Analytics workspace so you can use the Hybrid workers to run runbooks on-prem</li>
 	<li>Install at least one Hybrid Worker VM in your environment (<a title="https://docs.microsoft.com/en-us/azure/automation/automation-hybrid-runbook-worker" href="https://docs.microsoft.com/en-us/azure/automation/automation-hybrid-runbook-worker">https://docs.microsoft.com/en-us/azure/automation/automation-hybrid-runbook-worker</a>)</li>
 	<li>Configure the Diagnostics settings for you Azure Automation account and forward logs and metrics to the Log Analytics workspace (<a title="https://docs.microsoft.com/en-us/azure/automation/automation-manage-send-joblogs-log-analytics" href="https://docs.microsoft.com/en-us/azure/automation/automation-manage-send-joblogs-log-analytics">https://docs.microsoft.com/en-us/azure/automation/automation-manage-send-joblogs-log-analytics</a>). btw, this instruction is too complicated. you can simply go to Azure Monitors in the Azure Portal, then go to the "Diagnostics settings" blade, find your automation account, and configure it to send everything to your Log Analytics workspace</li>
</ol>
<a href="https://blog.tyang.org/wp-content/uploads/2018/03/image-1.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/03/image_thumb-1.png" alt="image" width="886" height="518" border="0" /></a>

Once these steps are completed, I created a runbook based on my existing PowerShell script. Since I need to store the list of SQL server names and the credential to connect to my SQL instances (in this case, i’m using my default sa account), I have created a variable in the automation account to store the SQL server names, and a credential object to store the "sa" credential.
<blockquote><strong>Note:</strong> This is only for demo purposes, you many use a different strategy to store all your sever names in your production environments (i.e. Azure table storage, your CMDB, or create computer groups in Log Analytics, and query Log Analytics for the members in the group, etc.)</blockquote>
Since I need this runbook to run on a regular basis, I created a schedule in Automation account to run this runbook. When the runbook is executed, all the Write-Output messages gets written to the job stream, and subsequently got logged into Log Analytics. i.e. Here’s the job output in Azure Automation:

<a href="https://blog.tyang.org/wp-content/uploads/2018/03/image-2.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/03/image_thumb-2.png" alt="image" width="962" height="523" border="0" /></a>

and also in Log Analytics (you'll need to wait few minutes after the runbook job):

<a href="https://blog.tyang.org/wp-content/uploads/2018/03/image-3.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/03/image_thumb-3.png" alt="image" width="949" height="453" border="0" /></a>

Once we can confirm these PowerShell script outputs got landed in Log Analytics, we can easily create Azure Monitor alerts based on custom search queries. In this case, I am creating two (2) separate alerts, one for the last DB backup date is more than 2 days old (The DB hasn’t been backed up for more than 2 days), and another one for the % free space within a database is less than 20%. Here are the search queries I used for these 2 alerts:

<strong>DB Backup Alerts:</strong>

<span style="background-color: #ffff00;">AzureDiagnostics | where RunbookName_s == "SQLMonitoringDemo" | where ResultDescription contains "Backup" |parse ResultDescription with "SQLServerName: " SQLServerName ", Database: " Database ", Last Backup Finish Date (UTC): '" BackupFinishedDateUTC:datetime  "'"* | project SQLServerName, Database, BackupFinishedDateUTC, TimeGenerated | where BackupFinishedDateUTC &lt;= ago(2d)</span>

<strong>DB Free Space Alerts:</strong>

<span style="background-color: #ffff00;">AzureDiagnostics | where RunbookName_s == "SQLMonitoringDemo" | where ResultDescription contains "Free Space" | parse ResultDescription with "SQLServerName: " SQLServerName ", Database: " Database ", Current Size MB: " CurrentSizeMB ", Free Space MB: " FreeSpaceMB ", Free Space Percentage: " FreeSpacePercent:long * | project SQLServerName, Database, CurrentSizeMB, FreeSpaceMB, FreeSpacePercent, TimeGenerated | where FreeSpacePercent &lt; 20</span>

As you can see, I’m extracting the SQL Server name, DB name, Last backup date, current size, free space size and free space % from the ResultDescription field using the parse() operator.  I'm also converting the FreeSpacePercent field to long and backup finished date to datetime type. The ResultDescription field is where the runbook jobstream data is stored. If I manually run these two search queries in the Advanced Analytics portal, I can see these custom fields got created in the search result on the fly:

<a href="https://blog.tyang.org/wp-content/uploads/2018/03/image-4.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/03/image_thumb-4.png" alt="image" width="1002" height="520" border="0" /></a>

<a href="https://blog.tyang.org/wp-content/uploads/2018/03/image-5.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/03/image_thumb-5.png" alt="image" width="1002" height="520" border="0" /></a>

To create the alerts, in Azure Portal, go to Azure Monitor, and create new alert rules in the Alerts (preview) blade:

<a href="https://blog.tyang.org/wp-content/uploads/2018/03/image-6.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/03/image_thumb-6.png" alt="image" width="988" height="734" border="0" /></a>

I also created an Action Group that contains my email address for the alert rules, so when the alerts are fired, I will get notified via email. there are other delivery options within Action Groups (i.e. SMS, voice calls, push notification to the Azure mobile app, webhooks, send to ITSM systems, Azure Automation runbooks, etc.), make sure you check them out.

<a href="https://blog.tyang.org/wp-content/uploads/2018/03/image-7.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/03/image_thumb-7.png" alt="image" width="967" height="714" border="0" /></a>

Needless to say, after a while, I started getting alert email notifications:

<a href="https://blog.tyang.org/wp-content/uploads/2018/03/image-8.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/03/image_thumb-8.png" alt="image" width="938" height="689" border="0" /></a>

If you want to learn more about the capability of the Log Analytics query language, make sure you visit the documentation site here: <a title="https://docs.loganalytics.io/index" href="https://docs.loganalytics.io/index">https://docs.loganalytics.io/index</a> and the demo workspace here: <a title="https://portal.loganalytics.io/demo#/discover/home" href="https://portal.loganalytics.io/demo#/discover/home">https://portal.loganalytics.io/demo#/discover/home</a>

Lastly, as promised, here’s the demo runbook I have used in this blog post:

https://gist.github.com/tyconsulting/08bdb5d63be83498a1e64755d5fa8583