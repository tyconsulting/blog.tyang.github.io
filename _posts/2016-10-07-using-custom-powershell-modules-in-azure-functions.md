---
id: 5679
title: Using Custom PowerShell Modules in Azure Functions
date: 2016-10-07T15:31:46+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=5679
permalink: /2016/10/07/using-custom-powershell-modules-in-azure-functions/
categories:
  - Azure
tags:
  - Azure
  - Azure Functions
  - Powershell
---
Like many other fellow MVPs, I have started playing with Azure Functions over the last few weeks. Although Azure Functions are primarily designed for developers and supports languages such as C#, Node.JS, PHP, etc. PowerShell support is currently in preview. This opens a lot of opportunities for IT Pros. My friend and fellow CDM MVP David O’Brien has written some really good posts on PowerShell in Azure Functions (<a title="https://david-obrien.net/" href="https://david-obrien.net/">https://david-obrien.net/</a>). Although the PowerShell runtime in Azure Functions comes with a lot of Azure PowerShell modules by default (refer to David’s post <a href="https://david-obrien.net/2016/07/azure-functions-PowerShell/">here</a> for details), these modules are out-dated, and some times, we do need to leverage other custom modules that are not shipped by default.

While I was trying to figure out a way to import custom modules into my PowerShell Azure Functions, I came across this post showing me how to upload 3rd party assemblies for C# functions: <a title="http://www.robfox.nl/2016/04/27/referencing-external-assemblies-azure-functions/" href="http://www.robfox.nl/2016/04/27/referencing-external-assemblies-azure-functions/">http://www.robfox.nl/2016/04/27/referencing-external-assemblies-azure-functions/</a>. So basically for adding assemblies for C#, you will need to create a folder called “bin” under your function root folder, and upload the DLL to the newly created folder using a FTP client. I thought I’d give this a try for PowerShell modules, and guess what? it worked! I’ll use one of my frequently used module called GAC as an example in this post and work through the process of how to prepare the module and how to use it in my PowerShell code.

01. I firstly download the Gac module from the PowerShell Gallery (<a title="https://www.powershellgallery.com/packages/Gac/1.0.1" href="https://www.powershellgallery.com/packages/Gac/1.0.1">https://www.powershellgallery.com/packages/Gac/1.0.1</a>):
<pre language="PowerShell">Save-Module Gac –repository PSGallery –path C:\temp
</pre>
02. Make sure the Azure Functions App Service has the deployment credential configured

<a href="http://blog.tyang.org/wp-content/uploads/2016/10/image.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/10/image_thumb.png" alt="image" width="343" height="205" border="0" /></a>

03. FTP to the App Service using the deployment credential configured in the preview step, create a “bin” folder under the Azure Functions folder (“/site/wwwroot/&lt;Azure Functions Name&gt;”) and upload the module folder:

<a href="http://blog.tyang.org/wp-content/uploads/2016/10/image-1.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/10/image_thumb-1.png" alt="image" width="384" height="316" border="0" /></a>

04. In Azure Functions, launch the Kudu console

<a href="http://blog.tyang.org/wp-content/uploads/2016/10/image-2.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/10/image_thumb-2.png" alt="image" width="327" height="231" border="0" /></a>

05. Identify the PowerShell module file system path in Kudu. The path is <strong>D:\home\site\wwwroot\&lt;Azure Function Name&gt;\bin\&lt;PS module name&gt;\&lt;PS module version&gt;</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2016/10/image-3.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/10/image_thumb-3.png" alt="image" width="437" height="318" border="0" /></a>

06. By default, the PowerShell runtime is configured to run on 32-bit platform. If the custom module requires 64-bit platform, you will need to configure the app setting and set the Platform to 64-bit

<a href="http://blog.tyang.org/wp-content/uploads/2016/10/image-4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/10/image_thumb-4.png" alt="image" width="426" height="282" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2016/10/image-5.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/10/image_thumb-5.png" alt="image" width="352" height="285" border="0" /></a>

Now that the module is uploaded, and because the module is not located in a folder that’s listed in the PSModulePath environment variable, we have to explicitly import the module manifest (.psd1 file) before using it. For example, I have created a function with only 2 lines of code as shown below:
<pre language="PowerShell">import-module 'D:\home\site\wwwroot\HttpTriggerPowerShell1\bin\Gac\1.0.1\Gac.psd1'
Get-GacAssembly
</pre>
The “Get-GacAssembly” cmdlet comes from the Gac PowerShell module. As the name suggests, it lists all the assemblies located in the Gac (Global Assemblies Cache). When I call the HTTP trigger function using Invoke-WebRequest, you’ll see the assemblies listed in the logs window:

<a href="http://blog.tyang.org/wp-content/uploads/2016/10/image-6.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/10/image_thumb-6.png" alt="image" width="696" height="120" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2016/10/image-7.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/10/image_thumb-7.png" alt="image" width="698" height="459" border="0" /></a>

I have also tested stopping and restarting the Azure App Service, and I can confirm the module files stayed at the original location after the restart based on my tests.

This concludes my topic for today. I have few other really cool blogs in the pipeline for using PowerShell in Azure Functions, stay tuned.