---
id: 1816
title: OpsMgr Alerts Push Notification to Android Devices
date: 2013-03-30T23:56:13+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=1816
permalink: /2013/03/30/opsmgr-alerts-push-notification-to-android-devices/
categories:
  - PowerShell
  - SCOM
tags:
  - SCOM
  - SCOM Notifications
---
<span style="color: #ff0000;"><strong>Update 07 April 2013:</strong></span> I've updated this script again to support iOS devices and removed the requirements for PowerShell version 3. The updated script can be found here <a href="http://blog.tyang.org/2013/04/07/opsmgr-alerts-push-notification-to-ios-and-android-and-windows-phone-devices/">here</a>.
<h2>Background</h2>
Stefan Stranger has written a 2-part blog post on how to use Windows Phone push notification for OpsMgr alerts. Stefan’s posts can be found here:

<a href="http://blogs.technet.com/b/stefan_stranger/archive/2013/01/05/windows-phone-push-notifications-for-your-opsmgr-alerts-part-1.aspx">Part 1</a>

<a href="http://blogs.technet.com/b/stefan_stranger/archive/2013/01/07/windows-phone-push-notifications-for-your-opsmgr-alerts-part-2.aspx">Part 2</a>

I got so excited about this idea, but I’m a big fan for Android when comes to mobile devices. I am currently using a Samsung Galaxy Nexus phone and a Samsung Galaxy Tab 2 10.1 tablet – both of them are Android devices. So I’ve spent some time to see if I can do the same for Android devices.

It turned out, there is also an app for Android devices, called "<a href="https://www.notifymyandroid.com/">Notify My Android</a>" <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" alt="Smile" src="http://blog.tyang.org/wp-content/uploads/2013/03/wlEmoticon-smile1.png" />. And the API’s for both apps are the same.
<h2>Setup Instructions</h2>
It’s pretty much the same way to get this setup for Android devices. I’ll now go through the steps to configure push notification for Android devices (and also for Windows Phones):

1. Install <em>"Notify My Android"</em> on Android devices via <a href="https://play.google.com/store/apps/details?id=com.usk.app.notifymyandroid">Google Play</a>

2. Sign up – either from android device or from <a href="https://notifiymyandroid.com">https://notifiymyandroid.com</a>

3. Generate an API key from <a href="https://notifymyandroid.com">https://notifymyandroid.com</a>, under "My Account"

<a href="http://blog.tyang.org/wp-content/uploads/2013/03/image18.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/03/image_thumb17.png" width="580" height="381" border="0" /></a>

<span style="color: #ff0000;"><strong>Note:</strong></span>

<em>Stefan mentioned the "Notify My Windows Phone" app costs $1.99. "Notify My Android" app is actually free from Google Play, HOWEVER, after you’ve signed up, your account is only a trail account. the limitation for the trail accounts is that you only get 5 push notifications per day. Premium account has removed this limit It costs one-off payment of $4.99 to upgrade to premium account. the upgrade payment can either be made via Google Play on your android devices or using PayPal via the website. I upgraded my account via Google Play (as I thought it’s easier than using PayPal).</em>

<em>As I have 2 Android devices, I don’t need to create multiple accounts or generate multiple API keys. Once I’ve logged in on both devices using my premium account, the push notifications get delivered to both devices at the same time.</em>

4. copy <a href="http://blog.tyang.org/wp-content/uploads/2013/03/MobileDevicesPushNotifications.zip">this script</a> to a unique location on all OpsMgr management servers in the Notifications Resource Pool (by default, this resource pool contains all management servers). In my lab, I have copied the script to <em><strong>D:\Scripts\MobileDevices-Notification</strong></em> on all my management servers. Below is what my updated script look like:

```powershell
#Requires -Version 3

Param($os,$apikey,$alertname,$alertsource,$alertseverity,$alertTimeRaised,$alertdescription)

# Enter the name of the application the notification originates from.
$application = "OM2012"

# Enter The event that occured. Depending on your application, this might be a summary, subject or a brief explanation.
$event = "OM2012 Alert"

# The full body of the notification.
$description = @"
AlertName: $alertname
Source: $alertsource
Severity: $alertseverity
TimeRaised: $alertTimeRaised
Description: $alertDescription
"@

#description maximum length is 10000, truncate it if it's over
If ($description.length -gt 10000)
{
$description = $description.substring(0,10000)
}
#You can enable the write-eventlog for logging purposes.
#write-eventlog -LogName Application -source MSIInstaller -EventId 999 -entrytype Information -Message $description

# An optional value representing the priority of the notification.
$priority = "-2"

# Specifies the responsetype you want. You can currently choose between JSON or XML (default)
$type = "json"
$os = $os.tolower()
Switch ($os)
{
"android" {$uri = "http://notifymyandroid.com/publicapi/notify?event=$event&priority=$priority&application=$application&description=$description&apikey=$apikey&type=$type"}
"windows" {$uri = "http://notifymywindowsphone.com/publicapi/notify?event=$event&priority=$priority&application=$application&description=$description&apikey=$apikey&type=$type"}
}

Invoke-WebRequest -Uri $uri
```

I’ve modified Stefan’s script (used in OpsMgr command notification channel) a little bit. Below is a list of what’s changed in my version of the script:
<ul>
	<li>supports both Windows Phone’s "Notify My Windows Phone" app and Android’s "Notify My Android" app.</li>
	<li>Script is more generic as the API key is not hardcoded in the script, instead, it’s passed into the the script as a parameter.</li>
	<li>Push notification messages contain additional alert information – alert source, alert description. – As both app’s API’s supports maximum 10,000 characters in notification description, the script will truncate the message to 10,000 characters if it’s over the limit.</li>
	<li>Additional parameters are required to be passed into the script. – therefore the OpsMgr command channel is different than Stefan’s version.</li>
