---
id: 132
title: ENHANCED SCOM Alerts Notification Emails!
date: 2010-07-19T17:32:00+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=132
permalink: /2010/07/19/enhanced-scom-alerts-notification-emails/
categories:
  - PowerShell
  - SCOM
tags:
  - Email Notifications
  - Featured
  - PowerShell
  - SCOM
---
**<span style="color: #ff0000;">17/08/2012: The version 2 of this script has just been released: </span>**<a href="http://blog.tyang.org/2012/08/16/scom-enhanced-email-notification-script-version-2/">http://blog.tyang.org/2012/08/16/scom-enhanced-email-notification-script-version-2/</a>

<span style="color: #ff0000;">**29/01/2012: The command notification channel setup section of this blog has been updated. More details of the change can be found HERE: <a href="http://blog.tyang.org/2012/01/29/command-line-parameters-for-scom-command-notification-channel/">http://blog.tyang.org/2012/01/29/command-line-parameters-for-scom-command-notification-channel/</a>**</span>

<strong style="color: #ff0000;">Please Note: This post and associated script has been updated on 30/09/2010.**

Even though SCOM is a great product, I personally believe that alert notification emails is something that really needs improvements. It is very hard (and almost impossible – according to my standard) to configure a meaningful notification email using the variables SCOM provides.

Most of times, the SCOM administrator would include a URL that takes you straight to the alert using SCOM web console. Web Console is greatly improved in SCOM 2007 R2, and it pretty much contains everything about the alert (such as alert name, description, source, time raised, monitor/rule name, description, knowledge article, etc).

<a href="http://blog.tyang.org/wp-content/uploads/2010/07/image11.png"><img style="border-width: 0px;" src="http://blog.tyang.org/wp-content/uploads/2010/07/image_thumb11.png" alt="image" width="580" height="302" border="0" /></a>

But why can’t we have all this information in the notification email so we don’t have to come to the web console?

This cannot be done natively using SMTP notification channels. I accomplished it almost 2 years ago for my previous employer, using PowerShell and SCOM Command Notification Channel. I wrote a PowerShell script to utilise System.Net.Mail classes to send out HTML formatted email that contains **EVERYTHING** that you can get from SCOM Operations Console or Web Console.

The following information is included in the notification email:

* - Alert name, description, severity, resolution state, source, path, Time created
* - Monitor / Rule name
* - Knowledge Article for the particular monitor / rule
* - Web console URL link to the alert
* - PowerShell command to retrieve the alert from SCOM command console

I completed forgot about this script until recently one of my customer’s support team asked me if there are any better ways to configure Alert Notification emails in SCOM. Now I’ve decided to post it in my blog so you all can benefit from it.

Below is the email notification for the alert from the above web console screenshot:

<a href="http://blog.tyang.org/wp-content/uploads/2010/09/image13.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2010/09/image_thumb13.png" alt="image" width="556" height="1062" border="0" /></a>

OK. if you want to try this out in your SCOM environment, please keep reading. Let’s go through the steps setting this up in SCOM:

1. Download SCOMEnhancedEmailNotification.ps1

2. Modify this section of the script (line 26-48, Highlighted in <span style="color: #d5d500;">Yellow</span>):

<a href="http://blog.tyang.org/wp-content/uploads/2010/09/image18.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2010/09/image_thumb18.png" alt="image" width="580" height="387" border="0" /></a>

* **$NotifiedResState** – At the end of this script, after the email is sent, it changes the resolution state of the alert to "Notified". I have manually created such resolution state using SCOM Operations Console with number 85. You can use other number if you wish, just make sure this variable represent the right number of the resolution state you want the script to set the alert to at the end.
* **Function getResStateName** - Modify function getResStateName to have ALL the resolution states for your SCOM environment.
* **$strSMTP** – The FQDN of your SMTP server
* **$iPort** – Port used for SMTP. default is 25. if your SMTP server is not use port 25, please change this variable accordingly.
* **$Sender** – make sure you have the sender (return address) and the display name set inside the bracket( )
* **$ErrRecipient** – If the script is running into errors, it will try to email the error message to this recipient. I’d suggest you to set this to your company’s SCOM administrator so they know there is a problem.

