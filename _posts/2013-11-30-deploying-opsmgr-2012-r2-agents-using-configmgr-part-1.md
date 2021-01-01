---
id: 2194
title: 'Deploying OpsMgr 2012 R2 Agents Using ConfigMgr &#8211; Part 1'
date: 2013-11-30T10:33:19+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=2194
permalink: /2013/11/30/deploying-opsmgr-2012-r2-agents-using-configmgr-part-1/
categories:
  - SCCM
  - SCOM
tags:
  - SCOM
  - SCOM Agent
---
By reading the title of this article, you may think, this practice is so common, is it worth blogging? Before I started this task, I thought it should be a quick one that I can knock off in 30 minutes. I had to say, I was wrong, I ended up spent few days on it.

Before I get into the details, I’d like to share some background and what I want to achieve. I’ll then go through the steps I took in ConfigMgr 2007 as well ConfigMgr 2012 R2. This is probably going to be too long for one blog post, so I’ll divide it into 2 parts.

I’ll cover the issues that I have experienced when using ConfigMgr 2007 part in part 1. In part 2, I’ll go through how I used the combination of the ConfigMgr 2012 application model and Compliance Settings (DCM) in ConfigMgr 2012 R2 to deploy the OpsMgr 2012 R2 agents.

<strong>Background</strong>

For the last 9 months or so, I’ve been working on a System Center refresh project. We are in the process of upgrading our existing System Center 2007 infrastructure to System Center 2012 (then we’ve decided to go to R2).

In my employer’s current environment, there are 5 OpsMgr 2007 management groups (1 Dev/Test and 4 Production). Since the supported maximum number of agents per management group has increased from 10,000 to 15,000 in OpsMgr 2012, with the new design for OpsMgr 2012, we are implementing 3 production and 1 Dev/Test management groups. so the agents will be shuffled around, not all agents from a 2007 management group are going to be migrated to the same 2012 management group.

Since ConfigMgr is also going to be migrated to 2012 R2, the OpsMgr 2012 R2 agent needs to be available in both ConfigMgr 2007 and 2012 R2 sites so OpsMgr agents migration can happen either before or after the ConfigMgr client migration. By doing this way, the OpsMgr agent migration is not depended on the result of ConfigMgr migration.

<strong>Requirements</strong>

Based my situation, I have the following requirements:
<ul>
	<li>I need to upgrade the existing OpsMgr 2007 agents and reconfigure them to point to the appropriate 2012 R2 management group.</li>
	<li>There are no multi-homing agents in my environment. the Old 2007 management group configuration need to be removed from agents.</li>
	<li>There are large number of legacy systems that don’t have Windows PowerShell installed. So all scripts need to be written using VBScript.</li>
	<li>The script must work for both upgrade and fresh install scenarios.</li>
	<li>Back in 2007, I had to create different programs within the package for 32-bit and 64 bit agents. In this script, I want the script to detect the correct msi to install based on OS architecture.</li>
	<li>Once the 2012 R2 agent is packaged up, it will be used in various OSD task sequences and become a part of the base SOE.</li>
</ul>
<strong>Install Scripts</strong>

There are many good scripts for installing OpsMgr 2012 agents out there. i.e. this one <a href="http://www.systemcentercentral.com/opsmgr-2012-installing-opsmgr-2012-agents-from-the-command-line-sample-script/">here</a> in particular. I used this script as a starting point and made it more generic. I took out any hardcoded management group configuration (Management Group Name, management server, port) and made them as parameters that need to be passed in. I’ve also made the script to get a list of all management groups that agent is connected to and remove any that is not the new 2012 management group that I want the agent to connect.

I tested the script using a command prompt running under LocalSystem account (this can be done using PsExec.exe, "PsExec.exe –s –d –i cmd")

This command opens a new command prompt window

<a href="http://blog.tyang.org/wp-content/uploads/2013/11/image.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/11/image_thumb.png" width="498" height="442" border="0" /></a>

and In task manager, I can confirm it is running under local system:

