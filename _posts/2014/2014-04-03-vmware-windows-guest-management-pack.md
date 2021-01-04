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
This Monday, I was configuring monitoring for all our System Center 2012 servers as per our Windows support team’s requirement. Since all the virtual machines for our System Center 2012 servers are hosted on VMware ESX, they want to monitor the VMware Tools service on these guest VM’s. Since it was Monday morning and I had one bottle of wine the night before, I thought instead of write it myself, I’ll see if I can find a MP for this from the community so my brain can have a bit of rest. Unfortunately, I didn’t have too much luck as I couldn’t find a free and simple MP just to monitor the VMware guest VM’s :worried:

So I spent some time this week and quickly wrote a very simple management pack to monitor VMware Tools. Below is what’s included in this MP:

**Class definitions:**

* VMware Guest Windows Computer Role
  * Based on Microsoft.Windows.ComputerRole
	![](http://blog.tyang.org/wp-content/uploads/2014/04/image.pn)
* VMware Tools
  * Based on Microsoft Windows.ApplicationComponent
  * Hosted by VMware Guest Windows Computer Role
	![](http://blog.tyang.org/wp-content/uploads/2014/04/image1.png)

**Discoveries for above mentioned classes**

**Monitors:**

* Basic Service monitor for VMware Tools service

  * Target: VMware Tools
* VMware Tools Installation Status Monitor - A monitor to monitor if VMware Tools is installed
  * Target: VMware Guest Windows Computer Role
* Dependency monitors to rollup VMware Tools health to it’s hosting class "VMware Guest Windows Computer Role".

![](http://blog.tyang.org/wp-content/uploads/2014/04/image2.png)

This MP is written using OpsMgr 2007 MP schema so it should work on both 2007 and 2012 versions. It can be downloaded [HERE](http://blog.tyang.org/wp-content/uploads/2014/04/VMware.Guest_.Monitoring.zip).

Since it’s a pretty simple MP, I didn’t bother to spend time writing a documentation. If you have questions or issues, please feel free to contact me.