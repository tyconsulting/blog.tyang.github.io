---
id: 1078
title: Reports not updated in SCOM SQL Reporting Service When the Management Pack was Updated
date: 2012-03-28T17:49:13+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=1078
permalink: /2012/03/28/reports-not-updated-in-scom-sql-reporting-service-when-the-management-pack-was-updated/
categories:
  - SCOM
tags:
  - SCOM
  - SCOM Reporting
---
I ran into an issue today. I have updated a report in a management pack. After I updated the version number, sealed it and imported the updated management pack into SCOM, the report that I have modified did not get updated in SQL Reporting Service (SRS).

Generally, once a new MP is imported into a management group, within few minutes, the reports within the MP should be deployed to SRS. This was the case when I updated the very same MP in Development environment, but in Production, I waited few hours and nothing has happened.

After few hours, I finally fix the issue.

For any reports that have been deployed as part of a MP, there should be a .mp file in the SRS folder, like this one:

<a href="http://blog.tyang.org/wp-content/uploads/2012/03/image4.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/03/image_thumb4.png" alt="image" width="580" height="258" border="0" /></a>

In the production environment, the .mp file name from my management pack folder in SRS is different than the one in development environment. I checked other management packs in both Prod and Dev and they all have the same .mp file name.

<strong>To fix the issue:</strong> I deleted the .mp file from SRS, restarted the SRS service. Within one minute, the updated report got deployed to SCOM SQL Reporting Service and the .mp file got recreated as well.