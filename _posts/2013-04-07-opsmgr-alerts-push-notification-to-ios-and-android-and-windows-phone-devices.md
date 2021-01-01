---
id: 1869
title: OpsMgr Alerts Push Notification to iOS (And Android, And Windows Phone) Devices
date: 2013-04-07T00:11:26+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=1869
permalink: /2013/04/07/opsmgr-alerts-push-notification-to-ios-and-android-and-windows-phone-devices/
categories:
  - SCOM
tags:
  - SCOM
  - SCOM Notifications
---
Last week, I’ve posted a solution for <a href="http://blog.tyang.org/2013/03/30/opsmgr-alerts-push-notification-to-android-devices/">OpsMgr alerts push notification to Android devices</a>, which was inspired by Stefan Stranger’s post for push notification for Windows Phone devices. Few iPhone lovers at work asked me, “what about iphones?” My response was, “Do I really care?? Why would I spend my time polishing a turd?”

But then I thought, I might as well do it, just to close the circle. Al though I hate any Apple products (except the old 160GB iPod Classic, which I still use), I’ve spent some time to work out how to do the same for iOS devices - Because iOS is still the most popular mobile devices out there…

An iPhone user at work told me he uses an iOS app called <a href="http://www.prowlapp.com/">Prowl</a> for his NZB or Sick Beard notifications (I wasn’t really sure exactly, don’t really spend too much time watching TV)…

So I’ve modified the PowerShell script to utilize Prowl API as well.

Luckily my partner has a spare first generation iPad doing nothing because she’s now using an iPad 3, I’m able to use this old iPad for testing.

I’ll now go through the steps to setup Prowl first, the command notification channel is pretty much the same with my previous post (I’ll go through what’s changed).

1. Firstly, buy and download Prowl from Apple App Store for $2.99: <a href="https://itunes.apple.com/us/app/prowl-growl-client/id320876271?mt=8&amp;ign-mpt=uo%3D4">https://itunes.apple.com/us/app/prowl-growl-client/id320876271?mt=8&amp;ign-mpt=uo%3D4</a>

<a href="http://blog.tyang.org/wp-content/uploads/2013/04/IMG_0004.jpg"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="IMG_0004" alt="IMG_0004" src="http://blog.tyang.org/wp-content/uploads/2013/04/IMG_0004_thumb.jpg" width="391" height="294" border="0" /></a>

2. Go to Prowl’s website and register an account: <a title="https://www.prowlapp.com/register.php" href="https://www.prowlapp.com/register.php">https://www.prowlapp.com/register.php</a>

3. Logon with the account and generate an API Key:

<a href="http://blog.tyang.org/wp-content/uploads/2013/04/image16.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/04/image_thumb15.png" width="456" height="368" border="0" /></a>

4. Logon to Prowl on your iOS device.

Now the the iOS device is configured.

Below is the updated PowerShell script used for command notification channel:

[sourcecode language="Powershell"]
Param($os,$apikey,$alertname,$alertsource,$alertseverity,$alertTimeRaised,$alertdescription)

# Enter the name of the application the notification originates from.
$application = &quot;OM2012&quot;

# Enter The event that occured. Depending on your application, this might be a summary, subject or a brief explanation.
$event = &quot;OM2012 Alert&quot;

Switch ($alertseverity)
{
&quot;2&quot; {$strSeverity = &quot;Critical&quot;}
&quot;1&quot; {$strSeverity = &quot;Warning&quot;}
&quot;0&quot; {$strSeverity = &quot;Information&quot;}
}

# The full body of the notification.
$description = @&quot;
AlertName: $alertname
Source: $alertsource
Severity: $strSeverity
TimeRaised: $alertTimeRaised
Description: $alertDescription
&quot;@

#description maximum length is 10000, truncate it if it's over
If ($description.length -gt 10000)
{
$description = $description.substring(0,10000)
}
#You can enable the write-eventlog for logging purposes.
#write-eventlog -LogName Application -source MSIInstaller -EventId 999 -entrytype Information -Message $description

