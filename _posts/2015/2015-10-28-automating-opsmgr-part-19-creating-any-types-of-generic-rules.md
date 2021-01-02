---
id: 4834
title: 'Automating OpsMgr Part 19: Creating Any Types of Generic Rules'
date: 2015-10-28T23:04:12+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=4834
permalink: /2015/10/28/automating-opsmgr-part-19-creating-any-types-of-generic-rules/
categories:
  - Azure
  - OMS
  - PowerShell
  - SCOM
  - SMA
tags:
  - Automating OpsMgr
  - Azure Automation
  - PowerShell
  - SCOM
  - SMA
---
<h3><a href="http://blog.tyang.org/wp-content/uploads/2015/06/OpsMgrExnteded.png"><img class="alignleft size-thumbnail wp-image-4038" src="http://blog.tyang.org/wp-content/uploads/2015/06/OpsMgrExnteded-150x150.png" alt="OpsMgrExnteded" width="150" height="150" /></a>Introduction</h3>
This is the 19th instalment of the Automating OpsMgr series. Previously on this series:
<ul>
	<li><a href="http://blog.tyang.org/2015/06/24/automating-opsmgr-part-1-introducing-opsmgrextended-powershell-sma-module/">Automating OpsMgr Part 1: Introducing OpsMgrExtended PowerShell / SMA Module</a></li>
	<li><a href="http://blog.tyang.org/2015/06/28/automating-opsmgr-part-2-sma-runbook-for-creating-configmgr-log-collection-rules/">Automating OpsMgr Part 2: SMA Runbook for Creating ConfigMgr Log Collection Rules</a></li>
	<li><a href="http://blog.tyang.org/2015/06/30/automating-opsmgr-part-3-new-management-pack-runbook-via-sma-and-azure-automation/">Automating OpsMgr Part 3: New Management Pack Runbook via SMA and Azure Automation</a></li>
	<li><a href="http://blog.tyang.org/2015/07/02/automating-opsmgr-part-4-create-new-empty-groups/">Automating OpsMgr Part 4:Creating New Empty Groups</a></li>
	<li><a href="http://blog.tyang.org/2015/07/06/automating-opsmgr-part-5-adding-computers-to-computer-groups/">Automating OpsMgr Part 5: Adding Computers to Computer Groups</a></li>
	<li><a href="http://blog.tyang.org/2015/07/13/automating-opsmgr-part-6-adding-monitoring-objects-to-instance-groups/">Automating OpsMgr Part 6: Adding Monitoring Objects to Instance Groups</a></li>
	<li><a href="http://blog.tyang.org/2015/07/17/automating-opsmgr-part-7-updated-opsmgrextended-module/">Automating OpsMgr Part 7: Updated OpsMgrExtended Module</a></li>
	<li><a href="http://blog.tyang.org/2015/07/17/automating-opsmgr-part-8-adding-management-pack-references/">Automating OpsMgr Part 8: Adding Management Pack References</a></li>
	<li><a href="http://blog.tyang.org/2015/07/17/automating-opsmgr-part-9-updating-group-discoveries/">Automating OpsMgr Part 9: Updating Group Discoveries</a></li>
	<li><a href="http://blog.tyang.org/2015/07/27/automating-opsmgr-part-10-deleting-groups/">Automating OpsMgr Part 10: Deleting Groups</a></li>
	<li><a href="http://blog.tyang.org/2015/07/29/automating-opsmgr-part-11-configuring-group-health-rollup/">Automating OpsMgr Part 11: Configuring Group Health Rollup</a></li>
	<li><a href="http://blog.tyang.org/2015/08/08/automating-opsmgr-part-12-creating-performance-collection-rules/">Automating OpsMgr Part 12: Creating Performance Collection Rules</a></li>
	<li><a href="http://blog.tyang.org/2015/08/24/automating-opsmgr-part-13-creating-2-state-performance-monitors/">Automating OpsMgr Part 13: Creating 2-State Performance Monitors</a></li>
	<li><a href="http://blog.tyang.org/2015/08/31/automating-opsmgr-part-14-creating-event-collection-rules/">Automating OpsMgr Part 14: Creating Event Collection Rules</a></li>
	<li><a href="http://blog.tyang.org/2015/09/25/automating-opsmgr-part-15-creating-2-state-event-monitors/">Automating OpsMgr Part 15: Creating 2-State Event Monitors</a></li>
	<li><a href="http://blog.tyang.org/2015/10/02/automating-opsmgr-part-16-creating-windows-service-monitors/">Automating OpsMgr Part 16: Creating Windows Service Monitors</a></li>
	<li><a href="http://blog.tyang.org/2015/10/04/automating-opsmgr-part-17-creating-windows-service-management-pack-template-instance/">Automating OpsMgr Part 17: Creating Windows Service Management Pack Template Instance</a></li>
	<li><a href="http://blog.tyang.org/2015/10/14/automating-opsmgr-part-18-second-update-to-the-opsmgrextended-module-v1-2/">Automating OpsMgr Part 18: Second Update to the OpsMgrExtended Module (v1.2)</a></li>
