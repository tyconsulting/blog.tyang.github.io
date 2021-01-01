---
id: 4241
title: 'Automating OpsMgr Part 8: Adding Management Pack References'
date: 2015-07-17T19:25:49+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=4241
permalink: /2015/07/17/automating-opsmgr-part-8-adding-management-pack-references/
categories:
  - PowerShell
  - SCOM
  - SMA
tags:
  - Automating OpsMgr
  - Powershell
  - SCOM
  - SMA
---
<h3><a href="http://blog.tyang.org/wp-content/uploads/2015/06/OpsMgrExnteded.png"><img class="alignleft size-thumbnail wp-image-4038" src="http://blog.tyang.org/wp-content/uploads/2015/06/OpsMgrExnteded-150x150.png" alt="OpsMgrExnteded" width="150" height="150" /></a>Introduction</h3>
This is the 8th instalment of the Automating OpsMgr series. Previously on this series:
<ul>
	<li><a href="http://blog.tyang.org/2015/06/24/automating-opsmgr-part-1-introducing-opsmgrextended-powershell-sma-module/">Automating OpsMgr Part 1: Introducing OpsMgrExtended PowerShell / SMA Module</a></li>
	<li><a href="http://blog.tyang.org/2015/06/28/automating-opsmgr-part-2-sma-runbook-for-creating-configmgr-log-collection-rules/">Automating OpsMgr Part 2: SMA Runbook for Creating ConfigMgr Log Collection Rules</a></li>
	<li><a href="http://blog.tyang.org/2015/06/30/automating-opsmgr-part-3-new-management-pack-runbook-via-sma-and-azure-automation/">Automating OpsMgr Part 3: New Management Pack Runbook via SMA and Azure Automation</a></li>
	<li><a href="http://blog.tyang.org/2015/07/02/automating-opsmgr-part-4-create-new-empty-groups/">Automating OpsMgr Part 4:Creating New Empty Groups</a></li>
	<li><a href="http://blog.tyang.org/2015/07/06/automating-opsmgr-part-5-adding-computers-to-computer-groups/">Automating OpsMgr Part 5: Adding Computers to Computer Groups</a></li>
	<li><a href="http://blog.tyang.org/2015/07/13/automating-opsmgr-part-6-adding-monitoring-objects-to-instance-groups/">Automating OpsMgr Part 6: Adding Monitoring Objects to Instance Groups</a></li>
	<li><a href="http://blog.tyang.org/2015/07/17/automating-opsmgr-part-7-updated-opsmgrextended-module/" target="_blank">Automating OpsMgr Part 7: Updated OpsMgrExtended Module</a></li>
</ul>
In part 4-6, I have demonstrated how to create and add static members to both instance groups and computer groups. In Part 7, I have released the updated <strong>OpsMgrExtended</strong> module (version 1.1), and demonstrated simplified runbooks for adding static members to groups. In this post, I will demonstrate how to add a management pack reference to an unsealed MP. In the next module, I will demonstrate how to update a group discovery (how groups are populated). But in order for me to demonstrate how to update group discoveries, I will need to cover adding MP references first.
<h3>What is Management Pack Reference</h3>
Management packs often use elements defined in other management packs. i.e. a discovery MP would need to refer to the library MP of which the class being discovered is defined; a monitor refers to the monitor type defined in another MP; or an override you created in an unsealed MP need to refer to the MP of which the workflow that you are creating the override for is defined, etc.

Because OpsMgr needs to ensure the referencing management pack does not change in a way that may impact all other management packs that are referencing this pack, only sealed management packs (or Management Pack bundles in OpsMgr 2012) can be referenced in other management packs because sealed MPs must comply with a set of rules when being upgraded. Unsealed management packs can reference other sealed management packs, but they cannot be referenced in other MPs.

<a href="http://blog.tyang.org/wp-content/uploads/2015/07/image28.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/07/image_thumb28.png" alt="image" width="481" height="600" border="0" /></a>

As shown above, in OpsMgr console, by opening the property page of a management pack, you can easily find out which management packs is this particular MP is referencing (the top section), and what other management packs are referencing this MP (the bottom section).

