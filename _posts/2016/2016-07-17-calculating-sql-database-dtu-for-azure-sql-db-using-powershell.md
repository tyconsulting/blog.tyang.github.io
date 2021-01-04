---
id: 5418
title: Calculating SQL Database DTU for Azure SQL DB Using PowerShell
date: 2016-07-17T18:58:50+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=5418
permalink: /2016/07/17/calculating-sql-database-dtu-for-azure-sql-db-using-powershell/
categories:
  - Azure
  - PowerShell
tags:
  - Azure
  - Azure SQL DB
---
over the last few weeks, I have been working on a project related to Azure SQL Database. One of the requirements was to be able to programmatically calculate the SQL Database DTU (<a href="https://channel9.msdn.com/Series/Windows-Azure-Storage-SQL-Database-Tutorials/Scott-Klein-Video-02">Database Throughput Unit</a>).

Since the DTU concept is Microsoft’s proprietary IP, the actual formula for the DTU calculation has not been released to the public. Luckily, Microsoft’s Justin Henriksen has developed an online <a href="http://dtucalculator.azurewebsites.net/">Azure SQL DB DTU Calculator</a>, you can also Justin’s blog <a href="https://justinhenriksen.wordpress.com/2015/05/15/introducing-the-azure-sql-database-dtu-calculator/">here</a>. I was able to use the web service Justin has developed for the online DTU Calculator, and I developed 2 PowerShell functions to perform the calculation by invoking the web service. The first function is called <a href="https://github.com/tyconsulting/BlogPosts/blob/master/Azure/Get-AzureSQLDBDTU.ps1">Get-AzureSQLDBDTU</a>, which can be used to calculate DTU for individual databases, the second function is called <a href="https://github.com/tyconsulting/BlogPosts/blob/master/Azure/Get-AzureSQLDBElasticPoolDTU.ps1">Get-AzureSQLDBElasticPoolDTU</a>, which can be used to calculate DTU for Azure SQL Elastic Pools.

Obviously, since we are invoking a web service, the computer where you are running the script from requires Internet connection. Here’s a sample script to invoke the **Get-AzureSQLDBDTU** function:

>**Note:** you will need to change the variables in the ‘variables’ region, the $LogicalDriveLetter is the drive letter for the SQL DB data file drive.

```powershell
#region variables
$SampleInterval = 1
$MaxSamples = 3600
$DatabaseName = 'AdventureWorks'
$LogicalDriveLetter = 'C'
$ComputerName = 'SQLDB01'
#endregion

#Get number of processors cores
$processors = get-wmiobject -query 'select * from win32_processor' -ComputerName $ComputerName
$Cores = 0
Foreach ($processor in $Processors)
{
  $Cores = $numberOfCores + $processor.NumberOfCores
}

#region collect perf counters
$counters = @('\Processor(_Total)\% Processor Time', "\LogicalDisk($LogicalDriveLetter`:)\Disk Reads/sec", "\LogicalDisk($LogicalDriveLetter`:)\Disk Writes/sec", "\SQLServer:Databases($DatabaseName)\Log Bytes Flushed/sec")

$arrRawPerfValues = Get-Counter -Counter $counters -SampleInterval $SampleInterval -MaxSamples $MaxSamples -ComputerName $ComputerName
$arrPerfValues = @()
Foreach ($item in $arrRawPerfValues)
{
  $processorTime =$item.CounterSamples[0].CookedValue
  $diskReads = $item.CounterSamples[1].CookedValue
  $diskWrites = $item.CounterSamples[2].CookedValue
  $logBytesFlushed = $item.CounterSamples[3].CookedValue
  $properties = @{
  diskReads       = $diskReads
  diskWrites      = $diskWrites
  logBytesFlushed = $logBytesFlushed
  processorTime   = $processorTime
  }
  $objPerf = New-Object -TypeName psobject -Property $properties
  $arrPerfValues += $objPerf
}
#endregion

#region Calculate DTU
#construct web API JSON parameter
$apiPerformanceItems = ConvertTo-Json -InputObject $arrPerfValues

#Invoke the web API to calculate DUT
$DTUCalculationResult = Get-AzureSQLDBDTU -Core $Cores -apiPerformanceItems $apiPerformanceItems
#endregion
```

The recommended Azure SQL DB service tier and coverage % can be retrieved in the **‘Recommendations’** property of the result:

<a href="http://blog.tyang.org/wp-content/uploads/2016/07/image.png"><img style="padding-top: 0px; padding-left: 0px; margin: 0px; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/07/image_thumb.png" alt="image" width="244" height="90" border="0" /></a>

the raw reading for each perf sample can be retrieved in the **‘SelectedServiceTiers’** property of the result:

<a href="http://blog.tyang.org/wp-content/uploads/2016/07/image-1.png"><img style="padding-top: 0px; padding-left: 0px; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/07/image_thumb-1.png" alt="image" width="689" height="164" border="0" /></a>

Lastly, thanks Justin for developing the DTU calculator and the web service, and pointing me to the right direction.