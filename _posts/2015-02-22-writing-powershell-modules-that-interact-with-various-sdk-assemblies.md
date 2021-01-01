---
id: 3730
title: Writing PowerShell Modules That Interact With Various SDK Assemblies
date: 2015-02-22T21:27:20+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=3730
permalink: /2015/02/22/writing-powershell-modules-that-interact-with-various-sdk-assemblies/
categories:
  - PowerShell
tags:
  - Powershell
---
Over the last few months, there have been few occasions that I needed to develop PowerShell scripts needed to leverage SDK DLLs from various products such as OpsMgr 2012 R2, SCSM 2012 R2 and SharePoint Client Component SDK.

In order to be able to leverage these SDK DLLs, it is obvious that prior to running the scripts, these DLLs must be installed on the computers where the scripts are going to be executed. However, this may not always be possible, for example:
<ul>
	<li><strong>Version Conflicts (i.e. OpsMgr):</strong> The OpsMgr SDK DLLs are installed into computer’s Global Assembly Cache (GAC) as part of the installation for the Management Server, Operations Console or the Web Console. However, you cannot install any components from multiple OpsMgr versions on the same computer (i.e. Operations console from OpsMgr 2012 and 2007).</li>
	<li><strong>Not being able to install or copy SDK DLLs (i.e. Azure Automation):</strong> If the script is a runbook in Azure Automation, you will not be able to pre-install the SDK assemblies on the runbook servers.</li>
</ul>
&nbsp;

In order to be able to overcome these constraints, I have developed a little trick: developing a simple PowerShell module, placing the required DLLs in the PS module folder and use a function in the module to load the DLLs from the PS Module base folder. I’ll now explain how to develop such PS module. I’ll use the custom module I’ve created for the Service Manager 2012 R2 SDK last week as an example. In this example, I named my customised module "SMSDK".

01. Firstly, create a module folder and then create a new PowerShell module manifest using "New-ModuleManifest" cmdlet.

02. Copy the  required SDK DLLs into the PowerShell Module Folder. The module folder would also contain the manifest file (.psd1) and a module script file (.psm1).

<a href="http://blog.tyang.org/wp-content/uploads/2015/02/SNAGHTML12c34a9.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML12c34a9" src="http://blog.tyang.org/wp-content/uploads/2015/02/SNAGHTML12c34a9_thumb.png" alt="SNAGHTML12c34a9" width="577" height="195" border="0" /></a>

03. Create a function to load the DLLs. In the "SMSDK" module that I’ve written, the function looks like this:
<pre language="PowerShell">Function Import-SMSDK
{
&lt;#
.Synopsis
Load System Center Service Manager 2012 R2 SDK DLLs

.Description
Load System Center Service Manager 2012 R2 SDK DLLs from either the Global Assembly Cache or from the DLLs located in SMSDK PS module directory. It will use GAC if the DLLs are already loaded in GAC.

.Example
# Load System Center Service Manager 2012 R2 SDK DLLs
Import-SMSDK

#&gt;
#SCSM 2012 R2 SDK DLLs
$DLLPath = (Get-Module SMSDK).ModuleBase
$arrDLLs = @()
$arrDLLs += 'Microsoft.EnterpriseManagement.Core.dll'
$arrDLLs += 'Microsoft.EnterpriseManagement.Packaging.dll'
$arrDLLs += 'Microsoft.EnterpriseManagement.ServiceManager.dll'
$AssemblyVersion = '7.0.5000.0'
$PublicKeyToken='31bf3856ad364e35'

#Load SDKs
$bSDKLoaded = $true
Foreach ($DLL in $arrDLLs)
{
$AssemblyName = $DLL.TrimEnd('.dll')
#try load from GAC first
Try {
Write-Verbose "Trying to load $AssemblyName from GAC..."
[Void][System.Reflection.Assembly]::Load("$AssemblyName, Version=$AssemblyVersion, Culture=neutral, PublicKeyToken=$PublicKeyToken")
} Catch {
Write-Verbose "Unable to load $AssemblyName from GAC. Trying PowerShell module base folder..."
#Can't load from GAC, now try PS module folder
Try {
$DLLFilePath = Join-Path $DLLPath $DLL
[Void][System.Reflection.Assembly]::LoadFrom($DLLFilePath)
} Catch {
Write-Verbose "Unable to load $DLL from either GAC or the SMSDK Powershell Module base folder. Please verify if the SDK DLLs exist in at least one location!"
$bSDKLoaded = $false
}
}
}
$bSDKLoaded
}
</pre>
As you can see, In this function, I have hardcoded the DLL file names, assembly version and public key token. The script will try to load the assemblies (with the specific names, version and public key token) from the Global Assembly Cache first (line 32). If the assemblies are not located in the GAC, it will load the assemblies from the DLLs located in the PS Module folder (line 38).

