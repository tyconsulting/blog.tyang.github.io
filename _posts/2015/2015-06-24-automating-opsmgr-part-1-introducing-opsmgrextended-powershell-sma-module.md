---
id: 4036
title: 'Automating OpsMgr Part 1: Introducing OpsMgrExtended PowerShell / SMA Module'
date: 2015-06-24T20:39:12+10:00
author: Tao Yang
#layout: post
excerpt: ""
header:
  overlay_image: /wp-content/uploads/2015/06/OpsMgrExnteded-banner.png
  overlay_filter: 0.5 # same as adding an opacity of 0.5 to a black background
guid: http://blog.tyang.org/?p=4036
permalink: /2015/06/24/automating-opsmgr-part-1-introducing-opsmgrextended-powershell-sma-module/
categories:
  - PowerShell
  - SCOM
  - SMA
tags:
  - Automating OpsMgr
  - Featured
  - OpsMgrExtended
  - PowerShell
  - SCOM
  - SMA
---

## Background

The **OpsMgrExtended** PowerShell and SMA module is a project that I have been working on since August last year. I am very glad that it is now ready to be released to the community.

This module is designed to fill some gaps in the current OpsMgr automation solutions provided natively in System Center 2012 suite. This module can be used as a System Center Service Management Automation (SMA) Integration Module, as well as a standalone PowerShell module.

Currently, the following products are available when comes to creating automation solutions for OpsMgr:

* OpsMgr native PowerShell module
* OpsMgr Integration Pack for System Center Orchestrator
* OpsMgr portable Integration Module for System Center Service Management Automation

In my opinion, each of above listed serves their purpose, but also have some limitations.

**OpsMgr PowerShell Module**
An OpsMgr native component that can be installed on any computers running PowerShell. With the System Center 2012 R2 release, this module offers 173 cmdlets. However, most of them are designed for administrative tasks, it is lacking features such as creating management pack components (i.e. rules, monitors, etc.).

**OpsMgr Integration Pack for System Center Orchestrator**

Microsoft has released a version of this IP for every release of OpsMgr 2012. However, the functionalities this IP provides is very limited.

<a href="http://blog.tyang.org/wp-content/uploads/2015/06/image10.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; margin: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/06/image_thumb10.png" alt="image" width="178" height="176" border="0" /></a>

As you can see, it only offer 8 activities. It also requires the corresponding version of the OpsMgr operational console to be manually installed on each Orchestrator runbook server and runbook designer computer before you can executing runbooks which utilise these activities. The requirement for the operations console introduces some limitations:

* You cannot install multiple versions of OpsMgr operations console on a same computer. – This means if you have multiple versions of OpsMgr (i.e. 2012 and 2007), you MUST use separate Orchestrator runbook servers and runbook designer computers for runbooks targeting these systems.
* If you also need to install OpsMgr agents on these runbook servers, you can ONLY install the agent that is the same version of the operations console. – This means if you do have both OpsMgr 2007 and 2012 in your environment, the runbook servers for your OpsMgr 2007 management groups cannot be monitored by OpsMgr 2012 (unless you implement less efficient agentless monitoring for these runbook servers).

**OpsMgr SMA Portable Integration Module**

When SMA was released as part of System Center 2012 R2, it was shipped with an OperationsManager portable module built-in to the product.

<a href="http://blog.tyang.org/wp-content/uploads/2015/06/SNAGHTMLa03ddea.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLa03ddea" src="http://blog.tyang.org/wp-content/uploads/2015/06/SNAGHTMLa03ddea_thumb.png" alt="SNAGHTMLa03ddea" width="361" height="430" border="0" /></a>

The <a href="http://blogs.technet.com/b/orchestrator/archive/2013/11/04/service-management-automation-portable-modules-what-why-and-how.aspx" target="_blank">portable modules</a> are not real modules. They are like the middle man between your runbooks and the "real" Integration Modules. It takes your input parameters and call the activities from the real module for you. i.e.

