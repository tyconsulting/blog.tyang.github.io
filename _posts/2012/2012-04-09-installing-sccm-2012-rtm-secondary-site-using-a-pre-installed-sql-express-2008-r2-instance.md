---
id: 1100
title: Installing SCCM 2012 RTM Secondary Site using A Pre-Installed SQL Express 2008 R2 Instance
date: 2012-04-09T00:15:46+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=1100
permalink: /2012/04/09/installing-sccm-2012-rtm-secondary-site-using-a-pre-installed-sql-express-2008-r2-instance/
categories:
  - SCCM
tags:
  - SCCM 2012
  - Secondary Site
  - SQL Express
---
Since System Center 2012 was RTM’d few days ago, I have started updating / migrating my home environment. After I migrated my 2 Hyper-V servers from VMM 2008 R2 to VMM 2012, I have started building a brand new SCCM 2012 environment so I can migrate SCCM 2007 to it. My plan is to install a Central Admin site, a child primary site and a Secondary site so I have a simple 3-tier hierarchy like my existing 2007 and 2012 Beta 2 environments.

The Central Admin site and the child primary site installation all went pretty smoothly. But I had some issues when installing the secondary site.

When installing Secondary Site from it’s parent primary, There are two options available for the database:
<ol>
	<li>Install and Configure a local copy of SQL Server Express on the secondary site computer</li>
	<li>Use an existing SQL Server instance.</li>
</ol>
I wanted to install SQL Express myself so I can control where it’s installed to and locations for data, log and backup files. – This is pretty common and most of SQL DBAs would configure to install SQL on a volume other than C:\ and place data / logs / backups on dedicated and separate disks. By using SCCM to install SQL express for you, you don’t get to choose any of this, which can be pretty annoying.

According to <a href="http://technet.microsoft.com/en-us/library/gg682077.aspx#BKMK_SupConfigSQLDBconfig">Supported Configurations for Configuration Manager</a>, secondary sites supports <strong>SQL Server Express 2008 R2 with SP1 and Cumulative Update 4</strong>. So I downloaded <a href="http://www.microsoft.com/download/en/details.aspx?id=26729">SQL Server 2008 R2 Express With SP1 with Tools (SQLEXPRWT_x64_ENU.exe)</a> and <a href="http://support.microsoft.com/kb/2633146">SQL 2008 R2 Service Pack 1 Cumulative Update 4</a> and installed them in order on my secondary site site server.

Below is what I have customised during the SQL express install:
<ul>
	<li>I configured the location for SQL, SQL instance, data files, log files and backup files the way I wanted it.</li>
	<li>I selected the SQL instance to use the collation "<strong>SQL_Latin1_General_CP1_CI_AS</strong>"<strong> </strong>because it is the only collation that SCCM supports.</li>
	<li>I kept the default secondary site SQL instance name "<strong>CONFIGMGRSEC</strong>" (this name is what’s used if you choose SCCM to install SQL Express for you).</li>
	<li>I have given a pre-configured AD group called "ConfigMgr2012 Servers" which contains all SCCM 2012 site servers <strong>sysadmin</strong> rights in SQL Express.</li>
</ul>
After the install, I applied CU4 and all went pretty smoothly.

Now, I tried to push Secondary Site install from the primary site. Under SQL Server setting step, I selected "<strong>Use an existing SQL Server instance</strong>" option and enter the secondary site server’s FQDN under "<strong>SQL server fully qualified domain name</strong>" and "CONFIGMGRSEC" under "<strong>SQL server instance name, if applicable</strong>". After finishing the wizard, the secondary site install failed during prerequisite checks. I got few errors in regards to the SQL collation is not set to SQL_Latin1_General_CP1_CI-AS:

<a href="http://blog.tyang.org/wp-content/uploads/2012/04/image.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/04/image_thumb.png" alt="image" width="580" height="167" border="0" /></a>

This is very strange because all my SQL instances in this hierarchy are set to this collation, and because of this, the setup did not even get kicked off.

Additionally, I also found the following:
<ul>
	<li>On the primary site server, in the ConfigMgrSetup.log under System root, I get the following errors:</li>
<ul>
	<li>CSql Error: Cannot find type data, cannot get a connection.</li>
	<li>[08001][17][Microsoft][ODBC SQL Server Driver][DBNETLIB]SQL Server does not exist or access denied.</li>
	<li>I could use the SQL management studio from Secondary site server to connect to the SQL express instance, but I couldn’t use the SQL management studio from a remote machine to connect to it:</li>
