---
id: 6414
title: OpsMgrExtended PowerShell module is now on GitHub and PSGallery
date: 2018-04-18T00:13:36+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=6414
permalink: /2018/04/18/opsmgrextended-powershell-module-is-now-on-github-and-psgallery/
categories:
  - PowerShell
  - SCOM
tags:
  - Automating OpsMgr
  - OpsMgrExtended
  - PowerShell
  - SCOM
---
I developed the OpsMgrExnteded module back in 2015 and it was freely available from my company’s website. I also wrote a 18-post blog series on <a href="https://blog.tyang.org/tag/automating-opsmgr/" target="_blank" rel="noopener">Automating OpsMgr</a> using this module

I was also aware of a bug in the New-OMOverride function in the module since 2015. I never got around to fix it because my focus has been shifted away from System Center. I just had a requirement to use this module so I have spent a little bit time yesterday and updated it to version 1.3. Here’s the change log:
<ul>
 	<li>Bug fixes in New-OMOverride function</li>
 	<li>Added SCOM 2016 SDK DLLs to the module (SCOM 2016 UR14). There is no need to manually copy the DLLs to the module folder anymore.</li>
 	<li>Updated the module manifest to make it compatible with PowerShell PackageManagement (WMF 5.0)</li>
 	<li>Configured the module to automatically load SCOM 2016 SDK DLLs</li>
 	<li>Removed Install-OpsMgrSDK and Import-OpsMgrSDK functions because they are not required</li>
</ul>
In addition to these updates, I have made the <a href="https://github.com/tyconsulting/OpsMgrExtended-PS-Module" target="_blank" rel="noopener">GitHub repo</a> for this module public and published it to <a href="https://www.powershellgallery.com/packages/OpsMgrExtended" target="_blank" rel="noopener">PowerShell Gallery</a>. Now if you are running PowerShell v5+, you can install this module by simply running:
<pre language='PowerShell'>
Install-Module OpsMgrExtended –Repository PSGallery –Force

```
Please feel free to fork the repo, submit pull requests, or provide feedback.