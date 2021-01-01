---
id: 5793
title: Injecting Event Log Export from .evtx Files to OMS Log Analytics
date: 2016-12-05T19:51:30+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=5793
permalink: /2016/12/05/injecting-event-log-export-from-evtx-files-to-oms-log-analytics/
categories:
  - Uncategorized
tags:
  - Azure Automation
  - OMS
  - Powershell
---
Over the last few days, I had an requirement injecting events from .evtx files into OMS Log Analytics. A typical .evtx file that I need to process contains over 140,000 events. Since the Azure Automation runbook have the maximum execution time of 3 hours, in order to make the runbook more efficient, I also had to update my OMSDataInjection PowerShell module to support bulk insert (<a title="http://blog.tyang.org/2016/12/05/omsdatainjection-powershell-module-updated/" href="http://blog.tyang.org/2016/12/05/omsdatainjection-powershell-module-updated/">http://blog.tyang.org/2016/12/05/omsdatainjection-powershell-module-updated/</a>).

I have publish the runbook on GitHub Gist:

https://gist.github.com/tyconsulting/72a19595246938ae0fb435a42afa4185

<span style="color: #ff0000;"><strong>Note:</strong></span> In order to use this runbook, you MUST use the latest OMSDataInjection module (version 1.1.1) because of the bulk insert.

You will need to specify the following parameters:
<ul>
 	<li>EvtExportPath - the file path (i.e. a SMB share) to the evtx file.</li>
 	<li>OMSConnectionName – the name of the OMSWorkspace connection asset you have created previously. this connection is defined in the OMSDataInjection module</li>
 	<li>OMSLogTypeName – The OMS log type name that you wish to use for the injected events.</li>
 	<li>BatchLimit – the number of events been injected in a single bulk request. This is an optional parameter, the default value is 1000 if it is not specified.</li>
 	<li>OMSTimeStampFieldName – For the OMS HTTP Data Collector API, you will need to tell the API which field in your log represent the timestamp. since all events extracted from .evtx files all have a “TimeCreated” field, the default value for this parameter is ‘TimeCreated’.</li>
</ul>
You can further customise the runbook and choose which fields from the evtx events that you wish to exclude. For the fields that you wish to exclude, you need to add them to the $arrSkippedProperties array variable (line 25 – 31). I have already pre-populated it with few obvious ones, you can add and remove them to suit your requirements.

Lastly, sometimes you will get events that their formatted description cannot be displayed. i.e.

<a href="http://blog.tyang.org/wp-content/uploads/2016/12/image-11.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/12/image_thumb-11.png" alt="image" width="416" height="148" border="0" /></a>

When the runbook cannot get the formatted description of event, it will use the XML content as the event description instead.

Sample event injected by this runbook:

<a href="http://blog.tyang.org/wp-content/uploads/2016/12/image-12.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/12/image_thumb-12.png" alt="image" width="706" height="299" border="0" /></a>