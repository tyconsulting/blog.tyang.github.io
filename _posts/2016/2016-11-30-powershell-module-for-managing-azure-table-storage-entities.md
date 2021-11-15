---
id: 5751
title: PowerShell Module for Managing Azure Table Storage Entities
date: 2016-11-30T12:32:15+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=5751
permalink: /2016/11/30/powershell-module-for-managing-azure-table-storage-entities/
categories:
  - Azure
  - PowerShell
tags:
  - Azure
  - Azure Storage
  - Azure Table
  - PowerShell
---

## Introduction

Firstly, apologies for not being able to blog for 6 weeks. I have been really busy lately.  As part of a project that I’m working on, I have been dealing with Azure Table storage and its REST API over the last couple of weeks. I have written few Azure Function app in C# as well as some Azure Automation runbooks in PowerShell that involves inserting, querying and updating records (entities) in Azure tables. I was struggling a little bit during development of these function apps and runbooks because I couldn’t find too many good code examples and I personally believe this REST API is not well documented on Microsoft’s documentation site (<a title="https://docs.microsoft.com/en-us/rest/api/storageservices/fileservices/table-service-rest-api" href="https://docs.microsoft.com/en-us/rest/api/storageservices/fileservices/table-service-rest-api">https://docs.microsoft.com/en-us/rest/api/storageservices/fileservices/table-service-rest-api</a>). Therefore I have spent the last two days developed a PowerShell module for managing the lifecycle of the Azure Table entities. This module can be used to perform CRUD (Create, Read, Update, Delete) operations for Azure Table entities.

## AzureTableEntity PowerShell Module

This PowerShell module is named as AzureTableEntity, it can be located in both GitHub and PowerShell Gallery:

 * GitHub: <a title="https://github.com/tyconsulting/AzureTableEntity-PowerShell-Module" href="https://github.com/tyconsulting/AzureTableEntity-PowerShell-Module">https://github.com/tyconsulting/AzureTableEntity-PowerShell-Module</a>
 * PowerShell Gallery: <a title="https://www.powershellgallery.com/packages/AzureTableEntity" href="https://www.powershellgallery.com/packages/AzureTableEntity">https://www.powershellgallery.com/packages/AzureTableEntity</a>

This module offers the following 4 functions:

* **Get-AzureTableEntity**: Search Azure Table entities by specifying a search string.
* **New-AzureTableEntity**: Insert one or more entities to Azure table storage.
* **Update-AzureTableEntity**: Update one or more entities to Azure table storage.
* **Remove-AzureTableEntity**: Remove one or more entities to Azure table storage.

>**Note:** All functions have been properly documented in the help file. you can use Get-Help cmdlet to access the help file.

### Get-AzureTableEntity

By default when performing query operation, the Azure Table REST API only returns up to 1000 entities or all entities returned from search within 5 seconds. This function has a parameter ‘-GetAll’ that can be used to return all search results from a large table. The default value of this parameter is set to $true.

The search result returned by the search API is deserialised. As the result, complex data type such as datetime is returned as string. If you want any datetime fields from the search result returned as original datetime field, you can set the "-ConvertDateTimeFields" parameter to $true. Please note this would potentially increase the script execution time when dealing with a large set of search result.

>**Hint:** You can easily build your search string using the <a href="http://storageexplorer.com/">Azure Storage Explorer</a>.

### New-AzureTableEntity

This function can be used to insert a single entity or bulk insert up to 100 entities (and the total payload size is less than 4MB).

Please make sure both "PartitionKey" and "RowKey" are included in the entity. The data type for these fields must be string.

i.e. Instead of setting RowKey = 1, you should set RowKey = **"1"** – because the value for both PartitionKey and RowKey must be a string.

### Update-AzureTableEntity

This function can be used to update a single entity or bulk update up to 100 entities (and the total payload size is less than 4MB).

Please note when updating an entity, all fields (including the fields that do not need to be updated) must be specified. It is actually a merge operation. If you are modifying an existing entity returned from the search operation (Get-AzureTableEntity) and the entity contains datetime fields, please make sure you set "-ConvertDateTimeFields" parameter to $true when performing the search in the first place. Please also be aware that the built-in Timestamp field must not be included in the entity fields.

### Remove-AzureTableEntity

This function can be used to remove a single entity or bulk remove up to 100 entities (and the total payload size is less than 4MB).

### Support for Azure Automation and SMA

To simply leveraging this module in Azure Automation or SMA, I have included a connection object in the module:

<a href="https://blog.tyang.org/wp-content/uploads/2016/11/image.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/11/image_thumb.png" alt="image" width="206" height="307" border="0" /></a>

Once you have created the connection objects, instead of specifying storage account, table name and storage account access key, you can simply specify the connection object using ‘-TableConnection’ parameter for all four functions.

### Sample Code

