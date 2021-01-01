---
id: 2299
title: Creating a Data Source for the Operational DB on OpsMgr 2012 R2 Reporting Server
date: 2013-12-06T13:10:59+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=2299
permalink: /2013/12/06/creating-data-source-operational-db-opsmgr-2012-r2-reporting-server/
categories:
  - SCOM
tags:
  - SCOM
  - SCOM Reporting
---
Creating a data source to for the OpsMgr Operational DB is a very common practice. This is required for many 3rd party OpsMgr reports. Kevin Holman blogged the instruction <a href="http://blogs.technet.com/b/kevinholman/archive/2008/06/27/creating-a-new-data-source-for-reporting-against-the-operational-database.aspx">here</a>.

In my case, I’m creating a data source called <strong>OperationalDataBaseMain</strong> for my favourite report MP <a href="http://www.systemcentercentral.com/pack-catalog/scc-health-check-management-pack-version-2/">SCC Health Check Management Pack</a>. Other than the data source name difference between Kevin’s blog and what’s required for SCC Health Check MP, Kevin configured the data source with the option “Credentials are not required”, which is essentially using the SSRS service account (DW Reader account). In the SCC Health Check MP documentation, it suggests to use the option “Windows integrated security”. Back then when I configured this data source in OpsMgr 2007, both options worked.

Today I was trying to configure this data source on our newly built OpsMgr 2012 R2 test management group where the Operational DB is hosted by SQL server, Data Warehouse and Reporting Server is hosted on SQL server B. Both SQL servers are running SQL 2012 SP1. I tried both authentication methods, none of them worked straightaway.

<strong>“Windows integrated security” option</strong>

When I chose this option, the test connection was successful, but when I tried to run a report that’s targeting the operational DB, I got this error (and my user ID is a member of the OpsMgr admin group):

<a href="http://blog.tyang.org/wp-content/uploads/2013/12/image.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/12/image_thumb.png" width="580" height="198" border="0" /></a>

<strong>“Credentials are not required” option</strong>

When I chose this option, the Test Connection was unsuccessful and I got this error:

<a href="http://blog.tyang.org/wp-content/uploads/2013/12/image1.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/12/image_thumb1.png" width="505" height="476" border="0" /></a>

<em><span style="color: #ff0000;">Login failed. the login is from an untrusted domain and cannot be used with Windows authentication.</span></em>

Both SQL servers and the DW reader service account is located in the same domain.

Furthermore, an event was logged on the Operational DB SQL server’s security log:

<a href="http://blog.tyang.org/wp-content/uploads/2013/12/image2.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/12/image_thumb2.png" width="424" height="370" border="0" /></a>

This log entry indicates the DW reader account does not have “logon from network” (logon type 3) rights.

Then I found out “Access this computer from the network” rights is restricted by a GPO to the following groups and the DW reader account is not a member of any of them:

<a href="http://blog.tyang.org/wp-content/uploads/2013/12/image3.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/12/image_thumb3.png" width="336" height="396" border="0" /></a>

So I added the DW reader service account to the local “Users” group on the SQL server hosting operational DB, tried to establish the connection again in the data source, this time, I got another error:

<a href="http://blog.tyang.org/wp-content/uploads/2013/12/image4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/12/image_thumb4.png" width="373" height="454" border="0" /></a>

<span style="color: #ff0000;"><em>Login failed for user &lt;DW Reader service account&gt;.</em></span>

It’s different message, so I checked SQL security, the DW Reader account was not listed as a user in SQL. I checked the SQL server for the OpsMgr 2007 environment, this account is added in SQL, been given public role and it’s not mapped to the operational DB. So I replicated this configuration on the SQL server hosting OpsMgr 2012 R2 operational DB, tested connection again in SSRS, now I have another different error:

<a href="http://blog.tyang.org/wp-content/uploads/2013/12/image5.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/12/image_thumb5.png" width="580" height="575" border="0" /></a>

<span style="color: #ff0000;"><em>Cannot open database “OperationsManager” requested by the login. the login failed. Login failed for user &lt;DW Reader service account&gt;.</em></span>

Also, I got a similar message in SQL log:

<a href="http://blog.tyang.org/wp-content/uploads/2013/12/image6.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/12/image_thumb6.png" width="580" height="86" border="0" /></a>

<span style="color: #ff0000;"><em>Login failed for user ‘&lt;DW Reader account&gt;’. Reason: Failed to open the explicitly specified database ‘OperationsManager’. [CLIENT: &lt;SSRS Server’s IP address&gt;]</em></span>

So I modified the user mapping for the DW reader account, given it “public” role for the OperationsManager DB

<a href="http://blog.tyang.org/wp-content/uploads/2013/12/image71.png"><img class="size-medium wp-image-2318 alignnone" alt="image7" src="http://blog.tyang.org/wp-content/uploads/2013/12/image71-300x272.png" width="300" height="272" /></a>

After this modification, I was able to connect the data source:

<a href="http://blog.tyang.org/wp-content/uploads/2013/12/image8.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/12/image_thumb8.png" width="450" height="467" border="0" /></a>

However, after I tried to run a report targeting the operational DB, I got another error:

<a href="http://blog.tyang.org/wp-content/uploads/2013/12/image9.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/12/image_thumb9.png" width="580" height="98" border="0" /></a>

I then modified the permission for DW Reader account within the Operational DB again. this time I’ve given the “db_datareader” role:

<a href="http://blog.tyang.org/wp-content/uploads/2013/12/image10.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/12/image_thumb10.png" width="513" height="464" border="0" /></a>

Finally, after this, the report successfully ran:

<a href="http://blog.tyang.org/wp-content/uploads/2013/12/image11.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/12/image_thumb11.png" width="580" height="381" border="0" /></a>

<strong>Summary</strong>

To summarise, <strong>In my environment</strong>, the DW Reader account needs to be given the following rights on the remote SQL server hosting operational DB to be able to setup the data source in SCOM reporting server’s SSRS instance:
<ul>
	<li>Logon from the network rights</li>
	<li>the “public” role for the SQL DB Engine</li>
	<li>“public” and “db_datareader” role for the OpsMgr operational DB.</li>
</ul>
<strong><span style="color: #ff0000;">Note:</span></strong>

Although I have checked 2 identical OpsMgr 2012 R2 test management groups we have here and DW reader account does not have any SQL rights on the operational DB SQL server by default in both management groups, I cannot verify / confirm if this scenario is by design. In my home lab, because both operational and DW databases are on the same SQL, I did not have to modify permissions for DW reader account at all.

I did not consult with any Microsoft people. This is purely just my personal experience. If you have any doubts, please do not implement this in your environment.