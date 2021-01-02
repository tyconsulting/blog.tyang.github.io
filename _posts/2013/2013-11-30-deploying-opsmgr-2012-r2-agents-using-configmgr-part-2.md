---
id: 2262
title: 'Deploying OpsMgr 2012 R2 Agents Using ConfigMgr - Part 2'
date: 2013-11-30T20:53:58+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=2262
permalink: /2013/11/30/deploying-opsmgr-202-r2-agents-using-configmgr-part-2/
categories:
  - SCCM
  - SCOM
tags:
  - SCOM
  - SCOM Agent
---
This is the 2nd part of 2-part blog series. Part 1 can be found <a title="Deploying OpsMgr 2012 R2 Agents Using ConfigMgr – Part 1" href="http://blog.tyang.org/2013/11/30/deploying-opsmgr-2012-r2-agents-using-configmgr-part-1/">HERE</a>.

In Part 1, I went through the issues I had with deploying OpsMgr 2012 R2 agent via ConfigMgr 2007. In this article, I will go through the steps I took to deploy OpsMgr 2012 R2 agent using ConfigMgr 2012 Application model and Compliance settings (DCM).

Moving to ConfigMgr 2012, I have decided to do utilise the new application model (it’s also to align the policy we set during the design phase of the System Center upgrade project: that wherever is possible, the new application model should be used rather than using the traditional packages / programs in ConfigMgr). By packaging the OpsMgr 2012 R2 agent as an application in ConfigMgr, it is enforced on the ConfigMgr client (i.e. ConfigMgr will automatically install it again if someone manually uninstalled it).

<strong>Challenges</strong>

Instead of creating multiple programs within one package for different management groups, I could create different deployment types for different OpsMgr MG’s within the same application. But, because ConfigMgr client will evaluate ALL deployment types in the order I configure using global conditions, it is just going to be way too complex for me to setup global conditions for such a complex OpsMgr environment. Further more, sometimes there are ad-hoc requirements that we also have to move OpsMgr clients among different MG’s for testing and troubleshooting. By using global conditions, this is almost unachievable in my scenario. One way to avoid totally relying on global conditions for the OpsMgr agent application is to create multiple OpsMgr 2012 R2 Agent applications within ConfigMgr 2012 R2, one for each OpsMgr 2012 R2 management group. This is an admin overhead – having to manage and maintain 4 (in my case) almost identical applications for the same purpose.

<strong>Solution</strong>

Because I only want to maintain one application in ConfigMgr for multiple OpsMgr management groups without creating complex global conditions, I have thrown ConfigMgr Compliance Settings (formally known as Desired Configuration Management or DCM) into the mix. The pre-requisite for tis approach is that the Compliance Settings need to be enabled for the ConfigMgr client. This can be done either on the default client setting or creating a custom client setting and deploy it a collection of clients:

<a href="http://blog.tyang.org/wp-content/uploads/2013/11/SNAGHTML23e4be6b.png"><img style="display: inline; border-width: 0px;" title="SNAGHTML23e4be6b" src="http://blog.tyang.org/wp-content/uploads/2013/11/SNAGHTML23e4be6b_thumb.png" alt="SNAGHTML23e4be6b" width="580" height="345" border="0" /></a>

Basically, I can separate the OpsMgr agent deployment into 2 steps:
<ol>
	<li>Install OpsMgr 2012 R2 Agent</li>
	<li>Configure OpsMgr 2012 R2 Agent to point to the appropriate management group.</li>
</ol>
By having Compliance Settings in the picture, the application in ConfigMgr will take care of step 1 – installing the agent. And then I create a Compliance Settings Configuration Baseline to ensure the OpsMgr agents are reporting the the correct management group. One good thing about ConfigMgr 2012 is that both applications and configuration baselines are enforced (Configuration Baseline can be configured to auto remediate in 2012, which is not possible in ConfigMgr 2007).

<strong><span style="color: #ff0000;">Note:</span></strong> I’m only using this approach because we are managing multiple OpsMgr management groups, if there is only one management group in your environment, this is probably unnecessary and over-complicated.

<strong>Instructions</strong>

Firstly, I need to create 2 global conditions for the OpsMgr 2012 R2 agent application. I named them as the following:
<ul>
	<li>OS Architecture</li>
	<li>Is OpsMgr or SCSM Management Server</li>
</ul>
As the name suggests, the "OS Architecture" Global condition detects the OS architecture using a VBScript which I wrote a long time ago and kept reusing it in many places.

