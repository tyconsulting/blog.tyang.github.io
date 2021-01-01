---
id: 6429
title: When Squared Up meets Windows Admin Center
date: 2018-05-04T09:44:14+10:00
author: Tao Yang
layout: post
guid: https://blog.tyang.org/?p=6429
permalink: /2018/05/04/when-squared-up-meets-windows-admin-center/
categories:
  - SCOM
  - Windows
tags:
  - SquaredUp
  - Windows Admin Center
---
I have been in the private preview for Project Honolulu (now called Windows Admin Center) for quite long time before it became GA and I am a big fan of it. I have also been a long time Squared Up fan, and I was one of their very first customers at my previous job.

I was really excited when Squared Up asked me to test their integration with Windows Admin Center couple of weeks ago. To me, it makes perfect sense if you have already deployed Windows Admin Center and are also using SCOM and Squared Up. Since Windows Admin Center is designed to replace various administrative tools for Windows, Hyper-V, failover clusters, etc., and SCOM has always been an enterprise monitoring and operational tool, the Squared Up Windows Admin Center extension surfaces the SCOM data and available tasks in the Windows Admin Center portal.

<strong>Squared Up Extension:</strong>

<a href="https://blog.tyang.org/wp-content/uploads/2018/05/image.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/05/image_thumb.png" alt="image" width="1002" height="511" border="0" /></a>

<strong>Native Windows Admin Center Overview Page:</strong>

<a href="https://blog.tyang.org/wp-content/uploads/2018/05/image-1.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/05/image_thumb-1.png" alt="image" width="1002" height="511" border="0" /></a>

As you can see, out of the box, the Squared Up page shows performance data, SCOM alerts associated to the server, health states for all the monitoring objects associated to the server.

Comparing to the native overview page, the performance counter graphs in the overview page are focused on the real-time most recent data (last 60 seconds) and updated every second. On the other hand, the perf graphs in the Squared Up extension are sourced from SCOM Data Warehouse database, which is focused on mid to long term trending, and are collected between 5-15 minutes in most cases. Depending on your SCOM Data Warehouse retention settings, generally, you can go back to 12 months!

<a href="https://blog.tyang.org/wp-content/uploads/2018/05/image-2.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/05/image_thumb-2.png" alt="image" width="905" height="740" border="0" /></a>

Windows Admin Center offers many extensions that allows you to manage Event Logs, File systems, certificate, firewall settings, services, registry, etc., and for those that are not covered by native extensions, you can use either PowerShell or Remote Desktop as the catch-all tools. But if you have already heavily invested in SCOM, and have many tasks already defined in SCOM, you can access these tasks right at the Squared Up page:

<a href="https://blog.tyang.org/wp-content/uploads/2018/05/image-3.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/05/image_thumb-3.png" alt="image" width="992" height="218" border="0" /></a>

<a href="https://blog.tyang.org/wp-content/uploads/2018/05/image-4.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/05/image_thumb-4.png" alt="image" width="953" height="598" border="0" /></a>

Furthermore, since all Squared Up dashboards are customisable, you can add / remove other widgets to the page. You can also use additional Squared Up plug-ins to connect to other systems such as SQL databases (using SQL plug-in), Azure Log Analytics and App Insights (using OMS and Azure plug-ins), or ServiceNow (using Web API plug-in).

You can find more about the Squared Up extension for Windows Admin Center at <a href="https://squaredup.com/product/honolulu/windows-admin-center-extension-customers/?utm_source=tao-yang&amp;utm_medium=public-relations&amp;utm_campaign=honolulu" target="_blank" rel="noopener">Squared Up’s website</a>.