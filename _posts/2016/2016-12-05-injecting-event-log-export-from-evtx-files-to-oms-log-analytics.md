---
id: 5793
title: Injecting Event Log Export from .evtx Files to OMS Log Analytics
date: 2016-12-05T19:51:30+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=5793
permalink: /2016/12/05/injecting-event-log-export-from-evtx-files-to-oms-log-analytics/
categories:
  - Uncategorized
tags:
  - Azure Automation
  - OMS
  - PowerShell
---
Over the last few days, I had an requirement injecting events from .evtx files into OMS Log Analytics. A typical .evtx file that I need to process contains over 140,000 events. Since the Azure Automation runbook have the maximum execution time of 3 hours, in order to make the runbook more efficient, I also had to update my OMSDataInjection PowerShell module to support bulk insert (<a title="https://blog.tyang.org/2016/12/05/omsdatainjection-powershell-module-updated/" href="https://blog.tyang.org/2016/12/05/omsdatainjection-powershell-module-updated/">https://blog.tyang.org/2016/12/05/omsdatainjection-powershell-module-updated/</a>).

I have publish the runbook on [GitHub Gist](https://gist.github.com/tyconsulting/72a19595246938ae0fb435a42afa4185):

```powershell
#requires -Version 2.0 -Modules OMSDataInjection

<#
    ========================================================================
    AUTHOR:  Tao Yang 
    DATE:    02/11/2016
    Version: 1.0
    Comment:
    Azure Automation Runbook that reads Windows Event export (evt) files
    and inject events to OMS Log Analytics.
    ========================================================================
#>
PARAM (
  [Parameter(Mandatory = $true)][ValidateScript({
        Test-Path $_
  })][String]$EvtExportPath,
  [Parameter(Mandatory = $true)][Alias('OMSConnection')][String]$OMSConnectionName,
  [Parameter(Mandatory = $true)][String]$OMSLogTypeName,
  [Parameter(Mandatory = $false)][Int]$BatchLimit = 1000,
  [Parameter(Mandatory = $false)][String]$OMSTimeStampFieldName = 'TimeCreated'
  
)

#Define the excluded fields
$arrSkippedProperties = New-Object -TypeName System.Collections.ArrayList
[Void]$arrSkippedProperties.Add('ContainerLog')
[Void]$arrSkippedProperties.Add('Bookmark')
[Void]$arrSkippedProperties.Add('Properties')
[Void]$arrSkippedProperties.Add('KeywordsDisplayNames')
[Void]$arrSkippedProperties.Add('Keywords')
[Void]$arrSkippedProperties.Add('RecordId')

#Get OMS connection
$OMSConnection = Get-AutomationConnection -Name $OMSConnectionName
#Process Evt file
Write-Output -Message "Processing Event Export file $EvtExportPath"
Write-Output "OMS Log Type: '$OMSLogTypeName'"
Write-Output "OMS Log Timestamp field: '$OMSTimeStampFieldName'"
Write-Output "Batch injection limit: $BatchLimit"

$LogQuery = [System.Diagnostics.Eventing.Reader.EventLogQuery]::new($EvtExportPath,[System.Diagnostics.Eventing.Reader.PathType]::FilePath)
$LogReader = New-Object -TypeName System.Diagnostics.Eventing.Reader.EventLogReader -ArgumentList ($LogQuery)
$arrEvents = @()
$i = 0
$BatchCount = 1 #the count of number of batches
$BatchSize = 0 #the number of events in the batch
For ($Event = $LogReader.ReadEvent(); $null -ne $Event; $Event = $LogReader.ReadEvent())
{
  $i++
  If ($BatchSize -le $BatchLimit)
  {
    #Write-Output -InputObject "Reading event number $i (Batch Number #$BatchCount)"
    $properties = @{}
    Foreach ($item in (Get-Member -InputObject $Event -MemberType Properties))
    {
      $PropertyName = $item.Name
      If (!$arrSkippedProperties.Contains($PropertyName))
      {
        $properties.Add($PropertyName, $Event.$PropertyName)
      }
    }
    #Add Event description
    $EventDescription = $Event.FormatDescription()
    If ($EventDescription.Length -eq 0)
    {
      #If formatted description is missing, then use the raw XML
      $EventDescription = $Event.ToXML()
    }
    $properties.Add('Description', $EventDescription)
    $objEvtExtract = New-Object -TypeName psobject -Property $properties
    $arrEvents += $objEvtExtract
    $BatchSize ++
  }
  if ($BatchSize -eq $BatchLimit)
  {
    #Submit to OMS
    Write-Output -InputObject "Injecting $($arrEvents.count) records to OMS"
    $OMSInjectResult = New-OMSDataInjection -OMSConnection $OMSConnection -LogType $OMSLogTypeName -UTCTimeStampField $OMSTimeStampFieldName -OMSDataObject $arrEvents -Verbose
    If ($OMSInjectResult -eq $true)
    {
      Write-Output "OMS log injection successful."
    } else {
      Write-Error "OMS log injection failed."
    }
    #clear array and reset batch count
    $arrEvents = @()
    $BatchCount ++
    $BatchSize = 0
  }
  
}
Write-Output -InputObject "Done. Total number of log injected: $i"
```

>**Note:** In order to use this runbook, you MUST use the latest OMSDataInjection module (version 1.1.1) because of the bulk insert.

You will need to specify the following parameters:

* EvtExportPath - the file path (i.e. a SMB share) to the evtx file.
* OMSConnectionName – the name of the OMSWorkspace connection asset you have created previously. this connection is defined in the OMSDataInjection module
* OMSLogTypeName – The OMS log type name that you wish to use for the injected events.
* BatchLimit – the number of events been injected in a single bulk request. This is an optional parameter, the default value is 1000 if it is not specified.
* OMSTimeStampFieldName – For the OMS HTTP Data Collector API, you will need to tell the API which field in your log represent the timestamp. since all events extracted from .evtx files all have a "TimeCreated" field, the default value for this parameter is ‘TimeCreated’.

You can further customise the runbook and choose which fields from the evtx events that you wish to exclude. For the fields that you wish to exclude, you need to add them to the $arrSkippedProperties array variable (line 25 – 31). I have already pre-populated it with few obvious ones, you can add and remove them to suit your requirements.

Lastly, sometimes you will get events that their formatted description cannot be displayed. i.e.

<a href="https://blog.tyang.org/wp-content/uploads/2016/12/image-11.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/12/image_thumb-11.png" alt="image" width="416" height="148" border="0" /></a>

When the runbook cannot get the formatted description of event, it will use the XML content as the event description instead.

Sample event injected by this runbook:

<a href="https://blog.tyang.org/wp-content/uploads/2016/12/image-12.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/12/image_thumb-12.png" alt="image" width="706" height="299" border="0" /></a>