---
id: 64
title: 'PowerShell Script: Setting NTFS Permissions in Bulk'
date: 2010-07-01T20:39:37+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=64
permalink: /2010/07/01/powershell-script-setting-ntfs-permissions-in-bulk/
categories:
  - PowerShell
tags:
  - NTFS Permission
  - PowerShell
---
Today I wrote <a title="BulkSet-NTFSPermissions.zip" href="http://blog.tyang.org/wp-content/uploads/2010/07/BulkSet-NTFSPermissions.zip"><strong>this</strong></a> PowerShell script to apply a same set of NTFS permission for a particular user or group to a list of folders. It reads the list of folders from a file that is specified from a parameter, apply the permission which is also specified  from parameters. The useage is as follow:

<strong> .\BulkSet-NTFSPermissions.ps1 -FolderListFile x:\xxxx\xxxx.txt -SecIdentity "Domain\Group" -AccessRights "FullControl" -AccessControlType "Allow"</strong>
<ul>
	<li><strong>FolderListFile</strong>: a flat text file containing the list of path that need to apply the NTFS permission. It needs to list one folder per line. the path can be a absolute local path such as <strong>C:\temp</strong> or a UNC path such as <strong>\\computer\C$\temp</strong>.</li>
	<li><strong>SecIdentity</strong>: The security identity (such as a user account or a security group) the permission is applied for.</li>
	<li><strong>AccessRights</strong>: type of access rights, such as FullControl, Read, ReadAndExecute, Modify, etc..</li>
	<li><strong>AccessControlType</strong>: Allow or Deny</li>
</ul>
This script checks the permission before applying for it. if the user / group already has the permission that we specified to a folder from the list, it will skip this folder and move to the next one. I had to use this script to grant a group full control rights to over 9000 folders. It only took around 40 minutes to run. I was very impressed!