---
id: 4500
title: OpsMgr Performance Collection Rules for OMS Near Real-Time Performance Data Collection
date: 2015-09-02T23:31:16+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=4500
permalink: /2015/09/02/opsmgr-performance-collection-rules-for-oms-near-real-time-performance-data-collection/
categories:
  - OMS
  - SCOM
tags:
  - Management Pack
  - OMS
  - SCOM
---
<span style="color: #ff0000;">Update: 09/09/2015: I found a small error in the demo MP provided at the end of this post, where one of the perf collection rules had an extra condition detection module (which prevents the real-time perf data to be sent to OMS). I have just updated the MP and the download link.</span>

## Introduction

Yesterday, the OMS product team has <a href="http://blogs.technet.com/b/momteam/archive/2015/09/01/near-real-time-performance-data-collection-in-oms.aspx">announced the availability of the Near-Real Time (NRT) Performance Data Collection in OMS</a>. My buddy and fellow SCCDM MVP Stanislav Zhelyazkov has already wrote an article on his blog: <a href="https://cloudadministrator.wordpress.com/2015/09/01/operations-management-suite-performance-monitoring/">Operations Management Suite – Performance Monitoring</a>.

I won’t repeat what’s already been discussed in these 2 posts, but I’ll tackle it from the management pack authoring perspective, and sharing what I have discovered so far.

**<span style="color: #ff0000;">Note:</span>** If you haven’t read above mentioned 2 posts, I strongly recommend you to do so before continuing with this article.

## Management Pack Under The Hood

By default, OMS has 8 performance counters configured for near-real time perf collection. You can see them in the settings section of your workspace:

<a href="https://blog.tyang.org/wp-content/uploads/2015/09/image.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/09/image_thumb.png" alt="image" width="655" height="373" border="0" /></a>

As explained in both the official blog post from the OMS product team as well as Stan’s blog, you can add additional perf counters on this page, and it will be pushed to the OpsMgr management groups that are connected to this OMS workspace. I am fairly certain, the sample interval range is **between 10-1800 seconds** (minimum 10 seconds, maximum 30 minutes).

All the counters configured on this page are stored in an Unsealed management pack called "Microsoft System Center Advisor Log Management Collection" in your OpsMgr management group.

<a href="https://blog.tyang.org/wp-content/uploads/2015/09/SNAGHTML6943086.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML6943086" src="https://blog.tyang.org/wp-content/uploads/2015/09/SNAGHTML6943086_thumb.png" alt="SNAGHTML6943086" width="624" height="301" border="0" /></a>

If you export this MP and open it using MPViewer, you will see there are 2 rules for each counter:

<a href="https://blog.tyang.org/wp-content/uploads/2015/09/SNAGHTML6a306af.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML6a306af" src="https://blog.tyang.org/wp-content/uploads/2015/09/SNAGHTML6a306af_thumb.png" alt="SNAGHTML6a306af" width="690" height="319" border="0" /></a>

**Microsoft.IntelligencePack.LogManagement.Collection.PerformanceCounter.xxxxxxxxxx:**

These rules are collecting the raw real time perf data:

<a href="https://blog.tyang.org/wp-content/uploads/2015/09/image1.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/09/image_thumb1.png" alt="image" width="648" height="243" border="0" /></a>

**Microsoft.IntelligencePack.LogManagement.Collection.PerformanceCounterAggregation.xxxxxxxxxx:**

As the name suggested, these rules are collecting the 30-minute aggregated data (As stated in the official blog post, the raw data retention is 14 days and the 30-minute aggregated data retention is same as your OMS data plan).

<a href="https://blog.tyang.org/wp-content/uploads/2015/09/image2.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/09/image_thumb2.png" alt="image" width="651" height="306" border="0" /></a>

After Examining these 2 rules closely,  we can see the following:

01. Both rules are disabled by default

02. Both rules are not remoteable (won’t work for agentless machines)

03. Both rules are targeting the Windows Computer class (Microsoft.Windows.Computer)

04. Both Rules are using the same data source module with same input parameters (Microsoft.IntelligencePacks.Performance.DataProvider). This configuration enables OpsMgr agents to leverage the <a href="https://technet.microsoft.com/en-us/library/Ff381335.aspx">Cookdown</a> feature to reduce the computer resource consumed by these rules.

