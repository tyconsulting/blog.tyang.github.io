---
id: 193
title: 'PowerShell: OS Build Script for Windows Server 2008, 2008 R2 and Windows 7'
date: 2010-09-15T17:32:02+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=193
permalink: /2010/09/15/powershell-os-build-script-for-windows-server-2008-2008-r2-and-windows-7/
Featured:
  - Featured
image: /wp-content/uploads/2010/09/icons_windows_100_2.png
categories:
  - PowerShell
  - Windows
tags:
  - Featured
  - Powershell
  - Windows Build Script
---
<strong>Background:</strong>

Around 2 years ago, I originally written a set of script to configure newly built Windows 2008 servers using PowerShell when my previous employer started to deploy their very first Windows 2008 server. These set of scripts were the very first scripts I’ve ever written in PowerShell.

Over the time, I have updated them many times and now they also support Windows 2008 R2 and Windows 7.

<strong>You can download the scripts </strong><a href="http://blog.tyang.org/wp-content/uploads/2010/09/Windows-Build-Script.zip"><strong>HERE</strong></a><strong>.</strong>

<strong>Purpose:</strong>

This set of build script is designed to automate the process of building a Windows server (version 2008 and above). It is designed for environments that do not have server SOEs. The intention is to install the OS with default settings and run these scripts right after the OS install. Although they will also work in Windows Vista and Windows 7, the settings are set according to server standard, they may not be suitable for configuring desktop / laptop for your end users.

