---
id: 946
title: 'SCOM: Monitoring an Interactive Process and The Recovery Task'
date: 2012-01-28T08:37:52+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=946
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

1. First of all, I created a class and its discovery to target my test machine "Client01"

2. Added "Microsoft.SystemCenter.ProcessMonitoring.Library" as a reference in my MP.

![40](https://blog.tyang.org/wp-content/uploads/2012/01/image40.png)

{:start="3"}
3. Created a process monitor for notepad.exe

* **Monitor Type:** Process Instance Count Monitor Type (from "Microsoft.SystemCenter.ProcessMonitoring.Library")

* **Monitor Configuration:**

  * ProcessName: notepad.exe
  * Frequency: 60
  * MinInstanceCount: 1
  * MaxInstanceCount: 1
  * InstanceCountOutOfRangeTimeThresholdInSeconds: 5

	>**Note:** While I was setting up the monitor, I realised the process name is case sensitive. Also, Frequency is in seconds
	
	>![41](https://blog.tyang.org/wp-content/uploads/2012/01/image41.png)
	
	>This is pretty much the same as using the Process Monitoring template from from the SCOM operations console (under Authoring Pane) – Except I used my own class rather than targeting to a group. Below is from the process monitoring wizard:

	>![42](https://blog.tyang.org/wp-content/uploads/2012/01/image42.png)

{:start="4"}
4. Now once I import the MP into my SCOM management group, I can verify it is working (from health explorer):

![43](https://blog.tyang.org/wp-content/uploads/2012/01/image43.png)

{:start="5"}
5. Because the way this monitor works, it is only healthy when the process count is in between MinInstanceCount and MaxInstanceCount (both set to 1 in this case). So the monitor’s health turns to Errorif there are say 2 instance of notepad running. Therefore I need to run a diagnostic task to determine how many instances are actually running because I only want to run the recovery task when the instance count is less than 1. I created a diagnostic task to run when the monitor’s health is in Error state. This diagnostic has only 1 action module: **"Microsoft.Windows.ScriptPropertyBagProbe":**

![44](https://blog.tyang.org/wp-content/uploads/2012/01/image44.png)

  * **Module configuration:**
    * ScriptName: CheckProcessDiagnostic.vbs
    * Arguments: notepad.exe
    * ScriptBody: refer to the vbscript below
    * TimeoutSeconds: 60

Here’s the script:

```vb
'==========================================
' AUTHOR:            Tao Yang
' Script Name:        CheckProcessDiagnostic.vbs
' DATE:                27/01/2012
' Version:            1.0
' COMMENT:            - Script to check process state.
'                    - Used for OpsMgr Management Pack diagnostic tasks.
'==========================================
ProcessName = WScript.Arguments.Item(0)
Set oAPI = CreateObject("MOM.ScriptAPI")
Set oBag = oAPI.CreatePropertyBag()
WMIQuery = "Select * From Win32_process WHERE name = '" + ProcessName + "'"
Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")
Set colProcesses = objWMIService.ExecQuery (WMIQuery)
Call oBag.AddValue("ProcessName",ProcessName)
If colProcesses.count< 1 Then
  Call oBag.AddValue("Result","Positive")
Else
  Call oBag.AddValue("Result","Negative")
End If
oAPI.Return(oBag)
```

This script returns a property bag variable"Result". The value of "Result" is "Positive" if there is less than 1 instance of notepad.exe running. otherwise, the value is "Negative". I will use the the value of "Result" to determine whether to run the recovery task or not by using a condition detection module in recovery task later.

{:start="6"}
6. Create a Write Actions module for the recovery task. I’m creating a separate module for this so I can use it in recovery tasks of multiple monitors.

![45](https://blog.tyang.org/wp-content/uploads/2012/01/image45.png)
	
* Member Module: **"Microsoft.Windows.PowerShellWriteAction"**
  
  ![46](https://blog.tyang.org/wp-content/uploads/2012/01/image46.png)

* Module Configuration:

  ![47](https://blog.tyang.org/wp-content/uploads/2012/01/image47.png)
	
While editing this module, Add below secion between </ScriptBody> and</Configuration>:

```xml
<Parameters>
  <Parameter>
    <Name>PsExecPath</Name>
    <Value>$Config/PsExecPath$</Value>
  </Parameter>
  <Parameter>
    <Name>PathToExe</Name>
    <Value>$Config/PathToExe$</Value>
  </Parameter>
  <Parameter>
    <Name>Context</Name>
    <Value>$Config/Context$</Value>
  </Parameter>
  <Parameter>
    <Name>Arguments</Name>
    <Value>$Config/Arguments$</Value>
  </Parameter>
</Parameters>
<TimeoutSeconds>$Config/TimeoutSeconds$</TimeoutSeconds>

```
![48](https://blog.tyang.org/wp-content/uploads/2012/01/image48.png)

Place the PowerShell script below between<ScriptBody></ScriptBody> section:

```powershell
#=================================================
# AUTHOR:  Tao Yang
# DATE:    16/01/2012
# Version: 1.0
# COMMENT: Start a exe on console session under LocalSystem Context
#=================================================

param([string]$PsExecPath, [string]$PathToExe, [string]$Context, [string]$Arguments)
# $Context should have only 2 possible values: "System" or "User". "User" needs Auto Admin Logon Enabled
Function Get-ConsoleSessionInfo
{
  $results = Query Session
  $ConsoleSession = $results | select-string "console\s+(\w+)\s+(\d+)\s+(\w+)"
  if ($ConsoleSession)
  {
    $UserName = $ConsoleSession.Matches[0].groups[1].value
    $SessionID = $ConsoleSession.Matches[0].groups[2].value
    $State = $ConsoleSession.Matches[0].groups[3].value
    $objConsoleSession = New-Object psobject
    Add-Member -InputObject $objConsoleSession -Name "UserName" -Value $UserName -MemberType NoteProperty
    Add-Member -InputObject $objConsoleSession -Name "SessionID" -Value $SessionID -MemberType NoteProperty
    Add-Member -InputObject $objConsoleSession -Name "State" -Value $State -MemberType NoteProperty
  } else { $objConsoleSession = $null }
  Return $objConsoleSession
}

$Mode = $null
#Determine UserID
If ($Context -ieq "User")
{
  $strUserName = $null
  $DefaultPassword = $null
  #detect if auto admin is enabled, if so, retrieve username and password from registry
  $WinlogonRegKey = get-itemproperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\"
  If ($WinlogonRegKey.AutoAdminLogon = "1")
  {
    $DefaultUserName = $WinlogonRegKey.DefaultUserName
    $DefaultDomainName = $WinlogonRegKey.DefaultDomainName
    $DefaultPassword = $WinlogonRegKey.DefaultPassword
    $strUserName = "$DefaultDomainName`\$DefaultUserName"
  }

  If ($strUserName -and $DefaultPassword)
  {
    $Mode = "User"
  } else {
    Write-Error "Owner variable set to `"User`" but Auto Admin Logon is not configured!"
  }
} elseif ($Context -ieq "System") {
  $Mode = "System"
} else {
  Write-Error "Incorrect Owner variable. it can only be `"User`" or `"System`""
}

#$thisScript = Split-Path $myInvocation.MyCommand.Path -Leaf
#$scriptRoot = Split-Path(Resolve-Path $myInvocation.MyCommand.Path)
#$PsExecPath = Join-Path $scriptRoot "PsExec.exe"
If (!(Test-Path $PsExecPath))
{
  Write-Error "Unable to locate PsExec.exe in $scriptRoot. Please make sure it is located in this directory!"
} else {
  #Get Console Session ID
  $ConsoleSessionID = (Get-ConsoleSessionInfo).SessionID
  if ($ConsoleSessionID)
  {
    If ($Mode -eq "User")
    {
      $strCmd = "$PsExecPath -accepteula -i $ConsoleSessionID -d -u $strUsername -p $DefaultPassword $PathToExe $arguments"
      Write-Host "Executing $strCmd`..."
      Invoke-Expression $strCmd
    } elseif ($Mode -eq "System") {
      $strCmd = "$PsExecPath -accepteula -i $ConsoleSessionID -d -s $PathToExe $arguments"
      #run app under LOCALSYSTEM context
      Write-Host "Executing $strCmd`..."
      Invoke-Expression $strCmd
    }
  } else {
    Write-Error "No one is currently logged on to the console session at the moment."
  }
}
```

>**Note:** this PowerShell script uses command "query session" to detect the session ID of the console session.
> When you save the configuration of this module, please **ignore** this error:

>![49](https://blog.tyang.org/wp-content/uploads/2012/01/image49.png)

Add the following item under Configuration Schema tab:

![50](https://blog.tyang.org/wp-content/uploads/2012/01/image50.png)

> **Note: Make sure "TimeoutSeconds" type is set to "Integer" and others are set to "String"

I also defined "TimeoutSeconds" as an overridable paramter:

<a href="https://blog.tyang.org/wp-content/uploads/2012/01/image51.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2012/01/image_thumb51.png" alt="image" width="545" height="234" border="0" /></a>

Finally, set the Accessibility to Public (so it can be used in other management pack once this management pack is sealed"):

<a href="https://blog.tyang.org/wp-content/uploads/2012/01/image52.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2012/01/image_thumb52.png" alt="image" width="545" height="175" border="0" /></a>

{:start="7"}
7. Create a recovery task to run after Diagnostic Task that I created from the step 5.

![53](https://blog.tyang.org/wp-content/uploads/2012/01/image53.png)

This recovery task has 2 modules: a condition detection module (System.ExpressionFilter) and an Actions module (From the Write Actions module I created from Step 6)

![54](https://blog.tyang.org/wp-content/uploads/2012/01/image54.png)

* **Condition Detection Module (System.ExpressionFilter):**

![55](https://blog.tyang.org/wp-content/uploads/2012/01/image55.png)

Click Edit and add below:

```xml
<Expression>
  <SimpleExpression>
    <ValueExpression>
      <XPathQuery Type="String">Diagnostic/DataItem/Property[@Name='Result']</XPathQuery>
    </ValueExpression>
    <Operator>Equal</Operator>
    <ValueExpression>
      <Value Type="String">Positive</Value>
    </ValueExpression>
  </SimpleExpression>
</Expression>
```
![56](https://blog.tyang.org/wp-content/uploads/2012/01/image56.png)

**Actions Module (Module Type from the write action module created in Step 6)**

* **PsExecPath:** Path to PsExec.exe on the target computer
* **PathToExe:** The executable that you want PsExec to run
* **Context:** 2 Possible values: "User" or "System"
* **Argument:** arguments for the executable that PsExec is executing
* **TimeoutSeconds:** i.e. 60

![57](https://blog.tyang.org/wp-content/uploads/2012/01/image57.png)

>**Note:** Regarding to the Context variable, I designed the script to launch PsExec to execute the executable either under LOCALSYSTEM (  with –s  operator in PsExec) or under the user that’s configured for Auto Admin Logon (with –u<username> and –p<password> operators in PsExec). Because when Auto Admin Logon is enabled, the default username and password is stored in the registry key (**HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon**). If "Context" is set to "User", the script reads the username and password from registry and pass them into PsExec. So, if Auto Admin Logon is not configured, the script won’t work if "Context" is set to "User"

![58](https://blog.tyang.org/wp-content/uploads/2012/01/image58.png)

>**Note:** In this example, the recovery task simply launch notepad.exe on the console session. I can also tell notepad to open a txt file if I add the path of the txt file to "Arguments".

>**Note:** This recovery task will error out if no one has logged on to the console session of the target computer.

Now, everything is setup, time to put it to test.

![59](https://blog.tyang.org/wp-content/uploads/2012/01/image59.png)

From screen capture below, I can see the monitor’s health became Error at 10:44pm 27/01/2012. After the Diagnostic task determined there is no notepad.exe running, the recovery task kicks in, at 10:45pm, it launched notepad.exe on console session (session ID 2). The PID of notepad.exe is 4000.

Now, when I go to the target computer, notepad is launched on the console session and I can easily get the details of notepad.exe process:

![60](https://blog.tyang.org/wp-content/uploads/2012/01/notepad.png)

![61](ttp://blog.tyang.org/wp-content/uploads/2012/01/image60.png)

You can see from above screen capture, notepad.exe was started at the same time when the recovery task ran, the session ID is 2, Owner is the account configured for Auto Admin Logon and process ID is same as the output from PsExec. Therefore, this instance of notepad.exe is the one started by the recovery task!

I’ve attached the 2 scripts used in Diagnostic and recovery tasks below. as well as my sample unsealed MP.

[Download From Here](https://blog.tyang.org/wp-content/uploads/2012/01/Custom.Interactive.Process.Monitoring.zip)

Please feel free to contact me if you have any questions or suggestions.