<a href="http://blog.tyang.org/wp-content/uploads/2013/11/SNAGHTML1ffa713f.png"><img style="display: inline; border: 0px;" title="SNAGHTML1ffa713f" alt="SNAGHTML1ffa713f" src="http://blog.tyang.org/wp-content/uploads/2013/11/SNAGHTML1ffa713f_thumb.png" width="580" height="232" border="0" /></a>

The script ran successfully within the command prompt window under LocalSystem account, the agent was upgraded, new MG configuration is added and the old MG is removed. I then created the package, program in SCCM, and created an advertisement targeting a test collection. After few test runs, I found out the the package only works on Windows Server 2003 or Windows XP machines. any Windows Server 2008 R2 and Windows Server 2012 machines would fail.

Long story short, after I added a logging function within the script, by examining the log, I noticed the script stops right after this line:

Set objMSConfig = CreateObject("AgentConfigManager.MgmtSvcCfg")

And this only happens in the more recent Windows OS versions.

I suddenly realised because ConfigMgr 2007 is only 32-bit app, it may have problem calling the 64-bit "AgentConfigManager.MgmtSvcCfg" com object. To prove my guess, I simply created a vbscript with just 2 lines:

[sourcecode language="VB"]
Set objMSConfig = CreateObject("AgentConfigManager.MgmtSvcCfg")
Wscript.Echo Err
```

I then ran it within a 32-bit command prompt window running under LocalSystem account (to simulate the runtime environment in ConfigMgr 2007 client). To do so, again, I used PsExec by using "Psexec.exe –s –d –i C:\Windows\SysWow64\cmd.exe"

<a href="http://blog.tyang.org/wp-content/uploads/2013/11/image1.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/11/image_thumb1.png" width="580" height="297" border="0" /></a>

and my guess is right:

Here’s the error:

<em><span style="color: #ff0000;">Microsoft VBScript runtime error: ActiveX component can't create object: 'AgentConfigManager.MgmtSvcCfg'</span></em>

<a href="http://blog.tyang.org/wp-content/uploads/2013/11/image2.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/11/image_thumb2.png" width="580" height="167" border="0" /></a>

If I run this script in 64-bit command window, there are no errors because Err variable equals 0:

<a href="http://blog.tyang.org/wp-content/uploads/2013/11/image3.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/11/image_thumb3.png" width="580" height="136" border="0" /></a>

So now, I’ve identified the problem being the 64-bit "AgentConfigManager.MgmtSvcCfg" object cannot be called by 32-bit applications. the workaround is fairly simple: I split the original script into 2 scripts. the first script firstly detects the OS architecture and install the appropriate version of MOMAGENT.msi. It then calls the second script to configure the agent using "AgentConfigManager.MgmtSvcCfg" object. The first script detects if itself is running in a 32-bit shell on a 64-bit OS. if so, it would bypass the 32-bit redirection and call the native 64-bit scripting engine cscript.exe using the <strong>%Windir%\sysnative\Cscript.exe</strong> to execute the second script. So the second script would never be executed within the 32-bit redirection mode.

I’ve named the first script <strong>OM12AgentMigration.vbs</strong>:

[sourcecode language="VB"]
'=============================================
' NAME:    OM12AgentMigration.vbs
' AUTHOR:  Tao Yang
' DATE:    19/11/2013
' Version 1.0.0.1
' COMMENT: OpsMgr 2012 agent migration script
'=============================================
Option Explicit
'ON ERROR RESUME NEXT

'Define variables
Dim objMSConfig, oArgs, OSArch, objWMIService, LogFile, LogFilePath
Dim strInstallCmd, Result, sh, col, arrOSVersion, strOSArch
Dim arrCurrentMGs, arrMGToRemove, iMGToRemoveCount
Dim CurrentMG, strConfigCmd, WinDir, SysnativeDir
Dim item, int64Bit, strPWD, MGCount, arrMGs, MGName, MG
Dim bNewMGAdded, bNewMGExists, bOldMGRemoved, objFSO
Dim MGToAdd, NewMgmtServer, MGToRemove, Port, TempDir
Dim hDefKey, strKeyPath, oReg, arrSubKeys, strSubkey

Const ForWriting = 2
Const ForAppending = 3

'process arguments
Set sh = Wscript.CreateObject("Wscript.Shell")
Set oArgs = Wscript.Arguments

IF oArgs.Count &lt; 2 THEN
	'Quit if no arguments passed in
	Wscript.Quit -1
ELSE
	MGToAdd = oArgs(0)
	NewMgmtServer = oArgs(1)
END IF

If (oArgs.Count = 3 ) Then
	Port = oArgs(2)
Else
	Port = 5723
End If

Set objFSO = CreateObject("Scripting.FileSystemObject")
TempDir = "C:\Temp"

If objFSO.FolderExists(TempDir) = FALSE Then
	objFSO.CreateFolder(TempDir)
End If

LogFilePath = TempDir & "\OM12AgentInstall.log"
Wscript.Echo LogFilePath
'delete previous log file
If objFSO.FileExists(LogFilePath) Then
   objFSO.DeleteFile(LogFilePath)
End If

'Create log file
Set LogFile = objFSO.CreateTextFile(LogFilePath, True)

LogFile.WriteLine "OM12AgentMigration.vbs version: 1.0.0.1"

'Set LogFile = objFSO.OpenTextFile(LogFilePath, ForWriting, True)

strPWD = CreateObject("Scripting.FileSystemObject").GetAbsolutePathName(".")

'Function to determine OS architecture
Function GetOSArch
	Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
	Set col = objWMIService.ExecQuery _
	("Select * from Win32_OperatingSystem")
	For Each item in col
		arrOSVersion = Split(item.Version,".")
		If arrOSVersion(0) &gt;= 6 Then
			'OS is Vista / 2008 or higher
			StrOSArch = item.OSArchitecture
		Else
			int64Bit = InStr(item.Caption,"x64")
			If int64Bit &gt; 0 Then
				strOSArch = "64-bit"
			Else
				strOSArch = "32-bit"
			End If
		End If
	Next
	GetOSArch = strOSArch
End Function

'Get OS architecture so we can determine which version of the agent to install
OSArch = GetOSArch
LogFile.WriteLine "OS Architecture: " & OSArch
'Prepare the agent install command
IF OSArch = "64-bit" THEN
	strInstallCmd = "msiexec /i " & CHR(34) & strPWD & "\AMD64\MOMAgent.msi" & CHR(34) & " /qn AcceptEndUserLicenseAgreement=1 /l*v " & TempDir & "\OM12AgentMSI.log"
	LogFile.WriteLine "64 bit OS detected. Installing OM12 R2 agent using command: '" & strInstallCmd & "'"
ELSEIF OSArch = "32-bit" THEN
	strInstallCmd = "msiexec /i " & CHR(34) & strPWD & "\i386\MOMAgent.msi" & CHR(34) & " /qn AcceptEndUserLicenseAgreement=1 /l*v " & TempDir & "\OM12AgentMSI.log"
	LogFile.WriteLine "32 bit OS detected. Installing OM12 R2 agent using command: '" & strInstallCmd & "'"
END IF

'Determine the command to execute the OM12AgentConfig.vbs script
WinDir = sh.ExpandEnvironmentStrings( "%WinDir%" )
SysnativeDir = WinDir & "\Sysnative"

If objFSO.FolderExists(SysnativeDir) = FALSE Then
	strConfigCmd = WinDir & "\System32\Cscript.exe " & CHR(34) & strPWD & "\OM12AgentConfig.vbs" & CHR(34) & " " & MGToAdd & " " & NewMgmtServer & " " & Port & " " & LogFilePath
Else
	strConfigCmd = WinDir & "\Sysnative\Cscript.exe " & CHR(34) & strPWD & "\OM12AgentConfig.vbs" & CHR(34) & " " & MGToAdd & " " & NewMgmtServer & " " & Port & " " & LogFilePath
End If

'Install agent
Result = sh.run(strInstallCmd,0,True)
If Result &lt;&gt; 0 Then
	LogFile.WriteLine "Failed to install OM12 R2 agent."
	LogFile.Close
	Wscript.Quit -1
Else
	LogFile.WriteLine "Successfully installed the OM12 R2 agent."
End if

LogFile.WriteLine "Start configuring the OM12 R2 agent."
LogFile.WriteLine "Calling OM12AgentConfig.vbs using command: " & strConfigCmd
'Wscript.Echo strConfigCmd
LogFile.Close
Result = sh.run(strConfigCmd,0,True)

```

