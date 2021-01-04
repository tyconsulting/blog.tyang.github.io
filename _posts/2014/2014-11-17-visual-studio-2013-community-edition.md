---
id: 3306
title: Visual Studio 2013 Community Edition
date: 2014-11-17T13:53:57+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=3306
permalink: /2014/11/17/visual-studio-2013-community-edition/
categories:
  - Visual Studio
tags:
  - Visual Studio
  - VSAE
---
Nowadays, Visual Studio is definitely one of my top 5 most-used applications. I have also started using Visual Studio Online to store source codes few months ago. I have started migrating my management packs and PowerShell scripts into Visual Studio Online, and connect Visual Studio to my Visual Studio Online repository.

Microsoft has released a new edition of Visual Studio 2013 few days ago: Visual Studio 2013 Community Edition. This morning, in order to test it, I uninstalled Visual Studio Ultimate from one of my laptops, and installed the new community edition instead.

I tested all the features and extensions that I care about, I have to say I’m amazed all of them worked!

<strong>Visual Studio Online:</strong> I am able to connect to my Visual Studio Online and retrieved a Management Pack project that I’m currently working on.

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/SNAGHTML730a5e.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML730a5e" src="http://blog.tyang.org/wp-content/uploads/2014/11/SNAGHTML730a5e_thumb.png" alt="SNAGHTML730a5e" width="451" height="326" border="0" /></a>

&nbsp;

<strong>Visual Studio Authoring Extension (VSAE):</strong> I installed VSAE version 1.1.0.0, same as the previous installation on my laptop, all MP related options are still there:

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/image.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/11/image_thumb.png" alt="image" width="419" height="291" border="0" /></a>

I tried to build the MP in the solution I’m working on, and it was built successfully:

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/SNAGHTML7680c5.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML7680c5" src="http://blog.tyang.org/wp-content/uploads/2014/11/SNAGHTML7680c5_thumb.png" alt="SNAGHTML7680c5" width="649" height="209" border="0" /></a>

&nbsp;

<strong>PowerShell Tools for Visual Studio 2013:</strong> This is a community extension developed by PowerShell MVP Adam Driscoll (More information can be found <a href="http://adamdriscoll.github.io/poshtools/">here</a>). This extension enables Visual Studio as a PowerShell script editor. As expected, it works in the Community edition and my PowerShell script is nicely laid out:

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/SNAGHTML7b8c49.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML7b8c49" src="http://blog.tyang.org/wp-content/uploads/2014/11/SNAGHTML7b8c49_thumb.png" alt="SNAGHTML7b8c49" width="593" height="390" border="0" /></a>

&nbsp;

In the past, when Microsoft has discontinued development of OpsMgr 2007 R2 Authoring Console and replaced it with VSAE, in my opinion, it has made it harder for average IT Pros to start authoring management packs. One of the reasons is that VSAE is an extension for Visual Studio, it requires Visual Studio Professional or Ultimate edition, which are not cheap comparing with the old Authoring console (Free).  Therefore I am really excited to find out VSAE works just fine with the latest free Community edition. I’m hoping the community edition would benefit OpsMgr and Service Manager specialists around the world by providing us an affordable authoring solution.

Lastly, having said that, in terms of licensing for the community edition, there are some limitations. Please read <a href="http://blogs.msdn.com/b/quick_thoughts/archive/2014/11/12/visual-studio-community-2013-free.aspx">THIS</a> article carefully before using it. i.e. If you are working for a large enterprise and are developing a commercial application, you probably not going to able to use it.

<strong><span style="color: #ff0000; font-size: medium;">Disclaimer:</span></strong> In this post, I’m only focusing the technical aspect based on my experience. Please don’t hold me responsible when you misused Visual Studio 2013 Community edition and violated the licensing condition. As I mentioned in the post, please read <a href="http://blogs.msdn.com/b/quick_thoughts/archive/2014/11/12/visual-studio-community-2013-free.aspx">THIS</a> article carefully to determine if you are eligible first!