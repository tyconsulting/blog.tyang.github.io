---
id: 4088
title: 'Automating OpsMgr Part 3: New Management Pack Runbook via SMA and Azure Automation'
date: 2015-06-30T16:39:05+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=4088
permalink: /2015/06/30/automating-opsmgr-part-3-new-management-pack-runbook-via-sma-and-azure-automation/
categories:
  - OMS
  - PowerShell
  - SCOM
  - SMA
tags:
  - Automating OpsMgr
  - Azure Automation
  - OMS
  - Powershell
  - SCOM
  - SMA
---
<h3><a href="http://blog.tyang.org/wp-content/uploads/2015/06/OpsMgrExnteded.png"><img class="alignleft size-thumbnail wp-image-4038" src="http://blog.tyang.org/wp-content/uploads/2015/06/OpsMgrExnteded-150x150.png" alt="OpsMgrExnteded" width="150" height="150" /></a>Introduction</h3>
This is the 3rd instalment of the Automating OpsMgr series. Previously on this series:
<ul>
	<li><span style="font-weight: normal;"><a href="http://blog.tyang.org/2015/06/24/automating-opsmgr-part-1-introducing-opsmgrextended-powershell-sma-module/" target="_blank">Automating OpsMgr Part 1: Introducing OpsMgrExtended PowerShell / SMA Module</a></span></li>
	<li><span style="font-weight: normal;"><a href="http://blog.tyang.org/2015/06/28/automating-opsmgr-part-2-sma-runbook-for-creating-configmgr-log-collection-rules/" target="_blank">Automating OpsMgr Part 2: SMA Runbook for Creating ConfigMgr Log Collection Rules</a></span></li>
</ul>
Today, I will demonstrate a rather simple runbook to create a blank management pack in the OpsMgr management group. Additional, I will also demonstrate executing this runbook not only on your On-Premise Service Management Automation (SMA) infrastructure, but also from an Azure Automation account via Hybrid Workers.

Since the Hybrid Worker is a very new component in Azure Automation, I will firstly give a brief introduction before diving into the runbook.
<h3>Azure Automation Hybrid Worker</h3>
Ever since Azure Automation was introduced, it was great solution for automating around your assets and fabric on Azure, but there was lack of capabilities of reaching out to your on-prem data centres. Last month during Microsoft Ignite in Chicago, Microsoft has announced an additional component: Hybrid Workers, which is a Azure Automation runbook worker that you can setup on a on-prem server computer. To find out more, you can watch this Ignite session recording: <a href="https://channel9.msdn.com/Events/Ignite/2015/BRK3451" target="_blank">Automating Operational and management Tasks Using Azure Automation</a>. and my buddy and fellow SCCDM MVP Stanislav Zhelyazkov has also written a good post on this topic: <a title="https://cloudadministrator.wordpress.com/2015/05/04/azure-automation-hybrid-worker-setup/" href="https://cloudadministrator.wordpress.com/2015/05/04/azure-automation-hybrid-worker-setup/">https://cloudadministrator.wordpress.com/2015/05/04/azure-automation-hybrid-worker-setup/</a>

I am not going to go through the steps of setting up hybrid workers as Stan has already covered in his post. As Stan pointed out in his post, currently, any Integration Modules that you imported into your Azure Automation account does not get pushed out Hybrid Workers. Therefore in order to execute the New-OpsMgrMP runbook on your hybrid workers, after you've imported the OpsMgrExtended module in your Azure Automation account,  you must also need to manually copy the module to all your hybrid worker servers. To do so:

1. log on to the hybrid worker, and look up the PSModulePath environment variable. You can do so in PowerShell using <strong>$env:PSModulePath</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2015/06/image26.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/06/image_thumb26.png" alt="image" width="687" height="89" border="0" /></a>

2. Copy the OpsMgrExtended module to a folder that is on the PSModulePath list. Please do not copy it to any folders that are part of your user profile. I have copied it to <strong>"C:\Program Files\WindowsPowerShell\Modules"</strong> folder.
<h3>Operations Manager SDK Connection</h3>
The "Operations Manager SDK" connection must be created in the Azure Automation account, the same way as your On-Prem SMA environment:

<a href="http://blog.tyang.org/wp-content/uploads/2015/06/SNAGHTML1aa0036a.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML1aa0036a" src="http://blog.tyang.org/wp-content/uploads/2015/06/SNAGHTML1aa0036a_thumb.png" alt="SNAGHTML1aa0036a" width="700" height="337" border="0" /></a>

