---
id: 1114
title: 'SCCM 2012 Log Parser: cmtrace.exe'
date: 2012-04-17T19:35:19+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=1114
permalink: /2012/04/17/sccm-2012-log-parser-cmtrace-exe/
categories:
  - SCCM
tags:
  - SCCM
---
In my opinion, <strong>THE</strong> most used utility (other than SCCM console) for any SCCM administrators / engineers would have to be <strong>trace32.exe</strong>. Back in SMS and SCCM 2007 days, trace32.exe comes with the <a href="http://www.microsoft.com/download/en/details.aspx?id=9257">SCCM Toolkit</a>, which contains a bunch of other tools.

Speaking of my own experience, out of all the tools provided by the toolkit, trace32.exe is the one I used the most.

Now with SCCM 2012, trace32.exe has been replaced by a new tool called <strong>cmtrace.exe</strong>.

Unlike trace32.exe, cmtrace.exe is actually built-in in SCCM, there is no need to download separate toolkits for it. cmtrace.32 can be found on the SCCM site server, under "**SCCM_Install_Dir\tools**" folder. Same as it’s predecessor trace32.exe, cmtrace.exe can be copied / redistributed to other locations / computers alone and use as a log parser.

I have also found that trace32.exe actually does not correct parse SCCM 2012 logs. For example, I’m using both trace32.exe and cmtrace.exe to open execmgr.log from a SCCM 2012 client:

<strong>trace32.exe:</strong>

<a href="https://blog.tyang.org/wp-content/uploads/2012/04/image8.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2012/04/image_thumb8.png" alt="image" width="580" height="410" border="0" /></a>

<strong>cmtrace.exe:</strong>

<a href="https://blog.tyang.org/wp-content/uploads/2012/04/image9.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2012/04/image_thumb9.png" alt="image" width="580" height="467" border="0" /></a>

So, if you are working with SCCM 2012, make sure you use cmtrace.exe rather than the good old trace32.exe. And maybe like me, copy cmtrace32.exe to your local machine and use it from there rather than using it on the server.