I have published some sample code I wrote when developing this module to [GitHub Gist](https://gist.github.com/tyconsulting/1ff706181d8e476528c86b8f7ac8af23):

```powershell
<#
================================================================================
AUTHOR:  Tao Yang 
DATE:    30/11/2016
Version: 1.0
Comment: Sample code for using AzureTableEntity PowerShell module
Project Repo: https://github.com/tyconsulting/AzureTableEntity-PowerShell-Module
================================================================================
#>

$StorageAccountName = '<Enter your storage account name>'
$TableName = '<Enter your Azure table name>'
$StorageAccountAccessKey = '<Enter your storage account access key>'

## Insert entities ##
#Bulk insert
$Entities = @()
$pro1 = @{
  PartitionKey = 'test1'
  RowKey = '1'
  CustomerName = 'Eric Cartman'
  dtDate = [datetime]::UtcNow
  Age = 9
  Alive = $true
}
$entity1 = New-Object psobject -Property $pro1

$pro2 = @{
  PartitionKey = 'test1'
  RowKey = '2'
  CustomerName = 'Bart Simpson'
  dtDate = [datetime]::UtcNow
  Age = 10
  Alive = $true
}
$entity2 = New-Object psobject -Property $pro2
$Entities += $entity1
$Entities += $entity2
$BulkInsert = New-AzureTableEntity -StorageAccountName $StorageAccountName -StorageAccountAccessKey $StorageAccountAccessKey -TableName $TableName -Entities $Entities -Verbose

#single insert
$pro3 = @{
  PartitionKey = 'test2'
  RowKey = '1'
  CustomerName = 'Bart'
  HourlyRate = 9.99
  today = [datetime]::UtcNow
}

$entity3 = New-Object psobject -Property $pro3
$SingleInsert = New-AzureTableEntity -StorageAccountName $StorageAccountName -StorageAccountAccessKey $StorageAccountAccessKey -TableName $TableName -Entities $Entity3 -Verbose

## search entity ##
#return up to 1000 entities
$StartUTCDate = Get-Date -year 2016 -Month 11 -day 27 -Hour 11 -Minute 0 -Second 0 -Millisecond 0
$strStartUTCDate = $StartUTCDate.ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
$QueryString = "(today ge datetime'$strStartUTCDate') and (PartitionKey eq 'test2')"
$SearchResult = Get-AzureTableEntity -StorageAccountName $StorageAccountName -StorageAccountAccessKey $StorageAccountAccessKey -TableName $TableName -QueryString $QueryString -GetAll $false -Verbose

#return all entities, and convert datetime fields
$StartUTCDate = Get-Date -year 2016 -Month 11 -day 27 -Hour 11 -Minute 0 -Second 0 -Millisecond 0
$strStartUTCDate = $StartUTCDate.ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
$QueryString = "(dtDate ge datetime'$strStartUTCDate') and (PartitionKey eq 'test2')"
$SearchResult = Get-AzureTableEntity -StorageAccountName $StorageAccountName -StorageAccountAccessKey $StorageAccountAccessKey -TableName $TableName -QueryString $QueryString -ConvertDateTimeFields $true -GetAll $true -Verbose

## update entities ##
#updating single entity
$pro3 = @{
  PartitionKey = 'test2'
  RowKey = '1'
  CustomerName = 'Bart Simpson'
  today = [datetime]::UtcNow
}

$entity3 = New-Object psobject -Property $pro3
$SingleInsert = Update-AzureTableEntity -StorageAccountName $StorageAccountName -StorageAccountAccessKey $StorageAccountAccessKey -TableName $TableName -Entities $Entity3 -Verbose

#updating multiple entities
$Entities = @()
$pro1 = @{
  PartitionKey = 'test1'
  RowKey = '1'
  CustomerName = 'Hello Kitty'
  dtDate = [datetime]::UtcNow
}
$entity1 = New-Object psobject -Property $pro1

$pro2 = @{
  PartitionKey = 'test1'
  RowKey = '2'
  CustomerName = 'Homer Simpson'
  dtDate = [datetime]::UtcNow
}
$entity2 = New-Object psobject -Property $pro2
$Entities += $entity1
$Entities += $entity2
$BulkUpdate = Update-AzureTableEntity -StorageAccountName $StorageAccountName -StorageAccountAccessKey $StorageAccountAccessKey -TableName $TableName -Entities $Entities -Verbose


## Remove entities ##
#removing single entity
$pro3 = @{
  PartitionKey = 'test2'
  RowKey = '1'
}

$entity3 = New-Object psobject -Property $pro3
$SingleRemoval = Remove-AzureTableEntity -StorageAccountName $StorageAccountName -StorageAccountAccessKey $StorageAccountAccessKey -TableName $TableName -Entities $Entity3 -Verbose

#Removing multiple entities
$Entities = @()
$pro1 = @{
  PartitionKey = 'test1'
  RowKey = '1'
}
$entity1 = New-Object psobject -Property $pro1

$pro2 = @{
  PartitionKey = 'test1'
  RowKey = '2'
}
$entity2 = New-Object psobject -Property $pro2
$Entities += $entity1
$Entities += $entity2
$BulkRemoval = Remove-AzureTableEntity -StorageAccountName $StorageAccountName -StorageAccountAccessKey $StorageAccountAccessKey -TableName $TableName -Entities $Entities -Verbose
```

## Summary

I wrote this module so I can simplify my Azure Automation runbooks and make IT Pro’s life easier when working on Azure Table storage. If you have to deal with Azure Table storage, I hope you find this module useful. If you are a developer and looking for code samples, you can still use this module and simply translate the code to the language of your choice.

I purposely didn’t include any functions for managing the Azure table storage itself because you can manage the Table storage using the Azure.Storage module.

Lastly, feedbacks are always welcome, so please drop me an email if you have any.