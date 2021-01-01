---
id: 2447
title: VMware Windows Guest Management Pack
date: 2014-04-03T12:50:05+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=2447
permalink: /2014/04/03/vmware-windows-guest-management-pack/
categories:
  - SCOM
tags:
  - MP Authoring
  - SCOM
---
This Monday, I was configuring monitoring for all our System Center 2012 servers as per our Windows support team’s requirement. Since all the virtual machines for our System Center 2012 servers are hosted on VMware ESX, they want to monitor the VMware Tools service on these guest VM’s. Since it was Monday morning and I had one bottle of wine the night before, I thought instead of write it myself, I’ll see if I can find a MP for this from the community so my brain can have a bit of rest. Unfortunately, I didn’t have too much luck as I couldn’t find a free and simple MP just to monitor the VMware guest VM’s :(

So I spent some time this week and quickly wrote a very simple management pack to monitor VMware Tools. Below is what’s included in this MP:

<strong>Class definitions:</strong>
<ul>
	<li>VMware Guest Windows Computer Role
<ul>
	<li>Based on Microsoft.Windows.ComputerRole</li>
</ul>
</li>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2014/04/image.png"><img style="float: none; margin-left: auto; display: block; margin-right: auto; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2014/04/image_thumb.png" width="555" height="241" border="0" /></a>
<ul>
	<li>VMware Tools
<ul>
	<li>Based on Microsoft Windows.ApplicationComponent</li>
	<li>Hosted by VMware Guest Windows Computer Role</li>
</ul>
</li>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2014/04/image1.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2014/04/image_thumb1.png" width="580" height="227" border="0" /></a>

<strong>Discoveries for above mentioned classes</strong>

<strong>Monitors:</strong>
<ul>
	<li>Basic Service monitor for VMware Tools service
<ul>
	<li>Target: VMware Tools</li>
</ul>
</li>
	<li>VMware Tools Installation Status Monitor - A monitor to monitor if VMware Tools is installed
<ul>
	<li>Target: VMware Guest Windows Computer Role</li>
</ul>
</li>
	<li>Dependency monitors to rollup VMware Tools health to it’s hosting class “VMware Guest Windows Computer Role”.</li>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2014/04/image2.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2014/04/image_thumb2.png" width="580" height="290" border="0" /></a>

This MP is written using OpsMgr 2007 MP schema so it should work on both 2007 and 2012 versions. It can be downloaded <a href="http://blog.tyang.org/wp-content/uploads/2014/04/VMware.Guest_.Monitoring.zip">HERE</a>.

Since it’s a pretty simple MP, I didn’t bother to spend time writing a documentation. If you have questions or issues, please feel free to contact me.