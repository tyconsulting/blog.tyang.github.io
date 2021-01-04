---
id: 6582
title: Deploying PowerShell Modules to NuGet Feeds (Version 2) Using VSTS CI/CD Pipelines
date: 2018-09-07T00:02:37+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=6582
permalink: /2018/09/07/deploying-powershell-modules-to-nuget-feeds-version-2-using-vsts-ci-cd-pipelines/
categories:
  - PowerShell
  - VSTS
tags:
  - PowerShell
  - VSTS
---
It’s been 2 weeks since my last post, I was half way through my list (of blogs to be written), then Melbourne was hit by a big cold wave, I got sick for over a week because of that, and with the recent outage of VSTS, I only got chance to finalise my code and demo for this post today.

## Background

Last year, I posted an article on <a href="https://blog.tyang.org/2017/09/03/deploying-powershell-module-from-github-to-a-myget-feed-using-vsts-cicd-pipeline/">how to deploy PowerShell modules from GitHub to MyGet feeds using VSTS</a>. I wasn’t really satisfied with what I did back then, and I had a requirement to develop several VSTS pipelines to deploy couple of private PowerShell modules I developed for a customer. I wanted to utilise out of the box tasks in my pipelines, have better Pester tests, and easier to deploy to multiple environments (multiple feeds). After some digging around, managed to use the <a href="https://docs.microsoft.com/en-us/vsts/pipelines/tasks/package/nuget?view=vsts">NuGet task</a> since under the hood, PowerShell modules is just a NuGet package:

<a href="https://blog.tyang.org/wp-content/uploads/2018/09/image.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/09/image_thumb.png" alt="image" width="801" height="522" border="0" /></a>

In order to use this NuGet task (which leverages nuget.exe), I needed to provide a NuGet Specification (.nuspec) file. i.e. here’s the nuspec file for Microsoft’s AzureAD PowerShell module:

<a href="https://blog.tyang.org/wp-content/uploads/2018/09/image-1.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/09/image_thumb-1.png" alt="image" width="665" height="511" border="0" /></a>

As you can see, the .nuspec file is a XML file that contains the meta data of the NuGet package, just like the PowerShell module manifest (.psd1) file.

When I was creating the pipelines for the customer, I was able to quickly creating the .nuspec files manually as part of the source code stored in the Git repo, then point the NuGet VSTS task to the specific nuspec file. This was quick and easy, since I didn’t have a lot of time to further automate the process, I left it there since it did the job. But I wanted to revisit this topic when I have a bit more time – I don’t really want to manually create / update the nuspec file every time, since it’s just copy & paste information from the module manifest .psd1 file.

## Automatically Generating NuGet Specification File

Over the last couple of days, I have spent some time on this, and wanted to come up a way to automatically generate the nuspec file for PowerShell modules – since when we create PowerShell modules, we only need to create the manifest files, the nuspec files were automatically created by Microsoft’s <a href="https://www.powershellgallery.com/packages/PowerShellGet">PowerShellGet module</a>. Luckily, PowerShellGet is open sourced, published in <a href="https://github.com/PowerShell/PowerShellGet">GitHub</a>, and it’s MIT license allows me to re-use its source code. I was able to "borrow" some code from it, and came up with this script that generates .nuspec files from .psd1 - **psd1-to-nuspec.ps1**:

{% gist c567e5cc66fc522d46743d744579be27 %}

To run this script, the only required parameter is –ManifestPath, which is the path to your PowerShell module manifest .psd1 file. This script adopted same behaviours as the Publish-Module cmdlet:

* In addition to the tags you have specified in the manifest file, it also creates tags for each cmdlet, commands, functions, DSC resource and role capability. so they become searchable when the module is pushed to the PowerShell Gallery.
* Able to identify ModuleVersion vs RequiredVersion for module dependencies

After I put together this script, I was able to include this in my Git repo, and use it in the build pipeline. Together with the PSPesterTest module I have <a href="https://blog.tyang.org/2018/08/24/powershell-module-pspestertest/">previously posted</a>, I was able to create a pipeline that:

* Performs a series of Pester tests against my code
* Create .nuspec file automatically
* publish the module to multiple feeds (as different environments in the release pipeline) using the native VSTS NuGet task

