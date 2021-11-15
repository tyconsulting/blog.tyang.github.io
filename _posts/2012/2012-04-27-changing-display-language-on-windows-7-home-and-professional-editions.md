---
id: 1119
title: Changing Display Language on Windows 7 Home and Professional Editions
date: 2012-04-27T19:00:14+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=1119
permalink: /2012/04/27/changing-display-language-on-windows-7-home-and-professional-editions/
categories:
  - Windows
tags:
  - Language
  - Windows
---
I bought a laptop for other family members yesterday, it comes with Windows 7 Home Premium. I needed to change the display language from English to Chinese because the main user of this laptop does not speak English.

I thought it was a no brainer as I’ve done it before, all I had to do was to load another language pack in "Regional and Language" in Control Panel. However, I was wrong. apparently this function is available in Windows 7 Ultimate and Enterprise editions.

I didn’t really want to use <a href="http://windows.microsoft.com/en-AU/windows7/products/windows-anytime-upgrade">Windows Anytime Upgrade</a> to upgrade it to Ultimate just so I can change the language. Lucky I found this post: <a href="http://mark.ossdl.de/2009/08/change-mui-language-pack-in-windows-7-home-and-professional/">http://mark.ossdl.de/2009/08/change-mui-language-pack-in-windows-7-home-and-professional/</a>

So below is what I’ve done:
<ol>
	<li>Download Windows 7 Service Pack 1 language pack (Because the laptop comes with Windows 7 SP1, I had RTM version of the language pack but it didn’t work.) – I downloaded the entire ISO from my TechNet subscription, but there are many blog posts around with the direct link to Windows Update for each individual language (such as this one: <a href="http://www.technize.net/windows-7-sp1-language-packs-direct-download-links-kb2483139/">http://www.technize.net/windows-7-sp1-language-packs-direct-download-links-kb2483139/</a>)</li>
	<li>Extracted the downloaded ISO (from TechNet subscription) to C:\Apps\langpacks</li>
	<li>in Command prompt:</li>
<ol>
	<li>dism /online /add-package /packagepath:C:\Apps\langpacks\zh-cn\lp.cab</li>
	<li>bcdedit /set {current} locale zh-cn</li>
	<li>bcdboot %WinDir% /l zh-cn</li>
</ol>
	<li>Backed up and deleted <strong>HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\MUI\UILanguages\en-US</strong></li>
	<li>Reboot</li>
</ol>
<span style="color: #ff0000; font-size: medium;"><strong>Note</strong></span>: if there were any windows updates that were pending to be installed, the install may fail after the language was changed. I had to run <strong>wuauclt /detectnow</strong> so Windows Update agent detects the updates for different language.