</ul>
Although I have written number of functions in the current version of the OpsMgrExtended module that allows you to  create some popular types of rules in OpsMgr (i.e. perf collection rules and event collection rules). Sometimes, you still need to create other types of rules, such as WMI event collection rules, or rules based on module types written by yourself. In this post, I will demonstrate how to create any types of rules using the <strong>New-OMRule</strong> function.

Additionally, since the OpsMgrExtended module can be used on both your on-prem SMA infrastructure as well as on your Azure Automation account (with the help of Hybrid Workers), and pretty much all the previous runbooks and posts are based on SMA, I will use Azure Automation in this post (and maybe in the future posts too). I will demonstrate 2 sample runbooks in this post. Since Azure Automation now supports PowerShell runbooks on both Azure runbook workers as well as on hybrid workers, with the 2 sample runbooks I’m going to demonstrate, one is based on PowerShell workflow and the other one is a PowerShell runbook.
<h3>What Components are OpsMgr Rules Made Up?</h3>
Before we diving into the sample runbooks, please let me explain how are the OpsMgr rules made up. In OpsMgr, a rule is essentially a workflow that contains the following components:
<ol>
	<li>One or more Data Source modules</li>
	<li>Zero or one Condition Detection Modules</li>
	<li>One or more Write Action modules</li>
</ol>
To explain in plain English, a rule can have multiple data source modules and write action modules, but condition detection module is optional, and you can only use up to 1 condition detection module in your rule. The order of execution is Data Source Modules –&gt; Condition Detection Module –&gt; Write Action Modules. Additionally, some modules requires mandatory and/or optional configuration parameters (i.e. System.SimpleScheduler), some modules do not require any configuration parameters (i.e. Microsoft.SystemCenter.CollectPerformanceData).
<h3>OM-Rule Design Consideration</h3>
When I was writing the New-OMRule function, I have realised in order to capture all required information for each member module, the following information is required:
<ul>
	<li>Module Type Name (Mandatory)</li>
	<li>Configuration (Optional)</li>
	<li>Member Module Name (Mandatory)</li>
	<li>RunAs Profile Name (Optional)</li>
</ul>
i.e. in the example below, I have high lighted the information required in a member module of a rule.

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/image32.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/10/image_thumb26.png" alt="image" width="668" height="142" border="0" /></a>

Other than the information listed above, if we are writing an alert-generating rule, we would also need the following information for the alert configuration:
<ul>
	<li>String Resource</li>
	<li>Language Pack ID</li>
	<li>Alert Name</li>
	<li>Alert Description</li>
</ul>
<h3></h3>
I needed to figure out a way to enforce users to supply all required information listed above. In order to do that, I think the best way is to define a class for member module configurations and another class for alert configurations. However, since class definition is a new concept only been introduced in PowerShell version 5 (which still in preview other than Windows 10 machines at the time of this writing), I could not do this natively in PowerShell. In order to work around this limitation, I have defined these two classes in OpsMgrExtended.Types.dll using C#. This DLL is shipped as part of the OpsMgrExtended module.

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/image33.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/10/image_thumb27.png" alt="image" width="471" height="193" border="0" /></a>

