---
id: 1432
title: Bug Fixes for SCOM Enhanced Email Notification Script V2
date: 2012-09-23T17:23:44+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=1432
permalink: /2012/09/23/bug-fixes-for-scom-enhanced-email-notification-script-v2/
categories:
  - SCOM
tags:
  - SCOM
---
Since I released the <a href="https://blog.tyang.org/2012/08/16/scom-enhanced-email-notification-script-version-2/">version 2 of the SCOM Enhanced Email Notification Script</a> last month, I’ve been made aware there are few bugs in the script.

First of all, apologies for not responding to these bugs sooner. I’ve been extremely busy at work and went away for a week attending Australia TechEd in Gold Coast. On top of all work related stuff, my 3-months old daughter occupies most of my spare time…

So, here are the 2 bugs that people in the community has found so far:
<ol>
	<li>agent name is not displayed in the email subject
<ul>
	<li>This is a bug in the script, the script has now been updated.</li>
</ul>
</li>
	<li>web console link in the email is displayed incorrectly (<a title="http://blogs.msdn.com/b/steverac/archive/2008/10/19/opsmgr-2007-command-line-notifications-and-alert-id.aspx" href="http://blogs.msdn.com/b/steverac/archive/2008/10/19/opsmgr-2007-command-line-notifications-and-alert-id.aspx">http://blogs.msdn.com/b/steverac/archive/2008/10/19/opsmgr-2007-command-line-notifications-and-alert-id.aspx</a>)
<ul>
	<li>Looks like it’s a known issue. The command channel needs to be updated.</li>
</ul>
</li>
</ol>
Thanks for Jon Tiffin and François LEFEBVRE for not only identified the bugs but also provided the fixes before I even had time to take a look.

The first bug is in the script itself and the second bug is related to the command line parameter for the command channel setup. I have updated the script and the command channel setup instruction. the updated package can be found <a href="https://blog.tyang.org/wp-content/uploads/2012/09/SCOMEnhancedEmailNotification.V2.1.rar">here</a>.

As always, if you’ve found any other issues, please let me know either via email or leave comments in my blog posts.