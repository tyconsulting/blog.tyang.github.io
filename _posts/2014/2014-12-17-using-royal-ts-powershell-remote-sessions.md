---
id: 3562
title: Using Royal TS for PowerShell Remote Sessions
date: 2014-12-17T20:44:11+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=3562
permalink: /2014/12/17/using-royal-ts-powershell-remote-sessions/
categories:
  - PowerShell
tags:
  - PowerShell
  - RoyalTS
---

## Background

I have used many Remote Desktop applications in the past. I have to say <a href="http://www.royalts.com/">Royal TS</a> is the one that I like the most! Recently, I showed it to one of my colleagues, after a bit of playing around, he purchased a license for himself too.

Today, my colleague asked me if I knew that Royal TS is also able to run external commands, and he thought it’s pretty cool that he’s able to launch PowerShell in the Royal TS window. Then I thought, if you can run PowerShell in Royal TS, we should be able to establish PS remote sessions in Royal TS too. Within 10 minutes, we managed to create few connections in Royal TS like these:

<a href="https://blog.tyang.org/wp-content/uploads/2014/12/SNAGHTML1c209a8d.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML1c209a8d" src="https://blog.tyang.org/wp-content/uploads/2014/12/SNAGHTML1c209a8d_thumb.png" alt="SNAGHTML1c209a8d" width="632" height="281" border="0" /></a>

<a href="https://blog.tyang.org/wp-content/uploads/2014/12/SNAGHTMLa497d178.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLa497d178" src="https://blog.tyang.org/wp-content/uploads/2014/12/SNAGHTMLa497d178_thumb.png" alt="SNAGHTMLa497d178" width="639" height="335" border="0" /></a>

<a href="https://blog.tyang.org/wp-content/uploads/2014/12/image24.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/12/image_thumb24.png" alt="image" width="673" height="411" border="0" /></a>

<a href="https://blog.tyang.org/wp-content/uploads/2014/12/SNAGHTML1c2e5543.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; margin: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML1c2e5543" src="https://blog.tyang.org/wp-content/uploads/2014/12/SNAGHTML1c2e5543_thumb.png" alt="SNAGHTML1c2e5543" width="192" height="244" border="0" /></a>

In this post, I’ll go through the steps I took to set them up.

## Connections to Individual Servers

To create a connection to an individual server,

1. Choose add->External Application:

<a href="https://blog.tyang.org/wp-content/uploads/2014/12/image25.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; margin: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/12/image_thumb25.png" alt="image" width="244" height="195" border="0" /></a>

{:start="2"}
2. Enter the following Details:

  * **Display Name:** The name of the server you want to connect to.
  * **Command:** C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
  * **Arguments:** -NoExit -Command "Enter-PSSession $CustomField1$"
  * **Working Directory:** C:\Windows\System32\WindowsPowerShell\v1.0

On the icon button next to the display name, choose "Use Application Icon" if you want to.

<a href="https://blog.tyang.org/wp-content/uploads/2014/12/image26.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/12/image_thumb26.png" alt="image" width="548" height="421" border="0" /></a>

<a href="https://blog.tyang.org/wp-content/uploads/2014/12/image27.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/12/image_thumb27.png" alt="image" width="347" height="167" border="0" /></a>

{:start="3"}
3.  Choose a Credential if you want to connect using an alternative credential

<a href="https://blog.tyang.org/wp-content/uploads/2014/12/SNAGHTML1c5136c4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML1c5136c4" src="https://blog.tyang.org/wp-content/uploads/2014/12/SNAGHTML1c5136c4_thumb.png" alt="SNAGHTML1c5136c4" width="408" height="208" border="0" /></a>

If you choose to use an alternative credential,  you must also tick "**Use Credentials**" box under Advanced tab:

<a href="https://blog.tyang.org/wp-content/uploads/2014/12/image28.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/12/image_thumb28.png" alt="image" width="526" height="404" border="0" /></a>

{:start="4"}
4. Enter the remote server name in Custom Field 1:

<a href="https://blog.tyang.org/wp-content/uploads/2014/12/image29.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/12/image_thumb29.png" alt="image" width="521" height="401" border="0" /></a>

**<span style="color: #ff0000;">Note:</span>** in the arguments field from step 01, I’ve used a Royal TS variable $CustomField1$ as the name of the computer in the Enter-PSSession command. It is more user friendly to use the Custom Field for the computer name, rather than modifying the argument string for each connection that you wish to create.

## <span style="color: #000000;">Create An Ad-Hoc Connection</span>

You can also create a connection in Royal TS for Ad-Hoc connections. In this scenario, you will need to enter the remote computer that you wish to connect to:

<a href="https://blog.tyang.org/wp-content/uploads/2014/12/image30.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/12/image_thumb30.png" alt="image" width="398" height="190" border="0" /></a>

After the the computer name has been entered, the connection is then established:

<a href="https://blog.tyang.org/wp-content/uploads/2014/12/image31.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/12/image_thumb31.png" alt="image" width="396" height="131" border="0" /></a>

