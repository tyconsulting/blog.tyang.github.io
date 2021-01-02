---
id: 5621
title: PowerShell DSC Resource for Managing Repositories and Modules
date: 2016-09-15T19:59:42+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=5621
permalink: /2016/09/15/powershell-dsc-resource-for-managing-repositories-and-modules/
categories:
  - PowerShell
tags:
  - DSC
  - PowerShell
---
<h3><a href="http://blog.tyang.org/wp-content/uploads/2016/09/256x256.png"><img style="background-image: none; float: left; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="256x256" src="http://blog.tyang.org/wp-content/uploads/2016/09/256x256_thumb.png" alt="256x256" width="151" height="151" align="left" border="0" /></a>Introduction</h3>
PowerShell version 5 has introduced a new feature that allows you to install packages (such as PowerShell modules) from NuGet repositories. If you have used cmdlets such as Find-Module, Install-Module or Uninstall-Module, then you have already taken advantage of this awesome feature.

By default, a Microsoft owned public repository <a href="https://www.powershellgallery.com/">PowerShell Gallery</a> is configured on all computers running PowerShell version 5 and when you use Find-Module or Install-Module, you are pulling the modules from the PowerShell Gallery.

Ever since I started using PowerShell v5, I’ve discovered some challenges managing modules for machines in my environment:
<ul>
 	<li>Lack of a fully automated way to push modules to a group of computers</li>
 	<li>Module version inconsistency between computers</li>
 	<li>Need of a private repository</li>
</ul>
Let me elaborate each of the point listed above.

<strong>Lack of a fully automated way to push modules to a group of computers</strong>

Back in the old days (pre WMF v5), I used to package PowerShell modules to msi’s and use ConfigMgr to deploy the msi to target computers. although it’s not too hard to a package module to msi, this method is really time consuming, not to mention it also requires ConfigMgr. In PowerShell v5, I can write a script that utilise PowerShell remoting to push modules to remote machines, this is still a manual process, and it may not be a viable solution for a large group of computers.

<strong>Module version inconsistency between computers</strong>

over the time, modules get updated, new modules get released from various sources. I often find module version become inconsistent among computers. there is no automated ways to update computers when a new version is released.

<strong>Need of a private repository</strong>

PowerShell Gallery is public. everything you publish to it will be available for the entire world. Organisations often write modules specifically for internal use, and may not want to share it with the rest of the world.

