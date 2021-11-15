---
id: 1596
title: 'Monitoring Weather Conditions &ndash; Using SCOM'
date: 2012-10-25T22:36:38+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=1596
permalink: /2012/10/25/monitoring-weather-conditions-using-scom/
categories:
  - SCOM
tags:
  - Featured
  - MP Authoring
  - SCOM
---
<strong><a href="https://blog.tyang.org/wp-content/uploads/2012/10/sysctr.png"><img class="alignleft  wp-image-1598" title="sysctr" alt="" src="https://blog.tyang.org/wp-content/uploads/2012/10/sysctr-281x300.png" width="197" height="210" /></a></strong>

<strong><span style="color: #993300;">16-03-2013:</span></strong> This MP has been updated. the download link in this article has been updated. Details of the update can be found <a href="https://blog.tyang.org/2013/03/16/opsmgr-weather-monitoring-mp-updated/">here</a>.

<strong>Background</strong>

Back in July this year, one day I was playing with PowerShell and discovered using New-WebProxyService to get various information from <a href="http://www.webservicex.net">http://www.webservicex.net</a>. I then had an idea to write a SCOM management pack to monitor weather conditions for cities around the world using the weather data from <a href="http://www.webservicex.net">www.webservicex.net</a>. And after I started writing it, I realised this idea wasn’t new. Pete Zerger has already blogged about it 2 years ago <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" alt="Smile" src="https://blog.tyang.org/wp-content/uploads/2012/10/wlEmoticon-smile1.png" />:

<a href="http://www.systemcentercentral.com/BlogDetails/tabid/143/IndexID/82997/Default.aspx">OpsMgr: Probing a Web Service with with PowerShell 2.0 in a Two-State Monitor</a>

Anyways, I still went ahead and continued working on this management pack during my spare time. Initially, I’ve developed 2 methods in the MP, one using <a href="http://www.webservicex.net">www.webservicex.net</a> and another one using the famous Google weather API. I then got side-tracked and stopped the development for couple of months. Couple of weeks ago, I’ve started working on it again. But this time, I just realised Google actually shut down the weather api:

<a href="https://blog.tyang.org/wp-content/uploads/2012/10/image23.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2012/10/image_thumb23.png" width="531" height="230" border="0" /></a>

So I’ve completely removed Google Weather API functions from the MP and concentrated on the other method: using <a href="http://www.webservicex.net">www.webservicex.net</a>

Now, I finally completed the first release of the management pack. And I’m going to go through details of this MP now.

<strong>Introduction</strong>

The "TYANG Weather Monitoring" management pack provides ability to monitor weather conditions and collect real time weather information for configured cities and locations. It utilise Windows PowerShell v2.0 to retrieve weather information from <a href="http://www.webservicex.net">http://www.webservicex.net</a>

This management pack provides:
<ul>
	<li>Various 3-state threshold monitors for weather readings such as temperature Celsius, temperature Fahrenheit, wind speed km/h, wind speed mile/h, etc.</li>
	<li>Performance collection rules to collect temperature, wind speed, relative humidity %, air pressure, dew point as performance data for each configured location</li>
	<li>Collect weather summary report as event data</li>
	<li>Alert generating rule to generate information alert when your favourite weather condition has detected for configured locations.</li>
	<li>Weather summary reports</li>
	<li>Ability to configure the weather probing node to use Metric or Imperial measuring units (or both) so only desired counters are collected for particular locations.</li>
</ul>
<strong>Pre-Requisites:</strong>
<ul>
	<li>SCOM agent is installed on all computers acting as weather probe computers.</li>
	<li>PowerShell version 2.0 (or 3.0) on all weather probe computers.</li>
	<li>Appropriate PowerShell execution policy to allow script executions.</li>
	<li>Internet Connection that allows connection to <a href="http://www.webservicex.net">http://www.webservicex.net</a></li>
</ul>
<strong>Object Model:</strong>

<a href="https://blog.tyang.org/wp-content/uploads/2012/10/object.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="object" alt="object" src="https://blog.tyang.org/wp-content/uploads/2012/10/object_thumb.png" width="495" height="409" border="0" /></a>

I’ve designed the object model this way so in the future I can add other web services providers to the MP (i.e. I know that Weather Bug provides an awesome weather API.)

<strong>What Does This MP Offer?</strong>

