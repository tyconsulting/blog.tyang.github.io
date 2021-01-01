---
id: 4733
title: 'Automating OpsMgr Part 18: Second Update to the OpsMgrExtended Module (v1.2)'
date: 2015-10-14T17:17:03+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=4733
permalink: /2015/10/14/automating-opsmgr-part-18-second-update-to-the-opsmgrextended-module-v1-2/
categories:
  - PowerShell
  - SCOM
  - SMA
tags:
  - Automating OpsMgr
  - PowerShell
  - SCOM
  - SMA
---
<h3><a href="http://blog.tyang.org/wp-content/uploads/2015/06/OpsMgrExnteded.png"><img class="alignleft size-thumbnail wp-image-4038" src="http://blog.tyang.org/wp-content/uploads/2015/06/OpsMgrExnteded-150x150.png" alt="OpsMgrExnteded" width="150" height="150" /></a>Introduction</h3>
This is the 18th instalment of the Automating OpsMgr series. Previously on this series:
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
</ul>
Before I diving into the topic of creating generic rules using the<strong> New-OMRule</strong> function from the <strong>OpsMgrExtended</strong> module, I have updated this module again. It is now on version 1.2.

I was working on another project and I needed to use the New-OMRule function to create rules and I realised this function did not support specifying optional RunAs accounts for member modules. As I needed to create rules that use a RunAs account in the data source module, I had to update this function to accommodate it.

Additionally, as I mentioned in the previous post (Part 17), there is a bug in the New-WindowsServiceTemplateInstance function, where the description field is not populated. I have also fixed it in this release.
<h3>What’s New?</h3>
So, in summary, here’s what’s changed:
<ul>
	<li>Updated OM-Rule function to allow specifying optional RunAs profile for each member module.</li>
	<li>Fixed the issue in New-WindowsServiceTemplateInstance function where the description field is not populated.</li>
</ul>
<h3>Where to Download V1.2?</h3>
I have updated the original link, so you can download this updated version at TY Consulting’s web site: <a href="http://www.tyconsulting.com.au/portfolio/opsmgrextended-powershell-and-sma-module/">http://www.tyconsulting.com.au/portfolio/opsmgrextended-powershell-and-sma-module/</a>
<h3>Conclusion</h3>
Now that I’ve updated and enhanced the New-OMRule function I will demonstrate how to create rules using this function as planned in the next module.