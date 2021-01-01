---
id: 2961
title: Location, Location, Location. Part 1
date: 2014-07-21T01:45:00+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=2961
permalink: /2014/07/21/location-location-location-part-1/
categories:
  - SCOM
tags:
  - Dashboard
  - MP Authoring
  - SCOM
---
<a href="http://blog.tyang.org/wp-content/uploads/2014/07/iStock_000006260161Small.jpg"><img style="background-image: none; float: left; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="iStock_000006260161Small" src="http://blog.tyang.org/wp-content/uploads/2014/07/iStock_000006260161Small_thumb.jpg" alt="iStock_000006260161Small" width="244" height="165" align="left" border="0" /></a>Yes, I am starting to write a 3 part series on this topic: Location, Location, Location. It is not about real estate business – It would be silly for me to wait until I’ve received MVP award to become a real estate salesman, right? <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" src="http://blog.tyang.org/wp-content/uploads/2014/07/wlEmoticon-smile2.png" alt="Smile" />

This series is all about tracking physical location for Windows based mobile devices (tablets and laptops). It involves windows tablets/ laptops, OpsMgr 2012, dashboards, Google Maps and Windows Location Platform. Does this interest you? if so, please continue reading. <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" src="http://blog.tyang.org/wp-content/uploads/2014/07/wlEmoticon-smile2.png" alt="Smile" />
<h3>Background</h3>
When I started designing the OpsMgr 2012 infrastructure for my employer about a 18 months ago, during requirements gathering phase, Windows tablets were seriously in the scope of devices to be monitored by OpsMgr. At that time, I thought it doesn’t make any sense having OpsMgr 2012 to monitor thousands of Windows tablets. Now, 18 months later, with more and more organisations started to adopt Windows 8 tablets into corporate environments, I thought I’d spend a little bit time on this and see what we can get out of OpsMgr if Windows 8 tablets and laptops are being monitored in OpsMgr 2012.

Since most of the modern devices are location aware, wouldn’t it be nice if we can use SCOM to monitor their physical locations? I had this idea after I posted the <a href="http://blog.tyang.org/2014/05/24/opsmgr-dashboard-fun-google-maps/">Google Map dashboard</a> couple of months ago. Now that FIFA World Cup is over and my life is back to normal, I finally had time to spend on it.
<h3>Introduction</h3>
One important aspect of tablets and laptops is being mobile. physical security has always been a big concern for organisations. By utilising Windows Location Framework, OpsMgr agent and dashboards, I managed to produce 3 scenarios in my lab. I will cover each one of them in one part of this series:
<ul>
	<li>Part 1: Track Windows 8 computers current location (real time)</li>
	<li>Part 2: Monitor the physical location (In case it’s gone M.I.A)</li>
	<li>Part 3: Track historical locations (where have they been?)</li>
</ul>
<strong><span style="color: #ff0000;">Note:</span></strong> The management packs I created for this experiment can be downloaded at the end of part 3.
<h3>Pre-requisites</h3>
To prepare my lab of these monitoring scenarios, I had to setup the following pre-requisites:

01. Setup DirectAccess for my home lab so my Surface Pro 2 would automatically connect to my lab when it is not at home (i.e. via a 4G connection).

02. Rebuilt my Surface Pro 2 to Windows 8.1 Enterprise edition. – As DirectAccess client is only available in Enterprise edition.

03. Made sure Windows Location Platform is enabled on Surface Pro 2. This is configured in Control Panel:

<a href="http://blog.tyang.org/wp-content/uploads/2014/07/image9.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/07/image_thumb9.png" alt="image" width="364" height="172" border="0" /></a>

and Privacy settings:

<a href="http://blog.tyang.org/wp-content/uploads/2014/07/image10.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/07/image_thumb10.png" alt="image" width="359" height="149" border="0" /></a>

We can also use GPO to enable it: Computer Configuration\Administrative Templates\Windows Components\Location and Sensors

<a href="http://blog.tyang.org/wp-content/uploads/2014/07/image11.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/07/image_thumb11.png" alt="image" width="366" height="366" border="0" /></a>

04. Make sure WinRM is enabled on the mobile devices. A PowerShell script I used in a dashboard uses WinRM to get the devices location report.

