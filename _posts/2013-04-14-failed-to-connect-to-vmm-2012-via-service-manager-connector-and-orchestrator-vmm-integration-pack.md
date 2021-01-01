---
id: 1887
title: Failed to Connect to VMM 2012 via Service Manager Connector and Orchestrator VMM Integration Pack
date: 2013-04-14T12:48:11+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=1887
permalink: /2013/04/14/failed-to-connect-to-vmm-2012-via-service-manager-connector-and-orchestrator-vmm-integration-pack/
categories:
  - SC Orchestrator
  - SCSM
  - SCVMM
tags:
  - Orchestrator
  - SCSM
  - SCVMM
---
I was thinking about how I can make my study room quieter and cooler as I had 4 desktop machines under my desks. The VMM server in my lab was running on a very old PC. Couple of weeks ago I bought a <a href="http://h10010.www1.hp.com/wwpc/uk/en/sm/WF06b/15351-15351-4237916-4237917-4237917-4248009-5336624.html?dnr=1">HP Proliant N54L Microserver</a> and rebuilt the VMM server on it. I put a 128GB SSD (For OS and all the apps), a 1TB SATA (For VMM Library) and 2x4GB DDR3 memory sticks on it, it runs so quiet, I can hardly hear it.

HP Proliant N54L:

<a href="http://blog.tyang.org/wp-content/uploads/2013/04/712969-375.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="712969-375" alt="712969-375" src="http://blog.tyang.org/wp-content/uploads/2013/04/712969-375_thumb.png" width="179" height="204" border="0" /></a>

&nbsp;

Yesterday, I was going through the labs for Microsoft exam <a href="http://www.microsoft.com/learning/en/us/exam.aspx?id=70-246">70-246: Minotoring and Operating a Private Cloud with System Center 2012</a><em></em> and I ran into issues that I could not create a VMM connector to connect to my new VMM server from Service Manager. I got a very simple error message: <em>“Cannot connect to VMM server &lt;vmm server name&gt;”</em>

<a href="http://blog.tyang.org/wp-content/uploads/2013/04/image15.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/04/image_thumb16.png" width="515" height="360" border="0" /></a>

While I was troubleshooting it, I realised 2 other issues:

1. I couldn’t create a PowerShell remote session to my VMM server using PowerShell command like:

<em><strong>New-PSSession –ComputerName &lt;VMM server FQDN&gt; –Credential &lt;Service Manager VMM Connector Account&gt;</strong></em>

2. After I have created a connection to the new VMM server in the Orchestrator VMM integration pack, I modified an existing test runbook called “Get Cloud” to use the new connection, and it also failed.

All of these worked fine on the old VMM server, WinRM is configured exactly the same between old and new VMM severs because it configured in a domain GPO.

Both these errors were related to some kind of Kerberos authentication errors. (It was very late at night, I forgot to take screenshots while I was troubleshooting it).

After few hours troubleshooting, I have found the problems:

1. During VMM install, I installed SQL server on the VMM server. I somehow installed SSRS (SQL Server Reporting Services) as well although it’s not required for VMM. I had SSRS running on a service account and I have registered the SPN’s for SSRS (i.e. setspn.exe –A http/&lt;VMM server Name&gt; &lt;Service Account&gt;). I realised SSRS was installed by mistake, so I uninstalled it. As soon as I removed the SPN’s for the http service (for SSRS), PowerShell remote sessions started to work. – because PS Remoting also uses http.

2. I then tried to run the VMM PowerShell cmdlet <strong>Get-SCVMMServer</strong> in the remote shell against the VMM server and I got an error:

<em><span style="color: #ff0000;">The type or name syntax of the registry key value IndigoTcpPort under Software\Microsoft\Microsoft System Center Virtual Machine Manager Administrator Console\Settings is incorrect.</span></em>

Luckily I found <a href="http://gokhanyildirim.wordpress.com/2012/05/01/the-type-or-name-syntax-of-the-registry-key-value-indigotcpport-under-softwaremicrosoftmicrosoft-system-center-virtual-machine-manager-administrator-consolesettings-is-incorrect/">this blog article</a>. In my VMM server’s registry, the value <strong>IndigoTcpPort</strong> under <em>HKLM\SOFTWARE\Microsoft\Microsoft System Center Virtual Machine Manager Administrator Console\Settings</em> is a REG_SZ (string) with no value configured. After I deleted it and recreated a REG_DWORD with value 1fa4 (which is hexadecimal for 8100), everything started working. The Get-SCVMMServer cmdlet worked fine. Service Manager VMM Connector was successfully created and Orchestrator runbooks were able to run.

So to summarise what I’ve done. I’ve reviewed and removed the SPN’s for http service which were originally created for SSRS, and corrected the “<strong>IndigoTcpPort</strong>” registry value.

It was not how I would like to spend my Saturday night, but I’m glad I’ve got it fixed so I can continue with my study.