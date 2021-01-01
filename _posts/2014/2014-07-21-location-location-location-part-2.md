---
id: 2984
title: Location, Location, Location. Part 2
date: 2014-07-21T01:55:48+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=2984
permalink: /2014/07/21/location-location-location-part-2/
categories:
  - SCOM
tags:
  - Dashboard
  - MP Authoring
  - SCOM
---
<a href="http://blog.tyang.org/wp-content/uploads/2014/07/mia.jpg"><img style="background-image: none; float: left; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="mia" src="http://blog.tyang.org/wp-content/uploads/2014/07/mia_thumb.jpg" alt="mia" width="244" height="202" align="left" border="0" /></a>This is the 2nd part of the 3-part series. In this post, I will demonstrate how do I monitor the physical location of my location aware devices (Windows 8 tablets and laptops). To do so, I created a monitor which generates alerts when a device has gone beyond allowed distance from its home location. I will now go through each the component in the management pack that I created to achieve this goal.
<h3>Custom Class: Location Aware Windows Client Computer</h3>
I created a custom class based on "Windows Client 8 Computer" class. I needed to create this class instead of just using existing Windows Client 8 Computer class because I need to store 2 additional property values: "Home Latitude" and "Home Longitude". Once been discovered, these 2 values will be passed to the monitor workflow so the script within the monitor can calculate the distance between current location and configured home location.

<a href="http://blog.tyang.org/wp-content/uploads/2014/07/image12.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/07/image_thumb12.png" alt="image" width="507" height="406" border="0" /></a>

I created the following registry keys and values for this custom class:

Key: <strong>HKLM\SOFTWARE\TYANG\MonitorLocation</strong>

REG_SZ values: <strong>HomeLatitude</strong> & <strong>HomeLongitude</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2014/07/image13.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/07/image_thumb13.png" alt="image" width="522" height="274" border="0" /></a>
<h3>Discovery</h3>
I created a registry discovery targeting Windows Client 8 Computer class to discover the class (Location Aware Windows Client Computer) and the 2 properties I defined.

<a href="http://blog.tyang.org/wp-content/uploads/2014/07/image14.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/07/image_thumb14.png" alt="image" width="401" height="403" border="0" /></a>

It is configured to run every 6 hours by default. This can be overridden.
<h3>Location Aware Device Missing In Action Monitor</h3>
<a href="http://blog.tyang.org/wp-content/uploads/2014/07/image15.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/07/image_thumb15.png" alt="image" width="484" height="473" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2014/07/image16.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/07/image_thumb16.png" alt="image" width="484" height="559" border="0" /></a>

To create this monitor, I firstly wrote a script to detect the current location and calculate the distance between the current location and home location (based on the registry value discovered).

<strong><span style="color: #ff0000;">Note:</span></strong> I managed to find few PowerShell scripts to calculate distance between 2 map coordinates (i.e. <a title="http://poshcode.org/2591" href="http://poshcode.org/2591">http://poshcode.org/2591</a> and <a title="http://stackoverflow.com/questions/365826/calculate-distance-between-2-gps-coordinates" href="http://stackoverflow.com/questions/365826/calculate-distance-between-2-gps-coordinates">http://stackoverflow.com/questions/365826/calculate-distance-between-2-gps-coordinates</a>). However, I believe all the examples I found are not calculating the distance correctly. For example, I know for fact that the direct distance between my home to my office is somewhere between 23 – 25 kilometres. Using both of these scripts I mentioned, the calculated distance is around 16 kilometres. It is too short to be considered being correct. In the end, I found a <a href="http://www.unix.com/shell-programming-and-scripting/134380-calculating-distance-between-two-lat-long-coordinates.html">VBScript from a Unix forum</a>. The result from this script is just over 23km, which also matches the result from this <a href="http://boulter.com/gps/distance/">online calculator</a>. Therefore, I converted this VBScript into PowerShell and used it in this management pack. As I am really bad at math, I didn’t bother looking into the differences between these scripts. It is beyond my ability.

When the script runs, it logs an informational event (event ID 10003) if the current location is successfully detected:

<a href="http://blog.tyang.org/wp-content/uploads/2014/07/SNAGHTMLb37b568.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="SNAGHTMLb37b568" src="http://blog.tyang.org/wp-content/uploads/2014/07/SNAGHTMLb37b568_thumb.png" alt="SNAGHTMLb37b568" width="476" height="238" border="0" /></a>

Or a warning event (event ID 10002) if the location data retrieved is not valid.

I then created Probe Action, Data Source modules and monitor type for this monitor. – All just usual drill, I won’t go through the details here.

As I have shown in the 1st and 2nd screenshots, I have configured required registry keys and values on my wife’s Dell XPS ultrabook (running Windows 8.1). The Home Latitude and Longitude coordinates are the location of my office. Because I configured the warning threshold to 5,000 metres (5km) and critical threshold to 10,000 metres (10km), a critical alert was generated against this XPS laptop:

<a href="http://blog.tyang.org/wp-content/uploads/2014/07/SNAGHTMLb381a0e.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="SNAGHTMLb381a0e" src="http://blog.tyang.org/wp-content/uploads/2014/07/SNAGHTMLb381a0e_thumb.png" alt="SNAGHTMLb381a0e" width="580" height="263" border="0" /></a>

For my Surface Pro 2, I configured the home location to be my home, therefore, currently as I’m home writing this blog post and it is right next to me, the health state for my Surface is healthy:

<a href="http://blog.tyang.org/wp-content/uploads/2014/07/SNAGHTMLb3e690c.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="SNAGHTMLb3e690c" src="http://blog.tyang.org/wp-content/uploads/2014/07/SNAGHTMLb3e690c_thumb.png" alt="SNAGHTMLb3e690c" width="580" height="422" border="0" /></a>

This concludes the 2nd part of the series. Please continue to <a href="http://blog.tyang.org/2014/07/21/location-location-location-part-3/">Part 3</a>.