---
id: 3225
title: Updated ConfigMgr 2012 (R2) Client Management Pack Version 1.2.0.0
date: 2014-10-04T18:41:56+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=3225
permalink: /2014/10/04/updated-configmgr-2012-r2-client-management-pack-version-1-2-0-0/
categories:
  - SCCM
  - SCOM
tags:
  - Featured
  - MP Authoring
  - SCCM
  - SCOM
---

## Background

It’s only been 2 weeks since I released the last update of this MP (version 1.1.0.0). Soon after the release, Mr. <a href="https://twitter.com/aquilaweb">David Allen</a>, a fellow System Center CDM MVP contacted me, asked me to test his SCCM Compliance MP, and possibly combine it with my ConfigMgr 2012 Client MP.

In the ConfigMgr 2012 Client MP, the OVERALL DCM baselines compliance status are monitored by the DCM Agent class, whereas in David’s SCCM Compliance MP, each DCM Baseline is discovered as a separate entity and monitored separately. Because of the utilisation of Cook Down feature, comparing with the approach in the ConfigMgr 2012 Client MP, this approach adds no additional overhead to the OpsMgr agents.

David’s MP also included a RunAs profile to allow users to configure monitoring for OpsMgr agents using a  Low-Privileged default action account.

I think both of the features are pretty cool, so I have taken David’s MP, re-modelled the health classes relationships, re-written the scripts from PowerShell to VBScripts, and combined what David has done to the ConfigMgr 2012 Client MP.

If you (the OpsMgr administrators) are concerned about number of additional objects that are going to be discovered by this release (every DCM baseline on every ConfigMgr 2012 Client monitored by OpsMgr), the DCM Baselines discovery is disabled by default, I have taken an similar approach as configuring Business Critical Desktop monitoring, there is an additional unsealed MP in this release to allow you to cherry pick which endpoints to monitor in this regards.

## What’s New in Version 1.2.0.0

Other than combining David’s SCCM Compliance MP, there are also few other updates included in this release. Here’s the full "What’s New" list:

<strong>Bug Fix: ConfigMgr 2012 Client Missing Client Health Evaluation (CCMEval) Execution Cycles Monitor alert parameter incorrect</strong>

<strong>Added a privileged RunAs Profile for all applicable workflows</strong>

<strong>Additional rule: ConfigMgr 2012 Client Missing Cache Content Removal Rule</strong>

<strong>Enhanced Compliance Monitoring</strong>
<ul>
	<li>Additional class: DCM Baseline (hosted by DCM agent)</li>
	<li>Additional Unit monitor: ConfigMgr 2012 Client DCM Baseline Last Compliance Status Monitor</li>
	<li>Additional aggregate and dependency monitors to rollup DCM Baseline health to DCM Agent</li>
	<li>Additional State View for DCM Baseline</li>
	<li>Additional instance groups:
<ul>
	<li>All DCM agents</li>
	<li>All DCM agents on server computers</li>
	<li>All DCM agents on client computers</li>
	<li>All Business Critical ConfigMgr 2012 Client DCM Agents</li>
</ul>
</li>
	<li>Additional unsealed MP: ConfigMgr 2012 Client Enhanced Compliance Monitoring
<ul>
	<li>Override to enabled DCM baseline discovery for All DCM agents on server computers group</li>
	<li>Override to disable old DCM baseline monitor for All DCM agents on server computers group</li>
	<li>Discovery for All Business Critical ConfigMgr 2012 Client DCM Agents (users will have to populate this group, same way as configuring business critical desktop monitoring)</li>
	<li>Override to enabled DCM baseline discovery for All Business Critical ConfigMgr 2012 Client DCM Agents group</li>
	<li>Override to disable old DCM baseline monitor for All Business Critical ConfigMgr 2012 Client DCM Agents group</li>
</ul>
</li>
	<li>Additional Agent Task: Evaluate DCM Baseline (targeting the DCM Baseline class)</li>