Additionally, I already have OpsMgr 2012 R2 agent installed on my Surface Pro 2 and it is reporting to my home management group. The latest OpsMgr 2012 Update Rollup (SP1 UR6 or R2 UR2) also needs to be installed in order to use the new PowerShell dashboard widgets.
<h3>Limitations – Lack of GPS Devices</h3>
When I started working on this experiment, I found my Surface Pro 2 does not have a GPS receiver (And Surface Pro 3 also doesn’t have it <img class="wlEmoticon wlEmoticon-sadsmile" style="border-style: none;" src="http://blog.tyang.org/wp-content/uploads/2014/07/wlEmoticon-sadsmile.png" alt="Sad smile" />). Then I also found most of the Windows 8 tablets currently out in the market don’t have GPS receivers built-in. I haven’t been able to find one with GPS receivers. Therefore, the location data provided by Windows Location API come from Wi-Fi triangulation, IP address resolution and cellular network triangulation, which is probably less accurate than GPS data (More details can be found on MSDN:<a title="http://msdn.microsoft.com/en-us/library/windows/apps/hh464919.aspx" href="http://msdn.microsoft.com/en-us/library/windows/apps/hh464919.aspx">http://msdn.microsoft.com/en-us/library/windows/apps/hh464919.aspx</a>). I didn’t want to purchase a Windows 8 compatible GPS receiver because I have no real need for it after this experiment, and also tried to use my Android phone as a bluetooth GPS receiver to the Windows 8 devices, but I couldn’t make it work.

Having said that, based on my experience, the data received from cellular and Wi-Fi network is fairly accurate for me. When I’m at home, the location on the map is my neighbour across the road, which is less than 20 metres away from my desk.
<h3>Scenario 1: Where is the the device currently located?</h3>
I created a fairly simply dashboard in OpsMgr to pinpoint the current location of a selected:

<a href="http://blog.tyang.org/wp-content/uploads/2014/07/SNAGHTMLa18e258.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="SNAGHTMLa18e258" src="http://blog.tyang.org/wp-content/uploads/2014/07/SNAGHTMLa18e258_thumb.png" alt="SNAGHTMLa18e258" width="580" height="338" border="0" /></a>

(Sorry guys, I pixelated the map as I don’t really want to post my home location on the Internet <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" src="http://blog.tyang.org/wp-content/uploads/2014/07/wlEmoticon-smile2.png" alt="Smile" />).

As you can see, this dashboard only contains 2 widgets. the left widget is a state widget targeting “<strong>Windows Client 8 Computer</strong>” class:

<a href="http://blog.tyang.org/wp-content/uploads/2014/07/SNAGHTMLa1bd8f3.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="SNAGHTMLa1bd8f3" src="http://blog.tyang.org/wp-content/uploads/2014/07/SNAGHTMLa1bd8f3_thumb.png" alt="SNAGHTMLa1bd8f3" width="405" height="296" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2014/07/SNAGHTMLa1c63fd.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="SNAGHTMLa1c63fd" src="http://blog.tyang.org/wp-content/uploads/2014/07/SNAGHTMLa1c63fd_thumb.png" alt="SNAGHTMLa1c63fd" width="406" height="224" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2014/07/SNAGHTMLa1ced71.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="SNAGHTMLa1ced71" src="http://blog.tyang.org/wp-content/uploads/2014/07/SNAGHTMLa1ced71_thumb.png" alt="SNAGHTMLa1ced71" width="408" height="295" border="0" /></a>

<strong><span style="color: #ff0000;">Note:</span></strong> Because I’m referencing Windows 8 computers, I have Windows 8 management packs (<a href="http://www.microsoft.com/en-us/download/details.aspx?id=38434">version 6.0.7024.0</a>) loaded in my management group. Since all the client computers in my lab are running 8.1, I have also installed the <a href="http://blogs.technet.com/b/kevinholman/archive/2014/04/01/windows-8-client-os-mp-doesn-t-discover-windows-8-1.aspx">Windows 8 Addendum MP from Kevin Holman</a> as the original one does not discover Windows 8.1.

The widget on the right is a PowerShell Web Browser widget (shipped with SP1 UR6 and R2 UR2). This widget runs the script below:

[sourcecode language="Powershell"]
Param($globalSelectedItems)
$dataObject = $ScriptContext.CreateInstance(&quot;xsd://Microsoft.SystemCenter.Visualization.Component.Library!Microsoft.SystemCenter.Visualization.Component.Library.WebBrowser.Schema/Request&quot;)
$dataObject[&quot;BaseUrl&quot;]=&quot;&lt;a href=&quot;http://maps.google.com/maps&amp;quot;&quot;&gt;http://maps.google.com/maps&quot;&lt;/a&gt;
$parameterCollection = $ScriptContext.CreateCollection(&quot;xsd://Microsoft.SystemCenter.Visualization.Component.Library!Microsoft.SystemCenter.Visualization.Component.Library.WebBrowser.Schema/UrlParameter[]&quot;)
foreach ($globalSelectedItem in $globalSelectedItems)
{
$globalSelectedItemInstance = Get-SCOMClassInstance -Id $globalSelectedItem[&quot;Id&quot;]
$DNSNameProperty = $globalSelectedItemInstance.GetMonitoringProperties() | Where-Object {$_.name -match &quot;^DNSName$&quot;}
$DNSName = $globalSelectedItemInstance.GetMonitoringPropertyValue($DNSNameProperty)

#Get Coordinates via WinRM

#Create a WinRM session to the remote computer
$RemoteSession = New-PSSession -ComputerName $DNSName
$objRemoteLoc = Invoke-command -scriptblock {
# Windows Location API
$mylocation = new-object -comObject LocationDisp.LatLongReportFactory
#$mylocation.ListenForReports(1000)

# Get Status
$mylocationstatus = $mylocation.status

#try again if first attemp is not successful
if ($mylocationstatus -ne 4)
{
#Remove-Variable mylocation
Start-Sleep -Seconds 5
$mylocation = new-object -comObject LocationDisp.LatLongReportFactory
$mylocationstatus = $mylocation.status
}
If ($mylocationstatus -eq 4)
{
# Windows Location Status returns 4, so we're &quot;Running&quot;
# Get Latitude and Longitude from LatlongReport property
$latitude = $mylocation.LatLongReport.Latitude
$longitude = $mylocation.LatLongReport.Longitude
$altitude = $mylocation.LatLongReport.altitude
$errorRadius = $mylocation.LatLongReport.ErrorRadius
}

#Pass invalid values if location is not detected
If ($latitude -eq $null -or $longitude -eq $null)
{
$bValidLoc = $false
} else {
$bValidLoc = $true
}

#Return Data
$objLoc = New-Object psobject
Add-Member -InputObject $objLoc -membertype noteproperty -name &quot;ValidLocation&quot; -value $bValidLoc
Add-Member -InputObject $objLoc -membertype noteproperty -name &quot;LocationStatus&quot; -value $mylocationstatus
Add-Member -InputObject $objLoc -membertype noteproperty -name &quot;latitude&quot; -value $latitude
Add-Member -InputObject $objLoc -membertype noteproperty -name &quot;longitude&quot; -value $longitude
Add-Member -InputObject $objLoc -membertype noteproperty -name &quot;altitude&quot; -value $altitude
Add-Member -InputObject $objLoc -membertype noteproperty -name &quot;errorRadius&quot; -value $errorRadius
$objLoc
} -Session $RemoteSession
$latitude = $objRemoteLoc | select -ExpandProperty latitude
$longitude = $objRemoteLoc | select -ExpandProperty longitude
$ValidLocation = $objRemoteLoc | select -ExpandProperty ValidLocation
$parameter = $ScriptContext.CreateInstance(&quot;xsd://Microsoft.SystemCenter.Visualization.Component.Library!Microsoft.SystemCenter.Visualization.Component.Library.WebBrowser.Schema/UrlParameter&quot;)
$parameter[&quot;Name&quot;] = &quot;q&quot;
$parameter[&quot;Value&quot;] = &quot;loc:&quot; + $latitude + &quot;+&quot; + $longitude
$parameterCollection.Add($parameter)
Remove-PSSession $RemoteSession
}
$dataObject[&quot;Parameters&quot;]= $parameterCollection
$ScriptContext.ReturnCollection.Add($dataObject)
[/sourcecode]

This script establishes a PS Remote session (WinRM) and retrieve computer’s coordinates using <strong>LocationDisp.LatLongReportFactory</strong> COM object. the coordinates then get passed back to the local PS session and then got pinned on Google Map based on the latitude and longitude data.

This concludes part 1 of the series. Please continue to <a href="http://blog.tyang.org/2014/07/21/location-location-location-part-2/">Part 2</a>.