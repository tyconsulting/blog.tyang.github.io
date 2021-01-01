---
id: 4990
title: 'Azure Automation Runbook: Test-OMSAlertRemediation'
date: 2015-12-15T18:15:30+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=4990
permalink: /2015/12/15/azure-automation-runbook-test-omsalertremediation/
categories:
  - Azure
  - OMS
  - PowerShell
tags:
  - Azure Automation
  - OMS
---
Couple of weeks ago, I published a post titled <a href="http://blog.tyang.org/2015/12/03/oms-alerting-walkthrough/">OMS Alerting Walkthrough</a>. I mentioned in the post that I have written a test runbook called Test-OMSAlertRemediation that extracts information from the OMS alert JSON input sends to you via email.

Once you have created this rnbook in your Azure Automation account, you can use it as the remediation runbook for any OMS alerts.

<strong>Source code:</strong>
<pre language="PowerShell">param ([object]$WebHookData)
#Process inputs from webhook data
Write-Verbose "Processing inputs from webhook data."
$WebhookName    =   $WebhookData.WebhookName
Write-Verbose "Webhook name: '$WebhookName'"
$WebhookHeaders =   $WebhookData.RequestHeader
$WebhookBody    =   $WebhookData.RequestBody
Write-Verbose "Webhook body:"
Write-Verbose $WebhookBody
$SearchResults = (ConvertFrom-JSON $WebhookBody).SearchResults
$SearchResultsId = $SearchResults.id
$SearchResultsValue = $SearchResults.value
$SearchResultsMetaData = $SearchResults.__metadata
#$SearchResult = $Inputs.SearchResult
Write-Verbose "Search Results:"
Write-Verbose $SearchResults
$SMTPConnection = Get-AutomationConnection SMTPNotification
$Subject = "Alert Remediation Runbook Input'"
$Body = @"
Search Results:
Id:
$SearchResultsId

Value:
$($SearchResultsValue | out-String)

Meta Data:
$SearchResultsMetaData
"@
Send-Email `
-Body $Body `
-HTMLBody $false `
-SMTPSettings $SMTPConnection `
-Subject $Subject `
-To your@email.address
</pre>
<strong>Requirements</strong>

This runbooks uses the SendEmail module for sending emails. You can install it to your automation account directly from PowerShell gallery(<a title="https://www.powershellgallery.com/packages/SendEmail/" href="https://www.powershellgallery.com/packages/SendEmail/">https://www.powershellgallery.com/packages/SendEmail/</a>), or download the source code from GitHub(<a title="https://github.com/tyconsulting/SendEmail_PowerShellModule" href="https://github.com/tyconsulting/SendEmail_PowerShellModule">https://github.com/tyconsulting/SendEmail_PowerShellModule</a>). Once the module is deployed to your Automation Account, you will then need to create a connection with type “<strong>SMTPServerConnection</strong>” with the name “<strong>SMTPNotification</strong>”:

<a href="http://blog.tyang.org/wp-content/uploads/2015/12/SNAGHTML2d83c96-2.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML2d83c96" src="http://blog.tyang.org/wp-content/uploads/2015/12/SNAGHTML2d83c96_thumb-1.png" alt="SNAGHTML2d83c96" width="237" height="710" border="0" /></a>

You will also need to place your email address in the last line of the runbook.

The email below is a sample of what this runbook produces:

<a href="http://blog.tyang.org/wp-content/uploads/2015/12/SNAGHTML2e18888.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML2e18888" src="http://blog.tyang.org/wp-content/uploads/2015/12/SNAGHTML2e18888_thumb-1.png" alt="SNAGHTML2e18888" width="448" height="795" border="0" /></a>

Hopefully this runbook would help you when you are designing your OMS alerting solutions.