---
id: 5378
title: HybridWorkerToolkit PowerShell Module Updated to Version 1.0.3
date: 2016-04-23T22:40:31+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=5378
permalink: /2016/04/23/hybridworkertoolkit-powershell-module-updated-to-version-1-0-3/
categories:
  - Azure
  - OMS
  - PowerShell
tags:
  - Azure Automation
  - OMS
  - Powershell
---
Few days ago, I published a PowerShell Module to be used on Azure Automation Hybrid Workers called HybridWorkerToolkit. You can find my blog article <a href="http://blog.tyang.org/2016/04/20/new-powershell-module-hybridworkertoolkit/">HERE</a>.

Yesterday, my good friend and fellow CDM MVP Daniele Grandini (<a href="https://twitter.com/DanieleGrandini">@DanieleGrandini</a>) gave me some feedback, so I’ve updated the module again and incorporated Daniele’s suggestions.

This is the list of updates in this release:
<ul>
 	<li>A new array parameter for New-HybridWorkerEventEntry called “<strong>-AdditionalParameters</strong>”. This parameter allows users to insert an array of additional parameters to be added in the event data:</li>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2016/04/SNAGHTMLb6e7547.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLb6e7547" src="http://blog.tyang.org/wp-content/uploads/2016/04/SNAGHTMLb6e7547_thumb.png" alt="SNAGHTMLb6e7547" width="588" height="391" border="0" /></a>
<ul>
 	<li>A new Boolean parameter for New-HybridWorkerEventEntry called “<strong>-LogMinimum</strong>”. This is an optional parameter with the default value of $false. When this parameter is set to true, other than the user specified messages and additional parameters, only the Azure Automation Job Id will be logged as event data:</li>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2016/04/image-4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/04/image_thumb-4.png" alt="image" width="588" height="274" border="0" /></a>

As we all know, we pay for the amount of data gets injected into our OMS workspace, this parameter allows you to minimise the size of your events (thus saves money on your OMS spending).

I have published this new release to both <a href="https://github.com/tyconsulting/HybridWorkerToolkit/releases/tag/1.0.3">GitHub</a> and <a href="https://www.powershellgallery.com/packages/HybridWorkerToolkit/1.0.3">PowerShell Gallery</a>.