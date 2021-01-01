---
id: 39
title: Using SCOM to Automatically Stop MOM Agent Service
date: 2010-06-28T05:55:47+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=39
permalink: /2010/06/28/using-scom-to-automatically-stop-mom-agent-service/
categories:
  - SCOM
tags:
  - MOM
  - SCOM
  - SCOM Migration
  - Stopping MOM Agents
---
I'm currently working on a MOM 2005-to-SCOM 2007 migration project for a client. after months of work, we are finally ready to stop MOM service.

We created a new GPO to set MOM service (MOM agent) to "Disabled" and linked to the top of the domain. we also wanted to make sure all MOM service are actually STOPPED on domain member servers AS WELL AS standalone SCOM agents. Traditionally, I'd create a package in SMS/SCCM with a script that firstly detect if SCOM agent service (HealthService) is running, and secondly, if so, stop MOM service. However, this particular client I'm currently working for does not have SCCM infrastructure for their servers. I didn't want to run a script to go out stop the MOM service on all servers because there are firewalls located in different segments of the network and running a script does not ENFORCE this setting...

To achieve my objective, I have created a basic service unit monitor in SCOM to detect the status of MOM service and created a recovery task for this monitor. The monitor generates an alert if MOM service is running and Recovery task will be executed to stop MOM service!

<a href="http://blog.tyang.org/wp-content/uploads/2010/06/Authoring.The_.Mornitor.jpg"><img class="size-full wp-image-52 alignnone" src="http://blog.tyang.org/wp-content/uploads/2010/06/Authoring.The_.Mornitor.jpg" alt="" width="818" height="149" /></a>

Below is what I've done:

1. Create a basic service monitor targeting Windows Operating System:

<a href="http://blog.tyang.org/wp-content/uploads/2010/06/Monitor.Properties.General.jpg"><img class="size-medium wp-image-40 alignnone" src="http://blog.tyang.org/wp-content/uploads/2010/06/Monitor.Properties.General-295x300.jpg" alt="" width="295" height="300" /></a>

This monitor is targeting MOM service

<a href="http://blog.tyang.org/wp-content/uploads/2010/06/Monitor.Properties.Service.Details.jpg"><img class="size-medium wp-image-41 alignnone" src="http://blog.tyang.org/wp-content/uploads/2010/06/Monitor.Properties.Service.Details-300x108.jpg" alt="" width="300" height="108" /></a>

If the service is NOT running, the health state is considered as healthy, otherwise, it is in warning state

<a href="http://blog.tyang.org/wp-content/uploads/2010/06/Monitor.Properties.Health.jpg"><img class="size-medium wp-image-42 alignnone" src="http://blog.tyang.org/wp-content/uploads/2010/06/Monitor.Properties.Health-300x129.jpg" alt="" width="300" height="129" /></a>

We only subscribe to critical and warning alerts, I didn't want get too much attention so I configured the alert severity to only Information:

<a href="http://blog.tyang.org/wp-content/uploads/2010/06/Monitor.Properties.Alerting.jpg"><img class="size-medium wp-image-43 alignnone" src="http://blog.tyang.org/wp-content/uploads/2010/06/Monitor.Properties.Alerting-295x300.jpg" alt="" width="295" height="300" /></a>

Lastly, I created a diagnostic and a recovery task associated to this monitor.

<a href="http://blog.tyang.org/wp-content/uploads/2010/06/Monitor.Properties.Diagnostic.and_.Recovery.jpg"><img class="size-medium wp-image-44 alignnone" src="http://blog.tyang.org/wp-content/uploads/2010/06/Monitor.Properties.Diagnostic.and_.Recovery-294x300.jpg" alt="" width="294" height="300" /></a>

The Diagnostic task is simply checking the state of MOM service:

<a href="http://blog.tyang.org/wp-content/uploads/2010/06/Diagnostic.Task_.Properties.Command.Line_.jpg"><img class="size-medium wp-image-45 alignnone" src="http://blog.tyang.org/wp-content/uploads/2010/06/Diagnostic.Task_.Properties.Command.Line_-300x202.jpg" alt="" width="300" height="202" /></a>

And the recovery task stops MOM service:

<a href="http://blog.tyang.org/wp-content/uploads/2010/06/Recovery.Task_.Properties.Command.Line_.jpg"><img class="size-medium wp-image-46 alignnone" src="http://blog.tyang.org/wp-content/uploads/2010/06/Recovery.Task_.Properties.Command.Line_-300x224.jpg" alt="" width="300" height="224" /></a>

So now the monitor is created. note from the first screen shot, I did not enable this monitor. I wanted to test it first! So I created an override to only enable it to a particular Windows 2003 server.

After few minutes, I could see the health state change in Health Explorer:

<a href="http://blog.tyang.org/wp-content/uploads/2010/06/State.Change.jpg"><img class="size-medium wp-image-47 alignnone" src="http://blog.tyang.org/wp-content/uploads/2010/06/State.Change-300x203.jpg" alt="" width="300" height="203" /></a>

1 minute after the health state changed from Healthy to Warning, it changed back to Healthy - because the recovery task kicked in and stopped MOM service. Below are the results from Diagnostic and Recovery Tasks:

Diagnostic Task:

<a href="http://blog.tyang.org/wp-content/uploads/2010/06/Diagnostic.Task_.Result.jpg"><img class="size-medium wp-image-48 alignnone" src="http://blog.tyang.org/wp-content/uploads/2010/06/Diagnostic.Task_.Result-300x184.jpg" alt="" width="300" height="184" /></a>

Recovery Task:

<a href="http://blog.tyang.org/wp-content/uploads/2010/06/Recovery.Task_.Result.jpg"><img class="size-medium wp-image-49 alignnone" src="http://blog.tyang.org/wp-content/uploads/2010/06/Recovery.Task_.Result-300x133.jpg" alt="" width="300" height="133" /></a>

And now, the alert is automatically closed:

<a href="http://blog.tyang.org/wp-content/uploads/2010/06/Alert.From_.Web_.Console1.jpg"><img class="size-large wp-image-51 alignnone" src="http://blog.tyang.org/wp-content/uploads/2010/06/Alert.From_.Web_.Console1-1024x492.jpg" alt="" width="580" height="278" /></a>

I logged on to the target server, checked MOM service, it is stopped:

<a href="http://blog.tyang.org/wp-content/uploads/2010/06/MOM.Service.Status.jpg"><img class="size-full wp-image-53 alignnone" src="http://blog.tyang.org/wp-content/uploads/2010/06/MOM.Service.Status.jpg" alt="" width="432" height="17" /></a>

Now, I can go ahead and enable this monitor!