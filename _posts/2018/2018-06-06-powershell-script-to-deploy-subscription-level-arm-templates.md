---
id: 6486
title: PowerShell Script to Deploy Subscription Level ARM Templates
date: 2018-06-06T23:10:31+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=6486
permalink: /2018/06/06/powershell-script-to-deploy-subscription-level-arm-templates/
categories:
  - Azure
  - PowerShell
  - VSTS
tags:
  - ARM Template
  - Azure
  - Powershell
  - VSTS
---
<h3>Introduction</h3>
In my <a href="https://blog.tyang.org/2018/06/06/using-arm-templates-to-deploying-azure-policy-definitions-that-requires-input-parameters/">previous post</a>, I demonstrated how to deploy Azure Policy definitions that require input parameters via ARM templates. as I mentioned in that post, at the time of writing, the tooling has not been updated to allow subscription level ARM template deployments. The only possible way to deploy such template right now is via the ARM REST API.

I have a requirement to deploy subscription level templates in VSTS pipelines. since I can’t use the native AzureRM PowerShell module or the Azure Resource Group Deployment VSTS task, I had to create a PowerShell script that can be used under the context of Azure PowerShell VSTS task.
<h3>Requirements</h3>
The script has the following requirements:

<strong>1. Being able to invoke ARM REST API within the Azure PowerShell VSTS task.</strong>

