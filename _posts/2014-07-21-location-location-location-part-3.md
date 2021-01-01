---
id: 3000
title: Location, Location, Location. Part 3
date: 2014-07-21T02:02:12+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=3000
permalink: /2014/07/21/location-location-location-part-3/
categories:
  - SCOM
tags:
  - Dashboard
  - MP Authoring
  - SCCM
---
<a href="http://blog.tyang.org/wp-content/uploads/2014/07/location-graphic.png"><img style="background-image: none; float: left; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="location-graphic" src="http://blog.tyang.org/wp-content/uploads/2014/07/location-graphic_thumb.png" alt="location-graphic" width="244" height="170" align="left" border="0" /></a>This is the 3rd and the final part of the 3-part series. In this post, I will demonstrate how do I track the physical location history for Windows 8 location aware computers (tablets and laptops), as well as how to visually present the data collected on a OpsMgr 2012 dashboard.

I often see people post of Facebook or Twitter that he or she has checked in at &lt;some places&gt; on Foursquare. I haven’t used Foursquare before (and don’t intend to in the future), I’m not sure what is the purpose of it, but please think this as Four Square in OpsMgr for your tablets <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" src="http://blog.tyang.org/wp-content/uploads/2014/07/wlEmoticon-smile3.png" alt="Smile" />. I will now go through the management pack elements I created to achieve this goal.
<h3>Event Collection Rule: Collect Location Aware Device Coordinate Rule</h3>
So, I firstly need to collect the location data periodically. Therefore, I created an event collection rule targeting the “Location Aware Windows Client Computer” class I created (explained in Part 2 of this series). This rule uses the same data source module as the “Location Aware Device Missing In Action Monitor” which I also explained in Part 2. I have configured this rule to pass the exact same data to the data source module as what the monitor does, – so we can utilise <a href="http://technet.microsoft.com/en-us/library/ff381335.aspx">Cook Down</a> (basically the data source only execute once and feed the output data to both the rule and the monitor).

<a href="http://blog.tyang.org/wp-content/uploads/2014/07/image17.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/07/image_thumb17.png" alt="image" width="414" height="434" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2014/07/image18.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/07/image_thumb18.png" alt="image" width="580" height="302" border="0" /></a>

<strong><span style="color: #ff0000;">Note:</span></strong> Although this rule does not require the home latitude and longitude and these 2 inputs are optional for the data source module, I still pass these 2 values in. Because in order to use Cook Down, both workflows need to pass the exact same data to the data source module. By not doing this, the same script will run twice in each scheduling cycle.

This rule maps the data collected from the data source module to event data, and stores the data in both Ops DB and DW DB. I’ve created a event view in the management pack, you can see the events created:

<a href="http://blog.tyang.org/wp-content/uploads/2014/07/SNAGHTMLb60c734.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="SNAGHTMLb60c734" src="http://blog.tyang.org/wp-content/uploads/2014/07/SNAGHTMLb60c734_thumb.png" alt="SNAGHTMLb60c734" width="580" height="440" border="0" /></a>
<h3>Location History Dashboard</h3>
Now, that the data has been captured and stored in OpsMgr databases as event data, we can consume this data in a dashboard:

<a href="http://blog.tyang.org/wp-content/uploads/2014/07/SNAGHTMLb65f9e4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="SNAGHTMLb65f9e4" src="http://blog.tyang.org/wp-content/uploads/2014/07/SNAGHTMLb65f9e4_thumb.png" alt="SNAGHTMLb65f9e4" width="580" height="325" border="0" /></a>

As shown above, there are 3 widgets in this Location History dashboard:
<ul>
	<li>Top Left: State Widget for Location Aware Windows Client Computer class.</li>
	<li>Bottom Left: Using PowerShell Grid widget to display the last 50 known locations of the selected device from the state widget.</li>
	<li>Right: Using PowerShell Web Browser widget to display the selected historical location from bottom left PowerShell Grid Widget.</li>
</ul>
The last 50 known locations for the selected devices are listed on bottom left section. Users can click on the first column (Number) to sort it based on the time stamp. When a previous location is selected, this location gets pined on the map. So we known exactly where the device is at that point of time. – From now on, I need to make sure my wife doesn’t have access to OpsMgr in my lab so she can’t track me down <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" src="http://blog.tyang.org/wp-content/uploads/2014/07/wlEmoticon-smile3.png" alt="Smile" />.

<strong><span style="color: #ff0000;">Note:</span></strong> the location shown in above screenshot is my office. I took my Surface to work, powered it on and connected to a 4G device, it automatically connected to my lab network using DirectAccess.

<a href="http://blog.tyang.org/wp-content/uploads/2014/07/Surface-in-car.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="Surface in car" src="http://blog.tyang.org/wp-content/uploads/2014/07/Surface-in-car_thumb.png" alt="Surface in car" width="579" height="330" border="0" /></a>

Since this event was collected over 2 days ago, for demonstration purpose, I had to modify the PowerShell grid widget to list a lot more than 50 previous locations.

The script below is what’s used in the bottom left PowerShell Grid widget:

[sourcecode language="Powershell"]
Param($globalSelectedItems)

