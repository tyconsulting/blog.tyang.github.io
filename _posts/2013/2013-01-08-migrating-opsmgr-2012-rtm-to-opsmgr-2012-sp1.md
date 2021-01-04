---
id: 1680
title: Migrating OpsMgr 2012 RTM to OpsMgr 2012 SP1
date: 2013-01-08T10:33:36+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=1680
permalink: /2013/01/08/migrating-opsmgr-2012-rtm-to-opsmgr-2012-sp1/
categories:
  - SCOM
tags:
  - SCOM
---
Over the Christmas / New Year break, I spent some time to upgrade the OpsMgr 2012 RTM environment in my test lab to SP1. Since System Center 2012 SP1 fully supports Windows Server 2012 and SQL 2012, I have decided not only to upgrade OpsMgr 2012 to SP1, but I'd also want all management servers, web server, database server to run on Windows Server 2012 and SQL server 2012.

My OpsMgr 2012 test environment consists 3 management servers, 1 database server (SQL 2008 R2, hosts both Operational and DW database, it is also the OpsMgr reporting server running SQL SSRS), and 1 web console server. All of these servers were running Windows Serer 2008 R2 SP1.

Below are the high level steps I have taken to upgrade this environment to OpsMgr 2012 SP1 and also migrate to Windows Server 2012 and SQL Server 2012 SP1:
<ol style="margin-left: 38pt;">
	<li>Update the existing OpsMgr 2012 RTM environment to SP1</li>
	<li>Build a new SQL 2012 SP1 database server running on Windows Server 2012 and Migrate both databases and reporting server role to this server.</li>
	<li>Move agents off each management server and rebuild them one by one running Windows Server 2012 and then install OpsMgr 2012 SP1 management server to join the existing management group.</li>
	<li>Rebuild Web console server to Windows Server 2012 and then install OpsMgr 2012 web console using OpsMgr 2012 SP1 install media.</li>
</ol>
Alone the process, I have documented some detailed steps and I want to share with the community as I assume I'm not the only one who also wants to upgrade the underlying OS for SCOM servers to Windows Server 2012. Here's what I have documented:

<span style="color: #ff0000;"><strong>Disclaimer:</strong> below are the step I've taken specific to my test environment. They are essentially combination of multiple guides from TechNet. Please only use it only as a reference, I hold no responsibilities for any damages it may occur to anyone else's OpsMgr environment.</span>
<ol>
	<li>Created Windows Server 2012 instance (named OpsMgrSQL01)</li>
	<li>Install SQL 2012 Enterprise With SP1 (Database Engine, Full-Text and Semantic Extractions for Search, SSRS, client tools etc)</li>
	<li>
