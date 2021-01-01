---
id: 779
title: 'SCOM MP Authoring Example: Generate alerts based on entries from SQL Database (Part 1 of 2)'
date: 2012-01-04T19:12:02+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=779
permalink: /2012/01/04/scom-mp-authoring-example-generate-alerts-based-on-entries-from-sql-database-part-1-of-2/
categories:
  - SCOM
tags:
  - MP Authoring
  - SCOM
---
This is probably going to be a bit too long for one single blog post. I’ll separate this topic into <strong>2 articles</strong>:
<ol>
	<li>Part 1 includes the background and overview of the rule and it’s workflow</li>
	<li><a href="http://blog.tyang.org/2012/01/05/scom-mp-authoring-example-generate-alerts-based-on-entries-from-sql-database-part-2-of-2/">Part 2</a> documents all the steps to create all the module types and the rule itself.</li>
</ol>
<strong>This article is the first part of the 2-part series.</strong>

Recently, I’ve been writing a SCOM management pack for a new application that my employer is implementing. This application logs any application related alarms into a SQL express database. One of the requirement for the MP is to catch these alarms from the database and generate alerts based on these alarms.

In the database, I’m interested in any records that has the value of “Alarm triggered” in “EventTypeCaption” column.

The the record is added to the database, the application also adds the time stamp in UTC to the “EventDate” field.

Below is a snapshot of a subset of the database. I’ve highlighted the records that I’m interested in:

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb.png" alt="image" width="580" height="419" border="0" /></a>

To achieve this goal, I’ve written some custom modules and created a rule using these modules.

<strong><span style="font-size: medium;">Rule overview:</span></strong>

As usual, the rule contains 3 modules:
<ol>
	<li>Data Source</li>
	<li>Condition Detection</li>
	<li>Actions</li>
</ol>
<a href="http://blog.tyang.org/wp-content/uploads/2012/01/Rule.jpg"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="Rule" src="http://blog.tyang.org/wp-content/uploads/2012/01/Rule_thumb.jpg" alt="Rule" width="304" height="441" border="0" /></a>

Below is the flow chat for the entire workflow:

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/workflow.jpg"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="workflow" src="http://blog.tyang.org/wp-content/uploads/2012/01/workflow_thumb.jpg" alt="workflow" width="397" height="779" border="0" /></a>

To explain the workflow in details:
<ol>
	<li>The workflow takes 3 inputs:
<ol>
	<li>IntervalSeconds – how frequent does the rule run</li>
	<li>SQLInstance – Name of the SQL instance</li>
	<li>Database – Name of the database</li>
</ol>
</li>
	<li>The data source member module system.simple.scheduler runs according to the intervalseconds</li>
	<li>The Probe Action member module (a PowerShell script) takes all 3 inputs:
<ol>
	<li>connect to the database in the SQL instance as specified from the input</li>
	<li>calculate the earliest time (current time minus intervalseconds from the input then convert to UTC). store the earliest time in a datetime variable $starttime</li>
	<li>Build the SQL query: <strong>"Select * from &lt;table name&gt; Where EventTypeCaption LIKE 'Alarm triggered' AND EventDate &gt;= '$StartTime'"</strong></li>
	<li>Execute the SQL query.</li>
	<li>If returned any data:
<ol>
	<li>Property Bag value “GenerateAlert” = True</li>
	<li>For each record, convert the EventDate from UTC time to local time.</li>
	<li>combine all records from the record set to a multi line string that include converted event date and event description. return this string as Property Bag value “LogEntry”</li>
	<li>return Property Bag Value “LogEntryCount”</li>
</ol>
</li>
</ol>
</li>
	<li>Condition Detection module detects Property Bag value “GenerateAlert” = True</li>
	<li>If passed Condition Detection Module, the Write Action module generates alert with LogEntry and LogEntryCount in alert description field.</li>
</ol>
<strong><span style="color: #ff0000; font-size: medium;">Note:</span></strong> I’m using <strong>PowerShellPropertyTriggerOnlyProbe</strong> rather than VBscript because I found it’s easier to convert UTC and local time back and forth as I can simply use .NET class System.TimeZoneInfo and powershell datetime object ToUTC() method to do the conversion. if we are to use VBScript, there is no equivalent trigger only probe for VBScript. I’ll try to cover this in a separate blog post.

<strong>What’s Next?</strong>

I’ll go through how to create each module types and the rule itself in part 2 of this series.

<strong>To be continued…</strong>

<a href="http://blog.tyang.org/2012/01/05/scom-mp-authoring-example-generate-alerts-based-on-entries-from-sql-database-part-2-of-2/">Part 2</a>