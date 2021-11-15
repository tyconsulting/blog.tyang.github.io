---
id: 5599
title: OMS Network Performance Monitor Power BI Report
date: 2016-08-22T23:27:45+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=5599
permalink: /2016/08/22/oms-network-performance-monitor-power-bi-report/
categories:
  - OMS
  - Power BI
tags:
  - OMS
  - Power BI
---
<a href="https://blog.tyang.org/wp-content/uploads/2016/08/image-42.png"><img style="background-image: none; float: left; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/08/image_thumb-42.png" alt="image" width="151" height="143" align="left" border="0" /></a>I’ve been playing with the OMS Network Performance Monitor (NPM) today. Earlier today, I’ve released an OpsMgr MP that contains tasks to configure MMA agent for NPM. You can find the post here: <a title="https://blog.tyang.org/2016/08/22/opsmgr-agent-task-to-configure-oms-network-performance-monitor-agents/" href="https://blog.tyang.org/2016/08/22/opsmgr-agent-task-to-configure-oms-network-performance-monitor-agents/">https://blog.tyang.org/2016/08/22/opsmgr-agent-task-to-configure-oms-network-performance-monitor-agents/</a>

The other thing I wanted to do is to create a Power BI dashboard for the data collected by OMS NPM solution. The data collected by NPM can be retrieved using OMS search query "**Type=NetworkMonitoring**".

To begin my experiment, I created a Power BI schedule in OMS using above mentioned query and waited a while for the data to populate in Power BI

<a href="https://blog.tyang.org/wp-content/uploads/2016/08/image-43.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/08/image_thumb-43.png" alt="image" width="375" height="171" border="0" /></a>

I then used 2 custom visuals from the <a href="https://app.powerbi.com/visuals/">Power BI Custom Visual Gallery</a>:

01. Force-Directed Graph

<a href="https://blog.tyang.org/wp-content/uploads/2016/08/image-44.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/08/image_thumb-44.png" alt="image" width="154" height="151" border="0" /></a>

{:start="2"}
02. Timeline

<a href="https://blog.tyang.org/wp-content/uploads/2016/08/image-45.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/08/image_thumb-45.png" alt="image" width="155" height="151" border="0" /></a>

and I created an interactive report that displays the network topology based on the NPM data:

<a href="https://blog.tyang.org/wp-content/uploads/2016/08/image-46.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/08/image_thumb-46.png" alt="image" width="704" height="397" border="0" /></a>

In this report, I’m using a built-in slicer (top left) visual to filter source computers and the timeline visual (bottom) to filter time windows. The main section (top right) consists of a Force-Directed Graph visual, which is used to draw the network topology diagram.

I can choose one or more source computers from the slicer, and choose a time window from the timeline visual located at the bottom.

On the network topology (Force-Directed Graph visual), the arrow represents the direction of the traffic, thickness represents the median network latency (thicker = higher latency), and the link colour represents the network loss health state determined by the OMS NPM solution (LossHealthState).

I will now explain the steps I’ve taken to create this Power BI report:

1. Create a blank report based on the OMS NPM dataset (that you’ve created from the OMS portal earlier).

2. Create a Page Level Filter based on the SubType Field, and only select "NetworkPath".

<a href="https://blog.tyang.org/wp-content/uploads/2016/08/image-47.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/08/image_thumb-47.png" alt="image" width="158" height="325" border="0" /></a>

{:start="3"}
3. Add the Slicer visual to the top left and configure it as shown below:

<a href="https://blog.tyang.org/wp-content/uploads/2016/08/image-48.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/08/image_thumb-48.png" alt="image" width="150" height="297" border="0" /></a>

<a href="https://blog.tyang.org/wp-content/uploads/2016/08/image-49.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/08/image_thumb-49.png" alt="image" width="152" height="389" border="0" /></a>

{:start="4"}
4. Add the Force-Directed Graph (ForceGraph) to the main section of the report (top right), and configure it as shown below:

Fields tab:

 * Source – SourceNetworkNodeInterface
 * Target – DestinationNetworkNodeInterface
 * Weight – Average of MedianLatency
 * Link Type – LossHealthState

<a href="https://blog.tyang.org/wp-content/uploads/2016/08/image-50.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/08/image_thumb-50.png" alt="image" width="171" height="365" border="0" /></a>

Format tab:

 * Data labels – On
 * Links
   * Arrow – On
   * Label – On
   * Color – By Link Type
   * Thickness – On
 * Nodes
   * Max name length – 15
 * Size – change to a value that suits you the best

<a href="https://blog.tyang.org/wp-content/uploads/2016/08/image-51.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/08/image_thumb-51.png" alt="image" width="175" height="792" border="0" /></a>

{:start="5"}
5. Add a timeline visual to the bottom of the report, then drag the TimeGenerated Field from the dataset to the Time field:

<a href="https://blog.tyang.org/wp-content/uploads/2016/08/image-52.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/08/image_thumb-52.png" alt="image" width="187" height="366" border="0" /></a>

As you can see, as long as you understand what each field means in the OMS data type that you are interested in, it’s really easy to create cool Power BI reports, as long as you are using appropriate visuals. This is all I have to share today, until next time, have fun in OMS and Power BI!