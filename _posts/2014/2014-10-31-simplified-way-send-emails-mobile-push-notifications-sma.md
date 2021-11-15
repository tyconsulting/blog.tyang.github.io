---
id: 3293
title: A Simplified Way to Send Emails and Mobile Push Notifications in SMA
date: 2014-10-31T22:38:03+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=3293
permalink: /2014/10/31/simplified-way-send-emails-mobile-push-notifications-sma/
categories:
  - PowerShell
  - SMA
tags:
  - PowerShell
  - SMA
---

## Background

For those who knows me, I’m an OpsMgr guy. I spend a lot of time in OpsMgr and I am very used to the way OpsMgr sends notifications (using notification channels and subscribers).

In OpsMgr, I like the idea of saving the SMTP configuration and notification recipients’ contact details into the system so everyone who has got enough privilege can use these configurations (when configuring alert subscriptions).

Over the last few months, I have spent a lot of time on SMA (Service Management Automation). As I started building more and more runbooks and integration modules, I really miss the simple way of sending notifications in OpsMgr. Although there is a built-in PowerShell cmdlet for sending emails (Send-MailMessage), it requires a lot of input parameters, and the runbook author needs to have all the SMTP information available. I thought it would be nice if I could save SMTP settings as connection objects (similar to notification channels in OpsMgr), and recipients’ contact details (email and mobile device push notification services’ api keys) also as connection objects (similar to subscribers in OpsMgr).

To achieve my goals, I have created 2 SMA Integration modules:

| Module Name          | Connection Type Name | PowerShell Functions        |
| -------------------- | -------------------- | --------------------------- |
| SendEmail            | SMTPServerConnection | Send-Email                  |
| SendPushNotification | SMAAddressBook       | Send-MobilePushNotification |

## SendEmail Module

This module defines a connection type where can be used to save all SMTP related information:

* SMTP Server address
* Port
* Authentication Method (Anonymous, Integrate or Credential)
* User name
* Password
* Sender Name
* Sender Address
* UseSSL (Boolean)

![](https://blog.tyang.org/wp-content/uploads/2014/10/SNAGHTML1ba0bfc7.png)

![](https://blog.tyang.org/wp-content/uploads/2014/10/image12.png)

![](https://blog.tyang.org/wp-content/uploads/2014/10/SNAGHTML1ba1992f.png)

This module also provides a PowerShell function called "Send-Email". Since when retrieving an automation connection in SMA, a hash table is returned, Not only you can pass individual SMTP parameters into the Send-Email function, you can also simply pass the SMA connection object that you have retrieved using "Get-AutomationConnection" cmdlet. for more information, please refer to the help topic of this function, and the sample runbook below.

## SendPushNotification Module

This module provides a connection type called SMAAddressBook. It can be used like an address book to store recipient’s contact details:

* Display Name
* Email Address (optional)
* NotifiyMyAndroid API Key (optional, encrypted)
* Prawl (iOS push notification) API Key (optional, encrypted)
* NotifyMyWndowsPhone API Key (optional, encrypted)

![](https://blog.tyang.org/wp-content/uploads/2014/10/image13.png)

![](https://blog.tyang.org/wp-content/uploads/2014/10/SNAGHTML1bb2b9d4.png)

This module also provides a PowerShell function called Send-MobilePushNotification. It can be used to send push notification to either Prawl, NotifyMyAndroid or NotifyMyWindowsPhone.

## Sample Runbook

```powershell
workflow Test-Notification {
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
```
As you can see from this sample, the runbook author does not need to know the SMTP server information (including login credentials), nor the contact details of the recipient. The runbook can simply pass the SMTP connection object (PowerShell Hash Table) into the Send-Email function.

After I executed this runbook, I received the notification via both Email and Android push notification:

![](https://blog.tyang.org/wp-content/uploads/2014/10/SNAGHTML1bb9521f.png)

![](https://blog.tyang.org/wp-content/uploads/2014/10/image14.png)

## Download

Please download from the download link below. Once downloaded, please import the zip files below into SMA:

![](https://blog.tyang.org/wp-content/uploads/2014/10/image15.png)

[Download Link](https://blog.tyang.org/wp-content/uploads/2014/12/SMANotificationModules.zip)

## Related Posts

[OpsMgr Alerts Push Notification to iOS (And Android, And Windows Phone) Devices](https://blog.tyang.org/2013/04/07/opsmgr-alerts-push-notification-to-ios-and-android-and-windows-phone-devices/)

[Authoring Integration Modules for SMA](http://blogs.technet.com/b/orchestrator/archive/2014/06/12/authoring-integration-modules-for-sma.aspx)

## Conclusion

As shown in the sample above, once the SMTP details are saved in SMTP connection objects, and recipients’ contact details are saved as SMAAddressBook connections, it is really simple to utilise the functions provided by these 2 modules to send notifications.

Also, I’d like to point out I had to create 2 integration modules instead of 1 because I need to create 2 kinds of connections. Having said that, these 2 modules do not depend on each other and can be used separately too.

As many people referring to SMA modules and runbooks as Lego pieces, I will definitely to share more and more my Lego pieces as they’ve been developed. In the meantime, please feel free to contact me if you have questions or suggestions.