<div>Upgrade existing OpsMgr 2012 RTM to SP1 (<a href="http://technet.microsoft.com/en-us/library/jj899854.aspx">http://technet.microsoft.com/en-us/library/jj899854.aspx</a>)</div>
<ol>
	<li>Backup OperationsManager and OperationsManagerDW databases.</li>
	<li>run SP1 setup on all management servers</li>
</ol>
</li>
	<li>
<div>Migrate SCOM Operational Database to new SQL 2012 server</div>
<ol>
	<li>Poweroff all management servers</li>
	<li>Backup OperationsManager database on the original SQL 2008 R2 server</li>
	<li>Copy OperationsManager.bak to new SQL 2012 server</li>
	<li>Restore OperationsManager database from OperationsManager.bak on SQL 2012 server</li>
	<li>On the original SQL 2008 server, take OperationsManager database offline</li>
	<li>Startup all management servers</li>
	<li>Stop System Center Data Access Service, System Center Management service and System Center Management Configuration service on all management servers</li>
	<li>Follow instruction from <a href="http://technet.microsoft.com/en-us/library/hh278848.aspx">http://technet.microsoft.com/en-us/library/hh278848.aspx</a> to migrate the operational database</li>
</ol>
</li>
	<li>make sure all management servers are functional</li>
	<li>
<div>Migrate SCOM Data Warehouse database and reporting server role to new SQL server</div>
<ol>
	<li>Backup OperationsManagerDW database on the original SQL 2008 R2 server</li>
	<li>Copy OperationsManagerDW.bak to new SQL 2012 server</li>
	<li>Restore OperationsManagerDW database on the new SQL 2012 server</li>
	<li>Follow instruction to finish moving DW database: <a href="http://technet.microsoft.com/en-us/library/hh268492.aspx">http://technet.microsoft.com/en-us/library/hh268492.aspx</a></li>
	<li>Configure SSRS on new SQL 2012 server</li>
	<li>Remove OpsMgr reporting server role from the old SQL 2008 server</li>
	<li>Install OpsMgr Reporting Server on new SQL 2012 server</li>
	<li>Follow instruction: <a href="http://technet.microsoft.com/en-us/library/hh457588.aspx">http://technet.microsoft.com/en-us/library/hh457588.aspx</a> to move the Reporting server</li>
	<li>On new SQL 2012 server, go to <strong>HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Reporting</strong>, change <strong>DWDBInstance</strong> to the new SQL 2012 server.</li>
	<li>On new SQL 2012 server, go to <strong>HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\System Center Operations Manager\12\Reporting</strong>, change <strong>DWDBInstance</strong> to the new SQL 2012 server.</li>
	<li>
<div>On the new SQL 2012 server hosting the operational database, update the OperationsManager database table.</div>
<ol>
	<li>Open SQL Server Management Studio.</li>
	<li>Expand Databases , OperationsManager , and Tables.</li>
	<li>Right-click dbo. MT_Microsoft$SystemCenter$DataWarehouse , and then click Edit Top 200 Rows .</li>
	<li>Change the value in the MainDatabaseServerName_2C77AA48_DB0A_5D69_F8FF_20E48F3AED0F column to reflect the name of the new SQL Server</li>
	<li>Close SQL Server Management Studio.</li>
</ol>
</li>
	<li>In new SQL 2012 server, go to SSRS web page http://localhost/reports, edit "Data Warehouse Main" data source to point to the new SQL 2012 server.</li>
</ol>
</li>
	<li>Turn off old SQL 2008 server</li>
	<li>Reboot new SQL 2012 server</li>
	<li>Reboot all management servers</li>
	<li>Move all agents from management server A to another management server</li>
	<li>If management server A is the RMS emulator, move the RMSE role to another management server by using <strong>Powershell Cmdlet: Get-SCOMManagementServer -Name "NewRMSE" | Set-SCOMRMSEmulator</strong></li>
	<li>
<div>If the Reporting server is pointing to this management server, configure the reporting server to use another MS by editing the registry key on the reporting server</div>
<ol>
	<li>Go to <strong>HKLM\SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Reporting</strong>, edit <strong>DefaultSDKServiceMachine</strong> to another management server.</li>
	<li>Go to <strong>HKLM\SOFTWARE\Microsoft\System Center Operations Manager\12\Reporting</strong>, edit <strong>DefaultSDKServiceMachine</strong> to another management server.</li>
	<li>Edit <strong>"&lt;SQL Install Dir&gt;\Microsoft SQL Server\MSRS11.MSSQLSERVER\Reporting Services\ReportServer\rsreportserver.config"</strong> file, locate 2 instances of <strong>&lt;ServerName&gt;</strong> tag and update the management server name</li>
	<li>Restart SSRS service on the new SQL 2012 server running SSRS</li>
	<li>Shut down management server A and make sure reporting still works</li>
	<li>Power up management server A</li>
</ol>
</li>
	<li>Uninstall OpsMgr management server on management server A from control panel.</li>
	<li>Delete management server A from OpsMgr console (Administration--&gt;Management Servers)</li>
	<li>Rebuild management server A with Windows Server 2012.</li>
	<li>Install Microsoft Report Viewer 2010</li>
	<li>Install OpsMgr 2012 Service Pack 1 on the newly built Windows Server 2012 and join it to the existing management group.</li>
	<li>Repeat step 10-17 for each management server that to be migrated to Windows Server 2012.</li>
	<li>Uninstall Web Console from Web Console server</li>
	<li>Rebuild Web Console server to Windows Server 2012</li>
	<li>Install Microsoft Report Viewer 2010 on the Web Console server</li>
	<li>Configure IIS and .NET prerequisites for OpsMgr 2012 web console</li>
	<li>Install OpsMgr 2012 Web Console on the newly built web console server</li>
	<li>Connect to the Web console server from a client computer and make sure the web console is functional.</li>
</ol>
Now, I have migrated everything but 1 management server to Windows Server 2012 and SQL server 2012. I have decided to keep one management server running Windows Server 2008 R2 just in case I need to test any different scenarios in the future.

I didn't have chance to build a Gateway server in the RTM environment so I didn't have a Gateway server to migrate.