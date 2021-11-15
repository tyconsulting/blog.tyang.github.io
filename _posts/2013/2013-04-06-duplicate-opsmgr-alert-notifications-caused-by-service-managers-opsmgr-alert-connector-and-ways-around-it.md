---
id: 1851
title: 'Duplicate OpsMgr Alert Notifications Caused by Service Manager&rsquo;s OpsMgr Alert Connector And Ways Around It.'
date: 2013-04-06T13:26:44+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=1851
permalink: /2013/04/06/duplicate-opsmgr-alert-notifications-caused-by-service-managers-opsmgr-alert-connector-and-ways-around-it/
categories:
  - SCOM
tags:
  - SCOM
  - SCOM Notifications
---
<h2>Background</h2>
Few days ago, I posted an article: <a href="https://blog.tyang.org/2013/03/30/opsmgr-alerts-push-notification-to-android-devices/">OpsMgr Alerts Push Notification to Android Devices</a>. In my lab, I have created a subscription to notify me all new critical alerts using this channel:

<a href="https://blog.tyang.org/wp-content/uploads/2013/04/image.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2013/04/image_thumb.png" width="458" height="443" border="0" /></a>

In the first few days, I wasn’t paying too much attention when every time I get spammed by these push notifications on my phone, 2 days ago, I realised every new critical alerts gets pushed to my phone twice and two notifications are 1-2 minutes apart:

<a href="https://blog.tyang.org/wp-content/uploads/2013/04/image1.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2013/04/image_thumb1.png" width="435" height="464" border="0" /></a>
<h2>Cause</h2>
After some troubleshooting, I found the Service Manager’s OpsMgr Alert Connector is causing this issue. Well, I wouldn’t say it’s a fault or bug, it’s just the way that OpsMgr alert notifications handles alert.

In my lab, I have configured an OpsMgr Alert Connector in Service Manager. As a result, Service Manager updates the OpsMgr alert with a Ticket ID after the alert is generated:

<a href="https://blog.tyang.org/wp-content/uploads/2013/04/image2.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2013/04/image_thumb2.png" width="479" height="374" border="0" /></a>

And in alert history tab, you can see Service Manager updated the alert soon after it was initially raised:

<a href="https://blog.tyang.org/wp-content/uploads/2013/04/image3.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2013/04/image_thumb3.png" width="580" height="292" border="0" /></a>

Looks like this issue has been identified for a long time. some one has already posted a thread in TechNet forum back in 2009: <a href="http://social.technet.microsoft.com/Forums/en-US/operationsmanagergeneral/thread/4d2f7f8f-c616-483e-a5af-8c77f5d20953/">http://social.technet.microsoft.com/Forums/en-US/operationsmanagergeneral/thread/4d2f7f8f-c616-483e-a5af-8c77f5d20953/</a>

OpsMgr alerts get processed by notification subscriptions every time they are updated. i.e. If I take a critical alert with resolution state of "New" and set the resolution state to "New" again in the OpsMgr console, it will get processed again by subscriptions:

<a href="https://blog.tyang.org/wp-content/uploads/2013/04/image4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2013/04/image_thumb4.png" width="518" height="291" border="0" /></a>

Therefore I wouldn’t blame service manager for this issue.
<h2>Possible Solutions</h2>
I can think of 3 possible solutions:

1. Put a 3 minutes delay in the OpsMgr alert subscription since Service Manager alert connector is configured to check OpsMgr every 60 seconds.

<a href="https://blog.tyang.org/wp-content/uploads/2013/04/image5.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2013/04/image_thumb5.png" width="580" height="546" border="0" /></a>

2. add another criteria to the alert subscription: with a "%" ticket ID – which means ticket ID must match a wildcard (%).

<a href="https://blog.tyang.org/wp-content/uploads/2013/04/image6.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2013/04/image_thumb6.png" width="490" height="302" border="0" /></a>

3. Modify the criteria to notify any new critical alert <strong>WITHOUT</strong> a ticket ID.

Each option has it’s pros an cons.

Option 1 would wait Service Manager 3 minutes so it can process the alert first. However, if the alert is generated by a monitor and the monitor has a recovery task, the alert is probably already closed after 3 minutes and you will not get notified. this may not be the desired result.

Option 2 would only pick up alerts that have already been processed by Service Manager. This adds a unnecessary dependency. If for some reasons Service Manager is down, Ticket ID field in the OpsMgr alert will not get updated, therefore alert subscription will not pick up the alert.

To me, Option 3 makes most of the sense. The subscription should only pick up the "brand new" new critical alerts, before Service Manager updates the Ticket ID. – But, it’s not that easy to configure. Why? because I cannot specify conditions like "<strong>and with a NULL ticket ID</strong>" via the OpsMgr Console. As you can see below, I can only specify a wildcard match to ticket ID:

<a href="https://blog.tyang.org/wp-content/uploads/2013/04/image7.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2013/04/image_thumb7.png" width="495" height="213" border="0" /></a>

