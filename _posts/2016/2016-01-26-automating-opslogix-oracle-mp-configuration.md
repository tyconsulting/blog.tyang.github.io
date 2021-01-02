---
id: 5153
title: Automating OpsLogix Oracle MP Configuration
date: 2016-01-26T10:09:51+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=5153
permalink: /2016/01/26/automating-opslogix-oracle-mp-configuration/
categories:
  - PowerShell
  - SCOM
tags:
  - OpsLogix
  - PowerShell
  - SCOM
---
<h3>Introduction</h3>
One of the flagship management packs from OpsLogix is the <a href="http://www.opslogix.com/oracle-management-pack/">Oracle Database MP</a>. This MP provides several GUI driven wizard to help you creating your own monitoring solutions for Oracle by leveraging the OpsMgr management pack templates (<a title="https://technet.microsoft.com/en-au/library/hh457614.aspx" href="https://technet.microsoft.com/en-au/library/hh457614.aspx">https://technet.microsoft.com/en-au/library/hh457614.aspx</a>). At this stage, the OpsLogix Oracle MP provides the following templates:

<strong>01. Oracle Alert Rule template</strong>

This template allows you to create a rule that checks a value from your oracle environment and generate alerts in the event that the value is detected or missing, depending on the configuration you have specified.

<strong>02. Oracle Performance Collection Rule template</strong>

This template allows you to create a rule that will collect performance data from your Oracle environment in order to visualize data on the performance view and reports.

<strong>03. Oracle Two-State Monitor Template</strong>

This template allows you to create a monitor that will check the health of an element according to the configuration that you have specified in the wizard. It will generate alerts when the monitor becomes unhealthy.

Like any other OpsMgr management pack templates, the above mentioned templates can be found in the Authoring pane of the OpsMgr console, under "Management Pack Templates":

<a href="http://blog.tyang.org/wp-content/uploads/2016/01/image-12.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/01/image_thumb-12.png" alt="image" width="589" height="408" border="0" /></a>
<h3>Some Background on Management Pack Templates</h3>
The MP templates provide great ways for users to create complex monitoring scenarios without having to use MP authoring tools such as VSAE or Silect MPAuthor. The MP templates are designed to satisfy specific monitoring needs (i.e. Windows service monitoring, TCP Port monitoring etc.). From an OpsMgr admin and operator point of view, they are great, because each template provides a user friendly GUI driven wizard for you to create your monitoring solutions.

From a MP developer point of view, these templates are not easy to create – not only because you need to define the templates in the MP, but most of time, you also need to design the UI pages to be used in the wizard, which is very time consuming (not to mention these UI pages are written in C#). I have done it several times, and believe me, they are not easy! So every time when I see a MP offers management pack templates, I really appreciate the effort put in by the developers.

Although I think the management pack templates provides a user friendly GUI driven wizard for users to create their monitoring solutions, in my opinion, the biggest drawback is <i>also</i> the GUI wizard. It means you HAVE TO use the GUI wizard – it may become an issue when you have a lot of stuff to configure.

Let me give you an example based on my own experience. A few months ago, I was away attending a conference overseas and a customer needed to create hundreds of instances for the Windows Service monitoring template. Because they didn’t want to wait for my return, I was told someone spent a <b>few days</b> clicking through the wizard many, many times.

So what other options do we have? Fortunately, the management pack template instances can be created via OpsMgr SDK.
<h3>Automating MP Template Instance Creation</h3>
If you have been following my blog series "<a href="http://blog.tyang.org/blog.tyang.org/tag/automating-opsmgr/">Automating OpsMgr</a>", you may have already read <a href="http://blog.tyang.org/2015/10/04/automating-opsmgr-part-17-creating-windows-service-management-pack-template-instance/">Part 17 of this series: Creating Windows Service Management Pack Template Instance</a>, where I demonstrated a runbook leveraging the <a href="http://www.tyconsulting.com.au/portfolio/opsmgrextended-powershell-and-sma-module/">OpsMgrExtended PowerShell module</a> and enabled people to create a management pack template instance (in this case, the Windows Service template) using one line of PowerShell script. This was a great example on how to create the template instances in mass scales.

OK, let’s go back to the OpsLogix Oracle MP… Just to put it out there, my experience with Oracle DB is very limited. Throughout the years I spent in IT, I’ve only been dealing with Microsoft’s SQL servers. Based on my experience with SQL, I know that every DBA will have a set of queries they regularly use to monitor their SQL environments. I assume this is also the case for Oracle. So, one of the first concerns I had when I started playing with this MP is, creating user defined monitoring scenarios could be very time consuming when using the management pack template wizards. Therefore, I spent few hours today, and produced 3 separate PowerShell functions that people can use to create instances for the 3 templates mentioned above. These functions are:
<ol>
	<li><strong>New-OpsLogixOracleAlertTemplateInstance</strong></li>
	<li><strong>New-OpsLogixOraclePerfTemplateInstance</strong></li>
	<li><strong>New-OpsLogixOracle2StateMonitorTemplateInstance</strong></li>
</ol>
<strong>Pre-requisites:</strong>

These functions requires the <a href="http://www.tyconsulting.com.au/portfolio/opsmgrextended-powershell-and-sma-module/">OpsMgrExtended Module</a> on the computer where you are running the script. Please follow the instruction and setup this module first.

<strong>Download Link:</strong>

I have uploaded the code for above mentioned PowerShell functions to Github. You can download them from <a title="https://github.com/tyconsulting/OpsMgr-SDK-Scripts/tree/master/OpsLogix%20Oracle%20MP%20Scripts" href="https://github.com/tyconsulting/OpsMgr-SDK-Scripts/tree/master/OpsLogix%20Oracle%20MP%20Scripts">https://github.com/tyconsulting/OpsMgr-SDK-Scripts/tree/master/OpsLogix%20Oracle%20MP%20Scripts</a>

Now, let’s test them, I will use the –verbose switch when calling these functions so you can see the verbose messages.

<strong>01. Creating a test MP</strong>

Firstly, I’ll create a test MP using the <strong>New-OMManagementPack</strong> command from the OpsMgrExtended module:
```powershell
New-OMManagementPack -SDK "OMMS01" -Name "TYANG.OpsLogix.Test" -DisplayName "TYANG OpsLogix Test MP" -Description "Custom MP for OpsLogix test MP" -Version 1.0.0.0 –Verbose

```
<a href="http://blog.tyang.org/wp-content/uploads/2016/01/image-13.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/01/image_thumb-13.png" alt="image" width="651" height="131" border="0" /></a>

<strong>02. Create an instance for the alert rule template (using PowerShell Splatting)</strong>

Calling the New-OpsLogixOracleAlertTemplateInstance function:

<a href="http://blog.tyang.org/wp-content/uploads/2016/01/image-14.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/01/image_thumb-14.png" alt="image" width="650" height="460" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2016/01/SNAGHTML7af883b.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML7af883b" src="http://blog.tyang.org/wp-content/uploads/2016/01/SNAGHTML7af883b_thumb.png" alt="SNAGHTML7af883b" width="528" height="318" border="0" /></a>

<strong>03. Create an instance for the performance collection template</strong>

Calling the New-OpsLogixOraclePerfTemplateInstance function:

<a href="http://blog.tyang.org/wp-content/uploads/2016/01/image-15.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/01/image_thumb-15.png" alt="image" width="650" height="386" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2016/01/SNAGHTML7b050da.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML7b050da" src="http://blog.tyang.org/wp-content/uploads/2016/01/SNAGHTML7b050da_thumb.png" alt="SNAGHTML7b050da" width="526" height="315" border="0" /></a>

<strong>04. Create an instance for the Two-State Monitor template</strong>

Calling the New-OpsLogixOracle2StateMonitorTemplateInstance function:

<a href="http://blog.tyang.org/wp-content/uploads/2016/01/image-16.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/01/image_thumb-16.png" alt="image" width="650" height="467" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2016/01/SNAGHTML7b1236d.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML7b1236d" src="http://blog.tyang.org/wp-content/uploads/2016/01/SNAGHTML7b1236d_thumb.png" alt="SNAGHTML7b1236d" width="538" height="322" border="0" /></a>

<strong>Note:</strong> There is also a test.ps1 script in this Github repository. It contains the test parameters used as shown in the screenshots above.
<h3>Conclusion</h3>
As you may have noticed, these functions also have a parameter set to support the SMA / Azure Automation connection object (defined in the OpsMgrExtended Module). If you are planning to make this part of your automation solution, you can simply change this from a PowerShell function to a runbook and use the –SDKConnection parameter to establish connection to the management group. this should be very straightforward; you can refer to my previous post on the Automating OpsMgr blog series for more details.

I hope these functions will help customers who are deploying Oracle monitoring solutions using OpsLogix Oracle MP. For example, if you need to create a lot of these instances, you can create a CSV file with all the required parameters and values, and then create a very simple PowerShell script to read the CSV file and then call the appropriate functions. I’ve done the hard work for you, the rest should be pretty easy  <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" src="http://blog.tyang.org/wp-content/uploads/2016/01/wlEmoticon-smile-1.png" alt="Smile" />.

Lastly, if anyone would like to evaluate the OpsLogix Oracle MP, they can be contacted via email <a href="mailto:sales@opslogix.com">sales@opslogix.com</a>