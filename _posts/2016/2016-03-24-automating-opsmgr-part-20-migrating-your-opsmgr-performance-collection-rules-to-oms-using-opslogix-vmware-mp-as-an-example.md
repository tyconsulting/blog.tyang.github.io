---
id: 5306
title: 'Automating OpsMgr Part 20: Migrating Your OpsMgr Performance Collection Rules to OMS (Using OpsLogix VMware MP as an Example)'
date: 2016-03-24T14:54:34+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=5306
permalink: /2016/03/24/automating-opsmgr-part-20-migrating-your-opsmgr-performance-collection-rules-to-oms-using-opslogix-vmware-mp-as-an-example/
categories:
  - OMS
  - SCOM
tags:
  - Automating OpsMgr
  - OMS
  - SCOM
---
<h3><a href="http://blog.tyang.org/wp-content/uploads/2015/06/OpsMgrExnteded.png"><img class="alignleft size-thumbnail wp-image-4038" src="http://blog.tyang.org/wp-content/uploads/2015/06/OpsMgrExnteded-150x150.png" alt="OpsMgrExnteded" width="150" height="150" /></a>Introduction</h3>
This is the 20th installment of the Automating OpsMgr series. Previously on this series:
<ul>
	<li><a href="http://blog.tyang.org/2015/06/24/automating-opsmgr-part-1-introducing-opsmgrextended-powershell-sma-module/">Automating OpsMgr Part 1: Introducing OpsMgrExtended PowerShell / SMA Module</a></li>
	<li><a href="http://blog.tyang.org/2015/06/28/automating-opsmgr-part-2-sma-runbook-for-creating-configmgr-log-collection-rules/">Automating OpsMgr Part 2: SMA Runbook for Creating ConfigMgr Log Collection Rules</a></li>
	<li><a href="http://blog.tyang.org/2015/06/30/automating-opsmgr-part-3-new-management-pack-runbook-via-sma-and-azure-automation/">Automating OpsMgr Part 3: New Management Pack Runbook via SMA and Azure Automation</a></li>
	<li><a href="http://blog.tyang.org/2015/07/02/automating-opsmgr-part-4-create-new-empty-groups/">Automating OpsMgr Part 4:Creating New Empty Groups</a></li>
	<li><a href="http://blog.tyang.org/2015/07/06/automating-opsmgr-part-5-adding-computers-to-computer-groups/">Automating OpsMgr Part 5: Adding Computers to Computer Groups</a></li>
	<li><a href="http://blog.tyang.org/2015/07/13/automating-opsmgr-part-6-adding-monitoring-objects-to-instance-groups/">Automating OpsMgr Part 6: Adding Monitoring Objects to Instance Groups</a></li>
	<li><a href="http://blog.tyang.org/2015/07/17/automating-opsmgr-part-7-updated-opsmgrextended-module/">Automating OpsMgr Part 7: Updated OpsMgrExtended Module</a></li>
	<li><a href="http://blog.tyang.org/2015/07/17/automating-opsmgr-part-8-adding-management-pack-references/">Automating OpsMgr Part 8: Adding Management Pack References</a></li>
	<li><a href="http://blog.tyang.org/2015/07/17/automating-opsmgr-part-9-updating-group-discoveries/">Automating OpsMgr Part 9: Updating Group Discoveries</a></li>
	<li><a href="http://blog.tyang.org/2015/07/27/automating-opsmgr-part-10-deleting-groups/">Automating OpsMgr Part 10: Deleting Groups</a></li>
	<li><a href="http://blog.tyang.org/2015/07/29/automating-opsmgr-part-11-configuring-group-health-rollup/">Automating OpsMgr Part 11: Configuring Group Health Rollup</a></li>
	<li><a href="http://blog.tyang.org/2015/08/08/automating-opsmgr-part-12-creating-performance-collection-rules/">Automating OpsMgr Part 12: Creating Performance Collection Rules</a></li>
	<li><a href="http://blog.tyang.org/2015/08/24/automating-opsmgr-part-13-creating-2-state-performance-monitors/">Automating OpsMgr Part 13: Creating 2-State Performance Monitors</a></li>
	<li><a href="http://blog.tyang.org/2015/08/31/automating-opsmgr-part-14-creating-event-collection-rules/">Automating OpsMgr Part 14: Creating Event Collection Rules</a></li>
	<li><a href="http://blog.tyang.org/2015/09/25/automating-opsmgr-part-15-creating-2-state-event-monitors/">Automating OpsMgr Part 15: Creating 2-State Event Monitors</a></li>
	<li><a href="http://blog.tyang.org/2015/10/02/automating-opsmgr-part-16-creating-windows-service-monitors/">Automating OpsMgr Part 16: Creating Windows Service Monitors</a></li>
	<li><a href="http://blog.tyang.org/2015/10/04/automating-opsmgr-part-17-creating-windows-service-management-pack-template-instance/">Automating OpsMgr Part 17: Creating Windows Service Management Pack Template Instance</a></li>
	<li><a href="http://blog.tyang.org/2015/10/14/automating-opsmgr-part-18-second-update-to-the-opsmgrextended-module-v1-2/">Automating OpsMgr Part 18: Second Update to the OpsMgrExtended Module (v1.2)</a></li>
	<li><a href="http://blog.tyang.org/2015/10/28/automating-opsmgr-part-19-creating-any-types-of-generic-rules/">Automating OpsMgr Part 19: Creating Any Types of Generic Rules</a></li>