</ul>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2012/04/image1.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/04/image_thumb1.png" alt="image" width="574" height="177" border="0" /></a>

After spending some time troubleshooting, I got it going. Below is what I have done on the SQL Express instance:

1. I’ve assign "ConfigMgr2012 Servers" group (which I created myself and it contains the primary site server’s computer account) "<strong>dbcreator</strong>" role on top of sysadmin role it already had.

<a href="http://blog.tyang.org/wp-content/uploads/2012/04/image2.png"><img style="background-image: none; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/04/image_thumb2.png" alt="image" width="244" height="210" border="0" /></a>

2. I realised by default, after I installed SQL express, TCP/IP protocol is disabled. So I went to<strong> SQL Server Configuration Manager</strong>, under SQL <strong>Server Network Connection</strong> —&gt; Protocols for CONFIGMGRSEC—&gt;TCP/IP, enabled it. I also had to configure the ports for this connection:

I removed 0 from "TCP Dynamic Ports" for each IP and added static port 1433 under "TCP Port"

<a href="http://blog.tyang.org/wp-content/uploads/2012/04/image3.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/04/image_thumb3.png" alt="image" width="454" height="502" border="0" /></a>

After you enabled TCP/IP and changed the port, you will be prompted that you have to restart SQL server service for the change to take effect, so I restarted the SQL service.

After these steps, the prerequisite checks were passed and the Secondary site installation finished successfully.

In summary below are the steps I took to pre-configure a SQL Express instance for SCCM 2012 secondary site:
<ol>
	<li>Install SQL Express 2008 R2 with SP1 with Tools</li>
	<li>Configure SQL express install directory as per my standard (not on C:\ drive)</li>
	<li>Configure SQL Express instance name as "<strong>CONFIGMGRSEC</strong>" as it is default to SCCM secondary site and there’s no reason to change it.</li>
	<li>Select "<strong>SQL_Latin1_General_CP1_CI_AS</strong>" as SQL server collation.</li>
	<li>Configure data/logs/backups directory</li>
	<li>add primary site server’s computer account (or a group containing primary site server’s computer account) as administrator during install</li>
	<li>Apply SQL Server 2008 R2 Service Pack 1 Cumulative Update 4 after SQL Express install</li>
	<li>Set a limit for amount of memory SQL express can use.</li>
	<li>Reboot secondary site server (just to be safe)</li>
	<li>give the parent primary site server's computer account dbcreator access in SQL Express instance.</li>
	<li>Enable TCP/IP for the SQL express instance.</li>
	<li>Configure TCP/IP connection port settings.</li>
	<li>Restart SQL service.</li>
	<li>Initiate Secondary Site install from Primary site (via SCCM console). – Unlike SCCM 2007, secondary site install can no longer be performed by running SCCM setup from secondary site servers.</li>
	<li>During setup wizard, choose "Use an existing SQL Server instance", enter secondary site server’s FQDN and SQL instance name ("CONFIGMGRSEC"). leave site database name and SQL broker port as default.</li>
	<li>monitor install status using the SCCM console:</li>
</ol>
<a href="http://blog.tyang.org/wp-content/uploads/2012/04/image4.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/04/image_thumb4.png" alt="image" width="580" height="474" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2012/04/image5.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/04/image_thumb5.png" alt="image" width="580" height="405" border="0" /></a>

You can also check:
<ul>
	<li>C:\ConfigMgrSetup.log on Primary Site server (contains details for Secondary Site install’s prerequisite checks).</li>
	<li>C:\ConfigMgrSetup.log on Secondary Site server (contains details for the actual setup).</li>
</ul>
Now, instead of having SQL Express installed and configured by SCCM, I have more control of it so I can align the configuration with my organisation’s standard (if it’s in a real production environment <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" src="http://blog.tyang.org/wp-content/uploads/2012/04/wlEmoticon-smile.png" alt="Smile" />).

In this case, I have my SQL data file located under F:\SQL_Data\Microsoft SQL Server\MSSQL10_50.CONFIGMGRSEC\MSSQL\DATA:

<a href="http://blog.tyang.org/wp-content/uploads/2012/04/image6.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/04/image_thumb6.png" alt="image" width="580" height="275" border="0" /></a>

And log files under G:\SQL_Logs\Microsoft SQL Server\MSSQL10_50.CONFIGMGRSEC\MSSQL\Data:

<a href="http://blog.tyang.org/wp-content/uploads/2012/04/image7.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/04/image_thumb7.png" alt="image" width="580" height="239" border="0" /></a>