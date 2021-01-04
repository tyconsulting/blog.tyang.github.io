---
id: 4795
title: 'A Sneak Peek at Squared Up&rsquo;s Upcoming OMS Plugin'
date: 2015-10-27T18:12:21+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=4795
permalink: /2015/10/27/a-sneak-peek-at-squared-ups-upcoming-oms-plugin/
categories:
  - OMS
tags:
  - OMS
  - SquaredUp
---

## Introduction

If you are an existing Squared Up customer, or have previously evaluated Squared Up’s product, you’d probably already know that currently, other than the existing SQL Plugin, Squared Up dashboards retrieve data via either OpsMgr Data Warehouse (DW) DB, or via OpsMgr SDK.

With the recent launch of Microsoft <a href="http://www.microsoft.com/oms">Operations Management Suite</a> (OMS), over the last few months, folks at Squared Up have been busy developing a plug-in within Squared Up to display data within OMS. Although Squared Up has not set a release date for this plugin yet, I would like to give you a high level preview on what the OMS plug-in looks like so you know what you are expecting <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" src="http://blog.tyang.org/wp-content/uploads/2015/10/wlEmoticon-smile1.png" alt="Smile" />.

## Squared Up OMS Plug-in

Squared Up’s OMS Plug-in is designed to enable customers display the data collected by OMS on the Squared Up dashboards. It leverages the <a href="https://technet.microsoft.com/library/mt484116.aspx">OMS Search API</a> and allows users to specify the OMS search query within the plugin, and the search result returned from OMS will be displayed on the dashboard.

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/image29.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/10/image_thumb23.png" alt="image" width="530" height="287" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/SNAGHTML2477479a.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML2477479a" src="http://blog.tyang.org/wp-content/uploads/2015/10/SNAGHTML2477479a_thumb.png" alt="SNAGHTML2477479a" width="554" height="435" border="0" /></a>

As you can see, you can simply use the exact same query you’ve used in OMS and copy/paste to the OMS plug-in configuration. You can also use "|" (pipe) followed by the "Select" command to specify the fields that you are interested in displaying on the dashboard.

Since OMS is collecting data that is not natively available in OpsMgr (such as Change Tracking data, Wired Data, etc.) , you can really extend your existing Squared Up investment with this plugin. For example, I have produced a dashboard using the OMS plug-in in my lab (as shown below):

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/image30.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/10/image_thumb24.png" alt="image" width="705" height="343" border="0" /></a>

In this dashboard, I have configured the following sections:

* Windows Services Changes For the Last 6 Hours
  * Data type: ConfigurationChange
  * OMS Solution: Change Tracking
* Software Changes For the Last 1 Day
  * Data type: ConfigurationChange
  * OMS Solution: Change Tracking
* Top Offenders in OpsMgr (Nosiest monitoring objects)
  * Data type: Alert
  * OMS Solution: Alert Management
* Hyper-V Host Available Memory
  * Data type: PerfHoulry
  * OMS Solution: Capacity Planning
* Wired Data Traffic by Process
  * Data type: WiredData
  * OMS Solution: Wired Data

Without the OMS plugin, some of above listed data will not be available in Squared Up dashboards (such as change tracking data and wired data), some could be retrieved only via complex SQL queries (such as top OpsMgr offenders). Take Top OpsMgr offenders as example again, it is super easy to find out who are the OpsMgr top offenders in OMS, by using a very simple query:

```text
Type=Alert AlertState=New TimeGenerated>NOW-24HOURS | measure count() by SourceFullName
```

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/image31.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/10/image_thumb25.png" alt="image" width="533" height="284" border="0" /></a>

## Interested in the OMS Plug-in?

Currently the version running in my lab environment is the "limited release technical preview". This plug-in will also be demonstrated in the upcoming events such as MMS.

Are you also interested in trying the Squared Up Plug-in yourself? Although Squared Up has not confirmed the release date for this plug-in, they have asked me to let everyone know that if you’d like to test and provide feedback, please contact Squared Up directly. You can find their contact details from their website: <a title="https://squaredup.com/contact/" href="https://squaredup.com/contact/">https://squaredup.com/contact/</a>