</ul>
OK, it has been 6 months since my last post on this blog series. I simply didn’t have time to continue on, but I know this is far from over. I am spending A LOT of time on OMS these days, some of you guys may have heard (or have already read) our newly published book <strong><em>Inside Microsoft Operations Management Suite</em></strong> (<a href="https://gallery.technet.microsoft.com/Inside-the-Operations-2928e342">TechNet</a>, <a href="http://www.amazon.com/Inside-Microsoft-Operations-Management-Hands–ebook/dp/B01CH1L9X6">Amazon</a>). I’m hoping you guys all have played with OMS and maybe even have started thinking what workloads can you move to OMS.

As we all know, we can pretty much categorise SCOM data into the following 4 categories:
<ul>
	<li>Performance Data</li>
	<li>Event Data</li>
	<li>Alert Data</li>
	<li>State Data</li>
</ul>
Unlike SCOM, since OMS does not use classes, there are no classes, relationships and state data in OMS, but for the other 3 types, we can easily get them over to OMS. With the SCOM alert data, you can simply enable the Alert solution after you have connected your SCOM management group to your OMS workspace. OMS also has its own alerting and remediation capability. For all existing performance collection and event collection rules, we can easily recreate them using a different Write Action module to store these data into OMS. In this post, I will show you how we can gather all performance collection rules from an existing OpsMgr management pack, and re-create these them for OMS (stored as PerfHourly data in OMS). But before we diving into it, let’s quickly go through the performance data in OMS.
<h3>OMS Performance Data</h3>
There are 2 types of performance data in OMS. The <strong>PerfHourly</strong> data was introduced with the Capacity Planning solution. As the name suggests, PerfHourly data is the hourly aggregated performance data. It does not store any raw perf data in OMS.

Another type of performance data is called <strong>Near-Real Time (NRT)</strong> performance data. NRT perf data can be access using queries such as <strong>Type=Perf</strong>. Unlike the PerfHourly data, NRT perf data can collect perf data as frequent as every 10 seconds, and the aggregation interval is every half hour. Both raw and aggregated NRT perf data are stored in OMS, where raw data is stored for 14 days and the OMS search queries only return aggregated data.

From the management pack point of view, it is a lot more complicated writing perf collection rules for NRT perf data. With the NRT perf data, we must always author 2 rules for every counter that we are going to collect, one for the raw data and one for the aggregated data. Secondly, for NRT perf data, when mapping performance data, the object name must always follow the format "<strong>\\&lt;Computer FQDN&gt;\&lt;Object Name&gt;</strong>". Lastly, the collection rule that collects the aggregated data must use a Condition Detection module called "Microsoft.IntelligencePacks.Performance.PerformanceAggregator".

