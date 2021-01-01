---
id: 4291
title: OpsMgr Group Health Rollup Configuration Task Management Pack
date: 2015-07-28T20:11:15+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=4291
permalink: /2015/07/28/opsmgr-group-health-rollup-configuration-task-management-pack/
categories:
  - SCOM
tags:
  - Management Pack
  - SCOM
---
<h3>Introduction</h3>
In OpsMgr, groups are frequently used when designing service level monitoring and dashboards. The group members’ health rollup behaviours can be configured by creating various dependency monitors targeting against the group.

When creating groups, only instance groups can be created within the OpsMgr console. Unlike computer groups, instance groups do not inherit any dependent monitors from their base class. Therefore when an instance group is created in the OpsMgr console, by default, the health state of the group is “Not monitored” (Uninitialized):

<a href="http://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTML6ecbad9.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML6ecbad9" src="http://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTML6ecbad9_thumb.png" alt="SNAGHTML6ecbad9" width="608" height="193" border="0" /></a>

In order to configure group members to rollup health state to the group object (so the group can be used in dashboards), one or more dependency monitors must be created manually after the group has been created. This manual process can be time consuming.

Squared Up has recognised this issue, and many of their customers have also asked for a way to simplify the process of configuring health roll-up for the groups (so the groups can be used in Squared Up dashboards).

Squared Up has engaged me and asked me to develop an agent task to configure group health rollup and make it available to the broader OpsMgr community.

The “OpsMgr group health Rollup Configuration Task Management Pack” provides an agent task to create dependency monitors for the selected groups using OpsMgr SDK.

<a href="http://blog.tyang.org/wp-content/uploads/2015/07/image39.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/07/image_thumb39.png" alt="image" width="644" height="290" border="0" /></a>
<h3>Management Pack Overview</h3>
In order for the OpsMgr operators to easily navigate to the groups, this management pack provides a state view for all groups (System.Group class):

<a href="http://blog.tyang.org/wp-content/uploads/2015/07/image40.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/07/image_thumb40.png" alt="image" width="544" height="321" border="0" /></a>

Although a set of required parameters are pre-configured for the agent task, the operators can also modify these parameters using overrides.

The following parameters can be customized via overrides:

<a href="http://blog.tyang.org/wp-content/uploads/2015/07/image41.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/07/image_thumb41.png" alt="image" width="576" height="445" border="0" /></a>
<ul>
	<li><b>Health Rollup Policy</b><b>：</b> Possible values: 'BestOf', 'WorstOf','Percentage'.</li>
	<li><b>Worst state of the percentage in healthy state</b><b>：</b> Integer between 1 and 100. Only used when Algorithm is set to 'Percentage'.</li>
	<li><b>Member Unavailable Rollup As</b><b>：</b> Possible Values: 'Uninitialized', 'Success ', 'Warning' and 'Error'</li>
	<li><b>Member in Maintenance Mode Rollup As</b><b>：</b> 'Uninitialized', 'Success', 'Warning' and 'Error'</li>
	<li><b>Management Pack Name</b><b>：</b> The Management Pack name of which the monitors going to be saved. Only used when the group is defined in a sealed MP.'</li>
	<li><b>Increase Management Pack version by 0.0.0.1</b><b>：</b> Specify if the management pack version should be increased by 0.0.0.1.</li>
</ul>
<span style="color: #ff0000;"><b>NOTE</b>: </span>Please <b><u>DO NOT</u></b> select multiple instance groups at once.

After the task is executed against a group, 4 dependency monitors are created:
<ul>
	<li>Availability Dependency Monitor</li>
	<li>Configuration Dependency Monitor</li>
	<li>Performance Dependency Monitor</li>
	<li>Security Dependency Monitor</li>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTML7326e1c.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML7326e1c" src="http://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTML7326e1c_thumb.png" alt="SNAGHTML7326e1c" width="619" height="461" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2015/07/image42.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/07/image_thumb42.png" alt="image" width="455" height="237" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2015/07/image43.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/07/image_thumb43.png" alt="image" width="339" height="363" border="0" /></a>
<h3>Security Consideration</h3>
Natively in OpsMgr, only user accounts assigned either authors role or administrators role have access to create monitors. However, users with lower privileges (such as operators and advanced operators) can potentially execute this task and create dependency monitors.

Please keep this in mind when deploying this management pack. You may need to scope user roles accordingly to only allow appropriate users have access to this task.
<h3>Credit</h3>
Thanks Squared Up for making this management pack free to the community.
<h3>Download</h3>
This management pack can be downloaded from the link below:

[wpdm_package id='4275']