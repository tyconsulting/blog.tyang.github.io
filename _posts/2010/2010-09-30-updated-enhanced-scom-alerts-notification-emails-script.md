---
id: 277
title: 'Updated: Enhanced SCOM Alerts Notification Emails script'
date: 2010-09-30T17:24:46+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=277
permalink: /2010/09/30/updated-enhanced-scom-alerts-notification-emails-script/
categories:
  - PowerShell
  - SCOM
tags:
  - Email Notifications
  - PowerShell
  - SCOM
  - Update
---
<a href="http://blog.tyang.org/wp-content/uploads/2010/09/update.jpg"><img class="alignleft size-thumbnail wp-image-278" title="update" src="http://blog.tyang.org/wp-content/uploads/2010/09/update-150x150.jpg" alt="" width="150" height="150" /></a>I have previously posted the <a href="http://blog.tyang.org/2010/07/19/enhanced-scom-alerts-notification-emails/">Enhanced SCOM Alerts Notification email scripts</a> back in July 2010.

I’d like to thank everyone who have tested it and provided feedbacks. You made me aware there are few issues and bugs with the script. Since I have just resigned and my new job won’t start in few weeks time, I have spent the last couple of days updating the script.

<strong>This is what I’ve done:</strong>

<strong>1. Removed GetNetbiosName function</strong>
<ul>
	<li>Few people advised there are often this function running into errors.  I realised I originally wrote this function because one of my previous employers required the SCOM agent NetBios name in the email. but since SCOM is designed to monitor applications and objects rather than individual servers, I don’t see any reasons to include Computer NetBIOS name in the email. For sure it will often fail if the alert source is from a AD Site or distributed application, etc.</li>
	<li></li>
	<li>Instead, I’ve added Alert Source, Path and Principal name in the email.</li>
	<li></li>
	<li>P.S. I’ve also rewritten the function, trying to fix the bug. I’ve still left the</li>
	<li>function in the script (but commented out). Feel free to use it somewhere else.</li>
</ul>
<strong>2. Reformatted HTML email body</strong>
<ul>
	<li>I have changed the format of few items from &lt;h3&gt; (header 3) to just &lt;b&gt; (bold) to make the email more readable.</li>
	<li></li>
	<li>I also made the alert severity more visual: Critical is displayed in <span style="color: #ff0000;">Red</span>, Warning displayed in <span style="color: #928107;">Yellow</span> and information displayed in <span style="color: #0000ff;">Blue</span> (if you subscribe informational alerts)</li>
	<li><a href="http://blog.tyang.org/wp-content/uploads/2010/09/image15.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2010/09/image_thumb15.png" border="0" alt="image" width="609" height="332" /></a></li>
</ul>
<strong>3. Added error handling for $rule.GetKnowledgeArticle() as sometimes there is no knowledge article.</strong>
<ul>
	<li>I often get error emails because GetKnowledgeArticle() method returns error. This is because not all rules and monitors will have knowledge articles associated to them.  I have added few lines of code to handle errors occurred when calling this method. basically if calling this method failed, it will remove the entry from $error.</li>
</ul>
<strong>4. Fixed the problem with unconverted Unicode characters (i.e. %002d)  displayed in emails.</strong>
<ul>
	<li>Before:</li>
	<li><a href="http://blog.tyang.org/wp-content/uploads/2010/09/image16.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2010/09/image_thumb16.png" border="0" alt="image" width="610" height="49" /></a></li>
	<li>After:</li>
	<li><a href="http://blog.tyang.org/wp-content/uploads/2010/09/image17.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2010/09/image_thumb17.png" border="0" alt="image" width="606" height="39" /></a></li>
</ul>
I have also updated the <a href="http://blog.tyang.org/2010/07/19/enhanced-scom-alerts-notification-emails/">original post</a>, so this script can still be downloaded from the download link on the original post.