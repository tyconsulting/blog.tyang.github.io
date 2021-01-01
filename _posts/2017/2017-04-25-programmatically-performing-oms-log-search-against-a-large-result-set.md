---
id: 5957
title: Programmatically Performing OMS Log Search Against a Large Result Set
date: 2017-04-25T00:44:54+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=5957
permalink: /2017/04/25/programmatically-performing-oms-log-search-against-a-large-result-set/
categories:
  - OMS
  - PowerShell
tags:
  - OMS
  - Powershell
---
<span style="font-size: small;"><a href="http://blog.tyang.org/wp-content/uploads/2017/04/Operations-Management-Suite-OMS.png"><img class="alignleft wp-image-5960 size-thumbnail" src="http://blog.tyang.org/wp-content/uploads/2017/04/Operations-Management-Suite-OMS-150x150.png" alt="" width="150" height="150" /></a>When performing OMS log search programmatically, you will encounter an API limitation that will prevent you from getting all the logs from the result set. Currently, if the search does not include an aggregation command, the API call will return maxium 5000 records. This limitation applies to both the OMS PowerShell module (</span><a href="https://docs.microsoft.com/en-us/powershell/module/azurerm.operationalinsights"><span style="font-size: small;">AzureRM.OperationalInsights</span></a><span style="font-size: small;">) and searching directly via the </span><a href="https://docs.microsoft.com/en-us/azure/log-analytics/log-analytics-log-search-api"><span style="font-size: small;">Log Search API</span></a><span style="font-size: small;">.</span>

<span style="font-size: small;">The return response you get from either the Get-AzureRmOperationalInsightsSearchResults cmdlet or the Log Search API, you will get the total number of logs contained in the result set from the response metadata (as shown below), but you will only able to receive up to 5000 records. Natively, there is no way to receive anything over the first 5000 records from a single request.</span>

<a href="http://blog.tyang.org/wp-content/uploads/2017/04/image.png"><span style="font-size: small;"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2017/04/image_thumb.png" alt="image" width="603" height="229" border="0" /></span></a>

<span style="font-size: small;">Last month, I was working on a solution where I needed to retrieve all results from search queries, so I reached out to the OMS product group and other CDM MVPs. My buddy and the fellow co-author of the Inside OMS book Stanislav Zhelyazkov provided a work around. Basically, the work around is to use the "skip" command in subsequent request calls until you have retrieved everything. For example, if you want to retrieve all agent heartbeat events using query "Type=Heartbeat", you could perform multiple queries until you have retrieved all the log entries as shown below:</span>
<ol>
 	<li><span style="font-size: small;">1</span><sup><span style="font-size: small;">st</span></sup><span style="font-size: small;"> Query: "Type=Heartbeat | Top 5000"</span></li>
 	<li><span style="font-size: small;">2</span><sup><span style="font-size: small;">nd</span></sup><span style="font-size: small;"> Query: "Type=Heartbeat | Skip 10000 | Top 5000"</span></li>
 	<li><span style="font-size: small;">3</span><sup><span style="font-size: small;">rd</span></sup><span style="font-size: small;"> Query: "Type=Heartbeat | Skip 15000 | Top 5000"</span></li>
 	<li><span style="font-size: small;">… repeat until the search API call returns no results</span></li>
</ol>
I have written a sample script using the OMS PowerShell module to demonstrate how to use the "skip" command in subsequent queries. The sample script is listed below:
https://gist.github.com/tyconsulting/5751fe6a364d989df2fc76138e55bb37

Here’s the script output based on my lab environment:

<a href="http://blog.tyang.org/wp-content/uploads/2017/04/image-1.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2017/04/image_thumb-1.png" alt="image" width="607" height="517" border="0" /></a>