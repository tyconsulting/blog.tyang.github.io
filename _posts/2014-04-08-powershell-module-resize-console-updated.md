---
id: 2487
title: 'PowerShell Module to resize console &ndash; Updated'
date: 2014-04-08T22:01:28+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=2487
permalink: /2014/04/08/powershell-module-resize-console-updated/
categories:
  - PowerShell
tags:
  - Powershell
  - Powershell Web Access
---
<a href="http://blog.tyang.org/wp-content/uploads/2014/04/PSWAIcon.png"><img style="margin-left: 0px; display: inline; margin-right: 0px; border: 0px;" title="PSWAIcon" alt="PSWAIcon" src="http://blog.tyang.org/wp-content/uploads/2014/04/PSWAIcon_thumb.png" width="243" height="244" align="left" border="0" /></a> Few days ago I wrote a <a href="http://blog.tyang.org/2014/04/05/powershell-module-resize-console/">PowerShell module</a> that contains 1 cmdlet / function to resize the PowerShell console windows.

It was a quick job that I did less than half an hour. I wrote it primarily to make PowerShell Web Access (PSWA) more user friendly.

Over the last couple of days, I spent a bit more time on this module, and add a lot more functionality to it. The original module had 107 lines of code, and the updated one has 591 lines.

Here’s a list of new features:

<strong>Additional cmdlets</strong>

This module now contains the following cmdlets:
<ul>
	<li>Resize-Console</li>
	<li>Get-CurrentConsoleSize</li>
	<li>Save-ConsoleProfile</li>
	<li>Remove-ConsoleProfile</li>
	<li>Get-ConsoleProfile</li>
	<li>Update-ConsoleProfile</li>
</ul>
I’ll go through each cmdlets later

<strong>Aliases for all cmdlets and parameters</strong>

Since I wrote this module primarily for PSWA, and I intend to access PSWA primarily from mobile devices such as phones and tablets, I need to make the module easier to use. I am sure I’m not the only person who’s suffering from <a href="http://en.wikipedia.org/wiki/Typographical_error">fat finger syndrome</a>. I <strong>HATE</strong> typing on tablets and phones. Even with the Type Cover 2 for my Surface Pro 2, I found the keys are too small. So less is more, aliases really help when I use mobile devices because I don’t have to type as much.

<strong>Buffer width is always same as window width when </strong><b>re-sizing</b>

When working on any kind of command prompts (cmd or PowerShell), I really don’t like the horizontal scroll bar. by making the buffer width always the same as window width, I don’t have to see the horizontal bars anymore.

<strong>Resize-Console –max switch</strong>

Or “rsc –m” if use aliases. The –max switch will move the window to the top left corner of the PRIMARY monitor and maximize the window size. It also set the buffer height to the maximum value of 9999. - This is equivalent to maximizing a normal window.

Every time I get on to a box (most likely via RDP) for the first time, I always had to manually set the PowerShell console size to suit my needs. then next time I RDP in from another computer with different display resolutions, I often had to set it again.

With resize-console –max, it will always set the console to the maximum size and occupies the entire screen. It will make my life so much easier. Not that I have OCD(Obsessive Compulsive Disorder), but for those ones who do, this function would make you much happier I suppose :). I’ll demonstrate this in the Youtube video at the end of this article.

Note: for this functionality, I used some of the code from <a href="http://richardspowershellblog.wordpress.com/2011/07/23/moving-windows/">Richard Siddaways’s blog</a>. So thanks to Richard.

<strong>Resize-Console –Profile</strong>

I have included a XML file (profiles.xml) in this module. We can save pre-defined console dimension (Window width and height) to this XML so we can use them later.

i.e.:

<a href="http://blog.tyang.org/wp-content/uploads/2014/04/SNAGHTML1aca2b96.png"><img style="display: inline; border: 0px;" title="SNAGHTML1aca2b96" alt="SNAGHTML1aca2b96" src="http://blog.tyang.org/wp-content/uploads/2014/04/SNAGHTML1aca2b96_thumb.png" width="270" height="560" border="0" /></a>

The screen size and resolution are different among different computers and mobile devices. I have created different profiles for each type of devices that I own, so when I use a particular device to access PSWA, I can simply apply the appropriate screen size to suit that device.

i.e. the screenshot below is taken from my mobile phone (Samsung Note3):

<a href="http://blog.tyang.org/wp-content/uploads/2014/04/image8.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2014/04/image_thumb8.png" width="569" height="322" border="0" /></a>

when I applied the profile “Note3”, the PSWA console fits perfectly on the screen.

Or, on my 10.1 inch tablet Samsung Galaxy Tab2:

<a href="http://blog.tyang.org/wp-content/uploads/2014/04/image9.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2014/04/image_thumb9.png" width="580" height="364" border="0" /></a>

I used aliases, applied the “tab2” profile to fit the screen.

With the introduction to the –profile functions, this module now includes these functions for CRUD operations:
<ul>
	<li><strong>Save-ConsoleProfile</strong></li>
	<li><strong>Remove-ConsoleProfile</strong></li>
	<li><strong>Get-ConsoleProfile</strong></li>
	<li><strong>Update-ConsoleProfile</strong></li>
</ul>
For details of each functions, You can refer to the help information (get-help)

<strong><span style="color: #ff0000;">Note:</span></strong> <em>only administrators will be able to modify the profiles.xml because it’s located in a system folder. so if UAC is enabled, admins will need launch powershell console as Administrator in order to use the Remove-ConsoleProfile and Update-ConsoleProfile cmdlet.</em>

<strong>Get-CurrentConsoleSize</strong>

This one simply display the current window size and buffer size on screen. it’s reading the properties of “$host.ui.rawui”

<a href="http://blog.tyang.org/wp-content/uploads/2014/04/SNAGHTML1ad77daf4.png"><img style="display: inline; border: 0px;" title="SNAGHTML1ad77daf[4]" alt="SNAGHTML1ad77daf[4]" src="http://blog.tyang.org/wp-content/uploads/2014/04/SNAGHTML1ad77daf4_thumb.png" width="374" height="195" border="0" /></a>

For your reference, here’s a recorded demo that I have updated to Youtube:

https://www.youtube.com/watch?v=awrhCsrI4_k

Please watch this video in full screen and 720P/1080P or you may not be able to see what’s happening on the powershell console.

You can download the module <strong><a href="http://blog.tyang.org/wp-content/uploads/2014/04/PSConsoleV2.zip">HERE</a></strong>. simply unzip and copy the whole folder to <strong>C:\Windows\System32\WindowsPowerShell\v1.0\Modules</strong>

So why am I spending time on this PowerShell project rather than System Center, which is my bread and butter? That would be the topic for my next blog article. :)

Please feel free to contact me for any issues or suggestions.

Until next time, happy PowerShelling :)