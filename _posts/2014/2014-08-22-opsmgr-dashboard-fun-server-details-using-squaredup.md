---
id: 3117
title: 'OpsMgr Dashboard Fun: Server Details Using SquaredUp'
date: 2014-08-22T20:06:11+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=3117
permalink: /2014/08/22/opsmgr-dashboard-fun-server-details-using-squaredup/
categories:
  - PowerShell
  - SCOM
tags:
  - Dashboard
  - SCOM
  - SquaredUp
---
After my <a href="https://blog.tyang.org/2014/08/05/opsmgr-dashboard-fun-performance-widget-using-squaredup/">previous post</a> on how to create a performance view using SquaredUp, the founder of SquaredUp, Richard Benwell told me that I can also use "&embed=true" parameter in the URL to get rid of the headers. I also managed to create another widget to display server details. Combined with the performance view, I create a dashboard like this:

<a href="https://blog.tyang.org/wp-content/uploads/2014/08/image7.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/08/image_thumb7.png" alt="image" width="696" height="445" border="0" /></a>

The bottom left is the improved version of the performance view (using embed parameter), and the right pane is the server details page:

<a href="https://blog.tyang.org/wp-content/uploads/2014/08/SNAGHTML2d6fce9d.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML2d6fce9d" src="https://blog.tyang.org/wp-content/uploads/2014/08/SNAGHTML2d6fce9d_thumb.png" alt="SNAGHTML2d6fce9d" width="469" height="966" border="0" /></a>

This server detail view contains the following information:

* Alerts associated to the computer
* Health states of the Distributed Apps that this computer is a part of.
* Health State of its hosted components (Equivalent to the Health Explorer??)
* Discovered properties of this computer

Combined with the performance view, it gives a good overview of the current state of the computer from different angles.

Here’s the script for this server detail view:

```powershell
Param($globalSelectedItems)
$dataObject = $ScriptContext.CreateInstance("xsd://Microsoft.SystemCenter.Visualization.Component.Library!Microsoft.SystemCenter.Visualization.Component.Library.WebBrowser.Schema/Request")
$dataObject["BaseUrl"]=<a href="http://<Your SquaredUp Web Server>/SquaredUp/object">http://Your SquaredUp Web Server/SquaredUp/object</a>
$parameterCollection = $ScriptContext.CreateCollection("xsd://Microsoft.SystemCenter.Visualization.Component.Library!Microsoft.SystemCenter.Visualization.Component.Library.WebBrowser.Schema/UrlParameter[]")
$bValid = $false
foreach ($globalSelectedItem in $globalSelectedItems)
{
  $parameter0 = $ScriptContext.CreateInstance("xsd://Microsoft.SystemCenter.Visualization.Component.Library!Microsoft.SystemCenter.Visualization.Component.Library.WebBrowser.Schema/UrlParameter")
  $parameter0["Name"] = "objectId"
  $parameter0["Value"] = $globalSelectedItem["Id"]

  $parameter1 = $ScriptContext.CreateInstance("xsd://Microsoft.SystemCenter.Visualization.Component.Library!Microsoft.SystemCenter.Visualization.Component.Library.WebBrowser.Schema/UrlParameter")
  $parameter1["Name"] = "Embed"
  $parameter1["Value"] = "true"

  $parameterCollection.Add($parameter0)
  $parameterCollection.Add($parameter1)
  $bValid = $true
}
If ($bValid)
{
  $dataObject["Parameters"]= $parameterCollection
  $ScriptContext.ReturnCollection.Add($dataObject)
}

```
And here’s the script for the improved performance view (with "&embed=true" parameter):

```powershell
Param($globalSelectedItems)
$dataObject = $ScriptContext.CreateInstance("xsd://Microsoft.SystemCenter.Visualization.Component.Library!Microsoft.SystemCenter.Visualization.Component.Library.WebBrowser.Schema/Request")
$dataObject["BaseUrl"]=<a href="http://<Your Squaredup Web Server>/SquaredUp/performance/objectoverview">http://Your Squaredup Web Server/SquaredUp/performance/objectoverview</a>
$parameterCollection = $ScriptContext.CreateCollection("xsd://Microsoft.SystemCenter.Visualization.Component.Library!Microsoft.SystemCenter.Visualization.Component.Library.WebBrowser.Schema/UrlParameter[]")
$bValid = $false
foreach ($globalSelectedItem in $globalSelectedItems)
{
  $parameter0 = $ScriptContext.CreateInstance("xsd://Microsoft.SystemCenter.Visualization.Component.Library!Microsoft.SystemCenter.Visualization.Component.Library.WebBrowser.Schema/UrlParameter")
  $parameter0["Name"] = "objectId"
  $parameter0["Value"] = $globalSelectedItem["Id"]

  $parameter1 = $ScriptContext.CreateInstance("xsd://Microsoft.SystemCenter.Visualization.Component.Library!Microsoft.SystemCenter.Visualization.Component.Library.WebBrowser.Schema/UrlParameter")
  $parameter1["Name"] = "timeframe"
  $parameter1["Value"] = "Last12Hours"

  $parameter2 = $ScriptContext.CreateInstance("xsd://Microsoft.SystemCenter.Visualization.Component.Library!Microsoft.SystemCenter.Visualization.Component.Library.WebBrowser.Schema/UrlParameter")
  $parameter2["Name"] = "Embed"
  $parameter2["Value"] = "true"

  $parameterCollection.Add($parameter0)
  $parameterCollection.Add($parameter1)
  $parameterCollection.Add($parameter2)
  $bValid = $true
}
If ($bValid)
{
  $dataObject["Parameters"]= $parameterCollection
  $ScriptContext.ReturnCollection.Add($dataObject)
}

```

I’d also like to clarify that my examples are just providing alternative ways to utilise SquaredUp and display useful information on a single pane of glass (dashboards).  I don’t want to mislead the readers of article to have an impression that SquaredUp relies on native OpsMgr consoles and dashboards. In my opinion and experience with SquaredUp, I think it is a perfect replacement to the built-in OpsMgr web console.