<a href="http://blog.tyang.org/wp-content/uploads/2015/06/image11.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/06/image_thumb11.png" alt="image" width="649" height="106" border="0" /></a>

In order to use the OperationsManager-Portable module in SMA, you must firstly manually install the "real" OpsMgr 2012 PowerShell module on all the SMA runbook servers. One of the great feature that SMA offers is being able to automatically deploy Integration Modules to all runbook servers once been imported into SMA. But for the portable modules, this is not the case, as you must manually install the "real" modules by yourself. The other limitation is, it still only just offers whatever is available in the native OpsMgr 2012 PowerShell module.

With all these limitations in mind, I have developed a brand new custom OpsMgr PowerShell / SMA Module OpsMgrExtended to fill some of these gaps.

## OpsMgrExtended Introduction

Back in January 2015, I have presented a work-in-progress version of this module in the Melbourne MVP Community Camp. At that time, I said it was going to be released in few weeks time. Unfortunately, I just couldn’t dedicate enough time on this project and I wanted to add few additional functions in this module, I only managed to finalise it now (5 months later). My presentation has been recorded, you can watch it and download the slide deck from my previous post: <a title="http://blog.tyang.org/2015/01/23/microsoft-mvp-community-camp-2015-session-sma-integration-module-opsmgrextended/" href="http://blog.tyang.org/2015/01/23/microsoft-mvp-community-camp-2015-session-sma-integration-module-opsmgrextended/">http://blog.tyang.org/2015/01/23/microsoft-mvp-community-camp-2015-session-sma-integration-module-opsmgrextended/</a>

### OpsMgr SDK Assemblies

The core component of all above mentioned native solutions is the OpsMgr SDK. All of them requires OpsMgr SDK assemblies to be installed onto the computer running the scripts and runbooks separately. This is done via the install of the OpsMgr Operations console and the PowerShell console. When you install the Operations Console or the PowerShell console onto a computer, the OpsMgr SDK assemblies are installed into the Global Assembly Cache (GAC) on this computer.

To make OpsMgrExtended module TRULLY portable and independent, I have placed the 3 OpsMgr 2012 R2 SDK DLLs into the module base folder. The PowerShell code in the OpsMgrExtended module would try to load the SDK assemblies from the GAC, but if the assemblies are not located in the GAC, it would leverage the 3 SDK DLLs that are located in the module base folder. By doing so, there is NO requirement for installing ANY OpsMgr components before you can start using this module.

### Why Using OpsMgrExtended?

"If you think you will do a task twice – **automate it!**"

When comes to automation, this is my favourite quote, from Joe Levy, a program manager in the System Center Orchestrator team. I have been managing large OpsMgr environments for many years. At my last job, I was pretty much the single point of contact for OpsMgr. Based on my own personal experience, there are a lot of repetitive tasks when managing OpsMgr infrastructures. This is why few years ago I spent few months of my spare time and developed the <a href="http://blog.tyang.org/2014/06/30/opsmgr-2012-self-maintenance-management-pack-2-4-0-0/" target="_blank">OpsMgr Self Maintenance MP</a>. This MP was targeting the administrative workflows which normally carried out by OpsMgr admins.

Other than the day-to-day tasks the Self Maintenance MP has already covered, I still find a lot of repetitive tasks that do not fall into that category. for example, management packs development. I have been writing management packs for few years. Based on my own experience and the feedbacks I got from the community, I believe a lot of OpsMgr customers, or the broader community are facing the following challenges:

**MP development can get very hard, and there are not many good MP developers out there.**

Most of the SCOM administrators in your organisation would fall into the "IT Pro" category. MP development can get very complicated and definitely a skillset more suitable for developers  rather than IT Pro’s. There are simply not many MP developers out there. I’ve been heavily involved in the OpsMgr community for few years now, I can confidently state that if I don’t know ALL the good MP developers in the OpsMgr community, I think I know most of them. So trust me when I say there are not many around. Sometimes, I would imagine, world would be a better place if MP Development skills are as popular as ConfigMgr OSD skills (which pretty much every System Center specialist I know has got that written down on their CV’s).

