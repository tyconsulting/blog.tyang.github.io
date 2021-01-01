---
id: 2122
title: 'Management Pack for ConfigMgr 2012 Clients &#8211; Testers Wanted!!'
date: 2013-08-31T01:13:16+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=2122
permalink: /2013/08/31/management-pack-configmgr-2012-clients-testers-wanted/
categories:
  - SCCM
  - SCOM
tags:
  - MP Authoring
  - SCCM
  - SCOM
---
<a href="http://blog.tyang.org/wp-content/uploads/2013/08/SCCM-Client-Monitor.png"><img class="alignleft size-medium wp-image-2124" alt="ConfigMgr 2012 Client MP Icon" src="http://blog.tyang.org/wp-content/uploads/2013/08/SCCM-Client-Monitor-300x300.png" width="300" height="300" /></a>I’ve written a OpsMgr management pack to monitor ConfigMgr 2007 clients in the past. The MP was published in <a href="http://blog.tyang.org/2012/03/04/system-center-configuration-manager-sccm-2007-client-management-pack-for-scom/">this blog</a>. Over the last month or so, as part of a project that I’m working on, I have written a Management Pack to monitor ConfigMgr 2012 Clients via OpsMgr 2012. This MP provides individualised monitoring for ConfigMgr 2012 clients, where the Microsoft ConfigMgr 2012 management pack does not.

To be honest, I wasn’t really happy with the ConfigMgr 2007 Client MP that I wrote almost 2 years ago. I think there are a lot of areas that needs improvement. So when I’m writting this MP for 2012 clients, I started from scratch and completely re-written it.

<span style="font-size: large;"><strong>MP Overview</strong></span>

This MP monitors scenarios listed below:

<strong>Detect Non-Compliant DCM baselines assigned to the ConfigMgr 2012 client</strong>

I often get requests to write monitors to monitor registry key values, file versions, etc. The DCM component in ConfigMgr is really design to for this purpose. This monitor will alert on ANY Non-Compliant DCM Baselines that are targeted to the ConfigMgr 2012 client. As long as the Configuration Item and DCM baselines are correctly configured, I don’t have to keep writing monitors in OpsMgr to monitor stuff like file versions and registry key values.

<strong>Detect missing hardware and software inventory cycle</strong>

Using Consecutive Samples monitors to detect if the ConfigMgr clients have missed hardware and software inventory cycle for a long period of time.

<strong>Detect failed application deployments on the ConfigMgr 2012 client</strong>

This monitor monitors if any applications (new in ConfigMgr 2012) have failed to deploy on the ConfigMgr 2012 client.

<strong>Detect failed advertisements on the ConfigMgr 2012 client</strong>

This rule is probably the only workflow that I have copied from the previous 2007 version of the MP. It runs on an interval and detects any failed advertisement since the last execution of the rule.

<strong>Detect Pending Software Updates on the ConfigMgr 2012 client</strong>

This monitor detects if there are any software updates that have passed the deadline for a period of time and still have not been installed (either waiting for service windows or failed to install).

<strong>Monitors "SMS Agent Host" service on the ConfigMig 2012 Client</strong>

A basic service monitor was created for this service. it is disabled by default.

Another Consecutive Samples monitor was also created and it would only alert of X number of samples. This monitor is enabled by default.

<strong>Detect Pending reboot on the ConfigMgr 2012 Client</strong>

This monitor detects pending reboot from the following four (4) components:
<ul>
	<li>Windows Component Base Servicing (from Vista onwards).</li>
	<li>Windows Update Agent</li>
	<li>ConfigMgr 2012 Client</li>
	<li>Pending File Rename Operations</li>
</ul>
Detect if business hours and service windows are configured

These monitors detects if the business hours and service windows are configured:

<a href="http://blog.tyang.org/wp-content/uploads/2013/08/Management-Pack-for-ConfigMgr-2012-Clien_13D2C/image.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/08/Management-Pack-for-ConfigMgr-2012-Clien_13D2C/image_thumb.png" width="334" height="150" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2013/08/Management-Pack-for-ConfigMgr-2012-Clien_13D2C/image_3.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/08/Management-Pack-for-ConfigMgr-2012-Clien_13D2C/image_thumb_3.png" width="283" height="298" border="0" /></a>

<strong>Detect if the client is assigned to the correct ConfigMgr primary site</strong>

This monitor is designed to monitor the site code assigned to the ConfigMgr 2012 client. Because each environment is different, this monitor is disabled by default. OpsMgr administrators will need to manually enable it via override. The CorrectSiteCode value will also need to be specified via override in order for this monitor to function properly.

In large ConfigMgr environments, it is very common that there are more than one (1) ConfigMgr hierarchy in the organisation. Sometimes it is very import to make sure ConfigMgr clients are assigned to the correct ConfigMgr primary sites.

<strong>Detect if client is able to communicate to a Management Point</strong>

In the 2007 version of the MP, I wrote a monitor that sends a HTTP request to the management point every hour. I really didn’t like this monitor and regret that I wrote it this way. I believe it was a bad idea to get all ConfigMgr clients to send HTTP request to the management point, and it generates a lot of alerts (I should have written it as a consecutive samples monitor). Luckily in ConfigMgr 2012 client, there is a new WMI class called "<strong>SMS_ActiveMPCandidate</strong>" located under "<strong>Root\Ccm\LocationServices</strong>" namespace. I can simply query this WMI class to find out if the ConfigMgr 2012 client has lost connectivity to the management points. Therefore HTTP request over the network is no longer required.

<strong>Detect if the builtin SCCM Client Health Evaluation (CcmEval) has not been executed according to the schedule.</strong>

CcmEval is a new component in ConfigMgr 2012 client. this consecutive samples monitor queries registry to detect the execution result of CcmEval scheduled task and alert if it not been executed for a long period of time.

The MP also provides various Agent Tasks that can be executed against ConfigMgr 2012 client (or client agents). i.e.

<a href="http://blog.tyang.org/wp-content/uploads/2013/08/Management-Pack-for-ConfigMgr-2012-Clien_13D2C/image_4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/08/Management-Pack-for-ConfigMgr-2012-Clien_13D2C/image_thumb_4.png" width="494" height="319" border="0" /></a>

By design, OpsMgr allows users to trigger an agent task on up to 10 managed objects at once. The figures below illustrates OpsMgr operators can multi-select up to 10 Software Update Agent objects from the state view and trigger the "Software Update Assignments Evaluation Cycle" agent task and task results for each selected node:

<a href="http://blog.tyang.org/wp-content/uploads/2013/08/Management-Pack-for-ConfigMgr-2012-Clien_13D2C/image_5.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/08/Management-Pack-for-ConfigMgr-2012-Clien_13D2C/image_thumb_5.png" width="286" height="376" border="0" /></a>

<strong>Class Diagram</strong>

The ConfigMgr 2012 Client class is defined as a local application and each client agent is defined as an application component (as shown below):

<a href="http://blog.tyang.org/wp-content/uploads/2013/08/Management-Pack-for-ConfigMgr-2012-Clien_13D2C/ConfigMgr-2012-client-Class-Diagram.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="ConfigMgr 2012 client Class Diagram" alt="ConfigMgr 2012 client Class Diagram" src="http://blog.tyang.org/wp-content/uploads/2013/08/Management-Pack-for-ConfigMgr-2012-Clien_13D2C/ConfigMgr-2012-client-Class-Diagram_thumb.png" width="580" height="196" border="0" /></a>

The health state of each client agent is rolled up to the parent class of "ConfigMgr 2012 Client", as indicated below:

<a href="http://blog.tyang.org/wp-content/uploads/2013/08/Management-Pack-for-ConfigMgr-2012-Clien_13D2C/image_6.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/08/Management-Pack-for-ConfigMgr-2012-Clien_13D2C/image_thumb_6.png" width="211" height="369" border="0" /></a>