<a href="http://blog.tyang.org/wp-content/uploads/2013/11/SNAGHTML23f734ad.png"><img style="display: inline; border-width: 0px;" title="SNAGHTML23f734ad" src="http://blog.tyang.org/wp-content/uploads/2013/11/SNAGHTML23f734ad_thumb.png" alt="SNAGHTML23f734ad" width="505" height="476" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2013/11/SNAGHTML23f7fe66.png"><img style="display: inline; border-width: 0px;" title="SNAGHTML23f7fe66" src="http://blog.tyang.org/wp-content/uploads/2013/11/SNAGHTML23f7fe66_thumb.png" alt="SNAGHTML23f7fe66" width="507" height="455" border="0" /></a>

Here’s the script (so you can copy and paste):

```vb
Function GetOSArch
  Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
  Set col = objWMIService.ExecQuery _
  ("Select * from Win32_OperatingSystem")
  For Each item in col
    arrOSVersion = Split(item.Version,".")
    If arrOSVersion(0) >= 6 Then
      'OS is Vista / 2008 or higher
      StrOSArch = item.OSArchitecture
    Else
      int64Bit = InStr(item.Caption,"x64")
      If int64Bit > 0 Then
        strOSArch = "64-bit"
      Else
        strOSArch = "32-bit"
      End If
    End If
  Next
  GetOSArch = strOSArch
End Function

OSArch = GetOSArch
Wscript.Echo OSArch
```

I also created the second global condition called "Is OpsMgr or SCSM Management Server" to detect if the endpoint is an OpsMgr or SCSM management server. Because OpsMgr agent cannot be install on OpsMgr or Service Manager management servers, they need to be excluded by the application deployment types. This global condition is based on a registry key, if the key <strong>HKLM\SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Server Management Groups</strong> exists, the the client is indeed an OpsMgr or Service Manager management server:

<a href="http://blog.tyang.org/wp-content/uploads/2013/11/SNAGHTML23fccf8d.png"><img style="display: inline; border-width: 0px;" title="SNAGHTML23fccf8d" src="http://blog.tyang.org/wp-content/uploads/2013/11/SNAGHTML23fccf8d_thumb.png" alt="SNAGHTML23fccf8d" width="550" height="493" border="0" /></a>

Next step is to create the application for OpsMgr 2012 R2 Agent. the "Create Application Wizard" is very straight forward. simply select either the 64-bit or 32-bit MOMAGENT.MSI and the wizard will identify all required information from the MSI.

<a href="http://blog.tyang.org/wp-content/uploads/2013/11/SNAGHTML240076ea.png"><img style="display: inline; border-width: 0px;" title="SNAGHTML240076ea" src="http://blog.tyang.org/wp-content/uploads/2013/11/SNAGHTML240076ea_thumb.png" alt="SNAGHTML240076ea" width="580" height="395" border="0" /></a>

I have changed the name of the application from "Microsoft Monitoring Agent" to "OpsMgr 2012 R2 agent" as I don’t expect every ConfigMgr operators in my company knows that Microsoft has renamed the OpsMgr agent in the 2012 R2 release.

<a href="http://blog.tyang.org/wp-content/uploads/2013/11/image9.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2013/11/image_thumb9.png" alt="image" width="580" height="476" border="0" /></a>

I have marked my modification in red. Please be aware that the default installation program <strong>MUST</strong> be changed to:

<strong>msiexec /i MOMAgent.msi /qn AcceptEndUserLicenseAgreement=1</strong>

<strong>AcceptEndUserLicenseAgreement=1</strong> is a required parameter. Without it, the MOMAgent.MSI will not install in quiet mode.

Once the application is created, I created another deployment type for the other OS architecture type. I also renamed both deployment type to reflect the OS architecture:

<a href="http://blog.tyang.org/wp-content/uploads/2013/11/image10.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2013/11/image_thumb10.png" alt="image" width="580" height="122" border="0" /></a>

Now I need to use the two global conditions I created earlier to define requirements for each deployment type.

For 64-bit deployment type, OS Architecture must be equal to "64-bit" and the registry key defined in "Is OpsMgr or SCSM Management Server" must not exist:

<a href="http://blog.tyang.org/wp-content/uploads/2013/11/SNAGHTML24120ed2.png"><img style="display: inline; border-width: 0px;" title="SNAGHTML24120ed2" src="http://blog.tyang.org/wp-content/uploads/2013/11/SNAGHTML24120ed2_thumb.png" alt="SNAGHTML24120ed2" width="520" height="344" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2013/11/SNAGHTML2412e8b8.png"><img style="display: inline; border-width: 0px;" title="SNAGHTML2412e8b8" src="http://blog.tyang.org/wp-content/uploads/2013/11/SNAGHTML2412e8b8_thumb.png" alt="SNAGHTML2412e8b8" width="403" height="368" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2013/11/SNAGHTML2413c79e.png"><img style="display: inline; border-width: 0px;" title="SNAGHTML2413c79e" src="http://blog.tyang.org/wp-content/uploads/2013/11/SNAGHTML2413c79e_thumb.png" alt="SNAGHTML2413c79e" width="414" height="354" border="0" /></a>

Same global conditions needs to apply to the 32-bit deployment type, except OS Architecture must equal to "32-bit"

<a href="http://blog.tyang.org/wp-content/uploads/2013/11/SNAGHTML2415d9c5.png"><img style="display: inline; border-width: 0px;" title="SNAGHTML2415d9c5" src="http://blog.tyang.org/wp-content/uploads/2013/11/SNAGHTML2415d9c5_thumb.png" alt="SNAGHTML2415d9c5" width="467" height="326" border="0" /></a>

Now, the application is setup. It can be deployed to a collection. this collection can include every machine needs to be monitored by OpsMgr, <strong>AS WELL AS</strong> OpsMgr and Service Manager management servers. The global conditions prevent the OpsMgr 2012 R2 Agent from installing on to the OpsMgr or Service Manager servers (even if it tries to install on the management servers, it’s going to fail anyway). The screenshot below indicates the 3 OpsMgr management servers in my lab environment have been excluded (I haven’t built Service Manager 2012 R2 in my lab yet so it’s not on the list):

<a href="http://blog.tyang.org/wp-content/uploads/2013/11/SNAGHTML242a3b1d.png"><img style="display: inline; border-width: 0px;" title="SNAGHTML242a3b1d" src="http://blog.tyang.org/wp-content/uploads/2013/11/SNAGHTML242a3b1d_thumb.png" alt="SNAGHTML242a3b1d" width="522" height="429" border="0" /></a>

<strong>Note:</strong> If a server is in the process to be setup as OpsMgr or Service Manager management server (or Service Manager DW management server), and it is already managed by ConfigMgr, please make sure it is not a member of the collection which the OpsMgr 2012 R2 Agent is deploying to, otherwise OpsMgr 2012 R2 agent might be install prior to the installation of OpsMgr or Service Manager server components and it will cause the server components installation to fail.

Just a side note here:
<ul>
	<li>When installing OpsMgr management server, OpsMgr agent <strong>MUST NOT</strong> be present on the computer.</li>
	<li>When installing Service Manager management server or Data Warehouse management server, OpsMgr agent <strong>MUST NOT</strong> be present on the computer.</li>
	<li>When installing Service Manager web portal server and it will later on be monitored by OpsMgr, the OpsMgr agent <strong>MUST</strong> be installed <strong><span style="color: #ff0000;"><span style="text-decoration: underline;">prior to</span></span></strong> the installation of Service Manager web portal. Otherwise, OpsMgr agent cannot be installed after the Service Manager web portal is installed.</li>
</ul>
Now that the application creation is complete, time to setup Configuration Baseline(s). I will need to setup one configuration item and one configuration baseline for each of the OpsMgr management groups. For the demonstration in this blog post, I’ll only setup one set of configuration item and configuration baseline – for the OpsMgr 2012 R2 management group in my lab.

Firstly, the Configuration Item needs to be created. I named in "OpsMgr 2012 R2 Agent Config CI" in my lab. But in real life, I’ll include the OpsMgr management group name in the Config Item name because is unique to that particular management group.

I’m creating a CI for Windows and it contains application settings:

<a href="http://blog.tyang.org/wp-content/uploads/2013/11/image11.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2013/11/image_thumb11.png" alt="image" width="580" height="450" border="0" /></a>

Next, for the application detection method, I use a VBScript to detect if the healthservice service is present.

<a href="http://blog.tyang.org/wp-content/uploads/2013/11/image12.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2013/11/image_thumb12.png" alt="image" width="580" height="513" border="0" /></a>

Here’s the script (OM12AgentAppCIDetect.vbs):