<a href="http://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTML11b42e4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML11b42e4" src="http://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTML11b42e4_thumb.png" alt="SNAGHTML11b42e4" width="657" height="423" border="0" /></a>

When reading the management pack XML (as shown above), you'll notice the references are defined in the beginning of the MP. When defining a MP reference, the following information must be supplied:
<ul>
	<li>Alias - This alias must be unique within the MP itself, and it is used by other elements within this MP, followed by an exclamation mark("!")</li>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTML11f5dbc.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML11f5dbc" src="http://blog.tyang.org/wp-content/uploads/2015/07/SNAGHTML11f5dbc_thumb.png" alt="SNAGHTML11f5dbc" width="572" height="134" border="0" /></a>
<ul>
	<li>ID - The internal name of the referencing MP</li>
	<li>Version - The <strong><u>minimum</u></strong> required version of the referencing MP.</li>
	<li>PublicKeyToken - the public key token of the key used to sealed this referencing MP.</li>
</ul>
<strong><span style="color: #ff0000;">Note:</span></strong> when you are writing management pack A and created a reference for management pack B with version 2.0.0.0, and the version of MP B loaded in your management group is version 2.0.0.1, then you will have no problem when loading A into your management group. However, if MP B in your management group is on version 1.0.0.0, you will not be able to load MP A without having to update B to at least 2.0.0.0 first before you are able to importing management pack A.
<h3>Creating Management Pack Reference Using OpsMgr SDK</h3>
When using OpsMgr SDK to create MP references, since you are creating the reference in an unsealed MP that is already loaded in your management group, the referencing management pack must also be present in the management group. And since the referencing MP should have already been loaded in the management group, the only 2 pieces of information you need to specify is the name of the MP, and the alias that you wish to use (but has to be unique, meaning not already been used). The SDK would lookup the version number and the public key token from the referencing MP, and use them when creating the reference.

The OpsMgrExtended module offers a function called <strong>New-OMManagementPackReference</strong> that can be used to easily create MP references in unsealed management packs. I have written a very simple runbook utilising this function.
<h3>Runbook: Add-MPReference</h3>
<pre language="PowerShell">Workflow Add-MPReference
{
Param(
[Parameter(Mandatory=$true)][String]$ManagementPackName,
[Parameter(Mandatory=$true)][String]$ReferenceMPAlias,
[Parameter(Mandatory=$true)][String]$ReferenceMPName
)

#Get OpsMgrSDK connection object
$OpsMgrSDKConn = Get-AutomationConnection -Name "OpsMgrSDK_TYANG"

#Add the MP reference
$AddResult = New-OMManagementPackReference -SDKConnection $OpsMgrSDKConn -ReferenceMPName $ReferenceMPName -Alias $ReferenceMPAlias -UnsealedMPName $ManagementPackName
Write-Verbose "MP Ref Added: $AddResult"
If ($AddResult -eq $true)
{
Write-Output "Done."
} else {
throw "Unable to add MP reference for '$ReferenceMPName' to unsealed MP '$ManagementPackName'."
exit
}
}
</pre>
This runbook takes 3 input parameters:
<ul>
	<li>ManagementPackName: the name of the unsealed MP where the reference is going to saved to</li>
	<li>ReferenceMPAlias: The alias of the referencing MP</li>
	<li>ReferenceMPName: The name of the referencing MP (must be a sealed MP).</li>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2015/07/image29.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/07/image_thumb29.png" alt="image" width="379" height="327" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2015/07/image30.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/07/image_thumb30.png" alt="image" width="391" height="383" border="0" /></a>

After the execution, the reference is created in the unsealed MP:

<a href="http://blog.tyang.org/wp-content/uploads/2015/07/image31.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/07/image_thumb31.png" alt="image" width="513" height="146" border="0" /></a>
<h3>Conclusion</h3>
In this post, I've demonstrated how to create a MP reference in an unsealed management pack. In the next post, I will demonstrate how to update a group discovery configuration (for dynamic group memberships).