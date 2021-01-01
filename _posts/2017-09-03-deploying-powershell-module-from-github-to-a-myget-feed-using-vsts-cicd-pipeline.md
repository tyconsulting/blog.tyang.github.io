---
id: 6230
title: Deploying PowerShell Module from GitHub to a MyGet Feed using VSTS CI/CD Pipeline
date: 2017-09-03T21:01:11+10:00
author: Tao Yang
layout: post
guid: https://blog.tyang.org/?p=6230
permalink: /2017/09/03/deploying-powershell-module-from-github-to-a-myget-feed-using-vsts-cicd-pipeline/
categories:
  - PowerShell
  - VSTS
tags:
  - DevOps
  - Powershell
  - VSTS
---
<h2>Introduction</h2>
Lately I have been playing with VSTS and its CI/CD capabilities. Since I have been writing a lot of PowerShell modules and I’m using GitHub and MyGet in this kind of projects, I thought a good scenario to build is to use VSTS CI/CD pipeline to automatically deploy the module from GitHub to my MyGet feed whenever I commit to the master branch for the particular PS module.

In summary, this is the process:
<ol>
 	<li>I commit code changes to master branch</li>
 	<li>VSTS starts the build process (CI)
<ol>
 	<li>fetch the artefact</li>
 	<li>run pester test making sure the module can be successfully imported</li>
 	<li>Zip the artefact</li>
</ol>
</li>
 	<li>If the build succeeded, the release process (CD) kicks in
<ol>
 	<li>fetch the zip file created by the build</li>
 	<li>unzip the zip file</li>
 	<li>publish the module to my MyGet feed</li>
</ol>
</li>
</ol>
In order to demonstrate the process, I have quickly written a PowerShell module that plays random sound clips from my favorite cartoon South Park. This demo module is located in a Public GitHub repo: <a title="https://github.com/tyconsulting/PSSouthPark" href="https://github.com/tyconsulting/PSSouthPark">https://github.com/tyconsulting/PSSouthPark</a>

I’ll now go through the entire process of setting up the pipeline in VSTS.
<h2>Creating and Configure Project in VSTS</h2>
<h3>Create VSTS Project</h3>
1. Create a new project in VSTS, make sure use Git version control

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb.png" alt="image" width="586" height="433" border="0" /></a>

2. Select ‘<strong>build code from an external repository</strong>’

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-1.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-1.png" alt="image" width="497" height="462" border="0" /></a>
<h3>Create Build Definition</h3>
3. Create new build definition

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-2.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-2.png" alt="image" width="428" height="212" border="0" /></a>

4.Select an empty template

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-3.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-3.png" alt="image" width="376" height="289" border="0" /></a>

5. Select agent queue (I’m using the Hosted agent queue)

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-4.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-4.png" alt="image" width="626" height="310" border="0" /></a>

6. In the ‘Get Sources’ step, connect to the GitHub repo

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-5.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-5.png" alt="image" width="759" height="558" border="0" /></a>

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-6.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-6.png" alt="image" width="751" height="552" border="0" /></a>

7. Add Pester unit test task (You can add this task to your VSTS account from the <a href="https://marketplace.visualstudio.com/items?itemName=petergroenewegen.PeterGroenewegen-Xpirit-Vsts-Build-Pester">market place</a>). Specify test file: <strong>ModuleImport.Tests.ps1</strong> (this test file is located in the root folder of the GitHub repo)

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-7.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-7.png" alt="image" width="695" height="379" border="0" /></a>

8. Add a task to publish test results

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-8.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-8.png" alt="image" width="698" height="548" border="0" /></a>

9. Add a task to archive files. Root folder to archive: <strong>$(Build.Repository.LocalPath)</strong>

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-9.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-9.png" alt="image" width="689" height="541" border="0" /></a>

10. Add a task to publish artifact
<ul>
 	<li>Path to publish: <strong>$(Build.ArtifactStagingDirectory)/</strong></li>
 	<li>Artifact Name: <strong>$(Build.BuildId).zip</strong></li>
 	<li>Artifact Type: Server</li>
