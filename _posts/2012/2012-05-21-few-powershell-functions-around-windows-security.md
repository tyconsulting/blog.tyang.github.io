---
id: 1240
title: Few PowerShell Functions Around Windows Security
date: 2012-05-21T20:51:23+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=1240
permalink: /2012/05/21/few-powershell-functions-around-windows-security/
categories:
  - PowerShell
  - Windows
tags:
  - PowerShell
  - Windows
---
As parts of the PowerShell project that I’m currently working on, with the help with other people’s contribution in various forums and blogs, I have produced few PowerShell functions around Windows security:

### Validate Credential

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

Usage:

```powershell
$MyCredential = Get-Credential

$ValidCredential = Validate-Credential $MyCredential
```

### Get Current User Name

```powershell
function Get-CurrentUser
{
  $me = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
  Return $me
}
```

Usage:


```powershell
$me = Get-CurrentUser
```

### Check If Current User has Local Admin Rights

```powershell
function AmI-LocalAdmin
{
  return ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}
```

Usage:


```powershell
$IAmAdmin = AmI-LocalAdmin

$IAmAdmin
```

### Check if a user is a member of a group

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

Usage:

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

### Get Local Machine’s SID

```powershell
function Get-LocalMachineSID
{
  $LocalAdmin = Get-WmiObject -query "SELECT * FROM Win32_UserAccount WHERE domain='$env:computername' AND SID LIKE '%-500'"
  $MachineSID = $localAdmin.SID.TrimEnd("-500")
  Return $MachineSID
}
```

Usage:

```powershell
$LocalMachineSID = Get-LocalMachineSID
```

### Check If an account is a domain account (as opposed to local account)

>**Note:** This function also requires the Get-LocalMachineSID function listed above


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

Usage:

```powershell
#Current User:
$me = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$IsDomainAccount = Is-DomainAccount $me

#Another User (Using User Principal Name @):
$user = new-object system.security.principal.windowsidentity(&lt;a href="mailto:tyang@corp.tyang.org"&gt;tyang@corp.tyang.org&lt;/a&gt;)
$IsDomainAccount = Is-DomainAccount $user
```