**It is hard to learn MP development**

I’m not saying this skill is very hard to learn. But I don’t believe there are enough good & structured materials for people who wants to pick up this skill. When I started writing management packs, I was really struggling in the beginning. My friend and fellow Melbourne based MVP <a href="https://twitter.com/orinthomas" target="_blank">Orin Thomas</a> once said to me, that he believes if you want people to start using your products, you need to make sure you invest heavily in developing trainings. I think what Orin said was spot on. I believe this is one of the main reasons that there are not many good MP developers around.

**Too many toolsets**

For beginners, you can use the OpsMgr operational console to write some really basic management pack elements. Most of the OpsMgr specialist who claims they can write management packs probably would use either the OpsMgr 2007 R2 Authoring Console, or the 3rd party product Silect MPAuthor. They are user-friendly, GUI based authoring tools and there are relatively easy to learn. Then for seasoned MP developers, they would normally use Visual Studio Authoring Extension (VSAE) – which is just a extension in Visual Studio, no GUI, you need to REALLY understand the management pack XML schema to be able to use this tool. not to mention Visual Studio is not free (Using it to author MPs for commercial purpose or for large organisations does not qualify you for using the free Community edition). It is hard to explain when someone completely new in this area ask me "what tool do people use to write management packs?"

**How about PowerShell?**

Most IT Pros should by now already very familiar with Windows PowerShell. Wouldn’t it be nice if I can use PowerShell to create OpsMgr monitors and rules? For example, if I need to monitor a Windows service, how about use a cmdlet like "New-ServiceMonitor" to create this service monitor in my OpsMgr management group?

Well, this is one of the areas I’m trying to cover in the OpsMgrExtended module.

When I was managing a large OpsMgr environment in my previous job, as much as I like developing management packs, sometimes, I still consider it as repetitive tasks. Every now and then, people would come to me and asked me to monitor service X, monitor perf counter Y, collect events Z, etc. I’ve done it once, I’ve learnt how to do it, I don’t want to do it over and over again, simply because I’m not a robot and I **HATE** repetitive tasks! Not to mention all the ITIL overhead that you have to put up with (i.e. testing, managing Dev, Test, Production environments, change management, release management, etc.). When there is a monitoring requirement, why can’t my customer simply fill out a request and whatever he / she needs to create gets automatically created? – Same way a normal end user would request for a piece of software to be installed on his / her PC? I don’t have to be involved (neither do I want to) when every time someone needs to get something created in OpsMgr. I’d rather spend my time working on some more complicated solutions :smiley:.

Another good example would be, over a year ago, I was helping a colleague from another team setting up a brand new OpsMgr 2012 environment to monitor couple of thousand servers within our organisation. My colleague has spent a lot of time, back and forth with the Windows server support team to identify their requirements. In the end, after I waited a long period of time, they finally gave me a spreadsheet which consists of 20-30 services they need to monitor. Imagine for most of the OpsMgr administrators who has never used VSAE before, this would take a lot of time and maybe a lot of copy-paste to accomplish when using Authoring Console, MPAuthor or even NotePad++. For me, although I used VSAE and I knew how to develop custom snippet templates in VSAE, still took me like 20-30 minutes to develop such snippet template, then generated MP fragment, built MP, testing, pushing to Production etc. And since our customers has already identified their requirements, I shouldn’t need to be involved at all if we have an automation solution in place.

As I demonstrated in my 2015 Melbourne MVP Community Camp presentation (demo 2, start from 28:05, link provided above), I have designed a set of tasks for customers to request new monitors:

