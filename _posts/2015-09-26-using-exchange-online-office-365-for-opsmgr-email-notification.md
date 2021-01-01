---
id: 4670
title: Using Exchange Online (Office 365) For OpsMgr Email Notification
date: 2015-09-26T14:02:23+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=4670
permalink: /2015/09/26/using-exchange-online-office-365-for-opsmgr-email-notification/
categories:
  - SCOM
tags:
  - SCOM
---
I haven’t been able to use OpsMgr email notifications in my lab since the beginning, because I do not have an on-prem Exchange server (nor that I want to). I have been using my enhanced email notification script and mobile device push notification scripts in the past.

Few weeks ago, I needed to setup a GSM monitor for a website and send notification to few other MVP friends via Email. Cameron pointed me to an old blog post from Marnix on setting up SMTP relay for OpsMgr notifications: <a title="http://thoughtsonopsmgr.blogspot.com.au/2009/09/how-to-configure-smtp-for-opsmgr-in.html" href="http://thoughtsonopsmgr.blogspot.com.au/2009/09/how-to-configure-smtp-for-opsmgr-in.html">http://thoughtsonopsmgr.blogspot.com.au/2009/09/how-to-configure-smtp-for-opsmgr-in.html</a>

I also managed to find another post by a fellow MVP Anton Gritsenko on setting up SCSM notification using Exchange Online (Office 365) via SMTP relay: <a title="http://blog.scsmsolutions.com/2012/02/setup-notification-from-scsm-to-exchange-online-office365-mailboxes/" href="http://blog.scsmsolutions.com/2012/02/setup-notification-from-scsm-to-exchange-online-office365-mailboxes/">http://blog.scsmsolutions.com/2012/02/setup-notification-from-scsm-to-exchange-online-office365-mailboxes/</a>

with the help of these 2 posts, I managed to quickly configure email notifications in my OpsMgr management group using Office 365.

As more and more organisations have moved from having On-Prem Exchange environments to using Office 365, I thought this setup could be useful for the community when someone need to use email notification in an environment without Exchange servers.

Since Marnix and Anton has already blogged this solution, I’ll only briefly go through what I’ve done in my lab:

01. In one of my Office 365 subscriptions (Enterprise E3), I create a user and assigned a license to it:

<a href="http://blog.tyang.org/wp-content/uploads/2015/09/SNAGHTMLf7da6aa.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLf7da6aa" src="http://blog.tyang.org/wp-content/uploads/2015/09/SNAGHTMLf7da6aa_thumb.png" alt="SNAGHTMLf7da6aa" width="225" height="357" border="0" /></a>

This user ID will be used to authenticate to Office 365 and email notifications will be send via this account.

02. Get the SMTP setting for your Office 365 subscription:

<a href="http://blog.tyang.org/wp-content/uploads/2015/09/image31.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/09/image_thumb31.png" alt="image" width="370" height="340" border="0" /></a>

03. Add the “SMTP Server” feature on one of my Windows Server 2012 R2 VMs:

<a href="http://blog.tyang.org/wp-content/uploads/2015/09/image32.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/09/image_thumb32.png" alt="image" width="394" height="280" border="0" /></a>

04. Open IIS 6.0 manager and you can see the SMTP Virtual Server:

<a href="http://blog.tyang.org/wp-content/uploads/2015/09/image33.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/09/image_thumb33.png" alt="image" width="398" height="283" border="0" /></a>

05. Configure SMTP Relay:

Outbound Security:

<a href="http://blog.tyang.org/wp-content/uploads/2015/09/SNAGHTMLfad281a.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLfad281a" src="http://blog.tyang.org/wp-content/uploads/2015/09/SNAGHTMLfad281a_thumb.png" alt="SNAGHTMLfad281a" width="305" height="311" border="0" /></a>

Outbound Connections:

<a href="http://blog.tyang.org/wp-content/uploads/2015/09/image34.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/09/image_thumb34.png" alt="image" width="278" height="156" border="0" /></a>

Advanced:

<a href="http://blog.tyang.org/wp-content/uploads/2015/09/image35.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/09/image_thumb35.png" alt="image" width="293" height="285" border="0" /></a>

06. Created a DNS alias smtp.&lt;domain name&gt; and pointed to the server where I installed SMTP server.

07. Setup SMTP notification channel in OpsMgr:

<a href="http://blog.tyang.org/wp-content/uploads/2015/09/SNAGHTMLfb0e4f3.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLfb0e4f3" src="http://blog.tyang.org/wp-content/uploads/2015/09/SNAGHTMLfb0e4f3_thumb.png" alt="SNAGHTMLfb0e4f3" width="475" height="411" border="0" /></a>

that’s it, it should take no longer than 10 minutes. Although I haven’t tried with other email provider, theoretically, it should also work of Gmail, Outlook.com, etc. as long as you have a valid account and the correct SMTP settings.