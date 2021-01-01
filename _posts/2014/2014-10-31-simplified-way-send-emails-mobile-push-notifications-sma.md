---
id: 3293
title: A Simplified Way to Send Emails and Mobile Push Notifications in SMA
date: 2014-10-31T22:38:03+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=3293
permalink: /2014/10/31/simplified-way-send-emails-mobile-push-notifications-sma/
categories:
  - PowerShell
  - SMA
tags:
  - PowerShell
  - SMA
---
<h3>Background</h3>
For those who knows me, I’m an OpsMgr guy. I spend a lot of time in OpsMgr and I am very used to the way OpsMgr sends notifications (using notification channels and subscribers).

In OpsMgr, I like the idea of saving the SMTP configuration and notification recipients’ contact details into the system so everyone who has got enough privilege can use these configurations (when configuring alert subscriptions).

Over the last few months, I have spent a lot of time on SMA (Service Management Automation). As I started building more and more runbooks and integration modules, I really miss the simple way of sending notifications in OpsMgr. Although there is a built-in PowerShell cmdlet for sending emails (Send-MailMessage), it requires a lot of input parameters, and the runbook author needs to have all the SMTP information available. I thought it would be nice if I could save SMTP settings as connection objects (similar to notification channels in OpsMgr), and recipients’ contact details (email and mobile device push notification services’ api keys) also as connection objects (similar to subscribers in OpsMgr).

To achieve my goals, I have created 2 SMA Integration modules:
<table style="color: #000000;" border="0" width="400" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td valign="top" width="102"><strong>Module Name</strong></td>
<td valign="top" width="124"><strong>Connection Type Name</strong></td>
<td valign="top" width="173"><strong>PowerShell Functions</strong></td>
</tr>
<tr>
<td valign="top" width="102">SendEmail</td>
<td valign="top" width="124">SMTPServerConnection</td>
<td valign="top" width="173">Send-Email</td>
</tr>
<tr>
<td valign="top" width="102">SendPushNotification</td>
<td valign="top" width="124">SMAAddressBook</td>
<td valign="top" width="173">Send-MobilePushNotification</td>
</tr>
</tbody>
</table>
<h3>SendEmail Module</h3>
This module defines a connection type where can be used to save all SMTP related information:
<ul>
	<li>SMTP Server address</li>
	<li>Port</li>
	<li>Authentication Method (Anonymous, Integrate or Credential)</li>
	<li>User name</li>
	<li>Password</li>
	<li>Sender Name</li>
	<li>Sender Address</li>
	<li>UseSSL (Boolean)</li>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2014/10/SNAGHTML1ba0bfc7.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML1ba0bfc7" src="http://blog.tyang.org/wp-content/uploads/2014/10/SNAGHTML1ba0bfc7_thumb.png" alt="SNAGHTML1ba0bfc7" width="476" height="305" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2014/10/image12.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/10/image_thumb12.png" alt="image" width="476" height="303" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2014/10/SNAGHTML1ba1992f.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML1ba1992f" src="http://blog.tyang.org/wp-content/uploads/2014/10/SNAGHTML1ba1992f_thumb.png" alt="SNAGHTML1ba1992f" width="475" height="301" border="0" /></a>

This module also provides a PowerShell function called "Send-Email". Since when retrieving an automation connection in SMA, a hash table is returned, Not only you can pass individual SMTP parameters into the Send-Email function, you can also simply pass the SMA connection object that you have retrieved using "Get-AutomationConnection" cmdlet. for more information, please refer to the help topic of this function, and the sample runbook below.
<h3>SendPushNotification Module</h3>
This module provides a connection type called SMAAddressBook. It can be used like an address book to store recipient’s contact details:
<ul>
	<li>Display Name</li>
	<li>Email Address (optional)</li>
	<li>NotifiyMyAndroid API Key (optional, encrypted)</li>
	<li>Prawl (iOS push notification) API Key (optional, encrypted)</li>
	<li>NotifyMyWndowsPhone API Key (optional, encrypted)</li>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2014/10/image13.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/10/image_thumb13.png" alt="image" width="516" height="328" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2014/10/SNAGHTML1bb2b9d4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML1bb2b9d4" src="http://blog.tyang.org/wp-content/uploads/2014/10/SNAGHTML1bb2b9d4_thumb.png" alt="SNAGHTML1bb2b9d4" width="517" height="329" border="0" /></a>

This module also provides a PowerShell function called Send-MobilePushNotification. It can be used to send push notification to either Prawl, NotifyMyAndroid or NotifyMyWindowsPhone.
<h3>Sample Runbook</h3>
<pre language="PowerShell">workflow Test-Notification {
	#Get the contact details
	$ContactName = 'tyang'
	Write-Verbose "Getting SMA Address Book entry for $ContactName"
	$Contact = Get-AutomationConnection -Name $ContactName
	
	#Get SMTP settings
	Write-Verbose "Getting SMTP configuration"
	$SMTPSettings = Get-AutomationConnection -Name GmailSMTP
	
	$Subject = "Test message from SMA"
	$Message = "Hello, this is a test message from your SMA server."
	
	#Send email
	Write-Verbose 'Sending email'
	Send-Email -SMTPSettings $SMTPSettings -To $Contact.Email -Subject $Subject -Body $Message -HTMLBody $false
	
	#Android Push Notification
	Write-Verbose 'Sending Android push notification'
	Send-MobilePushNotification -os "Android" -apikey $Contact.AndroidAPI -Subject $Subject -Application 'SMA' -Body $Message
}
</pre>
As you can see from this sample, the runbook author does not need to know the SMTP server information (including login credentials), nor the contact details of the recipient. The runbook can simply pass the SMTP connection object (PowerShell Hash Table) into the Send-Email function.

After I executed this runbook, I received the notification via both Email and Android push notification:

<a href="http://blog.tyang.org/wp-content/uploads/2014/10/SNAGHTML1bb9521f.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML1bb9521f" src="http://blog.tyang.org/wp-content/uploads/2014/10/SNAGHTML1bb9521f_thumb.png" alt="SNAGHTML1bb9521f" width="583" height="216" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2014/10/image14.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/10/image_thumb14.png" alt="image" width="529" height="262" border="0" /></a>
<h3>Download</h3>
Please download from the download link below. Once downloaded, please import the zip files below into SMA:

<a href="http://blog.tyang.org/wp-content/uploads/2014/10/image15.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/10/image_thumb15.png" alt="image" width="559" height="138" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2014/12/SMANotificationModules.zip">Download Link</a>
<h3>Related Posts</h3>
<a href="http://blog.tyang.org/2013/04/07/opsmgr-alerts-push-notification-to-ios-and-android-and-windows-phone-devices/">OpsMgr Alerts Push Notification to iOS (And Android, And Windows Phone) Devices</a>

<a href="http://blogs.technet.com/b/orchestrator/archive/2014/06/12/authoring-integration-modules-for-sma.aspx">Authoring Integration Modules for SMA</a>
<h3>Conclusion</h3>
As shown in the sample above, once the SMTP details are saved in SMTP connection objects, and recipients’ contact details are saved as SMAAddressBook connections, it is really simple to utilise the functions provided by these 2 modules to send notifications.

Also, I’d like to point out I had to create 2 integration modules instead of 1 because I need to create 2 kinds of connections. Having said that, these 2 modules do not depend on each other and can be used separately too.

As many people referring to SMA modules and runbooks as Lego pieces, I will definitely to share more and more my Lego pieces as they’ve been developed. In the meantime, please feel free to contact me if you have questions or suggestions.