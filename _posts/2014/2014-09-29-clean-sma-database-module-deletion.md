---
id: 3196
title: Clean Up SMA Database After a Module Deletion
date: 2014-09-29T17:55:38+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=3196
permalink: /2014/09/29/clean-sma-database-module-deletion/
categories:
  - SMA
tags:
  - SMA
---

## Background

I noticed an issue while I was writing a SMA integration module. I once made an mistake in the .json file and I noticed I couldn’t import the updated module back to SMA even after I firstly deleted the old version. I’ll explain this issue using a sample dummy module.

## Reproducing The Issue

To reproduce the issue, I firstly created a dummy module with 3 files:

<a href="https://blog.tyang.org/wp-content/uploads/2014/09/image1.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/09/image_thumb1.png" alt="image" width="394" height="113" border="0" /></a>

The module .psm1 and the connection file .json (notice there’s a connection field named "ComputerName" in the .json file):

<a href="https://blog.tyang.org/wp-content/uploads/2014/09/image2.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/09/image_thumb2.png" alt="image" width="563" height="276" border="0" /></a>

I zipped and imported this module into SMA, everything looks good so far. and the connection fields are correctly displayed (as expected):

<a href="https://blog.tyang.org/wp-content/uploads/2014/09/image3.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/09/image_thumb3.png" alt="image" width="507" height="320" border="0" /></a>

I then update the .json file (Changed the connection field name from ComputerName to ComputerFQDN):

<a href="https://blog.tyang.org/wp-content/uploads/2014/09/image4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/09/image_thumb4.png" alt="image" width="488" height="347" border="0" /></a>

I zipped the updated module, tried to import the module into SMA, but got an error:

<a href="https://blog.tyang.org/wp-content/uploads/2014/09/image5.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/09/image_thumb5.png" alt="image" width="519" height="96" border="0" /></a>

I then tried to delete the existing module and imported again, but I got the same error.
I also noticed that even after the module has been deleted, the connection is still available to be selected:

<a href="https://blog.tyang.org/wp-content/uploads/2014/09/SNAGHTML1a885165.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML1a885165" src="https://blog.tyang.org/wp-content/uploads/2014/09/SNAGHTML1a885165_thumb.png" alt="SNAGHTML1a885165" width="473" height="537" border="0" /></a>

## My Resolution

Since I couldn’t find any documentation on how to completely remove an Integration Module, I went ahead and developed a SQL script to completely remove the module and module connection from the various tables in the SMA database. Here’s the SQL script:
```sql
USE SMA
Declare @ModuleName Varchar(max)
Declare @ConnectionName Varchar(max)
Set @ModuleName = 'MyModule'
Set @ConnectionName = 'MyModuleConnection'

PRINT 'Deleting Connection Field values'
delete from Core.ConnectionFieldValues Where ConnectionKey in (Select ConnectionKey from Core.Connections Where ConnectionTypeKey in (Select ConnectionTypeKey from Core.ConnectionTypes Where Name = @ConnectionName))

PRINT 'Deleting Connections'
delete from Core.Connections Where ConnectionTypeKey in (Select ConnectionTypeKey from Core.ConnectionTypes Where Name = @ConnectionName)

Print 'Deleting Connection Fields'
delete from Core.ConnectionFields Where ConnectionTypeKey in (Select ConnectionTypeKey from Core.ConnectionTypes Where Name = @ConnectionName)

PRINT 'Deleting Connection Types'
delete from Core.ConnectionTypes where Name = @ConnectionName

PRINT 'Deleting Activity parameters'
delete from Core.ActivityParameters where ActivityParameterSetKey in (Select ActivityParameterSetKey from Core.ActivityParameterSets where ActivityKey in (Select ActivityKey from Core.Activities Where  ModuleVersionsKey in (Select ModuleVersionsKey From Core.ModuleVersions where  ModuleKey In (Select ModuleKey from Core.Modules Where ModuleName = @ModuleName))))

PRINT 'Deleting Core Activity parameter Sets'
delete from Core.ActivityParameterSets Where ActivityKey in (Select ActivityKey from Core.Activities Where  ModuleVersionsKey in (Select ModuleVersionsKey From Core.ModuleVersions where  ModuleKey In (Select ModuleKey from Core.Modules Where ModuleName = @ModuleName)))

PRINT 'Deleting Core Activities'
Delete from Core.Activities Where ModuleVersionsKey in (Select ModuleVersionsKey From Core.ModuleVersions where  ModuleKey In (Select ModuleKey from Core.Modules Where ModuleName = @ModuleName))

PRINT 'Deleting Job Modules'
delete from Core.JobModules Where ModuleVersionsKey in(Select ModuleVersionsKey from Core.ModuleVersions where ModuleKey in (Select ModuleKey from Core.Modules Where ModuleName = @ModuleName))

PRINT 'Deleting Module Version'
Delete from Core.ModuleVersions where ModuleKey In (Select ModuleKey from Core.Modules Where ModuleName = @ModuleName)

PRINT 'Deleting Modules'
Delete from core.Modules where ModuleName = @ModuleName

```
To use this script, you will need to change the <strong>@ModuleName</strong> and <strong>@ConnectionName</strong> variable to suit your module:

<a href="https://blog.tyang.org/wp-content/uploads/2014/09/SNAGHTML1a938e65.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML1a938e65" src="https://blog.tyang.org/wp-content/uploads/2014/09/SNAGHTML1a938e65_thumb.png" alt="SNAGHTML1a938e65" width="665" height="458" border="0" /></a>

After I ran this script, I was able to import the updated module:

<a href="https://blog.tyang.org/wp-content/uploads/2014/09/image6.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/09/image_thumb6.png" alt="image" width="488" height="365" border="0" /></a>

## Disclaimer

Although I’ve used this for multiple modules in multiple SMA environments and so far have not found any problems, I did not consult this workaround with SMA experts, please use this at your own risk. Please don’t blame me if it breaks your environment.