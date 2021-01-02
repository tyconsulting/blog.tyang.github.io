---
id: 3802
title: Various Ways to Find the ID of a Monitoring Object in OpsMgr
date: 2015-03-11T20:02:36+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=3802
permalink: /2015/03/11/various-ways-to-find-the-id-of-a-monitoring-object-in-opsmgr/
categories:
  - PowerShell
  - SCOM
tags:
  - PowerShell
  - SCOM
---
Often when working in OpsMgr, we need to find the ID of a monitoring object. For example, in the recent Squared Up Dashboard  version 2.0 Customer Preview webinar (<a title="https://www.youtube.com/watch?v=233oTAefrRM" href="https://www.youtube.com/watch?v=233oTAefrRM">https://www.youtube.com/watch?v=233oTAefrRM</a>), it was mentioned in the webinar that the monitoring object IDs must  be located when preparing the Visio diagram for the upcoming Visio plugin.

In this post, I’ll demonstrate 3 methods to retrieve the monitoring object ID from SCOM. These 3 methods are:
<ul>
	<li>Using OpsMgr built-in PowerShell Module "OperationsManager"</li>
	<li>Using OpsMgr SDK via Windows PowerShell</li>
	<li>Using SCSM Entity Explorer</li>
</ul>
In the demonstrations, I will show how to retrieve the monitoring object ID for a particular SQL database:
<ul>
	<li>Monitoring Class Display Name: <strong>SQL Database</strong></li>
	<li>DB name: <strong>master</strong></li>
	<li>DB Engine: <strong>MSSQLSERVER</strong></li>
	<li>SQL Server: <strong>SQLDB01.corp.tyang.org</strong></li>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2015/03/image4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/03/image_thumb4.png" alt="image" width="479" height="527" border="0" /></a>

<strong><span style="color: #ff0000;">Note: </span></strong>Before I start digging into this topic, if you are not very PowerShell savvy, and only want a simple GUI based solution, please go straight to the last method (using SCSM Entity Explorer).

&nbsp;

## Using OpsMgr PowerShell Module OperationsManager

<strong>01. Define variables and connect to the management server:</strong>
```powershell
#region variables

$ClassDisplayName = "SQL Database"
$DBName = "master"
$SQLServer = "sqldb01.corp.tyang.org"
$DBEngine = "MSSQLSERVER"

#endregion

#Connect to OpsMgr management server
import-module operationsmanager
New-SCOMManagementGroupConnection -ComputerName OPSMGRMS01

```
<strong>02. Get the monitoring class based on its display name:</strong>
```powershell
#Get the monitoring class based on the class display name
$MonitoringClasses = Get-SCOMClass -DisplayName $ClassDisplayName

```
However, in my management group, there are 2 classes with the same name "SQL Database":

<a href="http://blog.tyang.org/wp-content/uploads/2015/03/image5.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/03/image_thumb5.png" alt="image" width="565" height="88" border="0" /></a>

As you can see, the first item in the array $MonitoringClasses is the correct one in this case. We will reference it as <strong>$MonitoringClasses[0]</strong>.

<strong>03. Get the monitoring object for the particular database:</strong>
<pre language="PowerShell" class="">$MonitoringObject = Get-SCOMClassInstance -Class $MonitoringClasses[0] | Where-object {$_.Name -eq $DBName -and $_.'[Microsoft.Windows.Computer].PrincipalName'.value -ieq $SQLServer -and $_.'[Microsoft.SQLServer.ServerRole].InstanceName'.value -ieq $DBEngine}

```
The Get-SCOMClassInstance cmdlet does not take any criteria, therefore, the command above retrieves all instances of the SQL Database class, then filter the result based on the database name, SQL server name and SQL DB instance name to locate the particlar database that we are looking for.

<a href="http://blog.tyang.org/wp-content/uploads/2015/03/image6.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/03/image_thumb6.png" alt="image" width="554" height="513" border="0" /></a>

The monitoring object ID is highlighted as above.

<a href="http://blog.tyang.org/wp-content/uploads/2015/03/image7.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/03/image_thumb7.png" alt="image" width="473" height="221" border="0" /></a>

The type for the ID field is Guid. You can also convert it to a string as shown above.

&nbsp;

## Using OpsMgrSDK Via Windows PowerShell

In this example, I won’t spend too much time on how to load the SDK assemblies, in the script, I’m assuming the SDK DLLs are already loaded into the Global Assembly Cache (GAC). So, in order to use this script, you will need to run this on an OpsMgr management server or a web console server, or a computer that has operations console installed.

<strong>01. Define variables, load SDK assemblies and connect to OpsMgr management group:</strong>
```powershell
#region variables

$ClassDisplayName = "SQL Database"
$DBName = "master"
$SQLServer = "sqldb01.corp.tyang.org"
$DBEngine = "MSSQLSERVER"

#endregion
#Load SDK
[Void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.EnterpriseManagement.Core')
[Void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.EnterpriseManagement.OperationsManager')
[Void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.EnterpriseManagement.Runtime')

#Connect to management group
$MGConnSetting = New-Object Microsoft.EnterpriseManagement.ManagementGroupConnectionSettings("OpsMgrMS01")
$MG = New-Object Microsoft.EnterpriseManagement.ManagementGroup($MGConnSetting)

```
<strong>02. Get the monitoring class based on the display name</strong>
```powershell
#Get the monitoring class
$strMCQuery = "DisplayName = '$ClassDisplayName'"
$mcCriteria = New-Object Microsoft.EnterpriseManagement.Configuration.MonitoringClassCriteria($strMCQuery)
$MonitoringClass = $MG.GetMonitoringClasses($mcCriteria)

```
<a href="http://blog.tyang.org/wp-content/uploads/2015/03/image8.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/03/image_thumb8.png" alt="image" width="674" height="328" border="0" /></a>

As you can see, since the display name is not unique, 2 classes are returned from the search (this is same as the first method), except this time, the type for $MonitoringClass varible is a ReadOnlyCollection. However, we can still reference the correct monitoring class using $MonitoringClass[0]

<a href="http://blog.tyang.org/wp-content/uploads/2015/03/image9.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/03/image_thumb9.png" alt="image" width="637" height="170" border="0" /></a>

<strong>03. Get the monitoring object for the particular database:</strong>

Please refer to <a href="https://msdn.microsoft.com/en-us/library/microsoft.enterprisemanagement.monitoring.monitoringobjectgenericcriteria.aspx">this page</a> for the properties that you can use to build the search criteria (MonitoringObjectGenericCriteria)
```powershell
#Get the monitoring object
$DBPath = "$SQLServer`;$DBEngine"
$strMOQuery = "DisplayName = '$DBName' AND Path = '$DBPath'"
$MOCriteria = New-Object Microsoft.EnterpriseManagement.Monitoring.MonitoringObjectGenericCriteria($strMOQuery)
$MonitoringObject = $MG.GetMonitoringObjects($MOCriteria, $MonitoringClass[0])

```
As you can see, unlike the first method using the built-in module, we can specify a more granular search criteria to locate the monitoring object (as result, the command execution should be much faster). However, please keep in mind although there is only one monitoring object returned from the search result, the $MonitoirngObject variable is still a ReadOnlyCollection:

<a href="http://blog.tyang.org/wp-content/uploads/2015/03/image10.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/03/image_thumb10.png" alt="image" width="579" height="212" border="0" /></a>

And you can access the particular SQL Database (Monitoring Object) using $MonitoringObject[0]:

<a href="http://blog.tyang.org/wp-content/uploads/2015/03/image11.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/03/image_thumb11.png" alt="image" width="588" height="350" border="0" /></a>

&nbsp;

## Using SCSM Entity Explorer

SCSM Entity Explorer is a free utility developed by <a href="http://blog.dietergasser.com/">Dieter Gasser</a>. You can download it from TechNet Gallery: <a title="https://gallery.technet.microsoft.com/SCSM-Entity-Explorer-68b86bd2" href="https://gallery.technet.microsoft.com/SCSM-Entity-Explorer-68b86bd2">https://gallery.technet.microsoft.com/SCSM-Entity-Explorer-68b86bd2</a>

Although as the name suggested, it was developed for SCSM, it also works with OpsMgr. Once you’ve downloaded it and placed on a computer, you can follow the instruction below to locate the particular monitoring object.

<strong>01. Connect to an OpsMgr management server and search the monitoring class using display name</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2015/03/image12.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/03/image_thumb12.png" alt="image" width="612" height="390" border="0" /></a>

As shown above, there are 2 classes returned when searching the display name "SQL Database". You can find the correct one from the full name on the right.

<strong>02. Load objects for the monitoring class:</strong>

Go to the objects class and click on "Load Objects" button to load all instances.

<a href="http://blog.tyang.org/wp-content/uploads/2015/03/image13.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/03/image_thumb13.png" alt="image" width="678" height="378" border="0" /></a>

Unfortunately, the we cannot modify what properties to be displayed on the objects list, and the display name does not contain the SQL server and DB instance name. In this scenario, the only way to find the correct instance is to open each one using the "View Details" button.

<a href="http://blog.tyang.org/wp-content/uploads/2015/03/image14.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/03/image_thumb14.png" alt="image" width="249" height="300" border="0" /></a>

Once you’ve located the correct instance, the monitoring object ID is displayed on the objects list.

Having said that, if you are looking for a monitoring object from a singleton class (where there can only be 1 instance in the MG, such as a group), this method is probably the easiest out of all 3.

i.e. When I’m looking for a group I created for the Hyper-V servers and their health service watchers, there is only instance:

<a href="http://blog.tyang.org/wp-content/uploads/2015/03/image15.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/03/image_thumb15.png" alt="image" width="589" height="331" border="0" /></a>

Also, for certain monitoring objects (such as Windows Server), you can easily locate the correct instance based on the display name:

<a href="http://blog.tyang.org/wp-content/uploads/2015/03/image16.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/03/image_thumb16.png" alt="image" width="578" height="322" border="0" /></a>

## Conclusion

based on your requirements (and the information available for search), you can choose one of these methods whichever you think it’s the best.

Lastly,  if you know other ways to locate monitoring object ID, please leave a note here or send me an email.