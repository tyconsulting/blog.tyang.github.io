---
id: 4448
title: OpsMgr Alert Console Task For Squared Up
date: 2015-08-31T13:33:43+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=4448
permalink: /2015/08/31/opsmgr-alert-console-task-for-squared-up/
categories:
  - SCOM
tags:
  - Management Pack
  - SCOM
  - SquaredUp
---
I have just created 2 alert console tasks in OpsMgr for Squared Up:

* View Alert in Squared Up
* View Alert Source Object in Squared Up

<a href="http://blog.tyang.org/wp-content/uploads/2015/08/SNAGHTML7c0f76d.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML7c0f76d" src="http://blog.tyang.org/wp-content/uploads/2015/08/SNAGHTML7c0f76d_thumb.png" alt="SNAGHTML7c0f76d" width="546" height="293" border="0" /></a>

These 2 tasks will open the selected alert and alert source object in Squared Up  respectively using your default browser:

Squared Up Alert View:

<a href="http://blog.tyang.org/wp-content/uploads/2015/08/image39.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/08/image_thumb39.png" alt="image" width="538" height="372" border="0" /></a>

Squared Up Monitoring Object view (Alert Source Object):

<a href="http://blog.tyang.org/wp-content/uploads/2015/08/image40.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/08/image_thumb40.png" alt="image" width="533" height="368" border="0" /></a>

the management pack containing these 2 tasks can be downloaded at the end of this article. In order to use this MP, you will need to modify 2 lines:

<a href="http://blog.tyang.org/wp-content/uploads/2015/08/image41.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/08/image_thumb41.png" alt="image" width="677" height="335" border="0" /></a>

You need to open the unsealed MP (xml) in a text editor (such as Notepad++), and modify line 29 and 38 (as shown above). Please replace "http://Your-SquaredUp-URL" with the Squared Up URL in your environment. i.e.

<a href="http://blog.tyang.org/wp-content/uploads/2015/08/image42.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/08/image_thumb42.png" alt="image" width="661" height="327" border="0" /></a>

You can download this MP from the link below:

[DOWNLOAD](../../../../wp-content/uploads/2015/06/SquaredUp.Console.Task.zip)