---
id: 2621
title: Use of Disable Operations Manager alerts option in ConfigMgr
date: 2014-04-24T02:00:40+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=2621
permalink: /2014/04/24/use-disable-operations-manager-alerts-option-configmgr/
categories:
  - SCCM
  - SCOM
tags:
  - SCCM
  - SCOM
---
In System Center Configuration Manager, there is an option “<em>Disable Operations manager alerts while this program runs</em>” in the program within a package:

<a href="http://blog.tyang.org/wp-content/uploads/2014/04/SNAGHTMLb8938c7.png"><img style="display: inline; border: 0px;" title="SNAGHTMLb8938c7" src="http://blog.tyang.org/wp-content/uploads/2014/04/SNAGHTMLb8938c7_thumb.png" alt="SNAGHTMLb8938c7" width="435" height="288" border="0" /></a>

There are also same options in the deployment of ConfigMgr 2012 applications and Software update groups:

Application Deployment:

<a href="http://blog.tyang.org/wp-content/uploads/2014/04/SNAGHTMLb8d0495.png"><img style="display: inline; border: 0px;" title="SNAGHTMLb8d0495" src="http://blog.tyang.org/wp-content/uploads/2014/04/SNAGHTMLb8d0495_thumb.png" alt="SNAGHTMLb8d0495" width="449" height="412" border="0" /></a>

Software Update Groups Deployment:

<a href="http://blog.tyang.org/wp-content/uploads/2014/04/SNAGHTMLb8bc86b.png"><img style="display: inline; border: 0px;" title="SNAGHTMLb8bc86b" src="http://blog.tyang.org/wp-content/uploads/2014/04/SNAGHTMLb8bc86b_thumb.png" alt="SNAGHTMLb8bc86b" width="450" height="400" border="0" /></a>

Most of seasoned System Center specialists must already know that these tick boxes do not make the computers enter maintenance mode in OpsMgr. It’s suppressing alerts by pausing the OpsMgr healthservice. As far as I know, there is no way to initiate maintenance mode from an agent. Maintenance mode can only be started from the management server (via Consoles or any scripts / runbooks / applications via SDK).

I am a little bit concerned about enabling these options on deployments targeting OpsMgr management servers. Since I am on holidays this week and have some spare time, I have spent some time in my lab today and performed some tests.

The OpsMgr 2012 R2 management group running in my lab consists of 3 management servers. 2 of which (named OpsMgrMS01 and OpsMgrMS02) are dedicated for managing Windows computers, the 3rd one OpsMgrMS03 is used to manage network devices and UNIX computers. I configured my management group to heartbeat every 60 seconds and allow up to 3 missing heartbeats.

I created a simple batch file to wait 15 minutes and does nothing:

<a href="http://blog.tyang.org/wp-content/uploads/2014/04/image35.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/04/image_thumb35.png" alt="image" width="355" height="207" border="0" /></a>

I then created a package and a program in my lab’s ConfigMgr 2012 R2 site, distributed the package to all the distribution points, made sure the “Disable Operations Manager alerts while this program runs” is ticked.

I performed 4 series of the test by deploying this program to different management servers (or combination of management servers):

<strong>Test 1: Targeting Single Management Server OpsMgrMS02.</strong>

In OpsMgrMS02, there is one agent that hasn’t had failover management servers configured. so I firstly <span style="text-decoration: line-through;">advertised</span> I meant deployed this program to it. When the deployment kicked off, the HealthService entered pause state:

<a href="http://blog.tyang.org/wp-content/uploads/2014/04/image36.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/04/image_thumb36.png" alt="image" width="580" height="225" border="0" /></a>

And Event 1217 was logged to the Operations Manager log:

<a href="http://blog.tyang.org/wp-content/uploads/2014/04/image37.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/04/image_thumb37.png" alt="image" width="514" height="312" border="0" /></a>

I then waited 15 minutes, I was happy to see that no alerts were logged during this period. I checked few agents who are reporting to OpsMgrMS02, including the one without failover management servers configured. none of them complained about not able to contact the primary management server and no one has failed over to the secondary management servers.