```vb
'=========================================
' NAME:    OM12AgentAppCIDetect.vbs
' AUTHOR:  Tao Yang
' DATE:    26/11/2013
' Version 1.0.0.0
' COMMENT: Used in ConfigMgr 2012 CI to detect healthservice
'=========================================

bHSFound = FALSE
Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
Set colItems = objWMIService.ExecQuery("Select * from Win32_Service Where name = 'healthservice'")
For Each objItem in colItems
  bHSFound = TRUE
Next

'Process Result
If bHSFound THEN
  Wscript.Echo "Health Service found."
Else
  Wscript.quit
End If
```

<strong><span style="color: #ff0000;">Note:</span></strong> I understand healthservice is also present in OpsMgr and Service Manager management servers. Because the application deployment can be targeting a collection containing OpsMgr or Service Manager management servers, I need to make sure the CI detects the management servers as well, just in case the same collection is used for the Configuration Baselines. If I don’t include management servers in the CI application detect script (i.e. by directly detecting the OpsMgr agent), the Configuration Baseline evaluation result will be Non-Compliant on a management server, which is not a desired result. The script I used in later stage has the smarts to identify management servers.

Next, create a new Setting for the CI:

<a href="http://blog.tyang.org/wp-content/uploads/2013/11/SNAGHTML244c4828.png"><img style="display: inline; border-width: 0px;" title="SNAGHTML244c4828" src="http://blog.tyang.org/wp-content/uploads/2013/11/SNAGHTML244c4828_thumb.png" alt="SNAGHTML244c4828" width="454" height="395" border="0" /></a>

In the General tab, give setting a name, remember this is unique to the specific OpsMgr management group.

Setting type: Script

Data Type: String

Then add the discovery script and remediation script:

<a href="http://blog.tyang.org/wp-content/uploads/2013/11/image13.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2013/11/image_thumb13.png" alt="image" width="507" height="478" border="0" /></a>

Both scripts are written using VBScript.

Discovery Script (OM12AgentCIDiscovery):

<a href="http://blog.tyang.org/wp-content/uploads/2013/11/image14.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2013/11/image_thumb14.png" alt="image" width="484" height="490" border="0" /></a>

```vb
'==============================================
' NAME:    OM12AgentCIDiscovery.vbs
' AUTHOR:  Tao Yang
' DATE:    22/11/2013
' Version 1.0.0.0
' COMMENT: Used in ConfigMgr 2012 DCM for OpsMgr 2012 R2 agent
'==============================================

'Modify the following line to suit your environment.
AgentMGRegKey= "&lt;Your MG Name&gt;"

function ReadRegistry (strRegistryKey, strDefault )
  Dim WSHShell, value

  On Error Resume Next
  Set WSHShell = CreateObject("WScript.Shell")
  value = WSHShell.RegRead( strRegistryKey )

  if err.number &lt;&gt; 0 then
    ReadRegistry= strDefault
  else
    ReadRegistry=value
  end if

  set WSHShell = nothing
end function

Const HKEY_LOCAL_MACHINE = &H80000002

Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")

'01. Check if the OpsMgr or Service Manager management server is installed
Set colItems = objWMIService.ExecQuery("Select * from Win32_Service Where name = 'healthservice'")
bMgmtServer = FALSE
For Each objItem in colItems
  'Health Service found. Check if this machine is an OpsMgr or Service Manager management server.
  Set oReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\default:StdRegProv")
  ServerMGRegKey= "Server Management Groups"
  strKeyPath = "SOFTWARE\Microsoft\Microsoft Operations Manager\3.0"
  oReg.EnumKey HKEY_LOCAL_MACHINE, strKeyPath, arrSubKeys
  For Each subkey In arrSubKeys
    bFound = (subkey = ServerMGRegKey)
    if bFound then exit for
  Next
  IF bFound THEN
    'OpsMgr or Service Manager management server detected
    'Wscript.Echo "OpsMgr or SCSM management server detected."
    bMgmtServer = TRUE
  END IF
Next

'Wscript.Echo "bMgmtServer: " & bMgmtServer

'02. Check if the agent is connected to the correct management group
If bMgmtServer = False Then
  'Wscript.Echo "Check Agent's MG config"
  Set oReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\default:StdRegProv")
  strKeyPath = "SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Agent Management Groups"
  oReg.EnumKey HKEY_LOCAL_MACHINE, strKeyPath, arrSubKeys
  bIncorrectMG= FALSE
  If Not IsNull(arrSubKeys) Then
    For Each subkey In arrSubKeys
      bFound = (lcase(subkey) = lcase(AgentMGRegKey))
      IF bFound = FALSE THEN
      'Wscript.Echo "Incorrect management group found. Current Management Group: " & subkey
      bIncorrectMG = TRUE
      END IF
    Next
  ELSE
    bIncorrectMG = TRUE
  End IF
End If
'Wscript.Echo "bIncorrectMG: " & bIncorrectMG

'Process Result
bConfigRequired = FALSE
IF bMgmtServer = FALSE THEN
  IF bIncorrectMG = TRUE THEN
    bConfigRequired = TRUE
  END IF
END IF
'Wscript.Echo "bConfigRequired: " & bConfigRequired
If bConfigRequired = FALSE Then
  Wscript.Echo "Compliant"
Else
  Wscript.Echo "Non-Compliant"
End If
```