* New New blank unsealed MP
* Create a unit monitor in a "Test" management group
* Created a SMA runbook that runs daily and populates the MP list of my Test MG onto a SharePoint List
* When customers have tested the newly created monitor and happy with it, he / she can go to the SharePoint List, locate the specific MP where the monitor is stored, and use a drop-down box to copy the MP to the production environment.

This process has covered the entire process of creating, testing and implementing the new SCOM monitoring requirements without getting OpsMgr administrators involved at all!

### What functions / activities are included in this release of OpsMgrExtended

In the first release of this module, I have included 34 PowerShell functions (if you watched the presentation recording, there were 29 back in January, I’ve added few more since). These functions can be grouped into 3 categories:

**SDK Connection Functions**

* Import-OpsMgrSDk
  * Load the SDK assemblies. It will firstly try to load them from GAC, if the assemblies are not in GAC, it will load them from the SDK DLLs from the module base folder.
* Install-OpsMgrSDK
  * Install the OpsMgr SDK DLLs from the module base folder to the GAC
* Connect-OMManagementGroup
  * Establish connection to the OpsMgr management group by specifying a management server name (and optional alternative username and password).

**Administrative Tasks**

* Approve-OMManualAgents
  * Approve manually installed OpsMgr agents that meet the naming convention.
* Backup-OMManagementPacks
  * Backup OpsMgr management packs (unsealed and sealed).
* Add-OMManagementGroupToAgent
  * Configure an OpsMgr agent to report to a specific management group using WinRM.
* Remove-OMManagementGroupFromAgent
  * Remove a management group configuration from an OpsMgr agent using WinRM.
* Get-OMManagementGroupDefaultSettings
  * Get OpsMgr management group default settings via OpsMgr SDK. A System.Collections.ArrayList is returned containing all management group default settings. Each setting in the arraylist is presented in a hashtable format.
* Set-OMManagementGroupDefaultSetting
  * Set OpsMgr management group default settings.

**Basic Authoring Tasks**

* Get-OMManagementPack
  * Get a particular management pack by providing the management pack name or get all management pack in an OpsMgr management group using OpsMgr SDK.
* New-OMManagementPack
  * Create a new unsealed management pack in an OpsMgr management group.
* Remove-OMManagementPack
  * Remove a management pack from an OpsMgr management group.
* Copy-OMManagementPack
  * Copy an unsealed management pack from a source OpsMgr management group to the destination. management group.
* New-OMManagementPackReference
  * Add a management pack reference to an unsealed management pack.
* New-OM2StateEventMonitor
  * Create a 2-state event monitor in OpsMgr.
* New-OM2StatePerformanceMonitor
  * Create a 2-state performance monitor in OpsMgr.
* New-OMPerformanceCollectionRule
  * Create a performance collection rule in OpsMgr.
* New-OMEventCollectionRule
  * Create an event collection rule in OpsMgr.
* New-OMServiceMonitor
  * Create a Windows service monitor in OpsMgr.
* New-OMInstanceGroup
  * Create an empty instance group in OpsMgr using OpsMgr SDK. The group membership must be populated manually or via another script.
* New-OMComputerGroup
  * Create an empty computer group in OpsMgr using OpsMgr SDK. The group membership must be populated manually or via another script.
* New-OMConfigurationOverride
  * Create a configuration (parameter) override in OpsMgr using OpsMgr SDK.
* New-OMPropertyOverride
  * Create a property override in OpsMgr using OpsMgr SDK.
* New-OMOverride
  * Create an override in OpsMgr using OpsMgr SDK. This function would detect whether it’s a property override or configuration override and call New-OMPropertyOverride or new-OMConfigurationOverride accordingly.
* Remove-OMGroup
  * Remove an instance group or computer group in OpsMgr using OpsMgr SDK.
* Remove-OMOverride
  * Remove an override in OpsMgr.
* Get-OMDAMembers
  * Get monitoring objects that are members of a Distributed Application in OpsMgr using OpsMgr SDK. By default, this function only retrieves objects one level down. Users can use -Recursive parameter to retrieve all objects within the DA hierarchy.
