---
id: 3683
title: 'Microsoft MVP Community Camp 2015 and My Session for SMA Integration Module: OpsMgrExtended'
date: 2015-01-23T21:15:53+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=3683
permalink: /2015/01/23/microsoft-mvp-community-camp-2015-session-sma-integration-module-opsmgrextended/
categories:
  - MVP
  - SCOM
  - SMA
tags:
  - MVP
  - SCOM
  - SMA
---
<p align="left"><a href="http://blog.tyang.org/wp-content/uploads/2015/01/141215_comcamp2015_Melbourne_01.jpg"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="141215_comcamp2015_Melbourne_01" src="http://blog.tyang.org/wp-content/uploads/2015/01/141215_comcamp2015_Melbourne_01_thumb.jpg" alt="141215_comcamp2015_Melbourne_01" width="553" height="313" border="0" /></a></p>
On next Friday (30th Jan, 2015), I will be speaking at the Microsoft MVP Community Camp Day in Melbourne. I am pretty excited about this event as this is going to be my first presentation since I have become a System Center MVP in July 2014.

My session is titled "Automating SCOM tasks using SMA". Although this name sounds a little bit boring, let me assure you, it won’t be boring at all! The stuff I’m going to demonstrate is something I’ve been working on during my spare time over the last 6 month, and so far I’ve already written over 6,000 lines of PowerShell code. Basically, I have created a module called "OpsMgrExtended". this module can be used as a SMA Integration Module as well as a standalone PoewrShell module. It directly interact with OpsMgr SDKs, and can be used by SMA runbooks or PowerShell scripts to perform some advanced tasks in OpsMgr such as configuring management groups, creating rules, monitors, groups, overrides, etc.

If you have heard or used my OpsMgr Self Maintenance MP, you’d know that I have already automated many maintenance / administrative tasks in this MP, using nothing but OpsMgr itself. In this presentation, I will not be showing you anything that’s already been done by the Self Maintenance MP. I will heavily focus on automating management pack authoring tasks.

To date, I haven’t really discussed this piece of work in details with anyone other than few SCOM focused MVPs (and my wife of course). This is going to be the first time I’m demonstrating this project in public.

In order to help promoting this event, and also, trying to "lure" you to come to my session if you are based in Melbourne, I’ve recorded a short video demonstrating how I’ve automated the creation of a blank MP and then a Performance Monitor rule (with override) using SharePoint, Orchestrator and SMA. I will also include this same demo in my presentation, and it is probably going to be one of the easier ones <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" src="http://blog.tyang.org/wp-content/uploads/2015/01/wlEmoticon-smile.png" alt="Smile" />.

I’ve uploaded the recording to YouTube, you can watch from <a href="https://www.youtube.com/watch?v=aX9oSj_eKeY">https://www.youtube.com/watch?v=aX9oSj_eKeY</a> or from below:
<div id="scid:5737277B-5D6D-4f48-ABFC-DD9C333F4C5D:350a6272-7fac-4950-b22b-4a39718f0b0f" class="wlWriterEditableSmartContent" style="float: none; margin: 0px; display: inline; padding: 0px;">
<div><object width="705" height="395"><param name="movie" value="http://www.youtube.com/v/aX9oSj_eKeY?hl=en&hd=1" /><embed src="http://www.youtube.com/v/aX9oSj_eKeY?hl=en&hd=1" type="application/x-shockwave-flash" width="705" height="395" /></object></div>
<div style="width: 705px; clear: both; font-size: .8em;">Please watch in Youtube and switch to the full screen mode.</div>
</div>
&nbsp;

If you like what you saw and would like to see more and find out what’s under the hood, please come to this free event next Friday. You can register from <a href="https://msevents.microsoft.com/CUI/EventDetail.aspx?EventID=1032610277&Culture=en-AU&community=0">here</a>.

<a href="http://blog.tyang.org/wp-content/uploads/2015/01/image8.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/01/image_thumb8.png" alt="image" width="646" height="696" border="0" /></a>