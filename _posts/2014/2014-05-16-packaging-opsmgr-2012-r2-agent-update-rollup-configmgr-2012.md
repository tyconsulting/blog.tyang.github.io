---
id: 2671
title: Packaging OpsMgr 2012 R2 Agent WITH Update Rollup in ConfigMgr 2012
date: 2014-05-16T00:20:00+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=2671
permalink: /2014/05/16/packaging-opsmgr-2012-r2-agent-update-rollup-configmgr-2012/
categories:
  - SCCM
  - SCOM
tags:
  - SCOM
  - SCOM Update Rollup
---
<strong>Background</strong>

About 6 months ago, I wrote a 2-part blog series on deploying OpsMgr 2012 R2 agents using ConfigMgr  (<a href="https://blog.tyang.org/2013/11/30/deploying-opsmgr-2012-r2-agents-using-configmgr-part-1/">Part 1</a>, <a href="https://blog.tyang.org/2013/11/30/deploying-opsmgr-202-r2-agents-using-configmgr-part-2/">Part 2</a>). Since then, Update Rollup 1 and Update Rollup 2 has been released. Because UR1 did not include agent updates, I didn’t have to patch any agents. The most recent release of Update Rollup 2 does include agent updates, I’ll have to get the agents patched.

For me, and the project that I’m working on, this is a perfect timing, UR2 was release right before we production transitioning our newly built OpsMgr 2012 R2 management groups and we are just about to start piloting, so I have quickly patched all OpsMgr 2012 R2 management groups with UR2 and from agents point of view, UR2 would now become part of our baseline (for now).

I have determined that the best way for me to incorporate UR2 agent updates to the current agent application in ConfigMgr is to somehow "Slipstream" the update into the agent install. This is due to the size, nature of the environments, and the release management and patch management policies that I can’t comment on.

When I said "Slipstream", OpsMgr 2012 agents UR updates can’t really be slipstreamed into the agent install msi. So what I have done is to create an application in ConfigMgr that will install the agent AS WELL AS the update.

I’ll now go through the steps I took to setup the ConfigMgr application object.

<strong>Instruction</strong>

<strong><span style="color: #ff0000;">Note:</span></strong> The steps I took are largely the same as the Part 2 of the original post. I will only go through the changes I have made based on the original package rather than documenting it again from scratch.

01. I firstly duplicated the ConfigMgr source content of the original agent application to another folder.

02. Placed the agent UR2 updates in the AMD64 and i386 folders:

AMD64:

<a href="https://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML40ea9721.png"><img style="display: inline; border: 0px;" title="SNAGHTML40ea9721" src="https://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML40ea9721_thumb.png" alt="SNAGHTML40ea9721" width="492" height="220" border="0" /></a>

i386:

<a href="https://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML40eb7d6a.png"><img style="display: inline; border: 0px;" title="SNAGHTML40eb7d6a" src="https://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML40eb7d6a_thumb.png" alt="SNAGHTML40eb7d6a" width="493" height="206" border="0" /></a>

03. Place the newly created "<a href="https://blog.tyang.org/wp-content/uploads/2014/05/CM12_OM12AgentInstall.zip">CM12_OM12AgentInstall.vbs</a>" on the root folder:

<a href="https://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML40f70b0e.png"><img style="display: inline; border: 0px;" title="SNAGHTML40f70b0e" src="https://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML40f70b0e_thumb.png" alt="SNAGHTML40f70b0e" width="509" height="244" border="0" /></a>

<strong><span style="color: #ff0000;">Note:</span></strong> Please ignore the other 3 scripts in the above screenshot, they were from the 2007 package I created in the original blog post Part 1. They are not required here.

02. created an identical application as described in Part 2 of the original post. -Of course, the application name is changed to something like:

<a href="https://blog.tyang.org/wp-content/uploads/2014/05/image3.png"><img style="display: inline; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/05/image_thumb3.png" alt="image" width="388" height="34" border="0" /></a>

03. Modify the deployment type for the 64 bit machines:

Remove "<strong>\AMD64</strong>" from the end of the content location field.

<a href="https://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML40fea190.png"><img style="display: inline; border: 0px;" title="SNAGHTML40fea190" src="https://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML40fea190_thumb.png" alt="SNAGHTML40fea190" width="446" height="385" border="0" /></a>

Change the installation program from the "msiexec /i …." to <strong>Cscript /nologo CM12_OM12AgentInstall.vbs "64-bit"</strong>

<a href="https://blog.tyang.org/wp-content/uploads/2014/05/image4.png"><img style="display: inline; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/05/image_thumb4.png" alt="image" width="489" height="416" border="0" /></a>

04. Modify the 32 bit deployment type the same way as the 64 bit one:

Remove "\i386" from the end of the content location field and change the installation program to <strong>Cscript /nologo CM12_OM12AgentInstall.vbs "32-bit"</strong>

05. Distribute it to appropriate DP and <strong>test it!</strong>

<strong>Conclusion</strong>

The script used for the installation basically installs the MOMAgent.MSI and then UR2 agent update. It can be modified for installing other previous and future agent UR updates by changing the file names on line 59 and 64

<a href="https://blog.tyang.org/wp-content/uploads/2014/05/image5.png"><img style="display: inline; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/05/image_thumb5.png" alt="image" width="580" height="124" border="0" /></a>

When the application is deployed to a ConfigMgr client, the script creates few log files under C:\Temp:

<a href="https://blog.tyang.org/wp-content/uploads/2014/05/image6.png"><img style="display: inline; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/05/image_thumb6.png" alt="image" width="580" height="153" border="0" /></a>

Same as my original post Part 2, the application package does not configure agents to report to any management groups. This is because in my environment, there are multiple management groups, so I am using ConfigMgr Compliance Settings (aka DCM) to configure the agents. this is also documented in the Part 2 of the original post. If you’d like use the same application package to configure the agent, you can simply modify the CM12_OM12AgentInstall.vbs to also combine with the OM12AgentConfig.vbs that I’ve created in Part 1 of the original post. or create a separate application package and specify the dependency between these packages.