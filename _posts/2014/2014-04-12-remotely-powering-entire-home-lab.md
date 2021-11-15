---
id: 2503
title: Remotely Powering On and Off My Entire Home Lab
date: 2014-04-12T17:45:16+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=2503
permalink: /2014/04/12/remotely-powering-entire-home-lab/
categories:
  - PowerShell
tags:
  - PowerShell
  - PowerShell Web Access
---
My home lab consists of 3 PCs running Hyper-V and a HP Proliant Microserver N54L running SCVMM. I have previously blogged the lab setup in a 2-part blog posts (<a href="https://blog.tyang.org/2012/10/04/my-home-test-lab-part-1/">Part 1</a>, <a href="https://blog.tyang.org/2012/10/05/my-home-test-lab-part-2/">Part 2</a>). These 2 blog articles was written back in October 2012, although there are few changes in the current setup (new hardware, etc), but the overall setup is pretty much the same.

All 4 machines in my lab have been constantly running 24x7, except when we go on holidays or there’s a power outage (which doesn’t happen very often). This is largely because I just can’t be bothered to spend time start and shutdown all the physicals and virtuals every time I use the lab, not to mention I often access my lab when I’m in the office via RDP using my Surface Pro 2 with an external monitor. Because all of the computers are PC grade hardware, there are no out-of-band management cards (i.e. iLo, DRAC, etc.) on these boxes, I had no way to remotely start them when I was in the office.

In order to reduce the "carbon footprint", and more importantly, my electricity bill, I have been wanting to automate the the start and shutdown process of the entire lab for a while. Last weekend, I finally got around to it, and accomplished it by using only Wake On LAN (WOL) and PowerShell (with PowerShell Web Access, WinRM and CredSSP).

Because one of the PCs in my lab is my main desktop (running Windows 8.1 with Hyper-V role enabled), this PC is always running. my solution is to use this desktop (called "Study") to interact with other physical computers in the lab. I’ll now go through the steps I took to archive this goal:

<strong>1. confirm / configure Wake-On-LAN on all physical computers in the lab.</strong>

I installed a freeware called <a href="http://aquilawol.sourceforge.net/">AquilaWOL</a> on my "Study" PC, made sure I can WOL all other computers.

<a href="https://blog.tyang.org/wp-content/uploads/2014/04/image10.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2014/04/image_thumb10.png" width="398" height="364" border="0" /></a>

During my testing, the HP Microserver and one of the Hyper-V box (HyperV01, the one with the Intel motherboard) had no problem at all. However, the other HyperV box HyperV02, would not WOL. after some research, it seemed like a known issue with the motherboard that only be able to WOL when the computer is at sleep, not when it’s powered off. Luckily other than the on-board Marvell NIC, I also have a dual port Intel GB NIC and a single port Intel desktop GB NIC on this computer. the dual port NIC also wouldn’t work. but the desktop NIC worked :smiley:

<strong>2. Installed a Windows Server 2012 R2 virtual machine on my "Study" PC.</strong>

I named this VM "JUMP01" because I intend to use this as a jump box. I connected this VM to the virtual switch  which is on the same subnet as all physical computers – so I don’t rely on switch/routers to relay WOL packets. I also need my AD environment to be available when running the script, but because I have a domain controller already running as a VM on my Study PC, no additional VM’s are required.

<strong>3. Installed and configured PowerShell Web Access on the Jump server.</strong>

So I don’t have to RDP to the jump server to run the scripts. This also enables me to power on / off the lab from any mobile devices with a browser. I have followed <a href="https://blog.tyang.org/2012/11/10/my-first-impression-on-powershell-web-access/">my previous blog post</a> to install and configure PSWA. I also wrote a <a href="https://blog.tyang.org/2014/04/08/powershell-module-resize-console-updated/">PowerShell module</a> to resize PowerShell console size to make PSWA more user-friendly for mobile devices.

<strong>4. Developed PowerShell scripts to power on and power off the physical and virtuals.</strong>

I wrote 2 scripts: start-lab.ps1 and stop-lab.ps1. both scripts read required information from a XML file (labconfig.xml). this XML file contains all required information for my lab environment.

