---
id: 6124
title: Preventing Azure Automation Concurrent Jobs In the Runbook
date: 2017-07-03T13:39:52+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=6124
permalink: /2017/07/03/preventing-azure-automation-concurrent-jobs-in-the-runbook/
categories:
  - Azure
tags:
  - Azure
  - Azure Automation
---
Recently when I was writing an Azure Automation PowerShell runbook, I had an requirement that I need to make sure there should be only one job running at any given time. Since this runbook will be triggered by a webhook from external systems, there was no way for me to control when and how the webhook would be triggered. So I had to add some logic in the runbook that only execute the core code block if there are no other jobs running.

The key for this technique is to use the built-in variable that is available in any Azure Automation jobs called <strong>$PSPrivateMetaData</strong>. This variable contains the Job Id of the current job. Using this job Id, we are able to locate the Azure Automation account and the runbook for this job, and check how many jobs are running for the runbook. If there is only 1 job, then everything is good to go, you can continue on with whatever you need to do in your runbook, but if there are more than 1 jobs are running, then exit straightaway. The only pre-requisite is that you need to provide a way to login to the Azure subscription that’s hosting the Automation account.

Here’s an example, and I’m using the  AzureRunAsConnection (that is created when you create the Automation account):
```powershell
#Get current job Id
$CurrentJobId= $PSPrivateMetadata.JobId.Guid

#Login to Azure
Write-Output -InputObject 'Login to Azure'
try
{
  Add-AzureRmAccount -ServicePrincipal -TenantId $AzureConnection.TenantId -ApplicationId $AzureConnection.ApplicationId -CertificateThumbprint $AzureConnection.CertificateThumbprint
}
catch 
{
  if (!$AzureConnection)
  {
    $ErrorMessage = "Connection $AzureRunAsConnectionName not found."
    throw $ErrorMessage
  }
  else
  {
    Write-Error -Message $_.Exception
    throw $_.Exception
  }
}

#Get Automation account and resource group names
$AutomationAccounts = Find-AzureRmResource -ResourceType Microsoft.Automation/AutomationAccounts
foreach ($item in $AutomationAccounts) 
{
  # Loop through each Automation account to find this job
  $Job = Get-AzureRmAutomationJob -ResourceGroupName $item.ResourceGroupName -AutomationAccountName $item.Name -Id $CurrentJobId -ErrorAction SilentlyContinue
  if ($Job) 
  {
    $AutomationAccountName = $item.Name
    $ResourceGroupName = $item.ResourceGroupName
    $RunbookName = $Job.RunbookName
    break
  }
}
Write-Output "Automation Account Name: '$AutomationAccountName'"
Write-Output "Resource Group Name: '$ResourceGroupName'"
Write-Output "Runbook Name: '$RunbookName'"
#Check if the runbook is already running

$CurrentRunningJobs = Get-AzureRmAutomationJob -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -RunbookName $RunbookName | Where-object {($_.Status -imatch '\w+ing$' -or $_.Status -imatch 'queued') -and $_.JobId.tostring() -ine $CurrentJobId}
If ($CurrentRunningJobs)
{
  Write-output "Active runbook job detected."
  Foreach ($job in $CurrentRunningJobs)
  {
    Write-Output " - JobId: $($job.JobId), Status: '$($job.Status)'."
  }
  Write-output "The runbook job will stop now."
  Exit
} else {
  Write-Output "No concurrent runbook jobs found. OK to continue."
}

```
The sample code shown above does the following:
<ol>
 	<li>Login to Azure using the Run As connection.</li>
 	<li>Get all Automation account within the subscription</li>
 	<li>Loop through each Automation account to find the runbook using the job Id ($PSPrivateMetadata.JobId.Guid)</li>
 	<li>Once the runbook is located, get a list of jobs that the Job Id does not match the current job Id and the status is either ‘queued’ or ends with letters ‘ing’ (i.e. ‘running').</li>
 	<li>If there are jobs detected from the previous step, exit, otherwise, continue on.</li>
</ol>
I used this technique in my previous post <a href="https://blog.tyang.org/2017/02/17/managing-azure-automation-module-assets-using-myget/">Managing Azure Automation Module Assets Using MyGet</a>. In that post, I published a runbook that synchronizes module assets from your MyGet feed. This runbook should only have 1 job running at any given time or it will fail (i.e. trying to update a module that’s been updated).

If you have such a requirement, you can simply add the code block listed above in the beginning of your PowerShell runbook.