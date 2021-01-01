---
id: 75
title: 'PowerShell Script: Test-SMTP'
date: 2010-07-05T13:46:34+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/2010/07/05/powershell-script-test-smtp/
permalink: /2010/07/05/powershell-script-test-smtp/
categories:
  - PowerShell
tags:
  - PowerShell
  - SMTP
---
I wrote <a href="http://blog.tyang.org/wp-content/uploads/2010/07/Test-SMTP.zip">this simple script</a> last week to test SMTP server by sending a testing email.

Usage: .\Test-SMTP.PS1 -smtp smtp.xxxx.com -port 25 -from test@xxxx.com -to <a href="mailto:recipient@xxxx.com">recipient@xxxx.com</a>

If the email is successfully, the recipient will receive an email similar to this:

<a href="http://blog.tyang.org/wp-content/uploads/2010/07/image.png"><img style="border-width: 0px;" src="http://blog.tyang.org/wp-content/uploads/2010/07/image_thumb.png" border="0" alt="image" width="452" height="316" /></a>

The email contains the following information:
<ol>
	<li>Originating Computer: Where the script was run from</li>
	<li>SMTP Server Address: The SMTP server that sent this email</li>
	<li>SMTP Server Port: default SMTP port is 25</li>
	<li>Return (sender) address: This does not have to be a real address</li>
	<li>Recipient: Where the email is sent to.</li>
</ol>