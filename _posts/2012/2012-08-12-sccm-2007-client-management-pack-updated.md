---
id: 1341
title: SCCM 2007 Client Management Pack Updated
date: 2012-08-12T14:29:19+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=1341
permalink: /2012/08/12/sccm-2007-client-management-pack-updated/
categories:
  - SCCM
  - SCOM
tags:
  - MP Authoring
  - SCCM
  - SCOM
---
I received an email this morning regarding to the <a href="http://blog.tyang.org/2012/03/04/system-center-configuration-manager-sccm-2007-client-management-pack-for-scom/">SCCM 2007 Client Management Pack</a> that I wrote few months ago. Someone pointed out it had some issues in the language packs section of the MP. I had a look and realised the TYANG.System.Center.Configuration.Manager.2007.Monitoring.mp does have some orphaned string resources.

A bit background of this MP. I originally wrote this MP for my employer. Before I posted it on my blog, I removed everything that were specfic to my employer (few monitors, application components, relationships, discoveries, etc.). However, I ddin't delete associated display string resources in here:

<img src="http://blog.tyang.org/wp-content/uploads/2012/08/C9778810F9B77839DC5EDB092E6C0AF7B13047DF.png" alt="" width="467" height="346" border="0" />

I have just updated the MP (and increased the version number to 2.0.0.1).

The updated MP can be downloaded <a href="http://blog.tyang.org/wp-content/uploads/2012/08/TYANG.System.Center.Configuration.Manager.2007.Client.MP_.zip">HERE</a>.

I'll also update the download link on the original post.