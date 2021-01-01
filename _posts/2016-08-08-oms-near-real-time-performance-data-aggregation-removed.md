---
id: 5479
title: OMS Near Real Time Performance Data Aggregation Removed
date: 2016-08-08T21:47:44+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=5479
permalink: /2016/08/08/oms-near-real-time-performance-data-aggregation-removed/
categories:
  - OMS
  - SCOM
tags:
  - OMS
  - SCOM
---
Few weeks ago, the OMS product team has made a very nice change for the Near Real Time (NRT) Performance data – the data aggregation has been removed! I’ve been waiting for the official announcement before posting this on my blog. Now Leyla from the OMS team has finally broke the silence and made this public: <a href="https://blogs.technet.microsoft.com/msoms/2016/08/05/raw-searchable-performance-metrics-in-oms/">Raw searchable performance metrics in OMS</a>.

I’m really excited about this update. Before this change, we were only able to search 30-minute aggregated data via Log Search. this behaviour brings some limitations to us:
<ul>
 	<li>It’s difficult to calculate average values based on other intervals (i.e. 5-minute or 10-minute)</li>
 	<li>Performance based Alert rules can be really outdated – this is because the search result is based on the aggregated value over the last 30 minutes. In critical environment, this can be a bit too late!</li>
</ul>
By removing the data aggregation and making the raw data searchable (and living a longer life), the limitations listed above are resolved.

Another advantage this update brings is, it greatly simplified the process of authoring your own OpsMgr performance collection rules for OMS NRT Perf data. Before this change, the NRT perf rules come in pairs – each perf counter you want to collect must have 2 rules (with the identical data source module configurations). One rule is for collecting raw data and another is to collect the 30-minute aggregated data. This has been discussed in great details in Chapter 11 of our <em>Inside Microsoft Operations Management Suite</em> book (<a href="https://gallery.technet.microsoft.com/Inside-the-Operations-2928e342">TechNet</a>, <a href="https://www.amazon.com/Inside-Microsoft-Operations-Management-Hands--ebook/dp/B01CH1L9X6">Amazon</a>). Now, we no longer need to write 2 rules for each perf counter. We only need to write one rule – for the raw perf data.

The sample OpsMgr management pack below collects the "Log Cache Hit Ratio" counter for SQL Databases. It is targeting the Microsoft.SQLServer.Database class, which is the seedclass for pre-SQL 2014 databases (2005, 2008 and 2012):
<pre class="" language="XML">
<?xml version="1.0" encoding="utf-8"?>
<ManagementPack SchemaVersion="2.0" ContentReadable="true" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <Manifest>
    <Identity>
      <ID>OMS.NRT.Perf.Collection.Demo</ID>
      <Version>0.0.0.2</Version>
    </Identity>
    <Name>OMS.NRT.Perf.Collection.Demo</Name>
    <References>
      <Reference Alias="IPTypes">
        <ID>Microsoft.IntelligencePacks.Types</ID>
        <Version>7.0.10013.0</Version>
        <PublicKeyToken>31bf3856ad364e35</PublicKeyToken>
      </Reference>
      <Reference Alias="SQL">
        <ID>Microsoft.SQLServer.Library</ID>
        <Version>6.5.4.0</Version>
        <PublicKeyToken>31bf3856ad364e35</PublicKeyToken>
      </Reference>
      <Reference Alias="Windows">
        <ID>Microsoft.Windows.Library</ID>
        <Version>7.5.8501.0</Version>
        <PublicKeyToken>31bf3856ad364e35</PublicKeyToken>
      </Reference>
      <Reference Alias="System">
        <ID>System.Library</ID>
        <Version>7.5.8501.0</Version>
        <PublicKeyToken>31bf3856ad364e35</PublicKeyToken>
      </Reference>
    </References>
  </Manifest>
  <Monitoring>
    <Rules>
      <Rule ID="OMS.NRT.Perf.Collection.Demo.SQL.Log.Cache.Hit.Ratio.Perf.Rule" Target="SQL!Microsoft.SQLServer.Database" Enabled="true" Remotable="false" ConfirmDelivery="false" Priority="Normal" DiscardLevel="100">
        <Category>PerformanceCollection</Category>
        <DataSources>
          <DataSource ID="DS" TypeID="IPTypes!Microsoft.IntelligencePacks.Performance.DataProvider">
            <ComputerName>$Target/Host/Host/Property[Type="Windows!Microsoft.Windows.Computer"]/NetworkName$</ComputerName>
            <CounterName>Log Cache Hit Ratio</CounterName>
            <ObjectName>SQLServer:Databases</ObjectName>
            <InstanceName>$Target/Property[Type="SQL!Microsoft.SQLServer.Database"]/DatabaseName$</InstanceName>
            <AllInstances>false</AllInstances>
            <IntervalSeconds>10</IntervalSeconds>
          </DataSource>
        </DataSources>
        <WriteActions>
          <WriteAction ID="WA" TypeID="IPTypes!Microsoft.SystemCenter.CollectCloudPerformanceData_PerfIP" />
        </WriteActions>
      </Rule>
    </Rules>
  </Monitoring>
  <LanguagePacks>
    <LanguagePack ID="ENU" IsDefault="true">
      <DisplayStrings>
        <DisplayString ElementID="OMS.NRT.Perf.Collection.Demo">
          <Name>OMS NRT Perf Collection Demo</Name>
        </DisplayString>
        <DisplayString ElementID="OMS.NRT.Perf.Collection.Demo.SQL.Log.Cache.Hit.Ratio.Perf.Rule">
          <Name>OMS NRT Performance Collection Demo SQL Log Cache Hit Ratio Perf Rule</Name>
        </DisplayString>
      </DisplayStrings>
      <KnowledgeArticles></KnowledgeArticles>
    </LanguagePack>
  </LanguagePacks>
</ManagementPack>
</pre>
As you can see from the above sample MP, the rule that collects aggregated data is no longer required.

<a href="http://blog.tyang.org/wp-content/uploads/2016/08/image-6.png"><img style="padding-top: 0px; padding-left: 0px; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/08/image_thumb-6.png" alt="image" width="658" height="332" border="0" /></a>

So if you have written some rules collecting NRT perf data for OMS in the past, you may want to revisit what you’ve done in the past and remove the aggreated data collection rules.