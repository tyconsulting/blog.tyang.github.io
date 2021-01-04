---
id: 2368
title: OpsMgr 2012 Self Maintenance Management Pack Update (Version 2.3.0.0)
date: 2014-02-23T09:44:29+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=2368
permalink: /2014/02/23/opsmgr-2012-self-maintenance-management-pack-update-version-2-3-0-0/
categories:
  - SCOM
tags:
  - Featured
  - MP Authoring
  - SCOM
---
I have been extremely busy lately. Although I had few new ideas for the OpsMgr 2012 Self Maintenance MP for a while, I couldn’t find time to update it. This weekend, I managed to find some spare time and updated this management pack.

What’s new?

<strong>Updated the Close Aged Rule Generated Alerts Rule</strong>

Awhile back, someone suggested me to add a comment to the alert when it’s being closed by this rule. I think it’s a good idea, so I’ve updated this rule. now any alerts closed by this rule will have a comment "Closed by OpsMgr 2012 Self Maintenance Management Pack":

<a href="http://blog.tyang.org/wp-content/uploads/2014/02/image5.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2014/02/image_thumb5.png" width="565" height="299" border="0" /></a>

<strong>New Agent Task: Get Management Groups configured on an agent</strong>

This new task is targeting the agent class, it displays the management groups that are configured on the OpsMgr 2012 agents:

<a href="http://blog.tyang.org/wp-content/uploads/2014/02/image6.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2014/02/image_thumb6.png" width="397" height="483" border="0" /></a>

<strong><span style="color: #ff0000;">Note:</span></strong> Since there is already a state view for agents built-in in OpsMgr 2012, I did not bother to create such a view in this management pack. You can find the "Agents By Version" state view under Operations Manager\Agent Details:

<a href="http://blog.tyang.org/wp-content/uploads/2014/02/image7.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2014/02/image_thumb7.png" width="580" height="376" border="0" /></a>

<strong>New Rule: Auto approve manually installed agents if their computer names and domain names match configurable regular expressions</strong>

By default in OpsMgr, there are 3 possible options for manually installed agents:
<ul>
	<li>Reject all</li>
	<li>Automatically Approve all</li>
	<li>Manually Approve by OpsMgr administrators</li>
</ul>
The "OpsMgr 2012 Self Maintenance Approve Manual Agents Rule" runs on a schedule and approve manually installed agents of which computer name and domain name match the configurable computer name and domain name regular expression. This rule presents 2 benefits:

1. Allow OpsMgr to automatically approve agents based on preconfigured naming convention. It eliminates the needs for administrators to manually approve agents.

2. Agents approvals are staged. This prevents large number of agents are approved at once. In a large OpsMgr environment, this is particularly important as approving a large number of agents at once could consume a lot of system resources on management servers to transfer management packs and process the initial discovery workflows submitted from the agents.

This rule can be customized using overrides:
<ul>
	<li><strong>IntervalMinutes:</strong> How often (in minutes) does this rule run.</li>
	<li><strong>AgentNameRegex:</strong> Regular Expression for acceptable Agent computer names</li>
	<li><strong>AgentDomainRegex:</strong> Regular Expression for acceptable Agent domain names</li>
	<li><strong>MaxToApprove:</strong> Maxinum number of manually installed agents to be approved at a time.</li>
	<li><strong>SyncTime:</strong> What time does this rule run.</li>
	<li><strong>TimeoutSeconds:</strong> Timeout in seconds for the PowerShell script inside the rule.</li>
</ul>
This rule will approve manually installed agents (up to the number configured for MaxToAPprove) if both agent's computer name and domain name match configured regular expressions.

An information alert is generated if the rule has approved at least one (1) agent(s).

<a href="http://blog.tyang.org/wp-content/uploads/2014/02/image8.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2014/02/image_thumb8.png" width="580" height="448" border="0" /></a>

The list of approved agents is shown in Alert Context:

<a href="http://blog.tyang.org/wp-content/uploads/2014/02/image9.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2014/02/image_thumb9.png" width="580" height="258" border="0" /></a>

As shown in above alert, in my lab, I have configured the rule to approve any agents that have "CLIENT" as part of the computer name and the the domain name is exactly "corp.tyang.org". It found 2 agents pending approval, since MaxToApprove value is set to 2, both agents are approved.

<strong><span style="color: #ff0000;">Note:</span></strong> the rule uses case insensitive match (PowerShell –imatch operator). If you need help with building your regular expression, this article is a good starting point:

<a href="http://social.technet.microsoft.com/wiki/contents/articles/4310.powershell-working-with-regular-expressions-regex.aspx">PowerShell: Working With Regular Expressions (regex)</a>

I wrote this rule for the upcoming OpsMgr agents migration at work. As part of the System Center 2012 upgrade project that I have been working on over the last year or so, we will be migrating around 30,000 agents from 2 OpsMgr 2007 R2 management groups to 3 OpsMgr 2012 R2 management groups. I still remember the pain we have gone through couple of years ago when we added over 20,000 desktop computers into OpsMgr 2007 R2. at that time, to save us time manually approve these agents, I temporarily made the configuration change to allow OpsMgr to auto approve all manual agents. Although we have staged the agent rollout in ConfigMgr, we still had issues in OpsMgr as the management servers just couldn’t keep up with the load and most of the agents where showing Not Monitored with a green circle even days after been added to the management group.

