---
id: 2064
title: 'ConfigMgr Report: Total Number of Packages Per Distribution Point'
date: 2013-08-20T14:36:07+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=2064
permalink: /2013/08/20/configmgr-report-total-number-of-packages-per-distribution-point/
categories:
  - SCCM
tags:
  - SCCM Reports
---
Today I had to create a report in ConfigMgr to list total number of packages that have been assigned to each Distribution Point. The SQL query is rather simple, a one-liner. Here’s the query:
```sql
select ServerNALPath, COUNT (PackageID) As PackageCount from v_DistributionPoint group by ServerNALPath order by PackageCount
```
This query works on both ConfigMgr 2007 and 2012.

<strong>ConfigMgr 2007 Report:</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2013/08/image9.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/08/image_thumb9.png" width="580" height="302" border="0" /></a>

<strong>ConfigMgr 2012 Report:</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2013/08/image10.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/08/image_thumb10.png" width="580" height="400" border="0" /></a>