---
id: 108
title: 'PowerShell Script: Mass-Mailer'
date: 2010-07-08T16:41:40+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/2010/07/08/powershell-script-mass-mailer/
permalink: /2010/07/08/powershell-script-mass-mailer/
categories:
  - PowerShell
tags:
  - Emails
  - PowerShell
  - SMTP
---
Today a colleague asked me to write a script to send out a email to a large group of people but have the phrase "Dear &lt;person’s name"&gt;" in the beginning of email body.

I quickly wrote <a href="https://blog.tyang.org/wp-content/uploads/2010/07/Mass-Mailer.zip">this script</a>. Here are the steps you need to take before executing it:

1. Zip and place the Mass-Mailer folder somewhere on your computer. There are 3 files in the folder:

<a href="https://blog.tyang.org/wp-content/uploads/2010/07/image6.png"><img style="border: 0px;" src="https://blog.tyang.org/wp-content/uploads/2010/07/image_thumb6.png" border="0" alt="image" width="281" height="162" /></a>

{:start="2"}
2. in Mass-Mailer.ps1 file, modify the highlighted section ( and remove the "&lt;" and "&gt;"brackets):

<a href="https://blog.tyang.org/wp-content/uploads/2010/07/image7.png"><img style="border-width: 0px;" src="https://blog.tyang.org/wp-content/uploads/2010/07/image_thumb7.png" border="0" alt="image" width="580" height="323" /></a>

{:start="3"}
3. Open <strong>recipientsList.txt</strong> and enter recipients name and emails, one recipient per line with format Name<strong>;</strong>Email (i.e. <strong>John Smith;John.Smith@xxx.com</strong>)

<a href="https://blog.tyang.org/wp-content/uploads/2010/07/image8.png"><img style="border-width: 0px;" src="https://blog.tyang.org/wp-content/uploads/2010/07/image_thumb8.png" border="0" alt="image" width="506" height="134" /></a>

{:start="4"}
4. Write the email in<strong> EmailBody.txt</strong>

<a href="https://blog.tyang.org/wp-content/uploads/2010/07/image9.png"><img style="border-width: 0px;" src="https://blog.tyang.org/wp-content/uploads/2010/07/image_thumb9.png" border="0" alt="image" width="490" height="146" /></a>

{:start="5"}
5. Execute Mass-Mailer.PS1

The email is sent to each recipient individually. it looks like:

<a href="https://blog.tyang.org/wp-content/uploads/2010/07/image10.png"><img style="border-width: 0px;" src="https://blog.tyang.org/wp-content/uploads/2010/07/image_thumb10.png" border="0" alt="image" width="499" height="237" /></a>