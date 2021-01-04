---
id: 3770
title: PowerShell Script to Extract CMDB Data From System Center Service Manager Using SDK
date: 2015-03-04T20:48:46+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=3770
permalink: /2015/03/04/powershell-script-to-extract-cmdb-data-from-system-center-service-manager-using-sdk/
categories:
  - PowerShell
  - SCSM
tags:
  - PowerShell
  - SCSM
---

## Background

In my previous post <a href="http://blog.tyang.org/2015/02/22/writing-powershell-modules-that-interact-with-various-sdk-assemblies/">Writing PowerShell Module That Interact With Various SDK Assemblies</a>, I’ve explained how to create a PowerShell module that embeds various SDK DLLs and I’ve used System Center Service Manager SDK as an example. Well, the reason that I created the module for Service Manager SDK is because I needed to write a script to extract CMDB data from Service Manager. In this post, I’ll go through what’ I’ve done and the script can also be downloaded at the end of the article.

So, I needed to write a script to export configuration items from Service Manager, I have the following requirements:

  * The script must be generic and extendable to be able to extract instances of any CI classes.
  * The properties (to be exported) of each class should also be configurable.
  * Supports delta export (Only export what’s changed since last execution).
  * Be able to also export CI Relationships
  * Be able to filter unwanted relationships (from being exported).

After evaluating different options, I have decided to directly interact with Service Manager SDK in the script instead of using the native Service Manager PowerShell module and the community based module <a href="https://smlets.codeplex.com/">SMLets</a>.

## Pre-requisite

As I just mentioned, this script requires the SMSDK module I have created previously (you will have to locate the SDK DLLs from your Service Manager management server and copy them to the module folder as I explained in the previous post).

## Configuration

In order to make the script generic while being extendable, I’ve used a XML file to define various configurations for the script:

<a href="http://blog.tyang.org/wp-content/uploads/2015/03/image.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/03/image_thumb.png" alt="image" width="691" height="596" border="0" /></a>

I have added a lot of comments in this XML file so it should be very self-explanatory. Just few notes here:

  * This XML configuration file must be placed in the same folder as the script.
  * For each property that you wish to be exported from Service manager, list them under <Properties>&lt;PropertyName&gt; tag.
  * This script also exports the relationships associated with each CI object that is exported. However, only the relationships where the exported CI object is the **source object** are exported.
  * Both <PropertyName> and &lt;CIClassName&gt; are the internal names, Please do not use the display names.
  * You can use the SCSM Entity Explorer (Free download from <a href="https://gallery.technet.microsoft.com/SCSM-Entity-Explorer-68b86bd2">TechNet Gallery</a>) to identify what are the internal names for the class and property that you wish to export.

<a href="http://blog.tyang.org/wp-content/uploads/2015/03/image1.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/03/image_thumb1.png" alt="image" width="678" height="440" border="0" /></a>



## Script

Since I have written a lot of scripts using OpsMgr SDK in the past, I didn’t find Service Manager SDK too hard (although this is only the second time I’ve written scripts for Service Manager). The script itself is fairly simple and short:

```powershell
#==============================================================
# AUTHOR:  Tao Yang 
# DATE:    19/02/2015
# Version: 0.1
# Comment: Extract Service Manager 2012 R2 Configuration Items
#==============================================================
Param(
  [Parameter(Mandatory=$true)][String]$ManagementServer,
  [Parameter(Mandatory=$false)][String]$UserName = $null,
  [Parameter(Mandatory=$false)][SecureString]$Password = $null
)

#Import PS Module
#Import-module SMSDK
#Get the current time stamp
$now = Get-Date
$TimeStamp = Get-Date $now -UFormat %d-%m-%y.%H.%M.%S%Z
Write-Verbose "Current Timestamp: $TimeStamp"
$NowFileDateUTC =$now.ToFileTimeUtc()
#Load Config.xml
$thisscript = $MyInvocation.MyCommand.path
$ScriptRoot = Split-Path(Resolve-Path $thisscript)
$configXml = Join-Path $scriptRoot "Config.xml"
Write-Verbose "Reading Configuraiton XML file `'$ConfigXml`'..."
$xml = [xml][/xml](Get-Content $configXml)
$outputDir = $xml.configuration.OutputLocation
$LastSyncFileDateUTC = $xml.configuration.LastSyncFileDateUTC
If ($LastSyncFileDateUTC)
{
  $LastSyncDate = [datetime]::FromFileTimeUTC($LastSyncFileDateUTC)
  Write-Verbose "Last Sync Date (UTC): $LastSyncDate"
  $bFullSync = $false
} else {
  $LastSyncDate = $Null
  Write-Verbose "Last Sync Date is NULL."
  $bFullSync = $true
}
Write-Verbose "CI and Relationship exports will be saved in folder `'$OutputDir`'."

