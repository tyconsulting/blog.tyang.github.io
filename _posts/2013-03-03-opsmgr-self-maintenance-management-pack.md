---
id: 1726
title: OpsMgr Self Maintenance Management Pack
date: 2013-03-03T22:12:53+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=1726
permalink: /2013/03/03/opsmgr-self-maintenance-management-pack/
image: /wp-content/uploads/2013/03/maintenance_image.jpg
categories:
  - SCOM
tags:
  - Featured
  - SCOM
  - SCOM Management Pack
---
<h1><span style="font-size: x-large;">Background</span></h1>
I had this idea to automate some repetitive maintenance tasks that every SCOM administrator perform regularly via a management pack. So I started to write a OpsMgr self maintenance MP during my spare time around July last year, right after my baby girl Rosie was born. since then, I’ve got side-tracked many times, i.e. left for TechEd in September for a week, studying for ConfigMgr 2012 exam, studying for the 3 Windows Server 2012 MCSA exams, writing other management packs such as the Weather monitoring MP, etc. This MP has been sitting there 90% completed for months.

Few of weeks ago, I passed all 3 Windows Server 2012 exams required for MCSA, and got a phone call from my friend Dan Kregor. Dan told me he wanted to write a maintenance MP for OpsMgr, and I told him I’ve got one 90% done. So we got together, went through what needed to be included and Dan gave me some good ideas. Over last few weeks, I have spent most of my spare time working on this MP. Initially this MP was only designed for 2007 (which would also work on 2012), I then decided to build a 2012 version (based on OpsMgr 2012 MP schema) so the MP can utilise resource pools. There are also few additional rules / monitors in the 2012 version. Anyways, I’ve now finally finished both version of the MP. Below paragraphs are ripped from the MP documentation:
<h1><span style="font-size: x-large;">Introduction</span></h1>
OpsMgr Self Maintenance Management Pack automates some routine tasks generally performed by OpsMgr administrators on a regular basis. It also provides few rules / monitors to monitor the OpsMgr management group itself. This management pack contains 2 version.
<ul>
	<li>The OpsMgr 2007 R2 version works on both 2007 R2 and 2012 versions of OpsMgr.</li>
	<li>The OpsMgr 2012 version only works on OpsMgr 2012.</li>
</ul>
The 2012 version of this management pack is able to utilize OpsMgr 2012 resource pools and also provides additional rules and monitors than the 2007 version. For OpsMgr 2012 environments, it’s strongly recommended to use the 2012 version of this management pack.

The following workflows are included in this management pack:
<ul>
	<li>Automatically balance OpsMgr agents among a group of management servers.</li>
	<li>Automatically close aged rule-generated alerts</li>
	<li>Convert all manually installed OpsMgr agents to Remote-Manageable.</li>
	<li>Enable Agent-Proxy for all agents</li>
	<li>Backup Unsealed (and Sealed) management packs.</li>
	<li>Remove Disabled discovery objects</li>
	<li>Detect staled stage change events</li>
	<li>Monitoring the size of LocalizedText able from the OpsMgr operational database.</li>
	<li>Detects OpsMgr management servers in maintenance mode (Only available in OpsMgr 2012 version of the MP)</li>
	<li>Performance Collection rule for total number of SDK connection within the management group (among all management servers). (Only available in OpsMgr 2012 version of the MP).</li>
	<li>Agent tasks for:
<ul>
	<li>Manually backup management packs</li>
	<li>Get currently connected users to the SDK service</li>
	<li>Enable Agent Proxy for all agents.</li>
</ul>
</li>
</ul>
All the rules and monitors from the OpsMgr Self Maintenance management packs are disabled by default. This is to ensure OpsMgr administrators only turn on the workflows that are required for the OpsMgr environments they support and configure the required parameters for workflows to suit the environment.

The agent tasks from the management packs are enabled by default.

An unsealed override management pack is provided for each version of the OpsMgr Self Maintenance MP. OpsMgr administrators can use provided unsealed override MP for customization or they can also create their own override MPs for this purpose.
<h1><span style="font-size: x-large;">Credit</span></h1>
I’d like to thank Dan Kregor for sharing ideas with me and taking time testing the MP.

I appreciate any feedback from the community, this is only the first release, any thoughts on additional workflows that I can build into this MP is much appreciated!

Both versions of the management packs and the documentation can be downloaded <a href="http://blog.tyang.org/wp-content/uploads/2013/03/OpsMgr-Self-Maintenance.zip">HERE</a>.