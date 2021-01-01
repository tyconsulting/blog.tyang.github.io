---
id: 4625
title: OpsMgr Self Maintenance Management Pack 2.5.0.0
date: 2015-09-16T22:15:32+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=4625
permalink: /2015/09/16/opsmgr-self-maintenance-management-pack-2-5-0-0/
categories:
  - SCOM
tags:
  - Featured
  - Management Pack
  - MP Authoring
  - SCOM
---
<a href="http://blog.tyang.org/wp-content/uploads/2015/09/OMSelfMaintMPIcon.png"><img style="background-image: none; float: left; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px none;" title="OMSelfMaintMPIcon" src="http://blog.tyang.org/wp-content/uploads/2015/09/OMSelfMaintMPIcon_thumb.png" alt="OMSelfMaintMPIcon" width="125" height="122" align="left" border="0" /></a><span style="color: #ff0000;">26/10/2015 Update: It has been identified the unsealed override MP was not included in the download, and also there was a small error in "Known Issue" section (section 8) of the MP guide. Therefore I have just updated the download which now included the override MP and updated MP guide. However, if you have already downloaded the version 2.5.0.1, and only after the override MP, you can download it from <a href="http://blog.tyang.org/wp-content/uploads/2015/10/OpsMgr.2012.Self_.Maintenance.Overrides.zip">HERE</a>.</span>

<span style="color: #ff0000;">18/09/2015 Update: A bug has been identified in version 2.5.0.0, where the newly added Data Warehouse DB staging tables row count performance collection rules is causing issues with the Exchange Correlation service from the of Exchange MP (Please refer to the comment section of this post) because the rule category is set to "None". I have updated the category of these performance collection rules in both the Self Maintenance MP and the OMS Add-On MP. Please re-download the MP (version 2.5.0.1) if you have already downloaded it and you are using Exchange MP in your environment.</span>
<h3>Introduction</h3>
I can’t believe it has been 1 year and 3 month since the OpsMgr Self Maintenance MP was lastly updated. This is partially because over the last year or so, I have been spending a lot of time developing the OpsMgr PowerShell / SMA module OpsMgrExtended and am stilling working on the <a href="http://blog.tyang.org/tag/automating-opsmgr/">Automating OpsMgr blog series</a>.  But I think one of the main reasons is that I did not get too many new ideas for the next release. I have decided to start working on version 2.5 of the Self Maintenance MP few weeks ago, when I realised I have collected enough resources for a new release. So, after few weeks of development and testing, I’m pleased to announce the version 2.5 is ready for the general public.
<h3>What’s new in version 2.5?</h3>
<ul>
	<li>Bug Fix: corrected “Collect All Management Server SDK Connection Count Rule” where incorrect value may be collected when there are gateway servers in the management group.</li>
	<li>Additional Performance Rules for Data Warehouse DB Staging Tables row count.</li>
	<li>Additional 2-State performance monitors for Data Warehouse DB Staging Tables row count.</li>
	<li>Additional Monitor: Check if all management servers are on the same patch level</li>
	<li>Additional discovery to replace the built-in “Discovers the list of patches installed on Agents” discovery for health service. This additional discovery also discovers the patch list for OpsMgr management servers, gateway servers and SCSM servers.</li>
	<li>Additional Agent Task: Display patch list (patches for management servers, gateway servers, agents and web console servers).</li>
	<li>Additional Agent Task: Configure Group Health Rollup</li>
	<li>Updated “OpsMgr 2012 Self Maintenance Detect Manually Closed Monitor Alerts Rule” to include an option to reset any manually closed monitor upon detection.</li>
	<li>Additional Rule: “OpsMgr 2012 Self Maintenance Audit Agent Tasks Result Event Collection Rule”</li>
	<li>Additional Management Pack: “OpsMgr Self Maintenance OMS Add-On Management Pack”</li>
</ul>
<strong><span style="background-color: #ffff00;">To summarise, in my opinion, the 2 biggest features shipped in this release are the workflows built around managing OpsMgr Update Rollup patch level, and the extension to Microsoft Operations Management Suite (OMS) for the management groups that have already been connected to OMS via the new OpsMgr Self Maintenance OMS Add-On MP .</span></strong>

