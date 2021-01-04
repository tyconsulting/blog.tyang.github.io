---
id: 983
title: 'PowerShell Script: Calculate First and Last IP of a Subnet'
date: 2012-02-09T09:29:20+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=983
permalink: /2012/02/09/powershell-script-calculate-first-and-last-ip-of-a-subnet/
categories:
  - PowerShell
tags:
  - PowerShell
---
I just wrote this script to calculate the first and last IP of a subnet based on any given IP (within the subnet) and it's subnet mask:

<strong>Syntax:</strong> .\Get-NetworkStartEndAddress.ps1 "IP address" "Subnet Mask"

<a href="http://blog.tyang.org/wp-content/uploads/2012/02/Get-NetworkStartEndingAddress.png"><img class="alignnone size-full wp-image-984" title="Get-NetworkStartEndingAddress" src="http://blog.tyang.org/wp-content/uploads/2012/02/Get-NetworkStartEndingAddress.png" alt="" width="661" height="296" /></a>

Download here: <a href="http://blog.tyang.org/wp-content/uploads/2012/02/Get-NetworkStartEndAddress.ps1_.txt">Get-NetworkStartEndAddress.ps1</a>