---
id: 2149
title: Few PowerShell One-Liners To Check WinRM Settings on Remote Machines
date: 2013-09-16T22:26:21+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=2149
permalink: /2013/09/16/powershell-one-liners-check-winrm-settings-remote-machines/
categories:
  - PowerShell
tags:
  - PowerShell
  - PowerShell Remoting
---
To Check if WinRM has been enabled on a Remote machine:

```powershell
$RemoteMachine = "Remote Machine Name"

[system.convert]::ToBoolean(((winrm get winrm/config/winrs -r:$remotemachine | ?{$_ -imatch "AllowRemoteShellAccess"}).split("="))[1].trim())
```

To Check the Default HTTP listener port on a remote machine:
```powershell
$RemoteMachine = "Remote Machine Name"

[System.Convert]:: ToInt32(((winrm get winrm/config/Service/DefaultPorts -r:$RemoteMachine | ?{$_ -imatch "HTTP = " }).split("="))[1].trim())
```
To Check the Default HTTPS listener port on a remote machine:
```powershell
$RemoteMachine = "Remote Machine Name"

[System.Convert]:: ToInt32(((winrm get winrm/config/Service/DefaultPorts -r:$RemoteMachine | ?{$_ -imatch "HTTPS = " }).split("="))[1].trim())
```
<a href="http://blog.tyang.org/wp-content/uploads/2013/09/image4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/09/image_thumb4.png" width="580" height="71" border="0" /></a>