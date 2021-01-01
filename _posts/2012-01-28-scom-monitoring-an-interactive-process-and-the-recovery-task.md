---
id: 946
title: 'SCOM: Monitoring an Interactive Process and The Recovery Task'
date: 2012-01-28T08:37:52+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=946
permalink: /2012/01/28/scom-monitoring-an-interactive-process-and-the-recovery-task/
categories:
  - SCOM
tags:
  - MP Authoring
  - SCOM
---
Recently I’m working on a management pack for a series of apps for a business unit of my employer. There is a large number of processes that I need to monitor and they run interactively on the console session. Auto Admin Logon is enabled on these servers, when the server starts up, it automatically logged on using the account configured and the the interactive processes are automatically started.

Setting up monitors for these processes is easy. However, I went a step further and created a generic write action module to be used as recovery task that restarts the process interactively on the console session.

There is one pre-requisite for the recovery task: I had to use PsExec to launch the process on console session. PsExec can be downloaded here: <a href="http://technet.microsoft.com/en-us/sysinternals/bb897553">http://technet.microsoft.com/en-us/sysinternals/bb897553</a>. PsExec needs to be copied locally to the computers that are being monitored.

I’ll now use use an example to go through how I setup the monitor, write action module and recovery task for notepad.exe

<strong><span style="color: #ff0000;">01.</span></strong> First of all, I created a class and its discovery to target my test machine “Client01”

<strong><span style="color: #ff0000;">02.</span></strong> Added “Microsoft.SystemCenter.ProcessMonitoring.Library” as a reference in my MP.

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image40.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: block; float: none; margin-left: auto; margin-right: auto; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb40.png" alt="image" width="481" height="477" border="0" /></a>

<span style="color: #ff0000;">03.</span> Created a process monitor for notepad.exe
<ul>
<ul>
	<li><strong>Monitor Type:</strong> Process Instance Count Monitor Type (from “Microsoft.SystemCenter.ProcessMonitoring.Library”)</li>
	<li><strong>Monitor Configuration:</strong></li>
	<li></li>
</ul>
</ul>
<table width="600" border="0" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td valign="top" width="444">ProcessName</td>
<td valign="top" width="156">notepad.exe</td>
</tr>
<tr>
<td valign="top" width="444">Frequency</td>
<td valign="top" width="156">60</td>
</tr>
<tr>
<td valign="top" width="444">MinInstanceCount</td>
<td valign="top" width="156">1</td>
</tr>
<tr>
<td valign="top" width="444">MaxInstanceCount</td>
<td valign="top" width="156">1</td>
</tr>
<tr>
<td valign="top" width="444">InstanceCountOutOfRangeTimeThresholdInSeconds</td>
<td valign="top" width="156">5</td>
</tr>
</tbody>
</table>
<ul>
	<li><span style="color: #ff0000; font-size: small;"><strong>Note:</strong></span> While I was setting up the monitor, I realised the process name is case sensitive. Also, Frequency is in seconds</li>
	<li><a href="http://blog.tyang.org/wp-content/uploads/2012/01/image41.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: block; float: none; margin-left: auto; margin-right: auto; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb41.png" alt="image" width="550" height="273" border="0" /></a></li>
	<li>This is pretty much the same as using the Process Monitoring template from from the SCOM operations console (under Authoring Pane) – Except I used my own class rather than targeting to a group. Below is from the process monitoring wizard:</li>
	<li><a href="http://blog.tyang.org/wp-content/uploads/2012/01/image42.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: block; float: none; margin-left: auto; margin-right: auto; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb42.png" alt="image" width="537" height="395" border="0" /></a></li>
</ul>
<strong><span style="color: #ff0000;">04.</span></strong> Now once I import the MP into my SCOM management group, I can verify it is working (from health explorer):

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image43.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: block; float: none; margin-left: auto; margin-right: auto; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb43.png" alt="image" width="580" height="474" border="0" /></a>
<p align="left"><strong><span style="color: #ff0000;">05.</span></strong> Because the way this monitor works, it is only healthy when the process count is in between MinInstanceCount and MaxInstanceCount (both set to 1 in this case). So the monitor’s health turns to Errorif there are say 2 instance of notepad running. Therefore I need to run a diagnostic task to determine how many instances are actually running because I only want to run the recovery task when the instance count is less than 1. I created a diagnostic task to run when the monitor’s health is in Error state. This diagnostic has only 1 action module: <strong>“Microsoft.Windows.ScriptPropertyBagProbe”:</strong></p>
<p align="left"><a href="http://blog.tyang.org/wp-content/uploads/2012/01/image44.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: block; float: none; margin-left: auto; margin-right: auto; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb44.png" alt="image" width="544" height="535" border="0" /></a></p>

<ul>
<ul>
	<li>
