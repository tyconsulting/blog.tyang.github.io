---
id: 1180
title: Using SCOM To Count Logs and Produce Reports
date: 2012-04-27T23:40:54+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=1180
permalink: /2012/04/27/using-scom-to-count-logs-and-produce-reports/
categories:
  - SCOM
tags:
  - Featured
  - MP Authoring
  - SCOM
  - SCOM Reporting
  - SQL
---
Recently, I’ve been asked twice to produce daily reports involves counting some kind of logs:

<strong>Scenario 1:</strong>

The support team need to count number of Application event log entries of events with a specific event ID. A daily report is required to list the number for each computer.

<strong>Scenario 2:</strong>

An application produces a log file each day. The support team need to count the number of a specific phrase appeared in previous day’s log file. A daily report is required to list the count number for each computer.

The solution I produced for both scenarios are very similar. so I thought I’d blog this one.

<strong>Solution from High level View:</strong>
<ol>
	<li>Create a rule in the SCOM management pack to run once a day.</li>
	<li>Write a script within a rule in the SCOM management pack to count the log</li>
	<li>map the count number to performance data and save it in the SCOM operational and data warehouse DB.</li>
	<li>design a report for raw performance data in SQL SRS report builder</li>
	<li>save the report into the management pack</li>
	<li>schedule the report to run and to be emailed out once a day, AFTER the rule has run for the day.</li>
</ol>
In this blog post, I’m not going to go through the steps of creating the custom data source module and the performance collection rule. They are pretty straightforward and the sample management pack can be downloaded <span style="font-size: small;"><a href="http://blog.tyang.org/wp-content/uploads/2012/04/Custom.Log_.Count_.zip">HERE</a></span>.

I will however go through the steps to create the custom report for the data collected by this rule. I’m creating the report rather than using the built-in performance reports from the “Microsoft Generic Report Library” because none of the built-in performance reports support a table format. I don’t want any fancy charts with the report. All I want is a simple list of the raw perf counter values.

Now, let’s briefly go through the data source module and the performance collection rule.

<strong><span style="font-size: small;">Data Source Module:</span></strong> contains 2 members: <strong>System.Scheduler</strong> and <strong>Microsoft.Windows.PowerShellPropertyBagTriggerOnlyProbe</strong>:

<a href="http://blog.tyang.org/wp-content/uploads/2012/04/image10.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/04/image_thumb10.png" alt="image" width="580" height="328" border="0" /></a>

The <strong>Microsoft.PowershellPropertyBagTriggerOnlyProbe</strong> contains a powershell script that counts event log entries and pass the count into a PropertyBag:

[sourcecode language="PowerShell"]
#===========================================================================================
# AUTHOR:  Tao Yang
# DATE:    30/01/2012
# Version: 1.0
# COMMENT: Count for a particular event in event log and pass the count to property bag
#===========================================================================================
Param ([int]$TimeFrameInHours, [string]$LogName, [int]$EventID, [string]$EventSource)

$StartTime = (Get-Date).AddHours(-$TimeFrameInHours)
$iEventCount = 0
Try {
$Events = Get-EventLog -LogName $LogName -After $StartTime -Source $EventSource | Where-Object {$_.EventID -eq $EventID}
Foreach ($Event in $Events)
{
If ($Event -ne $null) {$iEventCount++}
}
} Catch {
$iEventCount = 0
}
$ComputerName = (Get-WmiObject Win32_ComputerSystem).Caption
$oAPI = New-Object -ComObject &quot;MOM.ScriptAPI&quot;
$OAPI.LogScriptEvent(&quot;Event-Count.PS1&quot;,9999,0,&quot;Start EventID $EventID Perf Collection Rule. Collecting $EventID events since $starttime...&quot;)
$oBag = $oAPI.CreatePropertyBag()
$oBag.AddValue('ComputerName', $ComputerName)
$oBag.AddValue('EventCount', $iEventCount)
$oBag.AddValue('TimeFrameInHours', $TimeFrameInHours)
$oBag.AddValue('LogName', $LogName)
$oBag.AddValue('EventID', $EventID)
$oBag.AddValue('EventSource', $EventSource)
$oBag
[/sourcecode]

<span style="font-size: small;"><strong>Performance Collection Rule</strong>:</span> This rule contains:

Data Source: the data source module created previously

Condition Detection: map the event log count in PropertyBag to performance counter

Actions: Write performance data to Operational and DW databases.

<a href="http://blog.tyang.org/wp-content/uploads/2012/04/image11.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/04/image_thumb11.png" alt="image" width="580" height="577" border="0" /></a>

<span style="font-size: small;"><strong>Report:</strong></span>

