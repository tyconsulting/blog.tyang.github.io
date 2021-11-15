---
id: 3156
title: ConfigMgr 2012 (R2) Client Management Pack Updated to Version 1.1.0.0
date: 2014-09-19T21:46:30+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=3156
permalink: /2014/09/19/configmgr-2012-r2-client-management-pack-updated-version-1-1-0-0/
categories:
  - SCOM
tags:
  - Featured
  - MP Authoring
  - SCCM
  - SCOM
---
<span style="color: #ff0000;">**4th October, 2014: This MP has been updated to Version 1.2.0.0. Please download the latest version from this page: <a href="https://blog.tyang.org/2014/10/04/updated-configmgr-2012-r2-client-management-pack-version-1-2-0-0/">https://blog.tyang.org/2014/10/04/updated-configmgr-2012-r2-client-management-pack-version-1-2-0-0/</a>.**</span>

OK, after few weeks of hard work, the updated version of the ConfigMgr 2012 (R2) Client MP is finally here.

The big focus in this release is to reduce the noise this MP generates. In the end, besides the new and updated components I have introduced in this MP, I also had to update every single script used by the monitors and rule.

The changes since previous version (v1.0.1.0) are listed below:

## Bug Fixes:

* Software Update agent health not rolled up (dependency monitors was missed in the previous release).
* SyncTime in some data source modules were not correctly implemented
* Typo in Pending Software update monitor alert description
* The "All ConfigMgr 2012 Client computer group" population is incorrect. It includes all windows computers, not just the ones with ConfigMgr 2012 client installed.
* Many warning alerts "Operations Manager failed to start a process" generated against various scripts used in this MP. It has been identified the issue is caused by the OpsMgr agent executing the workflows when the SMS Agent Host service is not running. This typically happened right after computer startup or reboot because SMS Agent Host service is set to Automatic (Delayed). All the scripts that query root\ccm WMI namespace have been re-written to wait up to 3 minutes for the SMS Agent Host to start (if it’s not already started). Hopefully this will reduce the number of these warning alerts. The updated scripts will also try to catch such condition so the alert indicates the actual issue:

	![](https://blog.tyang.org/wp-content/uploads/2014/09/clip_image002.jpg)

## Additional Items:

* A diagnostic task and a recovery task for the CcmExec service monitor. The diagnostic task detects if the system uptime is longer than 5 minutes (overrideable), if the system uptime is longer than 5 minutes, the recovery task will start the SMS Agent Host service. Both the service monitor and the recovery task are disabled by default. –If you decide to use this service monitor and the recovery task (both disabled by default), it would help to reduce the number of failed start a process warning alerts caused by stopped SMS Agent Host service.
* Monitor if the SCCM client has been placed into the Provisioning mode for a long period of time (Consecutive Sample monitor) (<a href="http://thoughtsonopsmgr.blogspot.com.au/2014/06/sccm-w7-osd-task-sequence-with-install.html">http://thoughtsonopsmgr.blogspot.com.au/2014/06/sccm-w7-osd-task-sequence-with-install.html</a>)
* The Missing CCMEval Consecutive Sample unit monitor has been disabled and replaced by a new monitor. The new monitor is no longer a consecutive sample monitor, it will simply detect if the CCMEval job has missed 5 consecutive cycles (number of missing cycles is overrideable). This new monitor is designed to simplify the detection process and to address the false alerts the previous consecutive monitor generates.
* Monitor CCMCache size. Alert when the available free space for the CCMCache is lower than 20%. Some ConfigMgr client computers may be hosted on expensive storage devices (i.e. 90% of my lab machines are now running on SSD). Therefore I think it is necessary to monitor the ccmcache usage.  This monitor provides an indication on how much space has been consumed by ccmcache folder.
* Agent Task: Delete CCMCache content


## Updated Items:


* Pending Reboot monitor updated to allow users to disable any of the 4 areas that the monitor checks for reboot (Pending File Rename operation is disabled by default because it generates too many alerts):
  * Component Based Serving
  * Windows Software Update Agent
  * SCCM Client
  * Pending File Rename operation
* The Missing CCMEval monitor is disabled and superseded.
* All consecutive samples monitors have been updated. The **System.ConsolidatorCondition** condition detection module has been replaced by the <strong><MatchCount></strong> configuration in the <strong>System.ExpressionFilter</strong> module (New in OpsMgr 2012) to consolidate consecutive samples. It simplifies the configuration and tuning process of these consecutive sample monitors.
* Additional events logged in the Operations manager event log by various scripts. – help with troubleshooting. Please refer to Appendix A of the MP documentation for the details of these events.


## Upgrade Tip

This version is in-place upgradable from the previous version. However, since there are additional input parameters introduced to the scripts used by monitors and rule, you may experience a large number of "Operations Manager failed to start a process" warning alert right after the updated MPs have been imported and distributed to the OpsMgr agents. To workaround this issue, I strongly recommend to place the "All ConfigMgr 2012 Clients" group into maintenance mode for 1 hour before importing the updated MPs. To do so, simply go the the "Discovered Inventory" view, and change the target type to "All ConfigMgr 2012 Clients", and place the selected group into maintenance mode.

<a href="https://blog.tyang.org/wp-content/uploads/2014/09/SNAGHTML30b0e7ee.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML30b0e7ee" src="https://blog.tyang.org/wp-content/uploads/2014/09/SNAGHTML30b0e7ee_thumb.png" alt="SNAGHTML30b0e7ee" width="661" height="494" border="0" /></a>

## Special Thanks

I’d like to thank all the people who has provided the feedback since the last release and spent time helped with testing this version. I’d like to specially thank <a href="https://cloudadministrator.wordpress.com/">Stanislav Zhelyazkov</a> for this valuable feedbacks and the testing effort. I’d also like to Thank Marnix Wolf for his <a href="http://thoughtsonopsmgr.blogspot.com.au/2014/06/sccm-w7-osd-task-sequence-with-install.html">blog post</a> which has helped me built the Provisioning Mode Consecutive Sample monitor in this MP.

## Download

<a href="https://blog.tyang.org/wp-content/uploads/2014/09/ConfigMgr-2012-Client-MP-V1.1.0.0.zip">Download ConfigMgr 2012 (R2) Client Management Pack 1.1.0.0</a>