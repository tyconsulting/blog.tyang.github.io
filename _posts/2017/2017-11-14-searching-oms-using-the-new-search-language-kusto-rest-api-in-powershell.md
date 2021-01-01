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
Currently Microsoft <a href="https://blogs.technet.microsoft.com/msoms/2017/10/17/azure-log-analytics-workspace-upgrades-in-progress/">is in the process of upgrading all OMS Log Analytics workspaces to the new query language</a> (named Kusto). Once your workspace has been upgraded, you will no longer able to invoke search queries using the <a href="https://docs.microsoft.com/en-us/powershell/module/azurerm.operationalinsights/get-azurermoperationalinsightssearchresults">Get-AzureRmOperationalInsightsSearchResults</a> cmdlet from the <strong>AzureRM.OperationalInsights</strong> PowerShell module. Kusto comes with a new set of REST APIs, you can find the documentation site here: <a href="https://dev.int.loganalytics.io">https://dev.int.loganalytics.io</a>.

According to the documentation, this REST API has the following <a href="https://dev.int.loganalytics.io/documentation/Using-the-API/Limits">limitations</a>:
<ul>
 	<li>Queries cannot return more than 500,000 rows</li>
 	<li>Queries cannot return more than 64,000,000 bytes (~61 MiB total data)</li>
 	<li>Quries cannot run longer than 10 minutes by default.</li>
</ul>
From the documentation site, you can also find a sample PowerShell module which allows you to invoke Kusto search queries via the <strong>ARM</strong> REST API: <a title="https://dev.int.loganalytics.io/documentation/Tools/PowerShell-Cmdlets" href="https://dev.int.loganalytics.io/documentation/Tools/PowerShell-Cmdlets">https://dev.int.loganalytics.io/documentation/Tools/PowerShell-Cmdlets</a>

I have contacted the OMS product group and I have been advised that since the sample PowerShell module offered from the documentation site invokes searches via ARM REST API (as opposed to via the direct Kusto API), the limitation for ARM REST API also applies, which means the query cannot return more than 8MB payload – which is significantly smaller than the direct Kusto API.

Previously with the old language, we also had similar limitations, and I have blogged ways to overcome the throttling limitations using ‘skip’ command. You can find my previous blog post here: <a title="https://blog.tyang.org/2017/04/25/programmatically-performing-oms-log-search-against-a-large-result-set/" href="https://blog.tyang.org/2017/04/25/programmatically-performing-oms-log-search-against-a-large-result-set/">https://blog.tyang.org/2017/04/25/programmatically-performing-oms-log-search-against-a-large-result-set/</a>. However, the new Kusto language does not have a ‘skip’ or equivalent command so it was not possible to use the same method when querying against a large result set. Luckily with the help from the OMS product group, I managed to get it working using the <strong>row_number()</strong> function, and developed a script directly invoking the new Log Analytics search REST API (instead of going through ARM).

Here’s the PowerShell script I developed, in order to run it, in addition to the AzureRM.Profile and AzureRM.Resources module, you will also need the <a href="https://www.powershellgallery.com/packages/AzureServicePrincipalAccount/">AzureServicePrincipalAccount PowerShell module</a> v1.2.0 or above (developed by myself) :

https://gist.github.com/tyconsulting/bf9b0cfc894125777f6bc912a3002a25

This script searches your workspace using Kusto API and exports results to one or more files. you will need to specify the following parameters:
<ul>
 	<li><strong>-AzureCredential</strong>: a PSCredential object for an Azure AD account that has access to your workspace</li>
 	<li><strong>-TenantId</strong>: the GUID for your AAD Tenant ID</li>
 	<li><strong>-WorkspaceId</strong>: the GUID for your Log Analytics workspace ID</li>
 	<li><strong>-SearchQuery</strong>: the Kusto search query you wish to perform</li>
 	<li><strong>-StartUTCTime</strong>: the start (earliest) time in UTC for the search operation. Optional, if not specified, the default value is 1 day ago</li>
 	<li><strong>-EndUTCTime</strong>: the end(latest) time in UTC for the search operation. Optional, if not specified, the default value is now</li>
 	<li><strong>-Timeout</strong>: the HTTP Rest time out for the Log Analytics REST API. optional, default value is 180 (seconds)</li>
 	<li><strong>-OutputDir</strong>: the directory where you want the search results to be saved. optional, default value is the script root folder.</li>
 	<li><strong>-OutputFileNamePrefix</strong>: the prefix for the output file name. Optional, default value is ‘OMSSearchResult’</li>
 	<li><strong>-OutputFormat</strong>: the format for the output files. you can choose between CSV and JSON. this parameter is optional, default is CSV</li>
 	<li><strong>-MaximumRowPerFile</strong>: the maximum number of rows for each output file. optional, default is 5000</li>
</ul>
I’ve added many verbose messages in the script. so if you run it with –<strong>Verbose</strong> switch, you’ll see more details while the script is running:

<a href="https://blog.tyang.org/wp-content/uploads/2017/11/image.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/11/image_thumb.png" alt="image" width="1002" height="553" border="0" /></a>

<strong><span style="background-color: #ffff00;">Note:</span></strong> If you perform search within a large time window, the script will take a long time to run depending on number of rows returned from the search result.

Lastly, please feel free to contact me if you have issues or suggestions.