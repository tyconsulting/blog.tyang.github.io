---
id: 5610
title: PowerShell Module for OMS HTTP Data Collector API
date: 2016-08-31T23:45:18+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=5610
permalink: /2016/08/31/powershell-module-for-oms-http-data-collector-api/
categories:
  - OMS
  - PowerShell
tags:
  - OMS
  - PowerShell
---

## Background

Earlier today, the OMS Product Group has released the OMS HTTP Data Collection API to public preview. If you haven’t read the announcement, you can read <a href="https://blogs.technet.microsoft.com/msoms/2016/08/30/http-data-collector-api-send-us-data-from-space-or-anywhere/">this blog post</a> written by the PM of this feature, Evan Hissey first.

As a Cloud and Datacenter Management MVP, I’ve had private preview access to this feature for few months now, and I actually even developed a solution using this API in a customer engagement with my friend and fellow CDM MVP Alex Verkinderen (<a href="https://twitter.com/AlexVerkinderen">@AlexVerkinderen</a>) just over a month ago. I was really impressed with the potential opportunities this feature may bring to us, I’ve been spamming Evan’s inbox asking him for the release date of this feature so I can blog about it and also present this in user group meetups.

Since most of us wouldn’t like having to deal with HTTP headers, bodies, authorizations and other overhead we have to put into our code in order to use this API, I have developed a PowerShell module to help us easily utilize this API.

## Introducing OMSDataInjection PowerShell Module

This module was developed about 2 months ago, I was waiting for the API to become public so I can release this module. So now the wait is over, I can finally release it.

This module contains only one public function: **New-OMSDataInjection**. This function is well documented in a proper help file. you can access it via **Get-Help New-OMSDataInjection –Full**. I have added 2 examples in the help file too:

**EXAMPLE 1:**

```powershell
PS C:\>$PrimaryKey = Read-Host -Prompt 'Enter the primary key'
 $ObjProperties = @{
 Computer = $env:COMPUTERNAME
 Username = $env:USERNAME
 Message  = 'This is a test message injected by the OMSDataInjection module. Input data type: PSObject'
 LogTime  = [Datetime]::UtcNow
 }
 $OMSDataObject = New-Object -TypeName PSObject -Property $ObjProperties
 $InjectData = New-OMSDataInjection -OMSWorkSpaceId '8eb61d08-133c-401a-a45b-0e611194779f' -PrimaryKey $PrimaryKey -LogType 'OMSTestData' -UTCTimeStampField 'LogTime' -OMSDataObject $OMSDataObject

Injecting data using a PS object by specifying the OMS workspace Id and primary key
```

**EXAMPLE 2:**

```powershell
PS C:\>$OMSConnection = Get-AutomationConnection 'OMSConnection'
$OMSDataJSON = @"
{
"Username":  "administrator",
"Message":  "This is a test message injected by the OMSDataInjection module. Input data type: JSON",
"LogTime":  "Tuesday, 28 June 2016 9:08:15 PM",
"Computer":  "SERVER01"
}
"@
$InjectData = New-OMSDataInjection -OMSConnection $OMSConnection -LogType 'OMSTestData' -UTCTimeStampField 'LogTime' -OMSDataJSON $OMSDataJSON
```

Injecting data using JSON formatted string by specifying the OMSWorkspace Azure Automation / SMA connection object (to be used in a runbook)

This PS module comes with the following features:

**01. A Connection object for using this module in Azure Automation and SMA.**

Once imported into your Azure Automation account (or SMA for the ‘old skool’ folks), you will be able to create connection objects that contains your OMS workspace Id, primary key and secondary key (optional):

<a href="https://blog.tyang.org/wp-content/uploads/2016/08/image-53.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/08/image_thumb-53.png" alt="image" width="215" height="326" border="0" /></a>

And as shown in Example 2 listed above, in your runbook, you can retrieve this connection object and use it when calling the New-OMSDataInjection function.

