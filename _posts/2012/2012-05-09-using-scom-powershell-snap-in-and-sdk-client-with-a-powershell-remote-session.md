---
id: 1219
title: Using SCOM PowerShell Snap-in and SDK client with a PowerShell Remote Session
date: 2012-05-09T22:11:10+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=1219
permalink: /2012/05/09/using-scom-powershell-snap-in-and-sdk-client-with-a-powershell-remote-session/
categories:
  - PowerShell
  - SCOM
tags:
  - Powershell
  - PS Remoting
  - SCOM
---
Recently, I’ve been working on a utility based on PowerShell scripts using WinForms GUI to perform some SCOM tasks (i.e. create maintenance window, approve manually installed agents, adding network devices, etc.). Since this script is going to be widely used in the organisation when it’s completed, I’ve always kept in mind that when users run this utility, the utility should only connect to SCOM SDK service when required and disconnect as soon as the task is done. In another word, I don’t want this utility to remain connected to the SDK service because Microsoft recommends the concurrent connections should not exceed 50 per management group.

So I did some testing to make sure my scripts disconnects from the RMS SDK service. I opened perfmon on RMS watching the "Client Connections" counter under OpsMgr SDK Service:

![](http://blog.tyang.org/wp-content/uploads/2012/05/image2.png)

![](http://blog.tyang.org/wp-content/uploads/2012/05/image3.png)

and want to make sure the performance counter drops when the script is supposed to disconnect from SCOM management group. In my script, I use both the SCOM PowerShell Snap-in and the SCOM SDK, below is what the code looks like:
## SCOM PowerShell Snap-in

**Connect to management group:**

```powershell
$RMS = "<RMS Server Name>"

Add-PSSnapin Microsoft.EnterpriseManagement.OperationsManager.Client
New-PSDrive -Name:Monitoring -PSProvider:OperationsManagerMonitoring -Root:\
Set-Location "OperationsManagerMonitoring::"
new-managementGroupConnection -ConnectionString:$RMS | Out-Null
Set-Location $RMS
```

**Disconnect from management group:**

```powershell
$CurrentMG = get-managementGroupConnection
if ($CurrentMG -ne $null)
{
  $CurrentMG | Remove-ManagementGroupConnection | Out-Null
}
```
## SCOM SDK
**Firstly, Load Assembly:**

```powershell
[System.Reflection.Assembly]::LoadFrom("$sdkDir\Microsoft.EnterpriseManagement.OperationsManager.Common.dll") | Out-Null
[System.Reflection.Assembly]::LoadFrom("$sdkDir\Microsoft.EnterpriseManagement.OperationsManager.dll") | Out-Null
```

**Connect to management group:**

```powershell
$UserName = "<user name>"
$UserDomain = "<user domain>"
$password = "<password>"
$securePassword = ConvertTo-SecureString $password –AsPlainText -Force

$MGConnSetting = New-Object Microsoft.EnterpriseManagement.ManagementGroupConnectionSettings($RootMS)
$MGConnSetting.UserName = $UserName
$MGConnSetting.Domain = $UserDomain
$MGConnSetting.Password = $SecurePassword
$ManagementGroup = New-Object Microsoft.EnterpriseManagement.ManagementGroup($MGConnSetting)
```

**Disconnect from management group:**

I couldn’t find a "disconnect" method for the [Microsoft.EnterpriseManagement.ManagementGroup](http://msdn.microsoft.com/en-us/library/microsoft.enterprisemanagement.managementgroup_methods.aspx) object. So I tried to simply remove the variable:

```powershell
Remove-Variable ManagementGroup
```

I couldn’t unload the SDK DLLs as I read it’s a limitation in .NET, the only way to unload a loaded DLL is to close the app.

## Test Results:

Regardless which way I use to connect to SCOM (PowerShell Snap-in or SDK), the perf counter does not drop when I tried to disconnect using methods above. In fact, I could only get the counter drop when I close the Powershell console (or exit my GUI app which is just a pure Powershell script).

![](http://blog.tyang.org/wp-content/uploads/2012/05/image4.png)

As shown above, notice that as soon as I exit PowerShell, the counter has dropped by 1.

Therefore, I thought I had 2 options to work around this issue.

1. Getting the script to launch another powershell.exe instance when trying to connect to SCOM every time but by doing so, I can’t really pass data / variable back to my script.

2. Use PowerShell Remoting to create a PS Session on local computer, run whatever needs to run against SCOM and remove the PS Session when it’s done. By doing so, I can still pass variables back to my script.

So I’ve decided to go with PowerShell Remoting. I’ve used "**Enable-PSremoting –force**" cmdlet to enable PS Remoting with all default settings.

I’ll use a simple get-agent cmdlet via PS Remoting as example, I’ve written something like this:

```powershell
$RMS = "<RMS Server Name>"
$AgentName = "<Agent Computer Name>"
$NewSession = new-pssession
$agent = invoke-command  -session $NewSession -ScriptBlock {
param($RMS,$AgentName)

Add-PSSnapin Microsoft.EnterpriseManagement.OperationsManager.Client
New-PSDrive -Name:Monitoring -PSProvider:OperationsManagerMonitoring -Root:\
Set-Location "OperationsManagerMonitoring::"
new-managementGroupConnection -ConnectionString:$RMS | Out-Null
Set-Location $RMS
$Agent = Get-Agent | Where-Object {$_.PrincipalName -imatch $AgentName}
$Agent
} -ArgumentList $RMS, $AgentName
Remove-PSSession $NewSession
```

I ran above code using an account that is a domain admin in my test environment and it’s also a SCOM administrator in my management group. But somehow I get this error:

<span style="color: #ff0000;">The user does not have sufficient permission to perform the operation.</span>

![](http://blog.tyang.org/wp-content/uploads/2012/05/image5.png)

After some research, I realised that I have to use the CredSSP (Credential Security Support Provider) authentication to pass my credential from the local Powershell session to the PS Remoting session (in this case, also on my local machine). So I modified my script to use Credssp when creating the new PS Session:

```powershell
$me = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$NewSession = new-pssession -ComputerName $env:COMPUTERNAME -Authentication Credssp -Credential (Get-Credential $me)
```

It turned out, after the modification, the code still would not work:

![](http://blog.tyang.org/wp-content/uploads/2012/05/image6.png)

I then found that I will also have to configure the remote session to pass my credential to the remote server again - in this case, the SDK service in SCOM RMS (second hop). so my credential will be passed from **Local PowerShell session –> PS remote session on the local computer –> SCOM RMS SDK Service**.

In addition to "**Enable-PSRemoting –force**", I had perform the following to make it work:

**1. Enable WinRM CredSSP to allow the second hop:**
Via PowerShell:

```powershell
Set-Item WSMAN:\localhost\client\auth\credssp –value $true
Set-Item WSMAN:\localhost\service\auth\credssp –value $true
```

Or Via Group Policy:

* Computer Configuration\Administrative Templates\Windows Components\Windows Remote Management (WinRM)\WinRM Client\Allow CredSSP authentication – Set to "Enabled"
* Computer Configuration\Administrative Templates\Windows Components\Windows Remote Management (WinRM)\WinRM Service\Allow CredSSP authentication – Set to "Enabled"

**2. Configure Credentials Delagations**

in Group Policy (either domain GPO or local policy), under

Computer Configuration\Administrative Templtes\System\Credential Delegation\Allow Delegating Fresh Credentials
* Set to Enabled
* Add "WSMAN/<local computer name>" to the server list

![](http://blog.tyang.org/wp-content/uploads/2012/05/image7.png)

Now, after I updated the group policy (gpupdate /force), the code should just work. As shown below, I have retrieved the agent information using SCOM Powershell Snap-in via a PS remote session.

![](http://blog.tyang.org/wp-content/uploads/2012/05/image8.png)

And now if I take a look at the OpsMgr SDK Service "Client Connections" perf counter:

![](http://blog.tyang.org/wp-content/uploads/2012/05/image9.png)

My script has connected to the SDK service for few seconds then disconnected!
## Conclusion
My code ended up like this:

```powershell
$me = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

$RMS =  "<RMS Server Name>"
$AgentName = "<Agent Computer Name>"
$NewSession = new-pssession -ComputerName $env:COMPUTERNAME -Authentication Credssp -Credential (Get-Credential $me)
$agent = invoke-command  -session $NewSession -ScriptBlock {
  param($RMS,$AgentName)

  Add-PSSnapin Microsoft.EnterpriseManagement.OperationsManager.Client
  New-PSDrive -Name:Monitoring -PSProvider:OperationsManagerMonitoring -Root:\
  Set-Location "OperationsManagerMonitoring::"
  new-managementGroupConnection -ConnectionString:$RMS | Out-Null
  Set-Location $RMS
  $Agent = Get-Agent | Where-Object {$_.PrincipalName -imatch $AgentName}
  $Agent
} -ArgumentList $RMS, $AgentName
Remove-PSSession $NewSession
```

I could not use "localhost" as computer name when creating new PS session (and adding "WSMAN/localhost" in "Allow Delegating Fresh Credentials policy". It doesn’t work.

## More Reading

On OpsMgr SDK service client connections counter:

* [http://blogs.technet.com/b/kevinholman/archive/2008/10/27/how-many-consoles-are-connected-to-my-rms.aspx](http://blogs.technet.com/b/kevinholman/archive/2008/10/27/how-many-consoles-are-connected-to-my-rms.aspx)
* [http://thoughtsonopsmgr.blogspot.com.au/2010/12/how-to-get-alert-when-too-many-scom.html](http://thoughtsonopsmgr.blogspot.com.au/2010/12/how-to-get-alert-when-too-many-scom.html)

On CredSSP , PS Remoting and SCOM PowerShell Cmdlets:

* [http://blogs.msdn.com/b/powershell/archive/2008/06/05/credssp-for-second-hop-remoting-part-i-domain-account.aspx](http://blogs.msdn.com/b/powershell/archive/2008/06/05/credssp-for-second-hop-remoting-part-i-domain-account.aspx)
* [http://blogs.technet.com/b/stefan_stranger/archive/2010/11/02/using-powershell-remoting-to-connect-to-opsmgr-root-management-server-and-use-the-opsmgr-cmdlets.aspx](http://blogs.technet.com/b/stefan_stranger/archive/2010/11/02/using-powershell-remoting-to-connect-to-opsmgr-root-management-server-and-use-the-opsmgr-cmdlets.aspx)

Additionally, I ran into this free ebook about a week ago, Even though I’m still reading it, it’s a pretty good book: [Secrets of PowerShell Remoting](http://www.lulu.com/shop/don-jones-and-tobias-weltner/secrets-of-powershell-remoting/ebook/product-20087080.html)