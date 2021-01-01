---
id: 3693
title: Session Recording for My Presentation in Microsoft MVP Community Camp Melbourne Event
date: 2015-02-01T19:44:18+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=3693
permalink: /2015/02/01/session-recording-presentation-microsoft-mvp-community-camp-melbourne-event/
categories:
  - MVP
  - SCOM
  - SMA
tags:
  - MVP
  - SCOM
  - SMA
---
<a href="http://blog.tyang.org/wp-content/uploads/2015/02/image.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/02/image_thumb.png" alt="image" width="372" height="211" border="0" /></a>

Last Friday, I presented in the Melbourne MVP Community Camp day, on the topic of “Automating SCOM Tasks Using SMA”.

I have uploaded the session recording to YouTube. You can either watch it here:
<div id="scid:5737277B-5D6D-4f48-ABFC-DD9C333F4C5D:053c04d2-2824-464b-81e8-b08232e88995" class="wlWriterEditableSmartContent" style="float: none; margin: 0px; display: inline; padding: 0px;">
<div><object width="694" height="390"><param name="movie" value="http://www.youtube.com/v/QW99bVFKg80?hl=en&amp;hd=1" /><embed src="http://www.youtube.com/v/QW99bVFKg80?hl=en&amp;hd=1" type="application/x-shockwave-flash" width="694" height="390" /></object></div>
<div style="width: 694px; clear: both; font-size: .8em;">If you’d like to watch it in full screen, please go to: https://www.youtube.com/watch?v=QW99bVFKg80</div>
</div>
&nbsp;

Or on YouTube: <a title="https://www.youtube.com/watch?v=QW99bVFKg80" href="https://www.youtube.com/watch?v=QW99bVFKg80">https://www.youtube.com/watch?v=QW99bVFKg80</a>

You can also download the presentation deck from <strong><a href="http://blog.tyang.org/wp-content/uploads/2015/02/Automating-SCOM-Tasks-Using-SMA.pdf">HERE</a></strong>.

And Here’s the sample script I used in my presentation when I explained how to connect to SCOM management group via SDK:
<pre language="PowerShell">
#Script Name: Sample-ConnectMG.ps1
#Load SCOM SDK DLLs from GAC
[System.Reflection.Assembly]::Load("Microsoft.EnterpriseManagement.Core, Version=7.0.5000.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35")
[System.Reflection.Assembly]::Load("Microsoft.EnterpriseManagement.OperationsManager, Version=7.0.5000.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35")
[System.Reflection.Assembly]::Load("Microsoft.EnterpriseManagement.Runtime, Version=7.0.5000.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35")

#Load SCOM SDK DLLs from a folder
[System.Reflection.Assembly]::LoadFrom("C:\Temp\Microsoft.EnterpriseManagement.Core.dll")
[System.Reflection.Assembly]::LoadFrom("C:\Temp\Microsoft.EnterpriseManagement.OperationsManager.dll")
[System.Reflection.Assembly]::LoadFrom("C:\Temp\Microsoft.EnterpriseManagement.Runtime.dll")

#Connect to SCOM Management Group
$ConnectionSetting = New-Object Microsoft.EnterpriseManagement.ManagementGroupConnectionSettings("OpsMgrMS01")

#Optionally, specify username and password
$UserName = "Domain\SCOMAdmin"
$Password = ConvertTo-SecureString -AsPlainText "password1234" -force
$ConnectionSetting.UserName = $Username
$ConnectionSetting.Password = $Password

#Connect to SCOM Management Group
$MG = New-Object Microsoft.EnterpriseManagement.ManagementGroup($ConnectionSetting)

#Get Management Group Administration
$Admin = $MG.Administration
</pre>
Overall, I think I could have done better - as I wasn’t in the best shape that day. I have been sick for the last 3 weeks (dry cough passed on to me from my daughter). The night before the presentation, I was coughing none-stop and couldn’t go to sleep. I then got up, looked up the Internet and someone suggested that sleeping upright might help. I then ended up slept on the couch for 2.5 hours before got up and drove to Microsoft’s office. So I was really exhausted even before I got on stage. Secondly, the USB external Microphone didn’t work on my Surface, so the sound was recorded from the internal mic – not the best quality for sure.

Anyways, for those who’s watching the recording online, I’m really interested in hearing back from you if you have any suggestions or feedbacks in regards to the session itself, or the OpsMgrExtended module that I’m about to release. So, please feel free to drop me an email if you like <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" src="http://blog.tyang.org/wp-content/uploads/2015/02/wlEmoticon-smile.png" alt="Smile" />.