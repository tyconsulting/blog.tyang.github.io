---
id: 1309
title: 'SCOM Alert Notification&ndash;Using Skype'
date: 2012-08-07T20:17:49+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=1309
permalink: /2012/08/07/scom-alert-notificationusing-skype/
categories:
  - PowerShell
  - SCOM
tags:
  - Featured
  - PowerShell
  - SCOM
  - Skype
---
<a href="http://blog.tyang.org/wp-content/uploads/2012/08/logo1.png"><img class="alignleft size-medium wp-image-1311" title="logo1" src="http://blog.tyang.org/wp-content/uploads/2012/08/logo1-300x86.png" alt="" width="300" height="86" /></a>Recently I’ve been wanting to setup SCOM notifications in my test environment that can reach me even when I’m not home.. However, I had two problem: I don’t have Lync / OCS servers in my lab and my home test lab does not have a registered domain name and so the Exchange server in the lab cannot email outside.

Since I have <a title="Skype" href="http://www.skype.com">Skype</a> installed on my PCs, phones and tablets, I thought it would be nice if SCOM can send me a message when a SCOM alert is raised.

It turned out to be relatively easy, with the help from the Skype API <a title="Skype4COM" href="http://developer.skype.com/accessories/skype4com">Skype4COM</a>, <a title="PsExec.exe" href="http://technet.microsoft.com/en-us/sysinternals/bb897553.aspx">PsExec.exe</a> and some PowerShell scripting, it only took me few hours to achieve this goal.

In a nutshell, I installed SCOM Command Console and Skype on a computer (I’ve tried both 64-bit Windows 7 and Windows Server 2008 R2). I’ll call this computer "Skype Node" in this post. I have also copied and registered the Skype4COM.dll on the Skype Node. I also wrote a PowerShell script that runs on the Skype Node computer to retrieve alert details and send out Skype messages. I then setup SCOM command notification to execute another script on the SCOM 2007 RMS / SCOM 2012 MS, this script will use PsExec.exe to remotely execute the script on Skype Node.

I managed to get this working on both SCOM 2007 R2 and SCOM 2012. The scripts and requirements are very similar, but SCOM 2007 R2 environments requires few additional configurations.

<a href="http://blog.tyang.org/wp-content/uploads/2012/08/SCOM2007-Diagram.jpg"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="SCOM2007 Diagram" src="http://blog.tyang.org/wp-content/uploads/2012/08/SCOM2007-Diagram_thumb.jpg" alt="SCOM2007 Diagram" width="580" height="290" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2012/08/SCOM2012-Diagram.jpg"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="SCOM2012 Diagram" src="http://blog.tyang.org/wp-content/uploads/2012/08/SCOM2012-Diagram_thumb.jpg" alt="SCOM2012 Diagram" width="580" height="311" border="0" /></a>

I won’t bother to go through the details on how to set this up for either SCOM 2007 R2 or SCOM 2012. the detailed guide can be downloaded from the link at the bottom of this post.

Now, I receive Skype messages on both my computer and my mobile phone:

<strong><span style="font-size: medium;">PC:</span></strong>

<a href="http://blog.tyang.org/wp-content/uploads/2012/08/PC-Screenshot.jpg"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="PC Screenshot" src="http://blog.tyang.org/wp-content/uploads/2012/08/PC-Screenshot_thumb.jpg" alt="PC Screenshot" width="580" height="165" border="0" /></a>

<strong><span style="font-size: medium;">Phone:</span></strong>

<a href="http://blog.tyang.org/wp-content/uploads/2012/08/iPhone-ScreenShot.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="iPhone ScreenShot" src="http://blog.tyang.org/wp-content/uploads/2012/08/iPhone-ScreenShot_thumb.png" alt="iPhone ScreenShot" width="370" height="553" border="0" /></a>

You can download everything you need (except Skype and SCOM itself of course) from below link. Once you’ve unzip the file, you will get:

<a href="http://blog.tyang.org/wp-content/uploads/2012/08/image.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/08/image_thumb.png" alt="image" width="442" height="208" border="0" /></a>

<strong>Skype Notification Guide.pdf</strong> is the guide that you need to follow to set this up.

<strong>Skype4COM-1.0.38.0</strong> is the version of Skype4COM I’ve used in this solution. it is the most recent version as of writing of this post.

<a title="Download Skype-Notification.zip" href="http://blog.tyang.org/wp-content/uploads/2012/08/Skype-Notification.zip">Download Link</a>

As always, feel free to contact me if you have questions or need help. However, I’ll try my best but I may not be able to get back to you straightaway.

Have fun Skyping :smiley:. Bye for now!