Please note in the beginning of the script, the variable "<strong>AgentMGRegKey</strong>" needs to be modified in each environment, it should be the name of the OpsMgr management group.

Remediation Script (OM12AgentRemediate.vbs):

<a href="http://blog.tyang.org/wp-content/uploads/2013/11/image15.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2013/11/image_thumb15.png" alt="image" width="506" height="510" border="0" /></a>

```vb
'=============================================
' NAME:    OM12AgentRemediate.vbs
' AUTHOR:  Tao Yang
' DATE:    21/11/2013
' Version 1.0.0.0
' COMMENT: OpsMgr 2012 agent CI Remediation script
'=============================================

'ON ERROR RESUME NEXT

Const ForWriting = 2
Const ForAppending = 8
'Dim arrMGToRemove()
'process arguments
Set sh = Wscript.CreateObject("Wscript.Shell")

MGToAdd = "&lt;Your Management Group Name&gt;"
NewMgmtServer = "&lt;Your Management Server’s FQDN&gt;"
Port = 5723

'Configure OpsMgr 2012 agent
Set objMSConfig = CreateObject("AgentConfigManager.MgmtSvcCfg")

'Get the current MG(s)
bNewMGExists = FALSE
Set arrCurrentMGs = objMSConfig.GetManagementGroups()
'Set arrMGToRemove = CreateObject( "System.Collections.ArrayList" )
For each CurrentMG in arrCurrentMGs
  MGName = CurrentMG.managementGroupName
  IF MGName &lt;&gt; MGToAdd THEN
    objMSConfig.RemoveManagementGroup(MGName)
    arrMGToRemove.Add MGName
  Else
    bNewMGExists = TRUE
  END IF
Next
'iMGToRemoveCount = arrMGToRemove.count

'If iMGToRemoveCount &gt; 0 Then
'    For each item in arrMGToRemove
'        objMSConfig.RemoveManagementGroup(item)
'    Next
'End If

'Add New MG
IF bNewMGExists = FALSE THEN
  Call objMSConfig.AddManagementGroup (MGToAdd, NewMgmtServer,Port)
END IF

'Confirm the new MG has been added
objMSConfig.GetManagementGroup(MGToAdd)
If Err= 0 Then
  bNewMGAdded = TRUE
Else
  bNewMGAdded = FALSE
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

'exit
IF (bNewMGAdded = TRUE AND bOldMGRemoved = TRUE) THEN
  Call objMSConfig.ReloadConfiguration
  Wscript.Quit 0
ELSE
  Wscript.Quit -1
END IF
```

Now, moving to the "Compliance Rule" tab and create a new compliance rule

<a href="http://blog.tyang.org/wp-content/uploads/2013/11/image16.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2013/11/image_thumb16.png" alt="image" width="446" height="418" border="0" /></a>

The Selected Setting should be default to the setting just created.

Rule type: Value

The value returned by the specified script must equal to "Compliant"

Tick the "Run the specified remediation script when this setting is noncompliant" check box

Tick the "Report noncompliance if this setting instance is not found" check box.

For "Noncompliance severity for reports", I selected "Critical with event"

<a href="http://blog.tyang.org/wp-content/uploads/2013/11/image17.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2013/11/image_thumb17.png" alt="image" width="519" height="535" border="0" /></a>

I unselected "Windows Embedded" under Supported Platforms:

<a href="http://blog.tyang.org/wp-content/uploads/2013/11/image18.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2013/11/image_thumb18.png" alt="image" width="503" height="443" border="0" /></a>

