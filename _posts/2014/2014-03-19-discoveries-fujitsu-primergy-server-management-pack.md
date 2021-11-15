---
id: 2413
title: Discoveries in Fujitsu PRIMERGY Server Management Pack
date: 2014-03-19T13:38:28+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=2413
permalink: /2014/03/19/discoveries-fujitsu-primergy-server-management-pack/
categories:
  - SCOM
tags:
  - MP Authoring
  - SCOM
---
I have been dealing this the Fujitsu PRIMERGY Server MP from Fujitsu ever since I started working for my current employer about 2.5 years ago. We found many issues with the previous version back in SCOM 2007 days and now as I’m setting up SCOM 2012 R2 management groups and having to implement the latest version 6.0.0.5, I believe there are still lots of rooms for improvement. I’ll only discuss discoveries in this blog article.

Other than the group populators, there is only one discovery workflow that discovers PRIMERGY servers as well as all other server components. This discovery runs a long VBScript (I counted, it has 5798 lines of code) on all Windows Server computers, every 1 hour by default. It breaks almost all the MP discovery best practices that I can think of.

<a href="https://blog.tyang.org/wp-content/uploads/2014/03/image4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2014/03/image_thumb4.png" width="580" height="263" border="0" /></a>

<strong>Discoveries are not staged</strong>

The MP should have included a simple top level registry based discovery to discover if the server is a Fujitsu server and then target all subsequent discoveries to the Fujitsu server that’s been discovered by the top level registry discovery.

<strong>Target is too generic</strong>

Targeting a script discovery to all server computers is a bad idea. nowadays, in most of environments, there are more virtual servers than physical servers. Why would I want to run this discovery to discover Fujitsu servers <strong>AS WELL AS</strong> all other server components on my virtual servers when clearly they are not going to be a Fujitsu server?

<strong>Single discovery for multiple classes</strong>

As you can see from the screenshot above, the discovery discovers 14 items. This has made impossible to disable discovery for any individual components.

In the previous version of MP (version 4), the script also discovers the actual temperature from various temperature sensors. I'm not sure why these data is required to be stored as properties of the server and it is a bad idea because it’s very unlikely that the temperature stays the same over a long period of time (i.e. 28.1 degrees now and 28.2 degrees an hour later). This has caused us a big issue when we realised few thousands Fujitsu servers were resubmitting discovery data every hour (config churn) in our SCOM 2007 environments. We couldn’t do anything about it if we want to keep the integrity of the vendor supported MP, because we can’t just disable the discovery for this particular component without actually modifying the VBScript in the discovery data source. In the end, we had to get Fujitsu to update script in the MP and seal it with their key to get around this issue.

In the current version (version 6), looks like they’ve kept this modification in the script:

<a href="https://blog.tyang.org/wp-content/uploads/2014/03/image5.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2014/03/image_thumb5.png" width="580" height="210" border="0" /></a>

<strong>Script based discovery runs too frequent (once an hour)</strong>

According to Microsoft’s <a href="https://social.technet.microsoft.com/wiki/contents/articles/14260.operations-manager-management-pack-authoring-discovery.aspx">best practise</a>, script discoveries should have a minimum interval of 4 hours (and should not target a broad class). Not to mention the script for this discovery is almost 6000 lines long!

In order to overcome these issues, I have created an additional addendum MP. Below is a list of what I’ve done in this addendum MP:

1. Created a custom class called "Fujitsu Server Computer (Addendum MP)".

2. Create a registry based discovery for the "Fujitsu Server Computer (Addendum MP)". This discovery is based on "<strong>HKLM\System\CurrentControlSet\Control\SystemInformation\SystemManufacturer</strong>" regkey value.

<a href="https://blog.tyang.org/wp-content/uploads/2014/03/image6.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2014/03/image_thumb6.png" width="580" height="244" border="0" /></a>

3. Created a group for all instances of "Fujitsu Server Computer (Addendum MP)" class.

4. Created an override to disable the original discovery from Fujitsu MP ( called "PRIMERGY Server Discovery Rule").

5. Created an override to enable the original discovery for the group I created in the previous step.

6. Created an override to change the interval from 3600 seconds (1 hour) to 43200 seconds (12 hours).

This addendum MP can be downloaded <strong><a href="https://blog.tyang.org/wp-content/uploads/2014/03/Fujitsu.Servers.PRIMERGY.Addendum.xml_.zip">HERE</a></strong>. I recommend anyone who’s using the Fujitsu PRIMERGY Server MP to take a look.

Lastly, the intention of this blog post is not to criticise Fujitsu, but rather making effort to make this MP better. Honestly, based on my own experience, Fujitsu has been pretty good listening to their customers and I am happy that they have rolled up the temperature sensor discovery changes to the new MP.