**02. Fall back to the secondary key if the primary key has failed**

When the optional secondary key is specified, if the web request using the primary key fails, the module will fall back to the secondary key and try the web request again using the secondary key. This is to ensure your script / automation runbooks will not be interrupted when you are in the process of  following the best practice and cycling through your keys.

**03. Supports two types of input: JSON and PSObject**

As you can see from Evan’s post, this API is expecting a JSON object as the HTTP body which contains the data to be injected into OMS. When I started testing this API few months ago, my good friend and fellow MVP Stanislav Zhelyazkov (<a href="https://twitter.com/StanZhelyazkov">@StanZhelyazkov</a>) suggested me instead of writing plain JSON format, it’s better to put everything into a PSObject then convert it to JSON in PowerShell so we don’t mess with the format and type of each field. I think it was a good idea, so I have coded the module to take either JSON format, or a PSObject that contains the data to be injected into OMS.

## Sample Script  and Runbook

I’ve created a sample script and a runbook to help you get started. They are also included in the Github repository for this module (link at the bottom of this article):

**Sample Script: Test-OMSDataInjection.ps1**

```powershell
#requires -Version 3 -Modules OMSDataInjection
$LogName = 'OMSTestData'
$UTCTimeStampField = 'LogTime'
$Now = [Datetime]::UtcNow
$ISONow = "{0:yyyy-MM-ddThh:mm:ssZ}" -f $now
#Change the OMSWorkspaceId
$OMSWorkSpaceId = Read-Host -Prompt 'Enter the workspace Id'
$PrimaryKey = Read-Host -Prompt 'Enter the primary key'

#region Test PS object input
$ObjProperties = @{
  Computer = $env:COMPUTERNAME
  Username = $env:USERNAME
  Message  = 'This is a test message injected by the OMSDataInjection module. Input data type: PSObject'
  LogTime  = $Now
}
$OMSDataObject = New-Object -TypeName PSObject -Property $ObjProperties

#Inject data
Write-Output "Injecting PSobject data into OMS"
$InjectData = New-OMSDataInjection -OMSWorkSpaceId $OMSWorkSpaceId -PrimaryKey $PrimaryKey -SecondaryKey $SecondaryKey -LogType $LogName -UTCTimeStampField 'LogTime' -OMSDataObject $OMSDataObject -Verbose
#endregion

#region test JSON input
#Placing the OMS Workspace ID and primary key into a hashtable
$OMSConnection = @{
  OMSWorkSpaceId = $OMSWorkSpaceId
  PrimaryKey = $PrimaryKey
}
$OMSDataJSON = @"
{
"Username":  "$env:USERNAME",
"Message":  "This is a test message injected by the OMSDataInjection module. Input data type: JSON",
"LogTime":  "$ISONow",
"Computer":  "$env:COMPUTERNAME"
}
"@
Write-Output "Injecting JSON data into OMS"
$InjectData = New-OMSDataInjection -OMSConnection $OMSConnection -LogType $LogName -UTCTimeStampField 'LogTime' -OMSDataJSON $OMSDataJSON -verbose
#endregion
```

**Sample Runbook: Test-OMSDataInjectionRunbook**