The second secript is named <strong>OM12AgentConfig.vbs</strong>:

[sourcecode language="VB"]
'=============================================
' NAME:    OM12AgentConfig.vbs
' AUTHOR:  Tao Yang
' DATE:    21/11/2013
' Version 1.0.0.0
' COMMENT: OpsMgr 2012 agent migration script
'=============================================

'ON ERROR RESUME NEXT
Const ForWriting = 2
Const ForAppending = 8

'process arguments
Set sh = Wscript.CreateObject("Wscript.Shell")
Set oArgs = Wscript.Arguments

IF oArgs.Count &lt; 4 THEN
	'Quit if no arguments passed in
	Wscript.Quit -1
ELSE
	MGToAdd = oArgs(0)
	NewMgmtServer = oArgs(1)
	Port = oArgs(2)
	LogFilePath = oArgs(3)
END IF

'Create FSO
Wscript.Echo LogFilePath
set objFSO = CreateObject("Scripting.FileSystemObject")
set LogFile = objFSO.OpenTextFile(LogFilePath, ForAppending, True)

LogFile.WriteLine "Start configuring the OM12 R2 agent."
'Configure OpsMgr 2012 agent
LogFile.WriteLine "Creating AgentConfigManager.MgmtSvcCfg object"
Set objMSConfig = CreateObject("AgentConfigManager.MgmtSvcCfg")

