---
id: 4776
title: Accessing OpsMgr Data on Your Mobile Devices through OMS Mobile Apps
date: 2015-10-22T16:17:37+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=4776
permalink: /2015/10/22/accessing-opsmgr-data-on-your-mobile-devices-through-oms-mobile-apps/
categories:
  - OMS
  - SCOM
tags:
  - OMS
  - SCOM
---
<a href="http://blog.tyang.org/wp-content/uploads/2015/10/image19.png"><img style="background-image: none; float: left; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/10/image_thumb13.png" alt="image" width="124" height="244" align="left" border="0" /></a>

Last year, my friends Cameron Fuller and Blake Wilson from Catapult Systems have written number of posts on "Taking my OpsMgr with me" (<a href="http://blogs.catapultsystems.com/cfuller/archive/2014/02/28/taking-my-opsmgr-with-me-with-live-maps/">Part 1</a>, <a href="http://blogs.catapultsystems.com/cfuller/archive/2014/02/26/taking-my-opsmgr-with-me-with-my-operations/">Part 2</a>, <a href="http://blogs.catapultsystems.com/bwilson/archive/2014/03/31/opsmgr-2012-dashboards-using-squaredup/">Part 3</a>, <a href="http://blogs.catapultsystems.com/cfuller/archive/2014/02/20/taking-my-opsmgr-with-me-with-xian-wings/">Part 4</a>, <a href="http://blogs.catapultsystems.com/cfuller/archive/2014/04/11/taking-my-opsmgr-with-me-wrap-up/">Part 5</a>). In their blog post series, Cameron and Blake have demonstrated multiple ways of accessing your OpsMgr data from mobile devices via number of 3rd party applications such as Xian Wings, Squared Up, Savision Live Maps, etc.

With the <a href="http://blogs.technet.com/b/momteam/archive/2015/10/21/log-analytics-on-the-move.aspx">recent release</a> of Microsoft Operations Management Suite (OMS) Android and iOS apps, the OMS mobile apps would be another good option when you need to access your OpsMgr data on your mobile devices.

As we know, we normally categorise OpsMgr data into the following areas:
<ul>
	<li>Alert Data</li>
	<li>Event Data</li>
	<li>Performance Data</li>
	<li>State Data</li>
	<li>Managed Entity Data</li>
</ul>
Once you have connected your OpsMgr management groups to your OMS workspace, with some additional configuration （i.e. configuring collections for log and Near Real-Time Perf data, enabling Alert Management and Capacity Planning solutions, etc.), we can easily access Alert data, Event data and Performance data from OMS. Unlike OpsMgr, since OMS does not implement object health model (monitoring classes and relationships), the State data and Managed Entity data has become irrelevant in this case.

In this post, I will show you some sample search queries and dashboards I have developed in my lab, and what these dashboards look like in the OMS Android app (from my Samsung Note 3 mobile phone).

First of all, OMS already comes with some useful built-in dashboards:

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/image20.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/10/image_thumb14.png" alt="image" width="149" height="294" border="0" /></a><a href="http://blog.tyang.org/wp-content/uploads/2015/10/image21.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/10/image_thumb15.png" alt="image" width="148" height="293" border="0" /></a><a href="http://blog.tyang.org/wp-content/uploads/2015/10/image22.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/10/image_thumb16.png" alt="image" width="149" height="294" border="0" /></a>

These built-in dashboards covered top level overview of alert data, perf data, event data, configuration changes data ,etc. Which are good starting point for you to drill down by tapping (or clicking) the dashboard tiles. i.e. the drill down from the "Alert raised during the past 1 day grouped by severity" tile:

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/image23.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/10/image_thumb17.png" alt="image" width="154" height="305" border="0" /></a>

I also managed to produced the following Saved Searches and then pined them on the dashboard:

### OpsMgr Management Server Heartbeat Event For the Last 15 Minutes

Using the OMS Add-On MP from version 2.5 of the <a href="http://blog.tyang.org/2015/09/16/opsmgr-self-maintenance-management-pack-2-5-0-0/">OpsMgr Self Maintenance MP</a>, I configured management servers to send heartbeat events to OMS every 5 minutes. The search query for this dashboard tile is:

<strong><em>Type=Event Source=OMSHeartbeat Computer=OMMS01 TimeGenerated&gt;NOW-15MINUTE | measure count() by TimeGenerated</em></strong>

I also configured a threshold that would hightlight when the value is under 3:

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/image24.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; margin: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/10/image_thumb18.png" alt="image" width="160" height="244" border="0" /></a>

As you can see, this dashboard tile has also changed colour in the OMS Android app just like the full blown web console:

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/SNAGHTMLa66124b.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLa66124b" src="http://blog.tyang.org/wp-content/uploads/2015/10/SNAGHTMLa66124b_thumb.png" alt="SNAGHTMLa66124b" width="154" height="304" border="0" /></a>

### Top 3 OpsMgr Offenders for the Last 24 Hours

