---
id: 4940
title: Squared Up Released version 2.3
date: 2015-12-06T18:19:29+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=4940
permalink: /2015/12/06/squared-up-released-version-2-3/
categories:
  - SCOM
tags:
  - Dashboard
  - SCOM
  - SquaredUp
---
Few weeks ago, the Squared Up folks sent me the preview bits for version 2.3. I haven’t had time to play with it until today.

There have already been few posts about v2.3, i.e. the <a href="https://squaredup.com/squared-up-version-23">post</a> by Squared Up, and the <a href="https://nocentdocent.wordpress.com/2015/11/20/getting-ready-for-squared_up-version-2-3-html5-console-for-scom/">post</a> by my friend and CDM MVP <a href="https://twitter.com/DanieleGrandini">Daniele Grandini</a>.

When I was reading the feature intro that Squared Up sent me, the one feature that really stood out for me was the Open Access Dashboards. You can read the feature description from Squared Up’s post <a href="https://squaredup.com/squared-up-version-23/#open">here</a>.

So basically, once you’ve made necessary configurations to support this feature and enabled Open Access on a dashboard, the IIS that’s hosting Squared Up would generate an image of the specific dashboard (in .png format), which you can open in any browsers without having to login to Squared Up. This image will be regenerated every 60 seconds, and the URL to this image uses a randomly generated GUID (in order to hide the URL of the full blown version of the dashboard).

![](http://blog.tyang.org/wp-content/uploads/2015/12/SQUPOpenAccess.png)

In the past, I’ve worked in environments where people had to create a read-only operator in OpsMgr for having Squared Up dashboards on big LCD screens on the wall. It is an admin overhead to manage this account and the password, not to mention that I’ve also seen it many times that when managers walk past, the dashboard is sitting at the login screen on the wall LCD screens because the session was expired. It doesn’t make the team look good :worried:.

The Open Access dashboards addressed these issues, it would be a great feature for those who uses Squared Up on big screens hanging on the wall.

So if you haven’t upgraded your Squared Up instance to v2.3, I strongly recommend you to take a look at this great feature and start planning your upgrade :smiley:.