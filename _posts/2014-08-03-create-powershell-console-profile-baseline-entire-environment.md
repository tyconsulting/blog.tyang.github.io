---
id: 3084
title: How to Create a PowerShell Console Profile Baseline for the Entire Environment
date: 2014-08-03T16:48:24+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=3084
permalink: /2014/08/03/create-powershell-console-profile-baseline-entire-environment/
categories:
  - PowerShell
  - SCCM
tags:
  - Powershell
  - SCCM
---
<h3>Background</h3>
Often when I’m working in my lab, I get frustrated because the code in PowerShell profiles varies between different computers and user accounts. And your user profile is also different between the normal PowerShell command console and PowerShell ISE. I wanted to be able to create a baseline for the PowerShell profiles across all computers and all users, no matter which PowerShell console is being used (normal command console vs PowerShell ISE).

For example, I would like to achieve the following when I start any 64 bit PowerShell consoles on any computers in my lab under any user accounts:
<ul>
	<li>Append “- Tao Yang Test Lab” in the console title</li>
	<li>Change console’s background colour to black</li>
	<li>Change the text colour to green</li>
	<li>if I’m on the normal PowerShell command console, maximise the console window using the PSConsole module I have written in the past (<a title="http://blog.tyang.org/2014/04/08/powershell-module-resize-console-updated/" href="http://blog.tyang.org/2014/04/08/powershell-module-resize-console-updated/">http://blog.tyang.org/2014/04/08/powershell-module-resize-console-updated/</a>)</li>
	<li>Set the location to C:\</li>
</ul>
This is what I want the consoles to look like:

<a href="http://blog.tyang.org/wp-content/uploads/2014/08/SNAGHTML65445bb.png"><img class="alignnone  wp-image-3070" src="http://blog.tyang.org/wp-content/uploads/2014/08/SNAGHTML65445bb.png" alt="SNAGHTML65445bb.png" width="428" height="167" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2014/08/image.png"><img class="alignnone  wp-image-3072" src="http://blog.tyang.org/wp-content/uploads/2014/08/image.png" alt="image.png" width="462" height="307" /></a>

Although I can manually copy the code into the profiles for each of my user accounts and enable roaming profile for  these users, I don’t want to take this approach because it’s too manual and I am not a big fan of roaming profiles.
<h3>Instructions</h3>
My approach is incredibly simple, all I had to do is to create a simple script and deployed it as a normal software package  using ConfigMgr. I’ll now go through the steps.

<strong>All Users All Hosts Profile</strong>

Firstly, there are actually not one (1), but six (6) different PowerShell profiles (I have to admit, I didn’t know this until now <img class="wlEmoticon wlEmoticon-smilewithtongueout" style="border-style: none;" src="http://blog.tyang.org/wp-content/uploads/2014/08/wlEmoticon-smilewithtongueout.png" alt="Smile with tongue out" />). <a href="http://blogs.technet.com/b/heyscriptingguy/archive/2012/05/21/understanding-the-six-powershell-profiles.aspx">This article</a> from the Scripting Guy explained it very well. Based on this article, I have identified that I need to work on the All Users All Hosts profile. Because I want the code to run regardless which user account am I using, and no matter whether I’m using the normal command console or PowerShell ISE.

<strong>Pre-Requisite</strong>

As I mentioned previously, because I want to use the PSConsole module I have developed earlier, I need to make sure this module is deployed to all computers in my lab. To do so, I have created a simple msi to copy the module to the PowerShell Module’s folder and deployed it to all the computers using ConfigMgr. I won’t go through how I created the msi here.

<strong>Code Inside the All Users All Hosts profile</strong>

The All Users All Hosts profile is located at <strong>$PsHome\profile.ps1</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2014/08/image1.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/08/image_thumb1.png" alt="image" width="362" height="86" border="0" /></a>

Here’s the code I’ve added to this profile:

[sourcecode language="Powershell"]
if (Get-module -name PSConsole -List)
{
Import-Module PSConsole
}

$host.UI.RawUI.BackgroundColor = &quot;Black&quot;
$host.UI.RawUI.ForegroundColor = &quot;Green&quot;
$host.UI.RawUI.WindowTitle = $host.UI.RawUI.WindowTitle + &quot;  - Tao Yang Test Lab&quot;
If ($psISE)
{
$psISE.Options.ConsolePaneBackgroundColor = &quot;Black&quot;
} else {
Resize-Console -max -ErrorAction SilentlyContinue
}
set-location C:\
Clear-Host
[/sourcecode]

<strong><span style="color: #ff0000;">Note:</span></strong> The $psISE variable only exists in the PowerShell ISE environment, therefore I’m using it to identify which console am I currently in and used an IF… Else… statement to control what’s getting executed within PowerShell ISE and normal PowerShell console.

<strong>Script To create All Users All Hosts Profile</strong>

Next, I have created a PowerShell script to create the All Users All Hosts profile:

[sourcecode language="Powershell"]
#=====================================================================
# Script Name:        CreateAllUsersAllHostsProfile.ps1
# DATE:               03/08/2014
# Version:            1.0
# COMMENT:            - Script to create All users All hosts PS profile
#=====================================================================

$ProfilePath = $profile.AllUsersAllHosts

#Create the profile if doesn't exist
If (!(test-path $ProfilePath))
{
New-Item -Path $ProfilePath -ItemType file -Force
}

#content of the profile script
$ProfileContent = @&quot;
if (Get-module -name PSConsole -List)
{
Import-Module PSConsole
}

`$host.UI.RawUI.BackgroundColor = &quot;Black&quot;
`$host.UI.RawUI.ForegroundColor = &quot;Green&quot;
`$host.UI.RawUI.WindowTitle = `$host.UI.RawUI.WindowTitle + &quot;  - Tao Yang Test Lab&quot;
If (`$psISE)
{
`$psISE.Options.ConsolePaneBackgroundColor = &quot;Black&quot;
} else {
Resize-Console -max -ErrorAction SilentlyContinue
}
set-location C:\
Clear-Host
&quot;@
#write contents to the profile
if (test-path $ProfilePath)
{
Set-Content -Path $ProfilePath -Value $ProfileContent -Force
} else {
Write-Error &quot;All Users All Hosts PS Profile does not exist and this script failed to create it.&quot;
}
[/sourcecode]

As you can see, I have stored the content in a multi-line string variable. The only thing to pay attention to is that I have to add the PowerShell escape character backtick (`)  in front of each variable (dollar sign $).

This script will overwrite the profile if already exists, so it will make sure the profile is consistent across all computers.

<strong>Deploy the Profile Creation Script Using ConfigMgr</strong>

In SCCM, I have created a Package with one program for this script:

<a href="http://blog.tyang.org/wp-content/uploads/2014/08/image2.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/08/image_thumb2.png" alt="image" width="432" height="456" border="0" /></a>

<strong>Command Line:</strong> %windir%\Sysnative\WindowsPowerShell\v1.0\Powershell.exe .\CreateAllUsersAllHostsProfile.ps1

<strong><span style="color: #ff0000;">Note:</span></strong> I’m using ConfigMgr 2012 R2 in my lab, although the ConfigMgr client seems to be 64-bit, this command will still be executed under 32-bit environment. Therefore I have to use “<strong>Sysnative</strong>” instead of “System32” to overcome 32-bit redirection in 64-bit OS.

I created a re-occurring deployment for this program:

<a href="http://blog.tyang.org/wp-content/uploads/2014/08/image3.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/08/image_thumb3.png" alt="image" width="399" height="350" border="0" /></a>

I’ve set it to run it once a day at 8:00am and always rerun.

<strong>Conclusion</strong>

This is an example on how we can standardise the baseline of PowerShell consoles within the environment. Individual users will still be able to add the users specific stuff in different profiles.

For example, on one of my computers, I have added one line to the default Current User Current Host profile:

<a href="http://blog.tyang.org/wp-content/uploads/2014/08/image4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/08/image_thumb4.png" alt="image" width="615" height="111" border="0" /></a>

In the All Users All Hosts profile, I have set the location to C:\, but in the Current User Current Host profile, I’ve set the location to “C:\Scripts\Backup Script”. The result is, when I started the console, the location is set to “C:\Scripts\Backup Script”. Obviously the Current User Current Host profile was executed after the All Users All Hosts profile. Therefore we can use the All Users All Hosts profile as a baseline and using Current User Current Host profile as a delta <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" src="http://blog.tyang.org/wp-content/uploads/2014/08/wlEmoticon-smile.png" alt="Smile" />.