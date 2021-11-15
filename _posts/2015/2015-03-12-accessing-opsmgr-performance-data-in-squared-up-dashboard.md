---
id: 3826
title: Accessing OpsMgr Performance Data in Squared Up Dashboard
date: 2015-03-12T20:46:47+10:00
author: Tao Yang
#layout: post
excerpt: ""
header:
  overlay_image: /wp-content/uploads/2015/03/squaredup.jpg
  overlay_filter: 0.5 # same as adding an opacity of 0.5 to a black background
guid: https://blog.tyang.org/?p=3826
permalink: /2015/03/12/accessing-opsmgr-performance-data-in-squared-up-dashboard/
categories:
  - SCOM
tags:
  - SCOM
  - SquaredUp
---
<span style="color: #ff0000;">13/03/2015 Update: Correction after feedback from Squared Up, Squared Up does not read perf data from Operational DB. Thus this post is updated with the correct information.</span>

Yesterday, my friend and fellow SCCDM MVP <a href="https://twitter.com/cfullerMVP">Cameron Fuller</a> has posted a good article explaining the differences between performance view and performance widget in OpsMgr. If you haven’t read it, please read it first from here: <a href="http://blogs.catapultsystems.com/cfuller/archive/2015/03/11/world-war-widget-the-performance-view-vs-the-performance-widget.aspx">World War Widget: The performance view vs the performance widget</a> and come back to this article.

As Cameron explained, performance views read data from the operational DB and you can access the most recent short term data. The performance widgets read data from the Data Warehouse DB and you are able to access the long term historical data this way.

I’d also like to throw a 3rd option into the mix, however, this is not something native in OpsMgr, but it is via the 3rd party dashboard Squared Up.

To be honest, Access Performance data must be my most favourite feature in Squared Up. In this post, I will show off few features related to this topic in the Squared Up console.

**01. Automatically Switch Between Data Sets**

Since all performance collection rules write performance data into both databases, Squared Up only reads performance data from Data Warehouse DB. When accessing the performance data in Squared Up, as long as you have already established Data Warehouse DB connection, Squared Up will automatically detect the best aggregation set for the performance data. You can access both long term and short term data from a single view:

<a href="https://blog.tyang.org/wp-content/uploads/2015/03/image17.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/03/image_thumb17.png" alt="image" width="657" height="205" border="0" /></a>

As shown above, the default period is 12 hours, the data displayed is the raw performance data (not aggregated), if I change the period to last 30 days, notice the performance counter name is also updated with "(hourly)" at the end – this means this graph is now based on the hourly aggregate dataset:

<a href="https://blog.tyang.org/wp-content/uploads/2015/03/image18.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/03/image_thumb18.png" alt="image" width="656" height="194" border="0" /></a>

If I change the period again, this time, I select "all", as shown below, it is showing about a year’s worth of data, and it has automatically switched to the daily aggregate dataset:

<a href="https://blog.tyang.org/wp-content/uploads/2015/03/image19.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/03/image_thumb19.png" alt="image" width="659" height="195" border="0" /></a>

**02. Accessing the numeric value from the graph**

Other than being able to auto detect and switch to the more appropriate data source and data set, if you move the cursor to any point on the graph, you will be able to read the exact figure at that point of time:

<a href="https://blog.tyang.org/wp-content/uploads/2015/03/image20.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/03/image_thumb20.png" alt="image" width="667" height="192" border="0" /></a>

**03. Selecting a Period from the graph:**

You can also highlight a period from the graph, and Squared Up will update the graph to only display the period you’ve just highlighted:

<a href="https://blog.tyang.org/wp-content/uploads/2015/03/image21.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/03/image_thumb21.png" alt="image" width="664" height="202" border="0" /></a>

<a href="https://blog.tyang.org/wp-content/uploads/2015/03/image22.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/03/image_thumb22.png" alt="image" width="668" height="195" border="0" /></a>

**04. Exporting Performance Data to Excel**

You can also export the data to Excel using the export button on the top right hand side of the page.

<a href="https://blog.tyang.org/wp-content/uploads/2015/03/image23.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/03/image_thumb23.png" alt="image" width="665" height="343" border="0" /></a>

When you open the exported Excel document, you’ll see 2 tabs – one for the numeric data on a table, one for the graph itself:

<a href="https://blog.tyang.org/wp-content/uploads/2015/03/SNAGHTML3db0931b.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML3db0931b" src="https://blog.tyang.org/wp-content/uploads/2015/03/SNAGHTML3db0931b_thumb.png" alt="SNAGHTML3db0931b" width="489" height="444" border="0" /></a>

<a href="https://blog.tyang.org/wp-content/uploads/2015/03/SNAGHTML3db16d20.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML3db16d20" src="https://blog.tyang.org/wp-content/uploads/2015/03/SNAGHTML3db16d20_thumb.png" alt="SNAGHTML3db16d20" width="579" height="321" border="0" /></a>



**Conclusion**

This is all based on my own experience, just my 2 cents on the topic that Cameron has started. I think it would be good to also show the community what a 3rd party product can do in addition to the native capabilities.

If you haven’t played with Squared Up before, I strongly recommend you to go take a look: <a href="http://www.squaredup.com">http://www.squaredup.com</a>, you can access the online demo from their website too. They also have few demo videos that you can watch: <a title="http://squaredup.com/resources/videos/" href="http://squaredup.com/resources/videos/">http://squaredup.com/resources/videos/</a>

Lastly, please feel free to drop me an email if you want to carry on this discussion.