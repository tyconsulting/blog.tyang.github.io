---
id: 3912
title: 'New MP: OpsMgr Health State Synchronization Library'
date: 2015-04-19T17:29:36+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=3912
permalink: /2015/04/19/new-mp-opsmgr-health-state-synchronization-library/
categories:
  - SCOM
tags:
  - Management Pack
  - SCOM
---
<h3><a href="http://blog.tyang.org/wp-content/uploads/2015/04/Health-Sync.png"><img class="alignleft size-thumbnail wp-image-3914" src="http://blog.tyang.org/wp-content/uploads/2015/04/Health-Sync-150x150.png" alt="Health Sync" width="150" height="150" /></a>Background</h3>
As I mentioned in previous blog posts, I will continue blogging on the topic of managing multiple OpsMgr management groups – a topic keeps getting brought up in the private conversations between us SCCDM MVPs.

Previously, I have written 2 posts demonstrated how to use Squared Up dashboard to access data from foreign management groups using their <a href="http://blog.tyang.org/2015/03/13/using-squared-up-as-an-universal-dashboard-solution/">SQL</a> and <a href="http://blog.tyang.org/2015/03/25/consolidate-multiple-squared-up-instances-into-single-dashboard/">Iframe</a> plugins. Now that I’ve covered the presentation layer (using Squared Up), I’d like to explore deeper in this subject.

I wanted to be able to synchronise the health state from a monitoring object managed by a remote management group into the local management group so it can be part of the health models users are building (i.e. be part of a Distributed Application, or simply a dashboard). I had this idea in my head for awhile now, over the last month or so, I finally managed to produce such a management pack that enables OpsMgr users to do so.
<h3>Introduction</h3>
It is common to have multiple OpsMgr management groups in large organisations. When designing distributed application or creating custom dashboards, one of the limitations is that OpsMgr users can only select monitoring objects within the local management group to be a part of the Health Model. This becomes an issue when users want to design a Distributed Application or dashboard that include components monitored by different OpsMgr management groups.

The <b>OpsMgr Health Synchronization Library</b> management pack is designed to provide a workaround to this limitation. This management pack provides a template that enables OpsMgr users to create monitoring objects named "<b>Health State Watcher</b>" hosted by All Management Servers Resource Pool. Health State Watcher objects have monitors configured to query health state of monitoring objects located in a remote management group using OpsMgr SDK.

<a href="http://blog.tyang.org/wp-content/uploads/2015/04/HealthStateSyncMPDiagram.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="HealthStateSyncMPDiagram" src="http://blog.tyang.org/wp-content/uploads/2015/04/HealthStateSyncMPDiagram_thumb.png" alt="HealthStateSyncMPDiagram" width="698" height="311" border="0" /></a>

As shown in the diagram above, an instance of Health State Watcher can be created for each monitoring object of user’s choice from a remote management group. Each Health State Watcher object will periodically update its own health state based on the health state of the remote monitoring object it is watching for (every 5 minutes by default). As shown above, the Health State Watcher can query health state of any monitoring objects from remote management group (i.e. a Windows Computer object, a Distributed Application or any other types monitoring objects).

This management pack provides 4 unit monitors to the Health State Watcher class. They are used to query the health state of the <b>Availability</b>, <b>Configuration</b>, <b>Performance</b> and <b>Security</b> aggregate monitors of the remote monitoring object respectively.

Once the Health State Watcher objects are created and correctly configured, it can be used to display the health state of the remote monitoring object in a dashboard or distributed application hosted by the local management group.
<h3>How Do I Use this MP?</h3>
This management pack provides a management pack template for OpsMgr users to create the Health State Watcher instances from the OpsMgr operations console.

<a href="http://blog.tyang.org/wp-content/uploads/2015/04/SNAGHTMLeb9f2ef.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; margin: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLeb9f2ef" src="http://blog.tyang.org/wp-content/uploads/2015/04/SNAGHTMLeb9f2ef_thumb.png" alt="SNAGHTMLeb9f2ef" width="206" height="244" border="0" /></a>

The following information must be provided when creating an instance using the management pack template:
<ul>
	<li>Display Name</li>
	<li>Description (Optional)</li>
	<li>Unsealed Management Pack (where the MP elements will be saved)</li>
	<li>One of the management servers from the remote management group</li>
	<li>Monitoring Object ID of the monitoring object from the remote management group</li>
	<li>Run-As account for SDK connection to the remote management group</li>
</ul>
Please follow the steps listed below to create a template instance.

1. Click the "Add Monitoring Wizard" from the Authoring pane under "Management Pack Template"

<a href="http://blog.tyang.org/wp-content/uploads/2015/04/SNAGHTMLec2e084.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLec2e084" src="http://blog.tyang.org/wp-content/uploads/2015/04/SNAGHTMLec2e084_thumb.png" alt="SNAGHTMLec2e084" width="544" height="321" border="0" /></a>

2. Choose "Cross Management Group Health State Monitoring" from the list

<a href="http://blog.tyang.org/wp-content/uploads/2015/04/SNAGHTMLec1c7a2.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLec1c7a2" src="http://blog.tyang.org/wp-content/uploads/2015/04/SNAGHTMLec1c7a2_thumb.png" alt="SNAGHTMLec1c7a2" width="602" height="490" border="0" /></a>