<strong>Test 2: Targeting all 3 management servers</strong>

I deleted the execution history from OpsMgrMS02’s registry, added the other 2 management servers to the collection in ConfigMgr and then created another mandatory assignment.

3 minutes after the deployment has kicked off on all management servers, I got an alert told me  that the All Management Servers Resource Pool is not available:

<a href="http://blog.tyang.org/wp-content/uploads/2014/04/image38.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/04/image_thumb38.png" alt="image" width="580" height="251" border="0" /></a>

I then powered off 2 virtual machines that are monitored in OpsMgr. As expected, I did not get any alerts for these 2 computers while the ConfigMgr deployment was running (because HealthService on all 3 management servers were paused). after 10 minutes or so, they are still not greyed out in the state view:

<a href="http://blog.tyang.org/wp-content/uploads/2014/04/image39.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/04/image_thumb39.png" alt="image" width="556" height="250" border="0" /></a>

Soon after the ConfigMgr deployment has finished, the healthservice on all management servers were running again, I got the alerts for the 2 offline agents very shortly because they were still off at that point of time.

<a href="http://blog.tyang.org/wp-content/uploads/2014/04/image40.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/04/image_thumb40.png" alt="image" width="541" height="286" border="0" /></a>

I also had a look at a performance view from the Windows Server MP:

<a href="http://blog.tyang.org/wp-content/uploads/2014/04/image41.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/04/image_thumb41.png" alt="image" width="580" height="403" border="0" /></a>

I picked a memory counter, the perf collection rule is configured to run every 10 minutes. As you can see from above figure, during the package deployment, the performance data was not collected because there’s 20 minutes apart between 2 readings (supposed to be 10) and the 15-minute deployment falls into the this time window.

<strong>Test 3: Targeting OpsMgrMS01</strong>

I’ve decided to test on a single MS again. This time I picked the first management server. After the HealthService is paused, I powered off a VM that is reporting to this management server. I was happy to see that the alerts were generated within few minutes (so it should!).

<strong>Test 4: Targeting 2 out of 3 Management Servers</strong>

For the final test, I targeted OpsMgrMS02 and OpsMgrMS03. Because resource pools require minimum 50% of their members to be healthy. by targeting 2 out of 3 management servers, the All Management Servers Resource Pool became unavailable again. I shutdown 2 virtual machines reporting to OpsMgrMS02. I got the same result as Test 2. alerts were only generated after 15 minutes, when healthservice on 2 management servers have resumed running.

<strong>Summary</strong>

<strong><span style="color: #ff0000;">Note:</span></strong> Below recommendations are only based on my <strong><span style="color: #ff0000;">PERSONAL</span></strong> experience / opinions:

Based on my tests, I strongly recommend not to use these options during ConfigMgr package / application / software update deployments.

In large organisations, the team who’s using ConfigMgr managing the server fleet is probably not the same people who look after the OpsMgr environments. OpsMgr administrators may not even aware these issues are caused by ConfigMgr deployments because OpsMgr event logs on management servers get filled out fairly quickly. that particular event 1217 may have already been overwritten by the time the OpsMgr administrators are looking for the cause.

By using this option against management servers, you are not only suppressing alerts on for management servers themselves, but also critical alerts (such as computers offline) of the entire management group.

In large management groups, you may get away with just targeting 1 or few management servers because as long as there are more than 50% of management servers running, AMSRP will still be functional. but if your management groups are fairly small (i.e. 2 management servers), you need to be aware that if you pause healthservice on even just 1 MS, AMSRP will be unavailable.

Depending on the nature of the ConfigMgr deployments for your OpsMgr management servers, if no reboots are required, you may want to only select the specific class that is impacted by the deployment to enter the maintenance mode  (i.e. computer role, application components, etc). If reboots are required, make sure failover management servers are configured for all your agents and then disable any alert connectors / subscriptions and stage the reboot process among all your management servers. Nowadays, most likely your management servers will be running on a virtualised platform, so the reboot process should be really quick.

Lastly, I’d like to hear about your opinion. If you have anything to add or disagree with me, please feel free to comment in this post or drop me an email.