'Get the current MG(s)
LogFile.WriteLine "Getting the configuration for the existing management group(s)."
bNewMGExists = FALSE

Set arrCurrentMGs = objMSConfig.GetManagementGroups()
iCount = 0
For each CurrentMG in arrCurrentMGs
	MGName = CurrentMG.managementGroupName
	IF MGName &lt;&gt; MGToAdd THEN
		LogFile.WriteLine "Removing Management Group: " & MGName
		objMSConfig.RemoveManagementGroup(MGName)
		iCount = iCount + 1
	Else
		LogFile.WriteLine "Skipping management group " & MGName & ", because it's the same as the MG that to be added."
		bNewMGExists = TRUE
	END IF
Next

LogFile.WriteLine "Total number of Management Group(s) Removed: " & iCount

'Add New MG
IF bNewMGExists = FALSE THEN
	LogFile.WriteLine "Adding new management group " & MGToAdd & ". Management server: " & NewMgmtServer & ". Port: " & Port
	Call objMSConfig.AddManagementGroup (MGToAdd, NewMgmtServer,Port)
END IF

'Confirm the new MG has been added
objMSConfig.GetManagementGroup(MGToAdd)
If Err= 0 Then
	bNewMGAdded = TRUE
	LogFile.WriteLine "New MG " & MGToAdd & " added."
Else
	bNewMGAdded = FALSE
	LogFile.WriteLine "New MG " & MGToAdd & " DID NOT get added."
End IF

'Confirm if the newly added MG is the only MG configured on the agent
bOldMGRemoved = TRUE
Set arrMGs = objMSConfig.GetManagementGroups()
For each MG in arrMGs
	MGName = MG.managementGroupName
	IF MGName &lt;&gt; MGToAdd THEN
		bOldMGRemoved = FALSE
	END IF
Next

LogFile.WriteLine "bNewMGAdded=" & bNewMGAdded
LogFile.WriteLine "bOldMGRemoved=" & bOldMGRemoved
'exit
IF (bNewMGAdded = TRUE AND bOldMGRemoved = TRUE) THEN
	LogFile.WriteLine "OM12 R2 agent installation and configuration successful. reloading the config..."
	Call objMSConfig.ReloadConfiguration
	LogFile.WriteLine "Done."
	LogFile.Close
	Wscript.Quit 0
