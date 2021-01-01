---
id: 1370
title: SCOM Enhanced Email Notification Script Version 2
date: 2012-08-16T23:01:13+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=1370
permalink: /2012/08/16/scom-enhanced-email-notification-script-version-2/
categories:
  - PowerShell
  - SCOM
tags:
  - Featured
  - Powershell
  - SCOM
---
<a href="http://blog.tyang.org/wp-content/uploads/2012/08/version-2-badge.png"><img class="alignleft size-full wp-image-1372" title="version-2-badge" src="http://blog.tyang.org/wp-content/uploads/2012/08/version-2-badge.png" alt="" width="128" height="128" /></a>Few years ago, I posted the <a href="http://blog.tyang.org/2010/07/19/enhanced-scom-alerts-notification-emails/">SCOM Enhanced Email Notification Script</a> in this blog and became well adopted by the community. Over the last week or so, I have spent most of my time at night re-writing this script and I have completed the new version (2.0) now.

There are few reasons why I have decided to rewrite this script:
<ul>
	<li>Make it to work in SCOM 2012</li>
	<li>To be able to include Company Knowledge articles in the email (someone asked me about this a long time ago)</li>
	<li>Ability to use an external / public SMTP server (i.e. gmail) to send emails so I can decommission the Exchange server in my test lab. – since all I use this Exchange server for is to send out alert notifications and it can’t email out to the real world!</li>
	<li>Improve the email HTML body layout.</li>
</ul>
<strong>So what’s changed?</strong>
<ul>
	<li>Now the script uses SCOM SDK instead of SCOM PowerShell snap-in / module. And because of this, it works on both SCOM 2007 R2 and SCOM 2012. – so far, from my experience playing with the them, the SDK’s in SCOM 2007 and 2012 look pretty similar!</li>
	<li>Also because of the use of SCOM SDK, I’m able to retrieve Company Knowledge articles.</li>
	<li>In the original script, it would only retrieve knowledge articles when the language of the article is ENU (“en-US”). Therefore, any knowledge articles stored in other language packs (such as ENA) in the management pack would not be retrieved. The script now retrieve ALL knowledge articles AND ALL company knowledge articles and display ALL of them in the email (as shown in the sample below).</li>
	<li>I have moved all the customisations out of the script itself to a <strong>config.xml</strong> to store customised settings. No need to modify the PS1 script anymore. Simply make necessary changes in the config.xml and place it to the same folder as the script.</li>
	<li>When setting up a native SCOM SMTP notification channel, there are only 2 authentication methods you can choose from: <strong>Anonymous</strong> and <strong>Windows Integrated</strong>. This script can be configured to use a separate user name and password to authenticate to SMTP so <strong>external SMTP servers such as gmail can be used.</strong> This eliminates the needs of having to use Exchange server for mail relay.</li>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2012/08/image1.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/08/image_thumb1.png" alt="image" width="283" height="148" border="0" /></a>
<ul>
	<li>In the original script, the alert resolution state is updated once the script has processed the alert. This feature can now be turned off. – Because we don’t always want to update the resolution state.</li>
	<li>Additionally, I have made the email body look a bit tidier, the layout now looks more similar to the alert view in the SCOM consoles:</li>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2012/08/image2.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/08/image_thumb2.png" alt="image" width="580" height="1163" border="0" /></a>

<strong>How to setup command subscription?</strong>

The command subscription setup is very similar to the previous version. However, for the new script, the web console link also needs to be passed into the script. I remove the section to generate web console link for the alert because the web console link can be passed into the script as a parameter natively by SCOM, why generate it again in the script when it’s already available natively?

Assuming the script is located on D:\Script folder of your RMS / MS. here’s how you set it up:

<a href="http://blog.tyang.org/wp-content/uploads/2012/08/image3.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/08/image_thumb3.png" alt="image" width="580" height="208" border="0" /></a>

From zip file that you can download from the link at the end of this post, you’ll find these files:

<a href="http://blog.tyang.org/wp-content/uploads/2012/08/image4.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/08/image_thumb4.png" alt="image" width="580" height="242" border="0" /></a>

It contains:
<ul>
	<li>The version 2 of the <strong>SCOMEnhancedEmailNotification.ps1</strong> script.</li>
	<li><strong>config.xml</strong> that you will need to modify to suit your needs</li>
	<li><strong>XML explaination.xlsx</strong> – explains each tag of the config.xml in details.</li>
	<li><strong>Command Channel Setup.txt</strong> – what to enter when setting up command channel. (assuming the script is located at D:\Script). you can simply change the location of the script and email addresses, then copy &amp; paste each field.</li>
	<li><strong>XML Sample</strong> – contains 3 config.xml samples. one for each SMTP authentication method (Anonymous, Integrated and Credential).</li>
</ul>
The notifications subscriber and subscriptions are setup exactly the same way as the original version of the script. you can simply refer to the <a href="http://blog.tyang.org/2010/07/19/enhanced-scom-alerts-notification-emails/">original blog post</a>.

<a href="http://blog.tyang.org/wp-content/uploads/2012/09/SCOMEnhancedEmailNotification.V2.1.rar">DOWNLOAD HERE</a>.