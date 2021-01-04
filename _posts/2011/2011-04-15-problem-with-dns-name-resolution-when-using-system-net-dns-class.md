---
id: 435
title: Problem with DNS name resolution when using System.Net.DNS class
date: 2011-04-15T22:51:00+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=435
permalink: /2011/04/15/problem-with-dns-name-resolution-when-using-system-net-dns-class/
categories:
  - DNS
  - PowerShell
tags:
  - DNS
  - PowerShell
  - System.Net.DNS
---
I recently ran into a problem when writing a PowerShell script to perform DNS Name resolution using .NET class <strong>System.Net.DNS (<a href="http://msdn.microsoft.com/en-us/library/system.net.dns.aspx">http://msdn.microsoft.com/en-us/library/system.net.dns.aspx</a>)</strong>.

I noticed when I’m using System.Net.DNS to perform reverse lookup (GetHostByAddress method), even though the PTR record is missing in DNS, it is still able to resolve the name. It looks like this method connects to the host to retrieve its host name.

When the machine is powered off, GetHostByAddress method is unable to resolve the IP address to it’s name (Which is desired result because there is no PTR record in reverse lookup zone):

<a href="http://blog.tyang.org/wp-content/uploads/2011/04/image3.png"><img style="padding-right: 0px; display: inline; padding-left: 0px; background-image: none; padding-top: 0px; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/04/image3_thumb.png" border="0" alt="image" width="832" height="377" /></a>

I then powered on the machine (Jump01), now I get different result. the IP address has been resolved to the host name:

<a href="http://blog.tyang.org/wp-content/uploads/2011/04/image11.png"><img style="padding-right: 0px; display: inline; padding-left: 0px; background-image: none; padding-top: 0px; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/04/image11_thumb.png" border="0" alt="image" width="833" height="336" /></a>

Because of the inconsistent result, I am not able to use System.Net.DNS class (even there are few other methods in this class, but the results are all the same).

What I really need is a way to perform DNS name resolution and provides SAME result as using <strong>nslookup</strong>. I found several PowerShell community projects, but none of them suits my requirement:

<strong>dnsutil.ps1</strong>:

Source: <a href="http://gsexdev.blogspot.com/2006/09/powershell-dns-utility-script-for.html">http://gsexdev.blogspot.com/2006/09/powershell-dns-utility-script-for.html</a>.

Reason: C# code wrapped inside the PowerShell script. Only works on 32bit PowerShell console.

<strong>C# .NET DNS query component</strong>:

Source: <a href="http://www.codeproject.com/KB/IP/dnslookupdotnet.aspx">http://www.codeproject.com/KB/IP/dnslookupdotnet.aspx</a>

Guide: <a href="http://thepowershellguy.com/blogs/posh/archive/2007/04/10/add-extended-dns-support-to-powershell-in-5-minutes.aspx">http://thepowershellguy.com/blogs/posh/archive/2007/04/10/add-extended-dns-support-to-powershell-in-5-minutes.aspx</a>

Reason: Does not perform PTR (reverse) lookup.

<strong>DnDns.dll:</strong>

Source & Guide: <a href="http://securitythroughabsurdity.com/2008/02/dndns-net-dns-client-library-resolver.html">http://securitythroughabsurdity.com/2008/02/dndns-net-dns-client-library-resolver.html</a>

Reason: It does not perform what it claims to do. I.e. The DnsQueryRequest.Resolve method only takes 4 parameters, not 5 as what instruction says. Also, it does not resolve IP to name. (for example, it does not resolve 192.168.1.26, but it resolves 26.1.168.192.in-addr.arpa).

<strong>DNSShell:</strong>

Source & Guide: <a href="http://dnsshell.codeplex.com/">http://dnsshell.codeplex.com/</a>

Reason: this works great and it’s easy to use. can perform reverse lookup using a single PowerShell Cmdlet <strong>Get-DNSRecord</strong>. However, I need to place the source to %PSModulePath% and import the module in PowerShell. I cannot do this to the production server which I use to run my script.

At the last, I found a freeware called <a href="http://www.simpledns.com/dns-client-lib.aspx">JHSoftware.DnsClient</a> and it solved my problem!

<a href="http://blog.tyang.org/wp-content/uploads/2011/04/image15.png"><img style="padding-right: 0px; display: inline; padding-left: 0px; background-image: none; padding-top: 0px; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/04/image15_thumb.png" border="0" alt="image" width="803" height="268" /></a>

As shown above

1. I first load the dll into Powershell

```powershell
[System.Reflection.Assembly]::LoadFile("&lt;path-to-DLL&gt;")
```

2. nslookup, make sure the PTR record does not exist

3. use the LookupReverse method from JHSoftware.DNSClient class the perform reverse lookup on 192.168.1.26 (JUMP01). it could not find it and an error was thrown.

```powershell
[JHSoftware.DNSClient]::LookupReverse("192.168.1.26")
```

4. Modify the PowerShell command, used Try-Catch statement, produced more user friendly output.

```powershell
Try {[JHSoftware.DNSClient]::LookupReverse("192.168.1.26")} Catch {"PTR Record not found!"}
```

5. use same method (LookupReverse) to perform reverse lookup on one of my SCCM server, it successfully returned the FQDN.

This is to do with my DNS record check which is part of my <a href="http://blog.tyang.org/2011/03/30/powershell-script-sccm-health-check">SCCM Health Check script</a> that I posted in previously. I am rewriting the DNS records check in the script as it produces inaccurate result. I have already completed the ability of utilizing PowerShell Remoting to check inboxes backlogs as I mentioned in the previous post. I will post the updated SCCM Health Check script in the next few days.