05. Comparing with the raw data collection rule, the aggregation data collection rule has an additional condition detection module (which is used for data aggregation) and the aggregated data is submitted to OMS via a different write-action module (Microsoft.SystemCenter.CollectCloudPerformanceDataAggregated_PerfIP).

06. Since both rules are disabled by default, the MP also comes with overrides to enable these rules for the OMS managed computers:

<a href="https://blog.tyang.org/wp-content/uploads/2015/09/SNAGHTML6c32a96.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML6c32a96" src="https://blog.tyang.org/wp-content/uploads/2015/09/SNAGHTML6c32a96_thumb.png" alt="SNAGHTML6c32a96" width="671" height="351" border="0" /></a>

## Write Your own OMS Near-Real Time Perf Collection Rules

Now that we have discovered how are the near-real time perf data is collected in OpsMgr, I have spent some time today testing different rule configurations. Based on **<u>my own experience</u>**, my findings are:

**01. Both raw data collection rule and aggregation data collection rule are required**

Based on my testing, I found in order to submit near-real time perf data to OMS, I must create both raw data and aggregation data collection rules (as shown above). I tried with only one rule for the raw data, after few hours, I still couldn’t see the data in OMS. I then created another rule for the aggregation data, imported the updated MP in OpsMgr, after about 30 minutes, the data became visible from the search result.

**02. Data source module "Microsoft.IntelligencePacks.Performance.DataProvider"**

The rule must use the data source module "Microsoft.IntelligencePacks.Performance.DataProvider", which is defined in management pack "Microsoft System Center Advisor Types Library" (Microsoft.IntelligencePacks.Types). This data source module consists of 2 member modules:

<a href="https://blog.tyang.org/wp-content/uploads/2015/09/image3.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/09/image_thumb3.png" alt="image" width="689" height="447" border="0" /></a>

* Data Source: System.Performance.DataProvider
* Condition Detection: System.Performance.DataGenericMapper

I have tried to use System.Performance.DataProvider module directly in both raw and aggregation data collection rules, unfortunately this configuration does not seem to work. additionally, many 4502 events were logged in the Operations Manager log on the OpsMgr agent computer indicating the configuration for the aggregation data collection rule is incorrect.

<a href="https://blog.tyang.org/wp-content/uploads/2015/09/image4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/09/image_thumb4.png" alt="image" width="565" height="533" border="0" /></a>

**03. The Rule target must be Windows Computer class (Microsoft.Windows.Computer).**

Initially I have written few rules targeting SQL DB Engine class, waited few hours and I could only see the 30-minute aggregated data in OMS (collected by the aggregation collection rules). The data insertion is every 30 minutes and the perf graph could not be displayed in OMS (showed "No Data"). When I changed the target for both rules from SQL DB Engine to Windows Computer class, the raw data started to appear.

Having said that, I have also tried Windows Server Computer class (Microsoft.Windows.Server.Computer). This class is derived from Windows Computer class. This configuration also worked. So in my opinion, it is fair to guess the target class must be Windows Computer class or class that’s based on Windows Computer class.

### Demo Management Pack "OMS Performance Demo MP"

I have created a MP during my experiments today. In the end, I have deleted all the rules that are not working in this MP and kept two sets rules for demonstration purpose:

* Set #1:
  * Target: Microsoft.Windows.Computer
  * Perf Counter: Processor(_Total)\% Privileged Time

<a href="https://blog.tyang.org/wp-content/uploads/2015/09/image5.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/09/image_thumb5.png" alt="image" width="729" height="366" border="0" /></a>

* Set #2:
  * Target: Microsoft.Windows.Server.Computer
  * Perf Counter: SQLServer:Memory Manager(*)\Free Memory (KB)

<a href="https://blog.tyang.org/wp-content/uploads/2015/09/image6.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/09/image_thumb6.png" alt="image" width="718" height="254" border="0" /></a>

You can download my demo MP from the link below:

[DOWNLOAD](../../../../wp-content/uploads/2015/09/OMS.Perf.Demo.zip)

**<span style="color: #ff0000;">Disclaimer:</span>**

This post is purely based on my own experiment, it may not be 100% accurate. Please use it with caution and test it in your test environment first!