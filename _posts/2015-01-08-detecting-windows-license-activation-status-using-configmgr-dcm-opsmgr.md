---
id: 3652
title: Detecting Windows License Activation Status Using ConfigMgr DCM and OpsMgr
date: 2015-01-08T10:04:21+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=3652
permalink: /2015/01/08/detecting-windows-license-activation-status-using-configmgr-dcm-opsmgr/
categories:
  - SCCM
  - SCOM
tags:
  - SCCM
  - SCOM
---
Hello and Happy New year. You are reading my first post in 2015! This is going to a quick post, something I did this week.

Recently, during a ConfigMgr 2012 RAP (Risk and Health Assessment Program) engagement with Microsoft, it has been identified that a small number of ConfigMgr Windows client computers do not have their Windows License activated. The recommendation from the Microsoft ConfigMgr PFE who’s running the RAP was to create a Compliance (DCM) baseline to detect whether the Windows license is activated on client computers.

To respond to the recommendation from Microsoft, I quickly created a DCM baseline with 1 Configuration Item (CI). The CI uses a simple PowerShell script to detect the Windows license status.

<a href="http://blog.tyang.org/wp-content/uploads/2015/01/image.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/01/image_thumb.png" alt="image" width="400" height="377" border="0" /></a>
<pre language="PowerShell" class="">$InstalledLicense = Get-WmiObject -Query "Select * from SoftwareLicensingProduct Where PartialProductKey IS NOT NULL AND ApplicationID = '55c92734-d682-4d71-983e-d6ec3f16059f'"
Switch ($InstalledLicense.LicenseStatus)
{
0 {"Unlicensed"}
1 {"Licensed"}
2 {"Out-of-Box Grace Period"}
3 {"Out-of-Tolerance Grace Period"}
4 {"Non-Genuine Grace Period"}
5 {"Notification"}
6 {"ExtendedGrace"}
}
</pre>
I configured the CI to only support computers running Windows 7 / Server 2008 R2 and above (as per the minimum supported OS for the SoftwareLicensingProduct WMI class documented on MSDN: <a title="http://msdn.microsoft.com/en-us/library/cc534596(v=vs.85).aspx" href="http://msdn.microsoft.com/en-us/library/cc534596(v=vs.85).aspx">http://msdn.microsoft.com/en-us/library/cc534596(v=vs.85).aspx</a>):

<a href="http://blog.tyang.org/wp-content/uploads/2015/01/image1.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/01/image_thumb1.png" alt="image" width="415" height="369" border="0" /></a>

The CI is configured with 1 compliance rule:

<a href="http://blog.tyang.org/wp-content/uploads/2015/01/image2.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/01/image_thumb2.png" alt="image" width="424" height="440" border="0" /></a>

Next, I created a Compliance baseline and assigned this CI to it. I then deployed the baseline to an appropriate collection. after few hours, the clients have started receiving the baseline and completed the first evaluation:

<a href="http://blog.tyang.org/wp-content/uploads/2015/01/SNAGHTMLfeb9db8.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLfeb9db8" src="http://blog.tyang.org/wp-content/uploads/2015/01/SNAGHTMLfeb9db8_thumb.png" alt="SNAGHTMLfeb9db8" width="328" height="391" border="0" /></a>

Additionally, since I have implemented and configured the latest <a href="http://blog.tyang.org/2014/10/04/updated-configmgr-2012-r2-client-management-pack-version-1-2-0-0/">ConfigMgr 2012 Client MP (Version 1.2.0.0)</a>, this DCM baseline assignments on SCOM managed computers are also discovered in SCOM, any non-compliant status would be alerted in SCOM as well.

<a href="http://blog.tyang.org/wp-content/uploads/2015/01/image3.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/01/image_thumb3.png" alt="image" width="655" height="374" border="0" /></a>

That’s all for today. It is just another example on how to use ConfigMgr DCM, OpsMgr and ConfigMgr 2012 Client MP to quickly implement a monitoring requirement.