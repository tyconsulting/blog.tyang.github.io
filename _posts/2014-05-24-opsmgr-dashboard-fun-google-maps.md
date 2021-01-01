---
id: 2771
title: 'OpsMgr Dashboard Fun: Google Maps'
date: 2014-05-24T16:20:32+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=2771
permalink: /2014/05/24/opsmgr-dashboard-fun-google-maps/
categories:
  - SCOM
tags:
  - Dashboard
  - SCOM
---
I am really excited about the 2 new PowerShell dashboard widget released in OpsMgr 2012 R2 UR2. PowerShell has always been my favourite scripting language, something I have been using on a daily basis since 2008. In my opinion, the opportunities are endless when having the ability to execute PowerShell scripts within an OpsMgr dashboard. I will start posting my ideas in this blog.

<strong>Background</strong>

For those who don’t know me, I work for an Australian retailer which has 3 brands (supermarkets, service stations and liquor stores) with totally over 2000 stores across the country. Pretty much every Windows device in the stores are being managed by System Center. Because of the nature of the environment we are in, in the past, there were ideas tossing around in the office that people really like to have some kind of map dashboard for OpsMgr, and we have trailed / tested different solutions. Although there are 3rd party solutions out there, yesterday, I have spent couple of hours and created a dashboard like this:

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/image15.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/05/image_thumb15.png" alt="image" width="580" height="318" border="0" /></a>

This dashboard contains:
<ul>
	<li>Top Left: State widget for a customized class called "TYANG Remote Computer", which is based on Windows Computer class.</li>
	<li>Bottom Left: Contextual PowerShell Grid widget displays health state of all related objects for "TYANG Remote Computers"</li>
	<li>Right: Contextual PowerShell Web Browser widget that pin-points the computer location on Google Maps.</li>
</ul>
In Action:

http://youtu.be/7Q7lEZYIv9E

I’ll now go through the steps I took to make this dashboard work. the management packs I used in the demo can also be downloaded from the link at the end of this post.

<strong>Instructions</strong>

<strong>Step 01. Create a management pack to define and discover the custom Windows Computer class.</strong>

I Named this management pack "Demo.Remote.Computers". I basically created a customized Windows Computer class with 4 additional properties:
<ul>
	<li>Street</li>
	<li>City (aka Suburb as what we call in Australia)</li>
	<li>State</li>
	<li>Country</li>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2014/05/image16.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/05/image_thumb16.png" alt="image" width="545" height="396" border="0" /></a>

I then created a registry key and stored these property values in the key:

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/image17.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/05/image_thumb17.png" alt="image" width="579" height="375" border="0" /></a>

After creating the registry key on few machines, I then created a filtered registry discovery workflow in the MP. It targets Windows Computer class and it is looking for this key. It also maps the 4 reg key values I created to the class properties.

Lastly, before I sealed the MP, I also created a folder and a state view for this custom class. The Accessibility of the folder is set to "Public" – so later on I can place the dashboard under this folder from a separate MP.

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/image18.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/05/image_thumb18.png" alt="image" width="580" height="62" border="0" /></a>

<strong>Step 02. Create the dashboard</strong>

Now that the class is defined and discovered, I can move on to the dashboard. To create the dashboard, firstly, I created a brand new MP from the Operations console, and called it "Demo Remote Computer Dashboard" with the ID "Demo.Remote.Computer.Dashboard". When the unsealed MP is created in the operations console, a folder is automatically created with the MP. I will place the dashboard under this folder (for now):

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/image19.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/05/image_thumb19.png" alt="image" width="286" height="46" border="0" /></a>

I gave the dashboard a name and chose an appropriate dashboard layout :

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML22e2dfb6.png"><img style="display: inline; border-width: 0px;" title="SNAGHTML22e2dfb6" src="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML22e2dfb6_thumb.png" alt="SNAGHTML22e2dfb6" width="288" height="166" border="0" /></a><a href="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML22e37454.png"><img style="display: inline; border-width: 0px;" title="SNAGHTML22e37454" src="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML22e37454_thumb.png" alt="SNAGHTML22e37454" width="274" height="166" border="0" /></a>

I added a state widget for the top left pane

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML22e4fb14.png"><img style="display: inline; border-width: 0px;" title="SNAGHTML22e4fb14" src="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML22e4fb14_thumb.png" alt="SNAGHTML22e4fb14" width="364" height="270" border="0" /></a>

Gave it a name: "Remote Computers"

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML22e5ef28.png"><img style="display: inline; border-width: 0px;" title="SNAGHTML22e5ef28" src="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML22e5ef28_thumb.png" alt="SNAGHTML22e5ef28" width="298" height="187" border="0" /></a>

Choose the class I have defined in Step 1

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML22e6ece1.png"><img style="display: inline; border-width: 0px;" title="SNAGHTML22e6ece1" src="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML22e6ece1_thumb.png" alt="SNAGHTML22e6ece1" width="355" height="263" border="0" /></a>

I want to display all instances, so I did not select anything in the Criteria step:

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML22e82adf.png"><img style="display: inline; border-width: 0px;" title="SNAGHTML22e82adf" src="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML22e82adf_thumb.png" alt="SNAGHTML22e82adf" width="464" height="267" border="0" /></a>

