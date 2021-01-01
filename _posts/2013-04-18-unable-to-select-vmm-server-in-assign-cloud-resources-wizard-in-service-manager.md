---
id: 1898
title: Unable to Select VMM Server in Assign Cloud Resources Wizard in Service Manager
date: 2013-04-18T22:16:08+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=1898
permalink: /2013/04/18/unable-to-select-vmm-server-in-assign-cloud-resources-wizard-in-service-manager/
categories:
  - SCOM
  - SCSM
  - SCVMM
tags:
  - CSPP
  - SCSM SCOM CI Connector
---
In the last few days, I’ve been going through the labs from Microsoft’s course <em>10750A: Monitoring and Operating a Private Cloud with System Center 2012</em>. As part of the lab, I installed the System Center 2012 SP1 version of the <a href="http://www.microsoft.com/en-us/download/details.aspx?id=36497">Cloud Service Process Pack</a> (CSPP).

Last night, I created a Cloud Resources Subscription Request, and then tried to assign the cloud resources to this request. While I was going through the “Assign Cloud Resources” wizard, I got stuck because my VMM server does not show up in the drop down list:

<a href="http://blog.tyang.org/wp-content/uploads/2013/04/image17.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/04/image_thumb17.png" width="580" height="407" border="0" /></a>

This has really annoyed me as it’s hard for me to find time to study and prepare for the exam with all the stuff going on at work. The only time I can study is from 9:30pm to 1:00am – after my daughter went to bed… the last thing I want to see at 12:00 mid night is an error stop me from going through the lab.

Anyways, after spending some time on google, I found people are having same issues as me and posted the question on the <a href="http://social.technet.microsoft.com/Forums/en-US/privatecloud/thread/edcc7273-2e65-4b12-a7c2-789f6d96fe32/">TechNet forum</a>. As suggested in the forum thread, the issue is the VMM 2012 Discovery management pack.

In my case, this MP was not selected in the SCOM CI connector in Service Manager. I couldn’t select it because it was greyed out in the connector. It was greyed out because the version of the MP loaded in Service Manager was <strong>3.0.6005.0</strong> and the version loaded in OpsMgr is <strong>3.1.6011.0</strong>.

According to <a href="http://social.technet.microsoft.com/wiki/contents/articles/15361.list-of-build-numbers-for-system-center-virtual-machine-manager.aspx">this article</a>, 3.0.6005.0 is the build number for VMM 2012 RTM and 3.1.6011.0 is the build number for VMM 2012 SP1 RTM. Looks like the VMM MP author is trying to match the VMM build version and MP version.

Version <strong>3.0.6005.0</strong> comes with the SP1 version of the Cloud Service Process Pack. Thus this was the one I imported in to Service Manager.

Version <strong>3.1.6011.0</strong> comes with VMM 2012 SP1 installation (located on the VMM server, under &lt;VMM Installation directory&gt;\ManagementPacks directory), and it has been previously imported into my OpsMgr management group.

I also found out the VMM 2012 management pack on Microsoft’s management pack catalog (<a href="http://systemcenter.pinpoint.microsoft.com">http://systemcenter.pinpoint.microsoft.com</a>) is <a href="http://systemcenter.pinpoint.microsoft.com/en-US/applications/Monitoring-Pack-for-System-Center-2012-Virtual-Machine-Manager-12884940307">version 3.0.6019.0</a>, which is different again…

After I imported version 3.1.6011.0 to Service Manager (because it’s the latest version and it’s the version in OpsMgr), I was able to select VMM 2012 Discovery MP in the OpsMgr CI connector:

<a href="http://blog.tyang.org/wp-content/uploads/2013/04/image18.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/04/image_thumb18.png" width="556" height="391" border="0" /></a>

I went to bed after I manually kicked off the connector synchronisation, this morning, the VMM server address appeared in the wizard:

<a href="http://blog.tyang.org/wp-content/uploads/2013/04/image19.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/04/image_thumb19.png" width="580" height="410" border="0" /></a>

Well, I guess it’s all part of the learning. Since I’m still pretty new to Service Manager, I’m not sure how many people in System Center community already know this issue. This post is more like a note to myself. I’m not sure why Microsoft included a very old version of the VMM MP in the most recent release of the Cloud Service Process Pack (which was only released last month).