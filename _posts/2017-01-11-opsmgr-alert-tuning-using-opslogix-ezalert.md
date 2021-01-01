---
id: 5861
title: OpsMgr Alert Tuning using OpsLogix EZalert
date: 2017-01-11T11:50:28+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=5861
permalink: /2017/01/11/opsmgr-alert-tuning-using-opslogix-ezalert/
categories:
  - SCOM
tags:
  - OpsLogix
  - SCOM
---
<a href="http://blog.tyang.org/wp-content/uploads/2017/01/EZAlert.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="EZAlert" src="http://blog.tyang.org/wp-content/uploads/2017/01/EZAlert_thumb.png" alt="EZAlert" width="427" height="106" border="0" /></a>

OpsLogix has recently released a new product to the market called “EZalert”. It learns the operator’s alert handling behaviour and then it is able to automatically update Alert resolution states based on its learning outcome. You can find more information about this product here: <a title="http://www.opslogix.com/ezalert/" href="http://www.opslogix.com/ezalert/">http://www.opslogix.com/ezalert/</a>. I was given a trail license for evaluation and review. Today I installed it on a dedicated VM and connected it to my lab OpsMgr management group.
<h3>EZalert Walkthrough</h3>
Once installed, I could see a new dashboard view added in the monitoring pane, and this is where we tune all the alerts:

<a href="http://blog.tyang.org/wp-content/uploads/2017/01/image.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2017/01/image_thumb.png" alt="image" width="682" height="450" border="0" /></a>

From this view, I can see all the active alerts, and I can start tuning then either one at a time, or I can multiple select and set desired state in bulk. Once I have gone through all the alerts on the list, I can choose to save the configuration under the Settings tab:

<a href="http://blog.tyang.org/wp-content/uploads/2017/01/image-1.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2017/01/image_thumb-1.png" alt="image" width="631" height="479" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2017/01/image-2.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2017/01/image_thumb-2.png" alt="image" width="349" height="395" border="0" /></a>

Once this is done, any new alerts that have previously been trained will be updated automatically when it was generated. i.e. I have created a test alert and trained EZalert to set the resolution state to Closed, as you can see below, it was created at 9:44:57AM and modified by EZalert 2 seconds later:

<a href="http://blog.tyang.org/wp-content/uploads/2017/01/image-3.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2017/01/image_thumb-3.png" alt="image" width="700" height="149" border="0" /></a>

Once the initial training process is completed and saved, the training tab will become empty. Any new alerts generated will show up in the training tab, and you can see if there’s a suggested state assigned, and you can also modify it by assigning another state:

<a href="http://blog.tyang.org/wp-content/uploads/2017/01/image-4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2017/01/image_thumb-4.png" alt="image" width="411" height="196" border="0" /></a>

And all previously trained alerts can be found in the history tab:

<a href="http://blog.tyang.org/wp-content/uploads/2017/01/image-5.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2017/01/image_thumb-5.png" alt="image" width="683" height="469" border="0" /></a>

You can also create exclusions. if you want EZalert to skip certain alerts for certain monitoring object (i.e. Disk space alert generated on C:\ on Server A), you can do so by creating exclusions:

<a href="http://blog.tyang.org/wp-content/uploads/2017/01/image-6.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2017/01/image_thumb-6.png" alt="image" width="417" height="474" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2017/01/image-7.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2017/01/image_thumb-7.png" alt="image" width="410" height="385" border="0" /></a>

In my opinion, this is a very good practice when tuning alerts. when setting alert resolution states, you only need to do it once, and EZalert learns your behaviour and repeat your action for you in the future. It will be a huge time saver for all your OpsMgr operators over the time. It will also become very handy for alert tuning in the follow situations:
<ul>
 	<li>When you have just deployed a new OpsMgr management group</li>
 	<li>When you have introduced new management packs in your management group</li>
 	<li>When you have updated existing management packs to the newer versions</li>
