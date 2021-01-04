---
id: 715
title: Error 80041001 in InventoryAgent.log after mof files modifications
date: 2011-10-09T16:39:23+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=715
permalink: /2011/10/09/error-80041001-in-inventoryagent-log-after-mof-files-modifications/
categories:
  - SCCM
tags:
  - Hardware Inventory
  - mof files
  - RegKeyToMOF
  - SCCM
---
I’ve been playing with SCCM mof files this weekend. After I’ve extended configuration.mof and sms_def.mof files to inventory a registry key during hardware inventory, I noticed below error logged in InventoryAgent.log on SCCM client:

Unknown error encountered processing an instance of class &lt;name of the WMI class&gt;: 80041001

<a href="http://blog.tyang.org/wp-content/uploads/2011/10/image10.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/10/image_thumb10.png" alt="image" width="580" height="95" border="0" /></a>

I checked the SCCM client, the WMI class was created correctly, but the inventory data was not loaded in the SCCM database therefore I could not view it in Resource Manager.

After gone through both configuration.mof and sms_def.mof many times made sure they are 100% correct, I found this error is actually caused by a bug in SCCM 2007.

Because the SCCM client I’m using for testing is a Windows 2008 R2 machine (therefore 64 bit) and the issue with 64 bit client is documented <a title="KB2617545" href="http://support.microsoft.com/kb/2617545"><strong>here</strong></a>.

Also, while I was playing with mof files, I found this awesome tool called <strong>RegKeyToMOF</strong>. The current version is v3.0 and can be found <a title="RegKeyToMOF v3.0 download" href="http://myitforum.com/cs2/files/folders/proddocs/entry152945.aspx"><strong>here</strong></a>. It supports SMS 2003, SCCM 2007 and SCCM 2012 Beta 2.

it automatically generates mof extensions for you when you select the registry key that you want to inventory:

<a href="http://blog.tyang.org/wp-content/uploads/2011/10/image11.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/10/image_thumb11.png" alt="image" width="580" height="366" border="0" /></a>

If you are planning to use this tool to generate the configuration.mof and sms_def.mof extensions, please make sure you tick "<strong>Enable 64bits (for Regkeys not written in Wow6432Node)</strong>" if you have 64-bit SCCM clients in your environment (nowadays, I can’t imagine that you don’t!). This is also what above mentioned KB article suggested.