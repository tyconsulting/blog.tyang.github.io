---
id: 188
title: Mailbox Archive Tool for Microsoft Exchange Servers
date: 2010-08-13T07:45:18+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=188
permalink: /2010/08/13/mailbox-archive-tool-for-microsoft-exchange-servers/
categories:
  - Microsoft Exchange
  - PowerShell
tags:
  - Exchange 2007
  - Exchange 2010
  - Export-Mailbox
  - Mailbox Archive
  - PowerShell
---
This is another GUI tool based on PowerShell I’ve written in the past.

A company I worked for needed a tool for Service Desk people to archive users’ mailboxes into PST file. I’m not an Exchange engineer, they told me they used to use ExMerge in Exchange 2003 environment but since upgraded to Exchange 2007,  they were no longer able to do so under a GUI interface because ExMerge was replaced by a PowerShell cmdlet "Export-MailBox".

So I wrote <a href="https://blog.tyang.org/wp-content/uploads/2010/08/Mail-Archive.zip">this mailbox archive tool</a>. it basically archives a mailbox into a PST file (with the option to whether delete mailbox after archiving):

<a href="https://blog.tyang.org/wp-content/uploads/2010/08/Screenshot.jpg"><img style="display: inline; border: 0px;" title="Screenshot" src="https://blog.tyang.org/wp-content/uploads/2010/08/Screenshot_thumb.jpg" alt="Screenshot" width="543" height="533" border="0" /></a>

<strong>This tool has been tested and it is working in both Exchange 2007 and 2010 environment.</strong>

<strong>Prerequisites:</strong>
<table border="0" width="615" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td valign="top" width="306"><strong>Exchange 2007</strong></td>
<td valign="top" width="307"><strong>Exchange 2010</strong></td>
</tr>
<tr>
<td valign="top" width="306">32 bit Operating System</td>
<td valign="top" width="307">64 bit Operating System</td>
</tr>
<tr>
<td valign="top" width="306">Outlook 2007</td>
<td valign="top" width="307">64 bit Outlook 2010</td>
</tr>
<tr>
<td valign="top" width="306">32 bit Exchange 2007 Management Tools</td>
<td valign="top" width="307">Exchange 2010 Management Tools</td>
</tr>
<tr>
<td valign="top" width="306">Windows PowerShell</td>
<td valign="top" width="307">Windows PowerShell</td>
</tr>
</tbody>
</table>
Setup operators permissions (Below powershell commands use "Domain\Exchange Operators Group" as an example):
<ul>
	<li><em>add-ExchangeAdministrator -Identity "Domain\Exchange Operators Group" -Role ViewOnlyAdmin -confirm:$false </em></li>
	<li><em>$mailDBs = Get-MailboxDatabase | where {$_.StorageGroup -match "Storage Group"} </em></li>
	<li><em>$mailDBs | add-adpermission -User "Domain\Exchange Operators Group" -AccessRights WriteOwner,WriteDacl -extendedrights ms-Exch-Store-Admin</em></li>
</ul>
Instructions:
<ol>
	<li>Logon to the computer using an account that’s been setup to have the appropriate rights.</li>
	<li>Launch the tool using the shortcut: (Note, I’ve hard coded the path in the shortcut to C:\Scripts\Mail-Archive. please modify the shortcut if required)<a href="https://blog.tyang.org/wp-content/uploads/2010/08/image1.png"><img style="display: inline; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2010/08/image_thumb1.png" alt="image" width="559" height="159" border="0" /></a></li>
	<li>Enter the mailbox and specify PST file location, choose "Delete after export" if desired.</li>
	<li>Click "Run" to begin archiving.</li>
	<li>output and logs are displayed on the output pane.</li>
	<li>Locate the PST file after it’s done<a href="https://blog.tyang.org/wp-content/uploads/2010/08/pst.jpg"><img style="display: inline; border: 0px;" title="pst" src="https://blog.tyang.org/wp-content/uploads/2010/08/pst_thumb.jpg" alt="pst" width="502" height="131" border="0" /></a></li>
	<li>Logs are also created for each export under the log folder:<a href="https://blog.tyang.org/wp-content/uploads/2010/08/image2.png"><img style="display: inline; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2010/08/image_thumb2.png" alt="image" width="466" height="212" border="0" /></a></li>
	<li>Note if export failed because it has reached bad item limit, you can change the threshold in MailArchiveConfig.ini. I’ve set it to 1000, increase it if you like.</li>
</ol>