ELSE
	LogFile.WriteLine "Error installing / configuring OM12 R2 agent"
	LogFile.Close
	Wscript.Quit -1
END IF
```

When creating the package in ConfigMgr, These 2 scripts need to be copied to the OpsMgr 2012 R2 agent install root folder: <a href="http://blog.tyang.org/wp-content/uploads/2013/11/SNAGHTML22520a61.png"><img style="display: inline; border: 0px;" title="SNAGHTML22520a61" alt="SNAGHTML22520a61" src="http://blog.tyang.org/wp-content/uploads/2013/11/SNAGHTML22520a61_thumb.png" width="580" height="208" border="0" /></a> The syntax for OM12AgentMigration.vbs is:

<strong>cscript /nologo OM12AgentMigration.vbs &lt;Management Group Name&gt; &lt;Management Server FDDN&gt; &lt;Port&gt;</strong>

Where the port parameter is optional. when not specified, the default port of 5723 is used. i.e.

cscript /nologo OM12AgentMigration.vbs MYOPSMGRMG  MyManagementServer.MyCompany.com

Both scripts log to a log file located at C:\Temp\OM12AgentInstall.log. When the first script executes msiexec, it also generates a msi log located at C:\Temp\OM12AgentMSI.log. I’ve hardcoded the log files path to C:\Temp rather than using the %temp% environment variable because during my testing in my work’s environment, I have noticed the %temp% variable in some of the machines are incorrectly configured and it would cause the script to fail. my script would create the C:\Temp directory if it does not exist.

The OM12AgentInstall.log looks like this: <a href="http://blog.tyang.org/wp-content/uploads/2013/11/SNAGHTML225046c7.png"><img style="display: inline; border: 0px;" title="SNAGHTML225046c7" alt="SNAGHTML225046c7" src="http://blog.tyang.org/wp-content/uploads/2013/11/SNAGHTML225046c7_thumb.png" width="580" height="244" border="0" /></a> I have also created an uninstall script called <strong>OM12AgentUninstall.vbs</strong>, which will work on both 32-bit and 64-bit Operating Systems. This script is also placed on the same folder as the other install scripts.

[sourcecode language="VB"]
'=============================================
' NAME:    OM12AgentUninstall.vbs
' AUTHOR:  Tao Yang
' DATE:    22/11/2013
' Version 1.0.0.0
' COMMENT: OpsMgr 2012 agent Uninstall script
'=============================================

MSIGUID64Bit = "{786970C5-E6F6-4A41-B238-AE25D4B91EEA}"
MSIGUID32Bit = "{B4A63055-7BB1-439E-862C-6844CB4897DA}"
Set sh = Wscript.CreateObject("Wscript.Shell")

'Function to determine OS architecture
Function GetOSArch
	Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
	Set col = objWMIService.ExecQuery _
	("Select * from Win32_OperatingSystem")
	For Each item in col
		arrOSVersion = Split(item.Version,".")
		If arrOSVersion(0) &gt;= 6 Then
			'OS is Vista / 2008 or higher
			StrOSArch = item.OSArchitecture
		Else
			int64Bit = InStr(item.Caption,"x64")
			If int64Bit &gt; 0 Then
				strOSArch = "64-bit"
			Else
				strOSArch = "32-bit"
			End If
		End If
	Next
	GetOSArch = strOSArch
End Function

'Get OS architecture so we can determine which version of the agent to install
OSArch = GetOSArch

IF OSArch = "64-bit" THEN
	strUninstallCmd = "msiexec /x " & MSIGUID64Bit & " /qn"
ELSEIF OSArch = "32-bit" THEN
	strUninstallCmd = "msiexec /x " & MSIGUID32Bit & " /qn"
END IF

'Install agent
Wscript.Echo "Uninstalling OM12 agent using command: " & strUninstallCmd
Result = sh.run(strUninstallCmd,0,True)
If Result &lt;&gt; 0 Then
	Wscript.Quit -1
Else
	Wscript.Quit 0
	Wscript.Echo "Successfully uninstalled the OM12 R2 agent."
End if
```

