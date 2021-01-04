---
id: 6241
title: AzureTableEntity PowerShell Module Updated
date: 2017-09-11T21:25:15+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=6241
permalink: /2017/09/11/azuretableentity-powershell-module-updated/
categories:
  - Azure
  - PowerShell
tags:
  - Azure
  - Azure Table
  - PowerShell
---
I have updated the AzureTableEntity PowerShell module few days ago. The latest version is 1.0.3.0 and it is published at:

PowerShell Gallery: <a title="https://www.powershellgallery.com/packages/AzureTableEntity/1.0.3.0" href="https://www.powershellgallery.com/packages/AzureTableEntity/1.0.3.0">https://www.powershellgallery.com/packages/AzureTableEntity/1.0.3.0</a>

GitHub: <a title="https://github.com/tyconsulting/AzureTableEntity-PowerShell-Module/releases" href="https://github.com/tyconsulting/AzureTableEntity-PowerShell-Module/releases">https://github.com/tyconsulting/AzureTableEntity-PowerShell-Module/releases</a>

What’s changed?

**New function Merge-AzureTableEntity**

Merge one or more entities in a Azure table. Please make sure you understand the difference between Azure table merge and update operations:

 * Update: replace entity fields with the the fields specified in the update operation
 * Merge: update the value of existing fields specified in the merge operation

If you want to update the value of an existing field and having the rest of the fields unchanged, make sure you use Merge-AzureTableEntity (instead of Update-AzureTableEntity).

**New function Test-AzureTableConnection**

Testing the connection to an Azure table by specifying Storage Account name, key and table name.

**Update-AzureTableEntity Bug Fix**

I have identified a bug in Update-AzureTableEntity when invoking bulk update. This is addressed in this release.