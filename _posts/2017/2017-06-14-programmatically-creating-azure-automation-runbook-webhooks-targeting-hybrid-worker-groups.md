---
id: 6117
title: Programmatically Creating Azure Automation Runbook Webhooks Targeting Hybrid Worker Groups
date: 2017-06-14T11:25:25+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=6117
permalink: /2017/06/14/programmatically-creating-azure-automation-runbook-webhooks-targeting-hybrid-worker-groups/
categories:
  - Azure
  - PowerShell
tags:
  - Azure
  - Azure Automation
  - Powershell
---
In Azure Automation, you can create a webhook for a runbook and target it to a Hybrid Worker group (as opposed to run on Azure). In the Azure portal, it is pretty easy to configure this ‘RunOn’ property when you are creating the webhook.

<a href="https://blog.tyang.org/wp-content/uploads/2017/06/image-1.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/06/image_thumb-1.png" alt="image" width="489" height="263" border="0" /></a>

However, at the time of writing this blog post, it is STILL not possible to specify where the webhook should target when creating it using the Azure Automation PowerShell module AzureRM.Automation (version 3.1.0 at the time of writing). The cmdlet New-AzureRMAutomationWebhook does not provide a parameter where you can specify the webhook "RunOn" target:

<a href="https://blog.tyang.org/wp-content/uploads/2017/06/image-2.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/06/image_thumb-2.png" alt="image" width="890" height="439" border="0" /></a>

there are several issues already logged by the community to the Azure PowerShell GitHub repo for this limitation:
<ul>
 	<li><a title="https://github.com/Azure/azure-powershell/issues/2247" href="https://github.com/Azure/azure-powershell/issues/2247">https://github.com/Azure/azure-powershell/issues/2247</a></li>
 	<li><a title="https://github.com/Azure/azure-powershell/issues/3082" href="https://github.com/Azure/azure-powershell/issues/3082">https://github.com/Azure/azure-powershell/issues/3082</a></li>
</ul>
I needed to create webhooks targeting Hybrid Worker groups in a PowerShell script last week, so I looked into using alternative methods. Other than the AzureRM.Automation PowerShell module, we can also create webhooks using the Azure Resource Manager (ARM) REST API and the ARM deployment templates. According to the documentations, both the REST API and template support the "RunOn" parameter. so this limitation is only related to the AzureRM.Automation PowerShell module. The REST API and ARM template documentations are located here:
<ul>
 	<li>REST API: <a title="https://docs.microsoft.com/en-us/rest/api/automation/webhook#Webhook_CreateOrUpdate" href="https://docs.microsoft.com/en-us/rest/api/automation/webhook#Webhook_CreateOrUpdate">https://docs.microsoft.com/en-us/rest/api/automation/webhook#Webhook_CreateOrUpdate</a></li>
 	<li>ARM Template: <a title="https://docs.microsoft.com/en-us/azure/templates/microsoft.automation/automationaccounts/webhooks" href="https://docs.microsoft.com/en-us/azure/templates/microsoft.automation/automationaccounts/webhooks">https://docs.microsoft.com/en-us/azure/templates/microsoft.automation/automationaccounts/webhooks</a></li>
</ul>
I ended up using the REST API in my solution and managed to create webhooks targeting Hybrid Worker Groups. Based on my experience, the documentation for the webhook Create / Update operation in the REST API is not very clear. As you can see below, The sample request body does not contain some important parameters: the ‘RunOn’ parameter for specifying where the webhook should target and the ‘parameters’ parameter for specifying the input parameters of the runbook:

<a href="https://blog.tyang.org/wp-content/uploads/2017/06/image-3.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/06/image_thumb-3.png" alt="image" width="692" height="586" border="0" /></a>

In this post, I will share the code block I used to create the webhook. For demonstration purposes, I have created a very simple Hello World runbook that takes a single input parameter call "Name":

HelloWorld Runbook:
<pre language="PowerShell">[CmdletBinding()]
PARAM (
[Parameter(Mandatory = $true)][String]$Name
)
Write-output "Hello $Name"
</pre>
Sample code for creating the webhook on Hybrid Worker groups:

https://gist.github.com/tyconsulting/99ac239c4b7522917c89cc80be097f23

<strong>Note:</strong> this sample script uses a function called Get-AADToken, which was discussed in my previous blog post: <a title="https://blog.tyang.org/2017/06/12/powershell-function-to-get-azure-ad-token/" href="https://blog.tyang.org/2017/06/12/powershell-function-to-get-azure-ad-token/">https://blog.tyang.org/2017/06/12/powershell-function-to-get-azure-ad-token/</a>

After I executed this block of code, a webhook is successfully created targeting my hybrid worker group with a validity period of 10 years:

<a href="https://blog.tyang.org/wp-content/uploads/2017/06/image-4.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/06/image_thumb-4.png" alt="image" width="1002" height="299" border="0" /></a>