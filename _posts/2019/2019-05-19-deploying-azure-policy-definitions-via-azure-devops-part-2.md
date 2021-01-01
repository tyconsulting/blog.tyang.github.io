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

<a href="https://blog.tyang.org/2019/05/19/deploying-azure-policy-definitions-via-azure-devops-part-1/"><strong>Part 1:</strong> Custom deployment scripts for policy and initiative definitions</a>

<strong>Part 2:</strong> Pester-test policy and initiative definitions in the build pipeline

<a href="https://blog.tyang.org/2019/05/19/deploying-azure-policy-definitions-via-azure-devops-part-3/"><strong>Part 3:</strong> Configuring build (CI) and release (CD) pipelines in Azure DevOps</a>

In this part, I will walk through the PowerShell module I have developed to pester-test policy and initiative definitions. My intention is to uses these tests to perform syntax validation in the build pipeline, ensure all the definition files are valid before being deployed in the release pipelines.

You can find the source code of this module here:

PowerShell module AzPolicyTest: <a href="https://github.com/tyconsulting/AzPolicyTest">https://github.com/tyconsulting/AzPolicyTest</a>

<h3>AzPolicyTest  PowerShell Module</h3>

This module provides the following functions:

<ul>
    <li><strong>Test-AzPolicyDefinition</strong>: Pester test Azure Policy definition syntax. Designed to test the azurepolicy.json files</li>
    <li><strong>Test-AzPolicySetDefinition</strong>: Pester test Azure Initiative definition syntax. Designed to test the azurepolicyset.json files</li>
    <li><strong>Test-JSONContent</strong>: Pester test for validating syntax of JSON files</li>
</ul>

All these commands support bulk testing more than one files if the path you’ve passed in is a folder.

The <strong>Test-AzPolicyDefinition</strong> performs the following tests against the Azure Policy definition json files:

<ul>
    <li>Top-level elements tests
<ul>
    <li>must contain element "name"</li>
    <li>must contain element "properties"</li>
</ul>
</li>
    <li>Definition elements value tests
<ul>
    <li>name value should not be null</li>
    <li>name value must not be longer than 64 characters</li>
    <li>name value must not contain spaces</li>
</ul>
</li>
    <li>Policy definition properties value test
<ul>
    <li>The properties element must contain "displayName" sub-element</li>
    <li>The properties element must contain "description" sub-element</li>
    <li>The properties element must contain "metadata" sub-element</li>
    <li>The properties element must contain "parameters" sub-element</li>
    <li>The properties element must contain "policyRule" sub-element</li>
    <li>displayname value must not be blank</li>
    <li>description value must not be blank</li>
    <li>"Category" must be defined in metadata</li>
</ul>
</li>
    <li>Policy rule test
<ul>
    <li>policy rule must contain "if" sub-element</li>
    <li>policy rule must contain "then" sub-element</li>
    <li>policy rule must use a valid effect (‘deny’, ‘audit’, ‘append’, ‘auditIfNotExists’, ‘disabled’, ‘deployIfNotExists’)</li>
</ul>
</li>
    <li>DeployIfNotExists effect configuration test
<ul>
    <li>When ‘DeployIfNotExists" effect is used, it must contain ‘details’ sub-element under ‘then’ in policy rule</li>
    <li>DeployIfNotExists Policy rule must contain a embedded 'deployment' element</li>
    <li>Deployment mode for 'DeployIfNotExists' effect must be 'incremental'</li>
    <li>DeployIfNotExists' Policy rule must contain a 'roleDefinitionIds' element</li>
    <li>roleDefinitionIds element must contain at least one item</li>
</ul>
</li>
    <li>DeployIfNotExists Embedded ARM Template Test
<ul>
    <li>Embedded template Must have a valid schema</li>
    <li>Embedded template Must contain a valid contentVersion</li>
    <li>Embedded template Must contain a 'parameters' element</li>
    <li>Embedded template Must contain a 'variables' element</li>
    <li>Embedded template Must contain a ‘resources’ element</li>
    <li>Embedded template Must contain a 'outputs’ element</li>
</ul>
</li>
</ul>

<a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-1.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-1.png" alt="image" width="646" height="638" border="0" /></a>

The <strong>Test-AzPolicySetDefinition</strong> performs the following tests against the Azure initiative definition json files:

<ul>
    <li style="list-style-type: none;">