</ul>
<strong>Additional icons</strong>
<ul>
	<li>Software Distribution Agent</li>
	<li>Software Update Agent</li>
	<li>Software Inventory Agent</li>
	<li>Hardware Inventory Agent</li>
	<li>DCM Agent</li>
	<li>DCM Baseline</li>
</ul>

## Enhanced Compliance Monitoring

Version 1.2.0.0 has introduced a new feature that can monitor assigned DCM Compliance Baselines on a more granular level. Prior to this release, there is a unit monitor targeting the DCM agent class and monitor the overall baselines compliance status as a whole. Since version 1.2.0.0, each individual DCM baseline can be discovered and monitored separately.

By default, the discovery for DCM Baselines is disabled. It needs to be enabled on manually via overrides before DCM baselines can be monitored individually.

<a href="http://blog.tyang.org/wp-content/uploads/2014/10/image.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/10/image_thumb.png" alt="image" width="698" height="261" border="0" /></a>

There are several groups can be used for overriding the DCM Baseline discovery:

| Scenario                                  | Override Target                                                                                                                                 |
| ----------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| Enable For All DCM Agents                 | Class: ConfigMgr 2012 Client Desired Configuration Management Agent                                                                             |
| Enable For Server Computers Only          | Group: All ConfigMgr 2012 Client DCM Agents on Server OS                                                                                        |
| Enable For Client Computers Only          | Group: All ConfigMgr 2012 Client DCM Agents on Client OS                                                                                        |
| Enable for a subset of group of computers | Manually create an instance group and populate the membership based on the "ConfigMgr 2012 Client Desired Configuration Management Agent" class |

>**Note:** Once the DCM Baseline discovery is enabled, please also disable the "ConfigMgr 2012 Client DCM Baselines Compliance Monitor" for the same targets as it has become redundant.

Once the DCM baselines are discovered, their compliance status is monitored individually:

<a href="http://blog.tyang.org/wp-content/uploads/2014/10/image1.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/10/image_thumb1.png" alt="image" width="700" height="387" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2014/10/SNAGHTML44656c89.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML44656c89" src="http://blog.tyang.org/wp-content/uploads/2014/10/SNAGHTML44656c89_thumb.png" alt="SNAGHTML44656c89" width="694" height="366" border="0" /></a>

Additionally, the DCM Baselines have an agent task called "Evaluate DCM Baseline", which can be used to manually evaluate the baseline. This agent task performs the same action as the "Evaluate" button in the ConfigMgr 2012 client:

<a href="http://blog.tyang.org/wp-content/uploads/2014/10/SNAGHTML44665daf.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML44665daf" src="http://blog.tyang.org/wp-content/uploads/2014/10/SNAGHTML44665daf_thumb.png" alt="SNAGHTML44665daf" width="667" height="321" border="0" /></a>

<a name="_Toc400202277"></a><strong><span style="color: #000000;">ConfigMgr 2012 Client Enhanced Compliance Monitoring Management Pack</span></strong>

An additional unsealed management pack named "ConfigMgr 2012 Client Enhanced Compliance Monitoring" is also introduced. This management pack includes the following:
<ul>
	<li>An override to enable DCM baseline discovery for "All ConfigMgr 2012 Client DCM Agents on Server OS" group.</li>
	<li>An override to disable the legacy ConfigMgr 2012 Client DCM Baselines Compliance Monitor for "All ConfigMgr 2012 Client DCM Agents on Server OS" group.</li>
	<li>A blank group discovery for the "All Business Critical ConfigMgr 2012 Client DCM Agents" group</li>
	<li>An override to enable DCM baseline discovery for "All Business Critical ConfigMgr 2012 Client DCM Agents" group.</li>
	<li>An override to disable the legacy ConfigMgr 2012 Client DCM Baselines Compliance Monitor for "All Business Critical ConfigMgr 2012 Client DCM Agents" group.</li>
</ul>


