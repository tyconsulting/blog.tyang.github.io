---
id: 5957
title: Programmatically Performing OMS Log Search Against a Large Result Set
date: 2017-04-25T00:44:54+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=5957
permalink: /2017/04/25/programmatically-performing-oms-log-search-against-a-large-result-set/
categories:
  - OMS
  - PowerShell
tags:
  - OMS
  - PowerShell
---
When performing OMS log search programmatically, you will encounter an API limitation that will prevent you from getting all the logs from the result set. Currently, if the search does not include an aggregation command, the API call will return maxium 5000 records. This limitation applies to both the OMS PowerShell module ([AzureRM.OperationalInsights](https://docs.microsoft.com/en-us/powershell/module/azurerm.operationalinsights)) and searching directly via the [Log Search API](https://docs.microsoft.com/en-us/azure/log-analytics/log-analytics-log-search-api).

The return response you get from either the Get-AzureRmOperationalInsightsSearchResults cmdlet or the Log Search API, you will get the total number of logs contained in the result set from the response metadata (as shown below), but you will only able to receive up to 5000 records. Natively, there is no way to receive anything over the first 5000 records from a single request.

![](https://blog.tyang.org/wp-content/uploads/2017/04/image.png)

Last month, I was working on a solution where I needed to retrieve all results from search queries, so I reached out to the OMS product group and other CDM MVPs. My buddy and the fellow co-author of the Inside OMS book Stanislav Zhelyazkov provided a work around. Basically, the work around is to use the "skip" command in subsequent request calls until you have retrieved everything. For example, if you want to retrieve all agent heartbeat events using query ```Type=Heartbeat```, you could perform multiple queries until you have retrieved all the log entries as shown below:

```sql
# 1st query
Type=Heartbeat | Top 5000

# 2nd query
Type=Heartbeat | Skip 10000 | Top 5000

# 3rd query
Type=Heartbeat | Skip 15000 | Top 5000
```

I have written a [sample script](https://gist.github.com/tyconsulting/5751fe6a364d989df2fc76138e55bb37) using the OMS PowerShell module to demonstrate how to use the "skip" command in subsequent queries. The sample script is listed below:

```powershell
#requires -Version 3.0 -Modules AzureRM.Profile,AzureRM.OperationalInsights
<#
=======================================================================
AUTHOR:  Tao Yang 
DATE:    24/04/2017
Version: 1.0
Comment:
Demonstrate how to retrieve all OMS query results using "skip" command
=======================================================================
#>
#Login to Azure
Write-Output "Login to Azure"
Add-AzureRMAccount
Set-AzureRmContext -SubscriptionId 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'

Clear-Host
$APIReturnLimit = 5000
$WorkspaceName = 'YOUR-OMS-WORKSPACE-NAME'
$OMSWorkspace = Get-AzureRmOperationalInsightsWorkspace | Where-Object {$_.Name -eq $WorkspaceName }
$OMSWorkspaceName = $OMSWorkspace.Name
$OMSWorkspaceResourceGroup = $OMSWorkspace.ResourceGroupName
$SearchQuery = "Type=Heartbeat"
$Now = [DateTime]::UtcNow
$StartDate = $Now.AddHours(-25)
$EndDate = $Now.AddHours(-11)
$arrResults = New-Object System.Collections.ArrayList

Write-output "Search Query: '$SearchQuery'"
Write-Output "Search Start Date (UTC): $StartDate"
Write-Output "Search End Date (UTC): $EndDate"
Write-Output "Making the first Log Search API call"
$FirstCall = Get-AzureRmOperationalInsightsSearchResults -WorkspaceName $OMSWorkspaceName -ResourceGroupName $OMSWorkspaceResourceGroup -Query $SearchQuery -Start $StartDate -End $EndDate -Top $APIReturnLimit
$ResultsetSize = $FirstCall.Metadata.Total
Write-Output "Return results total size: $ResultsetSize"

# Split and extract request Id
$FirstCallReqIdParts = $FirstCall.Id.Split("/")
$FirstCallReqId = $FirstCallReqIdParts[$FirstCallReqIdParts.Count -1]
Write-Output "Processing results from the first API call."
while($FirstCall.Metadata.Status -eq "Pending") {
  $FirstCall = Get-AzureRmOperationalInsightsSearchResults -WorkspaceName $OMSWorkspaceName -ResourceGroupName $OMSWorkspaceResourceGroup -Id $FirstCallReqId -Top $APIReturnLimit
}

#Processing results returned from the first API call
Foreach ($item in $FirstCall.value)
{
  $objResult = ConvertFrom-JSON $item.tostring()
  $objResult.psobject.Members.Remove('__metadata')
  [void]$arrResults.Add($objResult)
}

Write-Output "Number of results processed so far: $($arrResults.Count)"
If ($ResultsetSize -gt $APIReturnLimit)
{
  Write-output "total result size greater than the Log Search API limit of $APIReturnLimit. making subsequent API calls to retrieve all the rest..."
  $i = 0
  $AllDone = $false
  Do {
    $i++
    $iSkip = $APIReturnLimit * $i
    Write-Output "Making Subsequent call #$i"
    $SubsequentQuery = "$SearchQuery | Skip $iSkip | Top $APIReturnLimit"
    Write-output "Query: '$SubsequentQuery'"
    $SubsequentCall = Get-AzureRmOperationalInsightsSearchResults -WorkspaceName $OMSWorkspaceName -ResourceGroupName $OMSWorkspaceResourceGroup -Query $SubsequentQuery -Start $StartDate -End $EndDate -Top $APIReturnLimit
    # Split and extract request Id
    $SubsequentCallReqIdParts = $SubsequentCall.Id.Split("/")
    $SubsequentCallReqId = $SubsequentCallReqIdParts[$SubsequentCallReqIdParts.Count -1]
    while($SubsequentCall.Metadata.Status -eq "Pending") {
      $SubsequentCall = Get-AzureRmOperationalInsightsSearchResults -WorkspaceName $OMSWorkspaceName -ResourceGroupName $OMSWorkspaceResourceGroup -Id $SubsequentCallReqId -Top $APIReturnLimit
    }

    $SubsequentCallResultsetSize = $SubsequentCall.value.count
    If ($SubsequentCallResultsetSize -gt 0)
    {
      Write-OUtput "Number of results returned from subsequent call #$i`: $SubsequentCallResultsetSize"
      Foreach ($item in $SubsequentCall.value)
      {
        $objResult = ConvertFrom-JSON $item.tostring()
        $objResult.psobject.Members.Remove('__metadata')
        [void]$arrResults.Add($objResult)
      }
    } else {
      Write-Output "Finished making API calls."
      $AllDone = $true
    }
    Write-Output "Number of results processed so far: $($arrResults.Count)"
    Write-Output ""
  } Until ($AllDone)
}
Write-Output "Number of results processed: $($arrResults.Count)."
Write-Output "Here's the first record from the result set:"
$arrResults[0] | Format-List
```

Here’s the script output based on my lab environment:

![](https://blog.tyang.org/wp-content/uploads/2017/04/image-1.png)