$i = 1
foreach ($globalSelectedItem in $globalSelectedItems)
{
$MonitoringObjectID = $globalSelectedItem[&quot;Id&quot;]
$MG = Get-SCOMManagementGroup
$globalSelectedItemInstance = Get-SCOMClassInstance -Id $MonitoringObjectID
$Computername = $globalSelectedItemInstance.DisplayName
$strInstnaceCriteria = &quot;FullName='Microsoft.Windows.Computer:$Computername'&quot;
$InstanceCriteria = New-Object Microsoft.EnterpriseManagement.Monitoring.MonitoringObjectGenericCriteria($strInstnaceCriteria)
$Instance = $MG.GetMonitoringObjects($InstanceCriteria)[0]
$Events = Get-SCOMEvent -instance $Instance -EventId 10001 -EventSource &quot;LocationMonitoring&quot; | Where-Object {$_.Parameters[1] -eq 4} |Sort-Object TimeAdded -Descending | Select -First 50
foreach ($Event in $Events)
{
$EventID = $Event.Id.Tostring()
$LocalTime = $Event.Parameters[0]
$LocationStatus = $Event.Parameters[1]
$Latitude = $Event.Parameters[2]
$Longitude = $Event.Parameters[3]
$Altitude = $Event.Parameters[4]
$ErrorRadius = $Event.Parameters[5].trimend(&quot;.&quot;)

$dataObject = $ScriptContext.CreateInstance(&quot;xsd://foo!bar/baz&quot;)
$dataObject[&quot;Id&quot;]=$EventID
$dataObject[&quot;No&quot;]=$i
$dataObject[&quot;LocalTime&quot;]=$LocalTime
$dataObject[&quot;Latitude&quot;]=$Latitude
$dataObject[&quot;Longitude&quot;]=$Longitude
$dataObject[&quot;Altitude&quot;]=$Altitude
$dataObject[&quot;ErrorRadius (Metres)&quot;]=$ErrorRadius
$ScriptContext.ReturnCollection.Add($dataObject)
$i++
}
}
[/sourcecode]

&nbsp;

And here’s the script for the PowerShell Web Browser Widget:

[sourcecode language="Powershell"]
Param($globalSelectedItems)

$dataObject = $ScriptContext.CreateInstance(&quot;xsd://Microsoft.SystemCenter.Visualization.Component.Library!Microsoft.SystemCenter.Visualization.Component.Library.WebBrowser.Schema/Request&quot;)
$dataObject[&quot;BaseUrl&quot;]=&quot;&lt;a href=&quot;http://maps.google.com/maps&amp;quot;&quot;&gt;http://maps.google.com/maps&quot;&lt;/a&gt;
$parameterCollection = $ScriptContext.CreateCollection(&quot;xsd://Microsoft.SystemCenter.Visualization.Component.Library!Microsoft.SystemCenter.Visualization.Component.Library.WebBrowser.Schema/UrlParameter[]&quot;)
foreach ($globalSelectedItem in $globalSelectedItems)
{
$EventID = $globalSelectedItem[&quot;Id&quot;]
$Event = Get-SCOMEvent -Id $EventID
If ($Event)
{
$bIsEvent = $true
$Latitude = $Event.Parameters[2]
$Longitude = $Event.Parameters[3]

$parameter = $ScriptContext.CreateInstance(&quot;xsd://Microsoft.SystemCenter.Visualization.Component.Library!Microsoft.SystemCenter.Visualization.Component.Library.WebBrowser.Schema/UrlParameter&quot;)
$parameter[&quot;Name&quot;] = &quot;q&quot;
$parameter[&quot;Value&quot;] = &quot;loc:&quot; + $Latitude + &quot;+&quot; + $Longitude
$parameterCollection.Add($parameter)
} else {
$bIsEvent = $false
}
}
If ($bIsEvent)
{
$dataObject[&quot;Parameters&quot;]= $parameterCollection
$ScriptContext.ReturnCollection.Add($dataObject)
}
[/sourcecode]

<h3>Conclusion</h3>
This concludes the 3rd and the final part of the series. I know it is only a proof-of-concept. I’m not sure how practical it is if we are to implement this in a corporate environment. i.e. Since most of the current Windows tablets don’t have GPS receivers built-in, I’m not sure and haven’t been able to test how well does the Windows Location Provider calculate locations when a device is connected to a corporate Wi-Fi.

I have also noticed what seems to be a known issue with the Windows Location Provider COM object <a href="http://msdn.microsoft.com/en-us/library/windows/desktop/dd317709(v=vs.85).aspx">LocationDisp.LatLongReportFactory</a>. it doesn’t always return a valid location report. Therefore to work around the issue, I had to code all the scripts to retry and wait between attempts. I managed to get the script to work on all my devices. However, you may need to tweak the scripts if you don’t always get valid location reports.
<h3>Credit</h3>
Other than the VBScript I mentioned in Part 2, I was lucky enough to find <a href="http://www.verboon.info/tag/windows-location-provider/">this PowerShell script</a>. I used this script as the starting point for all my scripts.

Also, when I was trying to setup DirectAccess to get my lab ready for this experiment, I got a lot of help from Enterprise Security MVP Richard Hick’s blog: <a title="http://directaccess.richardhicks.com" href="http://directaccess.richardhicks.com">http://directaccess.richardhicks.com</a>. So thanks to Richard <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" src="http://blog.tyang.org/wp-content/uploads/2014/07/wlEmoticon-smile3.png" alt="Smile" />.
<h3>Download</h3>
You can download the actual monitoring MP and dashboard MP, as well as all the scripts I used in the MP and dashboards <a href="http://blog.tyang.org/wp-content/uploads/2014/07/Location-Location-Location.zip"><strong>HERE</strong></a>.

<strong><span style="color: #ff0000;">Note:</span></strong> For the monitoring MP (Location.Aware.Devices.Monitoring), I’ve also included the unsealed version in the zip file for your convenience (so you don’t have to unseal it if you want to look inside). Please do not import it into your management group because the dashboard MP is referencing it, therefore it has to be sealed.

Lastly, as always, I’d like to hear from the community. Please feel free to share your thoughts with me by leaving comments in the post or contacting me via email. Until next time, happy SCOMMING <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" src="http://blog.tyang.org/wp-content/uploads/2014/07/wlEmoticon-smile3.png" alt="Smile" />.