<a href="https://blog.tyang.org/wp-content/uploads/2014/04/SNAGHTML6bd3b2.png"><img style="display: inline; border: 0px;" title="SNAGHTML6bd3b2" alt="SNAGHTML6bd3b2" src="https://blog.tyang.org/wp-content/uploads/2014/04/SNAGHTML6bd3b2_thumb.png" width="514" height="538" border="0" /></a>

The PowerShell scripts utilise WinRM and CredSSP to interact with each physical computers (using PSSessions and Invoke-Command).

Below is a list of steps each script performs:

Start-Lab.ps1:
<ol>
	<li>Read XML, get information for all computers that are a member of the lab</li>
	<li>ping each lab member, send WOL magic packet if ping failed</li>
	<li>wait for 90 seconds (configurable via XML)</li>
	<li>Check OS readiness (configurable via XML)
<ul>
	<li>Minimum up time</li>
	<li>all required services are running</li>
</ul>
</li>
	<li>Once the OS is ready on the Hyper-V hosts, start VMs in groups hardcoded in the script (based on my naming standard in the lab).
<ul>
	<li>firstly start the CentOS VM configured as routers (they are configured to auto start with the host, but just in case they did not start).</li>
	<li>Then start the domain controller</li>
	<li>Then start all VMs hosting SQL databases (OpsMgr DB, ConfigMgr site servers, Service Manager DB, etc).</li>
	<li>Then start all other VMs except OpsMgr management servers</li>
	<li>Lastly, start all OpsMgr management servers (they must be started at the end so I don’t get any alerts).</li>
</ul>
</li>
</ol>
Stop-Lab.ps1:
<ol>
	<li>Read XML, get information for all computers that are a member of the lab</li>
	<li>ping each lab member, ignore the lab member if it does not respond to ping</li>
	<li>shutdown VM’s in order (which is the reverse order as the start-lab.ps1)</li>
	<li>double check if all VM’s are completely shutdown, if not, forcibly turn them off</li>
	<li>shutdown Hyper-V servers (and non-hyper-v physicals).</li>
</ol>
<span style="color: #ff0000;"><strong>Note:</strong></span> the WOL function in my script is taken from here: <a href="http://gallery.technet.microsoft.com/scriptcenter/Send-WOL-packet-using-0638be7b">http://gallery.technet.microsoft.com/scriptcenter/Send-WOL-packet-using-0638be7b</a>

<strong>5. Created a simple PowerShell module to execute the 2 steps I wrote.</strong>

On the jump server, I created a powershell module called "LabAdmin", which contains 2 functions that simply execute the powershell script:

<a href="https://blog.tyang.org/wp-content/uploads/2014/04/image11.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2014/04/image_thumb11.png" width="456" height="330" border="0" /></a>

<strong>6. Configured port forwarding on my ADSL router to allow me to access the PSWA site from the Internet</strong>

This allows me to manage my lab even when I’m not home.

i.e. starting the lab via my mobile phone (over 4G):

<a href="https://blog.tyang.org/wp-content/uploads/2014/04/image12.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2014/04/image_thumb12.png" width="580" height="328" border="0" /></a>

Here are the live demos for both scripts:

<strong>Start-Lab:</strong>

<iframe src="//www.youtube.com/embed/owxLYNCQOkc" height="375" width="640" allowfullscreen="" frameborder="0"></iframe>

<strong>Stop-Lab:</strong>

<iframe src="//www.youtube.com/embed/bjEnAi3tWEk" height="375" width="640" allowfullscreen="" frameborder="0"></iframe>


For your reference, the scripts can be downloaded <a href="https://blog.tyang.org/wp-content/uploads/2014/04/LabAdmin.zip">HERE</a>.

<strong>Conclusion</strong>

I live in Australia, one of the countries with the highest electricity prices. It is time for me to do something to cut down the running cost of my home lab - especially when my colleagues told me their average electricity bills are only half of mine.

Now, I can remotely start my entire lab anywhere via my mobile phone, and it only takes me a single command to shut down the lab, I won’t need to have them running 24x7. So I’m hoping my implemented this new feature in my lab, I should be able to see some noticeable reductions in my next power bill. :smiley: