---
id: 5812
title: PowerShell Script to Create OMS Saved Searches that Maps OpsMgr ACS Reports
date: 2016-12-17T20:16:15+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=5812
permalink: /2016/12/17/powershell-script-to-create-oms-saved-searches-that-maps-opsmgr-acs-reports/
categories:
  - OMS
  - PowerShell
tags:
  - OMS
  - PowerShell
---
Microsoft’s PFE Wei Hao Lim has published an awesome blog post that maps OpsMgr ACS reports to OMS search queries (<a title="https://blogs.msdn.microsoft.com/wei_out_there_with_system_center/2016/07/25/mapping-acs-reports-to-oms-search-queries/" href="https://blogs.msdn.microsoft.com/wei_out_there_with_system_center/2016/07/25/mapping-acs-reports-to-oms-search-queries/">https://blogs.msdn.microsoft.com/wei_out_there_with_system_center/2016/07/25/mapping-acs-reports-to-oms-search-queries/</a>)

There are 36 queries on Wei’s list, so it will take a while to manually create them all as saved searches via the OMS Portal. Since I can see that I will reuse these saved searches in many OMS engagements, I have created a script to automatically create them using the OMS PowerShell Module <a href="https://www.powershellgallery.com/packages/AzureRM.OperationalInsights">AzureRM.OperationalInsights</a>.

So here’s the [script](https://gist.github.com/tyconsulting/0c143b69c59bd4d2b4f96e1511ace0bf):

```powershell
#requires -Version 5.0 -Modules AzureRM.OperationalInsights, AzureRM.profile
<#
============================================================================================================================
AUTHOR:  Tao Yang 
DATE:    17-12-2016
Version: 1.0
Comment:
  - Create OMS saved searches to that map SCOM ACS reports that are
  - Listed in Wei Hao Lim's blog post:
  - https://blogs.msdn.microsoft.com/wei_out_there_with_system_center/2016/07/25/mapping-acs-reports-to-oms-search-queries/
============================================================================================================================
#>
#region class definition
Class OMSSavedSearch
{
  [String]$Name
  [String]$Category
  [String]$Query
  OMSSavedSearch ([String]$Name, [String]$Category, [String]$Query)
  {
    $this.Name = $Name
    $this.Category = $Category
    $this.Query = $Query
  }
}
#endregion

#region Add saved search queries
$Category = 'ACS Reports'
$arrSavedSearches = @()

#Access Violation Account Locked
$arrSavedSearches += [OMSSavedSearch]::new('Access Violation Account Locked Details', $Category, 'Type=SecurityEvent EventID=539 OR EventID=644 OR EventID=4740 OR EventID=6279')
$arrSavedSearches += [OMSSavedSearch]::new('Access Violation Account Locked Events Count', $Category, 'Type=SecurityEvent EventID=539 OR EventID=644 OR EventID=4740 OR EventID=6279 | measure count() by EventID')

#Access Violation: Unsuccessful Logon Attempts
$arrSavedSearches += [OMSSavedSearch]::new('Access Violation: Unsuccessful Logon Attempts Details', $Category, 'Type=SecurityEvent EventID:[529..537] OR EventID=539 OR (EventID=4625 AND Status=0xc000006d)  | Select TargetAccount, IpAddress, Computer, LogonProcessName, AuthenticationPackageName, LogonTypeName')
$arrSavedSearches += [OMSSavedSearch]::new('Access Violation: Unsuccessful Logon Attempts Target Account Count', $Category, 'Type=SecurityEvent EventID:[529..537] OR EventID=539 OR (EventID=4625 AND Status=0xc000006d) | measure count() by TargetAccount')

#Account Management: Domain and Built-in Administrators Membership Changes
$arrSavedSearches += [OMSSavedSearch]::new('Access Violation: Unsuccessful Logon Attempts Details', $Category, 'Type=SecurityEvent EventID:[529..537] OR EventID=539 OR (EventID=4625 AND Status=0xc000006d)  | Select TargetAccount, IpAddress, Computer, LogonProcessName, AuthenticationPackageName, LogonTypeName')
$arrSavedSearches += [OMSSavedSearch]::new('Access Violation: Unsuccessful Logon Attempts Target Account Count', $Category, 'Type=SecurityEvent EventID:[529..537] OR EventID=539 OR (EventID=4625 AND Status=0xc000006d) | measure count() by TargetAccount')

#Account Management: Passwords Change Attempts by Non-owner
$arrSavedSearches += [OMSSavedSearch]::new('Account Management: Passwords Change Attempts by Non-owner', $Category, 'Type=SecurityEvent (EventID=4723 OR EventID=4724 OR EventID:[627..628]) AND SubjectAccount!="ANONYMOUS LOGON" TargetAccount NOT IN {Type=SecurityEvent (EventID=4723 OR EventID=4724 OR EventID:[627..628]) AND SubjectAccount!="ANONYMOUS LOGON" | measure count() by SubjectAccount} | EXTEND SubjectAccount AS ChangedBy | Select  TimeGenerated, Computer, TargetAccount, ChangedBy')

#Account Management: User Accounts Created
$arrSavedSearches += [OMSSavedSearch]::new('Account Management: User Accounts Created', $Category, 'Type=SecurityEvent (EventID=624 OR EventID=4720) | EXTEND SubjectAccount AS CreatedBy | Select TimeGenerated, TargetAccount, CreatedBy, Computer')

#Account Management: User Accounts Deleted
$arrSavedSearches += [OMSSavedSearch]::new('Account Management: User Accounts Created', $Category, 'Type=SecurityEvent (EventID=630 OR EventID=4726) | EXTEND SubjectAccount AS DeletedBy | Select TimeGenerated, TargetAccount, DeletedBy, Computer')

#Forensic: All Events For Specified Computer
$arrSavedSearches += [OMSSavedSearch]::new('Forensic: All Events For Specified Computer (Update <<Computer Name>>)', $Category, 'Type=SecurityEvent Computer="<<Computer Name>>"')
$arrSavedSearches += [OMSSavedSearch]::new('Forensic: All Events For Specified Computer Activity Count (Update <<Computer Name>>)', $Category, 'Type=SecurityEvent Computer="<<Computer Name>>" | measure count() by Activity')

#Forensic: All Events For Specified User
$arrSavedSearches += [OMSSavedSearch]::new('Forensic: All Events For Specified User (Update <<User Domain\\Account Name>>)', $Category, 'Type=SecurityEvent Account="<<User Domain\\Account Name>>"')
$arrSavedSearches += [OMSSavedSearch]::new('Forensic: All Events For Specified User Activity Count (Update <<User Domain\\Account Name>>)', $Category, 'Type=SecurityEvent Account="<<User Domain\\Account Name>>" | measure count() by Activity')

#Forensic: All Events With Specified Event ID
$arrSavedSearches += [OMSSavedSearch]::new('Forensic: All Events With Specified Event ID (Update <<Event Id>>)', $Category, 'Type=SecurityEvent EventID="<<Event Id>>"')
$arrSavedSearches += [OMSSavedSearch]::new('Forensic: All Events With Specified Event ID (Update <<Event Id>>) Count by Computer', $Category, 'Type=SecurityEvent EventID="<<Event Id>>" | measure count() by Computer')
$arrSavedSearches += [OMSSavedSearch]::new('Forensic: All Events With Specified Event ID (Update <<Event Id>>) Count by Account', $Category, 'Type=SecurityEvent EventID="<<Event Id>>" | measure count() by Account')

#Planning: Event Counts
$arrSavedSearches += [OMSSavedSearch]::new('Planning: Event Counts', $Category, 'Type=SecurityEvent EventID!=0 | measure count() AS Count by Activity')

#Planning: Event Counts by Computer
$arrSavedSearches += [OMSSavedSearch]::new('Planning: Event Counts by Computer by activity (Update <<Computer Name>>)', $Category, 'Type=SecurityEvent Computer="<<Computer Name>>" | measure count() by Activity')
$arrSavedSearches += [OMSSavedSearch]::new('Planning: Event Counts by Computer by Event ID (Update <<Computer Name>>)', $Category, 'Type=SecurityEvent Computer="<<Computer Name>>" | measure count() by EventID')

#Planning: Hourly Event Distribution
$arrSavedSearches += [OMSSavedSearch]::new('Planning: Hourly Event Distribution', $Category, 'Type=SecurityEvent EventID!=0 | measure count() AS Count by TimeGenerated Interval 1Hour')
$arrSavedSearches += [OMSSavedSearch]::new('Planning: Hourly Event Distribution Filter by Event ID range (Update [xx..yy])', $Category, 'Type=SecurityEvent EventID!=0 AND EventID:[xx..yy] | measure count() AS Count by Activity Interval 1Hour')

#Planning: Logon Counts of Privileged Users
$arrSavedSearches += [OMSSavedSearch]::new('Planning: Logon Counts of Privileged Users', $Category, 'Type=SecurityEvent EventID=576 OR EventID=4672 AND SubjectDomainName!="NT AUTHORITY" AND AccountType!="Machine" | Select SubjectAccount, PrivilegeList')
$arrSavedSearches += [OMSSavedSearch]::new('Planning: Logon Counts of Privileged Users Count by SubjectAccount', $Category, 'Type=SecurityEvent EventID=576 OR EventID=4672 AND SubjectDomainName!="NT AUTHORITY" AND AccountType!="Machine" | Measure Count() by SubjectAccount')

#Policy: Account Policy Changed
$arrSavedSearches += [OMSSavedSearch]::new('Policy: Account Policy Changed', $Category, 'Type=SecurityEvent EventID=643 OR EventID=4739 | Select Computer, Activity, TimeGenerated, EventData')

#Policy: Audit Policy Changed
$arrSavedSearches += [OMSSavedSearch]::new('Policy: Audit Policy Changed', $Category, 'Type=SecurityEvent EventID=612 OR EventID=4719 | Select Computer, Activity, TimeGenerated, EventData')

#Policy: Object Permissions Changed
$arrSavedSearches += [OMSSavedSearch]::new('Policy: Object Permissions Changed', $Category, 'Type=SecurityEvent EventID=4670 | Select TimeGenerated, Activity, Computer, EventData')

#Policy: Privilege Added Or Removed
$arrSavedSearches += [OMSSavedSearch]::new('Policy: Privilege Added Or Removed', $Category, 'Type=SecurityEvent EventID:[608..609] OR EventID:[621..622] OR EventID:[4704..4705] | Select TimeGenerated, Activity, Computer, EventData')

#System Integrity: Audit Failure
$arrSavedSearches += [OMSSavedSearch]::new('System Integrity: Audit Failure', $Category, 'Type=SecurityEvent EventID=516 OR EventID=4612 | Select TimeGenerated, Activity, Computer')

#System Integrity: Audit Log Cleared
$arrSavedSearches += [OMSSavedSearch]::new('System Integrity: Audit Log Cleared', $Category, 'Type=SecurityEvent EventID=517 OR EventID=1102 | Select Activity, Computer, TimeGenerated, EventData')

#Usage: Object Access
$arrSavedSearches += [OMSSavedSearch]::new('Usage: Object Access', $Category, 'Type=SecurityEvent EventID=560 OR EventID=567 OR EventID=4656 OR EventID=4663 | Select Computer, Activity, TimeGenerated, EventData')

#Usage: Privileged logon
$arrSavedSearches += [OMSSavedSearch]::new('Usage: Privileged logon', $Category, 'Type=SecurityEvent EventID=576 OR EventID=4672 | Select TimeGenerated, Activity, Computer, SubjectAccount, PrivilegeList')

#Usage: Sensitive Security Groups Changes
$arrSavedSearches += [OMSSavedSearch]::new('Usage: Sensitive Security Groups Changes', $Category, 'Type=SecurityEvent EventID:[4727..4735] OR EventID=4737 OR EventID:[4754..4758] OR EventID:[631..639] OR EventID=641 OR EventID:[658..662] | EXTEND TargetUserName As GroupName | Select Activity, GroupName, SubjectAccount, MemberName, TimeGenerated')

#Usage: User Logon
$arrSavedSearches += [OMSSavedSearch]::new('Usage: User Logon', $Category, 'Type=SecurityEvent EventID=528 OR EventID=540 OR EventID=4624 | Select TimeGenerated, Activity, Computer, IpAddress, AuthenticationPackageName, LogonProcessName, LogonTypeName, TargetAccount')

#DAC: File Resource Property Changes
$arrSavedSearches += [OMSSavedSearch]::new('DAC: File Resource Property Changes', $Category, 'Type=SecurityEvent EventID=4911 | Select Computer, Activity, TimeGenerated, SubjectAccount, EventData')

#DAC: Central Access Policy For File Changes
$arrSavedSearches += [OMSSavedSearch]::new('DAC: Central Access Policy For File Changes', $Category, 'Type=SecurityEvent EventID=4913 | Select Computer, Activity, TimeGenerated, SubjectAccount, EventData')

#DAC: Object Attribute Changes
$arrSavedSearches += [OMSSavedSearch]::new('DAC: Object Attribute Changes', $Category, 'Type=SecurityEvent EventID=5136 OR EventID=5137 | Select Computer, Activity, TimeGenerated, SubjectAccount, EventData')
#endregion

#region Login to Azure and create the saved searches
#Login to Azure
Write-Output -InputObject 'Log in to Azure'
$LoginToAzure = $null = Add-AzureRmAccount -WarningAction SilentlyContinue

#Get Azure Sub
$Subscriptions = Get-AzureRmSubscription -WarningAction SilentlyContinue
Write-Output -InputObject 'Choose Azure Subscription where OMS Log Analytics Workspace is located:'
for ($i = 1;$i -le $Subscriptions.count; $i++) 
{
  Write-Host -Object "$i. $($Subscriptions[$i-1].SubscriptionName)"
}

[int]$ans = Read-Host -Prompt 'Enter selection'
$subscription = $Subscriptions[$ans-1]
$null = Set-AzureRmContext -SubscriptionName $subscription.SubscriptionName
Write-Output -InputObject ''
#Get OMS workspace
Write-Output -InputObject 'Select OMS Log Analytics Workspace:'
$OMSWorkspaces = Get-AzureRmOperationalInsightsWorkspace
for ($i = 1;$i -le $OMSWorkspaces.count; $i++) 
{
  Write-Host -Object "$i. $($OMSWorkspaces[$i-1].Name)"
}

[int]$ans = Read-Host -Prompt 'Enter selection'
$OMSWorkspace = $OMSWorkspaces[$ans-1]

#Create saved searches
Write-Output -InputObject 'Start creating saved searches'
Foreach ($item in $arrSavedSearches)
{
  Write-Output -InputObject "  - Creating saved search - Category: '$($item.Category)', Search Query: '$($item.Name)'"
  $SavedSearchId = [GUID]::NewGuid().Tostring()
  $NewSavedSearch = New-AzureRmOperationalInsightsSavedSearch -ResourceGroupName $OMSWorkspace.ResourceGroupName -WorkspaceName $OMSWorkspace.Name -SavedSearchId $SavedSearchId -DisplayName $item.Name -Category $item.Category -Query $item.Query -Version 1
}

Write-Output -InputObject 'Done!'
#endregion
```

You must run this script in PowerShell version 5 or later. Lastly, thanks Wei for sharing these valuable queries with the community!