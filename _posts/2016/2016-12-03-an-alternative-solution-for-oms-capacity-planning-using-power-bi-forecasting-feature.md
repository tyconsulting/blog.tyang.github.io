---
id: 5782
title: An Alternative Solution for OMS Capacity Planning Using Power BI Forecasting Feature
date: 2016-12-03T12:26:10+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=5782
permalink: /2016/12/03/an-alternative-solution-for-oms-capacity-planning-using-power-bi-forecasting-feature/
categories:
  - OMS
  - Power BI
tags:
  - OMS
  - Power BI
---

## Introduction

Back in September, the Power BI team introduced the Forecasting preview feature in Power BI Desktop. I was really excited to see this highly demanded feature finally been made available. However, it was only a preview feature in Power BI Desktop, it was not available in Power BI online. Few days ago, when the Power BI November update was introduced, this feature has come out of preview and became available also on Power BI Online.

In the cloud and data centre management context, forecasting plays a very important role in capacity planning. Earlier this year, before the OMS Capacity Planning solution V1 has been taken off the shelve, I have written couple of posts <a href="http://blog.tyang.org/2016/01/07/capacity-planning-oms-vs-opslogix-capacity-reportsmp/">comparing OMS Capacity Planning solution and OpsLogix OpsMgr Capacity Report MP</a>, and <a href="http://blog.tyang.org/2016/03/17/opslogix-capacity-report-management-pack-overview/">OpsLogix Capacity Report MP overview</a>. But ever since the OMS Capacity Planning solution was removed, at the moment, we don’t have a capacity planning solution for OMS data sources – the OpsLogix Capacity Report MP is 100% based on OpsMgr.

## Power BI Forecasting Feature

When I read the Power BI November update announcement few days ago, I was really excited because the Forecasting feature is finally available on Power BI Online, which means I can use this feature on OMS data sources (such as performance data).

Since I already have configured OMS to pump data to Power BI, it only took me around 15 minutes and I have created an OMS Performance Forecasting report in Power BI:

<a href="http://blog.tyang.org/wp-content/uploads/2016/12/image.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/12/image_thumb.png" alt="image" width="714" height="403" border="0" /></a>

I’m going to show you how to create this report in the remaining of this post.

## Step-by-Step Guide

### pre-requisites

01. Make sure you have already configured OMS to inject performance data (Type=Perf) to Power BI.

02. Download required Power BI custom visuals

In this report, I’m using two Power BI custom visuals that are not available out of the box, you will need to download the following from the <a href="https://app.powerbi.com/visuals/">Power BI Visuals Gallery</a>:

* Hierarchy Slicer (<a title="https://app.powerbi.com/visuals/show/HierarchySlicer1458836712039" href="https://app.powerbi.com/visuals/show/HierarchySlicer1458836712039">https://app.powerbi.com/visuals/show/HierarchySlicer1458836712039</a>)
* Timeline (<a title="https://app.powerbi.com/visuals/show/Timeline1447991079100" href="https://app.powerbi.com/visuals/show/Timeline1447991079100">https://app.powerbi.com/visuals/show/Timeline1447991079100</a>)

### Creating the report

01. Click on the data source for OMS perf data, you will see a blank canvas. firstly, import the above mentioned visuals to the report

<a href="http://blog.tyang.org/wp-content/uploads/2016/12/image-1.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; margin: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/12/image_thumb-1.png" alt="image" width="244" height="183" border="0" /></a>

{:start="2"}
02. Add a text box on the top of the report page for the report title

<a href="http://blog.tyang.org/wp-content/uploads/2016/12/image-2.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/12/image_thumb-2.png" alt="image" width="612" height="187" border="0" /></a>

{:start="3"}
03. Add a Hierarchy Slicer

<a href="http://blog.tyang.org/wp-content/uploads/2016/12/image-3.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/12/image_thumb-3.png" alt="image" width="412" height="193" border="0" /></a>

Configure the slicer to filter on the following fields (in the specific order):

* ObjectName
* CounterName
* Computer
* InstanceName

<a href="http://blog.tyang.org/wp-content/uploads/2016/12/image-4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; margin: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/12/image_thumb-4.png" alt="image" width="171" height="176" border="0" /></a>

and make sure Single Select on (default value). Optionally, give the visual a title:

<a href="http://blog.tyang.org/wp-content/uploads/2016/12/SNAGHTML3937892a.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML3937892a" src="http://blog.tyang.org/wp-content/uploads/2016/12/SNAGHTML3937892a_thumb.png" alt="SNAGHTML3937892a" width="137" height="267" border="0" /></a>

{:start="4"}
04. Add a line chart to the centre of the report. Drag TimeGenerated field to Axis and CounterValue to Values. For CounterValues, choose the average value.

<a href="http://blog.tyang.org/wp-content/uploads/2016/12/image-5.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; margin: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/12/image_thumb-5.png" alt="image" width="207" height="244" border="0" /></a>

Give the visual a title.

<a href="http://blog.tyang.org/wp-content/uploads/2016/12/image-6.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; margin: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/12/image_thumb-6.png" alt="image" width="134" height="244" border="0" /></a>

**Note: DO NOT** configure the "Legend" field for the line chart visual, otherwise the forecasting feature will be disabled.

{:start="5"}
05. In the Analytics pane of the Line Chart visual, configure forecast based on your requirements

<a href="http://blog.tyang.org/wp-content/uploads/2016/12/image-7.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/12/image_thumb-7.png" alt="image" width="158" height="524" border="0" /></a>

{:start="6"}
06. Optionally, also add a Trend Line

<a href="http://blog.tyang.org/wp-content/uploads/2016/12/image-8.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; margin: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/12/image_thumb-8.png" alt="image" width="175" height="244" border="0" /></a>

{:start="7"}
07. Add a Timeline visual to the bottom of the report page and drag the TimeGenerated field from the dataset to to the Time field of the visual.

<a href="http://blog.tyang.org/wp-content/uploads/2016/12/image-9.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; margin: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/12/image_thumb-9.png" alt="image" width="181" height="244" border="0" /></a>

In order to save the screen space, turn of Labels, and give the Timeline visual a title

<a href="http://blog.tyang.org/wp-content/uploads/2016/12/image-10.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; margin: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/12/image_thumb-10.png" alt="image" width="114" height="244" border="0" /></a>

{:start="8"}
08. Save the report. You can also ping this report page to a dashboard.

## Using the Report

Now that the report is created, you can select a counter instance using from the Hierarchy Slicer, and chose a time window that you want the forecasting to be based on from the Timeline slicer. the data on the Line Chart visual will be automatically updated.

<a href="http://blog.tyang.org/wp-content/uploads/2016/12/2016-12-03_12-40-44.gif"><img style="display: inline;" title="2016-12-03_12-40-44" src="http://blog.tyang.org/wp-content/uploads/2016/12/2016-12-03_12-40-44_thumb.gif" alt="2016-12-03_12-40-44" width="682" height="383" /></a>

## Summary

Comparing to the old OMS Capacity Planning Solution, what I demonstrated here only provides forecasting for individual performance counters. It does not analyse performance data in order to provide a high level overview like what the Capacity Planning solution did. However, since there is no forecasting capabilities in OMS at the moment, this provides a quick and easy way to give you some basic forecasting capabilities.