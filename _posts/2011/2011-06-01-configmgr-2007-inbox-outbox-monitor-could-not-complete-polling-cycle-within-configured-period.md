---
id: 557
title: 'ConfigMgr 2007 Inbox (Outbox) Monitor: Could not complete polling cycle within configured period'
date: 2011-06-01T13:57:11+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=557
permalink: /2011/06/01/configmgr-2007-inbox-outbox-monitor-could-not-complete-polling-cycle-within-configured-period/
categories:
  - SCCM
tags:
  - Daylight Saving
  - SCCM
  - SCCM Inbox monitor
  - SCCM Status Messages
---
Starting few weeks ago, In the SCCM environment which I support, all site servers located in one country started generating status messages similar to below every 15 minutes:

<em><strong>SMS Inbox Monitor took 3627 seconds to complete a cycle.  This exceeds its configured interval of 900 seconds by 2727 seconds.</strong></em>

<a href="http://blog.tyang.org/wp-content/uploads/2011/06/image.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/06/image_thumb.png" border="0" alt="image" width="506" height="499" /></a>

These messages are also logged in Site server’s application log. SCOM also detects it and generated warning alerts:

<a href="http://blog.tyang.org/wp-content/uploads/2011/06/image1.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/06/image_thumb1.png" border="0" alt="image" width="567" height="649" /></a>

&nbsp;

After reviewing inboxmgr.log, I noticed the time stamp for the log entries was <strong>1 hour</strong> ahead of the system time. This also happens to the other SCCM log files. I then noticed the day light saving for that particular time zone has ended few weeks ago and the SCCM services has not been restarted since then.

<strong>Cause</strong>: SCCM services have not been restarted since system time changed.

<strong>Solution</strong>: I restarted SMS_EXECUTIVE and SMS_SITE_COMPONENT_MANAGER services on affected site servers. and the system has stopped generating these messages. and time stamp for status messages are now back to normal.