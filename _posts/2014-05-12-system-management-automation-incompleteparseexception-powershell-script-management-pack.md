---
id: 2639
title: System.Management.Automation.IncompleteParseException for a PowerShell script from my Management Pack
date: 2014-05-12T19:22:05+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=2639
permalink: /2014/05/12/system-management-automation-incompleteparseexception-powershell-script-management-pack/
categories:
  - SCOM
tags:
  - MP Authoring
  - SCOM
---
I’m currently working on a management pack that I’m hoping to be released to public very soon. In one of the workflows in the MP, I got an error logged in the Operations Manager event log on the target agent:

<em><span style="color: #ff0000;">The PowerShell script failed with below exception </span></em>

<em><span style="color: #ff0000;">System.Management.Automation.IncompleteParseException: Missing closing '}' in statement block.
at System.Management.Automation.Runspaces.PipelineBase.Invoke(IEnumerable input)
at Microsoft.EnterpriseManagement.Common.PowerShell.RunspaceController.RunScript[T](String scriptName, String scriptBody, Dictionary`2 parameters, Object[] constructorArgs, IScriptDebug iScriptDebug, Boolean bSerializeOutput)</span></em>

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/image.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/05/image_thumb.png" alt="image" width="580" height="443" border="0" /></a>

Needless to say, the script runs just fine manually on the agent, so it is bug free. Took me a while to day to figure out what the issue is.

The script ended like this:

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML308e8f82.png"><img style="display: inline; border: 0px;" title="SNAGHTML308e8f82" src="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML308e8f82_thumb.png" alt="SNAGHTML308e8f82" width="580" height="194" border="0" /></a>

The last line is commented out, I’d uncomment it when test run it in powerShell prompt on an agent. When the MP is built in VSAE, it looked like this:

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML308f9e91.png"><img style="display: inline; border: 0px;" title="SNAGHTML308f9e91" src="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML308f9e91_thumb.png" alt="SNAGHTML308f9e91" width="580" height="150" border="0" /></a>

It’s on the same line as the CDATA close tag. After I started a new line at the end of the script, the MP started working:

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML30912afd.png"><img style="display: inline; border: 0px;" title="SNAGHTML30912afd" src="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML30912afd_thumb.png" alt="SNAGHTML30912afd" width="537" height="113" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML30923e81.png"><img style="display: inline; border: 0px;" title="SNAGHTML30923e81" src="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML30923e81_thumb.png" alt="SNAGHTML30923e81" width="580" height="129" border="0" /></a>

From now on, I’ll remember to end the PowerShell script with an empty line. Interestingly, another VBScript in the MP doesn’t have this issue…