</ul>
<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-10.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-10.png" alt="image" width="712" height="641" border="0" /></a>

11. Go to Triggers tab and enable the trigger

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-11.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-11.png" alt="image" width="722" height="593" border="0" /></a>

12. Save the build definition to “\” folder

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-12.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-12.png" alt="image" width="562" height="204" border="0" /></a>
<h3>Create Release Definition</h3>
13. Create a new release definition using an empty template

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-13.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-13.png" alt="image" width="560" height="324" border="0" /></a>

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-14.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-14.png" alt="image" width="726" height="497" border="0" /></a>

14. I named the environment “MyGetFeed_&lt;feedname&gt;”

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-15.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-15.png" alt="image" width="692" height="478" border="0" /></a>

15. Add build artifact (from the build definition we created earlier)

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-16.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-16.png" alt="image" width="803" height="550" border="0" /></a>

16. Create several process variables for the release

<strong>
</strong><strong>
</strong>
<table border="0" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td valign="top"><strong>Name</strong></td>
<td valign="top"><strong>Value</strong></td>
<td valign="top"><strong>Scope</strong></td>
</tr>
<tr>
<td valign="top">APIKey</td>
<td valign="top">&lt;API Key for my private MyGet feed&gt;</td>
<td valign="top">environment</td>
</tr>
<tr>
<td valign="top">FeedName</td>
<td valign="top">&lt;MyGet feed name&gt;</td>
<td valign="top">environment</td>
</tr>
<tr>
<td valign="top">ModuleFolderName</td>
<td valign="top">&lt;Name of the sub folder that contains the PS module files in GitHub repo&gt;</td>
<td valign="top">release</td>
</tr>
<tr>
<td valign="top">RepoBaseURI</td>
<td valign="top"><a title="https://www.myget.org/F/" href="https://www.myget.org/F/">https://www.myget.org/F/</a></td>
<td valign="top">release</td>
</tr>
</tbody>
</table>
<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-17.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-17.png" alt="image" width="1002" height="354" border="0" /></a>

17. Create a task to Extract files
<ul>
 	<li>Destination folder: <strong>$(System.DefaultWorkingDirectory)/output/</strong></li>
</ul>
<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-18.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-18.png" alt="image" width="878" height="626" border="0" /></a>

18. Create a task to execute PowerShell script
<ul>
 	<li>Type: <strong>File Path</strong></li>
 	<li>Script Path: <strong>$(System.DefaultWorkingDirectory)/output/s/DeployToModuleRepo.ps1</strong></li>
 	<li>Arguments: -<strong>RepoBaseURI $(RepoBaseURI) -FeedName $(FeedName) -APIKey $(APIKey) -ModuleFolderName $(ModuleFolderName)</strong></li>
</ul>
<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-19.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-19.png" alt="image" width="895" height="424" border="0" /></a>

19. Give release definition a name and save the definition

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-20.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-20.png" alt="image" width="618" height="201" border="0" /></a>

20. Enable Continuous Deployment trigger and save again

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-21.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-21.png" alt="image" width="799" height="392" border="0" /></a>
<h2>Testing the Pipeline</h2>
Now that I have created the pipeline, I’ll test it by committing the code to the GitHub repo master branch.

Soon after I committed the code to the master branch, I can see that the VSTS build (CI)completed successfully:

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-22.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-22.png" alt="image" width="951" height="453" border="0" /></a>

and the release (CD) also completed successfully after the build:

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-23.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-23.png" alt="image" width="967" height="445" border="0" /></a>

When I log on to MyGet, I can see the PSSouthPark module in my private feed:

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-24.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-24.png" alt="image" width="791" height="575" border="0" /></a>
<h2>Conclusion</h2>
By creating such VSTS CI/CD pipeline, I no longer need to manually push modules to my MyGet feed (which I use a lot) during development process. The deployment and pester test scripts can be reused with minimum modification. If you want to try this out yourself, please feel free to fork my sample <a href="https://github.com/tyconsulting/PSSouthPark">PSSouthPark module repo</a> and give it a try.