The OM-Rule is expecting instances of these classes defined in OpsMgrExtended.Types.dll as input parameters. You will see how I used these classes in the sample runbooks.
<h3>Sample PowerShell Runbook: New-WMIPerfCollectionRule</h3>
OK, let’s start with a "simpler" one first. The <strong>New-WMIPerfCollectionRule</strong> runbook is a PowerShell runbook that can be used to create perf collection rules based on WMI queries. I think it’s simpler than the other one because it’s a PowerShell runbook (as opposed to PowerShell workflow) and we don’t have to worry about configuring alerts for the rules created by this runbook. The source code for this runbook is listed below:
<pre class="" language="PowerShell">
Param(
[Parameter(Mandatory=$true)][String]$RuleName,
[Parameter(Mandatory=$true)][String]$RuleDisplayName,
[Parameter(Mandatory=$true)][String]$ClassName,
[Parameter(Mandatory=$false)][String]$WMINamespace="Root\CIMV2",
[Parameter(Mandatory=$true)][String]$WMIQuery,
[Parameter(Mandatory=$false)][Int]$IntervalSeconds=900,
[Parameter(Mandatory=$true)][String]$ObjectName,
[Parameter(Mandatory=$true)][String]$CounterName,
[Parameter(Mandatory=$false)][String]$InstanceNameWMIProperty,
[Parameter(Mandatory=$true)][String]$ValueWMIProperty
)
    
#Get OpsMgrSDK connection object
$OpsMgrSDKConn = Get-AutomationConnection -Name "OpsMgrSDK_HOME"

#Load the OpsMgrExtended PS module
Write-Verbose "Importing OpsMgrExtended PS module."
Import-Module OpsMgrExtended

#Data Source Module Configuration:
Write-Verbose "Configuring Data Source modules."
[OpsMgrExtended.ModuleConfiguration[]]$arrDataSourceModules = @()
$DAModuleTypeName = "Microsoft.Windows.WmiProvider"
$DAConfiguration = @"
<NameSpace>$WMINamespace</NameSpace>
<Query>$WMIQuery</Query>
<Frequency>$IntervalSeconds</Frequency>
"@
$DAMemberModuleName = "DS"
$DataSourceConfiguration = New-OMModuleConfiguration -ModuleTypeName $DAModuleTypeName -Configuration $DAConfiguration -MemberModuleName $DAMemberModuleName
$arrDataSourceModules += $DataSourceConfiguration