Pre-requisites:
<ul>
	<li>Install the Performance Report Model in SCOM reporting SSRS. Here’s a detailed instruction (even though it was written for SCOM 2007 SP1, it’s also applies to SCOM 2007 R2): <a title="http://www.systemcentercentral.com/BlogDetails/tabid/143/IndexID/20269/Default.aspx" href="http://www.systemcentercentral.com/BlogDetails/tabid/143/IndexID/20269/Default.aspx">http://www.systemcentercentral.com/BlogDetails/tabid/143/IndexID/20269/Default.aspx</a></li>
	<li>Please Note that in above article, it uses Event model as example. The report I’m going to create uses Performance model. so please make sure <strong>Performance.smdl</strong> is uploaded into SCOM Reporting SSRS and configured to use the “<strong>Data Warehouse Main</strong>” data source.</li>
	<li>Import the half finished management pack (with the data source module and the perf collection rule) into a SCOM management group (preferably your development environment).</li>
	<li>Create an override or simply change the schedule of the rule to run ASAP so the perf data is collected. this is very useful when testing the report later on.</li>
	<li></li>
</ul>
<strong>Steps of creating the report:</strong>

01.Browse to the SCOM Reporting SSRS reports <a href="http://&lt;servername&gt;/reports">http://&lt;servername&gt;/reports</a> URL

02. Launch Report Builder and click “Run” if security warning pops up

<a href="http://blog.tyang.org/wp-content/uploads/2012/04/image12.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/04/image_thumb12.png" alt="image" width="580" height="201" border="0" /></a>

03. In Report Builder, choose the following options in “Getting Started” pane to create a new report:

<a href="http://blog.tyang.org/wp-content/uploads/2012/04/image13.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/04/image_thumb13.png" alt="image" width="207" height="680" border="0" /></a>

04. Enter the report title:

<a href="http://blog.tyang.org/wp-content/uploads/2012/04/image14.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/04/image_thumb14.png" alt="image" width="580" height="215" border="0" /></a>

05. Drag “Performance Data Raw into the report

<a href="http://blog.tyang.org/wp-content/uploads/2012/04/image15.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/04/image_thumb15.png" alt="image" width="580" height="311" border="0" /></a>

06. Under Performance Data Raw / Object, Drag the “Name” field to the report<a href="http://blog.tyang.org/wp-content/uploads/2012/04/image16.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/04/image_thumb16.png" alt="image" width="580" height="462" border="0" /></a>

07. Rename the title of each row in the report table:

<a href="http://blog.tyang.org/wp-content/uploads/2012/04/image17.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/04/image_thumb17.png" alt="image" width="422" height="138" border="0" /></a>

08. Right click the number under “Event Count”, select “Format…”, and change “Decimal places” to 0

<a href="http://blog.tyang.org/wp-content/uploads/2012/04/image18.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/04/image_thumb18.png" alt="image" width="438" height="438" border="0" /></a>

09. Click the Filter button to create filters:

<a href="http://blog.tyang.org/wp-content/uploads/2012/04/image19.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/04/image_thumb19.png" alt="image" width="580" height="122" border="0" /></a>

10. Under <strong>Performance Data Raw \ Performance Rule Instance \ Performance Rule</strong>, drag the “<strong>Rule System Name</strong>” Field to the right and choose the rule I created in the management pack from the list. (Note: the rule name appears on the list because the management pack is already imported into SCOM and this rule has already collected some performance data.)

<a href="http://blog.tyang.org/wp-content/uploads/2012/04/image20.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/04/image_thumb20.png" alt="image" width="580" height="398" border="0" /></a>

11. Click on <strong>Performance Data Raw</strong> and drag “<strong>Date Time</strong>” field to the right

<a href="http://blog.tyang.org/wp-content/uploads/2012/04/image21.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/04/image_thumb21.png" alt="image" width="580" height="335" border="0" /></a>

12. Click on “equals” next to “Date Time” and change it to “After”:

<a href="http://blog.tyang.org/wp-content/uploads/2012/04/image22.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/04/image_thumb22.png" alt="image" width="358" height="259" border="0" /></a>

13. Choose “(n) days ago”

<a href="http://blog.tyang.org/wp-content/uploads/2012/04/image23.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/04/image_thumb23.png" alt="image" width="258" height="351" border="0" /></a>

14. Change “(n)” to “2”

<a href="http://blog.tyang.org/wp-content/uploads/2012/04/image24.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/04/image_thumb24.png" alt="image" width="333" height="67" border="0" /></a>

15. Click OK to exit the <strong>Filter Data</strong> window

16. Now, it’s time to test run the report. To do so, use the Run Report button on the top. Here’s the result from my test environment (Note: the date time is in UTC, <strong>NOT</strong> local time):

<a href="http://blog.tyang.org/wp-content/uploads/2012/04/image25.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/04/image_thumb25.png" alt="image" width="394" height="468" border="0" /></a>

17. If you want to make the report prettier (i.e. changing the font colour to pink <img class="wlEmoticon wlEmoticon-smilewithtongueout" src="http://blog.tyang.org/wp-content/uploads/2012/04/wlEmoticon-smilewithtongueout.png" alt="Smile with tongue out" />) or adjust the column width, or adding a company logo, you can click on “Design Report” button and modify the report.

18. Once you are happy with the report, save it to a RDL (report definition) file:

<a href="http://blog.tyang.org/wp-content/uploads/2012/04/image26.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/04/image_thumb26.png" alt="image" width="198" height="276" border="0" /></a>

