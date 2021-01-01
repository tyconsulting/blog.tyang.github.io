---
id: 2849
title: 'PowerShell Script: Remove Obsolete References from Unsealed OpsMgr Management Packs'
date: 2014-06-24T16:45:04+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=2849
permalink: /2014/06/24/powershell-script-remove-obsolete-references-unsealed-opsmgr-management-packs/
categories:
  - PowerShell
  - SCOM
tags:
  - Powershell
  - SCOM
---
<strong>Background</strong>

Last month, in TechEd North America, Cameron Fuller demonstrated a PowerShell script to search and remove obsolete MP references from an unsealed management pack. The script was written by Cameron’s colleague Matthew Dowst. You can watch Cameron’s presentation <a href="http://channel9.msdn.com/Events/TechEd/NorthAmerica/2014/DCIM-B420#fbid=">here</a> and get the script <a href="http://blogs.catapultsystems.com/mdowst/archive/2014/05/15/scom-amp-scsm-management-pack-cleanup.aspx">here</a>.

After TechEd, Cameron emailed me and suggest me to add this script into my OpsMgr Self Maintenance management pack. So before I built this functionality into the Self Maintenance MP, I have written a similar stand-alone script as a proof-of-concept.

<strong>Script Highlights:</strong>

The differences between my version and Matthew Dowst version are:
<ul>
	<li><strong>No need to export and re-import unsealed management packs:</strong> My script directly reads and updates MP contents using SCOM SDK. therefore unsealed MPs don’t need to be exported and re-imported.</li>
	<li><strong>Scan through all unsealed MPs:</strong> My script go through all unsealed MPs rather than individual XML files.</li>
	<li><strong>Option to backup MPs before changes are made:</strong> the script accept parameters to backup original unsealed MPs before any changes are made.</li>
	<li><strong>Option to increase MP version or keep version the same: </strong>Users can choose whether the MP version should be increased.</li>
	<li><strong>Allow test run (-WhatIf):</strong> Users can use –WhatIf switch to test run the script before changes are made.</li>
	<li><strong>MP Verify:</strong> the script verifies the MP before and after changes. if MP verify fails (including pre-existing errors), no changes will be made to the particular MP.</li>
	<li><strong>Allow Users to customize a “white list” for common MPs:</strong> When obsolete references are detected for the “common management packs” defined in the CommonMPs.XML (placed in the same folder as the script), these references will be ignored. This is because these common management packs are referenced in many out-of-box unsealed management packs by default. Additionally, since it is very unlikely these management packs will ever be deleted from the management group, therefore it should not be an issue when they are referenced in other management packs. Users can manually add / remove MPs from the list by editing the CommonMPs.XML. I have pre-populated the white list and included the following MPs:</li>
	<li>
<ul>
	<li>Microsoft.SystemCenter.Library</li>
	<li>Microsoft.Windows.Library</li>
	<li>System.Health.Library</li>
	<li>System.Library</li>
	<li>Microsoft.SystemCenter.DataWarehouse.Internal</li>
	<li>Microsoft.SystemCenter.Notifications.Library</li>
	<li>Microsoft.SystemCenter.DataWarehouse.Library</li>
	<li>Microsoft.SystemCenter.OperationsManager.Library</li>
	<li>System.ApplicationLog.Library</li>
	<li>Microsoft.SystemCenter.Advisor.Internal</li>
	<li>Microsoft.IntelligencePacks.Types</li>
	<li>Microsoft.SystemCenter.Visualization.Configuration.Library</li>
	<li>Microsoft.SystemCenter.Image.Library</li>
	<li>Microsoft.SystemCenter.Visualization.ServiceLevelComponents</li>
	<li>Microsoft.SystemCenter.NetworkDevice.Library</li>
	<li>Microsoft.SystemCenter.InstanceGroup.Library</li>
	<li>Microsoft.Windows.Client.Library</li>
</ul>
</li>
</ul>
<strong>Instruction:</strong>

You can run this script on any computers have OpsMgr 2012 console /agent / management server installed. The script includes a help documentation. you can access it via:

<strong>get-help .\MPReferencesCleanUp.ps1 –full</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2014/06/SNAGHTML436c9dc6.png"><img style="display: inline; border: 0px;" title="SNAGHTML436c9dc6" src="http://blog.tyang.org/wp-content/uploads/2014/06/SNAGHTML436c9dc6_thumb.png" alt="SNAGHTML436c9dc6" width="580" height="448" border="0" /></a>

<strong>Examples:</strong>

<strong>#1. Test run using -WhatIf: </strong>.\MPReferencesCleanUp.ps1 -ManagementServer "OPSMGRMS01" –BackupBeforeModify –BackupLocation "C:\Temp" -IncrementVersion –WhatIf

<a href="http://blog.tyang.org/wp-content/uploads/2014/06/image4.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/06/image_thumb4.png" alt="image" width="580" height="624" border="0" /></a>

<strong>#2. Real run without –WhatIf:</strong> .\MPReferencesCleanUp.ps1 -ManagementServer "OPSMGRMS01" –BackupBeforeModify –BackupLocation "C:\Temp" –IncrementVersion

<a href="http://blog.tyang.org/wp-content/uploads/2014/06/image5.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/06/image_thumb5.png" alt="image" width="580" height="513" border="0" /></a>

<strong>Download</strong>

The script can be downloaded <a href="http://blog.tyang.org/wp-content/uploads/2014/06/MPReferencesCleanUp.zip">HERE</a>.

<strong>What’s next?</strong>

As I mentioned in the beginning, the next version of the OpsMgr 2012 Self Maintenance MP will have the ability to detect and remove these obsolete references. The MP is pretty much done. I’ve sent it to few people to test. I should be able to publish it in few days. Despite the new functionalities of the self maintenance MP, this script will still be a good standalone tool to run ad-hoc when needed.

<strong>Credit</strong>

I’d like to thank the following people for testing and advices provided to this script (in random order):
<ul>
	<li>Cameron Fuller</li>
	<li>Raphael Burri</li>
	<li>Marnix Wolf</li>
	<li>Bob Cornelissen</li>
	<li>Dan Kregor</li>
</ul>
I also want to thank Matthew Dowst for the original script and Matthew Long for his <a href="http://matthewlong.wordpress.com/2012/12/14/deleting-a-scom-mp-which-the-microsoft-systemcenter-securereferenceoverride-mp-depends-upon/">blog post</a> where I got the ideas from.

Lastly, as always, please feel free to contact me if you have questions / issues.