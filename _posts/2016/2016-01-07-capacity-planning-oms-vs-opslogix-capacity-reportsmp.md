---
id: 5116
title: 'Capacity Planning &#8211; OMS Vs. OpsLogix Capacity Reports MP'
date: 2016-01-07T19:08:14+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=5116
permalink: /2016/01/07/capacity-planning-oms-vs-opslogix-capacity-reportsmp/
categories:
  - OMS
  - SCOM
tags:
  - OMS
  - OpsLogix
  - SCOM
---

## Introduction

When it comes to data center / fabric capacity planning, currently there are 2 major solutions within Microsoft’s System Center and OMS space. These solutions are:

* OMS Capacity Planning Solution (<a href="http://microsoft.com/oms">http://microsoft.com/oms</a>)
* OpsLogix Capacity Reporting Management Pack for OpsMgr (<a title="http://www.opslogix.com/capacity-management-pack/" href="http://www.opslogix.com/capacity-management-pack/">http://www.opslogix.com/capacity-management-pack/</a>)

In this post, I will discuss the differences and similarities between these 2 solutions

## OMS Capacity Planning Solution Overview

The OMS Capacity Planning solution was designed to provide an overview on the current and future utilisation of your virtualisation infrastructure and fabric. It is freely available for all OMS customers (well, you do have to pay for the OMS data consumption).

It collects a set of performance data via OpsMgr, and forecast your resource utilization based on the performance data collected.

If you have not used the OMS Capacity Planning solution yet and would like to learn more, here is a list of great resources for you:

* <a href="https://cloudadministrator.wordpress.com/2014/06/22/system-center-advisor-restarted-capacity-planning-part-4/">OMS Blog Post Series Part 4 – Capacity Planning</a> by Microsoft MVP Stanislav Zhelyazkov
* Chapter 5 of the <a href="https://gallery.technet.microsoft.com/Inside-the-Operations-2928e342/view/Reviews">Inside the Microsoft Operations Management Suite</a> e-book

To date, out of all the solutions that OMS provides, the Capacity Planning Solution is probably the one that has the most complex requirements. It requires:

1. Hyper-V hosts managed by VMM
2. VMM fully integrated with OpsMgr (configured via VMM console)
3. OpsMgr connected to OMS Workspace
4. VMM Management Servers and Hyper-V hosts onboarded to OMS via OpsMgr

Because of the nature of this solution, it collects **a specific set** of performance counters on **VMM** and **Hyper-V** servers to forecast the **compute** and **storage** fabric within your virtualisation infrastructure. It does not work for Other types of hypervisors that are being managed by VMM (i.e. VMware).

It provides some charts and diagrams which gives you a high level overview of your fabric.

<a href="https://blog.tyang.org/wp-content/uploads/2016/01/image-2.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/01/image_thumb-2.png" alt="image" width="436" height="198" border="0" /></a>

<a href="https://blog.tyang.org/wp-content/uploads/2016/01/image-3.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/01/image_thumb-3.png" alt="image" width="453" height="419" border="0" /></a>

<a href="https://blog.tyang.org/wp-content/uploads/2016/01/image-4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/01/image_thumb-4.png" alt="image" width="630" height="252" border="0" /></a>

<a href="https://blog.tyang.org/wp-content/uploads/2016/01/image-5.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/01/image_thumb-5.png" alt="image" width="623" height="249" border="0" /></a>

You can also access the performance data collected by this solution via Search (Type=Perf)

<a href="https://blog.tyang.org/wp-content/uploads/2016/01/image-6.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/01/image_thumb-6.png" alt="image" width="667" height="261" border="0" /></a>

## OpsLogix Capacity Report MP Overview

Unlike OMS Capacity Planning solution, the OpsLogix Capacity Report MP is not a hybrid solution. It does not require integrations with any products. Once you have imported the Capacity Report MP and the license MP, you should soon see the number of reports deployed in your OpsMgr management group.

<a href="https://blog.tyang.org/wp-content/uploads/2016/01/SNAGHTML15da8eb9.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML15da8eb9" src="https://blog.tyang.org/wp-content/uploads/2016/01/SNAGHTML15da8eb9_thumb.png" alt="SNAGHTML15da8eb9" width="651" height="422" border="0" /></a>

As the names suggest, with the two absolute value reports, you can pick any performance collection rules for the language that you have selected (default to "English").

<a href="https://blog.tyang.org/wp-content/uploads/2016/01/image-7.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/01/image_thumb-7.png" alt="image" width="469" height="244" border="0" /></a>

and the report lists each instance you have selected.

<a href="https://blog.tyang.org/wp-content/uploads/2016/01/image-8.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/01/image_thumb-8.png" alt="image" width="697" height="504" border="0" /></a>

The 2 columns on the left shows the forecasted changes and the forecasted value for each instance based on the time frame you have selected.

The percentage value reports are designed for the performance collection rules that are collecting percentage values. You can also specify warning and critical thresholds (in number of days) for the forecasted data.

<a href="https://blog.tyang.org/wp-content/uploads/2016/01/image-9.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/01/image_thumb-9.png" alt="image" width="676" height="548" border="0" /></a>

Or, if you only want to see the critical ones, you can use "Critical Only" reports.

<a href="https://blog.tyang.org/wp-content/uploads/2016/01/image-10.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/01/image_thumb-10.png" alt="image" width="573" height="198" border="0" /></a>

## Comparison

Although both solutions provide forecasting capabilities for your infrastructure managed by OpsMgr, it serves different purposes.

OMS Capacity Planning solution collects **a specific set** of performance counters around the compute and storage fabric, and provides a high level view on what is the current and future capacity for the fabric in your **Hyper-V** environment. If you want to take a look at what counters are being collected by the Capacity Planning solution, you can export the following MPs from your OpsMgr management group and take a look using MPViewer.

<a href="https://blog.tyang.org/wp-content/uploads/2016/01/image-11.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/01/image_thumb-11.png" alt="image" width="428" height="163" border="0" /></a>

The OpsLogix Capacity Report MP provides a set of generic reports that can be used to forecast pretty much any **existing counters** that are being currently collected in your OpsMgr environment. This is purely a reporting MP, it does not collect any performance counters by itself.

Since the performance data collected by the OMS Capacity Planning solution is being saved only at your OMS workspace, you will not see these performance collection rules from the drop down lists in the OpsLogix capacity reports because they are not available in your OpsMgr Data Warehouse DB.

Although I have not personally tried it, theoretically, you can use the OpsLogix capacity report MP to produce forecasting reports for your Hyper-V environments (just like what the OMS Capacity Planning does), as long as you have configured OpsMgr to collect the same counters. Additionally, if you are using other hypervisors such as VMware and they are being monitored by OpsMgr, you can also use the OpsLogix capacity report MP for forecasting your fabric resource utilisation – this is something the OMS Capacity Planning solution does not provide.

## Conclusion

I hope I have provided a high level overview and comparison between OMS Capacity Planning solution and OpsLogix Capacity Report MP in this post. If you have questions or feedback, please feel free to contact me.