---
id: 2057
title: OpsMgr Self Maintenance Management Pack Updated to Version 2.1.0.0
date: 2013-08-18T18:13:39+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=2057
permalink: /2013/08/18/opsmgr-self-maintenance-management-pack-updated-to-version-2-1-0-0/
categories:
  - SCOM
tags:
  - Featured
  - MP Authoring
  - SCOM
---
I’ve updated the OpsMgr Self Maintenance MP for OpsMgr 2012 again this weekend. the latest version is now 2.1.0.0.

The following is what’s new in this version:

<strong>Bug fix for the MP backup rule</strong>

The alert parameter and alert message was configured incorrectly. when the alert is generated for the failed backup, the error from the script was not displayed in the alert description:

<a href="https://blog.tyang.org/wp-content/uploads/2013/08/image5.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2013/08/image_thumb5.png" width="568" height="187" border="0" /></a>

This is now fixed, the alert description is correctly displayed:

<a href="https://blog.tyang.org/wp-content/uploads/2013/08/image6.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2013/08/image_thumb6.png" width="580" height="158" border="0" /></a>

<strong>New Rule: Detect Manually Closed Monitor-Generated Alerts</strong>

As any OpsMgr operators /administrators should know, monitor generated alerts should not be closed manually. There are many articles on the Internet in regards to this behaviour (so I won’t repeat it). Last week there was an incident at my work that made me came out with the idea of creating this rule. This rule runs on a schedule and check if there are any monitor-generated alerts that have been closed since its last execution. It would generate a warning alert if it detects this behaviour:

<a href="https://blog.tyang.org/wp-content/uploads/2013/08/image7.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2013/08/image_thumb7.png" width="580" height="405" border="0" /></a>

The alert description contains a list of users who has closed monitor-generated alerts (along with the alert count for each user). To investigate further, OpsMgr administrators can simply create an alert view for closed alerts to find out details of these alerts:

<a href="https://blog.tyang.org/wp-content/uploads/2013/08/image8.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2013/08/image_thumb8.png" width="579" height="311" border="0" /></a>

This version of the MP and the documentation can be downloaded [HERE](https://cookdown.com/scom-essentials/self-maintenance).