The key to this PS function is, you must firstly identify the assemblies version and public key token. There are 2 ways to can do this:
<ul>
	<li>Using the <a href="https://powershellgac.codeplex.com/">PowerShell GAC module</a> on a machine where the assemblies have already been loaded into the Global Assembly Cache (i.e. in my example, the Service Manager management server):</li>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2015/02/image7.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/02/image_thumb7.png" alt="image" width="683" height="273" border="0" /></a>
<ul>
	<li>Load the assemblies from the DLLs and then get the assemblies details from the current app domain:</li>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2015/02/image8.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/02/image_thumb8.png" alt="image" width="693" height="116" border="0" /></a>

<strong><span style="color: #ff0000;">Note:</span></strong> although you can load the assemblies from the GAC without specifying the version number, in this scenario, you MUST specify the version to ensure the correct version is loaded. It happened to me before when I developed a script that uses OpsMgr SDK, it worked on most of the computers but one computer. It took me a while to find out because the computer had both OpsMgr and Service Manager SDKs loaded in the GAC, the wrong assembly was loaded because I didn’t not specify the version number in the script.

Now, Once the Import SDK function is finalised, you may call it from scripts or other module functions. For example, in my "SMSDK" module, I’ve also created a function to establish connection to the Service Manager management group, called Connect-SMManagementGroup. This function calls the Import SDK (Import-SMSDK) function to load assemblies before connecting to the Service Manager management group:
<pre language="PowerShell">Function Connect-SMManagementGroup
{
&lt;#
.Synopsis
Connect to SCSM Management Group using SDK

.Description
Connect to SCSM Management Group Data Access Service using SDK

.Parameter -SDK
Management Server name.

.Parameter -UserName
Alternative user name to connect to the management group (optional).

.Parameter -Password
Alternative password to connect to the management group (optional).

.Example
# Connect to OpsMgr management group via management server "SCSMMS01" using different credential
$Password = ConvertTo-SecureString -AsPlainText "password1234" -force
$MG = Connect-OMManagementGroup -SDK "SCSMMS01" -Username "domain\SCSM.Admin" -Password $Password

.Example
# Connect to OpsMgr management group via management server "SCSMMS01" using current user's credential
$MG = Connect-OMManagementGroup -SDK "SCSMMS01"
OR
$MG = Connect-OMManagementGroup -Server "SCSMMS01"
#&gt;
[CmdletBinding()]
PARAM (
[Parameter(Mandatory=$true,HelpMessage='Please enter the Management Server name')][Alias('Server','s')][String]$SDK,
[Parameter(Mandatory=$false,HelpMessage='Please enter the user name to connect to the Service manager management group')][Alias('u')][String]$Username = $null,
[Parameter(Mandatory=$false,HelpMessage='Please enter the password to connect to the Service manager management group')][Alias('p')][SecureString]$Password = $null
)

#Check User name and password parameter
If ($Username)
{
If (!$Password)
{
Write-Error "Password for user name $Username must be specified!"
}
}

#Try Loadings SDK DLLs in case they haven't been loaded already
$bSDKLoaded = Import-SMSDK

#Connect to the management group
if ($bSDKLoaded)
{
$MGConnSetting = New-Object Microsoft.EnterpriseManagement.EnterpriseManagementConnectionSettings($SDK)
If ($Username -and $Password)
{
$MGConnSetting.UserName = $Username
$MGConnSetting.Password = $Password
}
$MG = New-Object Microsoft.EnterpriseManagement.EnterpriseManagementGroup($MGConnSetting)
}
$MG
}
</pre>
For your reference, You can download the sample module (SMSDK) <strong><span style="font-size: medium;"><a href="http://blog.tyang.org/wp-content/uploads/2015/02/SMSDK.zip">HERE</a></span></strong>. However, the SDK DLLs are not included in this zip file. For Service Manager, you can find these DLLs from the Service Manager 2012 R2 Management Server, in the &lt;SCSM Management Server Install Dir&gt;\SDK Binaries folder and manually copy them to the PS module folder:

<a href="http://blog.tyang.org/wp-content/uploads/2015/02/image9.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/02/image_thumb9.png" alt="image" width="521" height="122" border="0" /></a>

Lastly, this blog is purely based on my recent experiences. Other than the Service Manager module that I’ve used in this post, I’ve also used this technique in few of my previous work, i.e. the "<a href="http://blog.tyang.org/2014/12/23/sma-integration-module-sharepoint-list-operations/">SharePointSDK" module</a> and the upcoming "OpsMgrExtended" module that will soon be published (You can check out the preview from <a href="http://blog.tyang.org/2015/01/23/microsoft-mvp-community-camp-2015-session-sma-integration-module-opsmgrextended/">HERE</a> and <a href="http://blog.tyang.org/2015/02/01/session-recording-presentation-microsoft-mvp-community-camp-melbourne-event/">HERE</a>). I’d like to hear your thoughts, so please feel free to email me if you’d like to discuss further.