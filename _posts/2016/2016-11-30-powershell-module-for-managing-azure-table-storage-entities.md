---
id: 5751
title: PowerShell Module for Managing Azure Table Storage Entities
date: 2016-11-30T12:32:15+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=5751
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

## <img style="background-image: none; float: left; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="Azure Storage - Table" src="http://blog.tyang.org/wp-content/uploads/2016/11/Azure-Storage-Table.png" alt="Azure Storage - Table" width="166" height="166" align="left" border="0" />Introduction

Firstly, apologies for not being able to blog for 6 weeks. I have been really busy lately.  As part of a project that I’m working on, I have been dealing with Azure Table storage and its REST API over the last couple of weeks. I have written few Azure Function app in C# as well as some Azure Automation runbooks in PowerShell that involves inserting, querying and updating records (entities) in Azure tables. I was struggling a little bit during development of these function apps and runbooks because I couldn’t find too many good code examples and I personally believe this REST API is not well documented on Microsoft’s documentation site (<a title="https://docs.microsoft.com/en-us/rest/api/storageservices/fileservices/table-service-rest-api" href="https://docs.microsoft.com/en-us/rest/api/storageservices/fileservices/table-service-rest-api">https://docs.microsoft.com/en-us/rest/api/storageservices/fileservices/table-service-rest-api</a>). Therefore I have spent the last two days developed a PowerShell module for managing the lifecycle of the Azure Table entities. This module can be used to perform CRUD (Create, Read, Update, Delete) operations for Azure Table entities.

## AzureTableEntity PowerShell Module

This PowerShell module is named as AzureTableEntity, it can be located in both GitHub and PowerShell Gallery:
<ul>
 	<li>GitHub: <a title="https://github.com/tyconsulting/AzureTableEntity-PowerShell-Module" href="https://github.com/tyconsulting/AzureTableEntity-PowerShell-Module">https://github.com/tyconsulting/AzureTableEntity-PowerShell-Module</a></li>
 	<li>PowerShell Gallery: <a title="https://www.powershellgallery.com/packages/AzureTableEntity" href="https://www.powershellgallery.com/packages/AzureTableEntity">https://www.powershellgallery.com/packages/AzureTableEntity</a></li>
</ul>
This module offers the following 4 functions:
<table style="color: #000000;" border="1" width="693" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td valign="top" width="405"><strong>Get-AzureTableEntity</strong></td>
<td valign="top" width="286">Search Azure Table entities by specifying a search string.</td>
</tr>
<tr>
<td valign="top" width="417"><strong>New-AzureTableEntity</strong></td>
<td valign="top" width="293">Insert one or more entities to Azure table storage.</td>
</tr>
<tr>
<td valign="top" width="419"><strong>Update-AzureTableEntity</strong></td>
<td valign="top" width="295">Update one or more entities to Azure table storage.</td>
</tr>
<tr>
<td valign="top" width="418"><strong>Remove-AzureTableEntity</strong></td>
<td valign="top" width="297">Remove one or more entities to Azure table storage.</td>
</tr>
</tbody>
</table>
<span style="color: #ff0000;"><strong>Note:</strong> </span>All functions have been properly documented in the help file. you can use Get-Help cmdlet to access the help file.
<h4>Get-AzureTableEntity</h4>
By default when performing query operation, the Azure Table REST API only returns up to 1000 entities or all entities returned from search within 5 seconds. This function has a parameter ‘-GetAll’ that can be used to return all search results from a large table. The default value of this parameter is set to $true.

The search result returned by the search API is deserialised. As the result, complex data type such as datetime is returned as string. If you want any datetime fields from the search result returned as original datetime field, you can set the "-ConvertDateTimeFields" parameter to $true. Please note this would potentially increase the script execution time when dealing with a large set of search result.

<span style="color: #ff0000;"><strong>Hint:</strong></span> You can easily build your search string using the <a href="http://storageexplorer.com/">Azure Storage Explorer</a>.
<h4>New-AzureTableEntity</h4>
This function can be used to insert a single entity or bulk insert up to 100 entities (and the total payload size is less than 4MB).

Please make sure both "PartitionKey" and "RowKey" are included in the entity. The data type for these fields must be string.

i.e. Instead of setting RowKey = 1, you should set RowKey = <strong>"1" – </strong>because the value for both PartitionKey and RowKey must be a string.
<h4>Update-AzureTableEntity</h4>
This function can be used to update a single entity or bulk update up to 100 entities (and the total payload size is less than 4MB).

Please note when updating an entity, all fields (including the fields that do not need to be updated) must be specified. It is actually a merge operation. If you are modifying an existing entity returned from the search operation (Get-AzureTableEntity) and the entity contains datetime fields, please make sure you set "-ConvertDateTimeFields" parameter to $true when performing the search in the first place. Please also be aware that the built-in Timestamp field must not be included in the entity fields.
<h4>Remove-AzureTableEntity</h4>
This function can be used to remove a single entity or bulk remove up to 100 entities (and the total payload size is less than 4MB).
<h4>Support for Azure Automation and SMA</h4>
To simply leveraging this module in Azure Automation or SMA, I have included a connection object in the module:

<a href="http://blog.tyang.org/wp-content/uploads/2016/11/image.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/11/image_thumb.png" alt="image" width="206" height="307" border="0" /></a>

Once you have created the connection objects, instead of specifying storage account, table name and storage account access key, you can simply specify the connection object using ‘-TableConnection’ parameter for all four functions.
<h4>Sample Code</h4>
I have published some sample code I wrote when developing this module to GitHub Gist:

https://gist.github.com/tyconsulting/1ff706181d8e476528c86b8f7ac8af23

## Summary

I wrote this module so I can simplify my Azure Automation runbooks and make IT Pro’s life easier when working on Azure Table storage. If you have to deal with Azure Table storage, I hope you find this module useful. If you are a developer and looking for code samples, you can still use this module and simply translate the code to the language of your choice.

I purposely didn’t include any functions for managing the Azure table storage itself because you can manage the Table storage using the Azure.Storage module.

Lastly, feedbacks are always welcome, so please drop me an email if you have any.