<span style="font-size: large;"><strong>Design Considerations</strong></span>

During the Management Packs development, the following factors have been taken into consideration:
<ul>
	<li>The solution is built using Visual Studio Authoring Extension (VSAE). All the management packs are using the OpsMgr 2012 version of the MP schema, which means these management packs are not backwards compatible. They will not work in OpsMgr 2007 management groups.</li>
	<li>All scripts used in the management packs are written using VBScript. There are no requirements for Windows PowerShell on OpsMgr agent computers to run the workflows within the management packs.
Various ConfigMgr 2012 Client Agents (DCM agent, Hardware Inventory Agent, Software Update Agent, etc.) are defined as separate local application component object so monitors / rules for these ConfigMgr 2012 Client functions are only applied to the client if these agents are enabled by ConfigMgr client policies.</li>
	<li>All the data gathered by the workflows (discoveries, monitors, rules) are retrieved locally from the ConfigMgr 2012 client. The management packs do not query any ConfigMgr Site Systems.</li>
	<li>The top level initial discovery workflows have been designed to target Windows Server Computer class and Windows Client Computer class separately. The discovery for Windows Client Computer class is disabled by default. Therefore by default, this monitoring solution does not monitor ConfigMgr 2012 Clients on Windows Client computers. If it is required, the monitoring for Windows Client computers has to be manually enabled (by enabling the top level discovery via overrides).</li>
	<li>Wherever is possible, consecutive samples monitors are utilised to reduce the number of possible false alerts in OpsMgr.</li>
</ul>
<strong><span style="font-size: large;">Tested Platform</span></strong>

I was only able to test this MP on multiple OpsMgr 2012 SP1 and ConfigMgr 2012 SP1 environments.

I did not test it on RTM version of OpsMgr 2012 and ConfigMgr 2012 as they are not available for me.

Although System Center 2012 R2 RTM is just around corner, I don’t have any R2 Preview environments that I can use to test.

<span style="font-size: large;"><strong>Known Issue</strong></span>

An error will occur when try to create an override to an unsealed management pack that is created in the OpsMgr operational console:

<a href="http://blog.tyang.org/wp-content/uploads/2013/08/Management-Pack-for-ConfigMgr-2012-Clien_13D2C/image_7.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/08/Management-Pack-for-ConfigMgr-2012-Clien_13D2C/image_thumb_7.png" width="323" height="179" border="0" /></a>

The cause of this issue is the same as my recent OpsMgr Self Maintenance MP: OpsMgr doesn’t like "2012" as part of the ID of the management pack. The workaround is documented in the MP documentation.

<span style="font-size: large;"><strong>Feedback</strong></span>

All the items provided by this MP are based on my best understanding of ConfigMgr 2012 and it’s clients. To be honest, I haven’t really been too "hands on" with ConfigMgr 2012 since it was released. Therefore I’m really keen to invite the broader System Center community to evaluate and test this MP before I change the version number to 1.0.0.0.

Please do not hesitate to contact me for any bugs and if you think any of the workflows are incorrectly written, or if you have suggestions for additional items. In return to the testing effort from the community, I will publish the finishing piece on this blog.

<strong><span style="color: #ff0000;">Note:</span></strong> A friend of mine did suggest me to include the Endpoint Protection clent agent in the MP. I can’t do this at the moment because it is not a requirement for the project. But I will definitely see what I can do in the future release when I have some spare time.

The MP and the documentation can be downloaded below. To help with anyone who’s evaluating the MP, I have documented how and where each workflow retrieves data from the client (either via WMI or registry) in the documentation.

For those who’s willing to help and test this MP, <strong>THANK YOU!</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2013/08/ConfigMgr-2012-Client-Monitoring-0.2.0.0.zip"><strong>DOWNLOAD HERE</strong></a>