---
id: 174
title: Balancing Number of SCOM Agent Per Management Server using PowerShell
date: 2010-08-11T17:54:24+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=174
permalink: /2010/08/11/balancing-number-of-scom-agent-per-management-server-using-powershell/
categories:
  - PowerShell
  - SCOM
tags:
  - Failover Management Servers
  - PowerShell
  - Primary Management Server
  - SCOM agent assignments
---
I came across a situation yesterday in one of the clients SCOM environment:

They currently have a single SCOM management group setup as the following:

<a href="https://blog.tyang.org/wp-content/uploads/2010/08/Drawing2.jpg"><img style="border: 0px;" src="https://blog.tyang.org/wp-content/uploads/2010/08/Drawing2_thumb.jpg" border="0" alt="Drawing2" width="551" height="321" /></a>
<ol>
	<li>all SCOM management servers (including the root management server) are located on the same segment of the network.</li>
	<li>internal agents (from the same forest) are reporting to management server #1 and #2.</li>
	<li>External agents (from different forests) are reporting to management server #3 and #4 through firewall.</li>
	<li>SCOM is not integrated to AD – Therefore primary and failover management servers are not automatically assigned to agents.</li>
</ol>
<strong>I needed to achieve:</strong>
<ol>
	<li>agents are evenly distributed to the Internal and external management servers.</li>
	<li>all other management servers in the same group are assigned as failover management servers.</li>
	<li>For Example, there are 513 agent managed computers in internal network. They need to be evenly spread between management server #1 and #2 (so one management server will have 256 agents and the other will have 257 agents). All agents hanging off management server #1 will have #2 assigned as failover management server and vice versa.</li>
</ol>
I wrote <a href="https://blog.tyang.org/wp-content/uploads/2010/08/Balance-ManagementServers.zip">this PowerShell script</a> for this task. if you create a Windows scheduled task and run it on a regular basis, you’ll ensure all your SCOM agents are evenly assigned to a group of management servers and have correct settings for failover management servers.

The script does so by doing the following:
<ol>
	<li>Work out total number of agents that are currently hanging off the management servers specified in the script (line 33-37):</li>
	<p />
	<a href="https://blog.tyang.org/wp-content/uploads/2010/08/image.png"><img style="border: 0px;" src="https://blog.tyang.org/wp-content/uploads/2010/08/image_thumb.png" border="0" alt="image" width="580" height="62" /></a>
	<li>Work out which management servers are over average and which ones are below average</li>
	<li>Go through each one that’s over the average, move agents to another random management server until it reaches the average number.</li>
	<li>after each agent move, check the destination management server, make sure it is still under the average number, otherwise, remove it from the pool of under average management servers.</li>
	<li>Go through the remaining agents on each management server and make sure they are set to use all the other management servers as failover management servers.</li>
</ol>
<strong>Note: PowerShell Version 2 is required to run this script! This script can only run on the root management server. if you want to run it somewhere else, please modify line 15 of the script to have the correct FQDN of your RMS server.</strong>