---
id: 462
title: 'PowerShell Functions: Get IPV4 Network Start and End Address'
date: 2011-05-01T18:19:47+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=462
permalink: /2011/05/01/powershell-functions-get-ipv4-network-start-and-end-address/
categories:
  - PowerShell
tags:
  - IP Address
  - Networking
  - Powershell
---
<div>I wrote 2 PowerShell functions today: <strong>Get-IPV4NetworkStartIP</strong> and <strong>Get-IPV4NetworkEndIP. </strong></div>
<div><strong>Input:</strong> Network IP address in <a href="http://en.wikipedia.org/wiki/CIDR_notation">CIDR notation Format</a></div>
<div><strong>Output: </strong>The start or end IP (<a href="http://msdn.microsoft.com/en-us/library/system.net.ipaddress.aspx">System.Net.IPAddress</a> object).</div>
<div><strong>Get-IPV4NetworkStartIP:</strong></div>
<div>[sourcecode language="Powershell"]
Function Get-IPV4NetworkStartIP ($strNetwork)
{
$StrNetworkAddress = ($strNetwork.split(&quot;/&quot;))[0]
$NetworkIP = ([System.Net.IPAddress]$StrNetworkAddress).GetAddressBytes()
[Array]::Reverse($NetworkIP)
$NetworkIP = ([System.Net.IPAddress]($NetworkIP -join &quot;.&quot;)).Address
$StartIP = $NetworkIP +1
#Convert To Double
If (($StartIP.Gettype()).Name -ine &quot;double&quot;)
{
$StartIP = [Convert]::ToDouble($StartIP)
}
$StartIP = [System.Net.IPAddress]$StartIP
Return $StartIP
}
[/sourcecode]

</div>
<div><strong>Get-IPV4NetworkEndIP:</strong></div>
[sourcecode language="Powershell"]
Function Get-IPV4NetworkEndIP ($strNetwork)
{
$StrNetworkAddress = ($strNetwork.split(&quot;/&quot;))[0]
[int]$NetworkLength = ($strNetwork.split(&quot;/&quot;))[1]
$IPLength = 32-$NetworkLength
$NumberOfIPs = ([System.Math]::Pow(2, $IPLength)) -1
$NetworkIP = ([System.Net.IPAddress]$StrNetworkAddress).GetAddressBytes()
[Array]::Reverse($NetworkIP)
$NetworkIP = ([System.Net.IPAddress]($NetworkIP -join &quot;.&quot;)).Address
$EndIP = $NetworkIP + $NumberOfIPs
If (($EndIP.Gettype()).Name -ine &quot;double&quot;)
{
$EndIP = [Convert]::ToDouble($EndIP)
}
$EndIP = [System.Net.IPAddress]$EndIP
Return $EndIP
}
[/sourcecode]
<div><strong> </strong></div>
<div><strong>Usage:</strong></div>
<ul>
	<li>Get-IPV4NetworkStartIP “192.168.1.0/24”</li>
</ul>
<ul>
	<li>Get-IPV4NetworkEndIP “192.168.1.0/24”</li>
</ul>
<div><strong>Examples:</strong></div>
<div><a href="http://blog.tyang.org/wp-content/uploads/2011/05/image.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/05/image_thumb.png" border="0" alt="image" width="580" height="900" /></a></div>