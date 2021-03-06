---
id: 7113
title: Azure Automation Runbook to Export Data From Multiple Log Analytics Workspaces
date: 2019-06-30T02:42:32+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=7113
permalink: /2019/06/30/azure-automation-runbook-to-export-data-from-multiple-log-analytics-workspaces/
categories:
  - Azure
tags:
  - Azure
  - Azure Automation
  - Log Analytics
  - PowerShell
---
I wrote a runbook a while back to export data from Azure Log Analytics workspaces using it’s search API <a href="https://dev.loganalytics.io/documentation/Using-the-API">https://dev.loganalytics.io/documentation/Using-the-API</a> because a customer had a requirement to ingest the logs and metrics from Azure Log Analytics to other 3rd party systems.
Recently, I updated this runbook to support searching all workspaces from all subscriptions in one or more management groups. For example, you can use this runbook to extract data from all log analytics workspaces in your AAD tenant if you pass in the root management group name to the runbook.

You can find the runbook source code here:

{%gist 81cd2b80d8b151e38d5b52b80b4c6ee3 %}

## Requirements

1. The following PowerShell modules must be installed in the Azure Automation account and any Hybrid Worker servers if running on Hybrid Workers (all available at PowerShell Gallery):
  * az.accounts
  * az.resources
  * AzureServicePrincipalAccount (minimum version 2.0.0)
2. An Azure AD application and service principal. the service principal must have a key based secret (not certificate). Assign the service principal contributor role to the Log Analytics workspace you wish to invoke the search query, or at the management group level if you wish to search multiple workspaces.
3. Once the PowerShell modules are installed in the Automation account, create a "Key Based AzureServicePrincipal" connection object using the service principal created in the previous step:

![](https://blog.tyang.org/wp-content/uploads/2019/06/image-5.png)

## Executing the runbook

The runbook is designed to run on a schedule, for several times per hour. In Azure Automation, since the most frequent schedule you can create is hourly, in my environments, I have created 4 hourly schedules, running on the 00, 15, 30 and 45 minute each hour. The runbook use several input parameters to determine the time window for the search query.
When scheduling the runbook, you will need to specify the following input parameters:

* **AzureConnectionName** – the name of the key based service principal connection you created earlier
* **WorkspaceId** – the workspace Id of the log analytics workspace. The search API requires you to provide a workspace Id even when you are targeting your search to multiple workspaces.
* **managementGroupName** – optional, specify one or more management group names to search Log Analytics workspaces from. You need to specify the names in square brackets. i.e. <span style="background-color: #ffff00">["mg-name"]</span>, or <span style="background-color: #ffff00">["mg-name-1", "mg-name-2"]</span>
* **SearchQuery** – the Kusto search query you wish to invoke
* **LogFriendlyName** – a friendly name for the log returned from the search. this will be part of the output file names.
* **IntervalMinute** – how often the runbook runs. valid inputs: 5,10,15,20,30,60
* **HourlySequenceNo** – the number of job executions within the current full hour. i.e. if you are scheduling the runbook to run every 10 minutes, this should be between 1 and 6
* **IndexingMinuteOffset** – optional, default value is 10. logs only become searchable after indexed, this parameter is used to calculate the start time of the search time span. Generally, logs are indexed under 10 minutes.
* **Timeout** – optional, default value 180 (seconds). This is the log search REST API timeout setting
* **OutputDir** – the place you where you store the search results. use an UNC path instead of local path.
* **OutputFormat** – optional, default is ‘JSON’. you can choose ‘JSON’ or ‘CSV’. I recommend you to use JSON because CSV has a flat structure. Use JSON to ensure data integrity because you don’t have to flatten the log entries.
* **Encoding** – optional, default value set to "ASCII". This is the encoding for the output file. possible values are: 'Unknown', 'String', 'Unicode', 'BigEndianUnicode', 'UTF8', 'UTF7', 'UTF32', 'ASCII', 'Default', 'OEM'
* **MaximumRowPerFile** – optional, default value is 5000. Use this parameter to define maximum log entries stored in a file (to keep output files in reasonable sizes). The value must be between 1,000 and 10,000
* **Zip** – optional, Boolean value. default is $false. Use this parameter if you wish to zip output files (to keep the sizes down).

## Example

### Input parameters

![](https://blog.tyang.org/wp-content/uploads/2019/06/image-6.png)

### Job output

![](https://blog.tyang.org/wp-content/uploads/2019/06/image-7.png)

### Output file

![](https://blog.tyang.org/wp-content/uploads/2019/06/image-8.png)

## Credit

In this script, I've borrowed some code from Matthew Dowst's KQLParser module ([https://www.powershellgallery.com/packages/KQLParser/0.0.0.2](https://www.powershellgallery.com/packages/KQLParser/0.0.0.2)) to parse the Kusto search results.