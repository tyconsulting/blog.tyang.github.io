---
id: 2311
title: Event 18054 Logged by SQL After OpsMgr Data Warehouse DB Move/Restore
date: 2013-12-24T10:39:36+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=2311
permalink: /2013/12/24/event-18054-logged-sql-opsmgr-data-warehouse-db-moverestore/
categories:
  - SCOM
tags:
  - SCOM
  - SCOM Database
---
Couple of weeks ago, we had to completely rebuild a SQL server hosting OpsMgr 2012 R2 Data Warehouse DB (reinstall OS, SQL, etc). After I restored the OperationsManagerDW database from the backup, the following error was logged to the Application Event log by SQL every minute:

<a href="https://blog.tyang.org/wp-content/uploads/2013/12/image12.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2013/12/image_thumb12.png" width="572" height="394" border="0" /></a>

<span style="color: #ff0000;"><em>Error 777971002, severity 14, state 10 was raised, but no message with that error number was found in sys.messages. If error is larger than 50000, make sure the user-defined message is added using sp_addmessage.</em></span>

Many people have already blogged this issue after moving / restoring the OpsMgr Operational DB (OperationsManager). i.e.

<a href="http://blogs.technet.com/b/kevinholman/archive/2010/10/26/after-moving-your-operationsmanager-database-you-might-find-event-18054-errors-in-the-sql-server-application-log.aspx">http://blogs.technet.com/b/kevinholman/archive/2010/10/26/after-moving-your-operationsmanager-database-you-might-find-event-18054-errors-in-the-sql-server-application-log.aspx</a>

<a href="http://blogs.technet.com/b/mgoedtel/archive/2007/08/06/update-to-moving-operationsmanager-database-steps.aspx">http://blogs.technet.com/b/mgoedtel/archive/2007/08/06/update-to-moving-operationsmanager-database-steps.aspx</a>

but I could find any solutions for the Data Warehouse DB. Luckily, this article from Marnix Wolf pointed me to the right direction:

<a href="http://thoughtsonopsmgr.blogspot.com.au/2012/10/moving-om12-operations-database-dont.html">Moving the OM12 Operations Database: Don’t Forget The Master Database</a>

Basically, Marnix managed to find the SQL script from the installation media to create the custom SQL messages to the master DB.

After only few minutes, I managed to find the section of the SQL script to create these SQL messages for the Data Warehouse DB from the OpsMgr 2012 R2 install media as well.

the SQL script is located at: <strong>"&lt;Install media&gt;\setup\AMD64\Datawarehouse.Initial.Setup.sql</strong>"

the section I need to run is at the very end of this long SQL script (starting from line 17931 to the end of the script, which is line 18055)

<a href="https://blog.tyang.org/wp-content/uploads/2013/12/SNAGHTML65dd07.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML65dd07" alt="SNAGHTML65dd07" src="https://blog.tyang.org/wp-content/uploads/2013/12/SNAGHTML65dd07_thumb.png" width="580" height="627" border="0" /></a>

<a href="https://blog.tyang.org/wp-content/uploads/2013/12/SNAGHTML6bc0d0.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML6bc0d0" alt="SNAGHTML6bc0d0" src="https://blog.tyang.org/wp-content/uploads/2013/12/SNAGHTML6bc0d0_thumb.png" width="580" height="627" border="0" /></a>

I copied and pasted this section into SQL management studio and executed it against the <strong>master</strong> database. This has stopped the Event 18054 in the application log.

Since this SQL script is an intellectual property of Microsoft, I won’t post it in this article. You should be able to easily find it from the installation media.