---
id: 251
title: 'PowerShell Function: Validate Subnet Mask'
date: 2010-09-16T07:12:01+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=251
permalink: /2010/09/16/powershell-function-validate-subnet-mask/
image: /wp-content/uploads/2010/09/routeripicon1.jpg
categories:
  - PowerShell
tags:
  - PowerShell
  - TCP/IP
  - Validate Subnet Mask
---
<p>This is a function I wrote couple of days ago for the <a href="https://blog.tyang.org/2010/09/03/powershell-os-build-script-for-windows-server-2008-2008-r2-and-windows-7/">Windows Build Scripts</a> which I blogged yesterday. I think it is pretty cool so I’d like to blog this function individually:</p>  <p><a href="https://blog.tyang.org/wp-content/uploads/2010/09/image12.png"><img style="border-bottom: 0px; border-left: 0px; display: inline; border-top: 0px; border-right: 0px" title="image" border="0" alt="image" src="https://blog.tyang.org/wp-content/uploads/2010/09/image_thumb12.png" width="579" height="626" /></a> </p>  <p>It checks the following:</p>  <ul>   <li>- if subnet mask is in numeric and consists 4 sections separated by "." </li>    <li>- If each section is ranged between 0 and 255 </li>    <li>- convert it to binary format and make sure it is a valid subnet mask (first part consists all "1"s and second part consists all "0"s). </li> </ul>  <p>So here’s the usage:</p>  <p><a href="https://blog.tyang.org/wp-content/uploads/2010/09/image11.png"><img style="border-right-width: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; border-left-width: 0px" title="image" border="0" alt="image" src="https://blog.tyang.org/wp-content/uploads/2010/09/image_thumb11.png" width="578" height="382" /></a></p>  <p>This function can be downloaded <a href="https://blog.tyang.org/wp-content/uploads/2010/09/ValidateSubnetMask.zip">HERE</a></p>