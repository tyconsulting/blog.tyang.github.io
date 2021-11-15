---
id: 3912
title: 'New MP: OpsMgr Health State Synchronization Library'
date: 2015-04-19T17:29:36+10:00
author: Tao Yang
#layout: post
excerpt: ""
header:
  overlay_image: /wp-content/uploads/2015/04/Health-Sync-banner.png
  overlay_filter: 0.5 # same as adding an opacity of 0.5 to a black background
guid: https://blog.tyang.org/?p=3912
permalink: /2015/04/19/new-mp-opsmgr-health-state-synchronization-library/
categories:
  - SCOM
tags:
  - Management Pack
  - SCOM
---

## Background

As I mentioned in previous blog posts, I will continue blogging on the topic of managing multiple OpsMgr management groups – a topic keeps getting brought up in the private conversations between us SCCDM MVPs.

Previously, I have written 2 posts demonstrated how to use Squared Up dashboard to access data from foreign management groups using their [SQL](https://blog.tyang.org/2015/03/13/using-squared-up-as-an-universal-dashboard-solution/) and [Iframe](ttp://blog.tyang.org/2015/03/25/consolidate-multiple-squared-up-instances-into-single-dashboard/) plugins. Now that I’ve covered the presentation layer (using Squared Up), I’d like to explore deeper in this subject.

I wanted to be able to synchronise the health state from a monitoring object managed by a remote management group into the local management group so it can be part of the health models users are building (i.e. be part of a Distributed Application, or simply a dashboard). I had this idea in my head for awhile now, over the last month or so, I finally managed to produce such a management pack that enables OpsMgr users to do so.

## Introduction

It is common to have multiple OpsMgr management groups in large organisations. When designing distributed application or creating custom dashboards, one of the limitations is that OpsMgr users can only select monitoring objects within the local management group to be a part of the Health Model. This becomes an issue when users want to design a Distributed Application or dashboard that include components monitored by different OpsMgr management groups.

The **OpsMgr Health Synchronization Library** management pack is designed to provide a workaround to this limitation. This management pack provides a template that enables OpsMgr users to create monitoring objects named "<b>Health State Watcher</b>" hosted by All Management Servers Resource Pool. Health State Watcher objects have monitors configured to query health state of monitoring objects located in a remote management group using OpsMgr SDK.

![](https://blog.tyang.org/wp-content/uploads/2015/04/HealthStateSyncMPDiagram.png)

As shown in the diagram above, an instance of Health State Watcher can be created for each monitoring object of user’s choice from a remote management group. Each Health State Watcher object will periodically update its own health state based on the health state of the remote monitoring object it is watching for (every 5 minutes by default). As shown above, the Health State Watcher can query health state of any monitoring objects from remote management group (i.e. a Windows Computer object, a Distributed Application or any other types monitoring objects).

This management pack provides 4 unit monitors to the Health State Watcher class. They are used to query the health state of the **Availability**, <b>Configuration</b>, <b>Performance</b> and <b>Security</b> aggregate monitors of the remote monitoring object respectively.

Once the Health State Watcher objects are created and correctly configured, it can be used to display the health state of the remote monitoring object in a dashboard or distributed application hosted by the local management group.

## How Do I Use this MP?

This management pack provides a management pack template for OpsMgr users to create the Health State Watcher instances from the OpsMgr operations console.

![](https://blog.tyang.org/wp-content/uploads/2015/04/SNAGHTMLeb9f2ef.png)

The following information must be provided when creating an instance using the management pack template:

* Display Name
* Description (Optional)
* Unsealed Management Pack (where the MP elements will be saved)
* One of the management servers from the remote management group
* Monitoring Object ID of the monitoring object from the remote management group
* Run-As account for SDK connection to the remote management group


Please follow the steps listed below to create a template instance.

1. Click the "Add Monitoring Wizard" from the Authoring pane under "Management Pack Template"

	![](https://blog.tyang.org/wp-content/uploads/2015/04/SNAGHTMLec2e084.png)

{:start="2"}
2. Choose "Cross Management Group Health State Monitoring" from the list

	![](https://blog.tyang.org/wp-content/uploads/2015/04/SNAGHTMLec1c7a2.png)

{:start="3"}
3. In General Property page, enter the display name, description and select an unsealed MP from the drop-down list:

	![](https://blog.tyang.org/wp-content/uploads/2015/04/image.png)

{:start="4"}
4. In the Parameter Configuration Page, enter the following information:

	![](https://blog.tyang.org/wp-content/uploads/2015/04/image1.png)

   * Management server from the remote management group
   * Source Instance ID (monitoring object ID) of the monitoring object from the remote management group

	>**Note:** there are multiple ways to find the monitoring object ID in OpsMgr. Please refer to this article for possible ways to locate the ID: [https://blog.tyang.org/2015/03/11/various-ways-to-find-the-id-of-a-monitoring-object-in-opsmgr/](https://blog.tyang.org/2015/03/11/various-ways-to-find-the-id-of-a-monitoring-object-in-opsmgr/)

   * Select the Run-As account that was created prior to running this wizard.

	>**Note:** The Run-As account must meet the following requirements:
	>1. It must have at least Operator access in the remote management group
	>2. It must be distributed to all management servers

	![](https://blog.tyang.org/wp-content/uploads/2015/04/image2.png)

  * It must have logon locally access on all management servers. – This is a general requirement for all Windows Run-As accounts in OpsMgr. Although it will never be used to logon locally on the management servers, without this right, the workflows that are using this Run-As account will not work.

{:start="5"}
5. Confirm all information is correct in the Summary page, and click on "Create".

	![](https://blog.tyang.org/wp-content/uploads/2015/04/image3.png)

{:start="6"}
6. After few minutes, the health state of the Health State Watcher instance should be synchronized from the remote monitoring object:

Overall state:

![](https://blog.tyang.org/wp-content/uploads/2015/04/image4.png)

Health Explorer:

![](https://blog.tyang.org/wp-content/uploads/2015/04/image5.png)

Source monitoring object (from remote MG):

![](https://blog.tyang.org/wp-content/uploads/2015/04/image6.png)

## Sample Distributed Application

The diagram below demonstrates how to utilize the health state watcher in a Distributed Application:

![](https://blog.tyang.org/wp-content/uploads/2015/04/image7.png)

In the demo environment, the 2 domain controllers (AD01 and AD02) are being monitored by a management group located in the On-Prem network. There is another domain controller located in Microsoft Azure IaaS, and it is being monitored by a separate management group in Azure. A Health State Watcher object was created previously to synchronize the health state of the Azure DC Windows computer health.

## Sample Dashboard (Using Squared Up)

![](https://blog.tyang.org/wp-content/uploads/2015/04/image8.png)

As shown above, on the left section, the Health State Watcher object for the Azure based domain controller is pinned on the correct location of a World Map dashboard. The health state of individual domain controllers are also listed on the right.

## Credit

The workflows in this MP are actually pretty simple, but it has taken me A LOT of time to finish this MP. This is largely caused by the template UI interfaces. Unfortunately, I couldn’t find any official guides on how to build template UIs using C#. I’d like to thank my friend and fellow SCCDM MVP **Daniele Grandini** ([blog](https://nocentdocent.wordpress.com/), [twitter](https://twitter.com/DanieleGrandini)) for testing and helping me debugging this MP when I hit the road block with the template UI interface.

## Where can I download this management pack?

As I mentioned in my previous post, from now on, any new tools such as management packs, modules, scripts etc. will be released under TY Consulting and download links will be provided from it’s website [www.tyconsulting.com.au](http://www.tyconsulting.com.au).

You can download this MP **for free** from <a title="http://www.tyconsulting.com.au/downloads/" href="http://www.tyconsulting.com.au/downloads/">http://www.tyconsulting.com.au/downloads/</a>, however, to help me promote and grow my business, I am asking you to provide your name, email and company name in a form and the download link will be emailed to you by the system.

Lastly, as always, any feedbacks are welcome. Please feel free to drop me an email if you have anything to share.