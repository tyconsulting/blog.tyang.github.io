---
id: 1694
title: Installing SCCM 2012 SP1 Secondary Site with a Pre-Configured SQL 2012 Instance
date: 2013-01-23T11:09:01+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=1694
permalink: /2013/01/23/installing-sccm-2012-sp1-secondary-site-with-a-pre-configured-sql-2012-instance/
categories:
  - SCCM
tags:
  - SCCM
  - Secondary Site
---
Over the last week, I’ve been re-installing my SCCM lab environment to SCCM 2012 SP1. I’m using Windows Server 2012 as the base OS for all site system roles and all database engines and SQL reporting server run on SQL 2012.

I got stuck few days ago when I was building my first secondary site. I was trying to use a pre-installed SQL 2012 Express With SP1 instance for the secondary site database. I followed the instruction that I have previously blogged for SQL Express 2008 R2: <a title="http://blog.tyang.org/2012/04/09/installing-sccm-2012-rtm-secondary-site-using-a-pre-installed-sql-express-2008-r2-instance/" href="http://blog.tyang.org/2012/04/09/installing-sccm-2012-rtm-secondary-site-using-a-pre-installed-sql-express-2008-r2-instance/">http://blog.tyang.org/2012/04/09/installing-sccm-2012-rtm-secondary-site-using-a-pre-installed-sql-express-2008-r2-instance/</a>

After I installed and configured the SQL express instance for the secondary site, I started the secondary site install (from the parent primary site). However, I was keep getting this error during the prerequisites check:

<span style="color: #ff0000;"><strong>SQL server sysadmin rights:</strong></span>

<span style="color: #ff0000;"><em>Either the user account running Configuration Manager Setup does not have sysadmin SQL Server role permission on the SQL Server instance selected for site database installation, or the SQL Server instance could not be contacted to verify permissions. Setup cannot continue.</em></span>

<span style="color: #000000;">Prerequisite check result:</span>

<a href="http://blog.tyang.org/wp-content/uploads/2013/01/clip_image001.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="clip_image001" alt="clip_image001" src="http://blog.tyang.org/wp-content/uploads/2013/01/clip_image001_thumb.png" width="580" height="397" border="0" /></a>

<span style="color: #000000;">ConfigMgrPrereq.log:</span>

<a href="http://blog.tyang.org/wp-content/uploads/2013/01/clip_image0016.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="clip_image001[6]" alt="clip_image001[6]" src="http://blog.tyang.org/wp-content/uploads/2013/01/clip_image0016_thumb.png" width="580" height="321" border="0" /></a>

The error suggested that my account does not have sysadmin rights. In fact, both my user account and the site server computer account have sysadmin and dbcreator rights in that SQL 2012 instance.

I then tried few different SQL configurations, including using default instance rather than named instance (CONFIGMGRSEC), and using SQL 2012 Enterprise rather than Express edition, they made no difference. I then installed SQL 2008 R2 Express With SP2 (with exact same configuration in terms of security, collation, using named instance, enabling SQL Server Browser service, etc). and the pre-requisite checks passed and secondary site got successfully installed.

After I compared settings in SQL 2008 R2 and the SQL 2012 Express instance I had installed on another secondary site server, I found the issue:

During SQL 2012 install, the sysadmin rights was not granted to the local system account (NT AUTHORITY\SYSTEM). In SQL 2008 R2, "NT AUTHORITY\SYSTEM" account by default has sysadmin rights. During the prerequisites check, SCCM installs a series of services on the target secondary site server to perform the checks. these services are installed to run under LOCALSYSTEM account. The SQL sysadmin rights check failed because the LOCALSYSTEM account does not have sysadmin rights as it was running under LOCALSYSTEM account. To a degree, the error message is somewhat misleading in my opinion.

i.e. system event log entry for one of the services installed by prerequisites check:

<a href="http://blog.tyang.org/wp-content/uploads/2013/01/image.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/01/image_thumb.png" width="578" height="403" border="0" /></a>

<strong><span style="text-decoration: underline;">So to fix the issue, I simply gave "NT AUTHORITY\SYSTEM" account the same access in SQL 2012 as in SQL 2008 R2:</span></strong>

<strong>sysadmin</strong> and <strong>securityadmin</strong> role:

<a href="http://blog.tyang.org/wp-content/uploads/2013/01/clip_image0018.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="clip_image001[8]" alt="clip_image001[8]" src="http://blog.tyang.org/wp-content/uploads/2013/01/clip_image0018_thumb.png" width="541" height="490" border="0" /></a>

To summarise, when installing SCCM 2012 SP1 secondary site on a pre-configured SQL 2012 instance regardless which SQL edition is being used, "NT AUTHORITY\SYSTEM" account needs to be given <strong>securityadmin </strong>and <strong>sysadmin</strong> rights. If SQL Express is used, there are few additional steps need to be carried out to configure the SQL TCP connection as documented in my previous blog: <a title="http://blog.tyang.org/2012/04/09/installing-sccm-2012-rtm-secondary-site-using-a-pre-installed-sql-express-2008-r2-instance/" href="http://blog.tyang.org/2012/04/09/installing-sccm-2012-rtm-secondary-site-using-a-pre-installed-sql-express-2008-r2-instance/">http://blog.tyang.org/2012/04/09/installing-sccm-2012-rtm-secondary-site-using-a-pre-installed-sql-express-2008-r2-instance/</a>