I defined what I property that I want to display, and how to sort the instances:

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/image20.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/05/image_thumb20.png" alt="image" width="527" height="490" border="0" /></a>

Then click Next and Create to create the widget.

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/image21.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/05/image_thumb21.png" alt="image" width="439" height="276" border="0" /></a>

Next, I’ll create a PowerShell Grid contextual widget in the bottom right section to display the health of each related components.

Choose "PowerShell Grid Widget"

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML22ed3e40.png"><img style="display: inline; border-width: 0px;" title="SNAGHTML22ed3e40" src="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML22ed3e40_thumb.png" alt="SNAGHTML22ed3e40" width="432" height="312" border="0" /></a>

Name: "Components"

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML22ee6098.png"><img style="display: inline; border-width: 0px;" title="SNAGHTML22ee6098" src="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML22ee6098_thumb.png" alt="SNAGHTML22ee6098" width="482" height="221" border="0" /></a>

Add the script below to the script section:

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML22ef9a12.png"><img style="display: inline; border-width: 0px;" title="SNAGHTML22ef9a12" src="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML22ef9a12_thumb.png" alt="SNAGHTML22ef9a12" width="580" height="326" border="0" /></a>

[source language="Powershell"]
Param($globalSelectedItems)
foreach ($globalSelectedItem in $globalSelectedItems)
{
$globalSelectedItemInstance = Get-SCOMClassInstance -Id $globalSelectedItem["Id"]
foreach ($relatedItem in $globalSelectedItemInstance.GetRelatedMonitoringObjects())
{
$ClassName = $relatedItem.GetMonitoringclasses()[0].DisplayName
$dataObject = $ScriptContext.CreateFromObject($relatedItem, "Id=Id,State=HealthState,DisplayName=DisplayName,FullName=FullName", $null)
$dataObject["ParentRelatedObject"] = $globalSelectedItemInstance.DisplayName
$ScriptContext.ReturnCollection.Add($dataObject)
}
}
[/source]

Click Next and Create to create the widget.

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML22f0d6d8.png"><img style="display: inline; border-width: 0px;" title="SNAGHTML22f0d6d8" src="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML22f0d6d8_thumb.png" alt="SNAGHTML22f0d6d8" width="573" height="336" border="0" /></a>

Lastly, I’ll create a PoweShell Web Browser contextual widget for the map on the right section.

Choose PowerShell Web Browser Widget

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML22f274d8.png"><img style="display: inline; border-width: 0px;" title="SNAGHTML22f274d8" src="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML22f274d8_thumb.png" alt="SNAGHTML22f274d8" width="532" height="398" border="0" /></a>

Name it "Map"

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML22f3613c.png"><img style="display: inline; border-width: 0px;" title="SNAGHTML22f3613c" src="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML22f3613c_thumb.png" alt="SNAGHTML22f3613c" width="340" height="172" border="0" /></a>

Copy the script below to the script section:

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML22f4ac2b.png"><img style="display: inline; border-width: 0px;" title="SNAGHTML22f4ac2b" src="http://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML22f4ac2b_thumb.png" alt="SNAGHTML22f4ac2b" width="569" height="378" border="0" /></a>

[source language="Powershell"]
Param($globalSelectedItems)
$dataObject = $ScriptContext.CreateInstance("xsd://Microsoft.SystemCenter.Visualization.Component.Library!Microsoft.SystemCenter.Visualization.Component.Library.WebBrowser.Schema/Request")
$dataObject["BaseUrl"]="http://maps.google.com/maps"
$parameterCollection = $ScriptContext.CreateCollection("xsd://Microsoft.SystemCenter.Visualization.Component.Library!Microsoft.SystemCenter.Visualization.Component.Library.WebBrowser.Schema/UrlParameter[]")
foreach ($globalSelectedItem in $globalSelectedItems)
{
$globalSelectedItemInstance = Get-SCOMClassInstance -Id $globalSelectedItem["Id"]
$StreetProperty = $globalSelectedItemInstance.GetMonitoringProperties() | Where-Object {$_.name -match "Street"}
$CityProperty = $globalSelectedItemInstance.GetMonitoringProperties() | Where-Object {$_.name -match "City"}
$StateProperty = $globalSelectedItemInstance.GetMonitoringProperties() | Where-Object {$_.name -match "State"}
$CountryProperty = $globalSelectedItemInstance.GetMonitoringProperties() | Where-Object {$_.name -match "Country"}
$Street = $globalSelectedItemInstance.GetMonitoringPropertyValue($StreetProperty)
$City = $globalSelectedItemInstance.GetMonitoringPropertyValue($CityProperty)
$State = $globalSelectedItemInstance.GetMonitoringPropertyValue($StateProperty)
$Country = $globalSelectedItemInstance.GetMonitoringPropertyValue($CountryProperty)
$parameter = $ScriptContext.CreateInstance("xsd://Microsoft.SystemCenter.Visualization.Component.Library!Microsoft.SystemCenter.Visualization.Component.Library.WebBrowser.Schema/UrlParameter")
$parameter["Name"] = "q"
$parameter["Value"] = "$street $City $state $Country"
$parameterCollection.Add($parameter)
}
$dataObject["Parameters"]= $parameterCollection
$ScriptContext.ReturnCollection.Add($dataObject)
[/source]

