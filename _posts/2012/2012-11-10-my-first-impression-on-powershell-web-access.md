---
id: 1635
title: My First Impression on PowerShell Web Access
date: 2012-11-10T11:28:05+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=1635
permalink: /2012/11/10/my-first-impression-on-powershell-web-access/
image: /wp-content/uploads/2012/11/Web-Browse-Icons-1.png
categories:
  - PowerShell
tags:
  - PowerShell
  - PowerShell Remoting
  - PowerShell Web Access
---
I ran up an instance of Windows Server 2012 in my test lab last night so I can play with various new features such as IPAM and PowerShell Web Access, etc.

Today I configured this box as the PowerShell Web Access (PSWA) gateway. I have to say, I am very very impressed! The implementation is easy, took me less than an hour (including time spent reading TechNet articles) and having ability to access PowerShell console on virtually any web browser for all Windows machines in my lab is just fantastic!

Now I can probably get away from using RDP most of the times since I’m pretty comfortable with PowerShell <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" src="http://blog.tyang.org/wp-content/uploads/2012/11/wlEmoticon-smile.png" alt="Smile" />

<strong>So, here are the steps I took to setup PSWA:</strong>

1. Add the PSWA feature in Server Manager

2. Install PSWA web application using PowerShell:

```powershell
Install-PswaWebApplication
```

3. Requested and installed a SSL certificate for the PSWA gateway machine from my Enterprise CA

4. In IIS, configured HTTPS for the default web site and used the SSL certificate I just installed from previous step.

5. Created an AD group called PSWA_Users and added few user IDs into this group.

6. Create PSWA Authorization Rule:

```powershell
Add-PSWAAuthorizationRule -UserGroupName Corp\PSWA_Users -Computername * -ConfigurationName *
```

<a href="http://blog.tyang.org/wp-content/uploads/2012/11/image.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/11/image_thumb.png" alt="image" width="580" height="52" border="0" /></a>

7. Since I can’t guarantee that WinRM has been enabled and configured on every machine, I’ve created a GPO to enable WinRM and linked it to the domain root.

Now, PSWA is pretty much ready to go. I launch the web access console on Google Chrome and entered my credential and the computer that I wish to connect to:

<a href="http://blog.tyang.org/wp-content/uploads/2012/11/image1.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/11/image_thumb1.png" alt="image" width="580" height="351" border="0" /></a>

And I’m in!

<a href="http://blog.tyang.org/wp-content/uploads/2012/11/image2.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/11/image_thumb2.png" alt="image" width="580" height="424" border="0" /></a>

It’s great to see that Microsoft releases a web-based product that runs on browsers other than IE. I don’t think I’ve seen anything like this before!

<strong>Additional Configurations:</strong>

I started testing by connecting to a SCOM management server and tried to retrieve all SCOM agents in my management group (Only 11 in total so I’d assume not huge amount of data is returned). I used:

```powershell
Import-Module OperationsManager
$a = Get-SCOMAgent
```

Interestingly, it failed and the connection to the management server was closed:

<a href="http://blog.tyang.org/wp-content/uploads/2012/11/image3.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/11/image_thumb3.png" alt="image" width="580" height="201" border="0" /></a>

Error:

<em><span style="color: #ff0000;">Processing data for a remote command failed with the following error message: The WSMan provider host process did not return a proper response. A provider in the host process may have behaved improperly.</span></em>

This reminded me the default setting for "Maximum amount of memory in MB per Shell" for WinRM, which I blogged previously in this <a href="http://blog.tyang.org/2012/06/07/using-powershell-remote-sessions-in-a-large-scom-environment/">post</a>. The default setting on Windows Server 2008 R2 and Windows 7 is 150MB. This default setting has increased to 1024MB on Windows Server 2012 and Windows 8.

So to test, since I have 3 management servers in the OM12 management group, I’ve increased this setting to 1024 on another management server. It fixed the error:

