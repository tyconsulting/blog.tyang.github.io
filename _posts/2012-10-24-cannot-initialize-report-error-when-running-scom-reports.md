---
id: 1552
title: '&ldquo;Cannot initialize report&rdquo; Error When Running SCOM Reports'
date: 2012-10-24T19:52:05+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=1552
permalink: /2012/10/24/cannot-initialize-report-error-when-running-scom-reports/
categories:
  - SCOM
tags:
  - SCOM
  - SCOM Reporting
---
Yesterday, I noticed I get this error when I tried to run some reports in the <a href="http://www.systemcentercentral.com/BlogDetails/tabid/143/IndexID/73350/Default.aspx">System Center Central Health Check Reports MP</a> in my home SCOM 2007 R2 environment:

<span style="color: #ff0000;"><em>“Value of 01-Jan-01 12:00:00 AM” is not valid for ‘value’. ‘Value’ should be between ‘MinDate’ and ‘MaxDate’.</em></span>

<a href="http://blog.tyang.org/wp-content/uploads/2012/10/image19.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/10/image_thumb19.png" alt="image" width="580" height="383" border="0" /></a>

I then realised I get exactly the same error on any reports which contain datetime pickers in the report.

<a href="http://blog.tyang.org/wp-content/uploads/2012/10/image20.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/10/image_thumb20.png" alt="image" width="580" height="107" border="0" /></a>

Long story short, after spending some time troubleshooting this issue, including updating my SCOM 2007 R2 environment from CU5 to CU6 as this blog post has suggested:
<h4><a href="http://scug.be/christopher/2012/04/06/scom-2007-r2-reporting-value-of-1-01-0001-12-00-00-am-is-not-valid-for-value-value-should-be-between-mindate-and-maxdate/">SCOM 2007 R2 – Reporting : Value of ’1/01/0001 12:00:00 AM’ is not valid for ‘Value’. ‘Value’ should be between ‘MinDate’ and ‘MaxDate’</a></h4>
CU6 update didn’t fix my issue. The issue end up being the regional setting on my SCOM all-in-one box (RMS, databases and reporting server).

I live in Australia, so normally, I would set the language format to English (Australia). However, when I create a new management pack using SCOM 2007 R2 Authoring Console on a computer set to use English (Australia) language format, by default, 2 language packs are created in the management pack: ENU (English United States) and ENA (English Australia) and default language pack is set to ENA. I don’t always remember to change the default and delete ENA language pack for every management pack I’m working on. So,to work around this issue, on the 2 machines that I run Authoring Console from (one being the all-in-one SCOM server), I set the language format to English (United States) and modify the short date format from default <strong>M/d/yyyy</strong> to <strong>dd-MMMM-yy </strong>so I’m not confused with the month and day when I read a date. this is the cause of the error in SCOM reports.

<strong>Default English (United States) formats:</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2012/10/image21.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/10/image_thumb21.png" alt="image" width="351" height="403" border="0" /></a>

<strong>Modified formats:</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2012/10/image22.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/10/image_thumb22.png" alt="image" width="348" height="401" border="0" /></a>

After I changed the format back to default on my SCOM server, the reports started running! Since all the SCOM server roles are on the same box, I can’t confirm if which components (i.e. RMS, SSRS etc.) relies on the default language formats.