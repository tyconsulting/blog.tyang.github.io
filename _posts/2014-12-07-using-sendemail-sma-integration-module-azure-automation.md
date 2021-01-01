---
id: 3425
title: Using the SendEmail SMA Integration Module in Azure Automation
date: 2014-12-07T11:38:48+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=3425
permalink: /2014/12/07/using-sendemail-sma-integration-module-azure-automation/
categories:
  - Azure
tags:
  - Azure Automation
  - SMA
---
Over the last couple of days, I’ve spent sometime on Azure Automation (SMA in Azure). The first thing I did was imported and configured the <a href="http://blog.tyang.org/2014/10/31/simplified-way-send-emails-mobile-push-notifications-sma/">SendEmail and SendPushNotification SMA Integration Modules</a> that I have posted earlier. I created a simple test runbook to send an email and a push notification to my android phone:
<pre language="PowerShell">workflow Test-PushNotification
{
#Get the contact details
$ContactName = 'tyang'
Write-Verbose "Getting SMA Address Book entry for $ContactName"
$Contact = Get-AutomationConnection -Name $ContactName
Write-Verbose "Contact: $Contact"

#Get SMTP settings
Write-Verbose "Getting SMTP configuration"
$SMTPSettings = Get-AutomationConnection -Name 'GmailSMTP'
Write-Verbose $SMTPSettings
$Subject = "Test message from Azure Automation"
$Message = "Hello, this is a test message from Azure Automation."

#Send email
Write-Verbose 'Sending email'
$Send = Send-Email -SMTPSettings $SMTPSettings -To $Contact.Email -Subject $Subject -Body $Message -HTMLBody $false

#Android Push Notification
Write-Verbose 'Sending Android push notification'
Send-MobilePushNotification -os "Android" -apikey $Contact.AndroidAPI -Subject $Subject -Application 'Azure Automation' -Body $Message
}
</pre>
However, I found 2 issues related to the SendEmail module. I’ll go through both of the issues in this post.
<h3>Issue 1</h3>
When I executed this runbook, it failed to send the email message. I got this error:

<span style="color: #ff0000;"><em>Cannot find the 'Send-Email' command. If this command is defined as a workflow, ensure it is defined before the workflow that calls it. If it is a command intended to run directly within Windows PowerShell (or is not available on this system), place it in an InlineScript: 'InlineScript { Send-Email }'</em></span>

<a href="http://blog.tyang.org/wp-content/uploads/2014/12/SNAGHTML6ef25ba9.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML6ef25ba9" src="http://blog.tyang.org/wp-content/uploads/2014/12/SNAGHTML6ef25ba9_thumb.png" alt="SNAGHTML6ef25ba9" width="665" height="569" border="0" /></a>

I found the cause of this issue is because I did not have a PowerShell module manifest file (psd1) in this module:

<a href="http://blog.tyang.org/wp-content/uploads/2014/12/image.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/12/image_thumb.png" alt="image" width="471" height="80" border="0" /></a>

Whereas the SendPushNotification module works because it has a manifest file:

<a href="http://blog.tyang.org/wp-content/uploads/2014/12/image1.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/12/image_thumb1.png" alt="image" width="465" height="96" border="0" /></a>

I didn’t pick this one up when I released the modules because it worked in the On-Prem SMA environments when I wrote it. So, it’s easy to fix this issue. I generated a manifest file for SendEmail module, uploaded it to Azure Automation, the issue went away.
<h3>Issue 2</h3>
After fixing the first issue, I started receiving SMTP authentication errors. I have configured a Gmail account as the sender – same as how I setup in my lab’s SMA environment, but I got SMTP error 5.5.1:

<em><span style="color: #ff0000;">Exception calling "Send" with "1" argument(s): "The SMTP server requires a secure connection or the client was not authenticated. The server response was: 5.5.1 Authentication Required.</span></em>

<a href="http://blog.tyang.org/wp-content/uploads/2014/12/image2.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/12/image_thumb2.png" alt="image" width="467" height="245" border="0" /></a>

Because this Gmail account is linked to my another Gmail account, I soon received an email from Google telling me they’ve detected some suspicious sign in activities:

<a href="http://blog.tyang.org/wp-content/uploads/2014/12/SNAGHTML6f0c1c8e.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML6f0c1c8e" src="http://blog.tyang.org/wp-content/uploads/2014/12/SNAGHTML6f0c1c8e_thumb.png" alt="SNAGHTML6f0c1c8e" width="462" height="434" border="0" /></a>

So, looks like a Google security feature has detected someone is trying to sign in not from my normal location (Australia), – because I’ve chosen East US region when I opened my Azure Automation account.

I then decided to use Outlook instead of Gmail. So I created an Outlook account, configured the connection and updated the runbook. Unfortunately, I received similar SMTP errors and the account was temporarily suspended because of these sign in activities.

Luckily, I could go adjust these security activity settings, and verify these sign in activities are mine:

<a href="http://blog.tyang.org/wp-content/uploads/2014/12/SNAGHTML6f13122c.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML6f13122c" src="http://blog.tyang.org/wp-content/uploads/2014/12/SNAGHTML6f13122c_thumb.png" alt="SNAGHTML6f13122c" width="490" height="482" border="0" /></a>

After adjusting these security settings, the runbook started working and I received the test notification email from the runbook:

<a href="http://blog.tyang.org/wp-content/uploads/2014/12/SNAGHTML6f13fab7.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML6f13fab7" src="http://blog.tyang.org/wp-content/uploads/2014/12/SNAGHTML6f13fab7_thumb.png" alt="SNAGHTML6f13fab7" width="515" height="206" border="0" /></a>
<h3>Conclusion</h3>
Based on my experience, I’m guessing the module manifest file is a must-have in Azure Automation? I have updated the SendEmail module and re-uploaded to this blog. If you have already downloaded it, sorry but you will need to download again if you are planning to use it in Azure Automation (Here’s the <a href="http://blog.tyang.org/wp-content/uploads/2014/12/SMANotificationModules.zip">download link</a>).

And if you are using a public email service as the sender like me, the security features implemented by the service provider may prevent you from using the email account in Azure Automation. You may need to adjust the security settings of the email account (like what I did with the Outlook account).

Lastly, if you haven’t tried Azure Automation, I strongly recommend you to give it a try. You get 500 minutes job run time a month for free (<a title="http://azure.microsoft.com/en-us/pricing/details/automation/" href="http://azure.microsoft.com/en-us/pricing/details/automation/">http://azure.microsoft.com/en-us/pricing/details/automation/</a>). This should easily get you started.