<div align="left"><strong>Module configuration:</strong></div></li>
	<li>
<table width="600" border="0" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td valign="top" width="300">ScriptName</td>
<td valign="top" width="300">CheckProcessDiagnostic.vbs</td>
</tr>
<tr>
<td valign="top" width="300">Arguments</td>
<td valign="top" width="300">notepad.exe</td>
</tr>
<tr>
<td valign="top" width="300">ScriptBody</td>
<td valign="top" width="300">refer to the vbscript below</td>
</tr>
<tr>
<td valign="top" width="300">TimeoutSeconds</td>
<td valign="top" width="300">60</td>
</tr>
</tbody>
</table>
</li>
	<li>
<div align="left">Here’s the script:</div></li>
</ul>
</ul>
[sourcecode language="vbnet"]
'==========================================
' AUTHOR:            Tao Yang
' Script Name:        CheckProcessDiagnostic.vbs
' DATE:                27/01/2012
' Version:            1.0
' COMMENT:            - Script to check process state.
'                    - Used for OpsMgr Management Pack diagnostic tasks.
'==========================================
ProcessName = WScript.Arguments.Item(0)
Set oAPI = CreateObject(&quot;MOM.ScriptAPI&quot;)
Set oBag = oAPI.CreatePropertyBag()
WMIQuery = &quot;Select * From Win32_process WHERE name = '&quot; + ProcessName + &quot;'&quot;
Set objWMIService = GetObject(&quot;winmgmts:\\.\root\cimv2&quot;)
Set colProcesses = objWMIService.ExecQuery (WMIQuery)
Call oBag.AddValue(&quot;ProcessName&quot;,ProcessName)
If colProcesses.count &amp;lt; 1 Then
Call oBag.AddValue(&quot;Result&quot;,&quot;Positive&quot;)
Else
Call oBag.AddValue(&quot;Result&quot;,&quot;Negative&quot;)
End If
oAPI.Return(oBag)
[/sourcecode]
<ul>
	<li>This script returns a property bag variable“Result”. The value of “Result” is “Positive” if there is less than 1 instance of notepad.exe running. otherwise, the value is “Negative”. I will use the the value of “Result” to determine whether to run the recovery task or not by using a condition detection module in recovery task later.</li>
</ul>
<strong><span style="color: #ff0000;">06.</span></strong> Create a Write Actions module for the recovery task. I’m creating a separate module for this so I can use it in recovery tasks of multiple monitors.
<ul>
<ul>
	<li><a href="http://blog.tyang.org/wp-content/uploads/2012/01/image45.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: block; float: none; margin-left: auto; margin-right: auto; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb45.png" alt="image" width="522" height="514" border="0" /></a></li>
	<li>Member Module: <strong>“Microsoft.Windows.PowerShellWriteAction”</strong></li>
	<li><a href="http://blog.tyang.org/wp-content/uploads/2012/01/image46.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb46.png" alt="image" width="545" height="536" border="0" /></a></li>
	<li><strong>Module Configuration:</strong></li>
	<li><a href="http://blog.tyang.org/wp-content/uploads/2012/01/image47.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb47.png" alt="image" width="719" height="683" border="0" /></a></li>
	<li>While editing this module, Add below secion between &lt;/ScriptBody&gt; and &lt;/Configuration&gt;:</li>
</ul>
</ul>
<span style="color: #ff0000;">&lt;Parameters&gt;
&lt;Parameter&gt;
&lt;Name&gt;PsExecPath&lt;/Name&gt;
&lt;Value&gt;$Config/PsExecPath$&lt;/Value&gt;
&lt;/Parameter&gt;
&lt;Parameter&gt;
&lt;Name&gt;PathToExe&lt;/Name&gt;
&lt;Value&gt;$Config/PathToExe$&lt;/Value&gt;
&lt;/Parameter&gt;
&lt;Parameter&gt;
&lt;Name&gt;Context&lt;/Name&gt;
&lt;Value&gt;$Config/Context$&lt;/Value&gt;
&lt;/Parameter&gt;
&lt;Parameter&gt;
&lt;Name&gt;Arguments&lt;/Name&gt;
&lt;Value&gt;$Config/Arguments$&lt;/Value&gt;
&lt;/Parameter&gt;
&lt;/Parameters&gt;
&lt;TimeoutSeconds&gt;$Config/TimeoutSeconds$&lt;/TimeoutSeconds&gt;</span>

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image48.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb48.png" alt="image" width="545" height="385" border="0" /></a>
Place the PowerShell script below between &lt;ScriptBody&gt;&lt;/ScriptBody&gt; section:

[sourcecode language="powershell"]
#=================================================
# AUTHOR:  Tao Yang
# DATE:    16/01/2012
# Version: 1.0
# COMMENT: Start a exe on console session under LocalSystem Context
#=================================================