# An optional value representing the priority of the notification.
$priority = &quot;-2&quot;

# Specifies the responsetype you want. You can currently choose between JSON or XML (default)
$type = &quot;json&quot;
$os = $os.tolower()
Switch ($os)
{
    &quot;android&quot; {$uri = &quot;http://notifymyandroid.com/publicapi/notify?event=$event&amp;priority=$priority&amp;application=$application&amp;description=$description&amp;apikey=$apikey&amp;type=$type&quot;}
    &quot;windows&quot; {$uri = &quot;http://notifymywindowsphone.com/publicapi/notify?event=$event&amp;priority=$priority&amp;application=$application&amp;description=$description&amp;apikey=$apikey&amp;type=$type&quot;}
    &quot;ios&quot; {$uri = &quot;http://api.prowlapp.com/publicapi/add?event=$event&amp;priority=$priority&amp;application=$application&amp;description=$description&amp;apikey=$apikey&amp;type=$type&quot;}
}

#Invoke-WebRequest -Uri $uri
$response = [System.Net.WebRequest]::Create($uri)
$response.GetResponse()
[/sourcecode]

The script can also be downloaded <a href="http://blog.tyang.org/wp-content/uploads/2013/04/MobileDevicesPushNotifications.zip">here</a>.

I have made the following changes to the script:

1. Windows PowerShell version 3 is no longer a requirement.

As we all know, Microsoft has removed Windows Management Framework 3.0 update for operating systems earlier than Windows 8 &amp; Server 2012 from WSUS couple of months ago because it breaks many applications including SCCM, SharePoint, etc.. More Info can be found <a href="http://myitforum.com/myitforumwp/2012/12/19/troublesome-wmf-3-0-update-now-expired-for-all-platforms/">here</a>. I saw someone posted a question in System Center Central’s forum wanting to install WMF 3.0 on OpsMgr management servers just to run this script. So I replaced the PowerShell 3.0 cmdlet <strong>Invoke-WebRequest</strong> (which was inherited from Stefan’s original script) with a .NET method in <strong>System.Net.WebRequest</strong>.

2. The original script was displaying alert severity as number (0 = information, 1 = warning, 2 = critical), I’ve updated it to display the actual severity in English rather than number.

3. the $os parameter supports additional value of “ios”.

The command notification setup is exactly the same as the previous version (except OS parameter now supports “ios”):

In my lab, the script is located on <em><strong>D:\Scripts\MobileDevices-Notification</strong></em> on all my management servers, so the setup looks like:

<strong>Full path of the command line:</strong>

C:\WINDOWS\system32\windowspowershell\v1.0\powershell.exe

<strong>Command line parameters:</strong>

<span style="font-family: Arial; font-size: large;">D:\Scripts\MobileDevices-Notification\MobileDevicesPushNotifications.ps1 ‘&lt;mobile device type&gt;’ ‘&lt;API Key&gt;’ ‘$Data/Context/DataItem/AlertName$’ ‘$Data[Default='Not Present']/Context/DataItem/ManagedEntityPath$\$Data[Default='Not Present']/Context/DataItem/ManagedEntityDisplayName$’ ‘$Data/Context/DataItem/Severity$’ ‘$Data/Context/DataItem/TimeRaisedLocal$’ ‘$Data[Default='Not Present']/Context/DataItem/AlertDescription$’</span>

<strong>Startup Folder:</strong>

D:\Scripts\MobileDevices-Notification

<strong><span style="color: #ff0000;">Note:</span></strong>

The script takes the following parameters (in the correct order):

1. <strong>OS</strong>: support either <span style="color: #ff0000; font-size: large;">“ios”,</span> “android” or “windows”

2. <strong>API key</strong>: generated from either Notify My Windows Phone or Notify My Android website

3. <strong>AlertName</strong>

4. <strong>AlertSource</strong>: Addition to Stefan’s script.

5. <strong>AlertSeverity</strong>

6. <strong>AlertTimeRaised</strong>

7. <strong>Alert Description</strong>: Addition to Stefan’s script.

<strong>Command line samples</strong> (assuming the API key is 1111111111111111):

<strong>For iOS devices:</strong>

<span style="font-family: Arial; font-size: large;"><span style="font-size: medium;">D:\Scripts\MobileDevices-Notification\MobileDevicesPushNotifications.ps1 ‘<span style="color: #ff0000;"><strong>ios</strong></span>’ ‘1111111111111111’ ‘$Data/Context/DataItem/AlertName$’ ‘$Data[Default='Not Present']/Context/DataItem/ManagedEntityPath$\$Data[Default='Not Present']/Context/DataItem/ManagedEntityDisplayName$’ ‘$Data/Context/DataItem/Severity$’ ‘$Data/Context/DataItem/TimeRaisedLocal$’ ‘$Data[Default='Not Present']/Context/DataItem/AlertDescription$</span>’</span>

<strong>For Android devices:</strong>

<span style="font-family: Arial; font-size: large;"><span style="font-size: medium;">D:\Scripts\MobileDevices-Notification\MobileDevicesPushNotifications.ps1 ‘<strong><span style="color: #ff0000;">android</span></strong>’ ‘1111111111111111’ ‘$Data/Context/DataItem/AlertName$’ ‘$Data[Default='Not Present']/Context/DataItem/ManagedEntityPath$\$Data[Default='Not Present']/Context/DataItem/ManagedEntityDisplayName$’ ‘$Data/Context/DataItem/Severity$’ ‘$Data/Context/DataItem/TimeRaisedLocal$’ ‘$Data[Default='Not Present']/Context/DataItem/AlertDescription$</span>’</span>

<strong>For Windows phone devices:</strong>

<span style="font-family: Arial; font-size: large;"><span style="font-size: medium;">D:\Scripts\MobileDevices-Notification\MobileDevicesPushNotifications.ps1 ‘<strong><span style="color: #ff0000;">windows</span></strong>’ ‘1111111111111111’ ‘$Data/Context/DataItem/AlertName$’ ‘$Data[Default='Not Present']/Context/DataItem/ManagedEntityPath$\$Data[Default='Not Present']/Context/DataItem/ManagedEntityDisplayName$’ ‘$Data/Context/DataItem/Severity$’ ‘$Data/Context/DataItem/TimeRaisedLocal$’ ‘$Data[Default='Not Present']/Context/DataItem/AlertDescription$</span>’</span>

On my iPad, when an alert has arrived:

<a href="http://blog.tyang.org/wp-content/uploads/2013/04/IMG_0007.jpg"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="IMG_0007" alt="IMG_0007" src="http://blog.tyang.org/wp-content/uploads/2013/04/IMG_0007_thumb.jpg" width="399" height="300" border="0" /></a>

And I can also see the details once I opened Prowl:

<a href="http://blog.tyang.org/wp-content/uploads/2013/04/IMG_0008.jpg"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="IMG_0008" alt="IMG_0008" src="http://blog.tyang.org/wp-content/uploads/2013/04/IMG_0008_thumb.jpg" width="511" height="384" border="0" /></a>

Similar to the Android and Windows phone APIs, Prowl has a limitation of 1000 notifications per hour from an IP address. I wouldn’t think any healthy OpsMgr environments would hit that limit.

If you’ve already got the notification channel setup for Android device (from my previous post), you can simply replace the script with the new one. and the same script can be used for iOS and Windows phone devices too.
<h2>Summary</h2>
At this stage, this script would work on all 3 major mobile device types: iOS, Android and Windows Phone by using 3 different push notification API’s:

Windows Phone: <a href="https://notifymywindowsphone.com/">Notify My Windows Phone</a>

Android: <a href="https://www.notifymyandroid.com/">Notify My Android</a>

iOS: <a href="http://www.prowlapp.com/">Prowl</a>

Again, thanks Stefan for his original posts and script. Hopefully this script will be adopted by more people as most of the population is still using iOS and Android devices.