---
id: 1240
title: Few PowerShell Functions Around Windows Security
date: 2012-05-21T20:51:23+10:00
author: Tao Yang
#layout: post
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
```powershell
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
```

<strong>Usage:</strong>

```powershell
$MyCredential = Get-Credential

$ValidCredential = Validate-Credential $MyCredential
```
<h1>Get Current User Name</h1>
```powershell
function Get-CurrentUser
{
$me = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
Return $me
}
```

<strong>Usage:</strong>

```powershell
$me = Get-CurrentUser
```
<h1>Check If Current User has Local Admin Rights</h1>
```powershell
function AmI-LocalAdmin
{
return ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}
```

<strong>Usage:</strong>

```powershell
$IAmAdmin = AmI-LocalAdmin

$IAmAdmin
```
<h1>Check if a user is a member of a group</h1>
```powershell
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
```

<strong>Usage:</strong>

```powershell
#Current User:

$me = [System.Security.Principal.WindowsIdentity]::GetCurrent()

$group = "\domain admins"

$IsMember = Check-GroupMembership $me $group

#Another User (Using User Principal Name @):

$user = new-object system.security.principal.windowsidentity("tyang@corp.tyang.org")

$group = "\domain admins"

$IsMember = Check-GroupMembership $user $group
```
<h1>Get Local Machine’s SID</h1>
```powershell
function Get-LocalMachineSID
{
$LocalAdmin = Get-WmiObject -query "SELECT * FROM Win32_UserAccount WHERE domain='$env:computername' AND SID LIKE '%-500'"
$MachineSID = $localAdmin.SID.TrimEnd("-500")
Return $MachineSID
}
```

<strong>Usage:</strong>

```powershell
$LocalMachineSID = Get-LocalMachineSID
```
<h1>Check If an account is a domain account (as opposed to local account)</h1>
<strong><span style="color: #ff0000;">Note:</span></strong> This function also requires the <strong>Get-LocalMachineSID</strong> function listed above

```powershell
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
```

<strong>Usage:</strong>

```powershell
#Current User:

$me = [System.Security.Principal.WindowsIdentity]::GetCurrent()

$IsDomainAccount = Is-DomainAccount $me

#Another User (Using User Principal Name @):

$user = new-object system.security.principal.windowsidentity(&lt;a href="mailto:tyang@corp.tyang.org"&gt;tyang@corp.tyang.org&lt;/a&gt;)

$IsDomainAccount = Is-DomainAccount $user
```