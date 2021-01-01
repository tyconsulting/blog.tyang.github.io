---
id: 3847
title: Using Squared Up As an Universal Dashboard Solution
date: 2015-03-13T18:19:17+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=3847
permalink: /2015/03/13/using-squared-up-as-an-universal-dashboard-solution/
categories:
  - SCOM
tags:
  - SCOM
  - SquaredUp
---
<h3>Background</h3>
I’ve been playing with Squared Up a lot lately – to get myself familiar with the new 2.0 version, thus my recent few posts were all related to it.

few days ago, I was involved in a conversation around from SCOM users / consumers point view, how to bring data from multiple management groups into a single pane of glass. As the result of this conversation, I’ve spent some time and tried the <a href="http://download.squaredup.com/downloads/download-info/sql/">Squared Up SQL Plugin</a>. After couple of hours, I managed to produce 2 dashboards using this plugin, both using data sources that are foreign to the OpsMgr management group the Squared Up instance is connected to.

In this blog, I’ll go through the steps setting up the following dashboards:
<ul>
	<li>Active Alerts from another OpsMgr management group (data source: the OperationsManager DB from the other management group).</li>
	<li>ConfigMgr 2012 Package Distribution Dashboard (data source: ConfigMgr primary site DB).</li>
</ul>
&nbsp;

I will demonstrate using the Squared Up 2.0 dashboard installed on the OpsMgr web console server in my home lab.

The foreign OpsMgr management group is hosted in my Azure subscription. All the servers used by this management group are connected to my home lab via a Azure S2S VPN connection. They are located on the same domain as my on-prem lab.

The ConfigMgr infrastructure is also located in my home lab (on-prem).
<h3>Pre-Requisites</h3>
<strong>Setting up DB access in SQL</strong>

Since the SQL connection string used by this plugin is stored in clear text, SquaredUp does not recommend using a username and password. Therefore, in the connection string, I’m using integrated security.

Since the SquaredUp IIS Application pool is running using the local NetworkService account, I must grant the SquaredUp web server’s computer account datareader access to the database that’s going to be used as the data source. i.e. for my ConfigMgr primary site DB:

<a href="http://blog.tyang.org/wp-content/uploads/2015/03/image24.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/03/image_thumb24.png" alt="image" width="419" height="378" border="0" /></a>

and for the OpsMgr operational DB:

<a href="http://blog.tyang.org/wp-content/uploads/2015/03/image25.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/03/image_thumb25.png" alt="image" width="421" height="380" border="0" /></a>

<strong>Installing Squared Up SQL Plugin</strong>

You will need to install the <strong><span style="text-decoration: underline;">latest</span></strong> version (2.0.2) of the plugin. if you have already installed it before, please make sure you update to this version. There was a bug in the earlier versions, and it has been fixed in 2.0.2.

&nbsp;
<h3>ConfigMgr Package Distribution Dashboard</h3>
<a href="http://blog.tyang.org/wp-content/uploads/2015/03/SNAGHTML421df2f8.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML421df2f8" src="http://blog.tyang.org/wp-content/uploads/2015/03/SNAGHTML421df2f8_thumb.png" alt="SNAGHTML421df2f8" width="670" height="375" border="0" /></a>

This dashboard contains 3 parts (two parts on the top, one on the bottom). the top 2 parts displays the a single number (how many package distributions are in error and retrying states). the bottom part is a list for all the distributions that are in these 2 states.

All 3 parts are using the SQL plugin, the connection string for all 3 parts are:

<em>Data Source=&lt;ConfigMgr DB Server&gt;;Initial Catalog=&lt;ConfigMgr Site DB&gt;;Integrated Security=True;</em>

the top 2 parts are configured like this:

<a href="http://blog.tyang.org/wp-content/uploads/2015/03/image26.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/03/image_thumb26.png" alt="image" width="671" height="307" border="0" /></a>

<strong>Pkg Dist - Error State part (Top left):</strong>

SQL query string:

<em>SELECT Count([StateGroupName]) FROM v_ContentDistributionReport where StateGroupName = 'Error'</em>

<strong>Pkg Dist – Retrying State part (Top right):</strong>

SQL query string:

<em>SELECT Count([StateGroupName]) FROM v_ContentDistributionReport where StateGroupName = 'Retrying'</em>

Other parameters:

isscalar: true

scalarfontsize: 120

<strong>Pkg Dist – List (Bottom):</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2015/03/image27.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/03/image_thumb27.png" alt="image" width="592" height="276" border="0" /></a>

SQL query string:

<em>SELECT [PkgID],[DistributionPoint],[State],[StateName],[StateGroupName],[SourceVersion],[SiteCode],Convert(VARCHAR(24),[SummaryDate],113) as 'Summary Date',[PackageType] FROM v_ContentDistributionReport where StateGroupName &lt;&gt; 'Success' order by StateGroupName desc</em>