The server  name I used is the FQDN of one of my OpsMgr management server. The user name is a service account I created in my on-prem Active Directory (I believe it's called Legacy AD or LAD now <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" src="http://blog.tyang.org/wp-content/uploads/2015/06/wlEmoticon-smile2.png" alt="Smile" />). i.e. Domain\ServicecAccount.  This is connection is created exactly the same as the one I created in my On-Prem SMA environment.
<h3>New-OpsMgrMP Runbook</h3>
<pre language="PowerShell">workflow New-OpsMgrMP
{
Param(
[Parameter(Mandatory=$true)][String]$Name,
[Parameter(Mandatory=$true)][String]$DisplayName,
[Parameter(Mandatory=$false)][String]$Description,
[Parameter(Mandatory=$false)][String]$Version = "1.0.0.0"
)

#Get OpsMgr SDK connection object
$OpsMgrSDKConn = Get-AutomationConnection -Name "OpsMgrSDK_TYANG"

#Create MP
$MPCreated = InlineScript
{
#Validate MP Name
If ($USING:Name -notmatch "([a-zA-Z0-9]+\.)+[a-zA-Z0-9]+")
{
#Invalid MP name entered
$ErrMsg = "Invalid Management Pack name specified. Please make sure it only contains alphanumeric charaters and only use '.' to separate words. i.e. Your.Company.Test1.MP."
Write-Error $ErrMsg
} else {
#Name is valid, creating the MP
New-OMManagementPack -SDKConnection $USING:OpsMgrSDKConn -Name $USING:Name -DisplayName $USING:DisplayName -Description $USING:Description -Version $USING:Version
}
Return $MPCreated
}

If ($MPCreated)
{
Write-Output "Management Pack `"$Name`" created."
} else {
Write-Error "Unable to create Management Pack `"$Name`"."
}

Write-Output "Done."
}
</pre>
The runbook in Azure Automation and SMA is exactly identical. Please note I have configured the Operations Manager SDK connection name to be identical on Azure Automation and SMA. you will need to update Line 11 of this runbook to the name of the connection you've created:

<a href="http://blog.tyang.org/wp-content/uploads/2015/06/image27.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/06/image_thumb27.png" alt="image" width="529" height="59" border="0" /></a>

<strong>Executing the runbook on SMA:</strong>

Fill out the required parameters. the parameter "Version" is configured as optional in the runbook (with default value of "1.0.0.0"), so I did not enter a version number in that field:

<a href="http://blog.tyang.org/wp-content/uploads/2015/06/image28.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/06/image_thumb28.png" alt="image" width="482" height="416" border="0" /></a>

Result:

<a href="http://blog.tyang.org/wp-content/uploads/2015/06/image29.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/06/image_thumb29.png" alt="image" width="458" height="486" border="0" /></a>

And you can then see the management pack in OpsMgr operational console:

<a href="http://blog.tyang.org/wp-content/uploads/2015/06/image30.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/06/image_thumb30.png" alt="image" width="445" height="450" border="0" /></a>

<strong>Executing Runbook on Azure Automation via Hybrid Worker:</strong>

Fill out the input parameters and select "Hybrid Worker". As you can see, the default value for "Version" parameter has already been prepopulated in the Azure portal:

<a href="http://blog.tyang.org/wp-content/uploads/2015/06/SNAGHTML1aab8ac4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML1aab8ac4" src="http://blog.tyang.org/wp-content/uploads/2015/06/SNAGHTML1aab8ac4_thumb.png" alt="SNAGHTML1aab8ac4" width="690" height="492" border="0" /></a>

Result:

<a href="http://blog.tyang.org/wp-content/uploads/2015/06/image31.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/06/image_thumb31.png" alt="image" width="690" height="347" border="0" /></a>

And then the management pack appeared in OpsMgr operational console:

<a href="http://blog.tyang.org/wp-content/uploads/2015/06/image32.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/06/image_thumb32.png" alt="image" width="463" height="470" border="0" /></a>
<h3>Conclusion</h3>
This is a rather simple runbook sample, the key to this runbook is the "<strong>New-OMManagementPack</strong>" activity from the OpsMgrExtended module.

For those who do not have SMA in their environment, I have just demonstrated how to leverage Azure Automation and Hybrid Workers to perform the same activities. As shown in Stan's blog post, it's rather easy to setup a Hybrid Worker in your environment, all you need is a Windows server with Internet connection. Unlike SMA, you do not need any database servers for Hybrid Workers.

I'd also like to point out, even if you have not opened an Azure Automation account yet, I strongly recommend you to do so and give it a try. You can go on a free tier, which gives you 500 job minutes a month. For testing and up skilling purposes, this is more than enough!

Lastly, if you would also like to see the ability to automatically push out custom modules to Hybrid workers in the future, Please help me and vote this idea in Azure  user voice:

<a title="http://feedback.azure.com/forums/246290-azure-automation/suggestions/8591839-allow-custom-integration-modules-to-be-automatical" href="http://feedback.azure.com/forums/246290-azure-automation/suggestions/8591839-allow-custom-integration-modules-to-be-automatical">http://feedback.azure.com/forums/246290-azure-automation/suggestions/8591839-allow-custom-integration-modules-to-be-automatical</a>