#Condition Detection Module
Write-Verbose "Configuring Condition Detection module."
If ($InstanceNameWMIProperty -ne $null)
{
	$InstanceName = "`$Data/Property[@Name='$InstanceNameWMIProperty']$"
} else {
	$InstanceName = "_Total"
}
$CDModuleTypeName = "System.Performance.DataGenericMapper"
$CDConfig = @"
<ObjectName>Logical Disk</ObjectName>
<CounterName>$CounterName</CounterName>
<InstanceName>$InstanceName</InstanceName>
<Value>`$Data/Property[@Name='$ValueWMIProperty']$</Value>	
"@
$ConditionDetectionConfiguration = New-OMModuleConfiguration -ModuleTypeName $CDModuleTypeName -Configuration $CDConfig -MemberModuleName "MapToPerf"

#Write Action modules
Write-Verbose "Configuring write action modules."
[OpsMgrExtended.ModuleConfiguration[]]$arrWriteActionModules = @()
$WAWriteToDBConfiguration = New-OMModuleConfiguration -ModuleTypeName "Microsoft.SystemCenter.CollectPerformanceData" -MemberModuleName "WriteToDB"
$WAWriteToDWConfiguration = New-OMModuleConfiguration -ModuleTypeName "Microsoft.SystemCenter.DataWarehouse.PublishPerformanceData" -MemberModuleName "WriteToDW"
$WAWriteToOMSConfiguration = New-OMModuleConfiguration -ModuleTypeName "Microsoft.SystemCenter.CollectCloudPerformanceData" -MemberModuleName "WriteToOMS"
$arrWriteActionModules += $WAWriteToDBConfiguration
$arrWriteActionModules += $WAWriteToDWConfiguration
$arrWriteActionModules += $WAWriteToOMSConfiguration

#Create WMI Event Collection Rule, MP Version will be increased by 0.0.0.1
$MPName = "Test.OpsMgrExtended"

        
#Validate rule Name
If ($RuleName -notmatch "([a-zA-Z0-9]+\.)+[a-zA-Z0-9]+")
{
    #Invalid rule name entered
    $ErrMsg = "Invalid rule name specified. Please make sure it only contains alphanumeric charaters and only use '.' to separate words. i.e. 'Your.Company.XYZ.WMI.Performance.Collection.Rule'."
    Write-Error $ErrMsg 
} else {
    #Name is valid, creating the rule
	$RuleCreated = New-OMRule -SDKConnection $OpsMgrSDKConn -MPName $MPName -RuleName $RuleName -RuleDisplayName $RuleDisplayName -Category "PerformanceCollection" -ClassName $ClassName -DataSourceModules $arrDataSourceModules -ConditionDetectionModule $ConditionDetectionConfiguration -WriteActionModules $arrWriteActionModules -Remotable $false
}

If ($RuleCreated)
{
	Write-Output "Rule `"$RuleName`" created."
} else {
	Write-Error "Unable to create Rule `"$RuleName`"."
}

```
As you can see, this runbook requires the following input parameters:
<ul>
	<li>RuleName – the internal name of the rule</li>
	<li>RuleDisplayName – the display name of the rule. this is what people will see in OpsMgr console</li>
	<li>ClassName – The internal name of the target class (i.e. "Microsoft.Windows.OperatingSystem")</li>
	<li>WMINameSpace – the WMI name space of where the WMI class you are going to query resides. This is optional. if not specified, the default value of "Root\CIMV2" will be used</li>
	<li>WMIQuery – the WMI query to retrieve the performance counter value</li>
	<li>IntervalSeconds – the rule execution interval in seconds. this is optional, if not specified, the default value of 900 (15 minutes) will be used.</li>
	<li>ObjectName – The object name for the performance data (i.e. Process, or LogicalDisk)</li>
	<li>CounterName – the counter name for the performance data (i.e. ProcessCount, or FreeSpaceMB)</li>
	<li>InstanceNameWMIProperty – the property returned from the WMI query which represent the performance data instance value (i.e. if you are collecting logical disk counters, the result of WMI query may contain a property that represent the drive letter, which can be used to identify the instance in perf data). This is optional, if not specified, the perf data instance name would be "_Total".</li>
	<li>ValueWMIProperty – the property returned from the WMI query that represent the perf value.</li>
</ul>
The first step of this runbook is to retrieve a connection object named "OpsMgrSDK_Home" from my Azure Automation account (or SMA). This connection object is pre-configured, which contains the computer name of one of my OpsMgr management servers, and the credential of a service account which has OpsMgr admin privilege in my management group.

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/SNAGHTMLddea7c.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLddea7c" src="http://blog.tyang.org/wp-content/uploads/2015/10/SNAGHTMLddea7c_thumb.png" alt="SNAGHTMLddea7c" width="193" height="435" border="0" /></a>

The runbook also needs to explicitly import the OpsMgrExtended module. During the test, I found for this PowerShell runbook, I must manually import the module using <strong>Import-Module</strong> cmdlet in order to load the assemblies defined in the <strong>OpsMgrExtended.Types.dll</strong>. Since we are going to be using hybrid workers, you must manually deploy this module to your hybrid workers because at the time of this writing, Azure Automation is not able to automatically deploy required modules to hybrid workers.

Next, we must define the module configurations for each member module used by the WMI perf collection rules that this runbook creates. I have determined this type of rules should be configured using the following modules
<ul>
	<li>One Data Source Module
<ul>
	<li>Microsoft.Windows.WmiProvider</li>
</ul>
</li>
	<li>One Condition Detection Module
<ul>
	<li>System.Performance.DataGenericMapper</li>
</ul>
</li>
	<li>Three Write Action Modules
<ul>
	<li>Microsoft.SystemCenter.CollectPerformanceData</li>
	<li>Microsoft.SystemCenter.DataWarehouse.PUblishPerformanceData</li>
	<li>Microsoft.SystemCenter.CollectCloudPerformanceData</li>
</ul>
</li>
</ul>
To explain in English, the rules created by this runbook would periodically execute a WMI query (Data source module), then map the result from WMI query to OpsMgr performance data (Condition detection module), finally store the performance data in OpsMgr operational DB, data warehouse DB and also OMS workspace (3 write action modules).

So we will need to use the <strong>New-OMModuleConfiguration</strong> function from the OpsMgrExtended PS module to create an instance of the "OpsMgrExtended.ModuleConfiguration" class. As explained earlier, the "OpsMgrExtended.ModuleConfiguration" class is defined in the OpsMgrExtended.Types.dll. Take the data source member module as an example:
```powershell

$DAModuleTypeName = "Microsoft.Windows.WmiProvider"
$DAConfiguration = @"
<NameSpace>$WMINamespace</NameSpace>
<Query>$WMIQuery</Query>
<Frequency>$IntervalSeconds</Frequency>
"@
$DAMemberModuleName = "DS"
$DataSourceConfiguration = New-OMModuleConfiguration -ModuleTypeName $DAModuleTypeName -Configuration $DAConfiguration -MemberModuleName $DAMemberModuleName

```
I have placed the module type name, module configuration and the member module name into separate variables and passed them to the New-OMModuleConfiguration function and created a module configuration object for the data source module.

<strong>Note:</strong>

You can use <strong>Get-Help New-OMModuleConfiguration</strong> to access the help file for this function. If you need to use an alternative OpsMgr RunAs profile to for any member modules, you can also specify the name of the RunAs profile you are going to use with the<strong> –RunAsMPName</strong> and the <strong>–RunAsName</strong> parameter. The RunAsMPName parameter is used to specify the internal name of the management pack that defined the RunAs profile, and the RunAsName parameter is used to specify the internal name of the RunAs profile (i.e. if you are creating rules for SQL related classes, you might need to use the default SQL RunAs Profile, in this case, the –RunAsMPName would be "Microsoft.SQLServer.Library" and –RunAsName would be "Microsoft.SQLServer.SQLDefaultAccount".)

Since a rule can have multiple data source modules and multiple write action modules, the <strong>New-OMRule</strong> function is expecting the array type of input for data source modules and write action modules. This is why even there is only going to be one data source member module or write action member module, we still need to place them into separate arrays before passing into the OM-Rule function:

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/image34.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/10/image_thumb28.png" alt="image" width="427" height="145" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/image35.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/10/image_thumb29.png" alt="image" width="629" height="111" border="0" /></a>

On the other hand, since the condition detection member module is optional, and you can only have maximum one condition detection member module, you do not need to place the module configuration object for the condition detection module into an array.

Lastly, I have hardcoded the management pack name to be "Test.OpsMgrExtended" in this sample runbook. this MP must be created prior to running this runbook otherwise it would fail. However, if you have a look at the sample runbooks in previous posts, you can easily figure out a way to firstly detect the existence of this MP and use this runbook to create the MP if it does not exist in your management group.

Now, it’s time to take this runbook for a test run. I’m using the following parameters during the test run:
<ul>
	<li>RuleName: "Test.WMIPerfCollection.Process.Count.WMI.Performance.Collection.Rule"</li>
	<li>RuleDisplayName: "Windows Server Process Count Performance Collection Rule"</li>
	<li>ClassName: "Microsoft.Windows.OperatingSystem"</li>
	<li>WMIQuery: "select Processes from Win32_PerfRawData_PerfOS_Objects"</li>
	<li>ObjectName: "Process"</li>
	<li>CounterName: "ProcessCount"</li>
	<li>ValueWMIProperty: "Processes" –verbose</li>
</ul>
And I have specified to run on a hybrid worker group:

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/SNAGHTMLd3df42.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLd3df42" src="http://blog.tyang.org/wp-content/uploads/2015/10/SNAGHTMLd3df42_thumb.png" alt="SNAGHTMLd3df42" width="610" height="693" border="0" /></a>

The hybrid worker will pick up this job very soon, and during this test run, the job was completed around 2 minutes. after the job finishes, I’m able to find this rule in OpsMgr console:

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/image36.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/10/image_thumb30.png" alt="image" width="418" height="437" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/image37.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/10/image_thumb31.png" alt="image" width="419" height="439" border="0" /></a>
<h3>Sample PowerShell Workflow Runbook: New-WindowsEventAlertRule</h3>
Now, let’s take a look at the second sample runbook. This runbook is designed to create rules that detects certain event log entries and generates alerts upon detection. I think it’s more complicated than the first sample because this is a traditional PowerShell workflow runbook (which works on both SMA and Azure Automation), and we also need to configure alert settings for this rule. The source code for this runbook is listed below:
<pre class="" language="PowerShell">
Workflow New-WindowsEventAlertRule
{
    Param(
    [Parameter(Mandatory=$true)][String]$RuleName,
    [Parameter(Mandatory=$true)][String]$RuleDisplayName,
    [Parameter(Mandatory=$true)][String]$ClassName,
	[Parameter(Mandatory=$true)][String]$EventLog,
    [Parameter(Mandatory=$true)][Int]$EventID,
	[Parameter(Mandatory=$true)][String]$EventSource,
	[Parameter(Mandatory=$true)][ValidateSet('Success', 'Error', 'Warning', 'Information', 'Audit Failure', 'Audit Success')][String]$EventLevel,
	[Parameter(Mandatory=$true)][String]$AlertName,
    [Parameter(Mandatory=$true)][ValidateSet('Critical', 'Warning', 'Information')][String]$AlertSeverity,
    [Parameter(Mandatory=$true)][ValidateSet('Low', 'Medium', 'High')][String]$AlertPriority
    )
    
    #Get OpsMgrSDK connection object
    $OpsMgrSDKConn = Get-AutomationConnection -Name "OpsMgrSDK_Home"

	#Get Event Level
    $iEventLevel = Inlinescript
    {
	    Switch ($USING:EventLevel)
	    {
		    'Success' {$iEventLevel = 0}
		    'Error' {$iEventLevel = 1}
		    'Warning' {$iEventLevel = 2}
		    'Information' {$iEventLevel = 4}
		    'Audit Failure' {$iEventLevel = 16}
		    'Audit Success' {$iEventLevel = 8}
	    }
        $iEventLevel
    }
    
    #Get Alert Priority
    $iAlertPriority = InlineScript
    {
 	    Switch ($USING:AlertPriority)
	    {
		    'Low' {$iAlertPriority = 0}
		    'Medium' {$iAlertPriority = 1}
		    'High' {$iAlertPriority = 2}
	    }
        $iAlertPriority   
    }
    
    #Get Alert Severity
        $iAlertSeverity = InlineScript
    {
 	    Switch ($USING:AlertSeverity)
	    {
		    'Information' {$iAlertSeverity = 0}
		    'Warning' {$iAlertSeverity = 1}
		    'Critical' {$iAlertSeverity = 2}
	    }
        $iAlertSeverity   
    }
    #Data Source Module Configuration:
    [OpsMgrExtended.ModuleConfiguration[]]$arrDataSourceModules = @()
    $DAModuleTypeName = "Microsoft.Windows.EventProvider"
    $DAConfiguration = @"
<LogName>$EventLog</LogName>
<Expression>
    <And>
    <Expression>
        <SimpleExpression>
        <ValueExpression>
            <XPathQuery Type="UnsignedInteger">EventDisplayNumber</XPathQuery>
        </ValueExpression>
        <Operator>Equal</Operator>
        <ValueExpression>
            <Value Type="UnsignedInteger">$EventID</Value>
        </ValueExpression>
        </SimpleExpression>
    </Expression>
    <Expression>
        <RegExExpression>
        <ValueExpression>
            <XPathQuery Type="String">PublisherName</XPathQuery>
        </ValueExpression>
        <Operator>ContainsSubstring</Operator>
        <Pattern>$EventSource</Pattern>
        </RegExExpression>
    </Expression>
    <Expression>
        <SimpleExpression>
        <ValueExpression>
            <XPathQuery Type="Integer">EventLevel</XPathQuery>
        </ValueExpression>
        <Operator>Equal</Operator>
        <ValueExpression>
            <Value Type="Integer">$iEventLevel</Value>
        </ValueExpression>
        </SimpleExpression>
    </Expression>
    </And>
</Expression>
"@
    $DAMemberModuleName = "DS"
    $DataSourceConfiguration = New-OMModuleConfiguration -ModuleTypeName $DAModuleTypeName -Configuration $DAConfiguration -MemberModuleName $DAMemberModuleName
    $arrDataSourceModules += $DataSourceConfiguration

    #Write Action modules
    $arrWriteActionModules = @()
	$AlertWAConfig = @"
<Priority>$iAlertPriority</Priority>
<Severity>$iAlertSeverity</Severity>
<AlertName />
<AlertDescription />
<AlertOwner />
<AlertMessageId>`$MPElement[Name="$RuleName.AlertMessage"]$</AlertMessageId>
<AlertParameters>
    <AlertParameter1>`$Data/LoggingComputer$</AlertParameter1>
    <AlertParameter2>`$Data/EventDescription$</AlertParameter2>
</AlertParameters>
"@
    $WAAlertConfiguration = New-OMModuleConfiguration -ModuleTypeName "System.Health.GenerateAlert" -MemberModuleName "Alert" -Configuration $AlertWAConfig
    $arrWriteActionModules += $WAAlertConfiguration

	#Alert configuration
    $arrAlertConfigurations = @()
	$AlertDescription = @"
Computer: {0}
Event Description: {1}
"@
	$StringResource = "$RuleName`.AlertMessage"
	$AlertConfiguration = New-OMAlertConfiguration -AlertName $AlertName -AlertDescription $AlertDescription -StringResource $StringResource
    $arrAlertConfigurations += $AlertConfiguration
    #Create Windows Event alert Rule, MP Version will be increased by 0.0.0.1
    $MPName = "Test.OpsMgrExtended"
    $RuleCreated = InlineScript
    {

        
        #Validate rule Name
        If ($USING:RuleName -notmatch "([a-zA-Z0-9]+\.)+[a-zA-Z0-9]+")
        {
            #Invalid rule name entered
            $ErrMsg = "Invalid rule name specified. Please make sure it only contains alphanumeric charaters and only use '.' to separate words. i.e. 'Your.Company.XYZ.Event.Alert.Rule'."
            Write-Error $ErrMsg 
        } else {
            #Name is valid, creating the rule
            #Write-Verbose "$($USING:arrAlertConfigurations.count)"
			New-OMRule -SDKConnection $USING:OpsMgrSDKConn -MPName $USING:MPName -RuleName $USING:RuleName -RuleDisplayName $USING:RuleDisplayName -Category "Alert" -ClassName $USING:ClassName -DataSourceModules $USING:arrDataSourceModules -WriteActionModules $USING:arrWriteActionModules -Remotable $false -GenerateAlert $true -AlertConfigurations $USING:arrAlertConfigurations
        }
    }

    If ($RuleCreated)
	{
		Write-Output "Rule `"$RuleName`" created."
	} else {
		Write-Error "Unable to create Rule `"$RuleName`"."
	}
}

```
This runbook takes the following input parameters:
<ul>
	<li>RuleName – the internal name of the rule that you are creating</li>
	<li>RuleDisplayName – the display name of the rule</li>
	<li>ClassName – The internal name of the target class (i.e. "Microsoft.Windows.OperatingSystem")</li>
	<li>EventLog – the name of the event log (i.e. "System")</li>
	<li>EventID – the ID of the event that you are detecting</li>
	<li>EventSource – is what you see as "source" in Windows event log</li>
	<li>EventLevel – can be one of the following value:
<ul>
	<li>Success</li>
	<li>Error</li>
	<li>Warning</li>
	<li>Information</li>
	<li>Audit Failure</li>
	<li>Audit Success</li>
</ul>
</li>
	<li>AlertName – the alert name / title</li>
	<li>AlertSeverity – can be one of the following value:
<ul>
	<li>Critical</li>
	<li>Warning</li>
	<li>Information</li>
</ul>
</li>
	<li>AlertProirity – can be one of the following value:
<ul>
	<li>Low</li>
	<li>Medium</li>
	<li>High</li>
</ul>
</li>
</ul>
As you can see, firstly, other than the standard process of retrieving the connection object for my OpsMgr management group, I have used several "Switch" statements with inline scripts to translate the event level, alert priority and alert severity from English words (string) to numbers (integer), because when configuring member modules for OpsMgr rules, we must use the number (instead of names). Note I’ve also used "ValidateSet" to validate the input of these parameters, so only valid inputs are allowed.

I am not going to explain the member module configurations again, because I’ve already covered it in the first sample. But please note because the rules created by this runbook will be generating alerts, we must configure alert settings. In OpsMgr, when a workflow is configured to generate alerts (either rules or monitors), other than the rule / monitor itself, we must also define a String Resource for the alert message ID, as well as defining the alert name and description in a preferred language pack (by default, ENU). Therefore, we are going to use another class defined in OpsMgrExtended.Types.dll for alert configuration. The class for alert configuration is called <strong>OpsMgrExtended.AlertConfiguration</strong>, and you can use <strong>New-OMAlertConfiguration</strong> function to create an instance of this class. Same as all other functions in the OpsMgrExtended PS module, you can use Get-Help cmdlet to access the help file for New-OMAlertConfiguration. You will need to specify the following input parameters for New-OMAlertConfiguration:
<ul>
	<li>AlertName – the name / title of the alert</li>
	<li>AlertDescription – the alert description / detail</li>
	<li>LanguagePackID – the 3-letter language pack code for the language pack that you wish to create the alert message under. this is an optional parameter, if not specified, the default value of "ENU’' will be used.</li>
	<li>StringResource – the ID for the alert string resource</li>
</ul>
As you can see, since the write action member module for the rules created by this runbook would be "System.Health.GenerateAlert", and we are defining &lt;AlertMessageId&gt; and &lt;AlertParameters&gt; in the write action member module configuration:

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/image38.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/10/image_thumb32.png" alt="image" width="559" height="161" border="0" /></a>

The String Resource must match the AlertMessageId:

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/image39.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/10/image_thumb33.png" alt="image" width="462" height="208" border="0" /></a>

And if you have previously authored OpsMgr management packs, you’d probably already know how to define the &lt;AlertParameters&gt; section for the alert description. Basically, any variables you are using in the alert description must be defined in the &lt;AlertParameters&gt; section, then in the alert description, you’d reference them using "{}" and a number inside. &lt;AlertParameter1&gt; becomes {0}, &lt;AlertParameter2&gt; becomes {1}, and so on. You can up to define 10 alert parameters:

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/image40.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/10/image_thumb34.png" alt="image" width="527" height="187" border="0" /></a>

Since you can define multiple alert messages (for multiple language packs), when you are creating alert generating rules, the <strong>New-OMRule</strong> function would expect you to pass in an array that contains OpsMgrExtended.AlertConfiguration objects. So, even if you are only defining the alert in one language pack, please still place it into an array before passing to the New-OMRule function:

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/image41.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/10/image_thumb35.png" alt="image" width="526" height="52" border="0" /></a>

OK, now, let’s give this runbook a test run with the following parameters:
<ul>
	<li>RuleName: "Test.Disk.Controller.Event.Alert.Rule"</li>
	<li>RuleDisplayName: "Disk Controller Error Event Alert Rule"</li>
	<li>ClassName: "Microsoft.Windows.OperatingSystem"</li>
	<li>EventLog: "System"</li>
	<li>EventID: 11</li>
	<li>EventSource: "Disk"</li>
	<li>EventLevel: Error</li>
	<li>AlertName: "Windows Disk Controller Error"</li>
	<li>AlertSeverity: Critical</li>
	<li>AlertPriority: High</li>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2015/10/SNAGHTML1055790.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML1055790" src="http://blog.tyang.org/wp-content/uploads/2015/10/SNAGHTML1055790_thumb.png" alt="SNAGHTML1055790" width="516" height="575" border="0" /></a>

After the hybrid worker in my lab executed the runbook, I am able to see the rule created in OpsMgr console:

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/image42.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/10/image_thumb36.png" alt="image" width="314" height="329" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/image43.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/10/image_thumb37.png" alt="image" width="587" height="354" border="0" /></a>

and the raw XML (once I’ve exported the MP):

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/image44.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/10/image_thumb38.png" alt="image" width="697" height="587" border="0" /></a>
<h3>Hybrid Worker Configuration</h3>
Since the samples in this post are all based on Azure Automation and Hybrid worker, I just want to point out this article if you need help setting it up: <a title="https://azure.microsoft.com/en-us/documentation/articles/automation-hybrid-runbook-worker/" href="https://azure.microsoft.com/en-us/documentation/articles/automation-hybrid-runbook-worker/">https://azure.microsoft.com/en-us/documentation/articles/automation-hybrid-runbook-worker/</a>

Also as I mentioned earlier, you will need to deploy OpsMgrExtended module manually on to the hybrid workers by yourself. When copying the OpsMgrExtended module to your hybrid workers, make sure you copy to a folder that’s listed in the PSModulePath environment variable. During my testing with a PowerShell runbook, I initially placed it under "C:\Program Files\WindowsPowerShell\Modules" folder, as it was listed in the PSModulePath environment variable when I checked in a PowerShell console on the hybrid worker. However, I got error messages telling me the runbook could not find commands defined in the OpsMgrExtended module. To troubleshoot, I wrote a simple PowerShell runbook:

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/image45.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/10/image_thumb39.png" alt="image" width="636" height="275" border="0" /></a>

and based on the output, the folder in "C:\Program Files" is not listed!

<a href="http://blog.tyang.org/wp-content/uploads/2015/10/image46.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/10/image_thumb40.png" alt="image" width="700" height="147" border="0" /></a>

Therefore, I had to move the module to another location (C:\Windows\System32\WindowsPowerShell\v1.0\Modules). after the move, the runbook started working.
<h3>Summary</h3>
In this post, I have demonstrated how to use the New-OMRule function from OpsMgrExtended PS module to create any types of rules in OpsMgr. Although OpsMgrExtended module has already shipped two other functions to create event collection and performance collection rules, the New-OMRule fills the gap that allows users to specify each individual member module and its configurations. This is probably the most technically in-depth post in the Automating OpsMgr series. I have tried my best to explain and demonstrate how to use the New-OMRule function. But if you are still unclear, have questions or issues, please feel free to contact me.

I haven’t figured out what I will cover in the next post, but I still have a lot to cover in this series. Since I am attending few conferences in the coming weeks in November, I probably won’t have time to work on part 20 until end of November. Until next time, happy automating!