---
id: 7021
title: Deploying Azure Policy Definitions via Azure DevOps (Part 2)
date: 2019-05-19T23:05:32+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=7021
permalink: /2019/05/19/deploying-azure-policy-definitions-via-azure-devops-part-2/
categories:
  - Azure
tags:
  - Azure
  - Azure DevOps
  - Azure Policy
  - DevOpsAzurePolicySeries
  - PowerShell
---
This is the 2nd installment of the 3-part blog series. You can find the other parts here:

<a href="https://blog.tyang.org/2019/05/19/deploying-azure-policy-definitions-via-azure-devops-part-1/">**Part 1:** Custom deployment scripts for policy and initiative definitions</a>

**Part 2:** Pester-test policy and initiative definitions in the build pipeline

<a href="https://blog.tyang.org/2019/05/19/deploying-azure-policy-definitions-via-azure-devops-part-3/">**Part 3:** Configuring build (CI) and release (CD) pipelines in Azure DevOps</a>

In this part, I will walk through the PowerShell module I have developed to pester-test policy and initiative definitions. My intention is to uses these tests to perform syntax validation in the build pipeline, ensure all the definition files are valid before being deployed in the release pipelines.

You can find the source code of this module here:

PowerShell module AzPolicyTest: <a href="https://github.com/tyconsulting/AzPolicyTest">https://github.com/tyconsulting/AzPolicyTest</a>


## AzPolicyTest  PowerShell Module

This module provides the following functions:

* **Test-AzPolicyDefinition**: Pester test Azure Policy definition syntax. Designed to test the azurepolicy.json files
* **Test-AzPolicySetDefinition**: Pester test Azure Initiative definition syntax. Designed to test the azurepolicyset.json files
* **Test-JSONContent**: Pester test for validating syntax of JSON files


All these commands support bulk testing more than one files if the path you’ve passed in is a folder.

The **Test-AzPolicyDefinition** performs the following tests against the Azure Policy definition json files:


* Top-level elements tests
  * must contain element "name"
  * must contain element "properties"
* Definition elements value tests
  * name value should not be null
  * name value must not be longer than 64 characters
  * name value must not contain spaces
* Policy definition properties value test
  * The properties element must contain "displayName" sub-element
  * The properties element must contain "description" sub-element
  * The properties element must contain "metadata" sub-element
  * The properties element must contain "parameters" sub-element
  * The properties element must contain "policyRule" sub-element
  * displayname value must not be blank
  * description value must not be blank
  * "Category" must be defined in metadata
* Policy rule test
  * policy rule must contain "if" sub-element
  * policy rule must contain "then" sub-element
  * policy rule must use a valid effect (‘deny’, ‘audit’, ‘append’, ‘auditIfNotExists’, ‘disabled’, ‘deployIfNotExists’)
* DeployIfNotExists effect configuration test
  * When ‘DeployIfNotExists" effect is used, it must contain ‘details’ sub-element under ‘then’ in policy rule
  * DeployIfNotExists Policy rule must contain a embedded 'deployment' element
  * Deployment mode for 'DeployIfNotExists' effect must be 'incremental'
  * DeployIfNotExists' Policy rule must contain a 'roleDefinitionIds' element
  * roleDefinitionIds element must contain at least one item
* DeployIfNotExists Embedded ARM Template Test
  * Embedded template Must have a valid schema
  * Embedded template Must contain a valid contentVersion
  * Embedded template Must contain a 'parameters' element
  * Embedded template Must contain a 'variables' element
  * Embedded template Must contain a ‘resources’ element
  * Embedded template Must contain a 'outputs’ element

<a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-1.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-1.png" alt="image" width="646" height="638" border="0" /></a>

The **Test-AzPolicySetDefinition** performs the following tests against the Azure initiative definition json files:

* Top-level elements tests
  * must contain element "name"
  * must contain element "properties"
* Definition elements value tests
  * name value should not be null
  * name value must not be longer than 64 characters
  * name value must not contain spaces
* Policy definition properties value test
  * The properties element must contain "displayName" sub-element
  * The properties element must contain "description" sub-element
  * The properties element must contain "metadata" sub-element
  * The properties element must contain "parameters" sub-element
  * The properties element must contain "policyDefinitions" sub-element
  * policyDefinitions element must contain at least one item
  * displayname value must not be blank
  * description value must not be blank
  * "Category" must be defined in metadata
* Member policy test
  * Member policy must contain ‘policyDefinitionId’ element
  * ‘policyDefinitionId’ must contain a value

<a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-2.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-2.png" alt="image" width="633" height="707" border="0" /></a>

## Publishing AzPolicyTest to Azure Artifacts Feed

I need a place to host the PowerShell module, so it can be installed at runtime – since I’m planning to use the Microsoft-hosted agents in Azure DevOps.

Azure Artifacts supports NuGet and private repo, and it’s a component in Azure DevOps, so I didn't bother to use other 3rd party services such as MyGet this time.

Microsoft provides an awesome instruction on how to use Azure Artifacts feeds as private PowerShell repositories. You can find it here: <a href="https://docs.microsoft.com/en-us/azure/devops/artifacts/tutorials/private-powershell-library?view=azure-devops">https://docs.microsoft.com/en-us/azure/devops/artifacts/tutorials/private-powershell-library?view=azure-devops</a>

The high level process consists of the following steps:

1. Setup a NuGet feed for the Azure Artifacts feed on your development computer
2. Create a NuGet specification (.nuspec) file for the PowerShell module
3. Create a NuGet package based on the .nuspec file
4. Publish the NuGet package to the Azure Artifacts feed

>**Note:** The Microsoft’s documentation also showed how to setup the feed as a PowerShell repository in PowerShell. This is not required here because we don’t need to install the module from the Azure Artifacts feed to the local computer

The nuspec file is already provided in the AzPolicyTest’s GitHub repo, if you want to re-use the module, simply package it and push it to your Azure Artifacts feed.

>**Note:** You also need to publish all dependency modules to the NuGet feed. In this case, since this module requires Pester (version 4.7.0 or above). you will need to download the nuget package from <a href="https://www.powershellgallery.com/packages/Pester/" target="_blank" rel="noopener noreferrer">PowerShell Gallery</a> (select Manual Download), and publish it to Azure Artifacts. This is required because at the time of writing, Azure Artifacts does not support NuGet upstream feeds. so I can’t setup PowerShell Gallery as an upstream feed.

This concludes the 2nd part of the blog series. In part 3, I will walk through the process of setting up build and release pipelines.