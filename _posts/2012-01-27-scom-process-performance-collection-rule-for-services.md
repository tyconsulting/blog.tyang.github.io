---
id: 888
title: 'SCOM: Process Performance Collection Rule for Services'
date: 2012-01-27T12:28:08+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=888
permalink: /2012/01/27/scom-process-performance-collection-rule-for-services/
categories:
  - SCOM
tags:
  - MP Authoring
  - PerfMon
  - SCOM
---
Setting up Performance Collection rules for a particular process is pretty straightforward in SCOM. However, the it has it’s limitations.

Process performance collections rules are straightforward to setup, as long as there is ONLY ONE instance of the particular process running on the computers that your rule is targeting. Also, each rule can only collect ONE performance counter.

The problem with that is, if I need to collect performance counters for a particular service, i.e. Server Service (lanmanserver) or a particular SQL server instance (when there are multiple SQL instances running on the same server) , I will not be able to do so using the default performance collection module “System.Performance.OptimizedDataProvider” because server service runs under the generic service host svchost.exe. Typically, there are many instances of svchost.exe running for various services:

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image31.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb31.png" alt="image" width="580" height="756" border="0" /></a>

According to above screen capture, there are 10 instances of svchost.exe running on my computer. And when selecting performance counter in SCOM consoles, there are 10 instances of svchost:

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image32.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb32.png" alt="image" width="537" height="428" border="0" /></a>

It’s the same if I simply run perfmon on the computer: there are 10 instances of svchost:

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image33.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb33.png" alt="image" width="580" height="426" border="0" /></a>

There’s actually a blog article on TechNet explaining this issue with perfmon: <a href="http://blogs.technet.com/b/askperf/archive/2010/03/30/perfmon-identifying-processes-by-pid-instead-of-instance.aspx">Perfmon: Identifying processes by PID instead of instance</a>

So, there is a workaround for perfmon, but it doesn’t really help me with my performance collection rule in SCOM.

To overcome this issue, I had to create some customized modules to collect the counters that I’m interested in via WMI. I’ll now explain what I’ve done to achieve the goal.

1. I firstly created a probe action module to run a vbscript to collect ALL the counters I’m interested in via WMI. In the script:
<ol>
	<li>takes the service name and computer name from the input parameter, get the PID for the service from <strong>win32_service</strong> class (note, I had to pass computer name to the script so it can connect to remote computer’s WMI namespace, this is required for agentless monitoring)</li>
	<li>retrieve the values of the performance counters from <strong>Win32_PerfFormattedData_PerfProc_Process</strong> class using query <strong>"Select * from Win32_PerfFormattedData_PerfProc_Process Where IDProcess = ProcessID"</strong> (ProcessID was retrieved from step 1)</li>
	<li>For each performance counter, create a property bag and add the property bag to MOM.ScriptAPI object</li>
	<li>Return all property bags.</li>
</ol>
2. Create a Data Source module which contains 3 modules and the modules are executed on the following order:
<ol>
	<li>System.SimpleScheduler (runs according to a schedule)</li>
	<li>Probe module created from step 1 (retrieve performance counters and return then via property bag)</li>
	<li>System.Performance.DataGenericMapper (Map the property bag values to performance data)</li>
</ol>
Now that I’ve created all the required modules, I can then create a SINGLE rule to collect all different counters that I defined in the probe action module. To do so:

1. In Authoring console, create a Custom Rule:

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image34.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb34.png" alt="image" width="311" height="236" border="0" /></a>

2. Give the rule a name and choose the target:

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image35.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb35.png" alt="image" width="580" height="578" border="0" /></a>

3. Add the data source module I previously created and configure the variables (service name is the actual service name, <span style="color: #ff0000;"><strong>NOT</strong></span> service display name):

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image36.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb36.png" alt="image" width="580" height="534" border="0" /></a>

