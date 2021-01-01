---
id: 5906
title: Managing Azure Automation Module Assets Using MyGet
date: 2017-02-17T16:29:48+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=5906
permalink: /2017/02/17/managing-azure-automation-module-assets-using-myget/
categories:
  - Azure
  - OMS
  - PowerShell
tags:
  - Azure
  - Azure Automation
  - MyGet
  - OMS
  - Powershell
---
<a href="http://blog.tyang.org/wp-content/uploads/2017/02/SNAGHTML2756703.png"><img style="background-image: none; float: left; padding-top: 0px; padding-left: 0px; margin-left: 0px; display: inline; padding-right: 0px; margin-right: 0px; border: 0px;" title="SNAGHTML2756703" src="http://blog.tyang.org/wp-content/uploads/2017/02/SNAGHTML2756703_thumb.png" alt="SNAGHTML2756703" width="266" height="116" align="left" border="0" /></a>
<h5>Background</h5>
Managing the life cycle of PowerShell module assets in your Azure Automation accounts can be challenging. If  you are currently using Azure Automation, you may have already noticed the following behaviours when managing the module assets:

<strong>1. It is difficult to automate the module asset deployment process.</strong>

If you want to automate the module deployment to your Automation Account (i.e. using the PowerShell cmdlet New-AzureRmAutomationModule), you must ensure the module that you are trying to import is zipped into a zip file and located on a public location where Azure Automation can read via HTTP (i.e. Azure Blob storage). In my opinion, this is over complicated.

<strong>2. Modules are not deployed to the Hybrid Workers automatically</strong>

If you are using Hybrid Workers, you must also manage the modules separately. Unlike Azure runbook workers, Azure Automation does not automatically deploy modules to Hybrid Workers. This means when you import a module to your Azure Automation account, you must also manually deploy it to your Hybrid Worker computers.

<strong>3. Difficult to maintain module version consistencies.</strong>

Since managing modules in your Azure Automation accounts and hybrid workers are two separate processes, it is hard to make sure the versions of your module assets are consistent between your automation account and hybrid worker computers.

