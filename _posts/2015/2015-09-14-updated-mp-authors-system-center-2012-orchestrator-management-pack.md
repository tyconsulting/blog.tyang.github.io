---
id: 4578
title: 'Updated MP Author&#8217;s System Center 2012 Orchestrator Management Pack'
date: 2015-09-14T16:05:50+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=4578
permalink: /2015/09/14/updated-mp-authors-system-center-2012-orchestrator-management-pack/
categories:
  - SC Orchestrator
  - SCOM
tags:
  - Management Pack
  - Orchestrator
  - SCOM
---

## Background

Over the last week or so, I’ve been busy creating Squared Up dashboards for various System Center 2012 components, which will be made publicly available through Squared Up’s new community site. While I was creating dashboards for some System Center components, I realised how little do the native MP from Microsoft offers (i.e. Orchestrator and Windows Azure Pack).  Luckily, some awesome MP developers have recognised this and released additional MPs to fill the gaps. i.e
<ul>
 	<li>Brian Wren’s (aka MP Author) Orchestrator Runbook Sample MP: <a title="https://gallery.technet.microsoft.com/Orchestrator-Runbook-90307b26" href="https://gallery.technet.microsoft.com/Orchestrator-Runbook-90307b26">https://gallery.technet.microsoft.com/Orchestrator-Runbook-90307b26</a></li>
 	<li>Oskar Landman’s Windows Azure Pack (WAP) MP: <a title="https://gallery.technet.microsoft.com/SCOM-Management-Pack-3855607d" href="https://gallery.technet.microsoft.com/SCOM-Management-Pack-3855607d">https://gallery.technet.microsoft.com/SCOM-Management-Pack-3855607d</a></li>
</ul>
So in additional to creating Squared Up dashboards for the native System Center management packs, I have also created dashboards for above mentioned community MPs.

However, if you have used (or tried to use) Brian’s Orchestrator Runbook MP, you’d probably know the PowerShell scripts in the MP is not compatible with Windows Server 2012 R2 or PowerShell version 3 and later. The issue is raised in the Q and A section (in a function, you can not use return in try-catch-finally statement).

## Updated MP

I have tried to implement this MP a while back at my previous job. Not only I tried to update the PowerShell scripts, in my opinion, I did not want to create another "Runbook Host" class (by creating few registry keys and values) for hosting runbooks. Therefore, I’ve made another update to this MP: I’ve removed "Runbbook Host" class, and configured the "Orchestrator Runbooks" objects to be hosted by the Orchestrator Management Server:

<a href="http://blog.tyang.org/wp-content/uploads/2015/09/image7.png"><img style="padding-top: 0px;padding-left: 0px;padding-right: 0px;border: 0px" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/09/image_thumb7.png" alt="image" width="396" height="321" border="0" /></a>

You can also see the hosting stack in Squared Up (the critical object on the top is the runbook, and the critical object at the bottom is the Windows Computer:

<a href="http://blog.tyang.org/wp-content/uploads/2015/09/image8.png"><img style="padding-top: 0px;padding-left: 0px;padding-right: 0px;border: 0px" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/09/image_thumb8.png" alt="image" width="547" height="201" border="0" /></a>

After I updated this MP  (must be over a year ago), I've never bothered to publish it. Few weeks ago, my fellow SCCDM MVP Adin Ermie had a requirement for a fixed version. That's when I realised I worked on it last year. When I gave Adin my version, he has also found out I fixed some scripts, but not all of them. So I updated it again, tested it myself today, and made sure the runbooks are correctly discovered and monitored.

## Upgrade Compatibility

If you have already imported the original MP in your management group, I am afraid my updated version will not be compatible for in place upgrade, because I have removed various elements from the original MP (class definition, discoveries, etc.), and I have also used another key to seal the MP. These changes made the updated MP not compatible for in-place upgrade. So, if you’d like to use my version, you will have to delete the original version from your management group first.

## Configuring the Management Pack

From Brian’s original MP download, there is also a MP guide included. As stated in the original MP guide, you will need to create few registry keys and values for the Runbook Host as well as creating a Run As account that has access to the Orchestrator Web Service.

When using this updated MP, it is obvious that you do not need to create those registry keys and values anymore because the "Runbook Host" class has been removed. But you will still need to create this Run As account and assign it to the "Orchestrator Web Service Account" Run As Profile:

<a href="http://blog.tyang.org/wp-content/uploads/2015/09/SNAGHTMLb7e815f.png"><img style="padding-top: 0px;padding-left: 0px;padding-right: 0px;border: 0px" title="SNAGHTMLb7e815f" src="http://blog.tyang.org/wp-content/uploads/2015/09/SNAGHTMLb7e815f_thumb.png" alt="SNAGHTMLb7e815f" width="460" height="359" border="0" /></a>

However, since I have removed the "Runbook Host" class, instead of distributing this Run As account to the health service hosting the "Runbook Host" class instance, you will need to distribute it to your Orchestrator management servers instead.

You may also want to monitor the "Monitor runbooks". If this is the case, you will need to enable the "Runbook Running" monitor for the "MPAuthor Monitor Runbooks" group:

<a href="http://blog.tyang.org/wp-content/uploads/2015/09/SNAGHTMLb8fdd57.png"><img style="padding-top: 0px;padding-left: 0px;padding-right: 0px;border: 0px" title="SNAGHTMLb8fdd57" src="http://blog.tyang.org/wp-content/uploads/2015/09/SNAGHTMLb8fdd57_thumb.png" alt="SNAGHTMLb8fdd57" width="611" height="285" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2015/09/image9.png"><img style="padding-top: 0px;padding-left: 0px;padding-right: 0px;border: 0px" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/09/image_thumb9.png" alt="image" width="447" height="464" border="0" /></a>

I have enabled this monitor in my lab, and the Squared Up dashboard I created ended up look like this:

<a href="http://blog.tyang.org/wp-content/uploads/2015/09/image10.png"><img style="padding-top: 0px;padding-left: 0px;padding-right: 0px;border: 0px" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/09/image_thumb10.png" alt="image" width="688" height="389" border="0" /></a>

## Credit

Obviously, big thank-you would go to <a href="https://twitter.com/MPAuthor">Brian Wren</a>, for developing this MP and made the entire VSAE project available for everyone. I’d also like to thank my fellow SCCDM MVP <a href="http://micloud.azurewebsites.net/">Adin Ermie</a> for testing it for me.

## Download

You can download my updated MP from the link below. Please feel free to contact me if you have any questions or issues.

[wpdm_package id='4565']

<strong>GitHub Repo</strong>

<a href="https://github.com/tyconsulting/SCOM.MP_Updated_MPAUthor.Orchestrator">https://github.com/tyconsulting/SCOM.MP_Updated_MPAUthor.Orchestrator</a>

&nbsp;

&nbsp;