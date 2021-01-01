---
id: 3022
title: 'OpsMgr 2012: A Trick to Drive Another Contextual Widget From PowerShell Grid Widget'
date: 2014-07-23T22:17:07+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=3022
permalink: /2014/07/23/opsmgr-2012-trick-drive-another-contextual-widget-powershell-grid-widget/
categories:
  - SCOM
tags:
  - Dashboard
  - Powershell
  - SCOM
---
PowerShell Grid widget and PowerShell Web Browser Widget were released as part of OpsMgr 2012 SP1 UR6 and R2 UR2. To me, these two widgets have opened a window of opportunities, because by using PowerShell, it allows OpsMgr 2012 users to customise and present the data exactly the way they wanted on dashboards.

Since it has been released, many people have share their work. Recently, Microsoft has started a <a href="http://blog.tyang.org/2014/07/23/new-opsmgr-2012-dashboards-repository-technet-gallery/">new repository</a> for the PowerShell widgets in TechNet Gallery.

The best article for the PowerShell Grid Widget that I have seen so far is from <a href="http://ok-sandbox.com/2014/05/scom-powershell-grid-widget-mere-mortals/">Oleg Kapustin’s blog: SCOM Powershell Grid Widget for Mere Mortals</a>. In Oleg’s article (and seems to be a common practice), for each item that to be listed by the PowerShell Grid Widget, a unique Id is assigned to it (an auto incremented number):

<a href="http://blog.tyang.org/wp-content/uploads/2014/07/image20.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/07/image_thumb20.png" alt="image" width="580" height="254" border="0" /></a>

Today, I want to share a small trick with you, something I’ve only picked up couple of days ago when I was writing the Location History dashboard for the <a href="http://blog.tyang.org/2014/07/21/location-location-location-part-3/">3rd part of my Location, Location, Location series</a>. This is what the dashboard looks like:

<a href="http://blog.tyang.org/wp-content/uploads/2014/07/SNAGHTML52cdecf.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="SNAGHTML52cdecf" src="http://blog.tyang.org/wp-content/uploads/2014/07/SNAGHTML52cdecf_thumb.png" alt="SNAGHTML52cdecf" width="580" height="326" border="0" /></a>

On this dashboard, users suppose to make their way from section 1 (state widget) to section 2 (PowerShell Grid Widget) and finally to section 3 (PowerShell Web Browser Widget). The PowerShell script in section 2 retrieves particular events generated by the object from section 1 using OpsMgr cmdlets, then display the data on this customised list. This script is listed below:

[sourcecode language="PowerShell"]
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

Because I need to drive the contextual PowerShell Web Browser widget (section 3) from the PowerShell Grid Widget (section 2), the script used in section 3 needs to locate the exact event selected in section 2. As per Oleg’s article, based on his experiment, the only property passed between widgets is the “Id” property (of the data object). therefore, instead of using an auto increment number as the value for “Id” property as demonstrated in the previous screenshot from Oleg’s blog, I assigned the actual event Id as the data object Id so script in section 3 can use the event ID to retrieve data from the particular event.

From Section 2:

<a href="http://blog.tyang.org/wp-content/uploads/2014/07/image21.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/07/image_thumb21.png" alt="image" width="475" height="298" border="0" /></a>

From Section 3:

<a href="http://blog.tyang.org/wp-content/uploads/2014/07/image22.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/07/image_thumb22.png" alt="image" width="453" height="421" border="0" /></a>

<strong><span style="font-size: large;">Conclusion</span></strong>

Please keep in mind, the only property (and its value) for $globalselectedItems that travels between contextual widgets is “Id” property. if you want to drive another contextual widget based on the data passed from a PowerShell Grid Widget, please make sure you use the actual Id of the OpsMgr object (monitoring object, class, event, alert, etc…) so the next widget can use this Id to retrieve the object from OpsMgr.