To create this connection in Royal TS, instead of using the Custom Field 1 for the computer name, I’ve added an additional PowerShell command in the Arguments:

**Arguments:** -NoExit -Command "<span style="color: #ff0000;">$Computer = Read-Host 'Please enter the Computer Name';</span> Enter-PSSession $Computer"

<a href="https://blog.tyang.org/wp-content/uploads/2014/12/image32.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/12/image_thumb32.png" alt="image" width="556" height="427" border="0" /></a>

The Custom Field 1 is no longer required in this scenario. Everything else is the same as the previous sample (for individual computers).

## Other Considerations

**Maximised PowerShell Window**

You may have noticed from the screenshots above, that the PowerShell windows are perfectly fitted in the Royal TS frame. this is because I am also using a customised PS Module that I’ve written in the past to resize the PoewerShell window. Without this module, the PowerShell console would not automatically fit into the Royal TS frame:

<a href="https://blog.tyang.org/wp-content/uploads/2014/12/image33.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/12/image_thumb33.png" alt="image" width="311" height="191" border="0" /></a> **<span style="color: #ff0000; font-size: large;">VS</span>** <a href="https://blog.tyang.org/wp-content/uploads/2014/12/image34.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/12/image_thumb34.png" alt="image" width="313" height="192" border="0" /></a>

If you like your console looks like the left one rather than one on the right, please follow the instruction below.

1. <a href="https://blog.tyang.org/2014/04/08/powershell-module-resize-console-updated/">Download the PSConsole Module</a> and place it under **C:\windows\system32\WindowsPowerShell\v1.0\Modules**

<a href="https://blog.tyang.org/wp-content/uploads/2014/12/image35.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/12/image_thumb35.png" alt="image" width="444" height="171" border="0" /></a>

{:start="2"}
2. Modify the "All Users Current Host" profile **<span style="color: #ff0000;">from a normal PowerShell window</span>** (NOT within PowerShell ISE). If you are not sure if this profile has been created, run the command below:
```powershell
if (!(test-Path $profile.alluserscurrenthost)) {New-Item -type File -Path $Profile.alluserscurrenthost}

```
<a href="https://blog.tyang.org/wp-content/uploads/2014/12/image36.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/12/image_thumb36.png" alt="image" width="611" height="115" border="0" /></a>

After the profile is created, open it in notepad (in PowerShell window, type: **Notepad $Profile.AllUsersCurrentHost**) and add 2 lines of code:
```powershell
import-module PSConsole
Resize -max

```
<a href="https://blog.tyang.org/wp-content/uploads/2014/12/image37.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/12/image_thumb37.png" alt="image" width="405" height="131" border="0" /></a>

After saving the changes, next time when you initiate a connection in Royal TS, the console will automatically maximise to use all the usable space.

**<span style="color: #ff0000;">Note:</span>** Because most likely you will be using an alternative (privileged credential) for these PS remote sessions. therefore the resize console commands cannot be placed into the default profile (current user current host). It must be placed into an All users profile. And also because the resize command only works in a normal PowerShell console (not in PowerShell ISE), therefore the only profile that you can use is the "All Users Current Host" profile from the normal PowerShell console.

Alternatively, if you do not wish to make changes to the All Users Current host profile, you can also add the above mentioned lines into the Royal TS connection arguments field:

i.e.

Arguments: **-NoExit -Command "<span style="color: #ff0000;">import-module psconsole; resize -max;</span> Enter-PSSession $CustomField1$"**

<a href="https://blog.tyang.org/wp-content/uploads/2014/12/image38.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/12/image_thumb38.png" alt="image" width="562" height="432" border="0" /></a>

**Duplicating Royal TS Connections**

If you want to create multiple connections, all you need to do is to create the first one manually, and then duplicate it multiple times:

<a href="https://blog.tyang.org/wp-content/uploads/2014/12/image39.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/12/image_thumb39.png" alt="image" width="258" height="332" border="0" /></a>

When duplicating connections, the only fields you need to change are the Display Name and CustomField1.

## WinRM configuration

Needless to say, WinRM must be enabled and properly configured for PS remoting to work. this is a pre-requisite. I won’t go through how to configure WinRM here. Someone actually wrote a whole <a href="http://powershell.org/wp/2012/08/06/ebook-secrets-of-powershell-remoting/">book</a> on this topic.

## Conclusion

I’d like to thank Stefan Koell (<a href="http://www.code4ward.net/main/blog.aspx">blog</a>, <a href="https://twitter.com/StefanKoell">twitter</a>), the Royal TS developer (and also my fellow SCCDM MVP) for such an awesome tool. This is now probably **THE** most used application on all my computers <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" src="https://blog.tyang.org/wp-content/uploads/2014/12/wlEmoticon-smile3.png" alt="Smile" />.

If you haven’t tried <a href="http://www.royalts.com/">Royal TS</a> out, please give it a try. Other than the obvious Windows version, there are also a Mac version, an iOS version and an Android version.