---
id: 2456
title: SQL DB Engines Not Discovered in SCOM and My Troubleshooting Experiences
date: 2014-04-03T15:24:02+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=2456
permalink: /2014/04/03/sql-db-engines-discovered-scom-troubleshooting-experiences/
categories:
  - SCOM
tags:
  - SCOM
---
Few days ago while I was in the OpsMgr 2012 console, I realised that all 3 SQL clusters hosting my OpsMgr Ops DBs are not discovered by MS SQL management packs. All other SQL clusters with same version of SQL got discovered (i.e. clusters hosting ConfigMgr 2012 site databases, etc.).

Since I backup both sealed and unsealed MPs using my OpsMgr Self Maintenance MP, I went grabbed a unsealed copy (exported to .xml) of "Microsoft.Windows.Server.2012.Discovery" MP, extracted the discovery script "DiscoverSQL2012DBEngineDiscovery.vbs" and tried to run manually on the active node of one of the problematic SQL cluster. the script failed. So I added few lines of "Wscript.Echo" to break the scripts up and identified it failed at this line:

<a href="https://blog.tyang.org/wp-content/uploads/2014/04/image3.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2014/04/image_thumb3.png" width="519" height="180" border="0" /></a>

So next, I went to check the SQL Full-Text Filter Daemon Launcher service and realised it is set to manual and I can’t start it. I got an "Access is Denied" error.

<a href="https://blog.tyang.org/wp-content/uploads/2014/04/image4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2014/04/image_thumb4.png" width="537" height="228" border="0" /></a>

I confirmed this service is running on all other working SQL clusters. So I went to the Windows engineer who built this SQL cluster. After some troubleshooting, the Windows engineer told me it is caused by a GPO that he created for all SCOM SQL servers.

In the GPO, he restricted permission for this service and also modified NTFS permissions for the root folder of where SQL is installed to. Somehow these settings has caused the SQL Full-text Filter Daemon Launcher services to fail to start, while the SQL DB engines are running fine and we had no issues with the SCOM databases.

In the end, after all the GPO settings are reverted back, rebooted all cluster nodes. I waited overnight and checked again next day. all SQL DB engines have been discovered in SCOM. I could also manually run the discovery script on the active cluster node:

<a href="https://blog.tyang.org/wp-content/uploads/2014/04/image5.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2014/04/image_thumb5.png" width="580" height="184" border="0" /></a>