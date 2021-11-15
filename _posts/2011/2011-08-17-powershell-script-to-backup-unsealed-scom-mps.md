---
id: 668
title: PowerShell script to backup unsealed SCOM MPs
date: 2011-08-17T09:40:49+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=668
permalink: /2011/08/17/powershell-script-to-backup-unsealed-scom-mps/
categories:
  - SCOM
tags:
  - Backup Management Packs
  - SCOM
---
Not sure if anyone has written this before. I have written this simple script to backup all unsealed management packs.

I have scheduled it to run daily on RMS via Windows Task Scheduler.

<strong>How does it work:</strong>
<ol>
	<li>Backup unsealed MPs to a local folder.</li>
	<li>Delete older backups from local folder</li>
	<li>robocopy backup from local folder to a remote location using purge option (Anything that not exist from source will be deleted from destination. Therefore old backups are deleted from remote folder as well.)</li>
</ol>
<strong>Preparing the script:</strong>

Modify line 21-23 to suit your environment

<a href="https://blog.tyang.org/wp-content/uploads/2011/08/image14.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2011/08/image_thumb14.png" alt="image" width="580" height="81" border="0" /></a>

<strong>$backuproot</strong> – local folder where MPs are backed up to.

<strong>$remoteLocation</strong> – Remote location where backups are robocopied to.

<strong>$daysToKeep</strong> – retention period

Finally, make sure you the account scheduled task runs under has appropriate rights in SCOM.

Download the script <a href="https://blog.tyang.org/wp-content/uploads/2011/08/Backup-UnsealedMPs.zip">HERE</a>.