Over the past few months, I have invested lot of my time on MyGet and looking for ways to close these gaps. Few months ago, I have released a PowerShell DSC Resource module called cPowerShellPackageManagement (<a title="http://blog.tyang.org/2016/09/15/powershell-dsc-resource-for-managing-repositories-and-modules/" href="http://blog.tyang.org/2016/09/15/powershell-dsc-resource-for-managing-repositories-and-modules/">http://blog.tyang.org/2016/09/15/powershell-dsc-resource-for-managing-repositories-and-modules/</a>). By using this DSC resource module, we can easily develop DSC configurations for computers (such as Hybrid Workers) to automatically install modules from a PowerShell module repository (i.e. a MyGet feed). This approach closes the gaps of managing Hybrid Worker computers (item #2 on the list above). Today, I am going to discuss how we can tackle item #1 and #3. Before I start talking about my solutions, let me quickly introduce MyGet first.
<h5>What is MyGet?</h5>
Myget (<a href="http://www.myget.org">www.myget.org</a>) is a SaaS based package repository hosted on the cloud. It supports all the popular package providers such as NuGet, Npm etc. It can host both private and public repository (called a feed) for you or your organisation.

If you come from a developer or DevOps background, you may have already heard about MyGet in the past, or have used similar on-premises package repositories (such as ProGet). If you are an IT Pro, since you are reading this blog post right now, you must be familiar with PowerShell, therefore must have heard or used PowerShell Gallery (<a href="https://powershellgallery.com">https://powershellgallery.com</a>). You can use MyGet the same way as PowerShell Gallery in PowerShell version 5 and later, except you have absolute control of the content in your feeds. Also,  if you are using a paid MyGet account, you can have private feeds and you can control the access by issuing API keys. You can also create multiple feeds that contain different packages (PowerShell modules in this case). i.e. if you develop PowerShell modules, you can have a Dev feed for you to use during development, and also Test and Production feeds for testing and production uses.
<h5>Why Do I Need MyGet?</h5>
You may be a little bit hesitate to use PowerShell Gallery because it is 100% public. As a regular user like everyone else, you can only do very little. i.e. you can publish modules to PowerShell gallery, but you can’t guarantee your modules will stay there forever. Microsoft may decide to un-list your modules if they find problems with it (i.e. failed to comply with the rules set in the PSScriptAnalyzer). You also don’t have access to delete your modules from PowerShell Gallery. You can un-list your modules, but they are still hosted there. To me, PowerShell Gallery is more like a community platform that allows everyone to share their work, but you should not use it in any production environments because you don’t have any controls on the content, how can you make sure the content you need is going to be there tomorrow?

MyGet allows you to create feeds that you have total control, and as I mentioned already, with a paid MyGet account, you can have private feeds to host your IPs that you don’t want to share with the rest of the world.

MyGet also ships with other awesome features, such as Webhook support.
<h5>Automating Module Deployment to Automation Account</h5>
I have developed a runbook that retrieves a list of modules from a repository (i.e. your MyGet feed), and import each module to the Automation account of where the runbook resides, if the module does not exist or the version is lower than the latest available version from the module repository. Before importing, the runbook also tries to work out the module dependencies and import required modules in groups (i.e. the modules without dependencies are imported first).  Here’s the runbook source code:

https://gist.github.com/tyconsulting/df78d43e64fe86fe772f947fded3c4da

<strong>Note:</strong> this runbook does not download and zip up PowerShell modules from the repository feed. Instead, it construct the URI to the underlying NuGet package and import the package directly to your automation account.

In order to use the runbook, you will need to create a automation variable first.

Name: <strong>ModuleFeedLocation</strong>

Value: <strong>&lt;the source location URI to your repository feed&gt;</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2017/02/image.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; margin: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2017/02/image_thumb.png" alt="image" width="165" height="244" border="0" /></a>

<strong>Note:</strong> if you are not sure what is the source location URI for your feed, check out this help document from MyGet website: <a title="http://docs.myget.org/docs/how-to/publish-a-powershell-module-to-myget" href="http://docs.myget.org/docs/how-to/publish-a-powershell-module-to-myget">http://docs.myget.org/docs/how-to/publish-a-powershell-module-to-myget</a>. However, I don’t believe the documentation is 100% accurate. Based on my experience, no matter if you are using private or public feeds, the Source location URI should be:

<span style="background-color: #ffff00;">https://www.myget.org/F/&lt;feed-name&gt;/<strong>auth/&lt;api-key&gt;/</strong>api/v2</span>

The API key is available on the MyGet portal:

<a href="http://blog.tyang.org/wp-content/uploads/2017/02/image-1.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2017/02/image_thumb-1.png" alt="image" width="344" height="353" border="0" /></a>

if  you have connected to the feed as a PowerShell repository, you can also check using Get-PSRepository cmdlet:

<a href="http://blog.tyang.org/wp-content/uploads/2017/02/image-2.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2017/02/image_thumb-2.png" alt="image" width="598" height="61" border="0" /></a>

Other than the automation variable, you will also need to make sure you have the AzureRunAsConnection connection asset and associated certificate asset created. these assets are created automatically by default when you created your Azure Automation account:

<a href="http://blog.tyang.org/wp-content/uploads/2017/02/image-3.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; margin: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2017/02/image_thumb-3.png" alt="image" width="168" height="244" border="0" /></a>

If you don’t have this connection asset, you can manually create it using PowerShell – this process is documented here: <a title="https://docs.microsoft.com/en-au/azure/automation/automation-sec-configure-azure-runas-account" href="https://docs.microsoft.com/en-au/azure/automation/automation-sec-configure-azure-runas-account">https://docs.microsoft.com/en-au/azure/automation/automation-sec-configure-azure-runas-account</a>

Once the runbook and all required assets are in place, you will also need to create a webhook for the runbook. It is OK to configure the webhook to target Azure workers (although targeting hybrid worker group is also OK, but not necessary).

<a href="http://blog.tyang.org/wp-content/uploads/2017/02/image-4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2017/02/image_thumb-4.png" alt="image" width="371" height="216" border="0" /></a>

Once the webhook is created, go to MyGet portal, go to your feed then go to the Webhook section and add a HTTP POST webhook

<a href="http://blog.tyang.org/wp-content/uploads/2017/02/image-5.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2017/02/image_thumb-5.png" alt="image" width="329" height="296" border="0" /></a>

then enter a description and paste the runbook webhook URL. for the webhook trigger, only tick "Package Added":

<a href="http://blog.tyang.org/wp-content/uploads/2017/02/image-6.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2017/02/image_thumb-6.png" alt="image" width="321" height="276" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2017/02/image-7.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2017/02/image_thumb-7.png" alt="image" width="323" height="278" border="0" /></a>

Once the webhook trigger is created, everything is good to go. when next time you add a PowerShell module or update an existing module on your MyGet feed, it will automatically trigger the Azure Automation runbook, which will find the modules need to be imported and updated, and attempt to import them one a time.

<a href="http://blog.tyang.org/wp-content/uploads/2017/02/image-8.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2017/02/image_thumb-8.png" alt="image" width="693" height="573" border="0" /></a>

<strong>Tips:</strong>

Once you have configured your MyGet feed as a PowerShell repository on a computer running PowerShell v 5 or later, you can publish modules located on your local computer to the feed using <strong>Publish-Module</strong> cmdlet. You can also configure MyGet to get modules from another repository such as PowerShell Gallery. I have blogged this previously: <a title="http://blog.tyang.org/2016/09/20/pushing-powershell-modules-from-powershell-gallery-to-your-myget-feeds-directly/" href="http://blog.tyang.org/2016/09/20/pushing-powershell-modules-from-powershell-gallery-to-your-myget-feeds-directly/">http://blog.tyang.org/2016/09/20/pushing-powershell-modules-from-powershell-gallery-to-your-myget-feeds-directly/</a>

If you want to configure multiple Automation accounts to sync with a single MyGet feed, you can simply create the runbook and required assets in each automation account, and add a webhook trigger for each instance of the runbook within your MyGet feed.
<h5>Things to Watchout</h5>
there are few things that you need to watch out when using this solution:

<strong>1. be aware of the limitations in Azure Automation</strong>

Some of these limitations may impact your module imports. you can find the official documentation here:  <a title="https://docs.microsoft.com/en-us/azure/azure-subscription-service-limits#automation-limits" href="https://docs.microsoft.com/en-us/azure/azure-subscription-service-limits#automation-limits">https://docs.microsoft.com/en-us/azure/azure-subscription-service-limits#automation-limits</a>

<strong>2. Unlike any NuGet repositories such as PowerShell Gallery and MyGet, Azure Automation does not support storing different versions of same module</strong>

This may cause some of the module imports to fail. For example, if you have a module called ModuleA (version 1.0) that is a dependency to ModuleB version 1.0. You have ModuleA 1.0, ModuleB 1.0 and 2.0 in your MyGet repository, the runbook will firstly import ModuleB 2.0 to your automation account first. then when it tries to import ModuleA 1.0, it may fail because it does not pass the validation test (by importing ModuleA 1.0 on the runbook worker computer). so prior to committing these kind of packages to a feed that’s being used by Azure Automation, make sure you test it first on another feed, and make sure you can successfully install and import the module on your local computer.

<strong>3. Do not load too many modules to the feed initially</strong>

Module import into Azure Automation account takes a lot of time. when running a runbook job on Azure workers, the runbook can run maximum 3 hours due to its fair share policy. so if you have a lot of modules to load in the beginning, you need to make sure the runbook job can be completed within 3 hours. or you may have to rerun the runbook to pickup the modules didn’t get imported in the previous runbook job. Alternatively, you can configure the runbook to run on a Hybrid Worker group, because the fair share policy does not apply when the job is being executed on hybrid workers.
<h5>Conclusion</h5>
If you use a dedicated MyGet feed to host all required modules for Azure Automation, you can use the cPowerShellPackageManagement DSC resource module I mentioned earlier in this blog post to automate the module deployment to Hybrid Workers. In the same time, by using the method described in this blog post, you have also got the Automation account covered.

Therefore, if you have both DSC configured for Hybrid Workers (i.e using Azure Automation DSC), and have this runbook and webhook configured, by adding a new package to your MyGet feed, your entire Azure Automation infrastructure is updated automatically.

My MVP buddy Alex Verkinderen also also done some interesting integration between MyGet and PowerShell Gallery. He is going to publish his innovation on his blog (<a title="http://www.mscloud.be/" href="http://www.mscloud.be/">http://www.mscloud.be/</a>) soon, so make sure you subscribe to his blog <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" src="http://blog.tyang.org/wp-content/uploads/2017/02/wlEmoticon-smile.png" alt="Smile" />.

Lastly, thanks Alex for testing the runbook for me, and if anyone has any questions or suggestions, please feel free to contact me.