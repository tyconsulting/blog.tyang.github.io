---
id: 75
title: 'PowerShell Script: Test-SMTP'
date: 2010-07-05T13:46:34+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/2010/07/05/powershell-script-test-smtp/
permalink: /2010/07/05/powershell-script-test-smtp/
categories:
  - PowerShell
tags:
  - PowerShell
  - SMTP
---
I wrote <a href="https://blog.tyang.org/wp-content/uploads/2010/07/Test-SMTP.zip">this simple script</a> last week to test SMTP server by sending a testing email.

Usage:

```powershell
.\Test-SMTP.PS1 -smtp smtp.xxxx.com -port 25 -from test@xxxx.com -to recipient@xxxx.com
```
If the email is successfully, the recipient will receive an email similar to this:

<a href="https://blog.tyang.org/wp-content/uploads/2010/07/image.png"><img style="border-width: 0px;" src="https://blog.tyang.org/wp-content/uploads/2010/07/image_thumb.png" border="0" alt="image" width="452" height="316" /></a>

The email contains the following information:

* Originating Computer: Where the script was run from
* SMTP Server Address: The SMTP server that sent this email
* SMTP Server Port: default SMTP port is 25
* Return (sender) address: This does not have to be a real address
* Recipient: Where the email is sent to.
