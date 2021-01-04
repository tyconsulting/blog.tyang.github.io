---
id: 4979
title: Extending Your OpsMgr Power BI Dashboards to Power BI Sites
date: 2015-12-14T17:30:11+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=4979
permalink: /2015/12/14/extending-your-opsmgr-power-bi-dashboards-to-power-bi-sites/
categories:
  - Power BI
  - SCOM
tags:
  - Dashboard
  - Power BI
  - SCOM
---

## Introduction

Few days ago, my friend and CDM MVP Cameron Fuller published a great article on how to build Power BI Dashboards for OpsMgr. You can check out Cameron’s post from here: <a title="http://blogs.catapultsystems.com/cfuller/archive/2015/12/01/using-power-bi-for-disk-space-dashboards-and-reports-in-operations-manager/" href="http://blogs.catapultsystems.com/cfuller/archive/2015/12/01/using-power-bi-for-disk-space-dashboards-and-reports-in-operations-manager/">http://blogs.catapultsystems.com/cfuller/archive/2015/12/01/using-power-bi-for-disk-space-dashboards-and-reports-in-operations-manager/</a>

The solution Cameron produced was based on Power BI desktop and OpsMgr Data Warehouse DB, which both are located in your on-premises network. After Cameron has shown us what he has produced, I spent some time, and managed to extend the reports and dashboards that Cameron has created using Power BI Desktop to Power BI sites, which is a cloud-based PaaS solution offered as a part of the Office 365.

In this post, I will go through the process of setting up this solution so you can move Cameron’s Power BI dashboard to the cloud.

## Pre-Requisites

In order to create a Power BI dataset in your cloud based Power BI sites which is based on the on-prem OpsMgr Data Warehouse DB, we will need to install a component called <a href="https://powerbi.microsoft.com/en-us/documentation/powerbi-gateway-enterprise/">Power BI Enterprise Gateway</a> (Currently in preview) on a server in your on-prem data center. As shown in the diagram below, once the dataset is created for the OpsMgr Data Warehouse DB, the Power BI Site will query the OpsMgr DW DB through the Power BI Enterprise Gateway.

<a href="http://blog.tyang.org/wp-content/uploads/2015/12/PowerBI-OpsMgr-Dashboard-Connection.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="PowerBI OpsMgr Dashboard Connection" src="http://blog.tyang.org/wp-content/uploads/2015/12/PowerBI-OpsMgr-Dashboard-Connection_thumb.png" alt="PowerBI OpsMgr Dashboard Connection" width="558" height="228" border="0" /></a>



The solution we are going to implement requires the following pre-requisites:

* A on-prem server for hosting the Power BI Enterprise Gateway
* Power BI Desktop installed on an on-prem computer (i.e. your own PC)
* A Power BI Pro account
* A service account that has access to the OpsMgr data warehouse DB

>**Note:** Power BI Enterprise Gateway is a feature only available for Power BI Pro accounts. Please refer to <a href="https://powerbi.microsoft.com/en-us/pricing">this page</a> for differences between Power BI Free and Pro accounts.

## Configuration

The install process for the Power BI Enterprise Gateway is very straightforward. It is documented here: <a title="https://powerbi.microsoft.com/en-us/documentation/powerbi-gateway-enterprise/" href="https://powerbi.microsoft.com/en-us/documentation/powerbi-gateway-enterprise/">https://powerbi.microsoft.com/en-us/documentation/powerbi-gateway-enterprise/</a>

