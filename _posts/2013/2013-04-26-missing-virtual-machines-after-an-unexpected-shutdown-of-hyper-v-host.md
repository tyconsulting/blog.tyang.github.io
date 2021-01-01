---
id: 1916
title: Missing Virtual Machines After An Unexpected Shutdown of Hyper-V Host
date: 2013-04-26T00:14:16+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=1916
permalink: /2013/04/26/missing-virtual-machines-after-an-unexpected-shutdown-of-hyper-v-host/
categories:
  - Hyper-V
tags:
  - Hyper-V
---
I’m not having any luck with computers lately. This is why all my recent posts are related to my troubleshooting experience.

Yesterday morning, there were some tradies working in my house fixing a leakage in my shower. I was just about to get in the car leaving home for the MS 70-246 exam, they connected some tools to a powerpoint and popped the safety switch. Therefore all my computers got shutdown unexpectly. I quickly switch the safety switch back on and left home.

After I came home few hours later, I turned all the computers back on and made sure all VM’s were up and running.

Today is a public holiday in Australia and New Zealand, and since I’ve just passed a exam yesterday after 2 months of study, I was going to spend some time with my daughter and trying to stay away from doing more work in the lab.

Unfortunately, my day didn’t turnout as what I’ve planned. This morning, I noticed there were around 15 VMs missing from one of my Windows Server 2012 Hyper-V hosts. I had 21 VMs running on that box and I could only see 6. all the rest were gone from the Hyper-V console.

On this Hyper-V server (named HYPERV01), there are 3 SATA disks and 2 SSDs hosting VMs. I found out all VMs from 2 out of 3 SATA drives went missing.

I checked <em><strong>C:\ProgramData\Microsoft\Windows\Hyper-V\Virtual Machines</strong></em> and all the symbolic links for VM’s are still there. Below errors were logged in the event log:

<a href="http://blog.tyang.org/wp-content/uploads/2013/04/image20.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/04/image_thumb20.png" width="580" height="249" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2013/04/image21.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/04/image_thumb21.png" width="580" height="191" border="0" /></a>

According to <a href="http://support.microsoft.com/kb/2249906">http://support.microsoft.com/kb/2249906</a>, It could be caused by insufficient NTFS permissions. I double, triple checked NTFS permissions, and used icacls command to assign virtual machine SID permission to VHDs and XMLs (as suggested in the KB), it didn’t help.

Another KB, <a href="http://support.microsoft.com/kb/969556">http://support.microsoft.com/kb/969556</a> suggests it’s caused by Intel IPMI driver. Although I’m running Windows Server 2012, not 2008 R2, I still downloaded Intel’s ResetAccess utility as suggested in the KB but it couldn’t run on Windows Server 2012.

KB961804(<a href="http://support.microsoft.com/kb/961804">http://support.microsoft.com/kb/961804</a>) reckons it’s caused by antivirus on access scan and exclusion list. I’m using SCEP (System Center Endpoint Protection) which comes with SCCM 2012. I previously configured exclusion using the Hyper-V antimalware policy template that comes with SCCM, and on top of what’s in the template, I’ve also added few file extensions to the policy (.VHD; .VHDX; .AVHD). However, I didn’t add .XML file type and the path to where VM’s are stored. I couldn’t go to SCCM and fix up the policy – because the Central and the primary site server where my Hyper-V is reporting to are among those 15 missing VM’s.

I didn’t configure to allow users to override SCEP on-access scan settings and exclusion list. So there is no way I could configure SCEP. I’ve then uninstalled SCCM client using "ccmsetup /uninstall" and and uninstalled SCEP agent from Programs and Features in Control panel. I rebooted HYPERV01 after the uninstallation.

After reboot, nothing’s changed. Still not fixed. I then spent next 5-6 hours tried many things including copying all VM’s out of a problematic drive and the reformatted the drive…

I also found in VMM console, the 2 problematic disks (D:\ and E:\) did not show up in the Hyper-V server properties:

<a href="http://blog.tyang.org/wp-content/uploads/2013/04/image22.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/04/image_thumb22.png" width="427" height="634" border="0" /></a>

Under the Storage tab, it showed these 2 drives have 0 GB available but in fact, both of them only have around 200 GB data on the 1 TB drives.

<a href="http://blog.tyang.org/wp-content/uploads/2013/04/image23.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/04/image_thumb23.png" width="580" height="429" border="0" /></a>

I tried to re-import the missing VM’s back, but I got this error:

<a href="http://blog.tyang.org/wp-content/uploads/2013/04/image24.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/04/image_thumb24.png" width="470" height="416" border="0" /></a>

Finally, at 11:00pm, I managed to fix the issue. I uninstalled "Windows Firewall Configuration Provider" from Programs and Features

<a href="http://blog.tyang.org/wp-content/uploads/2013/04/image25.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/04/image_thumb25.png" width="580" height="263" border="0" /></a>

According to some Google search results, it is a part of SCEP client. After uninstallation and a reboot, all my VM’s appeared in the Hyper-V console:

<a href="http://blog.tyang.org/wp-content/uploads/2013/04/image26.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/04/image_thumb26.png" width="467" height="372" border="0" /></a>

For those VMs that were copied back to the formatted drive, I had to configure NTFS permission as per KB2249906 before they could be started (because during the copying processes, the VM SID has lost access). (Tip: use /T switch in icacls command to apply the permission to all files and folders below).

Now I’ll have to put SCCM client back on and re-configure Hyper-V antimalware policy. I’ll leave it to tomorrow…

Anyways, this is how I spent my ANZAC day holiday. Maybe it’s time to get few UPS’s for the lab…