<strong>Performance Collection Rules:</strong>

Various performance collections to collect the following weather information:
<ul>
	<li>Dew.Point (Fahrenheit)</li>
	<li>Dew.Point (Celsius)</li>
	<li>Temperature (Fahrenheit)</li>
	<li>Temperature (Celsius)</li>
	<li>Wind Speed (Mph)</li>
	<li>Wind Speed (KMph)</li>
	<li>% Relative Humidity</li>
	<li>Pressure (hPa)</li>
	<li>Pressure (In. Hg)</li>
</ul>
The data collected by these rules are viewable via various built-in performance views in the MP and also via the performance reports from the SCOM Generic report library.

Examples:

Melbourne’s temperature for the last 24 hours:

<a href="https://blog.tyang.org/wp-content/uploads/2012/10/image24.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2012/10/image_thumb24.png" width="576" height="509" border="0" /></a>

New York City’s Wind Speed (in m/h) over the last 24 hours:

<a href="https://blog.tyang.org/wp-content/uploads/2012/10/image25.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2012/10/image_thumb25.png" width="576" height="549" border="0" /></a>

% Relative Humidity for Sydney over last 24 hours:

<a href="https://blog.tyang.org/wp-content/uploads/2012/10/image26.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2012/10/image_thumb26.png" width="580" height="484" border="0" /></a>

<strong>Event Collection Rule:</strong>

One event collection rule to collect weather summary for each location as event data.

The data is viewable via the built-in "Weahter Summary (Last 7 Days)" event view or via reports:

<a href="https://blog.tyang.org/wp-content/uploads/2012/10/image27.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2012/10/image_thumb27.png" width="528" height="395" border="0" /></a>

<strong>Alert Generating Rule:</strong>

One alert generating rule was created to run once a day and it detects a desired weather condition (based on sky conditions, wind speed and temperature range). It generates an information alert when desired weather condition is detected:
<ul>
	<li>TYANG Weather WebServiceX Probe Good Weather Condition Detection Rule</li>
</ul>
i.e. The "Good Weather" alert generated for Brisbane, Australia:

<a href="https://blog.tyang.org/wp-content/uploads/2012/10/image28.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2012/10/image_thumb28.png" width="580" height="266" border="0" /></a>

The purpose of this rule is to demonstrate how to alert on certain weather conditions. It is configured to run daily at 7:00 am(RMS local time) for all probe locations. Even though it utilise Cook Down feature and the data source module only run once for all locations in one country, you may choose to disable it and only enable it for a subset of probe locations. You may also use this rule as an example to build your own workflow. The data source for this rule is made public so you can reference it from other MPs.

Imagine setting up an email alert subscription for this alert for the city you live to email your boss telling him you are sick and won’t come in when a good weather is detected in the morning? <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" alt="Smile" src="https://blog.tyang.org/wp-content/uploads/2012/10/wlEmoticon-smile1.png" />

<strong>Monitors:</strong>

This MP also comes with various 3-state threshold monitors to generate alert when:
<ul>
	<li>Temperature is too low (too cold)</li>
	<li>Temperature is too high (too hot)</li>
	<li>Wind speed is too high (too windy)</li>
</ul>
Examples:

Critical Low Temperature (Fahrenheit) alert for New York City, USA:

<a href="https://blog.tyang.org/wp-content/uploads/2012/10/image29.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2012/10/image_thumb29.png" width="580" height="477" border="0" /></a>

Warning High Temperature (Celsius) alert for Guangzhou, China:

<a href="https://blog.tyang.org/wp-content/uploads/2012/10/image30.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2012/10/image_thumb30.png" width="580" height="479" border="0" /></a>

<strong>Reports:</strong>

I’ve also written 2 reports in this management pack:
<ul>
	<li>latest Weather Summary By Location
<ul>
	<li>the latest weather summary collected for a selected location</li>
</ul>
</li>
</ul>
<a href="https://blog.tyang.org/wp-content/uploads/2012/10/image31.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2012/10/image_thumb31.png" width="473" height="401" border="0" /></a>

<a href="https://blog.tyang.org/wp-content/uploads/2012/10/image32.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2012/10/image_thumb32.png" width="580" height="376" border="0" /></a>
<ul>
	<li>Weather Summary By Location