19. Open up the half finished management pack (unsealed) in Authoring Console, go to <strong>Reporting</strong> workspace and create a new report:

<a href="http://blog.tyang.org/wp-content/uploads/2012/04/image27.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/04/image_thumb27.png" alt="image" width="349" height="233" border="0" /></a>

20. Give the report an ID:

<a href="http://blog.tyang.org/wp-content/uploads/2012/04/image28.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/04/image_thumb28.png" alt="image" width="371" height="143" border="0" /></a>

21. In the “General” tab, give the report a name and target it to “<strong>Microsoft.Windows.Computer</strong>” class

<a href="http://blog.tyang.org/wp-content/uploads/2012/04/image29.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/04/image_thumb29.png" alt="image" width="392" height="395" border="0" /></a>

22. Go to “Definition” tab, click “Load content from file” and select the RDL file you’ve just created.

<a href="http://blog.tyang.org/wp-content/uploads/2012/04/image30.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/04/image_thumb30.png" alt="image" width="447" height="155" border="0" /></a>

23. Once the RDL file is loaded, remove the first line, which is the XML header <strong>&lt;?xml version="1.0" encoding="utf-8"?&gt;</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2012/04/image31.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/04/image_thumb31.png" alt="image" width="471" height="477" border="0" /></a>

24. Once the first line is removed, go to “Options” tab

25. Make sure “Visible” is set to “true” and “Accessibility” is set to “public”

<a href="http://blog.tyang.org/wp-content/uploads/2012/04/image32.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/04/image_thumb32.png" alt="image" width="411" height="416" border="0" /></a>

26. click apply and OK to exit the window

27. Now that the report is successfully created and tested, if you have changed the schedule of the perf collection rule (either edited the rule directly or created an override), it’s time to change the schedule back.

28. Now, if you want to keep the management pack unsealed, just export the updated management pack with the report into SCOM management group from authoring console. If you want to seal it, do so, and delete the previous unsealed version from the management group first, then import the sealed version into the management group.

I always increase the version number so I can lookup Event ID 1201 in SCOM agent’s Operations Manager log and make sure the updated version of the MP is received:

<a href="http://blog.tyang.org/wp-content/uploads/2012/04/image33.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/04/image_thumb33.png" alt="image" width="423" height="320" border="0" /></a>

29. After couple of minutes, if everything goes well, you should be able to see the report in both Operations Console Reporting workspace and also in SCOM Reporting SSRS site:

<a href="http://blog.tyang.org/wp-content/uploads/2012/04/image34.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/04/image_thumb34.png" alt="image" width="516" height="330" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2012/04/image35.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/04/image_thumb35.png" alt="image" width="580" height="237" border="0" /></a>

<span style="color: #ff0000; font-size: small;">Note:</span> In SSRS, you should also see a .mp file in the same folder. I’ve experienced issues where the report does not get updated with the updated MP, which was caused by incorrect .mp file in SSRS directory. Please refer to my <a href="http://blog.tyang.org/2012/03/28/reports-not-updated-in-scom-sql-reporting-service-when-the-management-pack-was-updated/">previous post</a> for details.

30. Schedule the report in SCOM reporting (so it can be emailed out according to a schedule) if you want to. make sure the report schedule is <strong>AFTER</strong> the rule schedule time (i.e. if the rule runs daily at 0:00am, the report schedule should be something like daily at 0:30am) otherwise newly collected data is not included in the report.

That concludes the steps to create the report. Few other things I’d also like to mention:
<ol>
	<li>In my case, for the second scenario I mentioned in the beginning (reading log files), the whole process and idea is the same. The only thing different is the script in the Data Source module.</li>
	<li>I could have moved the condition detection module (System.Performance.DataGenericMapper) from the rule to the data source module. I didn’t do it because then I can use the same data source module for other purposes later. For example, if later on, the support team comes to me and ask me to generate alerts once the count reaches a threshold, I can simply create a separate rule (or a custom monitor type and a monitor), using the same data source. If the input parameters of the data source is the same as the existing performance collection rule, the data source should only run once for multiple workflows because of the <a href="http://technet.microsoft.com/en-us/library/ff381335.aspx">Cookdown</a> feature.</li>
	<li>If the SCOM agent computer is in maintenance mode when the perf collection rule is scheduled to run, no perf data will be collected and the computer will be missing from the report.</li>
	<li>In my example, I’m using a PowerShell script. So PowerShell and it’s execution policy needs to be installed / enabled on the SCOM agent computers. if this doesn’t meet your requirement, just modify the module to use a VBscript instead. I’ve <a href="http://blog.tyang.org/2012/01/27/scom-powershell-property-bag-trigger-only-probe-vs-windows-script-property-bag-probe/">blogged previously</a> on how to create trigger only probe action modules for VBScript.</li>
</ol>
Again, the sample MP and the Report Definition RDL file can be downloaded <span style="font-size: small;"><a href="http://blog.tyang.org/wp-content/uploads/2012/04/Custom.Log_.Count_.zip">HERE</a></span>.