</ul>
<h3>EZalert vs Alert Update Connector</h3>
Before EZalert’s time, I have been using the OpsMgr Alert Update Connector (AUC) from Microsoft (<a title="https://blogs.technet.microsoft.com/kevinholman/2012/09/29/opsmgr-public-release-of-the-alert-update-connector/" href="https://blogs.technet.microsoft.com/kevinholman/2012/09/29/opsmgr-public-release-of-the-alert-update-connector/">https://blogs.technet.microsoft.com/kevinholman/2012/09/29/opsmgr-public-release-of-the-alert-update-connector/</a>). I was really struggling when configuring AUC so I developed my own solution to configure AUC in an automated fashion  (<a title="http://blog.tyang.org/2014/04/19/programmatically-generating-opsmgr-2012-alert-update-connector-configuration-xml/" href="http://blog.tyang.org/2014/04/19/programmatically-generating-opsmgr-2012-alert-update-connector-configuration-xml/">http://blog.tyang.org/2014/04/19/programmatically-generating-opsmgr-2012-alert-update-connector-configuration-xml/</a>) and I have also developed a management pack to monitor it (<a title="http://blog.tyang.org/2014/05/31/updated-opsmgr-2012-alert-update-connector-management-pack/" href="http://blog.tyang.org/2014/05/31/updated-opsmgr-2012-alert-update-connector-management-pack/">http://blog.tyang.org/2014/05/31/updated-opsmgr-2012-alert-update-connector-management-pack/</a>). In my opinion, AUC  is a solid solution. It’s been around for many years and being used by many customers. But I do find it has some limitations:
<ul>
 	<li>Configuration process is really hard</li>
 	<li>Configuration is based on rules and monitors, not alerts. So it’s easy to incorrectly configure rules and monitors that don’t generate alerts (i.e. perf / event collection rules, aggregate / dependency monitors, etc).</li>
 	<li>Modifying existing configuration causes service interrupt due to service restart</li>
 	<li>When running in a distributed environment (on multiple management servers), you need to make sure configuration files are consistent across these servers and only one instance is running at any given time.</li>
 	<li>No way to easily view the current configurations (without reading XML files)</li>
</ul>
I think EZalert has definitely addressed some of these shortcomings:
<ul>
 	<li>Alert training process is performed on the OpsMgr console</li>
 	<li>No need to restart services and reload configuration files after new alerts are added or when existing alerts are modified</li>
 	<li>Configurations are saved in a SQL database, not text based files</li>
 	<li>Current configuration are easily viewable within the SCOM console</li>
</ul>
However, AUC has the following advantages over EZalert:
<ul>
 	<li>AUC supports assigning different values to different groups or individual objects. In EZalert, the exception can only be created for individual monitoring objects and it doesn’t seem like you can assign different value for this object, it’s simply on/off exception</li>
 	<li>Other than Alert resolution state, AUC can also be used to update other alert properties (i.e. custom fields, Owner, ticket ID,  etc.). EZalert doesn’t seem like it can update other alert fields.</li>
</ul>
<h3>Things to Consider</h3>
When using EZalert, in my opinion, there are few things you need to consider:

<strong>1. It does not replace requirements for overrides</strong>

If you are training EZalert to automatically close an alert when it’s generated, then you should ask yourself - do you really need this alert to be generated in the first place? Unless you want to see these alerts in the alert statistics report, you should probably disable this alert via overrides. EZalert should not be used to replace overrides. if you don’t need this alert, disable it! it saves resources on both SCOM server and agent to process alert, and database space to store the alert.

<strong>2. Training Monitor generated alerts</strong>

As we all know, we shouldn’t manually close monitor generated alerts. So when you are training monitor alerts, make sure you don’t train EZalert to update the resolution state to “Closed”. consider using other states such as “Resolved”.

<strong>3. Create Scoped roles for normal operators in order to hide the EZalert dashboard view</strong>

You may not want normal operators to train alerts, so instead of using the built-in operators role, you’d better create your own scoped role and hide the EZalert dashboard view from normal operators
<h3>Conclusion</h3>
I believe EZalert has some strong use cases. Unless you have a very complicated alert flow automation process that leverages other alert fields such as custom fields, owner, etc. (i.e. for generating tickets, etc) and you are currently using AUC for this particular reason, I think EZalert gives you a much more user friendly experience for ongoing alert tuning.

I have personally implemented AUC in few places, and I still get calls every now and then from those places asking help with AUC configuration and it’s been few years since it was implemented. Also I’m not exactly sure if AUC is officially supported by Microsoft because it was originally developed by an OpsMgr PFE at this spare time (I’m not entirely sure about the supportability of AUC, maybe someone from MSFT can confirm). Whereas EZalert is a commercial product, the vendor OpsLogix provide full support of  it.

lastly, if you have any questions about EZalert, please feel free to contact OpsLogix directly.