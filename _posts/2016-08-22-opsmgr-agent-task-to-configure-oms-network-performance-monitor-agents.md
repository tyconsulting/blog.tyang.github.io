---
id: 5573
title: OpsMgr Agent Task to Configure OMS Network Performance Monitor Agents
date: 2016-08-22T17:41:30+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=5573
permalink: /2016/08/22/opsmgr-agent-task-to-configure-oms-network-performance-monitor-agents/
categories:
  - OMS
  - SCOM
tags:
  - Management Pack
  - OMS
  - SCOM
---
<a href="https://azure.microsoft.com/en-us/documentation/articles/log-analytics-network-performance-monitor/#installing-and-configuring-agents-for-the-solution">OMS Network Performance Monitor (NPM)</a> has made to public preview few weeks ago. Unlike other OMS solutions, for NPM, additional configuration is required on each agent that you wish to enrol to this solution. The detailed steps are documented in the solution documentation.

The product team has provided a PowerShell script to configure the MMA agents <em><strong>locally</strong></em> (link included in the documentation). In order to make the configuration process easier for the OpsMgr users, I have created a management pack that contains several agent tasks:
<ul>
 	<li>Enable OMS Network Performance Monitor</li>
 	<li>Disable OMS Network Performance Monitor</li>
 	<li>Get OMS Network Performance Monitor Agent Configuration</li>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2016/08/image-35.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/08/image_thumb-35.png" alt="image" width="319" height="318" border="0" /></a>

<strong>Note:</strong> Since this is an OpsMgr management pack, you can only use these tasks against agents that are enrolled to OMS via OpsMgr, or direct OMS agents that are also reporting to your OpsMgr management group.

These tasks are targeting the Health Service class, if you are also using my OpsMgr 2012 Self Maintenance MP, you will have a “Health Service” state view, and you will be able to access these tasks from the task pane of this view:

<a href="http://blog.tyang.org/wp-content/uploads/2016/08/image-36.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; margin: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/08/image_thumb-36.png" alt="image" width="244" height="205" border="0" /></a>

I can use the “Get OMS Network Performance Monitor Agent Configuration” task  to check if an agent has been configured for NPM.

i.e. Before an agent is configured, the task output shows it is not configured:

<a href="http://blog.tyang.org/wp-content/uploads/2016/08/image-37.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/08/image_thumb-37.png" alt="image" width="475" height="451" border="0" /></a>

Then I can use the “Enable OMS Network Performance Monitor” task to enable NPM on this agent:

<a href="http://blog.tyang.org/wp-content/uploads/2016/08/image-38.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/08/image_thumb-38.png" alt="image" width="476" height="681" border="0" /></a>

Once enabled, if I run the “Get OMS Network Performance Monitor Agent Configuration” task  again, the task output will show it’s enabled and also display the configured port number:

<a href="http://blog.tyang.org/wp-content/uploads/2016/08/image-39.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/08/image_thumb-39.png" alt="image" width="461" height="438" border="0" /></a>

and shortly after, you will be able to see the newly configured node in OMS NPM solution:

<a href="http://blog.tyang.org/wp-content/uploads/2016/08/image-40.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/08/image_thumb-40.png" alt="image" width="420" height="209" border="0" /></a>

If you want to remove the configuration, just simply run the “Disable OMS Network Performance Monitor” task:

<a href="http://blog.tyang.org/wp-content/uploads/2016/08/image-41.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/08/image_thumb-41.png" alt="image" width="450" height="575" border="0" /></a>

You can download the sealed version of this MP <span style="color: #ff0000; font-family: Arial; font-size: small;"><strong><a href="http://blog.tyang.org/wp-content/uploads/2016/08/OMS.Network.Performance.Monitor.Agent_.Task_.zip">HERE</a></strong></span>. I’ve also pushed the VSAE project for this MP to <a href="https://github.com/tyconsulting/BlogPosts/tree/master/OpsMgr/OMS.Network.Performance.Monitor.Agent.Task" target="_blank">GitHub</a>.