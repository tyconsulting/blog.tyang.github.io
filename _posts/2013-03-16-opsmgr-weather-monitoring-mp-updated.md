---
id: 1792
title: OpsMgr Weather Monitoring MP Updated
date: 2013-03-16T21:06:33+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=1792
permalink: /2013/03/16/opsmgr-weather-monitoring-mp-updated/
categories:
  - SCOM
tags:
  - Management Pack
  - MP Authoring
  - SCOM
---
I got an email from someone up in Sweden the other day in regards to the <a href="http://blog.tyang.org/2012/10/25/monitoring-weather-conditions-using-scom/">Weather Monitoring MP</a> that I released few months ago. I’ve been made aware that a negative temperature reading is being recorded as a positive value (i.e. –8 degrees is being collected as 8 degrees).

First of all, apologies for this mistake. I wrote the PowerShell script for the probe action module back in July last year, when most of world was in summer. I didn’t even think about negative values and I couldn’t test it anyway…

Last night, I spent some time fixing the management pack. As I was fixing the code, I also found few other issues due to in consistencies in <a href="http://www.webservicex.net">www.webservicex.net</a> (where the MP is getting the data from). for example, some locations have decimal points in temperature value (i.e. Vancouver, Canada), some locations have multiple &lt;Wind&gt; tags in the return data, etc. oh well, webservicex is a free service so there’s no point bagging them for inconsistencies.

Below is a list of bugs that are fixed in this release (1.0.1.0):
<ul>
	<li>Incorrect temperature collected when the reading is below zero</li>
	<li>Incorrect temperature collected when the reading contains decimal points</li>
	<li>script error when pressure reading is not within &lt;pressure&gt; tag (i.e. Vancouver, Canada uses &lt;PressureTendency&gt; tag). in this situation, pressure reading is not probed.</li>
	<li>fixed wind direction and speed probe when there are multiple &lt;Wind&gt; tags in the result.</li>
	<li>Agent task not displaying wind speed in KM/H</li>
	<li>Updated temperature related performance views to display negative temperature readings.</li>
</ul>
<strong><span style="color: #ff0000;">Note:</span></strong>

I’ve updated below 4 temperature related performance views so they can display negative values:

<a href="http://blog.tyang.org/wp-content/uploads/2013/03/image16.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/03/image_thumb15.png" width="270" height="199" border="0" /></a>

The Y-Axis range is set to –130 to 134 (degrees) for Imperial Unit (Fahrenheit) and –90 to 57 (degrees) for Metric Unit (Celsius). According to <a href="http://en.wikipedia.org/wiki/List_of_weather_records">Wikipedia</a>, these figures are the highest and lowest temperature ever recorded on this plant. They can be customised by right clicking the view and choose “Personalize view…”:

<a href="http://blog.tyang.org/wp-content/uploads/2013/03/image17.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/03/image_thumb16.png" width="530" height="289" border="0" /></a>

the updated MP can be downloaded <a href="http://blog.tyang.org/wp-content/uploads/2013/03/TYANG.Weather.Monitoring.v1.0.1.0.zip">HERE</a>. The download link from the <a href="http://blog.tyang.org/2012/10/25/monitoring-weather-conditions-using-scom/">original post</a> is also updated.