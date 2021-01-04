---
id: 2819
title: Updated OpsMgr 2012 Alert Update Connector Management Pack
date: 2014-05-31T11:09:46+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=2819
permalink: /2014/05/31/updated-opsmgr-2012-alert-update-connector-management-pack/
categories:
  - SCOM
tags:
  - MP Authoring
  - SCOM
---
I recently implemented OpsMgr 2012 Alert Update Connector in the new OpsMgr 2012 environments that I’m building. I have previously <a href="http://blog.tyang.org/2014/04/19/programmatically-generating-opsmgr-2012-alert-update-connector-configuration-xml/">blogged</a> my way of generating AUC’s configuration XML.

Now in my environment, AUC is playing a critical role in the alert logging process, it needs to be highly available. nothing will get logged to the ticketing system if AUC is not running. The unsealed management pack that came with AUC monitors each individual instance of Alert Update Connector service. It generates a critical alert when the service is not running while the start mode is configured to Automatic. However, in my opinion, this does not reflect the real health condition of AUC. Since we can install Alert Update Connector service on multiple computers, the connector should be considered as healthy when there is one instance (and one instance only) of the Alert Update Connector service running.

Therefore, I have updated the management pack. I have made the following changes to the original MP:

<strong>01. Bug fix in the VBScript used in Alert Update Connector Discovery</strong>

I have installed the Alert Update Connector service on all the management servers. I also have few Orchestrator runbook servers being monitored agentlessly because they are running runbooks which require OpsMgr 2007 R2 integration pack and console, so I can’t installed OpsMgr 2012 R2 agents on them. After imported the original management pack, I noticed Alert Update Connector services have also been discovered on these Orchestrator runbook servers.

The bug is highlighted below:

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/image37.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/05/image_thumb37.png" alt="image" width="580" height="400" border="0" /></a>

The discovery is configured to be remotable, but when performing the WMI query for the service, it is always querying the local computer where the discovery script is running. This is why the Alert Update Connector service has been incorrectly discovered on agentless monitored computers. This is an easy fix. since the target computer name has already been passed to the script, in line 91, "strComputer" needs be changed to "TargetComputer".

<strong>02. Updated the frequency for Alert Update Connector Discovery</strong>

In the original MP, this discovery runs once per hour. I have updated it every 12 hours.

<strong>03. Additional Monitor: Alert Connector Services Overall Status Monitor</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/image38.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/05/image_thumb38.png" alt="image" width="580" height="270" border="0" /></a>

This monitor is targeting the Alert Update Connector class (which is managed by All Management Servers Resource Pool), and checks number of running instances of Alert Update Connector service. it generates a critical alert when the running instance does not equal to 1.

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/image39.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/05/image_thumb39.png" alt="image" width="580" height="530" border="0" /></a>

This monitor also has 2 recovery tasks

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/image40.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/05/image_thumb40.png" alt="image" width="468" height="454" border="0" /></a>

When there are no running instances, the recovery task "Start One Instance of Alert Update Connector Service" will try to start 1 instance of this service. When the number of running instances is greater than 1, the recovery task "Stop and Disable additional running instances" will stop and disable all but 1 running instances.

The script execution results can be viewed in Health Explorer:

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/image41.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/05/image_thumb41.png" alt="image" width="569" height="376" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/image42.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/05/image_thumb42.png" alt="image" width="580" height="244" border="0" /></a>

Since the connector class is managed by AMSRP, the monitor workflow will run on a management server. If you only have the Alert Update Connector services installed on management servers, and the management server’s default action account should have local admin rights on the management servers, no additional configuration is required. however, if you have Alert update connector service installed on other servers where the default management servers action account does not have local admin rights, you may need to configure the Run-As profile defined in this MP:

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/image43.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/05/image_thumb43.png" alt="image" width="580" height="362" border="0" /></a>

<strong>03. Additional Groups</strong>

I’ve created 2 additional groups:
<ul>
	<li>Alert Update Connector Services Computer group</li>
	<li>Alert Update Connector Services Instance Group</li>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2014/05/image44.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/05/image_thumb44.png" alt="image" width="482" height="80" border="0" /></a>

&nbsp;

<strong>04. Additional Override: Disabled Alert Generation for the "Connector Service Status" monitor.</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/image45.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/05/image_thumb45.png" alt="image" width="555" height="314" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/image46.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/05/image_thumb46.png" alt="image" width="575" height="375" border="0" /></a>

I’m just trying to reduce the noise. Since the newly created overall status monitor will be generating alerts as well, I don’t think we need another one.

<strong>05. Removed the console task "Show Connector UI"</strong>

This task hardcoded the ConnectorConfiguration.exe to C:\AlertUpdateConnectorUI, and I’m not using this GUI tool in my environment (refer to my previous post). Therefore I have removed it from the MP.

I have changed the MP version to 1.0.1.0. I have also converted the original MP to a VSAE project. In the project, I have chopped the MP components into many fragments.

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/image47.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/05/image_thumb47.png" alt="image" width="150" height="464" border="0" /></a>

You can download both sealed and unsealed version of this MP, as well as the VSAE project (to make your life easier if you want to update it to suit your needs). However, I won’t include the key I used in for this MP. if you decided to update and seal it again, please use another key.

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/AlertUpdateConnectorMP.v1.0.1.0.zip"><strong>DOWNLOAD HERE</strong></a>.