---
id: 6230
title: Deploying PowerShell Module from GitHub to a MyGet Feed using VSTS CI/CD Pipeline
date: 2017-09-03T21:01:11+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=6230
permalink: /2017/09/03/deploying-powershell-module-from-github-to-a-myget-feed-using-vsts-cicd-pipeline/
categories:
  - PowerShell
  - VSTS
tags:
  - DevOps
  - PowerShell
  - VSTS
---
## Introduction
Lately I have been playing with VSTS and its CI/CD capabilities. Since I have been writing a lot of PowerShell modules and I’m using GitHub and MyGet in this kind of projects, I thought a good scenario to build is to use VSTS CI/CD pipeline to automatically deploy the module from GitHub to my MyGet feed whenever I commit to the master branch for the particular PS module.

In summary, this is the process:

1. I commit code changes to master branch
2. VSTS starts the build process (CI)
   1. fetch the artefact
   2. run pester test making sure the module can be successfully imported
   3. Zip the artefact
3. If the build succeeded, the release process (CD) kicks in
   1. fetch the zip file created by the build
   2. unzip the zip file
   3. publish the module to my MyGet feed

In order to demonstrate the process, I have quickly written a PowerShell module that plays random sound clips from my favorite cartoon South Park. This demo module is located in a Public GitHub repo: <a title="https://github.com/tyconsulting/PSSouthPark" href="https://github.com/tyconsulting/PSSouthPark">https://github.com/tyconsulting/PSSouthPark</a>

I’ll now go through the entire process of setting up the pipeline in VSTS.

## Creating and Configure Project in VSTS

### Create VSTS Project

1. Create a new project in VSTS, make sure use Git version control

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb.png" alt="image" width="586" height="433" border="0" /></a>

{:start="2"}
2. Select ‘**build code from an external repository**’

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-1.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-1.png" alt="image" width="497" height="462" border="0" /></a>

### Create Build Definition

{:start="3"}
3. Create new build definition

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-2.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-2.png" alt="image" width="428" height="212" border="0" /></a>

{:start="4"}
4.Select an empty template

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-3.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-3.png" alt="image" width="376" height="289" border="0" /></a>

{:start="5"}
5. Select agent queue (I’m using the Hosted agent queue)

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-4.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-4.png" alt="image" width="626" height="310" border="0" /></a>

{:start="6"}
6. In the ‘Get Sources’ step, connect to the GitHub repo

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-5.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-5.png" alt="image" width="759" height="558" border="0" /></a>

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-6.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-6.png" alt="image" width="751" height="552" border="0" /></a>

{:start="7"}
7. Add Pester unit test task (You can add this task to your VSTS account from the <a href="https://marketplace.visualstudio.com/items?itemName=petergroenewegen.PeterGroenewegen-Xpirit-Vsts-Build-Pester">market place</a>). Specify test file: **ModuleImport.Tests.ps1** (this test file is located in the root folder of the GitHub repo)

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-7.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-7.png" alt="image" width="695" height="379" border="0" /></a>

{:start="8"}
8. Add a task to publish test results

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-8.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-8.png" alt="image" width="698" height="548" border="0" /></a>

{:start="9"}
9. Add a task to archive files. Root folder to archive: **$(Build.Repository.LocalPath)**

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-9.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-9.png" alt="image" width="689" height="541" border="0" /></a>

{:start="10"}
10. Add a task to publish artifact

* Path to publish: **$(Build.ArtifactStagingDirectory)/**
* Artifact Name: **$(Build.BuildId).zip**
* Artifact Type: Server

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-10.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-10.png" alt="image" width="712" height="641" border="0" /></a>

{:start="11"}
11. Go to Triggers tab and enable the trigger

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-11.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-11.png" alt="image" width="722" height="593" border="0" /></a>

{:start="12"}
12. Save the build definition to "\" folder

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-12.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-12.png" alt="image" width="562" height="204" border="0" /></a>

### Create Release Definition

{:start="13"}
13. Create a new release definition using an empty template

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-13.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-13.png" alt="image" width="560" height="324" border="0" /></a>

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-14.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-14.png" alt="image" width="726" height="497" border="0" /></a>

{:start="14"}
14. I named the environment "MyGetFeed_<feedname>"

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-15.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-15.png" alt="image" width="692" height="478" border="0" /></a>

{:start="15"}
15. Add build artifact (from the build definition we created earlier)

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-16.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-16.png" alt="image" width="803" height="550" border="0" /></a>

{:start="16"}
16. Create several process variables for the release

| Name             | Value                                                                       | Scope       |
| ---------------- | --------------------------------------------------------------------------- | ----------- |
| APIKey           | \<API Key for my private MyGet feed\>                                       | environment |
| FeedName         | \<MyGet feed name\>                                                         | environment |
| ModuleFolderName | \<Name of the sub folder that contains the PS module files in GitHub repo\> | release     |
| RepoBaseURI      | https://www.myget.org/F/                                                    | release     |

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-17.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-17.png" alt="image" width="1002" height="354" border="0" /></a>

{:start="17"}
1.  Create a task to Extract files

* Destination folder: **$(System.DefaultWorkingDirectory)/output/**

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-18.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-18.png" alt="image" width="878" height="626" border="0" /></a>

{:start="18"}
18. Create a task to execute PowerShell script

 * Type: **File Path**
 * Script Path: **$(System.DefaultWorkingDirectory)/output/s/DeployToModuleRepo.ps1**
 * Arguments: -**RepoBaseURI $(RepoBaseURI) -FeedName $(FeedName) -APIKey $(APIKey) -ModuleFolderName $(ModuleFolderName)**

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-19.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-19.png" alt="image" width="895" height="424" border="0" /></a>

{:start="19"}
19. Give release definition a name and save the definition

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-20.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-20.png" alt="image" width="618" height="201" border="0" /></a>

{:start="20"}
20. Enable Continuous Deployment trigger and save again

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-21.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-21.png" alt="image" width="799" height="392" border="0" /></a>


## Testing the Pipeline
Now that I have created the pipeline, I’ll test it by committing the code to the GitHub repo master branch.

Soon after I committed the code to the master branch, I can see that the VSTS build (CI)completed successfully:

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-22.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-22.png" alt="image" width="951" height="453" border="0" /></a>

and the release (CD) also completed successfully after the build:

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-23.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-23.png" alt="image" width="967" height="445" border="0" /></a>

When I log on to MyGet, I can see the PSSouthPark module in my private feed:

<a href="https://blog.tyang.org/wp-content/uploads/2017/09/image-24.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/09/image_thumb-24.png" alt="image" width="791" height="575" border="0" /></a>

## Conclusion
By creating such VSTS CI/CD pipeline, I no longer need to manually push modules to my MyGet feed (which I use a lot) during development process. The deployment and pester test scripts can be reused with minimum modification. If you want to try this out yourself, please feel free to fork my sample <a href="https://github.com/tyconsulting/PSSouthPark">PSSouthPark module repo</a> and give it a try.