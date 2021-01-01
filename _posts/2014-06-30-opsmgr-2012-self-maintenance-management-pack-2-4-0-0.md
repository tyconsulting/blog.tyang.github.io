---
id: 2892
title: OpsMgr 2012 Self Maintenance Management Pack 2.4.0.0
date: 2014-06-30T15:37:33+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=2892
permalink: /2014/06/30/opsmgr-2012-self-maintenance-management-pack-2-4-0-0/
categories:
  - SCOM
tags:
  - Featured
  - MP Authoring
  - SCOM
---
This blog has been a bit quiet lately because of 2 reasons: FIFA World Cup and I’ve been updating the OpsMgr 2012 Self Maintenance MP. :)

<strong>What’s new in version 2.4.0.0?</strong>
<ul>
	<li>Corrected spelling mistake in Management Server maintenance mode watcher display name</li>
	<li>Updated knowledge article for OpsMgr 2012 Self Maintenance Detect Manually Closed Monitor Alerts Rule</li>
	<li>Additional Monitor: OpsMgr 2012 Self Maintenance Management Server Default Action Account OpsMgr Admin Privilege Monitor</li>
	<li>Additional Monitor: OpsMgr 2012 Self Maintenance Management Server Default Action Account Local Admin Privilege Monitor</li>
	<li>Additional Rule: OpsMgr 2012 Self Maintenance Obsolete Management Pack Alias Detection Rule</li>
	<li>Additional Agent Task: Get Workflow Name(ID)</li>
	<li>Additional Agent Task: Reset Monitor Health State</li>
	<li>Additional Agent Task: Remove Obsolete MP References</li>
</ul>
<strong>Additional Monitors to check if management servers action account has local admin on management servers and OpsMgr privileges</strong>

I often get emails from people who are having issues configuring workflows in the Self Maintenance MP. I found one of a common issues is that the default action account for management servers does not required privileges. Therefore I created 2 monitors in this release to monitor if the MS action account has local administrator and OpsMgr administrator privileges.

<a href="http://blog.tyang.org/wp-content/uploads/2014/06/image7.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/06/image_thumb7.png" alt="image" width="550" height="539" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2014/06/image8.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/06/image_thumb8.png" alt="image" width="558" height="549" border="0" /></a>

<strong>Additional Rule: OpsMgr 2012 Self Maintenance Obsolete Management Pack Alias Detection Rule</strong>

As I mentioned in my previous post <a href="http://blog.tyang.org/2014/06/24/powershell-script-remove-obsolete-references-unsealed-opsmgr-management-packs/">PowerShell Script: Remove Obsolete References from Unsealed OpsMgr Management Packs</a>, I’ve created a rule that detects obsolete MP references in unsealed management packs. The difference between the stand alone script (from previous post) and this rule is, this rule would only detect obsolete MP references, it will not try to remove them. Operators can use the “Remove Obsolete MP References” agent task manually remove them (or using the standalone script I published earlier).

<a href="http://blog.tyang.org/wp-content/uploads/2014/06/image9.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/06/image_thumb9.png" alt="image" width="529" height="549" border="0" /></a>

<strong>Additional Agent Task: Remove Obsolete MP References</strong>

This task targets All Management Servers Resource Pool and can be used in conjunction with the Obsolete Management Pack Alias Detection Rule to delete obsolete MP references from unsealed management packs.

<a href="http://blog.tyang.org/wp-content/uploads/2014/06/SNAGHTML5ed69f2.png"><img style="display: inline; border: 0px;" title="SNAGHTML5ed69f2" src="http://blog.tyang.org/wp-content/uploads/2014/06/SNAGHTML5ed69f2_thumb.png" alt="SNAGHTML5ed69f2" width="536" height="557" border="0" /></a>

<strong>Additional Agent Tasks: “Get Workflow Name(ID)” and “Reset Monitor Health State”</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2014/06/image10.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/06/image_thumb10.png" alt="image" width="242" height="292" border="0" /></a>

Previously, few people have suggested me to provide a method to reset all instances of a particular monitor. Recently, Cameron Fuller showed me a script from Matthew Dowst’s <a href="http://blogs.catapultsystems.com/mdowst/archive/2014/05/15/scom-monitor-reset-script.aspx">blog post</a> and suggested me to add this into the Self Maintenance MP.

The script from Matthew’s blog resets health state of all instances of monitors with a given display name. In my opinion, this is not granular enough as there are monitors sharing same display name, we can not use display name to uniquely identify a particular monitor.

i.e.

<a href="http://blog.tyang.org/wp-content/uploads/2014/06/image11.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/06/image_thumb11.png" alt="image" width="580" height="285" border="0" /></a>

Therefore, when I was writing the script for the Reset Monitor Health State agent task, I used monitor name instead of display name. However, since the monitor name is actually not viewable in the Operations Console, I had to create another agent task to get the name of a workflow (monitors, rules and discoveries).

i.e. let’s use the “Computer Browser Service Health” monitors as an example.

Get the monitor(s) using SCOM PowerShell Module:

<a href="http://blog.tyang.org/wp-content/uploads/2014/06/image12.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/06/image_thumb12.png" alt="image" width="580" height="523" border="0" /></a>

In my environment, there are 2 monitors that have the same display name. the actual monitor name is highlighted in the red rectangles. the names are unique. It is actually the MP element ID in the management pack where the monitor is coming from:

<a href="http://blog.tyang.org/wp-content/uploads/2014/06/image13.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/06/image_thumb13.png" alt="image" width="580" height="225" border="0" /></a>

So in order to use the “Reset Monitor Health State” task, operators firstly need to identify the monitor name (MP element ID), then paste it into an override field of the task. To make it easier, we can use the “Get Workflow Name(ID)” agent task to get the name:

<a href="http://blog.tyang.org/wp-content/uploads/2014/06/image14.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/06/image_thumb14.png" alt="image" width="580" height="573" border="0" /></a>

Then copy and paste the monitor name into the “MonitorName” override parameter of the “Reset Monitor Health State”:

<a href="http://blog.tyang.org/wp-content/uploads/2014/06/image15.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/06/image_thumb15.png" alt="image" width="580" height="345" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2014/06/image16.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/06/image_thumb16.png" alt="image" width="443" height="499" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2014/06/image17.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/06/image_thumb17.png" alt="image" width="489" height="501" border="0" /></a>

<strong>Where to find the detailed information for these additional items?</strong>

I have only covered a very high level overview of these additional workflows in this post. the detailed information can be found in the updated MP documentation (From Section 5.2.24 to 5.2.29):

<a href="http://blog.tyang.org/wp-content/uploads/2014/06/image18.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/06/image_thumb18.png" alt="image" width="580" height="203" border="0" /></a>

<strong><span style="text-decoration: underline;"><span style="color: #ff0000;">Please make sure you read each section before enabling / using each workflow!</span></span></strong>

<strong>Credit</strong>

I’d like to thank Cameron Fuller, Bob Cornelissen and Raphael Burri for the suggestions and testing effort. Also, thanks Matthew Dowst for the original scripts in his posts.

Lastly, if you have suggestions or issues / questions that are not documented in the documentation, please feel free to contact me.

<strong><a href="http://blog.tyang.org/wp-content/uploads/2014/06/OpsMgr-2012-Self-Maintenance-MP-2.4.0.0.zip">DOWNLOAD LINK</a></strong>