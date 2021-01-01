---
id: 720
title: Clean Up Old Hardware Inventory Data
date: 2011-10-09T18:42:30+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=720
permalink: /2011/10/09/clean-up-old-hardware-inventory-data/
categories:
  - SCCM
tags:
  - Hardware Inventory
  - SCCM
  - VBScript
  - WMI
---
In SCCM, after removing WMI classes that are no longer required from <strong>configuration.mof</strong> and <strong>sms_def.mof</strong>, the inventory data still exists in few places.

If you decide to clean them up, MyITForum.com has a great <a href="http://www.myitforum.com/myITWiki/sccminv.ashx">WIKI page for SCCM hardware inventory</a> which talked about different ways to clean up hardware inventory data.

I have tried the free <a href="http://www.sccmexpert.com/site_sweeper.aspx">SiteSweeper</a> tool from SCCMExpert.com which was mentioned in the WIKI page. It’s easy to use and you can remove multiple classes from site database at once:

<a href="http://blog.tyang.org/wp-content/uploads/2011/10/image12.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/10/image_thumb12.png" alt="image" width="580" height="378" border="0" /></a>

Other than removing the data from site databases throughout the hierarchy, the WMI class which you defined in the configuration.mof still exists in the client. I didn’t bother to look further to find tools/utilities to delete WMI classes, but simple found a sample vbscript from MSDN to modify WMI classes, and modified a little bit:

<strong>DeleteWMIClass.vbs:</strong>
[sourcecode language="vbnet"]
wbemCimtypeString = 8             ' String datatype
Set objSWbemService = GetObject(&quot;Winmgmts:root\cimv2&quot;)
Set objClass = objSWbemService.Get()
objClass.Path_.Class = &quot;&lt;name of WMI class you wish to delete&gt;&quot;

' Remove the new class and instance from the repository
objClass.Delete_()
If Err &amp;lt;&amp;gt; 0 Then
WScript.Echo Err.Number &amp;amp; &quot;    &quot; &amp;amp; Err.Description
Else
WScript.Echo &quot;Delete succeeded&quot;
End If

' Release SwbemServices object
Set objSWbemService = Nothing
[/sourcecode]
To modify it, specify the WMI class you wish to delete on line 4. If the WMI class is not located in root\CIMV2 namespace, change line 2 as well.

I created a package in SCCM and advertised it to all systems.

<strong><span style="color: #ff0000;">Note</span></strong>: When you create the program, make sure you use the syntax “Cscript DeleteWMIClass.vbs” so the output is redirected to command prompt rather than a message box.