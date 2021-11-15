---
id: 2788
title: Lookout for the IE Version in the OpsMgr PowerShell Web Browser Widget
date: 2014-05-24T17:01:30+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=2788
permalink: /2014/05/24/lookout-ie-version-opsmgr-powershell-web-browser-widget/
categories:
  - SCOM
tags:
  - SCOM
  - SCOM Dashboard
---
Last night, while I was working on my newly created <a href="https://blog.tyang.org/2014/05/24/opsmgr-dashboard-fun-google-maps">Google Map Dashboard</a> in OpsMgr, I kept getting script errors from the PowerShell Web Browser widget used for Google Maps:

<a href="https://blog.tyang.org/wp-content/uploads/2014/05/image33.png"><img style="border: 0px" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/05/image_thumb33.png" alt="image" width="580" height="306" border="0" /></a>

After some research online, some people suggests this is because the latest Google Maps only supports IE version 8 and later.

I was getting this error on Windows 8.1 (With Update) and Windows Server 2012 R2 (With Update). the IE version is 11:

<a href="https://blog.tyang.org/wp-content/uploads/2014/05/image34.png"><img style="border: 0px" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/05/image_thumb34.png" alt="image" width="393" height="276" border="0" /></a>

Long story short, in the end, I found the issue from couple of blog posts.

In my lab, when PowerShell Web Browser widgets opens a page, it enumerates IE 7. To prove this, I created a dashboard with just 1 Cell and created a PowerShell Web Browser widget with the script below:

<a href="https://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML2364221a.png"><img style="border: 0px" title="SNAGHTML2364221a" src="https://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML2364221a_thumb.png" alt="SNAGHTML2364221a" width="580" height="263" border="0" /></a>

```powershell
$dataObject = $ScriptContext.CreateInstance("xsd://Microsoft.SystemCenter.Visualization.Component.Library!Microsoft.SystemCenter.Visualization.Component.Library.WebBrowser.Schema/Request")
$dataObject["BaseUrl"]="&lt;a href="http://www.whatbrowser.org/intl/en/&quot;"&gt;http://www.whatbrowser.org/intl/en/"&lt;/a&gt;

$ScriptContext.ReturnCollection.Add($dataObject)
```

it simply launches the site <a href="http://www.whatbrowser.org/intl/en/">http://www.whatbrowser.org/intl/en/</a>

<strong>[07/2020]NOTE:</strong> whatbrowser.org seems to be offline now. an alternative is <a href="http://www.whatbrowser.org/">http://www.whatbrowser.org</a>

Surprisingly, it shows I’m using IE 7:

<a href="https://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML2366636f.png"><img style="border: 0px" title="SNAGHTML2366636f" src="https://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML2366636f_thumb.png" alt="SNAGHTML2366636f" width="580" height="357" border="0" /></a>

To fix the issue, I had to add a registry key value to enforce OpsMgr 2012 console to use IE 11 (as documented in MSDN: <a title="http://msdn.microsoft.com/en-us/library/ie/ee330730(v=vs.85).aspx" href="http://msdn.microsoft.com/en-us/library/ie/ee330730(v=vs.85).aspx">http://msdn.microsoft.com/en-us/library/ie/ee330730(v=vs.85).aspx</a>).

<strong>Reg Key Path:</strong>

HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION

<strong>DWORD value to add:</strong>

Microsoft.EnterpriseManagement.Monitoring.Console.exe

<strong>Value data:</strong>

decimal 11000

<a href="https://blog.tyang.org/wp-content/uploads/2014/05/image35.png"><img style="border: 0px" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/05/image_thumb35.png" alt="image" width="580" height="222" border="0" /></a>

<a href="https://blog.tyang.org/wp-content/uploads/2014/05/image36.png"><img style="border: 0px" title="image" src="https://blog.tyang.org/wp-content/uploads/2014/05/image_thumb36.png" alt="image" width="354" height="211" border="0" /></a>

After the registry modification, simply close and re-open the OpsMgr operational console, open the dashboard, the problem was resolved and whatbrowser.org shows I’m using IE 11:

<a href="https://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML23710b66.png"><img style="border: 0px" title="SNAGHTML23710b66" src="https://blog.tyang.org/wp-content/uploads/2014/05/SNAGHTML23710b66_thumb.png" alt="SNAGHTML23710b66" width="580" height="393" border="0" /></a>

I’m guessing this could be a common issue when using the PowerShell Web Browser widget to open a site that does not support earlier versions of IE. If this is the case, this registry modification will need to be implemented to all computers running OpsMgr 2012 consoles and wanting to use the dashboard.