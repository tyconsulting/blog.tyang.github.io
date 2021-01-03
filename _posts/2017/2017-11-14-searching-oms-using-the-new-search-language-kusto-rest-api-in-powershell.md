---
id: 6275
title: Searching OMS Using the New Search Language (Kusto) REST API in PowerShell
date: 2017-11-14T22:37:47+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=6275
permalink: /2017/11/14/searching-oms-using-the-new-search-language-kusto-rest-api-in-powershell/
categories:
  - OMS
  - PowerShell
tags:
  - Kusto
  - OMS
  - PowerShell
---
Currently Microsoft <a href="https://blogs.technet.microsoft.com/msoms/2017/10/17/azure-log-analytics-workspace-upgrades-in-progress/">is in the process of upgrading all OMS Log Analytics workspaces to the new query language</a> (named Kusto). Once your workspace has been upgraded, you will no longer able to invoke search queries using the <a href="https://docs.microsoft.com/en-us/powershell/module/azurerm.operationalinsights/get-azurermoperationalinsightssearchresults">Get-AzureRmOperationalInsightsSearchResults</a> cmdlet from the **AzureRM.OperationalInsights** PowerShell module. Kusto comes with a new set of REST APIs, you can find the documentation site here: <a href="https://dev.int.loganalytics.io">https://dev.int.loganalytics.io</a>.

According to the documentation, this REST API has the following <a href="https://dev.int.loganalytics.io/documentation/Using-the-API/Limits">limitations</a>:

 * Queries cannot return more than 500,000 rows
 * Queries cannot return more than 64,000,000 bytes (~61 MiB total data)
 * Quries cannot run longer than 10 minutes by default.

From the documentation site, you can also find a sample PowerShell module which allows you to invoke Kusto search queries via the **ARM** REST API: <a title="https://dev.int.loganalytics.io/documentation/Tools/PowerShell-Cmdlets" href="https://dev.int.loganalytics.io/documentation/Tools/PowerShell-Cmdlets">https://dev.int.loganalytics.io/documentation/Tools/PowerShell-Cmdlets</a>

I have contacted the OMS product group and I have been advised that since the sample PowerShell module offered from the documentation site invokes searches via ARM REST API (as opposed to via the direct Kusto API), the limitation for ARM REST API also applies, which means the query cannot return more than 8MB payload – which is significantly smaller than the direct Kusto API.

Previously with the old language, we also had similar limitations, and I have blogged ways to overcome the throttling limitations using ‘skip’ command. You can find my previous blog post here: <a title="https://blog.tyang.org/2017/04/25/programmatically-performing-oms-log-search-against-a-large-result-set/" href="https://blog.tyang.org/2017/04/25/programmatically-performing-oms-log-search-against-a-large-result-set/">https://blog.tyang.org/2017/04/25/programmatically-performing-oms-log-search-against-a-large-result-set/</a>. However, the new Kusto language does not have a ‘skip’ or equivalent command so it was not possible to use the same method when querying against a large result set. Luckily with the help from the OMS product group, I managed to get it working using the **row_number()** function, and developed a script directly invoking the new Log Analytics search REST API (instead of going through ARM).