<ul>
    <li style="list-style-type: none;">
<ul><!--StartFragment--></ul>
</li>
</ul>
</li>
</ul>

<ul>
    <li style="list-style-type: none;">
<ul>
    <li style="list-style-type: none;">
<ul>
    <li>Top-level elements tests
<ul>
    <li>must contain element "name"</li>
    <li>must contain element "properties"</li>
</ul>
</li>
    <li style="list-style-type: none;">
<ul><!--StartFragment--></ul>
</li>
</ul>
</li>
</ul>
</li>
</ul>

<ul>
    <li style="list-style-type: none;">
<ul>
    <li style="list-style-type: none;">
<ul>
    <li style="list-style-type: none;">
<ul>
    <li>Definition elements value tests
<ul>
    <li>name value should not be null</li>
    <li>name value must not be longer than 64 characters</li>
    <li>name value must not contain spaces</li>
</ul>
</li>
</ul>
</li>
    <li style="list-style-type: none;">
<ul>
    <li style="list-style-type: none;">
<ul><!--StartFragment--></ul>
</li>
</ul>
</li>
</ul>
</li>
</ul>
</li>
</ul>

<ul>
    <li style="list-style-type: none;">
<ul>
    <li style="list-style-type: none;">
<ul>
    <li style="list-style-type: none;">
<ul>
    <li>Policy definition properties value test
<ul>
    <li>The properties element must contain "displayName" sub-element</li>
    <li>The properties element must contain "description" sub-element</li>
    <li>The properties element must contain "metadata" sub-element</li>
    <li>The properties element must contain "parameters" sub-element</li>
    <li>The properties element must contain "policyDefinitions" sub-element</li>
    <li>policyDefinitions element must contain at least one item</li>
    <li>displayname value must not be blank</li>
    <li>description value must not be blank</li>
    <li>"Category" must be defined in metadata</li>
</ul>
</li>
    <li>Member policy test
<ul>
    <li>Member policy must contain ‘policyDefinitionId’ element</li>
    <li>‘policyDefinitionId’ must contain a value</li>
</ul>
</li>
</ul>
</li>
</ul>
</li>
</ul>
</li>
</ul>

<a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-2.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-2.png" alt="image" width="633" height="707" border="0" /></a>

<h3><!--EndFragment-->Publishing AzPolicyTest to Azure Artifacts Feed</h3>

I need a place to host the PowerShell module, so it can be installed at runtime – since I’m planning to use the Microsoft-hosted agents in Azure DevOps.

Azure Artifacts supports NuGet and private repo, and it’s a component in Azure DevOps, so I didn't bother to use other 3rd party services such as MyGet this time.

Microsoft provides an awesome instruction on how to use Azure Artifacts feeds as private PowerShell repositories. You can find it here: <a href="https://docs.microsoft.com/en-us/azure/devops/artifacts/tutorials/private-powershell-library?view=azure-devops">https://docs.microsoft.com/en-us/azure/devops/artifacts/tutorials/private-powershell-library?view=azure-devops</a>

The high level process consists of the following steps:

<ol>
    <li>Setup a NuGet feed for the Azure Artifacts feed on your development computer</li>
    <li>Create a NuGet specification (.nuspec) file for the PowerShell module</li>
    <li>Create a NuGet package based on the .nuspec file</li>
    <li>Publish the NuGet package to the Azure Artifacts feed</li>
</ol>

<strong>Note:</strong> The Microsoft’s documentation also showed how to setup the feed as a PowerShell repository in PowerShell. This is not required here because we don’t need to install the module from the Azure Artifacts feed to the local computer

The nuspec file is already provided in the AzPolicyTest’s GitHub repo, if you want to re-use the module, simply package it and push it to your Azure Artifacts feed.

<strong>Note: </strong>You also need to publish all dependency modules to the NuGet feed. In this case, since this module requires Pester (version 4.7.0 or above). you will need to download the nuget package from <a href="https://www.powershellgallery.com/packages/Pester/" target="_blank" rel="noopener noreferrer">PowerShell Gallery</a> (select Manual Download), and publish it to Azure Artifacts. This is required because at the time of writing, Azure Artifacts does not support NuGet upstream feeds. so I can’t setup PowerShell Gallery as an upstream feed.

This concludes the 2nd part of the blog series. In part 3, I will walk through the process of setting up build and release pipelines.

<!--EndFragment-->