Since an OpsMgr rule can only have up to one (1) condition detection member module, converting existing OpsMgr perf collection rules that already have an existing condition detection member module to OMS NRT perf rule may not be that straight forward. In this case, we may need to create some additional module types and things can get very complicated. It is certainly not something that we can use a generic script to achieve.

Therefore in order to make the script work with any existing OpsMgr performance collection rules, I have chosen to store the perf data in OMS as PerfHourly data because it has far less "red tapes". Having said that, please keep in mind it is still possible to re-create OpMgr perf collection rules as OMS NRT perf collection rules, but it’s just not something we can develop as a generic automated solution.

If you want to learn more about performance data in OMS, or how to author OMS based collection rules in SCOM using VSAE, please refer to <strong>Chapter 5: Working with Performance Data</strong> and <strong>Chapter 11: Custom Management Pack Authoring</strong> of the Inside OMS book I mentioned in the beginning of this post.
<h3>PowerShell Script: Copy-PerfRulesToOMS.ps1</h3>
In the previous posts of this blog series, I have simply placed the scripts / runbooks within the post it self. I have decided to use Github from now on. So the script Copy-PerfRulesToOMS.ps1 can be found in one of my public Github repositories: <a title="https://github.com/tyconsulting/OpsMgr-SDK-Scripts/blob/master/OMS%20Related%20Scripts/Copy-PerfRulesToOMS.ps1" href="https://github.com/tyconsulting/OpsMgr-SDK-Scripts/blob/master/OMS%20Related%20Scripts/Copy-PerfRulesToOMS.ps1">https://github.com/tyconsulting/OpsMgr-SDK-Scripts/blob/master/OMS%20Related%20Scripts/Copy-PerfRulesToOMS.ps1</a>

This script reads configurations of all performance collection rules in a particular OpsMgr management pack, and then recreate these rules with same configuration but stores the performance data as PerfHourly data in your OMS workspace. The OMS perf collection rules created by this script will be stored in a brand new unsealed MP with the name ‘&lt;Original MP name&gt;.OMS.Perf.Collection’ and display name ‘&lt;Original MP display name&gt; OMS PerfHourly Addon""’.

This script has the following pre-requisites:
<ul>
	<li><a href="http://www.tyconsulting.com.au/portfolio/opsmgrextended-powershell-and-sma-module/">OpsMgrExtended PS module</a> loaded on the machine where you are executing the script.</li>
	<li>An account with OpsMgr administrative rights</li>
	<li>OpsMgr management group must be connected to OMS</li>
</ul>
The script takes the following input parameters:
<ul>
	<li><strong>ManagementServer –</strong> Specify the name of an OpsMgr management server that you wish to connect to. This is a mandatory parameter.</li>
	<li><strong>Credential –</strong> Specify an alternative credential that has admin rights to the OpsMgr management group. This is an optional parameter.</li>
	<li><strong>ManagementPackName –</strong> Specify the source MP where you want to copy to Perf collection rule to OMS. This is not the display name but the actual MP name. In the OpsMgr console, when you open the management pack property, it is the ‘ID’ field. i.e. since I’m going to use the OpsLogix VMware management pack as an example in this post, the name for this MP is "OpsLogix.IMP.VMWare.Monitoring":</li>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2016/03/image-27.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/03/image_thumb-27.png" alt="image" width="370" height="379" border="0" /></a>

&nbsp;

<strong>Executing the script:</strong>

I have added many verbose messages in the script, so you can use the optional –verbose switch when executing the script.
<pre class="" language="PowerShell">$cred = Get-Credential

.\Copy-PerfRulesToOMS.ps1 -ManagementServer "ManagementServerName" -Credential $cred -ManagementPackName "OpsLogix.IMP.VMWare.Monitoring" –Verbose

