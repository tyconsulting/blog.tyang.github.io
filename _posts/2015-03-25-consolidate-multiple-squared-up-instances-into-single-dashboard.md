---
id: 3864
title: Consolidate Multiple Squared Up Instances into Single Dashboard
date: 2015-03-25T19:01:44+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=3864
permalink: /2015/03/25/consolidate-multiple-squared-up-instances-into-single-dashboard/
categories:
  - SCOM
tags:
  - SCOM; SquaredUp
---
Recently, I have been involved in many conversations in regards to managing multiple SCOM management groups with other SCCDM MVP colleagues. I am planning to write more on this topic in the future. 2 weeks ago, after I posted <a href="http://blog.tyang.org/2015/03/13/using-squared-up-as-an-universal-dashboard-solution/">using Squared Up as an universal dashboard</a> and demonstrated how to list active alerts from another management group using their SQL plugin, my friends at Squared Up hinted me that I can also use the Iframe plugin for this purpose. Therefore, today, I’d like to demonstrate how can we present information from multiple management group (multiple Squared Up instances) into a single Squared Up page / dashboard using their <a href="http://support.squaredup.com/support/solutions/articles/197479-iframe-plugin-reference">Iframe plugin</a>.

The Iframe plugin allows to you display an embedded page within a dashboard. In my lab, I have 2 SCOM management groups, one located in my home lab and another one is hosted in Azure. I have installed Squared Up on the web console server of each MG. Today, I managed to produce 2 dashboards in one of my Squared Up instances:

<strong>Alerts from Multiple MGs:</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2015/03/image29.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/03/image_thumb29.png" alt="image" width="690" height="390" border="0" /></a>

<strong>Servers from Multiple MGs:</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2015/03/image30.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/03/image_thumb30.png" alt="image" width="691" height="391" border="0" /></a>

Each section (left and right) uses an instance of Iframe plugin to display a particular web page from a Squared Up instance. The setup is relatively easy. I’ll go through how to setup them now.

01. Configure the page you want to display the way you like. i.e. for the alert page, using the options to customise however you want it to be.

<a href="http://blog.tyang.org/wp-content/uploads/2015/03/image31.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/03/image_thumb31.png" alt="image" width="669" height="209" border="0" /></a>

02. save the changes and copy the URL.

03. Create a new page, split into multiple sections, and in one of the sections, choose “Web Content”, and copy the URL in the <strong>src</strong> field

<a href="http://blog.tyang.org/wp-content/uploads/2015/03/image32.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/03/image_thumb32.png" alt="image" width="486" height="211" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2015/03/image33.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/03/image_thumb33.png" alt="image" width="616" height="292" border="0" /></a>

03. As shown above, add <strong>?embed=true</strong> at the end of the URL (to remove the header), and add 2 additional parameters (<strong>refresh</strong> = true, <strong>scrolling</strong> = true).

04. Repeat above steps in other sections.

For the server list dashboard, you can drill down by clicking on a server, and then you will be able to trigger agent tasks associated to that particular server:

<a href="http://blog.tyang.org/wp-content/uploads/2015/03/image34.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/03/image_thumb34.png" alt="image" width="634" height="358" border="0" /></a>

So, why am I using Squared Up to consolidate views instead of configuring a Connected MGs scenario? Connected MGs have its limitations such as:
<ul>
	<li>both management groups must be running the same version.</li>
	<li>both management groups must be located in the same domain or trusted domains. untrusted domains are not supported</li>
</ul>
More information about Connected MG can be found here: <a title="https://technet.microsoft.com/en-au/library/hh230698.aspx" href="https://technet.microsoft.com/en-au/library/hh230698.aspx">https://technet.microsoft.com/en-au/library/hh230698.aspx</a>

By using the Iframe Plugin, you simply consolidate the views into a single page, therefore the limitations for connected MGs listed above don’t apply here.

This is what I have to share today. As I mentioned in the beginning of this article, there will be more on managing multiple management groups in the future. so stay tuned <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" src="http://blog.tyang.org/wp-content/uploads/2015/03/wlEmoticon-smile1.png" alt="Smile" />.