param([string]$PsExecPath, [string]$PathToExe, [string]$Context, [string]$Arguments)
# $Context should have only 2 possible values: &quot;System&quot; or &quot;User&quot;. &quot;User&quot; needs Auto Admin Logon Enabled
Function Get-ConsoleSessionInfo
{
$results = Query Session
$ConsoleSession = $results | select-string &quot;console\s+(\w+)\s+(\d+)\s+(\w+)&quot;
if ($ConsoleSession)
{
$UserName = $ConsoleSession.Matches[0].groups[1].value
$SessionID = $ConsoleSession.Matches[0].groups[2].value
$State = $ConsoleSession.Matches[0].groups[3].value
$objConsoleSession = New-Object psobject
Add-Member -InputObject $objConsoleSession -Name &quot;UserName&quot; -Value $UserName -MemberType NoteProperty
Add-Member -InputObject $objConsoleSession -Name &quot;SessionID&quot; -Value $SessionID -MemberType NoteProperty
Add-Member -InputObject $objConsoleSession -Name &quot;State&quot; -Value $State -MemberType NoteProperty
} else { $objConsoleSession = $null }
Return $objConsoleSession
}

$Mode = $null
#Determine UserID
If ($Context -ieq &quot;User&quot;)
{
$strUserName = $null
$DefaultPassword = $null
#detect if auto admin is enabled, if so, retrieve username and password from registry
$WinlogonRegKey = get-itemproperty &quot;HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\&quot;
If ($WinlogonRegKey.AutoAdminLogon = &quot;1&quot;)
{
$DefaultUserName = $WinlogonRegKey.DefaultUserName
$DefaultDomainName = $WinlogonRegKey.DefaultDomainName
$DefaultPassword = $WinlogonRegKey.DefaultPassword
$strUserName = &quot;$DefaultDomainName`\$DefaultUserName&quot;
}

If ($strUserName -and $DefaultPassword)
{
$Mode = &quot;User&quot;
} else {
Write-Error &quot;Owner variable set to `&quot;User`&quot; but Auto Admin Logon is not configured!&quot;
}
} elseif ($Context -ieq &quot;System&quot;) {
$Mode = &quot;System&quot;
} else {
Write-Error &quot;Incorrect Owner variable. it can only be `&quot;User`&quot; or `&quot;System`&quot;&quot;
}

#$thisScript = Split-Path $myInvocation.MyCommand.Path -Leaf
#$scriptRoot = Split-Path(Resolve-Path $myInvocation.MyCommand.Path)
#$PsExecPath = Join-Path $scriptRoot &quot;PsExec.exe&quot;
If (!(Test-Path $PsExecPath))
{
Write-Error &quot;Unable to locate PsExec.exe in $scriptRoot. Please make sure it is located in this directory!&quot;
} else {
#Get Console Session ID
$ConsoleSessionID = (Get-ConsoleSessionInfo).SessionID
if ($ConsoleSessionID)
{
If ($Mode -eq &quot;User&quot;)
{
$strCmd = &quot;$PsExecPath -accepteula -i $ConsoleSessionID -d -u $strUsername -p $DefaultPassword $PathToExe $arguments&quot;
Write-Host &quot;Executing $strCmd`...&quot;
Invoke-Expression $strCmd
} elseif ($Mode -eq &quot;System&quot;) {
$strCmd = &quot;$PsExecPath -accepteula -i $ConsoleSessionID -d -s $PathToExe $arguments&quot;
#run app under LOCALSYSTEM context
Write-Host &quot;Executing $strCmd`...&quot;
Invoke-Expression $strCmd
}
} else {
Write-Error &quot;No one is currently logged on to the console session at the moment.&quot;
}
}
[/sourcecode]

<span style="color: #ff0000;"><strong>Note:</strong></span>this PowerShell script uses command “query session” to detect the session ID of the console session.

<span style="color: #ff0000;"><strong>Note:</strong></span> When you save the configuration of this module, please <strong>ignore</strong> this error:

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image49.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb49.png" alt="image" width="445" height="206" border="0" /></a>

Add the following item under Configuration Schema tab:

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image50.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb50.png" alt="image" width="545" height="547" border="0" /></a>

<strong><span style="color: #ff0000;">Note: </span></strong>Make sure “TimeoutSeconds” type is set to “Integer” and others are set to “String”

I also defined “TimeoutSeconds” as an overridable paramter:

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image51.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb51.png" alt="image" width="545" height="234" border="0" /></a>

Finally, set the Accessibility to Public (so it can be used in other management pack once this management pack is sealed"):

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image52.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb52.png" alt="image" width="545" height="175" border="0" /></a>

<strong><span style="color: #ff0000;">07.</span></strong> Create a recovery task to run after Diagnostic Task that I created from the step 5.

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image53.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: block; float: none; margin-left: auto; margin-right: auto; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb53.png" alt="image" width="479" height="475" border="0" /></a>
<ul>
	<li>This recovery task has 2 modules: a condition detection module (System.ExpressionFilter) and an Actions module (From the Write Actions module I created from Step 6)</li>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image54.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: block; float: none; margin-left: auto; margin-right: auto; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb54.png" alt="image" width="525" height="523" border="0" /></a>
<ul>
<ul>
	<li><strong>Condition Detection Module (System.ExpressionFilter):</strong></li>
	<li><a href="http://blog.tyang.org/wp-content/uploads/2012/01/image55.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb55.png" alt="image" width="593" height="562" border="0" /></a></li>
	<li>Click Edit and add below:</li>
</ul>
</ul>
<span style="color: #ff0000;">&lt;Expression&gt;
&lt;SimpleExpression&gt;
&lt;ValueExpression&gt;
&lt;XPathQuery Type="String"&gt;Diagnostic/DataItem/Property[@Name='Result']&lt;/XPathQuery&gt;
&lt;/ValueExpression&gt;
&lt;Operator&gt;Equal&lt;/Operator&gt;
&lt;ValueExpression&gt;
&lt;Value Type="String"&gt;Positive&lt;/Value&gt;
&lt;/ValueExpression&gt;
&lt;/SimpleExpression&gt;
&lt;/Expression&gt;</span>

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image56.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb56.png" alt="image" width="545" height="184" border="0" /></a>

<strong>Actions Module (Module Type from the write action module created in Step 6)</strong>
<table width="600" border="0" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td valign="top" width="143">PsExecPath</td>
<td valign="top" width="457">Path to PsExec.exe on the target computer</td>
</tr>
<tr>
<td valign="top" width="143">PathToExe</td>
<td valign="top" width="457">The executable that you want PsExec to run</td>
</tr>
<tr>
<td valign="top" width="143">Context</td>
<td valign="top" width="457">2 Possible values: “User” or “System”</td>
</tr>
<tr>
<td valign="top" width="143">Argument</td>
<td valign="top" width="457">arguments for the executable that PsExec is executing</td>
</tr>
<tr>
<td valign="top" width="143">TimeoutSeconds</td>
<td valign="top" width="457"></td>
</tr>
</tbody>
</table>
<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image57.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: block; float: none; margin-left: auto; margin-right: auto; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb57.png" alt="image" width="545" height="331" border="0" /></a>

<strong><span style="color: #ff0000;">Note:</span></strong> Regarding to the Context variable, I designed the script to launch PsExec to execute the executable either under LOCALSYSTEM (  with –s  operator in PsExec) or under the user that’s configured for Auto Admin Logon (with –u &lt;username&gt; and –p &lt;password&gt; operators in PsExec). Because when Auto Admin Logon is enabled, the default username and password is stored in the registry key (<strong>HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon</strong>). If “Context” is set to “User”, the script reads the username and password from registry and pass them into PsExec. So, if Auto Admin Logon is not configured, the script won’t work if “Context” is set to “User”

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image58.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb58.png" alt="image" width="545" height="259" border="0" /></a>

<strong><span style="color: #ff0000;">Note:</span></strong> In this example, the recovery task simply launch notepad.exe on the console session. I can also tell notepad to open a txt file if I add the path of the txt file to “Arguments”.

<strong><span style="color: #ff0000;">Note:</span></strong> This recovery task will error out if no one has logged on to the console session of the target computer.

Now, everything is setup, time to put it to test.

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image59.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb59.png" alt="image" width="545" height="482" border="0" /></a>

From screen capture below, I can see the monitor’s health became Error at 10:44pm 27/01/2012. After the Diagnostic task determined there is no notepad.exe running, the recovery task kicks in, at 10:45pm, it launched notepad.exe on console session (session ID 2). The PID of notepad.exe is 4000.

Now, when I go to the target computer, notepad is launched on the console session and I can easily get the details of notepad.exe process:

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/notepad.png"><img class="alignleft  wp-image-956" title="notepad" src="http://blog.tyang.org/wp-content/uploads/2012/01/notepad-300x252.png" alt="" width="498" height="335" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image60.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb60.png" alt="image" width="545" height="464" border="0" /></a>

You can see from above screen capture, notepad.exe was started at the same time when the recovery task ran, the session ID is 2, Owner is the account configured for Auto Admin Logon and process ID is same as the output from PsExec. Therefore, this instance of notepad.exe is the one started by the recovery task!

I’ve attached the 2 scripts used in Diagnostic and recovery tasks below. as well as my sample unsealed MP.

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/Custom.Interactive.Process.Monitoring.zip">Download From Here</a>

Please feel free to contact me if you have any questions or suggestions.