* New-OMAlertConfiguration
  * Create a new OpsMgrExtended.AlertConfiguration object that can be passed to the New-OMRule function as an input. This object is required for the New-OMRule function when creating an alert generating rule.
* New-OMModuleConfiguration
  * Create a new OpsMgrExtended.ModuleConfiguration object that can be passed to the New-OMRule function as an input.
* New-OMRule
  * Create a rule in OpsMgr by specifying data source modules, optional condition detection module, write action modules and also alert configuration when creating an alert generating rule. This function can be used to create any types of rules in OpsMgr.
* New-OMWindowsServiceTemplateInstance
  * Create a Windows Service monitoring template instance in OpsMgr.

**Advanced Authoring Tasks**

* New-OMTCPPortCheckDataSourceModuleType
* New-OMTCPPortCheckMonitorType
* New-OMTCPPortMonitoring

Last year, when I asked few OpsMgr focused MVPs for advice and feedbacks, my buddy <a href="http://scug.be/dieter/" target="_blank">Dieter Wijckmans</a> suggested me to create a function that creates a TCP Port monitoring template instance. When I had a look, I did not like the MP elements created by this template. As I explained in my MVP Community Camp presentation (Demo 3, starts at 47:13 in the recording), I didn’t like the module type and monitor types created by the TCP Port monitoring template because many values have been hard coded in the modules and the monitor types did not enable On-Demand detections. Therefore, instead of creating an instance of this template using SDK, I’ve taken the hard route, spent a week, written 1,200 lines of PowerShell code, recreated all the MP elements the way I wanted.

When you use New-OMTCPPortMonitoring function from this module, it creates the following items:

* Class Definition for TCP Port Watcher and various groups
* Class Relationships
* Class and Relationship Discoveries
* Data Source Module Type
* Monitor Type
* Performance Collection Rule
* 4 Unit Monitors and a dependency monitor
* Discovery Overrides

The monitors created by **New-OMTCPPortMonitoring** supports On-Demand detection (which can be triggered by clicking the "Recalculate Health" button in Health Explorer), and I have variablised the data source module type and monitor type, so they can be reused for other workflows.

### Establishing Connections to OpsMgr Management Groups

**Configuring SMA Integration Module**

When using this module in SMA, you may create a connection object to your OpsMgr management group.

<a href="http://blog.tyang.org/wp-content/uploads/2015/06/image12.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/06/image_thumb12.png" alt="image" width="396" height="252" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2015/06/image13.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/06/image_thumb13.png" alt="image" width="402" height="256" border="0" /></a>

* **Connection Type:** Operations Manager SDK
* **Name:** Name of this SMA connection object
* **Description:** Description of this SMA connection
* **ComputerName:** One of the OpsMgr management servers
* **UserName:** A Service Account that has OpsMgr administrator access
* **Password:** Password for the service account

**Connecting in Normal PowerShell Scripts**

When this module is used as a normal PowerShell module, all the functions that require OpsMgr management group connections support the following 3 parameters:

* -**SDK:** One of the OpsMgr management servers
* **-Username (optional):** Alternative account to connect to OpsMgr management group.
* **-Password (optional):** the password for the alternative account.

## Getting Help and More Information

I have included help information for every function in this module. You can access if using Get-Help cmdlet.

i.e. **Get-help New-OMRule –Full**

<a href="http://blog.tyang.org/wp-content/uploads/2015/06/SNAGHTMLeaa1c1f.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLeaa1c1f" src="http://blog.tyang.org/wp-content/uploads/2015/06/SNAGHTMLeaa1c1f_thumb.png" alt="SNAGHTMLeaa1c1f" width="417" height="435" border="0" /></a>

Once imported in SMA, you can also see the description for each function in the WAP Admin portal:

<a href="http://blog.tyang.org/wp-content/uploads/2015/06/SNAGHTMLeaf2cd0.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLeaf2cd0" src="http://blog.tyang.org/wp-content/uploads/2015/06/SNAGHTMLeaf2cd0_thumb.png" alt="SNAGHTMLeaf2cd0" width="498" height="411" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2015/06/SNAGHTMLeb0d60c.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLeb0d60c" src="http://blog.tyang.org/wp-content/uploads/2015/06/SNAGHTMLeb0d60c_thumb.png" alt="SNAGHTMLeb0d60c" width="443" height="340" border="0" /></a>

## Getting Started

I have written many sample runbooks for this module. Initially, my plan was to release these sample runbooks together with the module. Then I had a second thought, I think instead of releasing these samples now, I will make this a blog series and continue writing posts explaining how to use this module for different scenarios. I believe by doing so, it will help readers better understand the capability this module brings. I will name this series "Automating OpsMgr" and consider this is Part 1 of this series.

## System Requirements

The minimum PowerShell version required for this module is 3.0.

The entire module and sample runbooks were developed on Windows Server 2012 R2, Windows 8.1, OpsMgr 2012 R2 and PowerShell version 4.0.

I have not test this module on OpsMgr 2012 RTM and SP1. Although the SDK assembly version is the same between RTM, SP1 and R2, I cannot guarantee all functions and upcoming sample runbooks would work 100% on RTM and SP1 versions. If you have identified any issues, please let me know.

I have performed very limited testing on PowerShell 5.0 Preview. I cannot guarantee it will work with PowerShell 5.0 100%. But if you manage to find any issues on PowerShell 5.0, please let me know.

## Where Can I Download this Module?

This module can be downloaded from TY Consulting’s web site from link below:

<a href="http://www.tyconsulting.com.au/portfolio/opsmgrextended-powershell-and-sma-module/" target="_blank">DOWNLOAD HERE</a>.

I’m releasing this module under <a href="http://www.apache.org/licenses/LICENSE-2.0" target="_blank">Apache License Version 2.0</a>. If you do not agree with the term, please do not download or use this module.

Because this module requires OpsMgr 2012 SDK DLLs, and I am not allowed to distribute these DLLs (refer to System Center 2012 R2 Operations Manager EULA Section 7 Scope of License, which can be located on the OpsMgr 2012 R2 DVD under Licenses folder).

<a href="http://blog.tyang.org/wp-content/uploads/2015/06/image14.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/06/image_thumb14.png" alt="image" width="381" height="375" border="0" /></a>

Therefore, once you’ve downloaded this module, you will need to manually copy the following 3 DLLs into the module folder:

* Microsoft.EnterpriseManagement.Core.dll
* Microsoft.EnterpriseManagement.OperationsManager.dll
* Microsoft.EnterpriseManagement.Runtime.dll

These DLLs can be found on your OpsMgr management server, under **<OpsMgr Install Dir>\Server\SDK Binaries**:

<a href="http://blog.tyang.org/wp-content/uploads/2015/06/image15.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/06/image_thumb15.png" alt="image" width="532" height="129" border="0" /></a>

Copy them into the module folder:

<a href="http://blog.tyang.org/wp-content/uploads/2015/06/image16.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/06/image_thumb16.png" alt="image" width="537" height="273" border="0" /></a>

If it’s intended to be used in SMA, you will need to zip the folder back after DLLs been copied to the folder, then import the module in SMA.

Looking back, this has has been a very long journey - I have written around 6,800 lines of code for this module alone, not including all the sample runbooks that I'm going to publish for this blog series. I hope the community would find it useful, and please feel free to contact me if you have any new ideas or suggestions.

This is all I have for the Part 1 of this new series. In the next couple of days, I will discuss how to use the OpsMgrExtended module to create ConfigMgr log collections rules for OMS (As I previously blogged <a href="http://blog.tyang.org/2015/06/10/collecting-configmgr-logs-to-microsoft-operation-management-suite-the-nice-way/" target="_blank">here</a>.)