In order to invoke ARM REST APIs, an Azure AD oAuth token needs to be generated to access the resources in ARM endpoints (<a href="https://management.azure.com">https://management.azure.com</a>). Based on my own research, when running scripts in Azure PowerShell VSTS task, the oAuth token is not retrievable using Get-AzureRMContext cmdlet. To work around this limitation, I manually created the Azure AD Service Principal that the VSTS Service Endpoint uses and stored the key as a secret in an Azure Key Vault. Then created a variable group in the VSTS project and used it to retrieve the Service Principal key from the key vault. The key and the service principal name is passed into the script, the script looks up the Service Principal based on it’s name, and generates an oAuth token for ARM REST API calls.
<blockquote><strong>Note:</strong> In case you ask why not use the <a href="https://docs.microsoft.com/en-us/vsts/pipelines/scripts/powershell?view=vsts#oauth">oAuth token that can be made available in VSTS</a>? Based on my research and testing, that token is generated for invoking VSTS REST APIs, not ARM APIs. So the answer is no, I can’t use that token.</blockquote>
<strong>2. Being able to perform ARM template validation</strong>

Part of the build (CI) pipeline would be validating the ARM template and input parameters, make sure it template is valid before kicking off the release (CD) task. so the same script can also be used to perform the validation using an input parameter.
<h3>PowerShell Script Deploy-SubscriptionLevelTemplate.ps1</h3>
https://gist.github.com/tyconsulting/25915358d7d521e846260cead4211bd4

In order to execute the script, you will firstly need to create a service principal and also pass its key to the script.

<a href="https://blog.tyang.org/wp-content/uploads/2018/06/image-3.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/06/image_thumb-3.png" alt="image" width="637" height="600" border="0" /></a>

This service principal must have sufficient privilege in the subscription that you are deploying the template to. In my case, since I’m deploying policy definitions, the Service Principal needs to have the subscription Owner role because the Contributor role does not have required rights in Microsoft.Authorization resource provider.

To manually execute the script outside of the VSTS pipeline, you can do something like this:
<pre language="powershell">$TenantId = '74edd9d1-c33c-4890-bbfe-53d8eea27fad'
$SubscriptionId = '3fe4fa99-78ff-44a2-ad57-4d2cba88790a'
$ServicePrincipalAppNamePrefix = 'vsts'
$ServicePrincipalKey = 'ENTER YOUR SP KEY HERE'

$location = 'australiasoutheast'
Add-AzureRMAccount -Subscription $SubscriptionId

$TemplateFilePath = 'C:\temp\allowedRoleDefinitionDemo.azuredeploy.json'
$ParameterFilePath = "C:\temp\allowedRoleDefinitionDemo.azuredeploy.parameters.json"
.\Deploy-SubscriptionLevelTemplate.ps1 -TenantId $tenantId -SubscriptionId $SubscriptionId -location $location -ServicePrincipalAppNamePrefix $ServicePrincipalAppNamePrefix -ServicePrincipalKey $ServicePrincipalKey -TemplateFilePath $TemplateFilePath -ParameterFilePath $ParameterFilePath  -Verbose
</pre>
Few things to be aware of:
<ul>
 	<li>By default, the script parameter –validate is set to $false, to perform template validation instead of deployment, use <strong>–validate $true</strong> when executing the script.</li>
 	<li>The location field is still required even when deploying the template to a subscription (instead of a resource group)</li>
 	<li>the –ParameterFilePath parameter is optional. Only use it if you need to pass parameters into the template</li>
 	<li>You still need to login to Azure using Add-AzureRMAccount, because if you execute this script within the Azure PowerShell task in VSTS, it is already logged in using the service endpoint you have specified. This is to simulate the same context, and it is required to lookup the Azure AD Service Principal.</li>
 	<li>The function that generates oAuth token for the Service Principal is copied from my PowerShell module <strong>AzureServicePrincipalAccount</strong> (<a href="https://github.com/tyconsulting/AzureServicePrincipalAccount-PS">GitHub</a>, <a href="https://www.powershellgallery.com/packages/AzureServicePrincipalAccount">PSGallery</a>). I took it out instead of using the module so we don’t have to worry about installing the module to the VSTS agents.</li>
 	<li>I have put a lot of information in the verbose stream. Use –verbose to view them</li>
</ul>
i.e. the output when I deployed the sample template from my previous post:

<a href="https://blog.tyang.org/wp-content/uploads/2018/06/image-4.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/06/image_thumb-4.png" alt="image" width="1002" height="1078" border="0" /></a>
<h3>Using it in VSTS</h3>
To demonstrate this, I created a very simple project and pipelines in VSTS, in real life, you’d probably want to have additional tasks in your pipelines (i.e. running pester tests, etc.).

<strong>Creating a variable group to retrieve the Service Principal key from key vault (you will need to store it in KV manually first)</strong>

<a href="https://blog.tyang.org/wp-content/uploads/2018/06/image-5.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/06/image_thumb-5.png" alt="image" width="760" height="524" border="0" /></a>

<strong>Create Build Pipeline</strong>

<a href="https://blog.tyang.org/wp-content/uploads/2018/06/image-6.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/06/image_thumb-6.png" alt="image" width="802" height="855" border="0" /></a>

Firstly, associate the variable group to the build:

<a href="https://blog.tyang.org/wp-content/uploads/2018/06/image-7.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/06/image_thumb-7.png" alt="image" width="717" height="322" border="0" /></a>

The first Azure PowerShell task "Get Azure Subscription Details" retrieves the tenant and subscription Id from AzureRM context and store them as variables. here’s the inline script:
<pre language="powershell">$Context = Get-AzureRMContext
$TenantId = $Context.Tenant.Id
$SubId = $Context.subscription.Id
Write-Output ("##vso[task.setvariable variable=TenantId]$TenantId")
Write-Output ("##vso[task.setvariable variable=SubscriptionId]$SubId")
</pre>
<a href="https://blog.tyang.org/wp-content/uploads/2018/06/image-8.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/06/image_thumb-8.png" alt="image" width="961" height="790" border="0" /></a>

The second Azure PowerShell task executes the Deploy-SubscriptionLevelTemplate.ps1 script with the following parameters:

-TenantId $(TenantId) -SubscriptionId $(SubscriptionId) -location 'australiasoutheast' -ServicePrincipalAppNamePrefix 'vsts' -ServicePrincipalKey $(vsts) -TemplateFilePath "$(Build.SourcesDirectory)/ARMDeploymentDemo/SubLevelTemplateDemo/tagDemo.azuredeploy.json" -ParameterFilePath "$(Build.SourcesDirectory)/ARMDeploymentDemo/SubLevelTemplateDemo/tagDemo.azuredeploy.parameters.json" -validate $true

<a href="https://blog.tyang.org/wp-content/uploads/2018/06/image-9.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/06/image_thumb-9.png" alt="image" width="1002" height="532" border="0" /></a>
<blockquote><strong>Note:</strong> modify the parameters to suit your own needs.</blockquote>
Lastly, add a MSBuild step and a Publish Build Artifact step so the release task can access the output of the build pipeline.

<strong>Create Release Pipeline</strong>

firstly, create one or more environments according to your requirement. In this demo, I only have one:

<a href="https://blog.tyang.org/wp-content/uploads/2018/06/image-10.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/06/image_thumb-10.png" alt="image" width="711" height="552" border="0" /></a>

Link the variable group either to an environment or to the release

<a href="https://blog.tyang.org/wp-content/uploads/2018/06/image-11.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/06/image_thumb-11.png" alt="image" width="731" height="261" border="0" /></a>

Create two Azure PowerShell tasks. first task is to get the tenant Id and subscription Id, same as the build pipeline. the second task is executing the Deploy-SubscriptionLevelTemplate.ps1 script. note the input parameters are slightly different (different VSTS variables are used)

<a href="https://blog.tyang.org/wp-content/uploads/2018/06/image-12.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/06/image_thumb-12.png" alt="image" width="1002" height="524" border="0" /></a>

Input parameters (change it according to your requirements):

-TenantId $(TenantId) -SubscriptionId $(SubscriptionId) -location 'australiasoutheast' -ServicePrincipalAppNamePrefix 'vsts' -ServicePrincipalKey $(vsts) -TemplateFilePath "$(System.DefaultWorkingDirectory)/_ARMDeploymentDemo-CI/drop/SubLevelTemplateDemo/tagDemo.azuredeploy.json" -ParameterFilePath "$(System.DefaultWorkingDirectory)/_ARMDeploymentDemo-CI/drop/SubLevelTemplateDemo/tagDemo.azuredeploy.parameters.json" –verbose

<strong>Build Pipeline Execution output</strong>

<a href="https://blog.tyang.org/wp-content/uploads/2018/06/image-13.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/06/image_thumb-13.png" alt="image" width="1002" height="698" border="0" /></a>

<strong>Release Pipeline Execution output</strong>

<a href="https://blog.tyang.org/wp-content/uploads/2018/06/image-14.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/06/image_thumb-14.png" alt="image" width="1002" height="686" border="0" /></a>

If the template or parameter files contain errors, the build would fail:

<a href="https://blog.tyang.org/wp-content/uploads/2018/06/image-15.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/06/image_thumb-15.png" alt="image" width="945" height="408" border="0" /></a>
<h3>Summary</h3>
This script is designed primarily for VSTS Azure PowerShell task, therefore I’m using an AAD Service Principal.

It does not support specifying ARM input parameters as script input or specifying ARM template and parameters files in a URI format (like what AzureRM module does), because I don’t have such a requirement. Feel free to modify this script to suit your requirements. Suggestions are always welcome. just leave me a message in the comment area.