---
id: 4721
title: Displaying OpsMgr Events Data in Squared Up Dashboards
date: 2015-10-05T15:02:22+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=4721
permalink: /2015/10/05/displaying-opsmgr-events-data-in-squared-up-dashboards/
categories:
  - SCOM
tags:
  - Dashboard
  - SquaredUp
---
For those who’s been using Squared Up dashboards for your OpsMgr environments, you’d probably know that currently Squared Up does not have a plug-in for OpsMgr event data, thus you cannot display event data collected by OpsMgr on a Squared Up dashboard natively.

However, since Squared Up does have a SQL plugin and the OpsMgr event data is stored in OpsMgr databases, I’d like to show you a way of displaying event data using the SQL Plugin today.

When developing event collection rules for an OpsMgr management pack, MP developers generally would configure the collection rule to store the collected event in both operational DB (OperationsManager) and the Data Warehouse DB (OperationsManagerDW).

So why storing the data in 2 different databases? As you may know, in the native OpsMgr console, all the event views are accessing the event data from the operational DB, but when you are using reports to retrieve event data, most likely you are accessing the data from the DW DB. Another difference is, the retention period in Operational DB is a lot shorter than the Data Warehouse DB. For example the data retention period for event data is 7 days in Operational DB and 100 days in the DW DB.

With the Squared Up SQL Plugin, there’s a variable you can use for referencing the Data Warehouse DB (global:dw). I have developed couple of similar SQL query that you can run against the DW DB to retrieve event data:

### Get the 30 most recent events logged with a specific source (publisher):

```sql
Select Top 30 'Level' = Case Evt.EventLevelId WHEN 1 THEN 'Error' WHEN 2 THEN 'Warning' WHEN 4 THEN 'Information' WHEN 8 THEN 'Success Audit' WHEN 16 THEN 'Failure Audit' ELSE 'Undefined' END, Convert(VARCHAR(24),Evt.DateTime,113) as 'Date Time', Evt.EventDisplayNumber as 'Event Number',Pub.EventPublisherName As 'Source', Cmp.ComputerName As 'Name', Det.RenderedDescription As 'Description'
FROM Event.vEvent AS Evt WITH (NoLock)
INNER JOIN EventPublisher AS Pub WITH (NoLock) ON Evt.EventPublisherRowId = Pub.EventPublisherRowId
INNER JOIN Event.vEventRule AS EvtRule ON Evt.EventOriginId = EvtRule.EventOriginId
INNER JOIN EventLoggingComputer AS Cmp WITH (NoLock) ON Evt.LoggingComputerRowId = Cmp.EventLoggingComputerRowId
INNER JOIN Event.vEventDetail AS Det WITH (NoLock) ON Evt.EventOriginId = Det.EventOriginId
WHERE Pub.EventPublisherName = 'Place-Your-Event-Source-Here' Order by DateTime desc
```

### Get all events with a specific Event Number:

```sql
Select 'Level' = Case Evt.EventLevelId WHEN 1 THEN 'Error' WHEN 2 THEN 'Warning' WHEN 4 THEN 'Information' WHEN 8 THEN 'Success Audit' WHEN 16 THEN 'Failure Audit' ELSE 'Undefined' END, Convert(VARCHAR(24),Evt.DateTime,113) as 'Date Time', Evt.EventDisplayNumber as 'Event Number',Pub.EventPublisherName As 'Source', Cmp.ComputerName As 'Name', Det.RenderedDescription As 'Description'
FROM Event.vEvent AS Evt WITH (NoLock)
INNER JOIN EventPublisher AS Pub WITH (NoLock) ON Evt.EventPublisherRowId = Pub.EventPublisherRowId
INNER JOIN Event.vEventRule AS EvtRule ON Evt.EventOriginId = EvtRule.EventOriginId
INNER JOIN EventLoggingComputer AS Cmp WITH (NoLock) ON Evt.LoggingComputerRowId = Cmp.EventLoggingComputerRowId
INNER JOIN Event.vEventDetail AS Det WITH (NoLock) ON Evt.EventOriginId = Det.EventOriginId
WHERE Evt.EventNumber = Place-Your-Event-Number-Here Order by DateTime desc
```

>**Note:** For these 2 queries, you will need to place the event publisher name and event ID into the queries accordingly.

As an example, I have created a Squared Up dashboard for Forefront Endpoint Protection (FEP) MP, where I used the SQL plugin to retrieve the recent 30 security events logged by the MP:

![](https://blog.tyang.org/wp-content/uploads/2015/10/image11.png)

The result displayed by the SQL query matches the Event view shipped with the FEP MP:

![](https://blog.tyang.org/wp-content/uploads/2015/10/SNAGHTML87024d3.png)

![](https://blog.tyang.org/wp-content/uploads/2015/10/SNAGHTML8711770.png)

and I have used the Data Warehouse DB variable in the SQL plugin configuration:

![](https://blog.tyang.org/wp-content/uploads/2015/10/image12.png)

You can download this dashboard from Squared Up’s community site: [https://community.squaredup.com/browse/download-info/forefront-endpoint-protection-2/](https://community.squaredup.com/browse/download-info/forefront-endpoint-protection-2/)

Lastly, please always test and tweak to query to need your requirements in SQL Management Studio first.