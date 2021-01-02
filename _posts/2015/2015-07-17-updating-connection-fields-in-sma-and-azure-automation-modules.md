---
id: 4220
title: Updating Connection Fields in SMA and Azure Automation Modules
date: 2015-07-17T11:21:23+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=4220
permalink: /2015/07/17/updating-connection-fields-in-sma-and-azure-automation-modules/
categories:
  - OMS
  - SMA
tags:
  - Azure Automation
  - SMA
---
Recently when I was working with <a href="https://cloudadministrator.wordpress.com/" target="_blank">Stanislav Zhelyazkov</a> on the <a href="https://github.com/slavizh/OMSSearch" target="_blank">OMSSearch module</a>, Stan discovered an issue where the module connection type does not get updated when you import an updated version of the module in Azure Automation if the fields have been modified in the module. I have also seen this issue with SMA, so it is not only specific to Azure Automation.

Stan has also raised this issue in the User Voice: <a title="http://feedback.azure.com/forums/246290-azure-automation/suggestions/8791036-connection-fields-for-modules-are-not-updated" href="http://feedback.azure.com/forums/246290-azure-automation/suggestions/8791036-connection-fields-for-modules-are-not-updated">http://feedback.azure.com/forums/246290-azure-automation/suggestions/8791036-connection-fields-for-modules-are-not-updated</a>

As you can see from the feedback from Joe Levy and Beth Cooper, it is a known issue with SMA and Azure Automation. Joe has also provided a workaround for Azure Automation (deleting the connection type using REST API).

I have seen this issue many times in the past with SMA, and when I started writing this post, I realised I actually <a href="http://blog.tyang.org/2014/09/29/clean-sma-database-module-deletion/" target="_blank">blogged</a> about this issue almost a year ago. - I didn't remember blogging it at all, maybe it a sign that I'm getting old <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" src="http://blog.tyang.org/wp-content/uploads/2015/07/wlEmoticon-smile.png" alt="Smile" />.

Anyways, I've updated the SQL script from my previous post, wrapped the deletion commands in a transaction as per Beth's advice:

<pre language="SQL">
USE SMA
Declare @ModuleName Varchar(max)
Declare @ConnectionName Varchar(max)
Set @ModuleName = '<Your Module Name Here>'
Set @ConnectionName = '<Your Connection Name Here>'

BEGIN TRANSACTION T1
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
COMMIT TRANSACTION T1

```

As I explained in the <a href="http://blog.tyang.org/2014/09/29/clean-sma-database-module-deletion/" target="_blank">previous post</a>, you will need to update the <strong>@ModuleName</strong> and <strong>@ConnectionName</strong> variables accordingly.

Lastly, I'd like to state that it is very common to update the connection type JSON file during your module development phase. During this phase, you would probably use this script a lot <strong><u>on your development environment</u></strong>. But please do not try and use this in production environment. It is developed by myself with no involvement from Microsoft, and Microsoft would never support directly editing the database.

## Conclusion

If you are having this issue with On-Prem SMA, in your <u>non-prod environment</u>, you can try to use this SQL script to remove the connection type AFTER the old module has been deleted.

If you are having this issue in Azure Automation, please use the REST API as Joe mentioned in the User Voice: <a title="https://msdn.microsoft.com/en-us/library/azure/mt163852.aspx" href="https://msdn.microsoft.com/en-us/library/azure/mt163852.aspx">https://msdn.microsoft.com/en-us/library/azure/mt163852.aspx</a>