3. Once the script is modified, save it to a local folder on your RMS server. In this blog, we will use **D:\Scripts\** as an example.

4. Setting up SCOM Command notification channel:

**<span style="color: #ff0000;">NOTE: Because we are not using SMTP channels, we cannot specify the email addresses in Subscriber’s properties. Instead, we are passing in the email addresses as parameters. So for subscriptions with different subscribers, you will need to create multiple command channels with different email addresses.</span>**

<a href="http://blog.tyang.org/wp-content/uploads/2010/07/image12.png"><img style="border-width: 0px;" src="http://blog.tyang.org/wp-content/uploads/2010/07/image_thumb12.png" alt="image" width="420" height="368" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2010/07/commandnotification.png"><img class="alignleft size-full wp-image-964" title="commandnotification" src="http://blog.tyang.org/wp-content/uploads/2010/07/commandnotification.png" alt="" width="856" height="593" /></a>

Settings:

* **Full path of the command file**: C:\Windows\System32\WindowsPowerShell\v1.0\Powershell.exe
* **Command line parameters:** -Command "& '"D:\Scripts\SCOMEnhancedEmailNotification.ps1"'" -alertID '$Data/Context/DataItem/AlertId$' -Recipients @(<span style="color: #ff0000;">'Tao Yang;Tao.Yang@xxxx.com’,John Smith;John.Smith@xxxx.com‘</span>)
* <em>Note</em>:

* Recipients are passed into the script as an array variable. make sure you use this format inside the (): <span style="color: #ff0000;">‘</span>Recipient 1 Name<span style="color: #ff0000;">;Email’,’</span>Recipient 2 Name<span style="color: #ff0000;">;</span>Email<span style="color: #ff0000;">’</span>
* Alert ID is quoted using single quotation mark ONLY.


* **Startup folder for the command line:** D:\Scripts
* This is the location of the script

5. Setting up subscribers

<a href="http://blog.tyang.org/wp-content/uploads/2010/07/Subscriber1.jpg"><img style="border-width: 0px;" src="http://blog.tyang.org/wp-content/uploads/2010/07/Subscriber1_thumb.jpg" alt="Subscriber1" width="418" height="368" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2010/07/Subscriber2.jpg"><img style="border-width: 0px;" src="http://blog.tyang.org/wp-content/uploads/2010/07/Subscriber2_thumb.jpg" alt="Subscriber2" width="415" height="365" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2010/07/Subscriber3.jpg"><img style="border-width: 0px;" src="http://blog.tyang.org/wp-content/uploads/2010/07/Subscriber3_thumb.jpg" alt="Subscriber3" width="416" height="368" border="0" /></a>

Subscriber address:

<a href="http://blog.tyang.org/wp-content/uploads/2010/07/image13.png"><img style="border-width: 0px;" src="http://blog.tyang.org/wp-content/uploads/2010/07/image_thumb13.png" alt="image" width="418" height="368" border="0" /></a>

6. Setting up subscriptions

<a href="http://blog.tyang.org/wp-content/uploads/2010/07/Subscription3.jpg"><img style="border-width: 0px;" src="http://blog.tyang.org/wp-content/uploads/2010/07/Subscription3_thumb.jpg" alt="Subscription3" width="486" height="303" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2010/07/Subscription4.jpg"><img style="border-width: 0px;" src="http://blog.tyang.org/wp-content/uploads/2010/07/Subscription4_thumb.jpg" alt="Subscription4" width="493" height="283" border="0" /></a>

One last thing to remember: The powerShell execution policy on your RMS needs to set to RemoteSigned or Unrestricted.

This script can be downloaded <a href="http://blog.tyang.org/wp-content/uploads/2010/09/SCOMEnhancedEmailNotification_V1.1.zip">HERE</a>. Feel free to email me if you are having issues setting this up!