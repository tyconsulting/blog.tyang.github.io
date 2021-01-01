---
id: 3175
title: 'SMA Management Pack Could Not Connect To Database Alerts &#8211; My Troubleshooting Experience'
date: 2014-09-23T21:15:26+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=3175
permalink: /2014/09/23/sma-management-pack-connect-database-alertsmy-troubleshooting-experience/
categories:
  - SCOM
  - SMA
tags:
  - SCOM
  - SMA
  - SQL
---
I’ve setup 2 servers for the SMA environment in my lab a while back. Yesterday, I loaded the <a href="http://www.microsoft.com/en-au/download/details.aspx?id=40858">SMA MP (version 7.2.89.0)</a> into my OpsMgr management group. Needless to say, I followed the MP guide and configured the Database RunAs profile. However, soon after the MP is loaded, I started getting these 2 alerts:
<ul>
	<li>The Service Management Automation web service could not connect to the database.</li>
	<li>The Service Management Automation worker server could not connect to the database.</li>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2014/09/SNAGHTMLc49f04a.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLc49f04a" src="http://blog.tyang.org/wp-content/uploads/2014/09/SNAGHTMLc49f04a_thumb.png" alt="SNAGHTMLc49f04a" width="672" height="327" border="0" /></a>

To troubleshoot these alerts, I firstly unsealed the management pack <strong>Microsoft.SystemCenter.ServiceManagementAutomation.2012R2.mp</strong>, as this is where the monitors are coming from. The Data Source module of the monitor type uses <strong>System.OleDbProbe</strong> probe action module to make the connection to the database.

<a href="http://blog.tyang.org/wp-content/uploads/2014/09/SNAGHTMLc5582d0.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLc5582d0" src="http://blog.tyang.org/wp-content/uploads/2014/09/SNAGHTMLc5582d0_thumb.png" alt="SNAGHTMLc5582d0" width="797" height="288" border="0" /></a>

To simulate the problem, I used a small free utility called <a href="http://portableapps.com/apps/development/database_browser_portable">Database Browser Portable</a> to test the DB connection. I launched Database Browser using the same service account as what I configured in the RunAs profile in OpsMgr, and selected OleDB as the connection type:

<a href="http://blog.tyang.org/wp-content/uploads/2014/09/SNAGHTMLc61bf04.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLc61bf04" src="http://blog.tyang.org/wp-content/uploads/2014/09/SNAGHTMLc61bf04_thumb.png" alt="SNAGHTMLc61bf04" width="609" height="505" border="0" /></a>

I populated the Connection String based on the parameters (monitoring object properties) passed into the data source module: <strong>Provider=SQLOLEDB;Server=SQLDB01.corp.tyang.org\;Database=SMA;Integrated Security=SSPI</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2014/09/image.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/09/image_thumb.png" alt="image" width="675" height="356" border="0" /></a>

Note the Database Instance property is empty. this is OK in my lab because I’m using the default SQL instance. I’ll explain this later.

The test connection result is positive:

<a href="http://blog.tyang.org/wp-content/uploads/2014/09/SNAGHTMLc687aa6.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLc687aa6" src="http://blog.tyang.org/wp-content/uploads/2014/09/SNAGHTMLc687aa6_thumb.png" alt="SNAGHTMLc687aa6" width="516" height="405" border="0" /></a>

However, after connected, when I clicked the connection, nothing happened, the list of tables did not get populated. I then tried using my own account (which has god rights on everything in the lab), and I got the same result.

Long story short, after trying different configuration changes on the SQL server, I finally found the issue:

On the SQL server, the Name Pipes protocol was disabled

<a href="http://blog.tyang.org/wp-content/uploads/2014/09/SNAGHTMLc705360.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLc705360" src="http://blog.tyang.org/wp-content/uploads/2014/09/SNAGHTMLc705360_thumb.png" alt="SNAGHTMLc705360" width="402" height="190" border="0" /></a>

After I enabled it, I was able to populate the tables in Database Browser:

<a href="http://blog.tyang.org/wp-content/uploads/2014/09/SNAGHTMLc7245ca.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLc7245ca" src="http://blog.tyang.org/wp-content/uploads/2014/09/SNAGHTMLc7245ca_thumb.png" alt="SNAGHTMLc7245ca" width="365" height="360" border="0" /></a>

And within few minutes, the alerts were auto closed.

While I was troubleshooting this issue, I came across a <a href="https://cloudadministrator.wordpress.com/2014/02/11/quick-look-at-system-center-service-management-automation-management-pack/">blog post</a> from Stanislav Zhelyazkov. In the blog post, Stan mentioned adding the DB instance name in the registry (where the discoveries are looking for). However, when I added “MSSQLSERVER” in the registry and forced re-discovery, the monitors became critical again and I received several 11852 event in Operations Manager event log:

<a href="http://blog.tyang.org/wp-content/uploads/2014/09/SNAGHTMLc7e3526.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLc7e3526" src="http://blog.tyang.org/wp-content/uploads/2014/09/SNAGHTMLc7e3526_thumb.png" alt="SNAGHTMLc7e3526" width="676" height="412" border="0" /></a>

I email Stan and he got back to me and told me he’s using a named instance in his lab and these monitors are working fine in his lab after he added the SQL instance name in the registry. He also told me he didn’t recall specifying the SQL Instance name during the SMA setup but the setup went successful. My guess is that the SQL Browser service must be running on his SQL server, so the setup had no problem identifying the named instance.
<h3>Conclusion</h3>
Based on my experience and Stan’s experience, we’d like to make the following recommendations:
<ul>
	<li>Enable the Name Pipes protocol</li>
	<li>If using the default SQL instance, please do not manually populate the registry key</li>
	<li>If using a named instance, please add the SQL instance name in the registry if it’s not populated after setup.</li>
</ul>
&nbsp;

Thanks Stan for his input on this one!