Luckily I can do this outside of the console, by directly modifying the OpsMgr "Notification Internal Library" MP. Kevin Holman has an excellent blog post on this topic: <a href="http://blogs.technet.com/b/kevinholman/archive/2008/10/12/creating-granular-alert-notifications-rule-by-rule-monitor-by-monitor.aspx">Creating granular alert notifications - rule by rule, monitor by monitor</a>.

So I’ve decided that I’m going to go for option 3. I’ll now go through the steps I took to modify the existing alert subscription.

1. Export <strong>AND BACKUP</strong> the "Notification Internal Library" MP from the OpsMgr console (Microsoft.SystemCenter.Notifications.Internal.xml)

2. Open Microsoft.SystemCenter.Notifications.Internal.xml with a text editor (i.e. <a href="http://notepad-plus-plus.org/">Notepad++</a>).

3. Towards the end of the file, in the &lt;LanguagePack&gt; section, find the &lt;DisplayString&gt; associated to the subscription. Make sure the Name in &lt;Name&gt; tag matches the subscription name in the OpsMgr console, and ElementID starts with "subscription"

<a href="https://blog.tyang.org/wp-content/uploads/2013/04/image8.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2013/04/image_thumb8.png" width="508" height="296" border="0" /></a>

4. Change the name in &lt;Name&gt; tag, add "-Do Not Change In UI" at the end (As shown above). this is to remind anyone not to change this subscription in the Operations console after it’s imported back.

5. Find the Rule with the same ID as the ElementID for the &lt;DisplayString&gt; taken from step 3. The rule should be under &lt;Monitoring&gt;&lt;Rules&gt; tags.

<a href="https://blog.tyang.org/wp-content/uploads/2013/04/image9.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2013/04/image_thumb9.png" width="580" height="191" border="0" /></a>

6. Modify the DataSource module of this rule, Add below expression in &lt;Expressions&gt;&lt;And&gt; tag:

<span style="color: #ff0000;">&lt;Expression&gt;
&lt;UnaryExpression&gt;
&lt;ValueExpression&gt;
&lt;Property&gt;TicketId&lt;/Property&gt;
&lt;/ValueExpression&gt;
&lt;Operator&gt;IsNull&lt;/Operator&gt;
&lt;/UnaryExpression&gt;
&lt;/Expression&gt;</span>

<strong>Before:</strong>

<a href="https://blog.tyang.org/wp-content/uploads/2013/04/image10.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2013/04/image_thumb10.png" width="565" height="585" border="0" /></a>

<strong>After:</strong>

<a href="https://blog.tyang.org/wp-content/uploads/2013/04/image11.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2013/04/image_thumb11.png" width="565" height="724" border="0" /></a>

7. Save the changes and import the MP back to OpsMgr management group.

8. Wait few minutes for the new configuration to become active. Once it’s active, you will no longer see the criteria in operations console:

<a href="https://blog.tyang.org/wp-content/uploads/2013/04/image12.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2013/04/image_thumb12.png" width="580" height="194" border="0" /></a>

Now, when I test this notification by creating a critical alert (using a <a href="http://support.microsoft.com/kb/934756">test alert generating rule</a> I’ve configured previously), I only get 1 notification pushed out to my phone (and it was pushed out before Service Manager updated it):

<a href="https://blog.tyang.org/wp-content/uploads/2013/04/image13.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2013/04/image_thumb13.png" width="447" height="393" border="0" /></a>

<a href="https://blog.tyang.org/wp-content/uploads/2013/04/image14.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2013/04/image_thumb14.png" width="580" height="263" border="0" /></a>
<h2>More Information</h2>
<strong>MP Schema Reference:</strong>

ExpressionType: <a href="http://msdn.microsoft.com/en-us/library/ee692979.aspx">http://msdn.microsoft.com/en-us/library/ee692979.aspx</a>

ExpressionType (GroupPopulationSchema): <a href="http://msdn.microsoft.com/en-us/library/ff472337.aspx">http://msdn.microsoft.com/en-us/library/ff472337.aspx</a>

<strong><span style="color: #ff0000; font-size: large;">Note:</span></strong> I used UnaryExpression, which is only listed in GroupPopulation Schema ExpressionType. but it worked in this scenario.

<strong>Related Blog Articles:</strong>

Using Expressions and Wildcards to create groups, author rules and monitors, create console views and notification subscriptions, and in the Command Shell: <a href="http://blogs.technet.com/b/jonathanalmquist/archive/2010/10/13/regular-expression-syntax-in-scom-for-filtering-groups-monitor-elements-operational-views-notification-subscriptions-etc.aspx">http://blogs.technet.com/b/jonathanalmquist/archive/2010/10/13/regular-expression-syntax-in-scom-for-filtering-groups-monitor-elements-operational-views-notification-subscriptions-etc.aspx</a>

Creating granular alert notifications - rule by rule, monitor by monitor: <a href="http://blogs.technet.com/b/kevinholman/archive/2008/10/12/creating-granular-alert-notifications-rule-by-rule-monitor-by-monitor.aspx">http://blogs.technet.com/b/kevinholman/archive/2008/10/12/creating-granular-alert-notifications-rule-by-rule-monitor-by-monitor.aspx</a>