<a href="http://blog.tyang.org/wp-content/uploads/2012/11/image4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/11/image_thumb4.png" alt="image" width="580" height="342" border="0" /></a>

To further prove this error is actually caused by not having enough memory for the remote shell, I’ve connected PSWA to a Windows 8 machine, which has OM12 console and command shell installed. I used the following commands to connect to the OM12 management group:

```powershell
Import-Module OperationsManager
New-SCManagementGroupConnection OpsMgrMS03
```

It prompted an error saying I don’t have sufficient permission:

<a href="http://blog.tyang.org/wp-content/uploads/2012/11/image5.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/11/image_thumb5.png" alt="image" width="580" height="189" border="0" /></a>

This is by design, when using second hop in CredSSP, the credential has to be explicitly specified. so I changed the command to:

```powershell
New-SCManagementGroupConnection OpsMgrMS03 –Credential (Get-Credential domain\MyID)
```

after entering the password, I was successfully connected and I managed to retrieve all SCOM agents by using Get-SCOMAgent Cmdlet without issues.

<a href="http://blog.tyang.org/wp-content/uploads/2012/11/image6.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/11/image_thumb6.png" alt="image" width="580" height="352" border="0" /></a>

So to fix this issue once for all, I’ve modified the GPO I’ve just created and changed the "Maximum amount of memory in MB per Shell" setting to 1024.

<a href="http://blog.tyang.org/wp-content/uploads/2012/11/WinRM-Policy.htm">Click here</a> to see settings defined in my WinRM GPO.

I also configured another port forwarding rule on my ADSL router to forward port 443 to the PSWA gateway computer so I can connect when I’m not home.

<strong>PSWA on Mobile Devices:</strong>

I am able to launch and use PSWA on both my Android tablet (Samsung Galaxy Tab 10.1v running ICS) and my wife’s iPad 3 (running iOS 6) using both built-in browsers and Google Chrome on both devices.

Below are few screenshots from my Galaxy Tab:

<a href="http://blog.tyang.org/wp-content/uploads/2012/11/image7.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/11/image_thumb7.png" alt="image" width="551" height="346" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2012/11/image8.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/11/image_thumb8.png" alt="image" width="555" height="348" border="0" /></a>

Maybe it’s just me being an Apple noob, when I’m on the iPad, I could not find the Tab key on the keyboard, so I couldn’t use the PowerShell auto completion feature. – One more reason that I’m staying away from that product!

<strong>Console Size:</strong>

by default, the console size is 120x35, which seems like a waste of space when I’m on a big screen.

So I wrote a simple PowerShell script called <strong>Resize-Console.ps1</strong> to resize the window:

```powershell
$bufferSize = $Host.UI.RawUI.BufferSize
$buffersize.Width = 180
$host.UI.RawUI.BufferSize = $buffersize

$WindowSize = $host.UI.RawUI.WindowSize
$WindowSize.Width = 180
$WindowSize.Height = 40
$host.UI.RawUI.WindowSize = $WindowSize
```

After I ran this script, the console fits perfectly on my Galaxy tab (resolution 1280x800):

<a href="http://blog.tyang.org/wp-content/uploads/2012/11/image9.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/11/image_thumb9.png" alt="image" width="580" height="365" border="0" /></a>

This console size also works great on my laptop, which has the resolution of 1366x768. For different resolutions, the width and height need to be adjusted in the script. the only catch is the buffersize cannot be less than the window size (I set the width for both sizes to be the same).

I haven’t managed to work out a automated way to resize the console as when in a PS remote session, there is no $profile so I can’t add scripts into $profile like we normally do on a local console. If I find a way in the future, I’ll post it here.

This is what I found so far. I’ll continue to blog on this topic if I find any other interesting stuff!

By the way, I followed this TechNet article to configure the PSWA: <a href="http://technet.microsoft.com/en-us/library/hh831611.aspx">Deploy Windows PowerShell Web Access</a>