Now that the Configuration Item is created, I need to create a Configuration Baseline.

Again, in real life, I’d name the Configuration Baseline something relevant to the OpsMgr management group it represents. The creation of the Configuration Baseline is pretty straightforward, I need to add the CI I’ve just created to it.

<a href="http://blog.tyang.org/wp-content/uploads/2013/11/image19.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2013/11/image_thumb19.png" alt="image" width="496" height="449" border="0" /></a>

Now, the Configuration Baseline is created, I’ll create a collection that contains all the OpsMgr 2012 R2 agents that SHOULD report to this particular management group, and then deploy the baseline to this collection. When deploying the baseline, make sure the "Remediate noncompliant rules when supported" check box is selected.

<a href="http://blog.tyang.org/wp-content/uploads/2013/11/image20.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2013/11/image_thumb20.png" alt="image" width="544" height="549" border="0" /></a>

<span style="color: #ff0000;"><strong>Note:</strong></span> In real world, I would create a collection for the OpsMgr agent application deployment, and then create separate collections for each management groups for the Configuration Baslines deployments.

This should be all it’s required. After the OpsMgr 2012 R2 Agent application has been deployed the the endpoint and the Compliance Baseline has arrived to the ConfigMgr client, in my lab, within few hours, the Compliance Baseline got evaluated automatically (during DCM evaluation cycle), and the OpsMgr 2012 R2 client is automatically configured to point to the appropriate management group. The Configuration Baseline should be shown as compliant in the ConfigMgr client:

<a href="http://blog.tyang.org/wp-content/uploads/2013/11/image21.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2013/11/image_thumb21.png" alt="image" width="373" height="445" border="0" /></a>

And when opening "Microsoft Monitoring Agent" in the Control Panel,

<a href="http://blog.tyang.org/wp-content/uploads/2013/11/SNAGHTML24773e15.png"><img style="display: inline; border-width: 0px;" title="SNAGHTML24773e15" src="http://blog.tyang.org/wp-content/uploads/2013/11/SNAGHTML24773e15_thumb.png" alt="SNAGHTML24773e15" width="464" height="313" border="0" /></a>

you should see the management group you’ve configured in the CI remediation script:

<a href="http://blog.tyang.org/wp-content/uploads/2013/11/image22.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2013/11/image_thumb22.png" alt="image" width="459" height="385" border="0" /></a>

If you want to test the Configuration Baseline, you can simply delete the management group from the Microsoft Monitoring Agent, and then click the "Evaluate" button in ConfigMgr client under "Configuration Tab". If everything is working as expected, the configuration baseline will show as compliant and the management group is added back to the Microsoft Monitoring Agent.

<strong><span style="color: #ff0000;">Note:</span></strong> In the scenarios I mentioned earlier that sometimes when we need to temporarily move OpsMgr agents to different management groups, we will need to modify the collections which the Configuration Baselines are targeting to. To do so, I can firstly create a temp collection to include all OpsMgr agents that I need to move, then exclude this collection from the original Configuration Baseline collection and include it in the Configuration Baseline collection for the target management group. This is so much easier and flexible and we don’t even have to manually move the OpsMgr agents as the Configuration Baseline is going to move them for us.

<strong><span style="color: #ff0000;">Note:</span></strong> Please also be aware of the security setting configured for the OpsMgr management group:

<a href="http://blog.tyang.org/wp-content/uploads/2013/11/SNAGHTML2480b666.png"><img style="display: inline; border-width: 0px;" title="SNAGHTML2480b666" src="http://blog.tyang.org/wp-content/uploads/2013/11/SNAGHTML2480b666_thumb.png" alt="SNAGHTML2480b666" width="487" height="332" border="0" /></a>

If the management group is configured to reject new manual agent installations, you will never see any newly installed & configured OpsMgr agents in the OpsMgr console. You need set it to either automatically approve or review manually installed agents.

<strong>Summary</strong>

By using this method, in an environment with multiple OpsMgr 2012 R2 management group, we can avoid creating multiple applications for OpsMgr 2012 R2 Agent (for different management group) and avoid creating potentially complicated global conditions for the application deployment.

This method also ensures both the OpsMgr 2012 R2 agent installation and configuration is enforced. This prevents anyone with admin access on the endpoint to uninstall OpsMgr 2012 R2 agent or modify it’s configurations.