#Connect to SCSM Management Group
Write-Verbose "Connecting to System Center Service Manager SDK via server $ManagementServer`..."
If ($UserName -and $Password)
{
  $MG = Connect-SMManagementGroup -SDK $ManagementServer -UserName $UserName -Password $Password
} else {
  $MG = Connect-SMManagementGroup -SDK $ManagementServer
}
#Get the list of CI classes
Write-Verbose "Getting a list of CI classes to be imported from $ConfigXML`..."
$arrCIClasses = New-Object System.Collections.ArrayList
Foreach ($Item in $xml.Configuration.CIClasses.CICLass)
{
  Write-Verbose "Adding CI class `'$($item.CIClassName)`' to the list."
  [void]$arrCIClasses.Add($Item.CIClassName)
}

#Create an ArrayList to store relationship information
$arrRelationships = New-object System.Collections.ArrayList

#Create an ArrayList to store excluded relationship types
Write-Verbose "Processing excluded relationship types..."
$arrExcludedRelationshipTypes = New-Object System.Collections.ArrayList
Foreach ($item in $XML.Configuration.ExcludedRelationshipTypes.ExcludedRelationshipType)
{
  Write-Verbose "Relationship type '$item' will be excluded."
  [Void]$arrExcludedRelationshipTypes.Add($item)
}

#CI Search methods
[Type[]]$MethodType = ([Microsoft.EnterpriseManagement.Common.EnterpriseManagementObjectCriteria],[Microsoft.EnterpriseManagement.Common.ObjectQueryOptions])
$method = $mg.EntityObjects.GetType().GetMethod("GetObjectReader",$MethodType)
$genericMethod = $method.MakeGenericMethod([Microsoft.EnterpriseManagement.Common.EnterpriseManagementObject])
#related objects (where source) method type
[Type[]]$RelatedMethodType = @([Guid], [Microsoft.EnterpriseManagement.Common.TraversalDepth], [Microsoft.EnterpriseManagement.Common.ObjectQueryOptions])
$RelatedMethod = $mg.EntityObjects.GetType().GetMethod("GetRelationshipObjectsWhereSource",$RelatedMethodType)
$RelatedGenericMethod = $RelatedMethod.MakeGenericMethod([Microsoft.EnterpriseManagement.Common.EnterpriseManagementObject])
  
