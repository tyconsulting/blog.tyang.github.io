---
id: 3714
title: Updated Management Pack for Windows Server Logical Disk Auto Defragmentation
date: 2015-02-17T21:38:11+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=3714
permalink: /2015/02/17/updated-management-pack-for-windows-server-logical-disk-auto-defragmentation/
categories:
  - SCOM
tags:
  - Management Pack
  - SCOM
---
<h3><a href="http://blog.tyang.org/wp-content/uploads/2015/02/defrag.png"><img style="background-image: none; float: left; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="defrag" src="http://blog.tyang.org/wp-content/uploads/2015/02/defrag_thumb.png" alt="defrag" width="176" height="176" align="left" border="0" /></a>Background</h3>
I have been asked to automate Hyper-V logical disk defragmentation to address a wide-spread production issue at work. Without having a second look, I went for the famous <a href="http://blogs.catapultsystems.com/cfuller/archive/2013/10/24/automated-defragmentation-using-opsmgr-for-windows-2003-2008-and-2012-scom-sysctr-winserv-powershell.aspx">Autodefrag MP</a> authored by my friend and SCCDM MVP Cameron Fuller.

Cameron’s MP was released in Octorber, 2013, which is around 1.5 year ago. When I looked into Cameron’s MP, I realised unfortunately, it does not meet my requirements.

I had the following issues with Cameron’s MP:
<ul>
	<li>The MP schema is based on version 2 (OpsMgr 2012 MP schema), which prevents it from being used in OpsMgr 2007. This is a show stopper for me as I need to use it on both 2007 and 2012 management groups.</li>
	<li>The monitor reset PowerShell script used in the AutoDefrag MP uses OpsMgr 2012 PowerShell module, which won’t work with OpsMgr 2007.</li>
	<li>The AutoDefrag MP was based on Windows Server OS MP version 6.0.7026. In this version, the fragmentation monitors are enabled by default. However, since version 6.0.7230, these fragmentation monitors have been changed to be <strong><span style="text-decoration: underline;">disabled</span></strong> by default. Therefore, the overrides in the AutoDefrag MP to disable these monitors become obsolete since they are already disabled.</li>
</ul>
In the end, I have decided to rewrite this MP, but it’s still based on Cameron’s original logics.
<h3>New MP: Windows Server Auto Defragment</h3>
I’ve given the MP a new name: Windows Server Auto Defragment (ID: Windows.Server.Auto.Defragment).

The MP includes the following components:

<strong>Diagnostic Tasks: Log defragmentation to the Operations Manager Log</strong>

There are 3 identical diagnostic tasks (for Windows Server 2003, 2008 and 2012 logical disk fragmentation monitors). These tasks log an event log entry to agent’s Operations Manager log before the defrag recovery tasks starts.

<strong>Group: Drives to Enable Fragmentation Monitoring</strong>

This is an empty instance group. Users can place logical disks into this group to enable the “Logical Disk Fragmentation Level” monitors from the Microsoft Windows Server OS MPs.

You may add any instances of the following classes into this group:
<ul>
	<li>Windows Server 2003 Logical Disk</li>
	<li>Windows Server 2008 Logical Disk</li>
	<li>Windows Server 2012 Logical Disk</li>
</ul>
&nbsp;

<strong>Group: Drives to Enable Auto Defrag</strong>

This is an empty instance group. Users can place logical disks into this group to enable the diagnostic and recovery tasks for auto defrag.

You may add any instances of the following classes into this group:
<ul>
	<li>Windows Server 2003 Logical Disk</li>
	<li>Windows Server 2008 Logical Disk</li>
	<li>Windows Server 2012 Logical Disk</li>
</ul>
&nbsp;

<strong>Group: Drive to Enable Fragmentation Level Performance Collection</strong>

This is an empty instance group. Users can place logical disks into this group to enable the Windows Server Fragmentation Level Performance Collection Rule.

<span style="color: #ff0000;">Note:</span> Since this performance collection rule is targeting the “Logical Disk (Server)” class, which is the parent class of OS specific logical disk classes, you can simply add any instances of the “Logical Disk (Server)” class into this group.

<strong>Event Collection Rule: Collect autodefragmentation event information</strong>