<ul>
	<li>All the weather summary events for a selected location during a selected time frame</li>
</ul>
</li>
</ul>
<a href="https://blog.tyang.org/wp-content/uploads/2012/10/image33.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2012/10/image_thumb33.png" width="580" height="254" border="0" /></a>

<a href="https://blog.tyang.org/wp-content/uploads/2012/10/image34.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2012/10/image_thumb34.png" width="580" height="566" border="0" /></a>

<strong>Views:</strong>

Several views are configured in the management pack:

<a href="https://blog.tyang.org/wp-content/uploads/2012/10/image35.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2012/10/image_thumb35.png" width="424" height="410" border="0" /></a>

Example:

State View for all Probe Locations:

<a href="https://blog.tyang.org/wp-content/uploads/2012/10/image36.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2012/10/image_thumb36.png" width="580" height="515" border="0" /></a>

<strong>Agent Task:</strong>

An agent task called "<strong>Check Current Weather</strong>" is configured for <strong>WebServiceX Weather Probe Location</strong> class. You may run this manually to get the latest weather summary for a particular probe location:

<a href="https://blog.tyang.org/wp-content/uploads/2012/10/image37.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2012/10/image_thumb37.png" width="480" height="559" border="0" /></a>

<strong>Cook Down</strong>

I spent a lot of time to optimise workflows in this MP by fully utilise cook down. All the rules and monitors in this MP run on a schedule. They all use the same data source module. Except the alert generating rule, the PowerShell script inside the data source module only run once for each country in each probe node and feeds the data to all the performance collection rules, the event collection rule and all the monitors. When the data source runs, it creates a log entry in the Operations Manager log with <strong>Event ID 10000</strong>.

i.e. In my test environment, I have a computer configured as a probe node for 2 countries: Australia and China. Each country contains multiple cities.

The data source runs twice every 30 minutes (one for each country):

<a href="https://blog.tyang.org/wp-content/uploads/2012/10/image38.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2012/10/image_thumb38.png" width="506" height="506" border="0" /></a>

Therefore, if you wish to change the schedule (i.e. configure SyncTime or increase/decrease how frequent a workflow runs), I recommend you to change the schedule for ALL the rules and monitors to fully utilise cook down.

This shared data source module is called "TYANG Weather WebServiceX Probe Details by City and Country Data Source", it has been made public and you can use this in other MPs.

<strong><span style="color: #ff0000;">Note:</span> </strong>Even though the "WeatherStation" input parameter for this data source is different for each probe location, this data source contains another data source member module which retrieves weather information for ALL configured weather locations of this country. The "WeatherStation" input parameter is used in a condition detection member module inside the data source to filter the data for this specific probe location.

<strong>Known Issues</strong>
<ul>
	<li>Incorrect Event Descriptions are displayed in the <strong>Weather Summary (last 7 Days)</strong> Event View:</li>
</ul>
<a href="https://blog.tyang.org/wp-content/uploads/2012/10/image39.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2012/10/image_thumb39.png" width="580" height="366" border="0" /></a>
<ul>
<ul>
	<li>Apparently this is a known issue (in both SCOM 2007 and 2012 Operations Console). The data is stored correct in the data base. It’s just they are displayed incorrectly in the console.</li>
</ul>
	<li>This management pack MAY not work when the probe node computers require to use Proxy server to get to the Internet as the PowerShell Cmdlet <strong>New-WebServiceProxy</strong> does not support using Proxy servers. In the future, when I get more time, I might look at other ways to overcome this issue, but at this stage, I can’t really afford to spend more time on this.</li>
</ul>
<strong>Limitations:</strong>

<a href="http://www.WebserviceX.net">www.WebserviceX.net</a> only provides current weather information for cities outside of USA. It does not provide forecast information for places outside of USA. This is why I’m very disappointed that Google no longer provides the free weather API as it provided 5-day forecast and there are a lot more weather stations in the Google weather API than webservicex.net. I might choose another weather API in the future to further enhance this MP.

<strong>Download:</strong>

You can download both sealed and unsealed MP from below link along with a PDF documentation and few sample .reg files to help you configure the probe nodes and locations.

<a href="https://blog.tyang.org/wp-content/uploads/2013/03/TYANG.Weather.Monitoring.v1.0.1.0.zip">DOWNLOAD HERE</a>.