Below is a list of items that these scripts will configure for you (and where you can set the values for these items):
<table border="1" cellspacing="0" cellpadding="0" width="579">
<tbody>
<tr>
<td width="149" align="center"><strong>Item</strong></td>
<td width="66" align="center"><strong>Configured by</strong></td>
<td width="72" align="center"><strong>Config-urable</strong></td>
<td width="10" align="center"><strong>Configure from</strong></td>
<td width="280" align="center"><strong>Note</strong></td>
</tr>
<tr>
<td width="149">Rename Computer</td>
<td width="66">1_OSConfig.PS1</td>
<td width="72" align="center">Yes</td>
<td width="10">User Input</td>
<td width="280"> </td>
</tr>
<tr>
<td width="149">Registered Organization</td>
<td width="66">1_OSConfig.PS1</td>
<td width="72" align="center">Yes</td>
<td width="10">Configuration.ini (RegisteredOrg)</td>
<td width="280"> </td>
</tr>
<tr>
<td width="149">Registered Owner</td>
<td width="66">1_OSConfig.PS1</td>
<td width="72" align="center">Yes</td>
<td width="10">Configuration.ini (RegisteredOwner)</td>
<td width="280"> </td>
</tr>
<tr>
<td width="149">Startup &amp; Recovery Options Small Memory dump (256K) Automatically Restart Write an event to the system log</td>
<td width="66">1_OSConfig.PS1</td>
<td width="72" align="center">No</td>
<td width="10"> </td>
<td width="280"> </td>
</tr>
<tr>
<td width="149">Disabling unwanted services</td>
<td width="66">1_OSConfig.PS1</td>
<td width="72" align="center">Yes</td>
<td width="10">Configuration.ini (DisabledService)</td>
<td width="280">Enter the service name (not the display name) for each unwanted services</td>
</tr>
<tr>
<td width="149">Enable Remote Desktop</td>
<td width="66">1_OSConfig.PS1</td>
<td width="72" align="center">No</td>
<td width="10"> </td>
<td width="280"> </td>
</tr>
<tr>
<td width="149">Screen Saver with Password Protection</td>
<td width="66">1_OSConfig.PS1</td>
<td width="72" align="center">No</td>
<td width="10"> </td>
<td width="280"> </td>
</tr>
<tr>
<td width="149">Screen Saver</td>
<td width="66">1_OSConfig.PS1</td>
<td width="72" align="center">Yes</td>
<td width="10">Configuration.ini (ScreenSaverName)</td>
<td width="280">Name of the screen Saver</td>
</tr>
<tr>
<td width="149">Screen Saver time out</td>
<td width="66">1_OSConfig.PS1</td>
<td width="72" align="center">Yes</td>
<td width="10">Configuration.ini (ScreenSaverTimeout)</td>
<td width="280">Screen Saver Time out in seconds</td>
</tr>
<tr>
<td width="149">Force Classic Start Menu</td>
<td width="66">1_OSConfig.PS1</td>
<td width="72" align="center">No</td>
<td width="10"> </td>
<td width="280"> </td>
</tr>
<tr>
<td width="149">Disable Windows Animations</td>
<td width="66">1_OSConfig.PS1</td>
<td width="72" align="center">No</td>
<td width="10"> </td>
<td width="280"> </td>
</tr>
<tr>
<td width="149">Automatically End Hung Applications on ShutDown</td>
<td width="66">1_OSConfig.PS1</td>
<td width="72" align="center">No</td>
<td width="10"> </td>
<td width="280"> </td>
</tr>
<tr>
<td width="149">My Computer Icon Matches System Name on desktop</td>
<td width="66">1_OSConfig.PS1</td>
<td width="72" align="center">No</td>
<td width="10"> </td>
<td width="280"> </td>
</tr>
<tr>
<td width="149">NTP Time source</td>
<td width="66">1_OSConfig.PS1</td>
<td width="72" align="center">Yes</td>
<td width="10">Configuration.ini (NTP)</td>
<td width="280">After joining to the domain, this setting will be ignored as the NTP setting is set to NT5DS</td>
</tr>
<tr>
<td width="149">Disable User Account Control</td>
<td width="66">1_OSConfig.PS1</td>
<td width="72" align="center">No</td>
<td width="10"> </td>
<td width="280"> </td>
</tr>
<tr>
<td width="149">Boot menu time out setting</td>
<td width="66">1_OSConfig.PS1</td>
<td width="72" align="center">Yes</td>
<td width="10">Configuration.ini (BootTimeOut)</td>
<td width="280">Boot menu time out - in seconds</td>
</tr>
<tr>
<td width="149">Power Options - High Performance</td>
<td width="66">1_OSConfig.PS1</td>
<td width="72" align="center">No</td>
<td width="10"> </td>
<td width="280"> </td>
</tr>
<tr>
<td width="149">Regional and Language Options</td>
<td width="66">1_OSConfig.PS1</td>
<td width="72" align="center">Yes</td>
<td width="10">Configuration.ini (UserLocale, SystemLocale, ShortDate)</td>
<td width="280"> </td>
</tr>
<tr>
<td width="149">Configure Time Zone</td>
<td width="66">1_OSConfig.PS1</td>
<td width="72" align="center">Yes</td>
<td width="10">User Input</td>
<td width="280"> </td>
</tr>
<tr>
<td width="149">Configure Network Connections IP Address Subnet Mask Default Gateway</td>
<td width="66">2_network.PS1</td>
<td width="72" align="center">Yes</td>
<td width="10">User Input</td>
<td width="280">Inputs are validated</td>
</tr>
<tr>
<td width="149">Rename Active Connections that have names start with "Local Area Connection"</td>
<td width="66">2_network.PS1</td>
<td width="72" align="center">No</td>
<td width="10"> </td>
<td width="280"> </td>
</tr>
<tr>
<td width="149">Configure DNS Servers</td>
<td width="66">2_network.PS1</td>
<td width="72" align="center">Yes</td>
<td width="10">Configuration.ini (DNSServer)</td>
<td width="280">Enter the DNS server IP address for each DNS server</td>
</tr>
<tr>
<td width="149">Configure DNS Suffix Search List</td>
<td width="66">2_network.PS1</td>
<td width="72" align="center">Yes</td>
<td width="10">Configuration.ini (DNSSuffixSearch)</td>
<td width="280">Enter the domain name for each DNS suffix search</td>
</tr>
<tr>
<td width="149">Disable LMHosts lookup</td>
<td width="66">2_network.PS1</td>
<td width="72" align="center">No</td>
<td width="10"> </td>
<td width="280"> </td>
</tr>
<tr>
<td width="149">Show Network Connection Icon in Sys Tray - Windows 6.0 (2008 &amp; Vista) only</td>
<td width="66">2_network.PS1</td>
<td width="72" align="center">No</td>
<td width="10"> </td>
<td width="280"> </td>
</tr>
<tr>
<td width="149">Disable IPV6</td>
<td width="66">2_network.PS1</td>
<td width="72" align="center">No</td>
<td width="10"> </td>
<td width="280"> </td>
</tr>
<tr>
<td width="149">Rename Local Admin account</td>
<td width="66">3_Security.PS1</td>
<td width="72" align="center">Yes</td>
<td width="10">SecPolicy.inf (NewAdministratorName)</td>
<td width="280"> </td>
</tr>
<tr>
<td width="149">Reset Local Admin Password</td>
<td width="66">3_Security.PS1</td>
<td width="72" align="center">Yes</td>
<td width="10">User Input + Configuration.ini (AdminPassword)</td>
<td width="280">User input to decide if the password needs to be changed. New password stored in configuration.ini</td>
</tr>
<tr>
<td width="149">Rename Local Guest account</td>
<td width="66">3_Security.PS1</td>
<td width="72" align="center">Yes</td>
<td width="10">SecPolicy.inf (NewGuestName)</td>
<td width="280"> </td>
</tr>
<tr>
<td width="149">Reset Local Guest Password</td>
<td width="66">3_Security.PS1</td>
<td width="72" align="center">Yes</td>
<td width="10">Configuration.ini (GuestPassword)</td>
<td width="280"> </td>
</tr>
<tr>
<td width="149">Disable Local Guest account</td>
<td width="66">3_Security.PS1</td>
<td width="72" align="center">No</td>
<td width="10"> </td>
<td width="280"> </td>
</tr>
<tr>
<td width="149">Logon legal notice</td>
<td width="66">3_Security.PS1</td>
<td width="72" align="center">Yes</td>
<td width="10">SecPolicy.inf [Registry Values]</td>
<td width="280">LegalNoticeCaption and LegalNoticeText</td>
</tr>
<tr>
<td width="149">Configure local security policy</td>
<td width="66">3_Security.PS1</td>
<td width="72" align="center">Yes</td>
<td width="10">SecPolicy.inf</td>
<td width="280">SecPolicy.inf will be applied to the computer. Log file: security.log</td>
</tr>
<tr>
<td width="149">Configuring Event Logs (System, Application &amp; Security)</td>
<td width="66">3_Security.PS1</td>
<td width="72" align="center">Yes</td>
<td width="10">SecPolicy.inf</td>
<td width="280">under [system log], [application log] and [security log] section</td>
</tr>
<tr>
<td width="149">Configuring audit policies</td>
<td width="66">3_Security.PS1</td>
<td width="72" align="center">Yes</td>
<td width="10">SecPolicy.inf</td>
<td width="280">Under [Event Audit] section</td>
</tr>
<tr>
<td width="149">Do not display last user name</td>
<td width="66">3_Security.PS1</td>
<td width="72" align="center">Yes</td>
<td width="10">SecPolicy.inf</td>
<td width="280">Under [Registry Values]</td>
</tr>
<tr>
<td width="149">Configure LAN Manager authentication level</td>
<td width="66">3_Security.PS1</td>
<td width="72" align="center">Yes</td>
<td width="10">SecPolicy.inf</td>
<td width="280">Under [Registry Values], In Windows 2008 R2 and Windows 7, by default, it is set to only use NTLM V2. bu</td>
</tr>
</tbody>
</table>