The syntax for the uninstall script is straightforward:

Cscript /nologo OM12AgentUnisntall.vbs

<strong>Packaging in ConfigMgr 2007</strong>

I have shown the package source folder structure in previous screenshot. Because only English version of the agent is required in my enviornment, I have removed all the MST's for other languages in both amd64 and i386 folders. Each folder should only contain 3 files:

<a href="http://blog.tyang.org/wp-content/uploads/2013/11/agent-folder.jpg"><img class="alignleft size-medium wp-image-2205" alt="agent folder" src="http://blog.tyang.org/wp-content/uploads/2013/11/agent-folder-300x95.jpg" width="300" height="95" /></a><img alt="" src="file:///C:/Users/Tao/AppData/Local/Temp/SNAGHTML228f60b6.PNG" width="772" height="247" border="0" />

Because the management group information is passed into the script as parameters, I don’t have to create separate scripts for each OpsMgr 2012 R2 management groups. I created one package for OpsMgr 2012 R2 agents, and then created one install program for each management group and one generic uninstall program:

<a href="http://blog.tyang.org/wp-content/uploads/2013/11/image4.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/11/image_thumb4.png" width="580" height="138" border="0" /></a>

With the install program, here’s how I configured it:

The command line is same as what I mentioned above.

<a href="http://blog.tyang.org/wp-content/uploads/2013/11/image5.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/11/image_thumb5.png" width="415" height="478" border="0" /></a>

Because the script can detect the OS architecture, this program can run on any platform. Also, although the actual size for really small, once the agent start working with the management group, more space is required for the health service stores, downloaded management packs, etc. in my work’s production environment, I checked and the current 2007 R2 agents are using approx. 350MB space. So I specified the estimated disk space to 500MB.

<a href="http://blog.tyang.org/wp-content/uploads/2013/11/image6.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/11/image_thumb6.png" width="415" height="478" border="0" /></a>

The rest of the program properties are pretty normal:

<a href="http://blog.tyang.org/wp-content/uploads/2013/11/image7.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/11/image_thumb7.png" width="424" height="489" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2013/11/image8.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/11/image_thumb8.png" width="433" height="506" border="0" /></a>

Note: because this package will be used in OSD task sequences later, I ticked the checkbox as shown above.

<strong>Summary</strong>

Because of the input parameter difference between OpsMgr 2007 agent and OpsMgr 2012 agent, management group information can longer be passed into the MOMAGENT.MSI during the agent installation. The OpsMgr 2012 (R2) agent needs to be configured using the "AgentConfigManager.MgmtSvcCfg" object. Since the ConfigMgr 2007 is only a 32-bit application, the ConfigMgr 2007 agent on a 64-bit operating system cannot call "AgentConfigManager.MgmtSvcCfg".

By configuring the OpsMgr 2012 R2 agent package this way in ConfigMgr 2007, I have achieved the following goal:
<ul>
	<li>Able to install and configure 64-bit OpsMgr 2012 (R2) agent.</li>
	<li>No need for multiple programs for 32-bit and 64-bit operating systems.</li>
	<li>No need to update ConfigMgr package source when the OpsMgr management group changes (i.e. adding / removing management groups, modifying management server names agents reporting to, etc.) because these parameters are passed into the script as command line parameter. In ConfigMgr, these information is stored in the site database rather than within the package source. Therefore I will never have to update distribution points when modifying management group information.</li>
	<li>The script also removes any management groups that are not the one specified in the parameter, therefore no additional steps required to remove the old 2007 MG information off the agent.</li>
	<li>As best practice and the company standard, an uninstall program is also created.</li>
</ul>
<strong><span style="color: #ff0000;">Note: DO NOT use my approach on multi-homing OpsMgr agents.</span></strong>

<a title="Deploying OpsMgr 202 R2 Agents Using ConfigMgr – Part 2" href="http://blog.tyang.org/2013/11/30/deploying-opsmgr-202-r2-agents-using-configmgr-part-2/">Continue on to Part 2</a>….