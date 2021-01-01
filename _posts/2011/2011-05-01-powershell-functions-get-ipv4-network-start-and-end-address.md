---
id: 462
title: 'PowerShell Functions: Get IPV4 Network Start and End Address'
date: 2011-05-01T18:19:47+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=462
permalink: /2011/05/01/powershell-functions-get-ipv4-network-start-and-end-address/
categories:
  - PowerShell
tags:
  - IP Address
  - Networking
  - Powershell
---
I wrote 2 PowerShell functions today: **Get-IPV4NetworkStartIP** and **Get-IPV4NetworkEndIP**.
**Input:** Network IP address in [CIDR notation Format](http://en.wikipedia.org/wiki/CIDR_notation)
**Output:** The start or end IP ([System.Net.IPAddress](http://msdn.microsoft.com/en-us/library/system.net.ipaddress.aspx) object).
**Get-IPV4NetworkStartIP:**

```powershell
Function Get-IPV4NetworkStartIP ($strNetwork)
{
$StrNetworkAddress = ($strNetwork.split("/"))[0]
$NetworkIP = ([System.Net.IPAddress]$StrNetworkAddress).GetAddressBytes()
[Array]::Reverse($NetworkIP)
$NetworkIP = ([System.Net.IPAddress]($NetworkIP -join ".")).Address
$StartIP = $NetworkIP +1
#Convert To Double
If (($StartIP.Gettype()).Name -ine "double")
{
$StartIP = [Convert]::ToDouble($StartIP)
}
$StartIP = [System.Net.IPAddress]$StartIP
Return $StartIP
}
```

**Get-IPV4NetworkEndIP:**

```powershell
Function Get-IPV4NetworkEndIP ($strNetwork)
{
$StrNetworkAddress = ($strNetwork.split("/"))[0]
[int]$NetworkLength = ($strNetwork.split("/"))[1]
$IPLength = 32-$NetworkLength
$NumberOfIPs = ([System.Math]::Pow(2, $IPLength)) -1
$NetworkIP = ([System.Net.IPAddress]$StrNetworkAddress).GetAddressBytes()
[Array]::Reverse($NetworkIP)
$NetworkIP = ([System.Net.IPAddress]($NetworkIP -join ".")).Address
$EndIP = $NetworkIP + $NumberOfIPs
If (($EndIP.Gettype()).Name -ine "double")
{
$EndIP = [Convert]::ToDouble($EndIP)
}
$EndIP = [System.Net.IPAddress]$EndIP
Return $EndIP
}
```

**Usage:**

* Get-IPV4NetworkStartIP "192.168.1.0/24"
* Get-IPV4NetworkEndIP "192.168.1.0/24"

**Examples:**

![1](http://blog.tyang.org/wp-content/uploads/2011/05/image.png)
