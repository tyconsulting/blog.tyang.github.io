---
id: 3000
title: Location, Location, Location. Part 3
date: 2014-07-21T02:02:12+10:00
author: Tao Yang
#layout: post
excerpt: ""
header:
  overlay_image: /wp-content/uploads/2014/07/location-graphic.png
  overlay_filter: 0.5 # same as adding an opacity of 0.5 to a black background
guid: https://blog.tyang.org/?p=3000
permalink: /2014/07/21/location-location-location-part-3/
categories:
  - SCOM
tags:
  - Dashboard
  - MP Authoring
  - SCCM
---

This is the 3rd and the final part of the 3-part series. In this post, I will demonstrate how do I track the physical location history for Windows 8 location aware computers (tablets and laptops), as well as how to visually present the data collected on a OpsMgr 2012 dashboard.

I often see people post of Facebook or Twitter that he or she has checked in at *some places* on Foursquare. I haven’t used Foursquare before (and don’t intend to in the future), I’m not sure what is the purpose of it, but please think this as Four Square in OpsMgr for your tablets :smiley:. I will now go through the management pack elements I created to achieve this goal.

## Event Collection Rule: Collect Location Aware Device Coordinate Rule

So, I firstly need to collect the location data periodically. Therefore, I created an event collection rule targeting the "Location Aware Windows Client Computer" class I created (explained in Part 2 of this series). This rule uses the same data source module as the "Location Aware Device Missing In Action Monitor" which I also explained in Part 2. I have configured this rule to pass the exact same data to the data source module as what the monitor does, – so we can utilise [Cook Down](http://technet.microsoft.com/en-us/library/ff381335.aspx) (basically the data source only execute once and feed the output data to both the rule and the monitor).

![](https://blog.tyang.org/wp-content/uploads/2014/07/image17.png)

>**Note:** Although this rule does not require the home latitude and longitude and these 2 inputs are optional for the data source module, I still pass these 2 values in. Because in order to use Cook Down, both workflows need to pass the exact same data to the data source module. By not doing this, the same script will run twice in each scheduling cycle.

This rule maps the data collected from the data source module to event data, and stores the data in both Ops DB and DW DB. I’ve created a event view in the management pack, you can see the events created:

![](https://blog.tyang.org/wp-content/uploads/2014/07/SNAGHTMLb60c734.png)

## Location History Dashboard

Now, that the data has been captured and stored in OpsMgr databases as event data, we can consume this data in a dashboard:

![](https://blog.tyang.org/wp-content/uploads/2014/07/SNAGHTMLb65f9e4.png)

As shown above, there are 3 widgets in this Location History dashboard:

* Top Left: State Widget for Location Aware Windows Client Computer class.
* Bottom Left: Using PowerShell Grid widget to display the last 50 known locations of the selected device from the state widget.
* Right: Using PowerShell Web Browser widget to display the selected historical location from bottom left PowerShell Grid Widget.

The last 50 known locations for the selected devices are listed on bottom left section. Users can click on the first column (Number) to sort it based on the time stamp. When a previous location is selected, this location gets pined on the map. So we known exactly where the device is at that point of time. – From now on, I need to make sure my wife doesn’t have access to OpsMgr in my lab so she can’t track me down :smiley:.

>**Note:** the location shown in above screenshot is my office. I took my Surface to work, powered it on and connected to a 4G device, it automatically connected to my lab network using DirectAccess.

![](https://blog.tyang.org/wp-content/uploads/2014/07/Surface-in-car.png)

Since this event was collected over 2 days ago, for demonstration purpose, I had to modify the PowerShell grid widget to list a lot more than 50 previous locations.

The script below is what’s used in the bottom left PowerShell Grid widget:

```powershell
Param($globalSelectedItems)

$i = 1
foreach ($globalSelectedItem in $globalSelectedItems)
{
  $MonitoringObjectID = $globalSelectedItem["Id"]
  $MG = Get-SCOMManagementGroup
  $globalSelectedItemInstance = Get-SCOMClassInstance -Id $MonitoringObjectID
  $Computername = $globalSelectedItemInstance.DisplayName
  $strInstnaceCriteria = "FullName='Microsoft.Windows.Computer:$Computername'"
  $InstanceCriteria = New-Object Microsoft.EnterpriseManagement.Monitoring.MonitoringObjectGenericCriteria($strInstnaceCriteria)
  $Instance = $MG.GetMonitoringObjects($InstanceCriteria)[0]
  $Events = Get-SCOMEvent -instance $Instance -EventId 10001 -EventSource "LocationMonitoring" | Where-Object {$_.Parameters[1] -eq 4} |Sort-Object TimeAdded -Descending | Select -First 50
  foreach ($Event in $Events)
  {
    $EventID = $Event.Id.Tostring()
    $LocalTime = $Event.Parameters[0]
    $LocationStatus = $Event.Parameters[1]
    $Latitude = $Event.Parameters[2]
    $Longitude = $Event.Parameters[3]
    $Altitude = $Event.Parameters[4]
    $ErrorRadius = $Event.Parameters[5].trimend(".")

    $dataObject = $ScriptContext.CreateInstance("xsd://foo!bar/baz")
    $dataObject["Id"]=$EventID
    $dataObject["No"]=$i
    $dataObject["LocalTime"]=$LocalTime
    $dataObject["Latitude"]=$Latitude
    $dataObject["Longitude"]=$Longitude
    $dataObject["Altitude"]=$Altitude
    $dataObject["ErrorRadius (Metres)"]=$ErrorRadius
    $ScriptContext.ReturnCollection.Add($dataObject)
    $i++
  }
}
```

And here’s the script for the PowerShell Web Browser Widget:

```powershell
Param($globalSelectedItems)

$dataObject = $ScriptContext.CreateInstance("xsd://Microsoft.SystemCenter.Visualization.Component.Library!Microsoft.SystemCenter.Visualization.Component.Library.WebBrowser.Schema/Request")
$dataObject["BaseUrl"]="http://maps.google.com/maps"
$parameterCollection = $ScriptContext.CreateCollection("xsd://Microsoft.SystemCenter.Visualization.Component.Library!Microsoft.SystemCenter.Visualization.Component.Library.WebBrowser.Schema/UrlParameter[]")
foreach ($globalSelectedItem in $globalSelectedItems)
{
  $EventID = $globalSelectedItem["Id"]
  $Event = Get-SCOMEvent -Id $EventID
  If ($Event)
  {
    $bIsEvent = $true
    $Latitude = $Event.Parameters[2]
    $Longitude = $Event.Parameters[3]

    $parameter = $ScriptContext.CreateInstance("xsd://Microsoft.SystemCenter.Visualization.Component.Library!Microsoft.SystemCenter.Visualization.Component.Library.WebBrowser.Schema/UrlParameter")
    $parameter["Name"] = "q"
    $parameter["Value"] = "loc:" + $Latitude + "+" + $Longitude
    $parameterCollection.Add($parameter)
  } else {
    $bIsEvent = $false
  }
}
If ($bIsEvent)
{
  $dataObject["Parameters"]= $parameterCollection
  $ScriptContext.ReturnCollection.Add($dataObject)
}
```

## Conclusion

This concludes the 3rd and the final part of the series. I know it is only a proof-of-concept. I’m not sure how practical it is if we are to implement this in a corporate environment. i.e. Since most of the current Windows tablets don’t have GPS receivers built-in, I’m not sure and haven’t been able to test how well does the Windows Location Provider calculate locations when a device is connected to a corporate Wi-Fi.

I have also noticed what seems to be a known issue with the Windows Location Provider COM object [LocationDisp.LatLongReportFactory](http://msdn.microsoft.com/en-us/library/windows/desktop/dd317709(v=vs.85).aspx). it doesn’t always return a valid location report. Therefore to work around the issue, I had to code all the scripts to retry and wait between attempts. I managed to get the script to work on all my devices. However, you may need to tweak the scripts if you don’t always get valid location reports.

## Credit

Other than the VBScript I mentioned in Part 2, I was lucky enough to find this [PowerShell script](http://www.verboon.info/tag/windows-location-provider/). I used this script as the starting point for all my scripts.

Also, when I was trying to setup DirectAccess to get my lab ready for this experiment, I got a lot of help from Enterprise Security MVP Richard Hick’s blog: [http://directaccess.richardhicks.com](http://directaccess.richardhicks.com). So thanks to Richard :smiley:.

## Download

You can download the actual monitoring MP and dashboard MP, as well as all the scripts I used in the MP and dashboards [**HERE**](https://blog.tyang.org/wp-content/uploads/2014/07/Location-Location-Location.zip).

>**Note:** For the monitoring MP (Location.Aware.Devices.Monitoring), I’ve also included the unsealed version in the zip file for your convenience (so you don’t have to unseal it if you want to look inside). Please do not import it into your management group because the dashboard MP is referencing it, therefore it has to be sealed.

Lastly, as always, I’d like to hear from the community. Please feel free to share your thoughts with me by leaving comments in the post or contacting me via email. Until next time, happy SCOMMING :smiley:.