#Retrieve instances of each CI class
Foreach ($xmlCIClass in $xml.Configuration.CIClasses.CIClass)
{
  #CI Class Name
  $CIClassName = $xmlCIClass.CIClassName
  Write-Verbose "Start processing CI Class `'$CIClassName`'."
  #Properties to be captured
  $arrProperties = New-Object System.Collections.ArrayList
  Foreach ($item in $xmlCIClass.Properties.PropertyName)
  { 
    [void]$arrProperties.Add($($item.Tolower()))
  }
  
  #Make sure the ObjectStatus property is added (this is mandatory)
  If (!($arrProperties.contains('objectstatus')))
  {
    Write-Verbose "Add mandatory property 'objectstatus' to the property list."
    [Void]$arrProperties.Add("objectstatus")
  }

  #Retrieve the CI Class
  $CICriteria = New-Object Microsoft.EnterpriseManagement.Configuration.ManagementPackClassCriteria("Name='$CIClassName'")
  $CIClass = $MG.EntityTypes.GetClasses($CICriteria)[0]

  #Searching for applicable CI instances
  If (!$bFullSync)
  {
    #Only retrieve active items updated since last synchronisation
    #$dtLastSyncDate = [datetime]::ParseExact("$LastSyncDate", "dd/MM/yyyy h:mm:ss", $null)
    $strCriteria = "LastModified > '$LastSyncDate'"
    Write-Verbose "Instance Criteria string: `"$strCriteria`"."
    [Microsoft.EnterpriseManagement.Common.EnterpriseManagementObjectCriteria]$InstanceCriteria = New-object Microsoft.EnterpriseManagement.Common.EnterpriseManagementObjectCriteria($strCriteria, $CIClass)
  } else {
    #Retrieve all active items
    Write-Verbose "Last Sync Date is null. Instance Criteria string is set to NULL (getting all instances)."
    [Microsoft.EnterpriseManagement.Common.EnterpriseManagementObjectCriteria]$InstanceCriteria = New-object Microsoft.EnterpriseManagement.Common.EnterpriseManagementObjectCriteria($NULL, $CIClass)
  }

  #Get all CI instances
  Write-Verbose "Retrieving instances of CI class '$CIClassName`'..."
  $CIobjects = $genericMethod.Invoke($mg.EntityObjects, ([Microsoft.EnterpriseManagement.Common.EnterpriseManagementObjectCriteria]$InstanceCriteria, [Microsoft.EnterpriseManagement.Common.ObjectQueryOptions]::Default))

  #Process the result
  $arrCIInstances = New-Object System.Collections.ArrayList
  
  Foreach ($CIObject in $CIObjects)
  {
    #Create a custom psobject to store the configuration item
    $ObjCIInstance = New-Object psobject
    #Adding few additional properties
    #Class Name
    Add-Member -InputObject $ObjCIInstance -MemberType NoteProperty -Name ClassName -Value $CIClassName
    #FullName
    Add-Member -InputObject $ObjCIInstance -MemberType NoteProperty -Name FullName -Value $CIObject.FullName
    #CI Object ID
    Add-Member -InputObject $ObjCIInstance -MemberType NoteProperty -Name Id -Value $CIObject.Id
    #CI Object Last Modified date
    Add-Member -InputObject $ObjCIInstance -MemberType NoteProperty -Name LastModified -Value $CIObject.LastModified
    Foreach ($item in $CIObject.Values)
    {
      $TypeName = $item.Type.Name.ToLower()
      if ($arrProperties.contains($TypeName))
      {
        #If it's enumeration value, make sure we capture the display name
        If ($item.Value.XmlTag -eq "EnumerationValue")
        {
          $ItemValue = $item.Value.DisplayName
        } else {
          $ItemValue = $item.Value
        }
        Add-Member -InputObject $ObjCIInstance -MemberType NoteProperty -Name $item.Type.Name -Value $ItemValue
      }
    }
    #Add the custom psojbect to an ArrayList
    [Void]$arrCIInstances.Add($objCIInstance)

    #Get related objects
    #Source Classes
      $RelatedObjects = $RelatedGenericMethod.Invoke($mg.EntityObjects, ([guid]$CIObject.Id, [Microsoft.EnterpriseManagement.Common.TraversalDepth]::OneLevel, [Microsoft.EnterpriseManagement.Common.ObjectQueryOptions]::Default))
      Foreach ($RelatedObject in $RelatedObjects)
      {
        #Get the relationship class Name
        $RelationshipClassName = $MG.EntityTypes.GetRelationshipClass($RelatedObject.RelationshipId).Name
        If (!$arrExcludedRelationshipTypes.Contains($RelationshipClassName))
        {
          $objRelationship = New-Object psobject
          Add-Member -InputObject $objRelationship -MemberType NoteProperty RelationShipName -Value  $RelationshipClassName
          Add-Member -InputObject $objRelationship -MemberType NoteProperty RelationShipClassId -Value  $RelatedObject.RelationshipId
          Add-Member -InputObject $objRelationship -MemberType NoteProperty RelationShipObjectId -Value  $RelatedObject.Id
          Add-Member -InputObject $objRelationship -MemberType NoteProperty SourceObjectId -Value  $RelatedObject.SourceObject.Id
          Add-Member -InputObject $objRelationship -MemberType NoteProperty SourceObjectName -Value  $RelatedObject.SourceObject.Name
          Add-Member -InputObject $objRelationship -MemberType NoteProperty SourceObjectFullName -Value  $RelatedObject.SourceObject.FullName
          Add-Member -InputObject $objRelationship -MemberType NoteProperty TargetObjectId -Value  $RelatedObject.TargetObject.Id
          Add-Member -InputObject $objRelationship -MemberType NoteProperty TargetObjectName -Value  $RelatedObject.TargetObject.Name
          Add-Member -InputObject $objRelationship -MemberType NoteProperty TargetObjectFullName -Value  $RelatedObject.TargetObject.FullName
          [Void]$arrRelationships.Add($objRelationship)
        }
      }
  }
  $CICount = $arrCIInstances.Count
  Write-Verbose "Total Number of $CIClassName instances: $CICount."
  #Export the ArrayLists ot CSV
  if ($arrCIInstances.Count-gt 0)
  {
    Write-Verbose "Exporting CI instances for $CIClassName`..."
    $CIOutPutPath = Join-Path $outputDir "CMDB`.$CIClassName.CI.$TimeStamp.csv"
    $arrCIInstances | Export-Csv $CIOutPutPath -NoTypeInformation
  } else {
    Write-Verbose "No instances of '$CIClassName' is returned from search result."
  }
}
if ($arrRelationships.Count -gt 0)
{
  Write-Verbose "Exporting Relationship information..."
  $RelationshipOutputPath = Join-Path $outputDir "CMDB`.RShip.$TimeStamp.csv"
  $arrRelationships | Export-Csv $RelationshipOutputPath -NoTypeInformation
} else {
  Write-Verbose "No Relationships have been returned from search result."
}

Write-Verbose "Updating LastSyncFileDateUTC in the XML file '$ConfigXML'."
$XML.Configuration.LastSyncFileDateUTC = $NowFileDateUTC.tostring()
$XML.save($configXml)
```

To execute the script, simply pass the service management server name (user name and password are optional), and you can also use -verbose if you'd like to see verbose messages:

```powershell
.\SMConfigItemExtract.ps1 -ManagementServer SCSMMS01 -verbose
```
## Outputs

This script will create a separate CSV file for each CI class that’s configured in the XML. It will also create a single CSV file for ALL relationships export:

<a href="http://blog.tyang.org/wp-content/uploads/2015/03/image2.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/03/image_thumb2.png" alt="image" width="488" height="103" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2015/03/SNAGHTML1484a713.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML1484a713" src="http://blog.tyang.org/wp-content/uploads/2015/03/SNAGHTML1484a713_thumb.png" alt="SNAGHTML1484a713" width="687" height="223" border="0" /></a>

The script also writes the execution time stamp to the config.xml under <LastSyncFileDateUTC>. When the script runs next time, it will retrieve this value and only export the configuration items that have been changed after this time stamp. If you need to force a full sync, please manually remove the value in this tag:

<a href="http://blog.tyang.org/wp-content/uploads/2015/03/image3.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/03/image_thumb3.png" alt="image" width="463" height="124" border="0" /></a>

## Download

You can download the prerequisite SMSDK PowerShell module <a href="http://blog.tyang.org/wp-content/uploads/2015/02/SMSDK.zip">HERE</a>.

You can download the script and the config.xml file <a href="http://blog.tyang.org/wp-content/uploads/2015/03/SCSMCIExport.zip">HERE</a>.