Click Next and Create to create the widget.

The dashboard should be fully functional by now.

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/image22.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/05/image_thumb22.png" alt="image" width="463" height="277" border="0" /></a>

You can stop now, or continue on to the next step to use the <a href="http://blogs.technet.com/b/momteam/archive/2012/06/12/free-windows-server-2008-dashboards-for-opsmgr-2012-and-tool-to-help-create-your-own-customized-dashboards.aspx">GTM tool</a> to generalize the dashboard MP – if you want to use this dashboard in other management groups.

Step 03: Generalizing the Dashboard MP

Firstly, export the dashboard MP, but do not delete it from the management group after export.

Run the GTMTool.exe against the exported MP. When asked if I want to create a task pane dashboard, answer "Y" and enter the name of the MP I created in step 01 ("Demo.Remote.Computers").

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/image23.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/05/image_thumb23.png" alt="image" width="580" height="119" border="0" /></a>

Although it’s not required, but I also opened the MP generated by the GTMTool.exe, replaced all the "UIGenerated" strings with something meaningful.

Before:

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/image24.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/05/image_thumb24.png" alt="image" width="574" height="222" border="0" /></a>

After:

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/image25.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/05/image_thumb25.png" alt="image" width="580" height="345" border="0" /></a>

Lastly, delete the old dashboard MP in OpsMgr, and import the updated one. The dashboard can now be found under the folder from the MP created in step 01.

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/image26.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/05/image_thumb26.png" alt="image" width="244" height="57" border="0" /></a>

<strong>Issues I experienced</strong>

01. Google Maps VS. Bing Maps

Someone may want to ask, why did I choose Google Maps rather than Microsoft’s Bing Maps. Well, I’m not sure about other countries, but couple of years ago when I was testing a well known OpsMgr map dashboard, which uses Bing Map (you probably know which one I’m talking about), I found the mapping data for Australia is very inaccurate.

For example, when I searched my local supermarket using address, Google Maps had no problem pin-pointing it in the map, but Bing maps could not find it:

Google Maps:

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/image27.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/05/image_thumb27.png" alt="image" width="473" height="403" border="0" /></a>

Bing Maps:

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/image28.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/05/image_thumb28.png" alt="image" width="465" height="459" border="0" /></a>

You can argue that I live in a Melbourne’s outer suburb, it is approx. 50km away from CBD and I can see horses and cows on a daily basis. Bing can be accurate for metropolitan areas or famous tourist attractions.

i.e. the supermarket located in Bondi Junction, NSW, near the famous Bondi Beach:

Google Maps finds it:

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/image29.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/05/image_thumb29.png" alt="image" width="363" height="266" border="0" /></a>

Bing Maps also finds it:

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/image30.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/05/image_thumb30.png" alt="image" width="365" height="314" border="0" /></a>

But for me employer, who operates all over Australia including areas very remote, it’s clearly an issue – unless we use map co-ordinates instead of addresses.

02. Google Maps Script Error:

While I was configuring Google Map widget, I also had an issue that I always get a script execution error from IE:

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/image31.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/05/image_thumb31.png" alt="image" width="537" height="284" border="0" /></a>

After spending some time googling this error, I learned Google does not work well with certain versions of IE. This leads to an issue that could be a common issue with the PowerShell Web Browser Widget. I managed to identify and fix the error, I’ll cover the issue and the fix in a <a href="http://blog.tyang.org/2014/05/24/lookout-ie-version-opsmgr-powershell-web-browser-widget/">separate post</a>, because I believe this error can happen for other web sites.

03. Google Maps left pane

I tried to find a way to disable it, but in many online forums, people said there is no way to disable it unless use it in an iframe with the parameter "out=embed" in the URL.

<a href="http://blog.tyang.org/wp-content/uploads/2014/05/image32.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/05/image_thumb32.png" alt="image" width="244" height="204" border="0" /></a>

I’m not a web developer, but I’m guessing if I develop a web page on a web server to host such an iframe, I should be able to remove it? it’s just a thought, I haven’t looked into it.

Anyways, after playing with it for a while, I don’t really mind clicking the arrow to minimise the left pane every time, having the left pane there can be handy sometimes as I can also use the "Get Directions" function as I demonstrated in the video.

<strong>Conclusion</strong>

Overall, I spent more time trying to get Google Maps working in the widget than time creating the management pack and dashboard. The management packs can be downloaded <strong><a href="http://blog.tyang.org/wp-content/uploads/2014/05/Sample-Dashboard-Google-Maps.zip">HERE</a></strong>.

Please keep in mind the MP that defines and discovers your classes must be sealed so other MPs can reference it. I’ve included both sealed and unsealed version of this MP, if you want to test it out in your environment, please make sure you used the sealed version (Demo.Remote.Computers.mp).

I did not seal the dashboard MP so it is easier for you to see what’s under the hood.