<em><span style="color: #ff0000;">In summary, this management pack enables DCM baseline discovery for all ConfigMgr 2012 client on server computers and switch from existing "overall" compliance baselines status monitor to the new more granular compliance baseline status monitor which targets individual baselines. This management pack also enables users to manually populate the new "All Business Critical ConfigMgr 2012 Client DCM Agents" group. Members in this group will also be monitored the same way as the server computers as previously mentioned.</span></em>

>**Note:** Please only use this management pack when you prefer to enable enhanced compliance monitoring on all server computers, otherwise, please manually configure the groups and overrides as previously stated.

## New RunAs Profile for Low-Privilege Environments

Since almost all of the workflows in the ConfigMgr 2012 Client management packs require local administrative access to access various WMI namespaces and registry, it will not work when the OpsMgr agent RunAs account does not have local administrator privilege.

Separate RunAs accounts can be created and assigned to the "ConfigMgr 2012 Client Local Administrator RunAs Account" profile.

RunAs Account Example:

<a href="http://blog.tyang.org/wp-content/uploads/2014/10/image2.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/10/image_thumb2.png" alt="image" width="371" height="380" border="0" /></a>

RunAs Profile:

<a href="http://blog.tyang.org/wp-content/uploads/2014/10/SNAGHTML446ddb3a.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML446ddb3a" src="http://blog.tyang.org/wp-content/uploads/2014/10/SNAGHTML446ddb3a_thumb.png" alt="SNAGHTML446ddb3a" width="473" height="432" border="0" /></a>

For More information about OpsMgr RunAs account and profile, please refer to: <a href="http://technet.microsoft.com/en-us/library/hh212714.aspx">http://technet.microsoft.com/en-us/library/hh212714.aspx</a>

<b>Note:</b> When assigning a RunAs Account to the "ConfigMgr 2012 Client Local Administrator RunAs Account" profile, you will receive an error as below:

<a href="http://blog.tyang.org/wp-content/uploads/2014/10/image3.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/10/image_thumb3.png" alt="image" width="500" height="407" border="0" /></a>

Please refer to the MP documentation section "14.3 Error Received when Adding RunAs Account to the RunAs Profile" for instruction on fixing this error.

## New Rule: Missing Cache Content Removal Rule

This rule runs every 4 hours by default and checks if any registered ConfigMgr 2012 Client cache content has been deleted from the file system. When obsolete cache content is detected, this rule will remove the cache content entry from ConfigMgr 2012 client via WMI and generates an informational alert with the details of the missing cache content:

<a href="http://blog.tyang.org/wp-content/uploads/2014/10/image4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/10/image_thumb4.png" alt="image" width="635" height="399" border="0" /></a>

## Additional Icons:

Prior to this release, only the top level class ConfigMgr 2012 Client has its dedicated icons. I have spent a lot of time looking for icons for all other classes, I managed to produce icons for each monitoring classes in this release:

<a href="http://blog.tyang.org/wp-content/uploads/2014/10/image5.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/10/image_thumb5.png" alt="image" width="650" height="359" border="0" /></a>

>**Note:** I only managed to find high res icons for the Software Distribution Agent and the Software Update Agent (extracted from various DLLs and EXEs). I couldn’t find a way to extract icons from AdminUI.UIResources.DLL – where all the icons used by SCCM are stored. So for other icons, I had to use SnagIt to take screenshots of these icons. You may notice the quality is not that great, but after few days effort trying to find these icons, this is the best I can do. If you have a copy of these icons (res higher than 80x80), or know a way to extract these icons from AdminUI.UIResources.dll, please contact me and I’ll update them in the next release.

## Credit

**BIG** thank you to David Allen for his work on the SCCM Compliance MP, and also helping me test this release!

You can download the ConfigMgr 2012 Client MP Version 1.2.0.0 [**HERE**](http://blog.tyang.org/wp-content/uploads/2014/10/ConfigMgr-2012-Client-MP-V1.2.0.0.zip).

Until next time, happy SCOMMING!