I will walk through how I created the the build and release pipelines now, using the same demo module PSSouthPark from my original post last year. The source code is still located in one of my public GitHub repos: <a title="https://github.com/tyconsulting/PSSouthPark" href="https://github.com/tyconsulting/PSSouthPark">https://github.com/tyconsulting/PSSouthPark</a>, which is linked to my VSTS pipeline. Please feel free to clone or fork my repo if you want to give it a try yourself (or simply love South Park, or want to prank someone via WinRM :smiley:.

## Creating VSTS Pipelines

<span style="color: #ff0000;">Note:</span> In this demo, I’m using the hosted VSTS agent, if you are using your own agent pool, the steps can be slightly different than mine.

### Build (CI) Pipeline

Let’s start with the build pipeline. The build pipeline contains the following steps:

<a href="https://blog.tyang.org/wp-content/uploads/2018/09/image-2.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/09/image_thumb-2.png" alt="image" width="761" height="730" border="0" /></a>

1. Connect to GitHub repo

Firstly, since my code is located in a public GitHub repo, there’s no point to duplicate them into a VSTS Git repo in this case, so I’ve simply connected the pipeline to the GitHub repo:

<a href="https://blog.tyang.org/wp-content/uploads/2018/09/image-3.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/09/image_thumb-3.png" alt="image" width="605" height="613" border="0" /></a>

{: start="2"}
2. Create an agent phase called "Test Module Code" and leave the agent pool as default (inherit from pipeline).

3. Create a PowerShell task called "Install required PowerShell module" in "Test Module Code" phase.

This task runs few lines of inline scripts to install required modules to the VSTS agent – since I’m using host agents and they are stateless, they are required to run my Pester tests defined in the PSPesterTest module:

<a href="https://blog.tyang.org/wp-content/uploads/2018/09/image-4.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/09/image_thumb-4.png" alt="image" width="604" height="546" border="0" /></a>

```powershell
$FeedName = 'PSGallery'
Install-PackageProvider Nuget -Scope CurrentUser -Force
Install-module PSScriptAnalyzer -force -Scope CurrentUser -Repository $FeedName
Install-module PSPesterTest -force -Scope CurrentUser -Repository $FeedName
```

{: start="4"}
4. Add another PowerShell task called "Pester Test PowerShell scripts"

<a href="https://blog.tyang.org/wp-content/uploads/2018/09/image-5.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/09/image_thumb-5.png" alt="image" width="877" height="466" border="0" /></a>

```powershell
Import-Module PSPesterTest
Test-ImportModule -ModulePath $(Build.SourcesDirectory)\PSSouthPark -OutputFile $(Build.SourcesDirectory)\TEST-PSPesterTest.ModuleImport.XML
Test-PSScriptAnalyzerRule -Path $(Build.SourcesDirectory)\PSSouthPark -recurse -MinimumSeverityLevel Warning -OutputFile $(Build.SourcesDirectory)\TEST-PSPesterTest.PSSA.XML
```

This step runs the 2 Pester tests I have defined in the PesterTest module and output the result into XML files.

{: start="5"}
5. Publish Test Results

The last task for the "Test Module Code" job is publishing test result. Create a "Publish Test Results" task, and configure it as shown below:

<a href="https://blog.tyang.org/wp-content/uploads/2018/09/image-6.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/09/image_thumb-6.png" alt="image" width="646" height="376" border="0" /></a>

{: start="6"}
6. Create the 2nd Agent job called "Package Module" as shown below:

<a href="https://blog.tyang.org/wp-content/uploads/2018/09/image-7.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/09/image_thumb-7.png" alt="image" width="663" height="515" border="0" /></a>

It’s configured to run on hosted agent pool, and only starts if the previous job has succeeded.

{: start="7"}
7. Create a PowerShell task to create the Nuspec file:

<a href="https://blog.tyang.org/wp-content/uploads/2018/09/image-8.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/09/image_thumb-8.png" alt="image" width="655" height="424" border="0" /></a>

This task runs a script located in <span style="background-color: #ffff00;">build/psd1-to-nuspec.ps1</span> (you can browse to the file by clicking on the "…" button if you want to). the "Arguments" filed should be: <span style="background-color: #ffff00;">-ManifestPath $(Build.SourcesDirectory)\PSSouthPark\PSSouthPark.psd1</span>