So I would think this rule is like the bouncer standing in front of the night club. it will only allow someone you like to come in, and it also controls how many you will let in at once (so the night club don’t get too crowded). It will also make sure agents don’t get added to the wrong management group when there are multiple management groups in the environment.

I would also use this rule in conjunction with the auto balancing management servers rule from the same management pack, so after the agents are approved, they are balanced across multiple management servers.

<strong>New Monitor: Detect if each individual management server is in maintenance mode</strong>

This new monitor is called <strong>"OpsMgr 2012 Self Maintenance Local Management Server in Maintenance Mode Monitor"</strong>. Previously, I wrote another monitor in this MP called "OpsMgr 2012 Self Maintenance Management Servers in Maintenance Mode Monitor".

Writing a workflow to detecting if someone is in maintenance mode could be tricky in OpsMgr. because if you are in maintenance mode, you would unload all workflows and therefore it would not run the maintenance mode detection workflow. This is why when I wrote the original monitor, I targeted the monitor to run on "All Management Servers Resource Pool". However, it has a limitation that it will only generate alerts when more than 50% of members of "All Management Servers Resource Pool" is healthy and not in maintenance mode.

With the new monitor, I was inspirited by Kevin Holman’s recent blog article <a href="http://blogs.technet.com/b/kevinholman/archive/2014/01/19/how-to-create-workflows-that-wont-go-into-maintenance-mode.aspx">How to create workflows that wont go into Maintenance Mode</a> (Thanks Kevin!). As Kevin explained in his blog article, in order to make this monitor to run on each individual management server and continues to run even when its Windows Computer object has been placed into maintenance mode, I have created an unhosted class called "OpsMgr 2012 Self Maintenance Management Server Maintenance Mode Watcher". This object is discovered on each management server and it is not hosted by the Windows Computer. By doing so, this monitor will continue to run even when the management server’s Windows Computer object has been placed into maintenance mode.

A recovery task is also associated to this monitor (disabled by default). When enabled, it will automatically end the maintenance mode for the management server.

As the standard for the Self Maintenance MP, all workflows are disabled by default. Therefore, the object discovery for the Maintenance Mode Watcher class, this monitor itself and associated recovery task are all disabled by default.

<strong><span style="color: #ff0000;">Note:</span> </strong>In order to utilise this monitor, the object discovery and the monitor itself will need to be enabled via overrides. Optionally, the recovery task can also be enabled if you want the monitor to automatically end the maintenance mode for the management servers.

Object Discovery:

<a href="http://blog.tyang.org/wp-content/uploads/2014/02/image10.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2014/02/image_thumb10.png" width="580" height="220" border="0" /></a>

Monitor:

<a href="http://blog.tyang.org/wp-content/uploads/2014/02/image11.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2014/02/image_thumb11.png" width="580" height="230" border="0" /></a>

Recovery Task:

<a href="http://blog.tyang.org/wp-content/uploads/2014/02/image12.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2014/02/image_thumb12.png" width="580" height="566" border="0" /></a>

<strong><span style="color: #ff0000;">Note:</span></strong> I purposely did not create a state view for the Maintenance Mode Watcher objects. I don’t want normal operators to see these objects (so they can place the watcher objects into maintenance mode directly).

When I placed All 3 management servers in my lab into maintenance mode:

<a href="http://blog.tyang.org/wp-content/uploads/2014/02/image13.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2014/02/image_thumb13.png" width="535" height="154" border="0" /></a>

The maintenance mode watcher objects became unhealthy:

<a href="http://blog.tyang.org/wp-content/uploads/2014/02/image14.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2014/02/image_thumb14.png" width="580" height="150" border="0" /></a>

An alert was generated for each management server:

<a href="http://blog.tyang.org/wp-content/uploads/2014/02/image15.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2014/02/image_thumb15.png" width="580" height="177" border="0" /></a>

From the screenshot above, you can see that other alerts were generated for various resource pools heartbeat failures because all management servers are in maintenance mode. In this scenario, the old monitor that targets the "All Management Servers Resource Pool" would not work.

When I enabled the recovery task, the management server has been taken out of maintenance mode automatically:

<a href="http://blog.tyang.org/wp-content/uploads/2014/02/image16.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2014/02/image_thumb16.png" width="580" height="522" border="0" /></a>

As shown in above screenshot, I placed a management server into maintenance mode for 30 minutes (as shown in the MaintModeDetails), because I configured the monitor to run every 1 minute, on 11:57PM local time, (within 1 minute of the maintenance mode start time), the monitor detected the management server was in maintenance mode, and the recovery task has ended the maintenance mode.

<strong><span style="color: #ff0000;">Note:</span></strong> Please enable this recovery task with caution. i.e. If the monitor is configured to run every 5 minutes, you will never be able to place a management server into maintenance mode for more than 5 minutes. It may not always be desired.

The updated MP and documentation can be downloaded <a href="http://blog.tyang.org/wp-content/uploads/2014/02/OpsMgr.2012.Self_.Maintenance.MP_.2.3.0.01.zip">HERE</a>.

As always, please feel free to contact me if you have any feedbacks.