<strong><span style="color: #ff0000; font-size: medium;">Note:</span></strong> The <strong>Computername</strong> variable from above example is “$Target/Property[Type="Windows!Microsoft.Windows.Computer"]/PrincipalName$”, this is correct because I’m targeting the rule to Windows Computer. You will have to change it if you are targeting other classes. The best way is to use the prompt and choose the host’s principal name. Below is an example if I target the rule to Windows Operating System:

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image37.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb37.png" alt="image" width="580" height="525" border="0" /></a>

4. Add 2 Actions module (don’t need to configure them):
<ol>
	<li>Microsoft.SystemCenter.CollectionPerformanceData (WriteToDB)</li>
	<li>Microsoft.SystemCenter.DataWarehouse.PublishPerformanceData (WriteToDW)</li>
</ol>
<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image38.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb38.png" alt="image" width="580" height="455" border="0" /></a>

<strong><span style="color: #ff0000; font-size: medium;">Note:</span></strong> The 2nd action module WriteToDW is from Microsoft.SystemCenter.DataWarehouse.Library. you will have to add this library as a reference of your management pack.

Now, the rule is created, you can create a performance view for the rule and make sure it is collecting data:

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image39.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb39.png" alt="image" width="580" height="479" border="0" /></a>

Below is the VBScript I’ve used in probe action module:

[sourcecode language="vbnet"]
'=========================================================================
' AUTHOR:             Tao Yang
' Script Name:        ProcessPerfMonData.vbs
' DATE:               23/01/2012
' Version:            1.0
' COMMENT:            Script to collect perfmon data for specific service
'=========================================================================
Option Explicit
SetLocale(&quot;en-us&quot;)
Dim ServiceName, objWMIService,colService, objService, ComputerName
Dim ProcessID, ProcessName, colProcess, objProcess, colPerfData, objPerfData
Dim ElapsedTime, PercentProcessorTime, PercentUserTime, ThreadCount, PageFaultsPersec, IOReadBytesPersec, IOWriteBytesPersec
Dim oAPI, oBag, oInst
ServiceName = WScript.Arguments.Item(0)
ComputerName = Wscript.Arguments.Item(1)
Set oAPI = CreateObject(&quot;MOM.ScriptAPI&quot;)

Set objWMIService = GetObject(&quot;winmgmts:{impersonationLevel=impersonate}!\\&quot; &amp; ComputerName &amp;&quot;\root\cimv2&quot;)
Set colService = objWMIService.ExecQuery(&quot;Select * from Win32_Service Where Name = '&quot; + ServiceName + &quot;'&quot;)

For Each objService in colService
ProcessID = objService.ProcessID
Next

If ProcessID &lt;&gt; 0 THEN
Set colProcess = objWMIService.ExecQuery(&quot;Select * from Win32_Process Where ProcessID = &quot; &amp; ProcessID)
For Each objProcess in colProcess
ProcessName = objProcess.Name
Next
Set colPerfData = objWMIService.ExecQuery(&quot;Select * from Win32_PerfFormattedData_PerfProc_Process Where IDProcess = &quot; &amp; ProcessID)
For Each objPerfData in colPerfData
ElapsedTime = objPerfData.ElapsedTime
PercentProcessorTime = objPerfData.PercentProcessorTime
PercentUserTime = objPerfData.PercentUserTime
ThreadCount = objPerfData.ThreadCount
PageFaultsPersec = objPerfData.PageFaultsPersec
IOReadBytesPersec = objPerfData.IOReadBytesPersec
IOWriteBytesPersec = objPerfData.IOWriteBytesPersec
Next
'Elapsed Time
Set oBag = oAPI.CreatePropertyBag()
oBag.AddValue &quot;Object&quot;, &quot;Process&quot;
oBag.AddValue &quot;Instance&quot;, ServiceName
oBag.AddValue &quot;Counter&quot;, &quot;Elapsed Time&quot;
oBag.AddValue &quot;Value&quot;, ElapsedTime
oAPI.AddItem(oBag)