{: start="8"}
8. Add a NuGet task called "Create NuGet package" and configure it as shown below:

<a href="https://blog.tyang.org/wp-content/uploads/2018/09/image-9.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/09/image_thumb-9.png" alt="image" width="824" height="527" border="0" /></a>

<span style="color: #ff0000;">Note:</span> you won’t be able to browse to the nuspec file because it does not exist in the Git repo.

{: start="9"}
9. Create a "Publish Build Artifacts" task and configure it as shown below:

<a href="https://blog.tyang.org/wp-content/uploads/2018/09/image-10.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/09/image_thumb-10.png" alt="image" width="823" height="557" border="0" /></a>

Now, this is it for the build (CI) pipeline. save it, and move on to creating the Release (CD) pipeline.

### Release (CD) Pipeline

1. Creating NuGet Service connections

Before creating the Release pipeline, I need to create several service connections that link my VSTS project to the NuGet feeds that I wish to push packages to. To create these connections, go to Project settings, and under "Build and release" section, go to "Service connections", and add new NuGet connections

<a href="https://blog.tyang.org/wp-content/uploads/2018/09/image-11.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/09/image_thumb-11.png" alt="image" width="597" height="330" border="0" /></a>

In this demo, I am creating 3 environments (that pushes package to 3 different feeds), so I created 3 connections:

* A MyGet private feed
* A MyGet public feed
* PowerShell Gallery

<a href="https://blog.tyang.org/wp-content/uploads/2018/09/image-12.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/09/image_thumb-12.png" alt="image" width="538" height="335" border="0" /></a>

With MyGet feed, the feed URI is **https://www.myget.org/F/<FeedName>/api/v2**, and the URI for PowerShell Gallery is: <strong>https://www.powershellgallery.com/api/v2/package/</strong>

<span style="color: #ff0000;">Tip:</span> To retrieve the feed URI for PowerShell Gallery, on a Windows 10 machine, run this PowerShell command:

```powershell
Get-PSRepository –Name PSGallery | fl *
```

<a href="https://blog.tyang.org/wp-content/uploads/2018/09/image-13.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/09/image_thumb-13.png" alt="image" width="949" height="331" border="0" /></a>

Depending on the NuGet feed provider, you need to obtain an API key that has permission to publish to the particular feed that you wish to push packages to.

{: start="2"}
2. Create an environment, with one agent job called "Publish NuGet package"

3. Add a NuGet task:

<a href="https://blog.tyang.org/wp-content/uploads/2018/09/image-14.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/09/image_thumb-14.png" alt="image" width="955" height="598" border="0" /></a>

 * Command: push
 * Path to NuGet packages(s): $(System.DefaultWorkingDirectory)/PoShModule-PSSouthPark-CI/drop/*.nupkg
 * NuGet server: pick a connection you created earlier

<span style="color: #ff0000;">Note:</span> the NuGet package (nupkg) file name may change because it includes the version number, therefore use *.nupkg as the file name.

{: start="4"}
4. Clone this environment one or more times then update NuGet server from the drop down list if you are deploying it to more than one feeds

<a href="https://blog.tyang.org/wp-content/uploads/2018/09/image-15.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/09/image_thumb-15.png" alt="image" width="986" height="340" border="0" /></a>

In my demo, I don’t really want to deploy this module to PowerShell Gallery because it can be seen as offensive <img class="wlEmoticon wlEmoticon-smile" src="https://blog.tyang.org/wp-content/uploads/2018/09/wlEmoticon-smile.png" alt="Smile" />. so I configured the PowerShell Gallery environment to require pre-deployment approval (and I’ll go cancel it later).

<a href="https://blog.tyang.org/wp-content/uploads/2018/09/image-16.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/09/image_thumb-16.png" alt="image" width="931" height="124" border="0" /></a>

## Summary

In this article, I walked through how I deployed PowerShell modules to NuGet feeds using the native VSTS NuGet task. It took me a while to strip the useful code from Microsoft’s PowerShellGet module in order to automatically generate the nuspec files.

When the ```Publish-Module``` from PowerShellGet is executed, it generates a nuspec file for the module that you wish to publish, but deletes it after the deployment. It would be a lot easier for us if Microsoft can extend the capability to allow us to only generate nuspec file or create NuGet package without deploying it.