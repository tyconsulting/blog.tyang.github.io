---
id: 1325
title: Scripting 101 For George
date: 2012-08-08T23:49:18+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=1325
permalink: /2012/08/08/scripting-101-for-george/
enclosure:
  - |
    http://blog.tyang.org/wp-content/uploads/2012/08/ForGeorge.mp4
    154314
    video/mp4
    
categories:
  - PowerShell
tags:
  - Fun
  - Powershell
---
Yesterday at work, we were having a chat with George, the team leader of our infrastructure 3rd level support team. George told me since he’s a team leader, he doesn’t have to be technical <strong>ANYMORE</strong>, all he needs to do is to delegate. Then the topic somehow shifted to scripting and George said to me all he can write is “Hello World”.

So I challenged him by opening PowerShell console on my PC and asked him to write “Hello World” for me.

It turned out, he couldn’t write it. that proved he’s <strong>NEVER</strong> technical in the first place <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" src="http://blog.tyang.org/wp-content/uploads/2012/08/wlEmoticon-smile1.png" alt="Smile" />.

So I started an email trail with the whole team: Scripting 101 For George. I initially demonstrated to George how to write Hello World in VBScript, PowerShell, C# and even batch file. then other guys jumped in, extended the list to PHP, Perl, Java, Fortran, etc.

I then showed George how to create a “Hello World” infinite loop in PowerShell:

[sourcecode language="PowerShell"]
Do {
Write-Host “Hello World”
}
While ($George.Nationality –eq “Greek”)
[/sourcecode]


and How to Hello World in his favourite colour:

<a href="http://blog.tyang.org/wp-content/uploads/2012/08/clip_image002.jpg"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border-width: 0px;" title="clip_image002" src="http://blog.tyang.org/wp-content/uploads/2012/08/clip_image002_thumb.jpg" alt="clip_image002" width="580" height="90" border="0" /></a>

In the end, I’ve been asked to go a bit crazier so I wrote this:
<div id="scid:5737277B-5D6D-4f48-ABFC-DD9C333F4C5D:f1582243-e8ea-4e41-8c83-bde5095a3b7a" class="wlWriterEditableSmartContent" style="margin: 0px; display: inline; float: none; padding: 0px;">
<div><object width="509" height="314" classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,40,0"><param name="src" value="http://www.youtube.com/v/oW0MAlG1dLA?hl=en&amp;hd=1" /><embed width="509" height="314" type="application/x-shockwave-flash" src="http://www.youtube.com/v/oW0MAlG1dLA?hl=en&amp;hd=1" /></object></div>
<div style="width: 509px; clear: both; font-size: .8em;">Download the Video <a href="http://blog.tyang.org/wp-content/uploads/2012/08/ForGeorge.mp4">HERE</a>.</div>
</div>
Here’s the source code for ForGeorge.PS1: <a title="ForGeorge.PS1" href="http://blog.tyang.org/wp-content/uploads/2012/08/ForGeorge.zip">Download</a>

George, I hope you’ve now learned how to Hello World in PowerShell at least <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" src="http://blog.tyang.org/wp-content/uploads/2012/08/wlEmoticon-smile1.png" alt="Smile" />. And to our boss Craig, when you are talking about organising PowerShell training for the team, I’m totally with you 100%!