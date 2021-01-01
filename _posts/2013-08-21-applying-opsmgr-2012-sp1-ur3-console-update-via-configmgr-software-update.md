---
id: 2081
title: Applying OpsMgr 2012 SP1 UR3 Console Update via ConfigMgr Software Update
date: 2013-08-21T23:00:29+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=2081
permalink: /2013/08/21/applying-opsmgr-2012-sp1-ur3-console-update-via-configmgr-software-update/
categories:
  - SCOM
tags:
  - SCOM
  - SCOM Update Rollup
---
OpsMgr 2012 Sp1 Update Rollup 3 has been released for about a month now. Today I had some time after dinner so I thought it’s time for me to get my lab environment updated.

In the past, I’ve been updating the OpsMgr server roles manually and using ConfigMgr Software Update (SUP) to apply the agent and console updates.

While I was downloading the updates manually from WSUS (so I can manually update server roles), I noticed the console update is pretty big (621.5MB):

<a href="http://blog.tyang.org/wp-content/uploads/2013/08/image11.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/08/image_thumb11.png" width="580" height="71" border="0" /></a>

This is because it contains updates for different languages. If I manually download it, I’ll see a list of same update, for different languages:

<a href="http://blog.tyang.org/wp-content/uploads/2013/08/image12.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/08/image_thumb12.png" width="523" height="656" border="0" /></a>

As shown above, there are 2 updates for each language (both 32 bit and 64 bit). My environment only requires the English version (enu). so when I tried to download it in ConfigMgr, I only selected English. I noticed it took a bit too long to download over the ADSL 2 connection I have at home. When it’s done, the confirmation window shown it has successfully downloaded the update to the deployment package that I specified, for English Language only:

<a href="http://blog.tyang.org/wp-content/uploads/2013/08/image13.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/08/image_thumb13.png" width="566" height="561" border="0" /></a>

The update list I created in ConfigMgr only contains this one update, and the deployment package is brand new as well (does not contain updates from other update lists):

<a href="http://blog.tyang.org/wp-content/uploads/2013/08/image14.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/08/image_thumb14.png" width="478" height="294" border="0" /></a>

I then had a look at the package source folder for this deployment package and guess what?

<a href="http://blog.tyang.org/wp-content/uploads/2013/08/image15.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/08/image_thumb15.png" width="318" height="391" border="0" /></a>

it contains not only the English one, but also everything else!

<a href="http://blog.tyang.org/wp-content/uploads/2013/08/image16.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/08/image_thumb16.png" width="377" height="501" border="0" /></a>

For example, the first folder on the list contains the 32bit Russian version:

<a href="http://blog.tyang.org/wp-content/uploads/2013/08/image17.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/08/image_thumb17.png" width="511" height="131" border="0" /></a>

Looks like the OpsMgr 2012 Update Rollup updates do not honour the language selection in WSUS. This may not be an issue if all your ConfigMgr distribution points are connected to your site server over fast and reliable links and storage on your DP’s are not an issue. If the network link and the storage is an issue with your DP’s, this may be something you need to be aware of. Personally, I’d explore other options when next time I apply OpsMgr 2012 update rollup for console updates. On top of my head, I can think of two alternative approach straightaway:
<ol>
	<li>Package it up as a normal package in ConfigMgr.</li>
	<li>Since this update is in .msp format, I can easily create my own update using the System Center Update Publisher 2011 (SCUP) that is connected to my ConfigMgr 2012 SP1 hierarchy.</li>
</ol>