</ul>
5. Setup command notification channel:

<strong>Full path of the command line:</strong>

C:\WINDOWS\system32\windowspowershell\v1.0\powershell.exe

<strong>Command line parameters:</strong>

D:\Scripts\MobileDevices-Notification\MobileDevicesPushNotifications.ps1 '&lt;mobile device type&gt;' '&lt;API Key&gt;' '$Data/Context/DataItem/AlertName$' '$Data[Default='Not Present']/Context/DataItem/ManagedEntityPath$\$Data[Default='Not Present']/Context/DataItem/ManagedEntityDisplayName$' '$Data/Context/DataItem/Severity$' '$Data/Context/DataItem/TimeRaisedLocal$' '$Data[Default='Not Present']/Context/DataItem/AlertDescription$'

<strong>Startup Folder:</strong>

D:\Scripts\MobileDevices-Notification

<strong><span style="color: #ff0000;">Note:</span></strong>

The script takes the following parameters (in the correct order):

1. <strong>OS</strong>: support either "android" or "windows"

2. <strong>API key</strong>: generated from either Notify My Windows Phone or Notify My Android website

3. <strong>AlertName</strong>

4. <strong>AlertSource</strong>: Addition to Stefan’s script.

5. <strong>AlertSeverity</strong>

6. <strong>AlertTimeRaised</strong>

7. <strong>Alert Description</strong>: Addition to Stefan’s script.

The command line parameter can be populated by using pre-defined OpsMgr variables:

<a href="http://blog.tyang.org/wp-content/uploads/2013/03/image19.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/03/image_thumb18.png" width="580" height="429" border="0" /></a>

6. Follow <a href="http://blogs.technet.com/b/stefan_stranger/archive/2013/01/07/windows-phone-push-notifications-for-your-opsmgr-alerts-part-2.aspx">Part 2</a> of Stefan’s original post to setup Subscriber and Subscriptions.

I cannot test my version of the script against Windows phones because I don’t have one. But I’m fairly confident it should work. From what I can see, the API’s for both apps are exactly the same. Well, the only difference is the URL’s for API calls:

<a href="http://blog.tyang.org/wp-content/uploads/2013/03/image20.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/03/image_thumb19.png" width="580" height="83" border="0" /></a>

I think in real world, this is a very cost effective solution for alerts notification to mobile devices. According to the API documentations, multiple API keys can be used in a single API call. When using multiple API keys, the API keys needs to be separated by comma. Again, I have not tested this scenario against my script because I don’t really want to spend another $4.99 for another premium account.

If it’s required to setup push notification to multiple people (different mobile devices types, different notify app accounts and different Microsoft / Google accounts, thus different API keys), separate command notification channels need to be created (one per API key or group of API keys).

Below are what I get on my Android devices:

On the phone:

<a href="http://blog.tyang.org/wp-content/uploads/2013/03/Screenshot_2013-03-31-00-33-07.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="Screenshot_2013-03-31-00-33-07" alt="Screenshot_2013-03-31-00-33-07" src="http://blog.tyang.org/wp-content/uploads/2013/03/Screenshot_2013-03-31-00-33-07_thumb.png" width="413" height="731" border="0" /></a>

On the tablet:

<a href="http://blog.tyang.org/wp-content/uploads/2013/03/Screenshot_2013-03-31-00-37-03.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="Screenshot_2013-03-31-00-37-03" alt="Screenshot_2013-03-31-00-37-03" src="http://blog.tyang.org/wp-content/uploads/2013/03/Screenshot_2013-03-31-00-37-03_thumb.png" width="580" height="364" border="0" /></a>
<h2>Limitations</h2>
According the the FAQ pages on both websites, there are some limitations that are worth mentioning:

<strong>Notify My Windows Phone:</strong>

Are there any limitations to the amount of messages I can send?

Yes - The Microsoft Push Notification Service throttles notifications at 500 per 24 hours per device. The messages will however be stored temporarily at NotifyMyWindowsPhone, so they can be retrieved manually by hitting refresh from within the Windows Phone App.

<strong>Notify My Android:</strong>

Is there a rate limit for using the public API?

Yes. Right now the limit is set to 800 API calls per hour from a given IP. Remember that you can notify multiple API keys on a single API call. Please check the <a href="https://www.notifymyandroid.com/api.jsp">API documentation</a> for more details. Very few applications managed to reach that limit so far, but if you hit the cap too often, feel free to <a href="mailto:support@notifymyandroid.com">contact us</a> and ask for a developer key.

In my opinion, if you get over 500 messages a day on your Windows phone or 800 in one hour on android devices, there are something seriously wrong with your infrastructure <img class="wlEmoticon wlEmoticon-sadsmile" style="border-style: none;" alt="Sad smile" src="http://blog.tyang.org/wp-content/uploads/2013/03/wlEmoticon-sadsmile.png" /> or you might want to re-configure alert subscriptions to only notify really critical alerts.
<h2>Credit</h2>
Big thanks to Stefan for providing such an wonderful solution in the first place. <img class="wlEmoticon wlEmoticon-thumbsup" style="border-style: none;" alt="Thumbs up" src="http://blog.tyang.org/wp-content/uploads/2013/03/wlEmoticon-thumbsup.png" />