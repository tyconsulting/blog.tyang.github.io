---
id: 1035
title: SCCM Site Systems and Components Summarizer Reports
date: 2012-02-23T14:18:47+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=1035
permalink: /2012/02/23/sccm-site-systems-and-components-summarizer-reports/
categories:
  - SCCM
tags:
  - SCCM
  - SCCM Reports
---
I received an email today from someone who downloaded my <a href="http://blog.tyang.org/2012/01/31/sccm-health-check-script-updated-version-3-5/">SCCM Health Check Script 3.5</a>. He asked me if I can help to modify the script to only display Site Systems and Components status.

I thought this can be easily achieved by creating few simple reports inside SCCM. If you are running SCCM 2007 R3 and have Reporting Service Point configured, you can publish these reports to SQL Reporting Services and create some schedules to email out daily.

So I quickly wrote 3 reports:

1. Site Status Overview Report – A high level overview of site status

2. Site System Status Report – Provides same information as what shows under Site System Status in SCCM console.

3. Site Component Status Since 12:00AM Report – Provides same information as what shows under Component Status in SCCM console (assuming the Threshold period setting under Component Status Summarizer setting is left as default of ‘Since 12:00:00 AM’)
<h2><strong>Below are the SQL queries for each report:</strong></h2>
<strong>Site Status Overview Report</strong>

```sql
Select
SiteStatus.SiteCode, SiteInfo.SiteName, SiteStatus.Updated 'Time Stamp',
Case SiteStatus.Status
When 0 Then 'OK'
When 1 Then 'Warning'
When 2 Then 'Critical'
Else ' '
End AS 'Site Status',
Case SiteInfo.Status
When 1 Then 'Active'
When 2 Then 'Pending'
When 3 Then 'Failed'
When 4 Then 'Deleted'
When 5 Then 'Upgrade'
Else ' '
END AS 'Site State'
From V_SummarizerSiteStatus SiteStatus Join v_Site SiteInfo on SiteStatus.SiteCode = SiteInfo.SiteCode
Order By SiteCode
```

<strong>Site System Status Report</strong>

```sql
SELECT distinct
Case v_SiteSystemSummarizer.Status
When 0 Then 'OK'
When 1 Then 'Warning'
When 2 Then 'Critical'
Else ' '
End As 'Status',
SiteCode 'Site Code',
SUBSTRING(SiteSystem, CHARINDEX('\\', SiteSystem) + 2, CHARINDEX('"]', SiteSystem) - CHARINDEX('\\', SiteSystem) - 3 ) AS 'Site System',
REPLACE(Role, 'SMS', 'ConfigMgr') 'Role',
SUBSTRING(SiteObject, CHARINDEX('Display=', SiteObject) + 8, CHARINDEX('"]', SiteObject) - CHARINDEX('Display=',SiteObject) - 9) AS 'Storage Object',
Case ObjectType
When 0 Then 'Directory'
When 1 Then 'SQL Database'
When 2 Then 'SQL Transaction Log'
Else ' '
END AS 'Object Type',
CAST(BytesTotal/1024 AS VARCHAR(49)) + 'MB' 'Total',
CAST(BytesFree/1024 AS VARCHAR(49)) + 'MB' 'Free',
CASE PercentFree
When -1 Then 'Unknown'
When -2 Then 'Automatically grow'
ELSE CAST(PercentFree AS VARCHAR(49)) + '%'
END AS '%Free'
FROM v_SiteSystemSummarizer
Order By 'Storage Object'
```

<strong>Site Component Status Since 12:00AM Report:</strong>

```sql
SELECT distinct
Case v_ComponentSummarizer.Status
When 0 Then 'OK'
When 1 Then 'Warning'
When 2 Then 'Critical'
Else ' '
End As 'Status',
SiteCode 'Site Code',
MachineName 'Site System',
ComponentName 'Component',
Case v_componentSummarizer.State
When 0 Then 'Stopped'
When 1 Then 'Started'
When 2 Then 'Paused'
When 3 Then 'Installing'
When 4 Then 'Re-Installing'
When 5 Then 'De-Installing'
Else ' '
END AS 'Thread State',
Errors 'Errors',
Warnings 'Warnings',
Infos 'Information',
Case v_componentSummarizer.Type
When 0 Then 'Autostarting'
When 1 Then 'Scheduled'
When 2 Then 'Manual'
ELSE ' '
END AS 'Startup Type',
CASE AvailabilityState
When 0 Then 'Online'
When 3 Then 'Offline'
ELSE ' '
END AS 'Availability State',
NextScheduledTime 'Next Scheduled',
LastStarted 'Last Started',
LastContacted 'Last Status Message',
LastHeartbeat 'Last Heartbeat',
HeartbeatInterval 'Heartbeat Interval',
ComponentType 'Type'
from v_ComponentSummarizer
Where TallyInterval = '0001128000100008'
Order By ComponentName
```
<h2>Report Sample Screenshots:</h2>
<strong>Site Status Overview Report</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2012/02/image10.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/02/image_thumb10.png" alt="image" width="580" height="160" border="0" /></a>

<strong>Site System Status Report</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2012/02/image11.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/02/image_thumb11.png" alt="image" width="580" height="489" border="0" /></a>

<strong>Site Components Status Since 12:00AM Report:</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2012/02/image12.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/02/image_thumb12.png" alt="image" width="580" height="383" border="0" /></a>

I’ve exported these reports into a .mof file, which can be downloaded <a title="Site Reports" href="http://blog.tyang.org/wp-content/uploads/2012/02/SiteReports.zip">HERE</a>.