Here’s the [PowerShell script](https://gist.github.com/tyconsulting/bf9b0cfc894125777f6bc912a3002a25) I developed, in order to run it, in addition to the AzureRM.Profile and AzureRM.Resources module, you will also need the <a href="https://www.powershellgallery.com/packages/AzureServicePrincipalAccount/">AzureServicePrincipalAccount PowerShell module</a> v1.2.0 or above (developed by myself) :

```powershell
#Requires -Version 5.0
#Requires -Modules AzureRM.Resources, AzureRM.Profile, AzureServicePrincipalAccount
<#
  =================================================================================
  AUTHOR:  Tao Yang 
  DATE:    14/11/2017
  Version: 0.1
  Comment: Export OMS logs from an updated workspace (using Kusto language and API)
  =================================================================================
#>
[CmdletBinding()]
Param (
  [Parameter(Mandatory = $true)][PSCredential]$AzureCredential,

  [Parameter(Mandatory = $true)]
  [ValidateScript({
    try {
      [System.Guid]::Parse($_) | Out-Null
      $true
    } catch {
      $false
    }
  })]
  [String]$TenantId,

  [Parameter(Mandatory = $true)]
    [ValidateScript({
    try {
      [System.Guid]::Parse($_) | Out-Null
      $true
    } catch {
      $false
    }
  })]
  [string]$WorkspaceId,

  [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$SearchQuery,
  [Parameter(Mandatory = $false)][ValidateNotNullOrEmpty()][DateTime]$StartUTCTime,
  [Parameter(Mandatory = $false)][ValidateNotNullOrEmpty()][DateTime]$EndUTCTime,
  [Parameter(Mandatory = $false)][Validaterange(1,600)][int]$Timeout = 180,
  [Parameter(Mandatory = $false)][ValidateScript({Test-Path $_})][string]$OutputDir = $PSScriptRoot,
  [Parameter(Mandatory = $false)][ValidateNotNullOrEmpty()][string]$OutputFileNamePrefix = 'OMSSearchResult',
  [Parameter(Mandatory = $false)][ValidateSet('JSON', 'CSV')][string]$OutputFormat = 'CSV',
  [Parameter(Mandatory = $false)][Validaterange(1000,10000)][int]$MaximumRowPerFile = 5000
)

#region functions
Function ConvertFrom-LogAnalyticsJson
{
    [CmdletBinding()]
    [OutputType([Object])]
    Param (
        [parameter(Mandatory=$true)]
        [string]$JSON
    )

    $data = ConvertFrom-Json $JSON
    $count = 0
    foreach ($table in $data.Tables) {
        $count += $table.Rows.Count
    }

    $objectView = New-Object object[] $count
    $i = 0;
    foreach ($table in $data.Tables) {
        foreach ($row in $table.Rows) {
            # Create a dictionary of properties
            $properties = @{}
            for ($columnNum=0; $columnNum -lt $table.Columns.Count; $columnNum++) {
                $properties[$table.Columns[$columnNum].name] = $row[$columnNum]
            }
            # Then create a PSObject from it. This seems to be *much* faster than using Add-Member
            $objectView[$i] = (New-Object PSObject -Property $properties)
            $null = $i++
        }
    }

    $objectView
}

Function Invoke-OMSKustoSearch
{
  Param (
    [Parameter(Mandatory = $true)][string]$AADToken,

    [Parameter(Mandatory = $true)]
      [ValidateScript({
      try {
        [System.Guid]::Parse($_) | Out-Null
        $true
      } catch {
        $false
      }
    })]
    [string]$WorkspaceId,

    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$SearchQuery,
    [Parameter(Mandatory = $false)][Validaterange(1,600)][int]$Timeout = 180,
    [Parameter(Mandatory = $false)][ValidateNotNullOrEmpty()][string]$ISO8601TimeSpan
  )
  #Constructing queries
  $arrSearchResults = @()
  $RowNumber = 0
  $InitialQuery = "$SearchQuery | sort by TimeGenerated asc | extend rn=row_number()"
  $subsequentQueryTemplate = "$InitialQuery | where rn > {0}"
  $OMSAPIResourceURI = 'https://api.loganalytics.io'
  $OMSAPISearchURI = "$OMSAPIResourceURI/v1/workspaces/$WorkspaceId/query"
  #request header
  $RequestHeader = @{
    'Authorization' = $AADToken
    "Content-Type" = 'application/json'
    'prefer' = "wait=$Timeout, v1-response=true"
  }

  #intial query request
  Write-Verbose "invoking intial search request using query `"$InitialQuery`""
  Write-Verbose "Timespan: '$ISO8601TimeSpan'"

  #Construct REST request body
  $RequestBody = @{
    "query" = $InitialQuery
  }
  If ($PSBoundParameters.ContainsKey('ISO8601TimeSpan'))
  {
    $RequestBody.Add('timespan', $ISO8601TimeSpan)
  }

  $RequestBodyJSON = ConvertTo-Json -InputObject $RequestBody

  #Invoke search REST request
  $SearchRequest = Invoke-WebRequest -UseBasicParsing -Uri $OMSAPISearchURI -Headers $RequestHeader -Body $RequestBodyJSON -Method Post -Verbose
  
  #process result
  Write-Verbose "Parsing Log Analytics Query REST API Results."
  $arrSearchResults += ConvertFrom-LogAnalyticsJson $SearchRequest.Content
  Write-Verbose "Number of rows retrieved so far: $($arrSearchResults.count)"
  #Check if subsequent requests are required
  $objResponse = ConvertFrom-JSON $SearchRequest.Content
  If ($objResponse.error -ne $null)
  {
    Write-Verbose 'Initial query did not complete successful. Potentially hitting the API throttling limits.'
    Write-Verbose " - Error Code: $($objResponse.error.code)"
    Write-Verbose " - Error Message: $($objResponse.error.message)"
    Write-Verbose " - Inner Error code: $($objResponse.error.details.innererror.code)"
    Write-Verbose " - Inner Error Message: $($objResponse.error.details.innererror.message)"
    
    $iRepeat = 0
    If ($objresponse.error.code -ieq 'partialerror')
    {
      $iRepeat ++
      Write-Verbose "Partial Error occurred, subsequent queries required. Repeat count: $iRepeat."
      
      $bQueryCompleted = $false
      Do
      {
        Write-Verbose "Getting the row number for the last row returned from all previous requests."
        $RowNumber = $RowNumber + $arrSearchResults.count
        $subsequentQuery = [string]::Format($subsequentQueryTemplate, $RowNumber)
        Write-Verbose "Performing subsequent query number $iRepeat using query `"$subsequentQuery`""
        $SubsequentRequestBody = @{
          "query" = $subsequentQuery
        }
        If ($PSBoundParameters.ContainsKey('ISO8601TimeSpan'))
        {
          $SubsequentRequestBody.Add('timespan', $ISO8601TimeSpan)
        }

        $SubsequentRequestBodyJSON = ConvertTo-Json -InputObject $SubsequentRequestBody

        #Invoke search REST request
        $SubsequentSearchRequest = Invoke-WebRequest -UseBasicParsing -Uri $OMSAPISearchURI -Headers $RequestHeader -Body $SubsequentRequestBodyJSON -Method Post
  
        #process result
        Write-Verbose "Parsing Log Analytics Query REST API Results."
        $arrSearchResults += ConvertFrom-LogAnalyticsJson $SubsequentSearchRequest.Content
        #Check if subsequent requests are required
        $objSubsequentResponse = ConvertFrom-JSON $SubsequentSearchRequest.content
        if ($objSubsequentResponse.error.code -ine 'partialerror') {$bQueryCompleted = $true}
      } while (!$bQueryCompleted)
      Write-Verbose "Subsequent queries completed successful."
    }
  } else {
    Write-Verbose "Initial search query retrieved the entire result set."
  }

  $arrSearchResults
}

Function Get-QueryTimeSpan
{
  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $false)][ValidateNotNullOrEmpty()][DateTime]$StartUTCTime,
    [Parameter(Mandatory = $false)][ValidateNotNullOrEmpty()][DateTime]$EndUTCTime
  )
  $UTCNow = (get-date).ToUniversalTime()
  If (!$PSBoundParameters.ContainsKey('StartUTCTime'))
  {
    #If start time not specified, use 1 day as it is the default period if searching from OMS portal
    $StartUTCTime = $UTCNow.AddDays(-1)
    Write-Verbose "Start UTC Time noe specified. using the default value which is 1 day ago: '$StartUTCTime'"
  }
  If (!$PSBoundParameters.ContainsKey('EndUTCTime'))
  {
    #If end time not specified, use the current UTC time
    $EndUTCTime = $UTCNow
    Write-Verbose "Start UTC Time noe specified. using the current date time: '$EndUTCTime'"
  }

  $StartYear = $StartUTCTime.Year
  $StartMonth = '{0:D2}' -f $StartUTCTime.Month
  $StartDay  = '{0:D2}' -f $StartUTCTime.Day
  $StartHour  = '{0:D2}' -f $StartUTCTime.Hour
  $StartMinute = '{0:D2}' -f $StartUTCTime.Minute
  $StartSecond = '{0:D2}' -f $StartUTCTime.Second

  $EndYear = $EndUTCTime.Year
  $EndMonth = '{0:D2}' -f $EndUTCTime.Month
  $EndDay  = '{0:D2}' -f $EndUTCTime.Day
  $EndHour  = '{0:D2}' -f $EndUTCTime.Hour
  $EndMinute = '{0:D2}' -f $EndUTCTime.Minute
  $EndSecond = '{0:D2}' -f $EndUTCTime.Second

  $ISO8601TimeSpanTemplate = "{0}-{1}-{2}T{3}:{4}:{5}Z/{6}-{7}-{8}T{9}:{10}:{11}Z"
  $ISO8601TimeSpan = [System.String]::Format($ISO8601TimeSpanTemplate, $StartYear, $StartMonth, $StartDay, $StartHour, $StartMinute, $StartSecond, $EndYear, $EndMonth, $EndDay, $EndHour, $EndMinute, $EndSecond)
  $ISO8601TimeSpan
}

Function Export-ResultToFile
{
  [CmdletBinding()]
  Param (
    
    [Parameter(Mandatory = $true)][psobject[]]$Logs,
    [Parameter(Mandatory = $true)][ValidateScript({Test-Path $_})][string]$OutputDir,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$FileName,
    [Parameter(Mandatory = $true)][ValidateSet('JSON', 'CSV')][string]$OutputFormat
  )

  $OutputFilePath = Join-Path $OutputDir $FileName
  Write-Verbose "Exporting to '$OutputFilePath'..."
  Switch ($OutputFormat)
  {
    'CSV' {$Logs | Export-CSV -LiteralPath $OutputFilePath -NoTypeInformation -Force}
    'JSON' {ConvertTo-JSON -InputObject $Logs | Out-File $OutputFilePath -Force}
  }
  $OutputFilePath
}
#endregion

#region variables
$OMSAPIResourceURI = 'https://api.loganalytics.io'

#endregion

#region main
#Get AAD Token
Write-Verbose "Requesting Azure AD oAuth token"
$AADToken = AzureServicePrincipalAccount\Get-AzureADToken -TenantID $TenantId -Credential $AzureCredential -ResourceURI $OMSAPIResourceURI

#Work out the search time span
$TimeSpanParam = @{}
If ($PSBoundParameters.ContainsKey('StartUTCTime'))
{
  $TimeSpanParam.Add('StartUTCTime', $StartUTCTime)
}
If ($PSBoundParameters.ContainsKey('EndUTCTime'))
{
  $TimeSpanParam.Add('EndUTCTime', $EndUTCTime)
}

$ISO8601TimeSpan = Get-QueryTimeSpan @TimeSpanParam
Write-Output "Log Analytics search request ISO 8601 time span: '$ISO8601TimeSpan'."

#Invoke search API
Write-Verbose "Invoking search request. Search query: `"$SearchQuery`"... This could take a while"
$SearchResult = Invoke-OMSKustoSearch -AADToken $AADToken -WorkspaceId $WorkspaceId -SearchQuery $SearchQuery -ISO8601TimeSpan $ISO8601TimeSpan  -Timeout $Timeout
Write-Output "Total number of rows returned: $($SearchResult.count)"
#Export logs to files
$bAllExported = $false
$iExportCount = 0
$totalExported = 0
$arrExportFiles = @()
Do {
  
  $ExportSet = $searchresult | Select-Object -First $MaximumRowPerFile -Skip ($MaximumRowPerFile * $iExportCount) 
  $iExportCount ++

  #Export Log
  $FileName = "$OutputFileNamePrefix-$($ISO8601TimeSpan.replace(':', '.').split('Z/')[0])`-$iExportCount`.$OutputFormat" 
  
  Write-output "Exporting Batch No. $iExportCount with $($ExportSet.count) rows to '$FileName'"
  $arrExportFiles += Export-ResultToFile -Logs $ExportSet -OutputDir $OutputDir -FileName $FileName -OutputFormat $OutputFormat -Verbose

  $totalExported = $totalExported + $ExportSet.Count
  If ($totalExported -eq $SearchResult.Count)
  {
    $bAllExported = $true
  }
} While (!$bAllExported)
Write-output '', "All logs are exported to '$OutputDir'."


Write-Output "Total files created: $($arrExportFiles.Count)"
Write-output "Done!"
#endregion
```

This script searches your workspace using Kusto API and exports results to one or more files. you will need to specify the following parameters:

 * **-AzureCredential**: a PSCredential object for an Azure AD account that has access to your workspace
 * **-TenantId**: the GUID for your AAD Tenant ID
 * **-WorkspaceId**: the GUID for your Log Analytics workspace ID
 * **-SearchQuery**: the Kusto search query you wish to perform
 * **-StartUTCTime**: the start (earliest) time in UTC for the search operation. Optional, if not specified, the default value is 1 day ago
 * **-EndUTCTime**: the end(latest) time in UTC for the search operation. Optional, if not specified, the default value is now
 * **-Timeout**: the HTTP Rest time out for the Log Analytics REST API. optional, default value is 180 (seconds)
 * **-OutputDir**: the directory where you want the search results to be saved. optional, default value is the script root folder.
 * **-OutputFileNamePrefix**: the prefix for the output file name. Optional, default value is ‘OMSSearchResult’
 * **-OutputFormat**: the format for the output files. you can choose between CSV and JSON. this parameter is optional, default is CSV
 * **-MaximumRowPerFile**: the maximum number of rows for each output file. optional, default is 5000

I’ve added many verbose messages in the script. so if you run it with –**Verbose** switch, you’ll see more details while the script is running:

<a href="https://blog.tyang.org/wp-content/uploads/2017/11/image.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/11/image_thumb.png" alt="image" width="1002" height="553" border="0" /></a>

>**Note:** If you perform search within a large time window, the script will take a long time to run depending on number of rows returned from the search result.

Lastly, please feel free to contact me if you have issues or suggestions.