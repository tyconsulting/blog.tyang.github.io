---
id: 1745
title: '&ldquo;PowerShell Script failed to run&rdquo; alert in OpsMgr 2012'
date: 2013-03-04T14:43:24+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=1745
permalink: /2013/03/04/powershell-script-failed-to-run-alert-in-opsmgr-2012/
categories:
  - SCOM
tags:
  - MP Authoring
  - SCOM
---
Don’t you hate it when you’ve just released a piece of work to public and you found an issue with it? Well, this is what happened to me today. Yesterday and released the <a href="http://blog.tyang.org/2013/03/03/opsmgr-self-maintenance-management-pack/">OpsMgr Self Maintenance MP</a>, and today, I found an issue with the 2012 version.

After the MP is imported and the “OpsMgr 2012 Self Maintenance Operational Database LocalizedText Table Health Monitor” has been enabled via an override, you’ll soon get this alert from one of the management servers:

<span style="color: #ff0000;"><em>The PowerShell script failed with below exception</em></span>

<span style="color: #ff0000;"><em>System.Management.Automation.IncompleteParseException: White space is not allowed before the string terminator.
at System.Management.Automation.Runspaces.PipelineBase.Invoke(IEnumerable input)
at Microsoft.EnterpriseManagement.Common.PowerShell.RunspaceController.RunScript[T](String scriptName, String scriptBody, Dictionary`2 parameters, Object[] constructorArgs, IScriptDebug iScriptDebug, Boolean bSerializeOutput)</em></span>

<a href="http://blog.tyang.org/wp-content/uploads/2013/03/image.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/03/image_thumb.png" width="579" height="380" border="0" /></a>

After spent sometime troubleshooting, the issue is a bit stupid, but I’ll remember this in the future:

I wrote the 2007 version using 2007 R2 authoring console, thus no problems found. The 2012 version was written using Visual Studio Authoring Extension. In the particular probe action module used by the monitor type, this is what the raw code looks like:

<a href="http://blog.tyang.org/wp-content/uploads/2013/03/image1.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/03/image_thumb1.png" width="580" height="402" border="0" /></a>

when I pasted the script in the xml, I tried to format it using the Tab key.

This is what it should look like:

<a href="http://blog.tyang.org/wp-content/uploads/2013/03/image2.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/03/image_thumb2.png" width="580" height="457" border="0" /></a>

After I removed all the Tab spaces, the monitor started working.

I’ve changed the version number of the 2012 version to 1.0.0.1. I’ll update the MP from the original article from yesterday. For those who has already downloaded the MP, apologies. please download it again and the mp can be in-place upgraded to the new version.