other parameters:

isscalar: false

&nbsp;
<h3>Active Alerts Dashboard for a foreign OpsMgr MG</h3>
<a href="http://blog.tyang.org/wp-content/uploads/2015/03/image28.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/03/image_thumb28.png" alt="image" width="695" height="364" border="0" /></a>

Similar to the previous sample, there are 2 parts on the top displaying scalar values. In this case, I’ve chosen to display the active alerts count for critical and warning alerts. Followed by the 2 big scalar numbers, I added 2 lists for active critical &amp; warning alerts.

<strong>SQL connection strings:</strong>

<em>Data Source=&lt;OpsMgr DB server&gt;;Initial Catalog=OperationsManager;Integrated Security=True;</em>

<strong>Active Alert Count – Critical (Top left):</strong>

SQL query string:

<em>select count(id) from [dbo].[AlertView] where ResolutionState &lt;&gt; 255 and severity = 2</em>

isscalar: true

scalarfontsize: 120

<strong>Active Alert Count – Warning (Top right):</strong>

SQL query string:

<em>select count(id) from [dbo].[AlertView] where ResolutionState &lt;&gt; 255 and severity = 1</em>

isscalar: true

scalarfontsize: 120

<strong>Active Alerts – Critical (list):</strong>

SQL query string:

<em>SELECT Case a.[MonitoringObjectHealthState] When 0 Then 'Not Monitored' When 1 Then 'Healthy' When 2 Then 'Warning' When 3 Then 'Critical' END As 'Health State', a.[MonitoringObjectFullName] as 'Monitoring Object',a.[AlertStringName] as 'Alert Title',r.ResolutionStateName as 'Resolution State',Case a.Severity When 0 Then 'Information' When 1 Then 'Warning' When 2 Then 'Critical' END As 'Alert Severity', Case a.Priority When 0 Then 'Low' When 1 Then 'Medium' When 2 Then 'High' END As 'Alert Priority',Convert(VARCHAR(24),a.[TimeRaised],113) as 'Time Raised UTC' FROM [dbo].[AlertView] a inner join dbo.ResolutionStateView r on a.ResolutionState = r.ResolutionState where a.ResolutionState &lt;&gt; 255 and a.severity = 2 order by a.TimeRaised desc</em>

isscalar: false

tableshowheaders: true

<strong>Active Alerts – Warning (list):</strong>

SQL query string:

<em>SELECT Case a.[MonitoringObjectHealthState] When 0 Then 'Not Monitored' When 1 Then 'Healthy' When 2 Then 'Warning' When 3 Then 'Critical' END As 'Health State', a.[MonitoringObjectFullName] as 'Monitoring Object',a.[AlertStringName] as 'Alert Title',r.ResolutionStateName as 'Resolution State',Case a.Severity When 0 Then 'Information' When 1 Then 'Warning' When 2 Then 'Critical' END As 'Alert Severity', Case a.Priority When 0 Then 'Low' When 1 Then 'Medium' When 2 Then 'High' END As 'Alert Priority',Convert(VARCHAR(24),a.[TimeRaised],113) as 'Time Raised UTC' FROM [dbo].[AlertView] a inner join dbo.ResolutionStateView r on a.ResolutionState = r.ResolutionState where a.ResolutionState &lt;&gt; 255 and a.severity = 1 order by a.TimeRaised desc</em>

isscalar: false

tableshowheaders: true

As shown in the dashboard screenshot above, currently I have 9 critical and 12 warning alerts in the MG on the cloud, this figure matches what’s showing in the Operations console:

<a href="http://blog.tyang.org/wp-content/uploads/2015/03/SNAGHTML4252316b.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML4252316b" src="http://blog.tyang.org/wp-content/uploads/2015/03/SNAGHTML4252316b_thumb.png" alt="SNAGHTML4252316b" width="696" height="463" border="0" /></a>

&nbsp;
<h3>Conclusion</h3>
By using the Squared Up SQL plugin, you can potentially turn Squared UP into a dashboard for any systems (not just OpsMgr). The limit is your imagination <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" src="http://blog.tyang.org/wp-content/uploads/2015/03/wlEmoticon-smile.png" alt="Smile" />. I have also written few posts on Squared Up before, you can find them here: <a title="http://blog.tyang.org/tag/squaredup/" href="http://blog.tyang.org/tag/squaredup/">http://blog.tyang.org/tag/squaredup/</a>

Lastly, I encourage you to share your brilliant ideas with the rest of us, and I will for sure keep posting on this topic if I come up with something cool in the future.