---
id: 4670
title: Using Exchange Online (Office 365) For OpsMgr Email Notification
date: 2015-09-26T14:02:23+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=4670
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

1. In one of my Office 365 subscriptions (Enterprise E3), I create a user and assigned a license to it:

![](https://blog.tyang.org/wp-content/uploads/2015/09/SNAGHTMLf7da6aa.png)

This user ID will be used to authenticate to Office 365 and email notifications will be send via this account.

{:start="2"}
2. Get the SMTP setting for your Office 365 subscription:

  ![](https://blog.tyang.org/wp-content/uploads/2015/09/image31.png)

{:start="3"}
3. Add the "SMTP Server" feature on one of my Windows Server 2012 R2 VMs:

  ![](https://blog.tyang.org/wp-content/uploads/2015/09/image32.png)

{:start="4"}
4. Open IIS 6.0 manager and you can see the SMTP Virtual Server:

  ![](https://blog.tyang.org/wp-content/uploads/2015/09/image33.png)

{:start="5"}
5. Configure SMTP Relay:

  Outbound Security:

  ![](https://blog.tyang.org/wp-content/uploads/2015/09/SNAGHTMLfad281a.png)

  Outbound Connections:

  ![](https://blog.tyang.org/wp-content/uploads/2015/09/image34.png)

  Advanced:

  ![](https://blog.tyang.org/wp-content/uploads/2015/09/image35.png)

{:start="6"}
6. Created a DNS alias smtp.\<domain name\> and pointed to the server where I installed SMTP server.

{:start="7"}
7. Setup SMTP notification channel in OpsMgr:

  ![](https://blog.tyang.org/wp-content/uploads/2015/09/SNAGHTMLfb0e4f3.png)

that’s it, it should take no longer than 10 minutes. Although I haven’t tried with other email provider, theoretically, it should also work of Gmail, Outlook.com, etc. as long as you have a valid account and the correct SMTP settings.