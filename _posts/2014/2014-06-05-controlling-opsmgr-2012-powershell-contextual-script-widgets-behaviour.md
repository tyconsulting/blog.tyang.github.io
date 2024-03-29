---
id: 2833
title: Controlling OpsMgr 2012 PowerShell Contextual Script Widgets Behaviour
date: 2014-06-05T22:15:56+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=2833
permalink: /2014/06/05/controlling-opsmgr-2012-powershell-contextual-script-widgets-behaviour/
categories:
  - SCOM
tags:
  - Dashboard
  - SCOM
---
Few days ago I posted an <a href="https://blog.tyang.org/2014/05/24/opsmgr-dashboard-fun-google-maps/">OpsMgr 2012 dashboard using Google Maps</a>. After it’s been posted, I noticed there is a minor issue with the dashboard.

When I click on a monitoring object from the top left "Remote Computers" state widget, the "Map" widget on the right refreshes and loaded the map based on the location property values of the remote computer class:

<a href="https://blog.tyang.org/wp-content/uploads/2014/06/image.png"><img style="display: inline; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/06/image_thumb.png" alt="image" width="562" height="336" border="0" /></a>

But when I click on an object in the bottom left "Component" widget (which is a list of related objects of remote computer class), the map refreshes again. Only this time, because the locations cannot be found from object properties, it passed an empty string to Google Map:

<a href="https://blog.tyang.org/wp-content/uploads/2014/06/image1.png"><img style="display: inline; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/06/image_thumb1.png" alt="image" width="556" height="333" border="0" /></a>

This is because the "Map" widget uses a contextual PowerShell Web Browser Widget. a contextual widget gets data from other widgets within the dashboard and it is updated when objects of another widget is selected.

So, in order to overcome this issue, I have updated script used by the PowerShell Browser Widget for the map, to check if the selected object belongs to a specific class, if not, don’t return any data (thus the web page will not be reloaded and will remain the same.)

Here’s the updated script:

```powershell
Param($globalSelectedItems)

#Function to Check If the monitoring object belongs to a specific class
Function Validate-ObjectClass ($MonitoringObjectID, $ClassName)
{
  $ClassId = (Get-SCOMClass -Name "$ClassName").Id
  $MObject = Get-SCOMMonitoringObject -Id $MonitoringObjectID
  $bvalid = $false
  Foreach ($Id in $MObject.MonitoringClassIds)
  {
    If ($Id -eq $ClassId)
    {
      $bvalid = $true
    }
  }
  $bValid
}

$dataObject = $ScriptContext.CreateInstance("xsd://Microsoft.SystemCenter.Visualization.Component.Library!Microsoft.SystemCenter.Visualization.Component.Library.WebBrowser.Schema/Request")
$dataObject["BaseUrl"]="&lt;a href="http://maps.google.com/maps&quot;"&gt;http://maps.google.com/maps"&lt;/a&gt;
$parameterCollection = $ScriptContext.CreateCollection("xsd://Microsoft.SystemCenter.Visualization.Component.Library!Microsoft.SystemCenter.Visualization.Component.Library.WebBrowser.Schema/UrlParameter[]")
$bAllValid = $true #Assuming all selected objects are valid
foreach ($globalSelectedItem in $globalSelectedItems)
{
  #Save the monitoring object ID into a variable
  $MObjectID = $globalSelectedItem["Id"]
  #Check if a "Demo.Remote.Computers.Remote.Computer.Class" object is selected
  $bValidOBject = Validate-ObjectClass $MObjectID "Demo.Remote.Computers.Remote.Computer.Class"
  If ($bValidOBject)
  {
    #Valid object, continue building URL parameters
    $globalSelectedItemInstance = Get-SCOMClassInstance -Id $MObjectID
    $MProperties = $globalSelectedItemInstance.GetMonitoringProperties()
    $StreetProperty = $MProperties | Where-Object {$_.name -match "Street"}
    $CityProperty = $MProperties | Where-Object {$_.name -match "City"}
    $StateProperty = $MProperties | Where-Object {$_.name -match "State"}
    $CountryProperty = $MProperties | Where-Object {$_.name -match "Country"}
    $Street = $globalSelectedItemInstance.GetMonitoringPropertyValue($StreetProperty)
    $City = $globalSelectedItemInstance.GetMonitoringPropertyValue($CityProperty)
    $State = $globalSelectedItemInstance.GetMonitoringPropertyValue($StateProperty)
    $Country = $globalSelectedItemInstance.GetMonitoringPropertyValue($CountryProperty)
    $parameter = $ScriptContext.CreateInstance("xsd://Microsoft.SystemCenter.Visualization.Component.Library!Microsoft.SystemCenter.Visualization.Component.Library.WebBrowser.Schema/UrlParameter")
    $parameter["Name"] = "q"
    $parameter["Value"] = "$street $City $state $Country"
    $parameterCollection.Add($parameter)
  } else {
    #the object is not a valid object, therefore set "All Valid" boolean variable to false
    $bAllValid = $false
  }
}
#only return data when all selected objects are valid
If ($bAllValid)
{
  $dataObject["Parameters"]= $parameterCollection
  $ScriptContext.ReturnCollection.Add($dataObject)
}
```

The highlighted sections are what’s changed from the original script:

<a href="https://blog.tyang.org/wp-content/uploads/2014/06/image2.png"><img style="display: inline; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/06/image_thumb2.png" alt="image" width="580" height="548" border="0" /></a>

Now, I created another dashboard using the code above, when clicked on a related object from bottom left widget, nothing happens on the map widget. the map remains the same:

<a href="https://blog.tyang.org/wp-content/uploads/2014/06/image3.png"><img style="display: inline; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/06/image_thumb3.png" alt="image" width="580" height="378" border="0" /></a>

I put the code for the validation into a separate function <strong>Validate-ObjectClass</strong> so this function can be reused in other widgets and dashboard. You may use this function when there are more than 2 widgets in a dashboard and you only want a PowerShell contextual widget to refresh when a specific type of object is selected from other widgets.

I hope you find this blog post and script useful, please feel free to contact me if you have any questions or concerns.