'Percent Processor Time
Set oBag = oAPI.CreatePropertyBag()
oBag.AddValue &quot;Object&quot;, &quot;Process&quot;
oBag.AddValue &quot;Instance&quot;, ServiceName
oBag.AddValue &quot;Counter&quot;, &quot;% Processor Time&quot;
oBag.AddValue &quot;Value&quot;, PercentProcessorTime
oAPI.AddItem(oBag)

'Percent User Time
Set oBag = oAPI.CreatePropertyBag()
oBag.AddValue &quot;Object&quot;, &quot;Process&quot;
oBag.AddValue &quot;Instance&quot;, ServiceName
oBag.AddValue &quot;Counter&quot;, &quot;% User Time&quot;
oBag.AddValue &quot;Value&quot;, PercentUserTime
oAPI.AddItem(oBag)

'Thread Count
Set oBag = oAPI.CreatePropertyBag()
oBag.AddValue &quot;Object&quot;, &quot;Process&quot;
oBag.AddValue &quot;Instance&quot;, ServiceName
oBag.AddValue &quot;Counter&quot;, &quot;Thread Count&quot;
oBag.AddValue &quot;Value&quot;, ThreadCount
oAPI.AddItem(oBag)

'Page Faults/Sec
Set oBag = oAPI.CreatePropertyBag()
oBag.AddValue &quot;Object&quot;, &quot;Process&quot;
oBag.AddValue &quot;Instance&quot;, ServiceName
oBag.AddValue &quot;Counter&quot;, &quot;Page Faults/sec&quot;
oBag.AddValue &quot;Value&quot;, PageFaultsPersec
oAPI.AddItem(oBag)

'IO Read Bytes/sec
Set oBag = oAPI.CreatePropertyBag()
oBag.AddValue &quot;Object&quot;, &quot;Process&quot;
oBag.AddValue &quot;Instance&quot;, ServiceName
oBag.AddValue &quot;Counter&quot;, &quot;IO Read Bytes/sec&quot;
oBag.AddValue &quot;Value&quot;, IOReadBytesPersec
oAPI.AddItem(oBag)

'IO Write Bytes/sec
Set oBag = oAPI.CreatePropertyBag()
oBag.AddValue &quot;Object&quot;, &quot;Process&quot;
oBag.AddValue &quot;Instance&quot;, ServiceName
oBag.AddValue &quot;Counter&quot;, &quot;IO Write Bytes/sec&quot;
oBag.AddValue &quot;Value&quot;, IOWriteBytesPersec
oAPI.AddItem(oBag)
ELSE
'Return an empty property bag
Set oBag = oAPI.CreatePropertyBag()
oAPI.AddItem(oBag)
END IF
oAPI.ReturnItems
[/sourcecode]

As you can see, I’m collecting the following 7 counters in the script:
<ol>
	<li>Elapsed Time</li>
	<li>% Processor Time</li>
	<li>% User Time</li>
	<li>Thread Count</li>
	<li>Page Faults/sec</li>
	<li>IO Read Bytes/sec</li>
	<li>IO Write Bytes/sec</li>
</ol>
You will need to modify the script if you are collecting different counters. for details of the counters you can collect, please refer to Win32_PerfFormattedData_PerfProc_Process class documentation here at MSDN: <a title="http://msdn.microsoft.com/en-us/library/windows/desktop/aa394277(v=vs.85).aspx" href="http://msdn.microsoft.com/en-us/library/windows/desktop/aa394277(v=vs.85).aspx">http://msdn.microsoft.com/en-us/library/windows/desktop/aa394277(v=vs.85).aspx</a>

I’ve attached the script and the sample unsealed management pack at the bottom of this article. You can modify or recreate your own based on the samples. don’t forget to seal the management pack if you want to use the modules in other MPs.

VBScript: <a href="http://blog.tyang.org/wp-content/uploads/2012/01/ProcessPerfMonData.txt">ProcessPerfMonData.txt</a>

Unsealed MP: <a href="http://blog.tyang.org/wp-content/uploads/2012/01/TYANG.Custom.Performance.Monitoring.zip">TYANG.Custom.Performance.Monitoring.xml</a>