This rule collects the event logged by the “Log defragmentation to the Operations Manager Log” diagnostic tasks.

<strong>Reset Disk Fragmentation Health Rule</strong>

This rule is targeting the RMS / RMS Emulator, it runs every Monday at 12:00 and resets any unhealthy instances of disk fragmentation monitors back to healthy (so the monitor regular detection and recovery would run again next weekend).

<strong>Auto Defragmentation Event Report</strong>

This report lists all auto defragmentation events collected by the event collection rule within a specified time period

<a href="http://blog.tyang.org/wp-content/uploads/2015/02/image1.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/02/image_thumb1.png" alt="image" width="641" height="458" border="0" /></a>

<strong>Windows Server Fragmentation Level Performance Collection Rule</strong>

This rule collects the File Percent Fragmentation counter via WMI for Windows server logical disks. This rule is disabled by default.

If a logical drive has been placed into all 3 above groups as I mentioned above, you’d probably see a performance graph similar to this:

<a href="http://blog.tyang.org/wp-content/uploads/2015/02/image2.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/02/image_thumb2.png" alt="image" width="638" height="157" border="0" /></a>

As shown in above figure, Number 1 indicates the monitor has just ran and the defrag recovery task was executed, the drive has been defragmented. Number 2, 3 and 4 indicates the fragmentation level is slowly building up over the week and hopefully you’ll see this similar pattern on a weekly interval (because the fragmentation level monitor runs once a week by default).

<strong>Various views</strong>

The MP also contains various views under the “Windows Server Logical Drive Auto Defragment” folder:

<a href="http://blog.tyang.org/wp-content/uploads/2015/02/image3.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/02/image_thumb3.png" alt="image" width="332" height="142" border="0" /></a>
<h3>What’s Changed from the Original AutoDefrag MP?</h3>
Comparing with Cameron’s original MP, I have made the following changes in the new version:
<ul>
	<li>The MP is based on MP schema version 1, which works with OpsMgr 2007 (as well as OpsMgr 2012).</li>
	<li>Changed the minimum version of all the referencing Windows Server MPs to 6.0.7230.0 (where the fragmentation monitors became disabled by default).</li>
	<li>Sealed the Windows Server Auto Defragment MP. However, in order to allow users to manually populate groups, I have placed the group discoveries into an unsealed MP “Windows Server Auto Defragment Group Population”. By doing so, all MP elements are protected (in the sealed MP), but still allowing users to use the groups defined in the MP to manage auto defrag behaviours.</li>
	<li>Changed the monitor overrides from disabled to enabled because these monitors are now disabled by default. This means the users will now need to manually <strong><span style="text-decoration: underline;">INCLUDE</span></strong> the logical disks to be monitored rather than excluding the ones they don’t want.</li>
	<li>Replaced the Linked Report with a report to list auto defrag events.</li>
	<li>Additional performance collection rule to collect the File Percent Fragmentation counter via WMI. This rule is also disabled by default. It is enabled to a group called “Drives to Enable Fragmentation Level Performance Collection”</li>
	<li>Updated the monitor reset script to use SDK directly. This change is necessary in order to make it work for both OpsMgr 2007 and 2012. The original script would reset the monitor on every instance, the updated script would only reset the monitors for the unhealthy instances. Additionally, the monitor reset results are written to the RMS / RMSE’s Operations Manager log.</li>
	<li>Updated LogDefragmentation.vbs script for the diagnostic task to use MOM.ScriptAPI to log the event to Operations Manager log instead of the Application log.</li>
	<li>Updated message in LogDefragmentation.vbs from “"Operations Manager has performed an automated defragmentation on this system” to “Operations Manager will perform an automated defragmentation for &lt;Drive Letter&gt; drive on &lt;Server Name&gt;” – Because this diagnostic task runs at the same time as the recovery task, so the defrag is just about to start, not finished yet, I don’t believe the message should use past tense.</li>
	<li>Updated the diagnostic tasks to be disabled by default.</li>
	<li>Created overrides to enable the diagnostics for the “Drives to Enable Auto Defrag” group (same group where the recovery tasks are enabled).</li>
	<li>Updated the Data Source module of the event collection rule to use “Windows!Microsoft.Windows.ScriptGenerated.EventProvider” and it is only looking for event ID 4 generated by the specific script (LogDefragmentation.vbs). –by using this data source module, we can filter by the script name to give us more accurate detection.</li>
