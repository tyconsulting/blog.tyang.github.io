---
id: 1779
title: '&ldquo;Data Aggregation&rdquo; field became empty in OpsMgr 2007 linked Performance Report'
date: 2013-03-13T22:15:10+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=1779
permalink: /2013/03/13/data-aggregation-field-became-empty-in-opsmgr-2007-linked-performance-report/
categories:
  - SCOM
tags:
  - SCOM
  - SCOM Reporting
---
Today I needed to change some parameters in a linked performance report in one of the OpsMgr 2007 R2 management groups at work. When I opened the report property, the Data Aggregation field somehow became blank and greyed out:

<a href="http://blog.tyang.org/wp-content/uploads/2013/03/image9.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/03/image_thumb8.png" width="378" height="308" border="0" /></a>

As the result, when I tried to run the report, I get this error:

<a href="http://blog.tyang.org/wp-content/uploads/2013/03/image10.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/03/image_thumb9.png" width="488" height="173" border="0" /></a>

I found a blog article from Dieter Wijckmans "<a href="http://scug.be/dieter/2011/05/16/scom-2007-scheduled-reports-failing/">SCOM 2007: Scheduled reports failing</a>", it indicates it’s because there are duplicate management group ID specified in the report parameters. Dieter’s fix doesn’t really apply to me as the my report is not a scheduled report, however, my approach is much easier.

below is what I’ve done:

1. log on to the RMS box, and run below PowerShell script to get the management group ID:

```powershell
$RMS = $env:computername
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.EnterpriseManagement.OperationsManager.Common") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.EnterpriseManagement.OperationsManager") | Out-Null

$MGConnSetting = New-Object Microsoft.EnterpriseManagement.ManagementGroupConnectionSettings($RMS)
$MG = New-Object Microsoft.EnterpriseManagement.ManagementGroup($MGConnSetting)
$MG.Id
```

<a href="http://blog.tyang.org/wp-content/uploads/2013/03/image11.png"><img style="background-image: none; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/03/image_thumb10.png" width="442" height="223" border="0" /></a>

<span style="color: #ff0000;">Note:</span>

If RMS is clustered, replace "<em><strong>$env:computername</strong></em>" to the RMS cluster name in the first line.

{:start="2"}
2. export the management pack (assuming the linked report is stored in a unsealed MP), open the unsealed MP in a text editor

3. Go to

```xml
<Reporting>
  <LinkedReports>
    <LinkedReport ID= (where ID is the Id of the problematic report)>
      <Parameters>
```

Find the ManagementGroupId parameter and delete the incorrect value

<a href="http://blog.tyang.org/wp-content/uploads/2013/03/image12.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/03/image_thumb11.png" width="578" height="272" border="0" /></a>

{:start="4"}
4. Save the XML and import the unsealed MP back to the management group.

After importing the MP back, the "Data Aggregation" field is populated:

<a href="http://blog.tyang.org/wp-content/uploads/2013/03/image13.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/03/image_thumb12.png" width="518" height="317" border="0" /></a>

<strong><span style="color: #ff0000;">Note:</span></strong>

I can also change the report parameter in SSRS web site:

<a href="http://blog.tyang.org/wp-content/uploads/2013/03/image14.png"><img style="background-image: none; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/03/image_thumb13.png" width="377" height="176" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2013/03/image15.png"><img style="background-image: none; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/03/image_thumb14.png" width="580" height="311" border="0" /></a>

However, by directly modifying report in SSRS, the fix is only temporary. the original MP is not fixed and it will over write the report definition in SSRS. I’ve tried to update SSRS directly, the report got changed back shortly after.