---
id: 2041
title: OpsMgr Self Maintenance Management Pack Version 2.0.0.0
date: 2013-08-04T16:04:09+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=2041
permalink: /2013/08/04/opsmgr-self-maintenance-management-pack-version-2-0-0-0/
categories:
  - SCOM
tags:
  - Featured
  - MP Authoring
  - SCOM
---
I have published the <a href="https://blog.tyang.org/2013/03/03/opsmgr-self-maintenance-management-pack/">OpsMgr Self Maintenance Management Pack Version 1.0</a> on this blog few months ago. Over the last couple of month, I’ve been working on the version 2.0.0.0 of this MP during my spare time.

It has taken a lot longer than I thought because it was hard for me to find blocks of spare time to sit down and work on it. It is now complete and the list below is what has been added / changed in the version 2.0.0.0:

* A rule that detects user-defined overrides in the Default MP

![](https://blog.tyang.org/wp-content/uploads/2013/08/image.png)

* A rule that configures failover management servers for Windows agents.
* Agent Task: Check Data Warehouse Retention

![](https://blog.tyang.org/wp-content/uploads/2013/08/image1.png)

![](https://blog.tyang.org/wp-content/uploads/2013/08/image2.png)

* 2 monitors that monitor Data Warehouse Hourly and Daily aggregation process. (Adopted from [Michel Kamp’s blog post](http://michelkamp.wordpress.com/2013/03/24/get-a-grip-on-the-dwh-aggregations/))
* Data Warehouse Database Aggregation Process Performance Collection Rule. This rule collects number of outstanding data sets that are yet to be processed by DW hourly and daily aggregation process. (This rule uses the same data source as above mentioned monitors.)
* Bug Fixes:

* The Remove Disabled Discovery Objects rule in the OpsMgr 2012 version of the MP were configured incorrectly in version 1.0 and it was using the script designed for OpsMgr 2007 R2.
* The scripts used in the balancing agents rules (in both OpsMgr 2012 and OpsMgr 2007 versions) had a spelling mistake in one of the variables.

* Updated the Close Aged Rule Generated Alerts Rule with an additional configurable option. The original rule uses the TimeRaised property of the alert. It now can be configured to use LastModified date if desired.

![](https://blog.tyang.org/wp-content/uploads/2013/08/image3.png)

* State Views:

  * RMS Emulator
  * Management Servers
  * All Management Server Resource Pool
  * Unhealthy Health Service Watchers

* Performance View for the performance collection rule mentioned above for Data Warehouse Data sets.

![](https://blog.tyang.org/wp-content/uploads/2013/08/image4.png)

Due to time constrains and the age of OpsMgr 2007 R2, I have decided not to update the OpsMgr 2007 version of the MP. However, the bug in the balancing agent rule mentioned above has been fixed in the OpsMgr 2007 R2 version. Other than this bug fix, all of above mentioned changes have only been updated in the 2012 version.

Since the Version 1.0 of the MP has been released, I have received many positive feedbacks. Some of the additions / changes came from suggestions from the community.

Cameron Fuller mentioned this MP in his [MVP Pro Speaker presentation](http://blogs.technet.com/b/momteam/archive/2013/05/23/mvp-cameron-fuller-presents-operations-manager-evolution-taking-your-operations-manager-to-the-next-level.aspx). One thing Cameron mentioned was to add state views for various classes that agent tasks are targeting – to make it more user friendly for OpsMgr operators to run agent tasks.

Ian Blyth emailed me and suggested to update the "Close Aged Rule Generated Alert Rule" to include an option for using LastModified date instead.

Dan Kregor suggested me to create a view for "grey agents" – Hence Unhealthy Health Service Watchers state view.

I’ve asked Michel Kamp if it is OK to include the DW aggregations workflows from his [blog post](http://michelkamp.wordpress.com/2013/03/24/get-a-grip-on-the-dwh-aggregations/) in this MP. Michel was happy for me to use his idea. So special thanks to Michel for his excellent post. Since Michel did not post the finishing piece of his MP workflows in the blog post, I have make some changes from his blog post:

* The PowerShell script from Michel’s post requires SQL Server module. I have removed such requirement in the script in this MP.
* The Data Source module from Michel’s post contains a condition detection member module to map property bag value to performance data. I have taken this condition detection module out of data source module so I can configure the "On-Demand Detection" for the monitor type. – Which is an addition to Michel’s monitor type module.

The "Get DW Retention" agent task simply calls the [dwdatarp.exe](http://blogs.technet.com/b/momteam/archive/2008/05/14/data-warehouse-data-retention-policy-dwdatarp-exe.aspx). Dwdatarp.exe is embedded as a binary resource in the MP. therefore this version of the management pack comes with a .mpb (Management Pack Bundle) file.

I have documented detailed configurations of all workflows in the documentation of this MP, including a list of all event log entries generated by scripts within this MP. There is also a known issue when creating your own override MP in OpsMgr operations console. This issue and workaround is also documented in the documentation.

Please click [HERE](https://cookdown.com/scom-essentials/self-maintenance) to download the Management Packs and the documentation.

As always, please feel free to contact me if there are issues or suggestions.