</ul>
&nbsp;
<h3>How do I configure the management pack?</h3>
Cameron suggested me to use the 5 common scenarios from his original post when explaining different monitoring requirements. In Cameron’s post, he has listed the following 5 scenarios:

<em><strong>01. We do not want to automate defragmentation, but we want to be alerted to when drives are highly fragmented.</strong></em>

In this case, you will need to place the drives that you want to monitor in the “<strong>Drives to Enable Fragmentation Monitoring</strong>” group.

<strong>02. We want to i<em>gnore disk fragmentation levels completely</em>.</strong>

In this case, you don’t need to import this management pack at all. Since the fragmentation monitors are now disabled by default, this is the default configuration.

<strong><em>03. We want to auto defragment all drives</em>.</strong>

In this case, you will need to place all the drives that you want to auto defrag into 2 groups:
<ul>
	<li>Drives to Enable Fragmentation Monitoring</li>
	<li>Drives to Enable Auto Defrag</li>
</ul>
<em><strong>04. We want to auto defragment all drives but disable monitoring for fragmentation on specific drives.</strong></em>

Previously when Cameron released the original version, he needed to work on an exclusion logic because the fragmentation monitors were enabled by default. With the recent releases of Windows Server OS Management Packs, we need to work on a inclusion logic instead. So, in this case, you will need to add all drives that you want to monitor fragmentation level to the “Drives to Enable Fragmentation Monitoring” group, and put a subset of these drives to “Drives to Enable Auto Defrag” group.

<strong><em>05. We want to</em> a<em>uto defragment all drives but disable automated defragmentation on specific drives</em>.</strong>

This case would be similar to case #3: you will need to place the drives that you are interested in into these 2 groups:
<ul>
	<li>Drives to Enable Fragmentation Monitoring</li>
	<li>Drives to Enable Auto Defrag</li>
</ul>
In addition to these 5 scenarios, another scenario this MP is catered for is:

<em><strong>06. We want to collect drive fragmentation level as performance data</strong></em>

In this case, if you want to simply collect the fragmentation level as perf data (with or without fragmentation monitoring), you will need to add the drives that you are interested in into the “<strong>Drives to Enable Fragmentation Level Performance Collection</strong>” group.

<strong>So, How do I configure these groups?</strong>

By default, I have configured these groups to have a discovery rule to discover nothing on purpose:

<a href="http://blog.tyang.org/wp-content/uploads/2015/02/image4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/02/image_thumb4.png" alt="image" width="601" height="266" border="0" /></a>

As you can see, the default group discoveries are looking for any logical drives with the device name (drive letter) matches regular expression <strong>^$</strong>. “^$” represent blank / null value. Since all the discovered logical device would have a device name, these groups will be empty. You will need to modify the group memberships to suit your needs.

For example, if you want to include C: drive of all the physical servers, the group membership could be something like this:

<a href="http://blog.tyang.org/wp-content/uploads/2015/02/grouppop.png"><img class="alignnone  wp-image-3718" src="http://blog.tyang.org/wp-content/uploads/2015/02/grouppop.png" alt="grouppop" width="602" height="590" /></a>
<ul><!--EndFragment--></ul>
<span style="color: #ff0000;">Note:</span> In SCOM, only Hyper-V VMs are discovered as virtual machines. if you are running other hypervisors, the “virtual machine” property probably wont work.
<h3>MP Download</h3>
There are 2 management pack files included in this solution. You can download them <a href="http://blog.tyang.org/wp-content/uploads/2015/02/Windows.Server.Auto_.Defrag.zip">HERE</a>.

<a href="http://blog.tyang.org/wp-content/uploads/2015/02/image6.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/02/image_thumb6.png" alt="image" width="543" height="85" border="0" /></a>
<h3>Credit</h3>
Thanks Cameron for sharing the original MP with the community and providing guidance, review and testing on this version. I’d also like to thank all other OpsMgr focused MVP folks who have been involved in this discussion.

Lastly, as always, please feel free to contact me if you have questions / issues with this MP.