Once it is installed and connected to your Power BI account, you will be able to manage the gateway after you’ve logged on to the Power BI Site (<a title="https://app.powerbi.com/" href="https://app.powerbi.com/">https://app.powerbi.com/</a>):

<a href="http://blog.tyang.org/wp-content/uploads/2015/12/image-1.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/12/image_thumb-1.png" alt="image" width="325" height="247" border="0" /></a>

And you can use "Add Data Source" to establish connection to a data base via the gateway:

<a href="http://blog.tyang.org/wp-content/uploads/2015/12/SNAGHTML8d5b281.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML8d5b281" src="http://blog.tyang.org/wp-content/uploads/2015/12/SNAGHTML8d5b281_thumb.png" alt="SNAGHTML8d5b281" width="582" height="360" border="0" /></a>

I have created a data source for my OpsMgr DW DB:

<a href="http://blog.tyang.org/wp-content/uploads/2015/12/image-2.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/12/image_thumb-2.png" alt="image" width="575" height="454" border="0" /></a>

After the data source is created for the OpsMgr DW DB, I then need to create a dataset based on the OpsMgr DW DB. We must create this dataset in Power BI Desktop.

As Cameron already demonstrated in his post, in Power BI Desktop, we create a new document, and select SQL Server Database:

<a href="http://blog.tyang.org/wp-content/uploads/2015/12/image-3.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/12/image_thumb-3.png" alt="image" width="600" height="331" border="0" /></a>

We then specify the SQL server name and database name for the OpsMgr DW DB:

<a href="http://blog.tyang.org/wp-content/uploads/2015/12/image-4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/12/image_thumb-4.png" alt="image" width="407" height="170" border="0" /></a>

>**<span style="color: #ff0000;">Note:</span> Please make sure the server name and database name entered here is IDENTICAL as what you have entered for the OpsMgr DW DB Data Source you have created under the Power BI Enterprise Gateway.**

Then, we will select all the tables and views that we are interested in. I won’t repeat what Cameron has already demonstrated, Please refer to his post for more details on what tables and views to select.

Please make sure you have select ALL the tables and views that you need. Once we have uploaded this configuration to Power BI Site, we won’t be able to modify this dataset in Power BI Site.

Once we have selected all required tables and views, click "Load":

<a href="http://blog.tyang.org/wp-content/uploads/2015/12/image-5.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/12/image_thumb-5.png" alt="image" width="431" height="344" border="0" /></a>

Please make sure you choose "DirectQuery" when prompted:

<a href="http://blog.tyang.org/wp-content/uploads/2015/12/image-6.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/12/image_thumb-6.png" alt="image" width="406" height="237" border="0" /></a>

Power BI will then create the connections to each table and view you have selected. Depending on the number of tables and views you have selected, this process may take a while:

<a href="http://blog.tyang.org/wp-content/uploads/2015/12/image-7.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/12/image_thumb-7.png" alt="image" width="382" height="302" border="0" /></a>

You can now see all the tables and views you have selected in Power BI Desktop:

<a href="http://blog.tyang.org/wp-content/uploads/2015/12/image-8.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/12/image_thumb-8.png" alt="image" width="670" height="373" border="0" /></a>

Now, we can save this empty Power BI report:

<a href="http://blog.tyang.org/wp-content/uploads/2015/12/image-9.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/12/image_thumb-9.png" alt="image" width="668" height="372" border="0" /></a>

After it is saved, we can go back to the Power BI Site, and import the newly created report by clicking "Get Data":

<a href="http://blog.tyang.org/wp-content/uploads/2015/12/SNAGHTML8fb7716.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML8fb7716" src="http://blog.tyang.org/wp-content/uploads/2015/12/SNAGHTML8fb7716_thumb.png" alt="SNAGHTML8fb7716" width="584" height="343" border="0" /></a>

Then choose "Files:

<a href="http://blog.tyang.org/wp-content/uploads/2015/12/image-10.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/12/image_thumb-10.png" alt="image" width="500" height="293" border="0" /></a>

Select Local File, and choose the empty report we’ve just created in Power BI Desktop

<a href="http://blog.tyang.org/wp-content/uploads/2015/12/image-11.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/12/image_thumb-11.png" alt="image" width="504" height="304" border="0" /></a>

Then, you should be able to the new dataset appeared under "Datasets":

<a href="http://blog.tyang.org/wp-content/uploads/2015/12/image-12.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/12/image_thumb-12.png" alt="image" width="147" height="335" border="0" /></a>

And we can create a new report in Power BI Site, same way as what Cameron has demonstrated in his post:

<a href="http://blog.tyang.org/wp-content/uploads/2015/12/SNAGHTML9038b23.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML9038b23" src="http://blog.tyang.org/wp-content/uploads/2015/12/SNAGHTML9038b23_thumb.png" alt="SNAGHTML9038b23" width="673" height="370" border="0" /></a>

In my lab, I have created the dataset and imported the Power BI report file to Power BI Site few days ago. From the above screenshot, you can see the performance data collected today (as highlighted in red). This means the Power BI Site is directly quering my On-Prem OpsMgr DW DB in real time via the Power BI Enterprise gateway. And when I checked my usage, the OpsMgr DW DB dataset has only consumed 1MB of data:

<a href="http://blog.tyang.org/wp-content/uploads/2015/12/SNAGHTML9083664.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML9083664" src="http://blog.tyang.org/wp-content/uploads/2015/12/SNAGHTML9083664_thumb.png" alt="SNAGHTML9083664" width="661" height="388" border="0" /></a>

## Summary

In this post, I have demonstrated how to extend the PowerBI report and dashboard you have build in PowerBI Desktop located in your On-Prem environments to the cloud based version – Power BI Site, via the newly released Power BI Enterprise Gateway (still in preview at the time of writing).

Although we must have a Power BI Pro account in order to leverage the Power BI gateways, since are using direct query method when connecting to the OpsMgr DW database, this solution should not consume too much data from your monthly allowrance for the PRO user.

The performance for the report is really fast. My OpsMgr management group and the Power BI Enterprise Gateway server is located in my home lab, which is connected to the Internet only via an ADSL 2+ connection.

This is certainly a cheaper alternative OpsMgr dashboarding solution (compared with other commercial products). Additionally, since it is hosted on the cloud, it is much easier to access the reports and dashboard no matter where you are. Power BI also provides mobile apps for all 3 platforms (Windows, iOS and Android), which you can use to access the data using your preferred mobile devices. You can find more information about the mobile apps here: <a title="https://powerbi.microsoft.com/en-us/mobile" href="https://powerbi.microsoft.com/en-us/mobile">https://powerbi.microsoft.com/en-us/mobile</a>

You also have the ability to share the dashboards you have created with other people within your organisation.