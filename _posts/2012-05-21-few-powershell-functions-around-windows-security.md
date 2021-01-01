---
id: 1240
title: Few PowerShell Functions Around Windows Security
date: 2012-05-21T20:51:23+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=1240
permalink: /2012/05/21/few-powershell-functions-around-windows-security/
categories:
  - PowerShell
  - Windows
tags:
  - Powershell
  - Windows
---
As parts of the PowerShell project that I’m currently working on, with the help with other people’s contribution in various forums and blogs, I have produced few PowerShell functions around Windows security:
<h1>Validate Credential</h1>
[sourcecode language="PowerShell"]
function Validate-Credential($Cred)
{
$UserName = $Cred.Username
$Password = $Cred.GetNetworkCredential().Password
Add-Type -assemblyname System.DirectoryServices.AccountManagement
$DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Machine)
Try {
$ValidCredential = $DS.ValidateCredentials($UserName, $Password)
} Catch {
#if the account does not have required logon rights to the local machine, validation failed.
$ValidCredential = $false
}
Return $ValidCredential
}
[/sourcecode]

<strong>Usage:</strong>

[sourcecode language="PowerShell"]
$MyCredential = Get-Credential

$ValidCredential = Validate-Credential $MyCredential
[/sourcecode]
<h1>Get Current User Name</h1>
[sourcecode language="PowerShell"]
function Get-CurrentUser
{
$me = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
Return $me
}
[/sourcecode]

<strong>Usage:</strong>

[sourcecode language="PowerShell"]
$me = Get-CurrentUser
[/sourcecode]
<h1>Check If Current User has Local Admin Rights</h1>
[sourcecode language="PowerShell"]
function AmI-LocalAdmin
{
return ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] &quot;Administrator&quot;)
}
[/sourcecode]

<strong>Usage:</strong>

[sourcecode language="PowerShell"]
$IAmAdmin = AmI-LocalAdmin

$IAmAdmin
[/sourcecode]
<h1>Check if a user is a member of a group</h1>
[sourcecode language="PowerShell"]
function Check-GroupMembership ([System.Security.Principal.WindowsIdentity]$User, [string]$GroupName)
{
$WindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($User)

if($WindowsPrincipal.IsInRole($GroupName))
{
$bIsMember = $true
} else {
$bIsMember = $false
}
return $bIsMember
}
[/sourcecode]

<strong>Usage:</strong>

[sourcecode language="PowerShell"]
#Current User:

$me = [System.Security.Principal.WindowsIdentity]::GetCurrent()

$group = “\domain admins”

$IsMember = Check-GroupMembership $me $group

#Another User (Using User Principal Name @):

$user = new-object system.security.principal.windowsidentity(&quot;tyang@corp.tyang.org&quot;)

$group = “\domain admins”

$IsMember = Check-GroupMembership $user $group
[/sourcecode]
<h1>Get Local Machine’s SID</h1>
[sourcecode language="PowerShell"]
function Get-LocalMachineSID
{
$LocalAdmin = Get-WmiObject -query &quot;SELECT * FROM Win32_UserAccount WHERE domain='$env:computername' AND SID LIKE '%-500'&quot;
$MachineSID = $localAdmin.SID.TrimEnd(&quot;-500&quot;)
Return $MachineSID
}
[/sourcecode]

<strong>Usage:</strong>

[sourcecode language="PowerShell"]
$LocalMachineSID = Get-LocalMachineSID
[/sourcecode]
<h1>Check If an account is a domain account (as opposed to local account)</h1>
<strong><span style="color: #ff0000;">Note:</span></strong> This function also requires the <strong>Get-LocalMachineSID</strong> function listed above

[sourcecode language="PowerShell"]
Function Is-DomainAccount ([System.Security.Principal.WindowsIdentity]$User)
{
$LocalMachineSID = Get-LocalMachineSID
if ($User.user.value -ine $LocalMachineSID)
{
$bIsDomainAccount = $true
} else {
$bIsDomainAccount = $false
}
$bIsDomainAccount
}
[/sourcecode]

<strong>Usage:</strong>

[sourcecode language="PowerShell"]
#Current User:

$me = [System.Security.Principal.WindowsIdentity]::GetCurrent()

$IsDomainAccount = Is-DomainAccount $me

#Another User (Using User Principal Name @):

$user = new-object system.security.principal.windowsidentity(&lt;a href=&quot;mailto:tyang@corp.tyang.org&quot;&gt;tyang@corp.tyang.org&lt;/a&gt;)

$IsDomainAccount = Is-DomainAccount $user
[/sourcecode]