3. In General Property page, enter the display name, description and select an unsealed MP from the drop-down list:

<a href="http://blog.tyang.org/wp-content/uploads/2015/04/image.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/04/image_thumb.png" alt="image" width="555" height="406" border="0" /></a>

4. In the Parameter Configuration Page, enter the following information:

<a href="http://blog.tyang.org/wp-content/uploads/2015/04/image1.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/04/image_thumb1.png" alt="image" width="565" height="411" border="0" /></a>
<ul>
	<li>Management server from the remote management group</li>
	<li>Source Instance ID (monitoring object ID) of the monitoring object from the remote management group</li>
</ul>
<b>Note:</b> there are multiple ways to find the monitoring object ID in OpsMgr. Please refer to this article for possible ways to locate the ID: <a href="http://blog.tyang.org/2015/03/11/various-ways-to-find-the-id-of-a-monitoring-object-in-opsmgr/">http://blog.tyang.org/2015/03/11/various-ways-to-find-the-id-of-a-monitoring-object-in-opsmgr/</a>
<ul>
	<li>Select the Run-As account that was created prior to running this wizard.</li>
</ul>
<b>Note:</b> The Run-As account must meet the following requirements:
<ol>
<ol>
	<li>It must have at least Operator access in the remote management group</li>
	<li>It must be distributed to all management servers</li>
</ol>
</ol>
<a href="http://blog.tyang.org/wp-content/uploads/2015/04/image2.png"><img style="background-image: none; float: none; padding-top: 0px; padding-left: 0px; margin-left: auto; display: block; padding-right: 0px; margin-right: auto; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/04/image_thumb2.png" alt="image" width="347" height="350" border="0" /></a>
<ol>
<ol>
	<li>It must have logon locally access on all management servers. – This is a general requirement for all Windows Run-As accounts in OpsMgr. Although it will never be used to logon locally on the management servers, without this right, the workflows that are using this Run-As account will not work.</li>
</ol>
</ol>
&nbsp;

5. Confirm all information is correct in the Summary page, and click on "Create".

<a href="http://blog.tyang.org/wp-content/uploads/2015/04/image3.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/04/image_thumb3.png" alt="image" width="529" height="386" border="0" /></a>

6. After few minutes, the health state of the Health State Watcher instance should be synchronized from the remote monitoring object:

Overall state:

<a href="http://blog.tyang.org/wp-content/uploads/2015/04/image4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/04/image_thumb4.png" alt="image" width="522" height="311" border="0" /></a>

Health Explorer:

<a href="http://blog.tyang.org/wp-content/uploads/2015/04/image5.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/04/image_thumb5.png" alt="image" width="526" height="367" border="0" /></a>

Source monitoring object (from remote MG):

<a href="http://blog.tyang.org/wp-content/uploads/2015/04/image6.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/04/image_thumb6.png" alt="image" width="521" height="364" border="0" /></a>
<h3>Sample Distributed Application</h3>
The diagram below demonstrates how to utilize the health state watcher in a Distributed Application:

<a href="http://blog.tyang.org/wp-content/uploads/2015/04/image7.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/04/image_thumb7.png" alt="image" width="508" height="359" border="0" /></a>

In the demo environment, the 2 domain controllers (AD01 and AD02) are being monitored by a management group located in the On-Prem network. There is another domain controller located in Microsoft Azure IaaS, and it is being monitored by a separate management group in Azure. A Health State Watcher object was created previously to synchronize the health state of the Azure DC Windows computer health.
<h3>Sample Dashboard (Using Squared Up)</h3>
<a href="http://blog.tyang.org/wp-content/uploads/2015/04/image8.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/04/image_thumb8.png" alt="image" width="496" height="250" border="0" /></a>

As shown above, on the left section, the Health State Watcher object for the Azure based domain controller is pinned on the correct location of a World Map dashboard. The health state of individual domain controllers are also listed on the right.
<h3>Credit</h3>
The workflows in this MP are actually pretty simple, but it has taken me A LOT of time to finish this MP. This is largely caused by the template UI interfaces. Unfortunately, I couldn’t find any official guides on how to build template UIs using C#. I’d like to thank my friend and fellow SCCDM MVP <strong>Daniele Grandini</strong> (<a href="https://nocentdocent.wordpress.com/">blog</a>, <a href="https://twitter.com/DanieleGrandini">twitter</a>) for testing and helping me debugging this MP when I hit the road block with the template UI interface.
<h3>Where can I download this management pack?</h3>
As I mentioned in my previous post, from now on, any new tools such as management packs, modules, scripts etc. will be released under TY Consulting and download links will be provided from it’s website <a href="http://www.tyconsulting.com.au">www.tyconsulting.com.au</a>.

You can download this MP <strong>for free</strong> from <a title="http://www.tyconsulting.com.au/products/" href="http://www.tyconsulting.com.au/products/">http://www.tyconsulting.com.au/products/</a>, however, to help me promote and grow my business, I am asking you to provide your name, email and company name in a form and the download link will be emailed to you by the system.

Lastly, as always, any feedbacks are welcome. Please feel free to drop me an email if you have anything to share.