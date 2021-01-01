---
id: 85
title: Broken SCOM Web Console URLs?
date: 2010-07-06T15:57:13+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=85
permalink: /2010/07/06/broken-scom-web-console-urls/
categories:
  - SCOM
tags:
  - SCOM
  - TMG
  - URL Encoding
  - Web Console
---
I come across a situation where when i click on the web console URL from a SCOM notification email such as this one: <span style="color: #ff0000;">http://&lt;SCOM Web Server&gt;/default.aspx?DisplayMode=Pivot&amp;AlertID=%7b07aac5b0-4cf8-411f-b5a0-cb0075dc0f31%7d</span>

I get a HTTP 500 error:

<a href="http://blog.tyang.org/wp-content/uploads/2010/07/image3.png"><img style="border: 0px;" src="http://blog.tyang.org/wp-content/uploads/2010/07/image_thumb3.png" border="0" alt="image" width="580" height="525" /></a>

I had to change the URL from <span style="color: #ff0000;">http://&lt;SCOM Web Server&gt;/default.aspx?DisplayMode=Pivot&amp;AlertID=<strong><span style="color: #008000; font-size: medium;">%7b</span></strong>07aac5b0-4cf8-411f-b5a0-cb0075dc0f31</span><strong><span style="color: #008000; font-size: medium;">%7d</span></strong> to <span style="color: #ff0000;">http://&lt;SCOM Web Server&gt;/default.aspx?DisplayMode=Pivot&amp;AlertID=<strong><span style="color: #008000; font-size: medium;">{</span></strong>07aac5b0-4cf8-411f-b5a0-cb0075dc0f31</span><strong><span style="color: #008000; font-size: medium;">}</span></strong> to make it work. It’s quiet painful as <strong>%7b</strong> and<strong> %7d</strong> comes as a part of SCOM <strong>WebConsole Link</strong> variable…

For this particular environment, I found out it was caused by Forefront TMG server was blocking encoded URLs for this website.

After unticking <strong>Verify normalization</strong> and <strong>Block high bit characters</strong> in the TMG rule, the encoded URL started working!

<a href="http://blog.tyang.org/wp-content/uploads/2010/07/image4.png"><img style="border: 0px;" src="http://blog.tyang.org/wp-content/uploads/2010/07/image_thumb4.png" border="0" alt="image" width="452" height="500" /></a>