Before I dive into the main topic, I’d like to discuss what I have done for implementing private repositories.
<h3>Private Repositories</h3>
PowerShell PackageManagement uses NuGet repositories. I found the following solutions available:
<ul>
 	<li>MyGet (<a title="https://www.myget.org/" href="https://www.myget.org/">https://www.myget.org/</a>)</li>
 	<li>ProGet (<a title="http://inedo.com/proget" href="http://inedo.com/proget">http://inedo.com/proget</a>)</li>
 	<li>Private NuGet repository (<a title="https://learn-powershell.net/2014/04/11/setting-up-a-nuget-feed-for-use-with-oneget/" href="https://learn-powershell.net/2014/04/11/setting-up-a-nuget-feed-for-use-with-oneget/">https://learn-powershell.net/2014/04/11/setting-up-a-nuget-feed-for-use-with-oneget/</a>)</li>
</ul>
MyGet is a SaaS (Software as a Service) based repository hosted on the cloud. Although you can create your own feeds, private feeds come with a price tag (free accounts allow you to create public feeds that everyone can access).

ProGet is a on-premises solution. To install it, you will need a web server (and optionally a SQL server) within your network. It comes with free, basic and enterprise editions. the feature comparison is located here: <a title="http://inedo.com/proget/pricing/features-by-edition" href="http://inedo.com/proget/pricing/features-by-edition">http://inedo.com/proget/pricing/features-by-edition</a>

Since both MyGet and ProGet offer NFR (Not For Resell) licenses to Microsoft MVPs, I have tested both for my lab environment. They both work pretty well. I did not bother to setup the free private NuGet repository (the 3rd option).

These days, I found myself writing more and more PowerShell modules for different projects. During development phase, I’d normally use a feed that’s hosted on my ProGet server because it is located in my lab, so it’s faster to publish and download modules. Once the module is ready, I’d normally publish it to MyGet for general consumption because it’s a SaaS based application, both my lab machines and Azure IaaS machines will have no problem accessing it.
<h3>DSC Resource cPowerShellPackageManagement</h3>
In order to overcome the other two challenges that I’m facing (module automatically deployment and version inconsistency), I have created a DSC resource called cPowerShellPackageManagement.

According to the DSC namingstandard, the first letter ‘c’ indicates it is a community resource, and as the rest of the name suggests, it is used to manage PowerShell packages.

This DSC resource module contains 2 resources:
<ul>
 	<li>cPowerShellRepository – used to register or unregister specific NuGet feeds on computers running PowerShell v5 and above.</li>
 	<li>cPowerShellModuleManagement – used to install / uninstall modules on computers running PowerShell v5 and aove</li>
</ul>
<strong>cPowerShellRepository</strong>

Syntax:
```powershell
cPowerShellRepository [String] #ResourceName
{
Name = [string]
[DependsOn = [string[]]]
[Ensure = [string]{ Absent | Present }]
[InstallationPolicy = [string]{ Trusted | Untrusted }]
[PackageManagementProvider = [string]]
[PsDscRunAsCredential = [PSCredential]]
[PublishLocation = [string]]
[SourceLocation = [string]]
}

```
To register a feed, you will need to specify some basic information such as PublishLocation and SourceLocation. You can also set Ensure = Absent to unregister the feed with the name specified in the Name parameter.

When not specified, the InstallationPolicy field default value is "Untrusted". If you’d like to set the repository as a trusted repository, set this value to "Trusted".

<strong><span style="color: #ff0000;">Note:</span></strong> since the repository registration is based on each user (as opposed to machine based settings) and DSC configuration is executed under LocalSystem context. you will not be able to see the repository added by this resource if you run Get-PSRepository cmdlet under your own user account. If you start PowerShell under LocalSystem by using PsExec (run psexec /i /s /d powershell.exe), you will be able to see the repository:

<a href="http://blog.tyang.org/wp-content/uploads/2016/09/image.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/09/image_thumb.png" alt="image" width="354" height="102" border="0" /></a>

<strong>cPowerShellModuleManagement</strong>

Syntax:
```powershell
cPowerShellModuleManagement [String] #ResourceName
{
PSModuleName = [string]
RepositoryName = [string]
[DependsOn = [string[]]]
[Ensure = [string]{ Absent | Present }]
[MaintenanceLengthMinute = [Int32]]
[MaintenanceStartHour = [Int32]]
[MaintenanceStartMinute = [Int32]]
[PsDscRunAsCredential = [PSCredential]]
[PSModuleVersion = [string]]
}

```
<ul>
 	<li><strong>PSModuleName</strong> – PowerShell module name. When this is set to ‘all’, all modules from the specified repository will be installed. <u><em>So please do not use ‘all’ against PSGallery!!</em></u></li>
 	<li><strong>RepositoryName</strong> – Name of the repository where module will be installed from. This can be a public repository such as PowerShell Gallery, or your privately owned repository (i.e. your ProGet or MyGet feeds). You can use the cPowerShellRepository resource to configure the repository.</li>
 	<li><strong>PSModuleVersion </strong>– This is an optional field. when used, only the specified version will be installed (or uninstalled). If not specified, the latest version of the module from the repository will be used. This field will not impact other versions that are already installed on the computer (i.e. when installing the latest version, earlier versions will not be uninstalled).</li>
 	<li><strong>MaintenanceStartHour, MaintenanceStartMinute and MaintenanceLengthMinute</strong> – Since the LCM will run the DSC configuration on a pre-configured interval, you may not want to install / uninstall modules during business hours. Therefore, you can set the maintenance start hour (0-23) and start minute (0-59) to specify the start time of the maintenance window. MaintenanceLengthMinute represents the length of the maintenance window in minutes. These fields are optional, when specified, module installation and uninstallation will only take place when the LCM runs the configuration within the maintenance window. Note: Please make sure the MaintenanceLengthMinute is greater than the value configured for the LCM ConfigurationModeFrequencyMins property.</li>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2016/09/image-1.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/09/image_thumb-1.png" alt="image" width="428" height="220" border="0" /></a>
<h3>Sample Configuration</h3>
Here are some sample configurations to demonstrate the usage of these DSC resources.

<strong>1. Register to an On-Prem ProGet feed and install all modules from the feed</strong>
<pre Language=PowerShell>
Configuration SampleProGetConfiguration
{
    Import-DSCResource -Name cPowerShellRepository -ModuleName cPowerShellPackageManagement
    Import-DSCResource -Name cPowerShellModuleManagement -ModuleName cPowerShellPackageManagement
    #Register to On-Prem ProGet repository
    $SourceUri = "http://ProGetRepo/nuget/FeedName"
    $PublishUri = 'http://ProGetRepo/nuget/FeedName'
    $FeedName = 'ProGet'
    Node PowerShellModuleConfig {
      cPowerShellRepository ProGetRepo {
            Name = $FeedName
            SourceLocation = $SourceUri
            PublishLocation = $PublishUri
            Ensure = 'Present'
            InstallationPolicy = 'Trusted'
        }
        cPowerShellModuleManagement InstallAllModules {
            PSModuleName = 'All'
            Ensure = 'Present'
            RepositoryName = $FeedName
            DependsOn = "[cPowerShellRepository]ProGetRepo"
        }
    }
}

```
Using this configuration, I can manage the modules from the repository feed level. if I add or update a module to the feed, the DSC LCM on each configured compute will automatically install the newly added (or updated) module when next time the configuration is refreshed.

<strong>2. Register to a feed hosted on MyGet, and install several specific modules</strong>
<pre Language=PowerShell>
Configuration SampleMyGetConfiguration
{
    Import-DSCResource -Name cPowerShellRepository -ModuleName cPowerShellPackageManagement
    Import-DSCResource -Name cPowerShellModuleManagement -ModuleName cPowerShellPackageManagement
    #Register to MyGet repository
    $APIKey = 'ebb965a2-76f9-4e7c-bba8-5be232bf1e08'
    $SourceUri = "https://www.myget.org/F/MyGetUserName/auth/$APIKey/api/v2"
    $PublishUri = 'https://www.myget.org/F/MyGetUserName/api/v2/package'

    $FeedName = 'MyGet'
    Node PSModuleConfig {
      cPowerShellRepository MyGetRepo {
            Name = $FeedName
            SourceLocation = $SourceUri
            PublishLocation = $PublishUri
            Ensure = 'Present'
            InstallationPolicy = 'Trusted'
        }
        cPowerShellModuleManagement Gac {
            PSModuleName = 'Gac'
            PSModuleVersion = '1.0.1'
            Ensure = 'Present'
            RepositoryName = $FeedName
            DependsOn = "[cPowerShellRepository]MyGetRepo"
        }
        cPowerShellModuleManagement SharePointSDKWithMaintWindow {
            PSModuleName = 'SharePointSDK'
            Ensure = 'Present'
            RepositoryName = 'MyGet'
            MaintenanceStartHour = 22
            MaintenanceStartMinute = 20
            MaintenanceLengthMinute = 45
            DependsOn = "[cPowerShellRepository]MyGetRepo"
        }
    }
}

```
In this example, I’ve specified a particular module can be installed at any time (the Gac module), and another module can only be installed (or updated) at a specific time window (the SharePointSDK module).
<h3>Download and Install Locations</h3>
This DSC Resource has been published to PowerShellGallery: <a title="https://www.powershellgallery.com/packages/cPowerShellPackageManagement" href="https://www.powershellgallery.com/packages/cPowerShellPackageManagement">https://www.powershellgallery.com/packages/cPowerShellPackageManagement</a>

The project is also located on Github: <a title="https://github.com/tyconsulting/PowerShellPackageManagementDSCResource" href="https://github.com/tyconsulting/PowerShellPackageManagementDSCResource">https://github.com/tyconsulting/PowerShellPackageManagementDSCResource</a>
<h3>Special Thanks</h3>
I’d like to thank my MVP friends Jakob G Svendsen (<a href="https://twitter.com/JakobGSvendsen">@JakobGSvendsen</a>), Pete Zerger (<a href="https://twitter.com/pzerger">@pzerger</a>), Daniele Grandini (<a href="https://twitter.com/DanieleGrandini">@DanieleGrandini</a>) and James Bannan (<a href="https://twitter.com/jamesbannan">@JamesBannan</a>) who provided feedback and helped me testing the modules.