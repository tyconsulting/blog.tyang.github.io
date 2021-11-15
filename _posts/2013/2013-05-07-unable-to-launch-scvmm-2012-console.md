---
id: 1931
title: Unable to Launch SCVMM 2012 Console
date: 2013-05-07T00:34:03+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=1931
permalink: /2013/05/07/unable-to-launch-scvmm-2012-console/
categories:
  - SCVMM
tags:
  - SCVMM
---
I was planning to continue on my 70-247 exam preparation tonight, but I couldn't launch VMM 2012 console from any computers in my lab. So things didn’t turn out as planned. Lucky I’ve figured out the issue now after 4 hours troubleshooting. It’s just passed midnight, still one hour until my bed time, so I thought I’ll quickly document the issue.

When I tried to launch VMM using an account with Full Administrator rights, the console got stuck on below screen during load and would not go any further:

<a href="https://blog.tyang.org/wp-content/uploads/2013/05/image.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2013/05/image_thumb.png" width="480" height="311" border="0" /></a>

I also found out if I use an account which is a member of a Delegated Admin role that I’ve created called "Cloud Admin", although it also got stuck on this screen, but the console would eventually load after 10-15 minutes.

Long story short, after spent my entire night troubleshooting, I noticed there were few job got stuck on "Running" state by querying the database using below query:

```sql
SELECT * FROM [VirtualManagerDB].[dbo].[tbl_TR_TaskTrail] where TaskState = 'Running'
```

All of these running jobs were trying to run the VMM cmdlet <strong>Get-SCOpsMgrConnection</strong>. It seems each of this job is associated to a console connection attempt. I then tried to manually run this cmdlet from a PowerShell console, it also got stuck.

My OpsMgr management group consists 4 management servers and I’ve created a NLB cluster for the Data Access Service. I have configured OpsMgr integration in VMM using the NLB name a while back and the VMM console was working this morning before I went to work. I checked my OpsMgr servers, they are all healthy and I am able to connect to OpsMgr console using the NLB name from a Windows 8 machine. I’m not sure at this stage what’s causing it.

In order to get VMM consoles fixed as soon as possible, I’ve taken the following steps:

1. Kill all VMM console connections via task manager on all the machines that are trying to connect.

2. Restart System Center Virtual Machine Manager service on the VMM server in order to get rid of these running jobs

3. Use PowerShell cmdlet <strong>Remove-SCOpsMgrConnetion –force</strong> to remove the OpsMgr connection

<a href="https://blog.tyang.org/wp-content/uploads/2013/05/image4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2013/05/image_thumb2.png" width="468" height="202" border="0" /></a>

{:start="4"}
4. Confirm the OpsMgr connection is removed from the database by running below SQL query:

```sql
SELECT * FROM tbl_MOM_OMConnection
```

{:start="5"}
5. I restarted VMM service again just to be safe

Now I can open VMM console from any computers on my network <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" alt="Smile" src="https://blog.tyang.org/wp-content/uploads/2013/05/wlEmoticon-smile.png" />

I’ll try to add OpsMgr connection back in later. It’s bed time now…