I will now briefly go though each item from the list above. The detailed documentation can be found in the updated MP guide.
<h4>Bug Fix: Total SDK Connection Count Perf Rule</h4>
In previous version, the PowerShell script used by the “Collect All Management Server SDK Connection Count Rule” had a bug, where the incorrect count could be collected when there are gateway servers in the management group. i.e.

<a href="http://blog.tyang.org/wp-content/uploads/2015/09/image11.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/09/image_thumb11.png" alt="image" width="493" height="214" border="0" /></a>

As shown above, when I installed a gateway server in my management group, the counter value has become incorrect and has increased significantly. This issue is now fixed.
<h4>Monitoring and Collecting the Data Warehouse DB staging tables row count</h4>
Back in the MVP Summit in November last year, my friend and fellow MVP Bob Cornelissen suggested me to monitor the DW DB staging tables row count because he has experienced issues where large amount of data were stuck in the staging tables (<a title="http://www.bictt.com/blogs/bictt.php/2014/10/10/case-of-the-fast-growing" href="http://www.bictt.com/blogs/bictt.php/2014/10/10/case-of-the-fast-growing">http://www.bictt.com/blogs/bictt.php/2014/10/10/case-of-the-fast-growing</a>). Additionally, I have already included the staging tables row count in the Data Warehouse Health Check script which was released few months ago.

In this release, the MP comes with a performance collection rule and a 2-state performance threshold monitor for each of these 5 staging tables:
<ul>
	<li>Alert.AlertStage</li>
	<li>Event.EventStage</li>
	<li>ManagedEntityStage</li>
	<li>Perf.PerformanceStage</li>
	<li>State.StateStage</li>
</ul>
The performance collection rules collect the row count as performance data and store the data in both operational DB and the Data Warehouse DB:

<a href="http://blog.tyang.org/wp-content/uploads/2015/09/SNAGHTML23ed92.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML23ed92" src="http://blog.tyang.org/wp-content/uploads/2015/09/SNAGHTML23ed92_thumb.png" alt="SNAGHTML23ed92" width="554" height="382" border="0" /></a>

The 2-State performance threshold monitors will generate critical alerts when the row count over 1000.

<a href="http://blog.tyang.org/wp-content/uploads/2015/09/SNAGHTML26712f.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML26712f" src="http://blog.tyang.org/wp-content/uploads/2015/09/SNAGHTML26712f_thumb.png" alt="SNAGHTML26712f" width="563" height="183" border="0" /></a>
<h4>Managing OpsMgr Update Rollup Patch Level</h4>
Over the last 12 months, I have heard a lot of unpleasant stories caused by inconsistent patch levels between different OpsMgr components. In my opinion, currently we have the following challenges when managing updates for OpsMgr components:
<h5>People do not follow the instructions (aka Mr Holman’s blog posts) when applying OpsMgr updates.</h5>
Any seasoned OpsMgr folks would know wait for Kevin Holman’s post for the update when a UR is released, and the order for applying the UR is also critical. However, I have seen many times that wrong orders where followed or some steps where skipped during the update process (i.e. SQL update scripts, updating management packs, etc.)
<h5>OpsMgr management groups are partially updates due to the (mis)configuration of Windows Update (or other patching solutions such as ConfigMgr).</h5>
I have heard situations where a subset of management servers were updated by Windows Update, and the patch level among management servers themselves, as well as between servers and agents are different. Ideally, all management servers should be patched together within a very short time window (together with updating SQL DBs and management packs), and agents should also be updated ASAP. Leaving management servers in different patch levels would cause many undesired issues.
<h5>It is hard to identify the patch level for management servers</h5>
Although OpsMgr administrators can verify the patch list for the agent by creating a state view for agents and select “Patch List” property, the patch list property for OpsMgr management servers and gateway servers are not populated in OpsMgr. This is because the object discovery of which is responsible for populating this property only checks the patch applied to the MSI of the OpsMgr agent. Additionally, after the update rollup has been installed on OpsMgr servers, it does not show up in the Program and Features in Windows Control Panel. Up to date, the most popular way to check the servers patch level is by checking the version of few DLLs and EXEs. Due to these difficulties, people may not even aware of the inconsistent patch level within the management group because it is not obvious and it's hard to find out.

In order to address some of these issues, and helping OpsMgr administrators to better manage the patch level and patching process, I have created the following items in this release of the Self Maintenance MP:
<h5><b>State view for Health Service which also displays the patch list:</b></h5>
<a href="http://blog.tyang.org/wp-content/uploads/2015/09/SNAGHTML48f742.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML48f742" src="http://blog.tyang.org/wp-content/uploads/2015/09/SNAGHTML48f742_thumb.png" alt="SNAGHTML48f742" width="677" height="360" border="0" /></a>
<h5>An agent task targeting Health Service to list OpsMgr components patch level:</h5>
<a href="http://blog.tyang.org/wp-content/uploads/2015/09/SNAGHTML49c996.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML49c996" src="http://blog.tyang.org/wp-content/uploads/2015/09/SNAGHTML49c996_thumb.png" alt="SNAGHTML49c996" width="672" height="372" border="0" /></a>

Because the “Patch List” property is populated by an object discovery, which only runs infrequently, in order to check the up-to-date information(of the patch list), I have created a task called “Get Current Patch List”, which is targeting the Health Service class. This task will display the patch list for any of the following OpsMgr components installed on the selected health service:

Management Servers | Gateway Servers:

<a href="http://blog.tyang.org/wp-content/uploads/2015/09/image12.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/09/image_thumb12.png" alt="image" width="347" height="407" border="0" /></a><a href="http://blog.tyang.org/wp-content/uploads/2015/09/image13.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/09/image_thumb13.png" alt="image" width="323" height="405" border="0" /></a>

Agents | Web Console (also has agent installed):

<a href="http://blog.tyang.org/wp-content/uploads/2015/09/image14.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/09/image_thumb14.png" alt="image" width="347" height="435" border="0" /></a><a href="http://blog.tyang.org/wp-content/uploads/2015/09/image15.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/09/image_thumb15.png" alt="image" width="331" height="433" border="0" /></a>
<h5>Object Discovery: OpsMgr 2012 Self Maintenance Management Server and Agent Patch List Discovery</h5>
Natively in OpsMgr, the agent patch list is discovered by an object discovery called “Discovers the list of patches installed on Agents”:

<a href="http://blog.tyang.org/wp-content/uploads/2015/09/image16.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/09/image_thumb16.png" alt="image" width="412" height="409" border="0" /></a>

As the name suggests, this discovery discovers the patch list for agents, and nothing else. It does not discover the patch list for OpsMgr management servers, gateway servers, and SCSM management servers (if they are also monitored by OpsMgr using the version of the Microsoft Monitoring Agent that is a part of the Service Manager 2012). On the other hand, this discovery provided by the OpsMgr 2012 Self Maintenance MP (Version 2.5.0.0) is designed to replace the native patch list discovery. Instead of only discovering agent patch list, it also discovers the patch list for OpsMgr management servers, gateway servers, SCSM management servers and SCSM Data Warehouse management servers.

Same as all other workflows in the Self Maintenance MP, this discovery is disabled by default. In order to start using this discovery, please disable the built-in discovery “Discovers the list of patches installed on Agents” BEFORE enabling “OpsMgr 2012 Self Maintenance Management Server and Agent Patch List Discovery”:

<a href="http://blog.tyang.org/wp-content/uploads/2015/09/image17.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/09/image_thumb17.png" alt="image" width="687" height="315" border="0" /></a>

Shortly after the built-in discovery has been disabled and the “OpsMgr 2012 Self Maintenance Management Server and Agent Patch List Discovery” has been enabled for the Health Service class, the patch list for the OpsMgr management servers, gateway servers and SCSM management servers (including Data Warehouse management server) will be populated (as shown in the screenshot below):

<a href="http://blog.tyang.org/wp-content/uploads/2015/09/SNAGHTML51edc1.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML51edc1" src="http://blog.tyang.org/wp-content/uploads/2015/09/SNAGHTML51edc1_thumb.png" alt="SNAGHTML51edc1" width="668" height="374" border="0" /></a>

<b><span style="background-color: #ffff00;">Note:</span></b>

As shown above, the patch list for different flavors of Health Service is properly populated, with the exception of the Direct Microsoft Monitoring Agent for OpInsights (OMS). This is because at the time of writing this post (September, 2015), Microsoft has yet released any patches to the OMS direct MMA agent. The last Update Rollup for the Direct MMA agent is actually released as an updated agent (MSI) instead of an update (MSP). Therefore, since there is no update to the agent installer MSI, the patch list is not populated.

<strong><span style="background-color: #ffff00;">Warning:</span></strong>

Please do not leave both discoveries enabled at the same time as it will cause config-churn in your OpsMgr environment.
<h5>Monitor: OpsMgr 2012 Self Maintenance All Management Servers Patch List Consistency Consecutive Samples Monitor</h5>
This consecutive sample monitor is targeting the “All Management Servers Resource Pool” and it is configured to run every 2 hours (7200 seconds) by default. It executes a PowerShell script which uses WinRM to remotely connect to each management server and checks if all the management servers are on the same UR patch level.

In order to utilise this monitor, WinRM must be enabled and configured to accept connections from other management servers. The quickest way to do so is to run “Winrm QuickConfig” on these servers. The account that is running the script in the monitor must also have OS administrator privilege on all management servers (by default, it is running under the management server’s default action account). If the default action account does not have Windows OS administrator privilege on all management servers, a Run-As profile can be configured for this monitor:

<a href="http://blog.tyang.org/wp-content/uploads/2015/09/SNAGHTML53a46a.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML53a46a" src="http://blog.tyang.org/wp-content/uploads/2015/09/SNAGHTML53a46a_thumb.png" alt="SNAGHTML53a46a" width="671" height="423" border="0" /></a>

In addition to the optional Run-As profile, if WinRM on management servers are listening to a non-default port, the port number can also be modified via override:

<a href="http://blog.tyang.org/wp-content/uploads/2015/09/image18.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/09/image_thumb18.png" alt="image" width="322" height="354" border="0" /></a>

<b><span style="background-color: #ffff00;">Note:</span></b>

All management servers must be configured to use the same WinRM port. Using different WinRM port is not supported by the script used by the monitor.

If the monitor detected inconsistent patch level among management servers in 3 consecutive samples, a Critical alert will be raised:

<a href="http://blog.tyang.org/wp-content/uploads/2015/09/image19.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/09/image_thumb19.png" alt="image" width="688" height="309" border="0" /></a>

The number of consecutive sample can be modified via override (Match Count) parameter.
<h4>Agent Task: Configure group Health Rollup</h4>
This task has been previously released in the <a href="http://blog.tyang.org/2015/07/28/opsmgr-group-health-rollup-configuration-task-management-pack/">OpsMgr Group Health Rollup Task Management Pack</a>. I originally wrote this task in response to Squared Up’s customers feedback. When I was developing the original MP (for Squared Up), Squared Up has agreed for me to release it to the public free of charge, as well as making this as a part of the new Self Maintenance MP.

Therefore, this agent task is now part of the Self Maintenance MP, kudos Squared Up <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" src="http://blog.tyang.org/wp-content/uploads/2015/09/wlEmoticon-smile.png" alt="Smile" />.
<h4>Auditing Agent Tasks Execution Status</h4>
In OpsMgr, the task history is stored in the operational DB, which has a relatively short retention period. In this release, I have added a rule called “OpsMgr 2012 Self Maintenance Audit Agent Tasks Result Event Collection Rule”. it is designed to collect the agent task execution result and store it in both operational and Data Warehouse DB as event data. Because the data in the DW database generally has a much longer retention, the task execution results can be audited and reported.

<b><span style="background-color: #ffff00;">Note:</span></b>

This rule was inspired by this blog post (although the script used in this rule is completely different than the script from this post): <a href="http://www.systemcentercentral.com/archiving-scom-console-task-status-history-to-the-data-warehouse/">http://www.systemcentercentral.com/archiving-scom-console-task-status-history-to-the-data-warehouse/</a>
<h4>Resetting Health for Manually Closed Monitor Alerts</h4>
Having ability to automatically reset health state for manually closed monitor alerts must be THE most popular suggestion I have received for the Self Maintenance MP. I get this suggestions all the time, from the community, and also from MVPs. Originally, my plan was to write a brand new rule for this purpose. I then realised I already have created a rule to detect any manually closed monitor alerts. So instead of creating something brand new, I have updated the existing rule “OpsMgr 2012 Self Maintenance Detect Manually Closed Monitor Alerts Rule”. In this release, this rule now has an additional overrideable parameter called “ResetUnitMonitors”. This parameter is set to “false” by default. But when it is set to “true” via overrides, the script used by this rule will also reset the health state of the monitor of which generated the alert if the monitor is a unit monitor and its’ current health state is either warning or error:

<a href="http://blog.tyang.org/wp-content/uploads/2015/09/image20.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/09/image_thumb20.png" alt="image" width="480" height="228" border="0" /></a>
<h3>OpsMgr Self Maintenance OMS Add On MP</h3>
OK, we all have to admit, OMS is such a hot topic at the moment. Hopefully you all have played and read about this solution (if not, you can learn more about this product from Mr Pete Zerger’s survival guide for OMS:<a title="http://social.technet.microsoft.com/wiki/contents/articles/31909.ms-operations-management-suite-survival-guide.aspx" href="http://social.technet.microsoft.com/wiki/contents/articles/31909.ms-operations-management-suite-survival-guide.aspx">http://social.technet.microsoft.com/wiki/contents/articles/31909.ms-operations-management-suite-survival-guide.aspx</a>)

With the release of version 2.5.0.0, the new “OpsMgr Self Maintenance OMS Add-On Management Pack” has been introduced.

This management pack is designed to also send performance and event data generated by the OpsMgr 2012 Self Maintenance MP to the Microsoft Operations Management Suite (OMS) Workspace.

In addition to the existing performance and event data, this management pack also provides 2 event rules that send periodic “heartbeat” events to OMS from configured health service and All Management Servers Resource Pool. These 2 event rules are designed to monitor the basic health of the OpsMgr management group from OMS (Monitor the monitor scenario).

<b><span style="background-color: #ffff00;">Note:</span></b>

In order to use this management pack, the OpsMgr management must meet the minimum requirements for the OMS / Azure Operational Insights integration, and the connection to OMS must be configured prior to importing this management pack.
<h5><a name="_Toc430181567"></a><span style="color: #000000;">Sending Heartbeat Events to OMS</span></h5>
There have been many discussion and custom solutions on how to monitor the monitor? It is critical to be notified when the monitor - OpsMgr management group is “down”. With the recent release of Microsoft Operations Management Suite (OMS) and the ability to connect the on-premise OpsMgr management group to OMS workspace, the “OpsMgr Self Maintenance OMS Add-On Management Pack” provides the ability to send “heartbeat” events to OMS from
<ul>
	<li>All Management Servers Resource Pool (AMSRP)</li>
	<li>Various Health Service
<ul>
	<li>Management Servers and Gateway Servers</li>
	<li>Agents</li>
</ul>
</li>
</ul>
The idea behind these rules is that once the resource pool and management servers have started sending heartbeat events to OMS every x number of minutes, we will then be able to detect when the expected heartbeat events are missing, thus detecting potential issues within OpsMgr – thus monitoring the monitor.

The heartbeat events can be accessed via the the OMS web portal (as well as using the OMS search API):

i.e. the AMSRP heartbeat events for the last 15 minutes:

<a href="http://blog.tyang.org/wp-content/uploads/2015/09/image21.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/09/image_thumb21.png" alt="image" width="665" height="362" border="0" /></a>

Dashboard tile with threshold:

<a href="http://blog.tyang.org/wp-content/uploads/2015/09/SNAGHTMLb630de.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLb630de" src="http://blog.tyang.org/wp-content/uploads/2015/09/SNAGHTMLb630de_thumb.png" alt="SNAGHTMLb630de" width="558" height="447" border="0" /></a>

<strong><span style="background-color: #ffff00;">Note:</span></strong>

For the heartbeat event rule targeting the health service, I have configured it to continue sending the heartbeat even when the Windows computer has been placed into maintenance mode (not that management servers should ever been placed in maintenance mode in the first place <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" src="http://blog.tyang.org/wp-content/uploads/2015/09/wlEmoticon-smile.png" alt="Smile" />).

I’m not going to take all the credit for this one. Monitoring the monitor using OMS was an idea from my friend and fellow MVP Cameron Fuller. as the result of this discussion with Cameron and other CDM MVPs, I ended up developed a management pack which sends heartbeat events from AMSRP and selected health service (management servers for example) to OMS. This management pack has never been published to the public, but I believe Cameron has recently demonstrated it in the Minnesota System Center User Group meeting (<a title="http://blogs.catapultsystems.com/cfuller/archive/2015/08/14/summary-from-the-mnscug-august-2015-meeting/" href="http://blogs.catapultsystems.com/cfuller/archive/2015/08/14/summary-from-the-mnscug-august-2015-meeting/">http://blogs.catapultsystems.com/cfuller/archive/2015/08/14/summary-from-the-mnscug-august-2015-meeting/</a>)

Please refer to the MP guide section 7.1 for detailed information about this feature.
<h5><a name="_Toc430181571"></a><span style="color: #000000;">Collecting Data Generated by the OpsMgr 2012 Self Maintenance MP</span></h5>
Other than the heartbeat event collection rules, the OMS Add-On MP also collects the following event and performance data to OMS:
<ul>
	<li>Data Warehouse Database Aggregation Outstanding dataset count (Perf Data)</li>
	<li>Data Warehouse Database Staging Tables Row Count (Perf Data)</li>
	<li>All Management Server SDK Connection Count (Perf Data)</li>
	<li>OpsMgr Self Maintenance Health Service OMS Heartbeat Event Rule</li>
	<li>Agent Tasks Result Audit (Event Data)</li>
</ul>
The above listed data are already being generated by the OpsMgr 2012 Self Maintenance MP, The OMS Add-On MP fully utilise Cook Down feature, and store these data in OMS in additional to the OpsMgr databases.

i.e. Agent Task Results Audit Event:

<a href="http://blog.tyang.org/wp-content/uploads/2015/09/image22.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/09/image_thumb22.png" alt="image" width="633" height="499" border="0" /></a>

SDK Connection Count Perf Data:

<a href="http://blog.tyang.org/wp-content/uploads/2015/09/image23.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/09/image_thumb23.png" alt="image" width="623" height="396" border="0" /></a>

Please refer to the MP guide section 7.2 for more information (and sample search queries) about these OMS data collection rules.
<h3>Credit</h3>
There are simply too many people to thank. I have mentioned few names in this post, but if I attempt to mention everyone who’s given me feedback, advise and helped me testing, I’m sure I’ll miss someone.

So I’d like to thank the broader OpsMgr community for adopting this MP and for all the feedback and suggestions I’ve received.
<h3>What’s Next?</h3>
Well, my another short time goal is to create a Squared Up dashboard for this MP, and release it in Squared Up’s upcoming community dashboard site.

Speaking about the long time goal, my prediction is that the next release is probably going to be dedicated to OpsMgr 2016. I am planning to make a brand new MP for OpsMgr 2016 (instead of upgrading this build), so I am able to delete all the obsolete elements in the 2016 build. I will re-evaluate and test all the workflows in this MP, making sure it is still relevant for OpsMgr 2016.
<h3>Download</h3>
You can download this MP from my company’s website <span style="font-size: large;"><strong><a href="http://www.tyconsulting.com.au/portfolio/opsmgr-self-maintenance-management-pack-v-2-5-0-0/">HERE</a></strong></span>