```powershell
#requires -Version 3 -Modules OMSDataInjection
$LogName = 'OMSTestData'
$UTCTimeStampField = 'LogTime'
$Now = [Datetime]::UtcNow
$ISONOw = "{0:yyyy-MM-ddThh:mm:ssZ}" -f $now
#OMS connection object
$OMSConnectionName = 'OMSConnection'
$OMSConnection = Get-AutomationConnection -Name $OMSConnectionName

#region Test PS object input
$ObjProperties = @{
  Computer = $env:COMPUTERNAME
  Username = $env:USERNAME
  Message  = 'This is a test message injected by the OMSDataInjection module via an Azure Automation runbook. Input data type: PSObject'
  LogTime  = $Now
}
$OMSDataObject = New-Object -TypeName PSObject -Property $ObjProperties

#Inject data
Write-Output "Injecting PSobject data into OMS"
$InjectData = New-OMSDataInjection -OMSConnection $OMSConnection -LogType $LogName -UTCTimeStampField 'LogTime' -OMSDataObject $OMSDataObject -Verbose
#endregion

#region test JSON input
$OMSDataJSON = @"
{
"Username":  "$env:USERNAME",
"Message":  "This is a test message injected by the OMSDataInjection module via an Azure Automation runbook. Input data type: JSON",
"LogTime":  "$ISONow",
"Computer":  "$env:COMPUTERNAME"
}
"@
Write-Output "Injecting JSON data into OMS"
$InjectData = New-OMSDataInjection -OMSConnection $OMSConnection -LogType $LogName -UTCTimeStampField 'LogTime' -OMSDataJSON $OMSDataJSON -verbose
#endregion
```

## Exploring Data in OMS

Once the data is injected into OMS, if you are using a new data type,  it can take a while (few hours) for all the fields to be available in OMS.

i.e. the data injected by the sample script and Azure Automation runbook (executed on Azure):

<a href="https://blog.tyang.org/wp-content/uploads/2016/08/image-54.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/08/image_thumb-54.png" alt="image" width="573" height="419" border="0" /></a>

all the fields that you have defined are stored as custom fields in your OMS workspace:

<a href="https://blog.tyang.org/wp-content/uploads/2016/08/image-55.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/08/image_thumb-55.png" alt="image" width="512" height="324" border="0" /></a>

Please keep in mind, since the Custom Fields feature is still at the preview phase, there’s a limit of 100 custom fields per workspace at this stage (<a title="https://azure.microsoft.com/en-us/documentation/articles/log-analytics-custom-fields/" href="https://azure.microsoft.com/en-us/documentation/articles/log-analytics-custom-fields/">https://azure.microsoft.com/en-us/documentation/articles/log-analytics-custom-fields/</a>), so please be mindful of this limitation when you are building your custom solutions using the HTTP Data Collector API.

## Where to Download This Module?

I have published this module in PowerShell Gallery: <a title="https://www.powershellgallery.com/packages/OMSDataInjection" href="https://www.powershellgallery.com/packages/OMSDataInjection">https://www.powershellgallery.com/packages/OMSDataInjection</a>, if you are using PowerShell version 5 and above, you can install it directly from it: **Install-Module –Name OMSDataInjection –Repository PSGallery**

You can also download it from it’s GitHub repo: <a title="https://github.com/tyconsulting/OMSDataInjection-PSModule/releases" href="https://github.com/tyconsulting/OMSDataInjection-PSModule/releases">https://github.com/tyconsulting/OMSDataInjection-PSModule/releases</a>

## Summary

In the past, we’ve had the OMS Custom View Designer that can help us visualising the data that we already have in OMS Log Analytics, what we were missing is a native way to inject data into OMS. Now with the release of this API, the gap has been filled. Like Evan mentioned in his blog post, by coupling this API with the OMS View Designer (and even throwing Power BI into the mix), you can develop some really fancy solutions.

On 21st of September (3 weeks from now), I will be presenting at the Melbourne Microsoft Cloud and Datacenter Meetup (<a title="https://www.meetup.com/Melbourne-Microsoft-Cloud-and-Datacenter-Meetup/events/233154212/" href="https://www.meetup.com/Melbourne-Microsoft-Cloud-and-Datacenter-Meetup/events/233154212/">https://www.meetup.com/Melbourne-Microsoft-Cloud-and-Datacenter-Meetup/events/233154212/</a>), my topic is Developing Your OWN Custom OMS Solutions. I will doing live demos creating solutions using the HTTP Data Collector API as well as the Custom View Designer. If you are from Melbourne, I encourage you to attend. I am also planning to record this session and publish it on YouTube later.

Lastly, if you have any suggestions for this PowerShell module, please feel free to contact me!