In OpsMgr, we would often interested in finding out which monitoring objects has generated the most of the alerts. This can be easily achieved using a very simple search query in OMS:

<strong><em>Type=Alert AlertState=New TimeGenerated&gt;NOW-24HOURS | measure count() by SourceFullName | Top 3</em></strong>

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/SNAGHTMLa690c51.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLa690c51" src="http://blog.tyang.org/wp-content/uploads/2015/10/SNAGHTMLa690c51_thumb.png" alt="SNAGHTMLa690c51" width="160" height="316" border="0" /></a>

From this tile, I can see that most of the alerts generated in my management groups are Office 365 related.

### Error Events from the "Operations Manager" Event Log for the Last 24 Hours

If I want to see how many error events have been generated in the "Operations Manager" log on all the computers managed by OMS, I can use a query like this one:

<strong><em>Type=Event EventLevelName=error EventLog="Operations Manager" TimeGenerated&gt;NOW-24HOURS</em></strong>

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/SNAGHTMLa6db2bf.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLa6db2bf" src="http://blog.tyang.org/wp-content/uploads/2015/10/SNAGHTMLa6db2bf_thumb.png" alt="SNAGHTMLa6db2bf" width="154" height="304" border="0" /></a>

From this tile, I can then drill down by tapping the dashboard tile

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/image25.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/10/image_thumb19.png" alt="image" width="153" height="302" border="0" /></a><a href="http://blog.tyang.org/wp-content/uploads/2015/10/image26.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/10/image_thumb20.png" alt="image" width="152" height="299" border="0" /></a>

<strong>Note:</strong>

from this tile, you may have noticed there are only few bars for the recent time frames. this is because I have specified the query only return the events generated from the last 24 hours and the default time range for the OMS app is the last 7 days:

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/image27.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/10/image_thumb21.png" alt="image" width="142" height="279" border="0" /></a>

### Hyper-V Hosts Available Memory

Once you have configured the pre-requisites and enabled the Capacity Planning solution in OMS, this solution will start collecting various performance counters from your VMM managed Hyper-V hosts. The performance data collected by this solution is stored as hourly aggregated perf data (Type=PerfHourly). Therefore, we are able to get some common perf counters such as Memory Availability MBytes using a simple query like this:

<strong><em>Type=PerfHourly CounterName="Available MBytes" |Measure Avg(SampleValue) AS AVGMemory by Computer | sort AVGMemory</em></strong>

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/SNAGHTMLa6ffb09.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLa6ffb09" src="http://blog.tyang.org/wp-content/uploads/2015/10/SNAGHTMLa6ffb09_thumb.png" alt="SNAGHTMLa6ffb09" width="152" height="301" border="0" /></a>

And you can drill down from this tile:

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/image28.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/10/image_thumb22.png" alt="image" width="155" height="305" border="0" /></a>

From here, I can see in my lab, a Hyper-V host running on an Intel NUC has the least amount of available memory.

In my opinion, using the OMS mobile app has the following advantages comparing to the various mobile apps for OpsMgr:

### Support for multiple management groups and stand alone agents

Since you can connect multiple OpsMgr management groups into a single OMS workspace, and you are also able to connect standalone computers directly to OMS, the data returned from your search queries are consolidated among all data sources, not just one single management group.

### Cloud Based Solution

Since OpsMgr is primarily designed to monitor your on-prem infrastructure, generally your OpsMgr infrastructure would be place somewhere in you on-prem data centre. Therefore in order to access your OpsMgr data via a mobile app remotely, you’d either need to connect to your corporate network via VPN, or your network team would need to create some kind of reverse proxy tunnel for you to access your OpsMgr web based portal (such as Squared Up) from the internet. This adds additional complexity in your solution. By using the OMS mobile apps, since the data is hosted on Azure, you do not need any kind of connectivity between your mobile device and your on-prem data centres.

My fellow CDM MVP Steve Buchanan has also written an awesome overview for the Android app few days ago, you can read Steve’s post here: <a title="http://www.buchatech.com/2015/10/unpacking-the-operations-management-suite-android-app/" href="http://www.buchatech.com/2015/10/unpacking-the-operations-management-suite-android-app/">http://www.buchatech.com/2015/10/unpacking-the-operations-management-suite-android-app/</a>

Cameron has also just posted his experience with the iOS app on iPad on his blog: <a href="http://blogs.catapultsystems.com/cfuller/archive/2015/10/21/the-microsoft-oms-experience-on-an-ipad/">http://blogs.catapultsystems.com/cfuller/archive/2015/10/21/the-microsoft-oms-experience-on-an-ipad/</a>

Lastly, I recommend you to give the OMS mobile apps a try, they are currently available on all 3 platforms (Windows Phone, Android and iOS). If you do have your OpsMgr management groups connected to OMS, this app could come very handy <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" src="http://blog.tyang.org/wp-content/uploads/2015/10/wlEmoticon-smile.png" alt="Smile" />.