```
<a href="http://blog.tyang.org/wp-content/uploads/2016/03/SNAGHTMLd5d2347.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLd5d2347" src="http://blog.tyang.org/wp-content/uploads/2016/03/SNAGHTMLd5d2347_thumb.png" alt="SNAGHTMLd5d2347" width="663" height="410" border="0" /></a>

This script firstly connect to the management group, read the source MP, then retrieves all performance collection rules from this MP. If the source MP contains any perf collection rules, it will create a new unsealed MP and start creating a co-responding OMS PerfHourly collection rule for each original OpsMgr perf collection rule. the OMS PerfHourly collection rules will have the same properties, input parameters as well as the same data source and condition detection member modules as the original OpsMgr Perf Collection rules. But they will be configured to use another Write Action member module to send the perf data to OMS.

<strong><span style="color: #ff0000;">Note:</span></strong>
<ul>
	<li>The script detects OpsMgr Perf collection rules from the source MP by examining the actual write action member modules. If any of the write action member modules are either ‘Microsoft.SystemCenter.CollectPerformanceData’ (used to write perf data to OpsMgr operational DB) or ‘Microsoft.SystemCenter.DataWarehouse.PublishPerformanceData’ (used to write perf data to OpsMgr DW DB), then the script will consider the rule as a perf collection rule.</li>
	<li>When the source MP is unsealed, the script will failed under the following circumstances:
<ul>
	<li>a perf collection rule in the source MP is targeting a class defined in the source MP</li>
	<li>a perf collection rule in the source MP uses any data source or condition detection module types that are defined in the source MP</li>
</ul>
</li>
	<li>The script does not disable any existing perf collection rules from the source MP</li>
	<li>The script copies all attributes from the source perf collection rule to the new OMS PerfHourly rule, including the ‘Enabled’ property. So if the source perf collection rule is disabled by default, then the newly created OMS PerfHourly rule will also be disabled by default.</li>
	<li>Depending on the number of OpsMgr Perf Collection rules to be processed, this script can take some time to finish because it is writing new OMS PerfHourly rules to the destination MP one at a time. I purposed coded the script this way (rather than writing everything at once), is because by doing so, if a particular rule has failed MP verification, it would not impact the creation of other rules.</li>
</ul>
When the execution is completed, you will see a new unsealed MP created in your management group:

<a href="http://blog.tyang.org/wp-content/uploads/2016/03/image-28.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/03/image_thumb-28.png" alt="image" width="463" height="475" border="0" /></a>

and if I export it to XML and open it in MPViewer, I can see all the newly created OMS PerfHourly collection rules:

<a href="http://blog.tyang.org/wp-content/uploads/2016/03/image-29.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/03/image_thumb-29.png" alt="image" width="559" height="409" border="0" /></a>

At this stage, I don’t need to do anything else and all the performance data collected by the source MP (OpsLogix VMware MP in this example) will be stored not only in OpsMgr, but also in OMS.

Because the original OpsMgr perf collection rules and the co-responding OMS PerfHourly rules are sharing the exact same data source modules with same configuration, this would not add additional overhead to the OpsMgr agents due to the OpsMgr Cook Down feature. However, please keep in mind that from now on, if you need to apply overrides to the either rule, it’s best to apply the same override to both rules (so you don’t break Cook Down).

Although the PerfHourly data will not appear in your OMS workspace straightaway (due to the aggregation process), you should be able to see them within few hours:

<a href="http://blog.tyang.org/wp-content/uploads/2016/03/image-30.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/03/image_thumb-30.png" alt="image" width="613" height="578" border="0" /></a>

As you can see in the above screenshot, I now have all the VMware related counters defined in the OpsLogix VMware MP in my OMS workspace. the RootObjectName ‘VCENTER01’ is the vCenter server in my lab, and the ObjectDisplayName ‘exs01.corp.tyang.org’ is the VMware ESX host in my lab.
<h4>Summary</h4>
In this post, I have shared a script and demonstrated how to use this script to migrate your existing OpsMgr performance collection rules to OMS. We can easily write a very similar script for migrating existing event collection rules (maybe a blog topic for another day). I have demonstrated how to use this script to collect VMware related counters originally defined in the OpsLogix VMware MP.

In the next post of this series, I will demonstrate how to use OpsMgrExtended module, SharePointSDK module, Azure Automation, Hybrid Workers and SharePoint Online to build a portal for scheduling OpsMgr maintenance mode – this is based on one of the demos in my Azure Automation session with Pete Zeger from SCU 2016 APAC & Australia.

Until next time, happy automating!