---
id: 4062
title: 'Automating OpsMgr Part 2: SMA Runbook for Creating ConfigMgr Log Collection Rules'
date: 2015-06-28T19:03:02+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=4062
permalink: /2015/06/28/automating-opsmgr-part-2-sma-runbook-for-creating-configmgr-log-collection-rules/
categories:
  - OMS
  - PowerShell
  - SCOM
  - SMA
tags:
  - Automating OpsMgr
  - OMS
  - OpsMgrExtended
  - PowerShell
  - SCOM
  - SMA
---
<h3><a href="http://blog.tyang.org/wp-content/uploads/2015/06/OpsMgrExnteded.png"><img class="alignleft size-thumbnail wp-image-4038" src="http://blog.tyang.org/wp-content/uploads/2015/06/OpsMgrExnteded-150x150.png" alt="OpsMgrExnteded" width="150" height="150" /></a>Introduction</h3>
This is the 2nd instalment of the Automating OpsMgr series. Previously on this series:
<ul>
	<li><a href="http://blog.tyang.org/2015/06/24/automating-opsmgr-part-1-introducing-opsmgrextended-powershell-sma-module/" target="_blank">Automating OpsMgr Part 1: Introducing OpsMgrExtended PowerShell / SMA Module</a></li>
</ul>
Few weeks ago, I have also published a post: <a href="http://blog.tyang.org/2015/06/10/collecting-configmgr-logs-to-microsoft-operation-management-suite-the-nice-way/" target="_blank">Collecting ConfigMgr Logs To Microsoft Operation Management Suite – The NiCE Way</a>, which demonstrated how to use an OpInsights integrated OpsMgr management group and NiCE Log File MP to collect ConfigMgr client and server logs into <a href="http://www.microsoft.com/oms" target="_blank">Microsoft Operation Management Suite</a>.

The solution I provided in that post included few sealed management packs and a demo management pack which includes few actual event collection rules for ConfigMgr log files. However, it requires some manual XML editing outside of whatever MP authoring tool that you might be using, which could be a bit complicated for IT Pros and non management pack developers. The manual XML editing is necessary because the log collection rules use a Write Action module called "<strong>Microsoft.SystemCenter.CollectCloudGenericEvent</strong>" to send the event data to the OpInsights workspace. This write action module is located in the "<strong>Microsoft.IntelligencePacks.Types</strong>" sealed management pack. This management pack is automatically pushed to your OpsMgr management group once you’ve configured the OpInsights connection.

When using management pack authoring tools such as VSAE, if you need to reference a sealed management pack (or management pack bundle), you must have the sealed MP or MP bundle files (.mp or .mpb) handy and add these files as references in your MP project. But since the sealed MP "Microsoft.IntelligencePacks.Types" is automatically pushed to your management group as part of the OpInsights integration, and Microsoft does not provide a downloadable .mp file for this MP (yes,I have asked the OpInsights product group). There was no alternatives but manually editing the XML outside of the authoring tool in order to create these rules.

Our goal is to create potentially a large number of event collection rules for all the ConfigMgr event logs that ConfigMgr administrators are interested in. In my opinion, this is a perfect automation candidate because you will need to create multiple near-identical rules, and it is very time consuming if you use MP authoring tools and text editors to create these rules (as I explained above).
<h3>Pre-requisites</h3>
I am going to demonstrate how to create these event collection rules using a SMA runbook which uses The <strong><a href="http://www.tyconsulting.com.au/portfolio/opsmgrextended-powershell-and-sma-module/" target="_blank">OpsMgrExtended PowerShell module</a></strong>. In order to implement this solution, you will need the following:
<ul>
	<li>An OpsMgr 2012 SP1 or R2 management group that has been connected to Azure Operational Insights (OMS)</li>
	<li>A SMA infrastructure in your environment</li>
	<li><a href="http://www.microsoft.com/en-us/download/details.aspx?id=34709" target="_blank">Microsoft ConfigMgr 2012 management pack version 5.0.7804.1000</a> imported and configured in your OpsMgr management group</li>
	<li>The ConfigMgr components of which you need to collect the logs from must be monitored by the OpsMgr (including ConfigMgr servers and clients). These computers must be agent monitored. Agentless monitoring is not going to work in this scenario.</li>
	<li><a href="http://www.nice.de/log-file-monitoring-scom-nice-logfile-mp" target="_blank">NiCE Log File MP</a> imported in your OpsMgr management group</li>
	<li>OpsMgrExtended module imported into SMA and an "Operations Manager SDK" SMA connection object is created for your OpsMgr management group – Please refer to Part 1 of this series for details</li>
	<li>The "ConfigMgr Logs Collection Library Management Pack" must also be imported into your OpsMgr management group – Download link provided in my <a href="http://blog.tyang.org/2015/06/10/collecting-configmgr-logs-to-microsoft-operation-management-suite-the-nice-way/" target="_blank">previous post</a>.</li>
</ul>
&nbsp;
<h3>Runbook: New-ConfigMgrLogCollectionRule</h3>
<pre language="PowerShell">
workflow New-ConfigMgrLogCollectionRule
{
    Param(
        [Parameter(Mandatory=$true)][String]$RuleName,
        [Parameter(Mandatory=$true)][String]$RuleDisplayName,
        [Parameter(Mandatory=$true)][String]$ManagementPackName,
        [Parameter(Mandatory=$true)][ValidateSet("Microsoft.SystemCenter2012.ConfigurationManager.DistributionPoint","Microsoft.SystemCenter2012.ConfigurationManager.ManagementPoint","Microsoft.SystemCenter2012.ConfigurationManager.SiteServer","Microsoft.SystemCenter2012.ConfigurationManager.Client")][String]$ClassName,
        [Parameter(Mandatory=$true)][String]$LogDirectory,
        [Parameter(Mandatory=$true)][String]$LogFileName,
        [Parameter(Mandatory=$true)][String]$EventID,
        [Parameter(Mandatory=$true)][ValidateSet('Success', 'Error', 'Warning', 'Information', 'Audit Failure', 'Audit Success')][String]$EventLevel,
        [Parameter(Mandatory=$false)][Int]$IntervalSeconds=120
    )

    #Get OpsMgrSDK connection object
    $OpsMgrSDKConn = Get-AutomationConnection -Name "OpsMgrSDK_TYANG"

    #Get the destination MP
    Write-Verbose "Getting managemnet pack '$ManagementPackName'..."
    $MP = Get-OMManagementPack -SDKConnection $OpsMgrSDKConn -Name $ManagementPackName

    If ($MP)
    {
    #MP found, now check if it is sealed
        If ($MP.sealed)
        {
            Write-Error 'Unable to save to the management pack specified. It is sealed. Please specify an unsealed MP.'
            return $false
        }
    } else {
        Write-Error 'The management pack specified cannot be found. please make sure the correct name is specified.'
        return $false
    }

    #Make Sure the MP is referencing to 'Microsoft.Windows.Library' MP
    $WinLibRef = inlinescript {
        #Get the destination MP
	    Write-Verbose "Getting managemnet pack '$USING:ManagementPackName'..."
        $MP = Get-OMManagementPack -SDKConnection $USING:OpsMgrSDKConn -Name $USING:ManagementPackName

        If ($MP)
        {
            #MP found, now check if it is sealed
            If ($MP.sealed)
            {
                Write-Error 'Unable to save to the management pack specified. It is sealed. Please specify an unsealed MP.'
                return $false
            }
        } else {
            Write-Error 'The management pack specified cannot be found. please make sure the correct name is specified.'
            return $false
        }

	    #Make sure the destination MP is referencing the Microsoft.Windows.Library MP
	    $MPReferences = $MP.References
	    Foreach ($item in $MPReferences)
	    {
		    Write-Verbose "$($item.value.name)"
            If ($($item.value.Name) -eq "Microsoft.Windows.Library")
		    {
			    $WinLibRef = $item.key
                Write-Verbose "The MP ref key for 'Microsoft.Windows.Library' is $WinLibRef"
		    }
	    }
	    If ($WinLibRef -eq $NULL)
	    {
		    Write-Verbose "The MP ref for 'Microsoft.Windows.Library' is not found."
            #Create the reference
		    $NewMPRef = New-OMManagementPackReference -SDKConnection $USING:OpsMgrSDKConn -ReferenceMPName "Microsoft.Windows.Library" -Alias "Windows" -UnsealedMPName $USING:ManagementPackName
		    If ($NewMPRef -eq $true)
		    {
			    $WinLibRef = "Windows"
		    } else {
			    Write-Error "Unable to create a reference for 'Microsoft.Windows.Library' MP in the destination management pack '$ManagementPackName'. Unable to continue."
			    Return $false
		    }
	    }
        $WinLibRef
    }
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

    #Data Source Module Configuration:
    [OpsMgrExtended.ModuleConfiguration[]]$arrDataSourceModules = @()
    #Determine which Data Source module to use (client vs server)
    If ($ClassName -ieq 'Microsoft.SystemCenter2012.ConfigurationManager.Client')
    {
        $DAModuleTypeName = "ConfigMgr.Log.Collection.Library.ConfigMgr.Client.Log.DS"
    } else {
        $DAModuleTypeName = "ConfigMgr.Log.Collection.Library.ConfigMgr.Server.Log.DS"
    }

    Write-Verbose "WMI Query: `"$WMIQuery`""
    $DAConfiguration = @"
<IntervalSeconds>$IntervalSeconds</IntervalSeconds>
<ComputerName>`$Target/Host/Property[Type="$WinLibRef!Microsoft.Windows.Computer"]/NetworkName$</ComputerName>
<EventID>$EventID</EventID>
<EventCategory>0</EventCategory>
<EventLevel>$iEventLevel</EventLevel>
<LogDirectory>$LogDirectory</LogDirectory>
<FileName>$LogFileName</FileName>
"@
    $DAMemberModuleName = "DS"
    $DataSourceConfiguration = New-OMModuleConfiguration -ModuleTypeName $DAModuleTypeName -Configuration $DAConfiguration -MemberModuleName $DAMemberModuleName
    $arrDataSourceModules += $DataSourceConfiguration

    #Write Action modules
    [OpsMgrExtended.ModuleConfiguration[]]$arrWriteActionModules = @()
    $WAWriteToDBConfiguration = New-OMModuleConfiguration -ModuleTypeName "Microsoft.SystemCenter.CollectEvent" -MemberModuleName "WriteToDB"
    $WAWriteToDWConfiguration = New-OMModuleConfiguration -ModuleTypeName "Microsoft.SystemCenter.DataWarehouse.PublishEventData" -MemberModuleName "WriteToDW"
    $WAWriteToOMSConfiguration = New-OMModuleConfiguration -ModuleTypeName "Microsoft.SystemCenter.CollectCloudGenericEvent" -MemberModuleName "WriteToOMS"
    $arrWriteActionModules += $WAWriteToDBConfiguration
    $arrWriteActionModules += $WAWriteToDWConfiguration
    $arrWriteActionModules += $WAWriteToOMSConfiguration

    #Create WMI Event Collection Rule, MP Version will be increased by 0.0.0.1
    $RuleCreated = InlineScript
    {
        #Validate rule Name
        If ($USING:RuleName -notmatch "([a-zA-Z0-9]+\.)+[a-zA-Z0-9]+")
        {
            #Invalid rule name entered
            $ErrMsg = "Invalid rule name specified. Please make sure it only contains alphanumeric charaters and only use '.' to separate words. i.e. 'Your.Company.Application.Log.EventID.1234.Collection.Rule'."
            Write-Error $ErrMsg
        } else {
            #Name is valid, creating the rule
            New-OMRule -SDKConnection $USING:OpsMgrSDKConn -MPName $USING:ManagementPackName -RuleName $USING:RuleName -RuleDisplayName $USING:RuleDisplayName -Category "EventCollection" -ClassName $USING:ClassName -DataSourceModules $USING:arrDataSourceModules -WriteActionModules $USING:arrWriteActionModules -Remotable $false
        }
    }

    If ($RuleCreated)
    {
        Write-Output "Rule `"$RuleName`" created."
    } else {
        Write-Error "Unable to create Rule `"$RuleName`"."
    }
}
</pre>
When executing this runbook, the user must specify the following parameters:
<ul>
	<li><strong>RuleName:</strong> the internal name of the OpsMgr rule</li>
	<li><strong>RuleDisplayName:</strong> the display name of the OpsMgr rule</li>
	<li><strong>ManagementPackName:</strong> The internal name of the management pack (must be an existing MP in your OpsMgr management group)</li>
	<li><strong>ClassName: </strong>The target class of the rule. It must be one of the following values:
<ul>
	<li>"Microsoft.SystemCenter2012.ConfigurationManager.DistributionPoint"</li>
	<li>"Microsoft.SystemCenter2012.ConfigurationManager.ManagementPoint"</li>
	<li>"Microsoft.SystemCenter2012.ConfigurationManager.SiteServer"</li>
	<li>"Microsoft.SystemCenter2012.ConfigurationManager.Client"</li>
</ul>
</li>
	<li><strong>LogDirectory:</strong> The directory where the log is located (i.e. "C:\Windows\CCM\Logs")</li>
	<li><strong>LogFileName:</strong> The name of the log file (i.e. "UpdatesStore.Log")</li>
	<li><strong>EventID:</strong> The Event ID that you wish to use when converting log file entries to Windows events</li>
	<li><strong>EventLevel:</strong> Windows event level. Must be one of the following values:
<ul>
	<li>‘Success'</li>
	<li>'Error'</li>
	<li>'Warning'</li>
	<li>'Information'</li>
	<li>'Audit Failure'</li>
	<li>'Audit Success'</li>
</ul>
</li>
	<li><strong>IntervalSeconds:</strong> How often does the rule run</li>
</ul>
On line 16 of the runbook, I’ve coded the runbook to retrieve a SMA connection object called "OpsMgrSDK_TYANG":

<a href="http://blog.tyang.org/wp-content/uploads/2015/06/image17.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/06/image_thumb17.png" alt="image" width="585" height="57" border="0" /></a>

This is because my SMA connection object for my OpsMgr management group is named "OpsMgrSDK_TYANG". You will need to change this line according to how you’ve created your SMA connection:

<a href="http://blog.tyang.org/wp-content/uploads/2015/06/SNAGHTML10a57cfa.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML10a57cfa" src="http://blog.tyang.org/wp-content/uploads/2015/06/SNAGHTML10a57cfa_thumb.png" alt="SNAGHTML10a57cfa" width="333" height="487" border="0" /></a>

&nbsp;

You can also further simplify the runbook in the following possible areas:
<ul>
	<li>Hardcoding the destination management pack in the runbook</li>
	<li>Hardcoding the interval seconds (i.e. to 120 seconds)</li>
	<li>Create a switch statement for the target class, so instead entering "Microsoft.SystemCenter2012.ConfigurationManager.Client", users can simply enter "Client" for example.</li>
	<li>Create a switch statement for the LogDirectory parameter. for example, when the target class of "Client" is specified, set LogDirectory variable to "C:\Windows\CCM\Logs".</li>
	<li>Automatically populate Rule name and display name based on the target class and the log file name.</li>
	<li>Build a user’s request portal using System Center Service Manager or SharePoint List (This would be a separate topic for another day, but Please refer to my <a href="http://blog.tyang.org/2015/02/01/session-recording-presentation-microsoft-mvp-community-camp-melbourne-event/" target="_blank">previous MVP Community Camp presentation recording</a> for some samples I’ve created in the past using SharePoint Lists).</li>
</ul>
Lastly, needless to say, you can also execute this PowerShell workflow in a standalone PowerShell environment (or convert this PowerShell workflow into a regular PowerShell script). When running it outside of SMA, you will need to use another Parameter Set for the "New-OMManagementPackReference" and "New-OMRule" activities. So instead of using –SDKConnection Parameter, you will have to use –SDK (and optionally –Username and –Password) to connect to your OpsMgr management group. To Change it, please modify the following lines:

Change Line 16 to $SDK = "&lt;Your OpsMgr management server&gt;"

Change Line 47 to:

<a href="http://blog.tyang.org/wp-content/uploads/2015/06/image18.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/06/image_thumb18.png" alt="image" width="511" height="38" border="0" /></a>

$NewMPRef = New-OMManagementPackReference <span style="color: #ff0000;">-SDK $SDK</span> -ReferenceMPName "Microsoft.Windows.Library" -Alias "Windows" -UnsealedMPName $ManagementPackName

Change Line 117 to:

<a href="http://blog.tyang.org/wp-content/uploads/2015/06/image19.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/06/image_thumb19.png" alt="image" width="566" height="51" border="0" /></a>

New-OMRule <span style="color: #ff0000;">-SDK $USING:SDK</span> -MPName $USING:ManagementPackName -RuleName $USING:RuleName -RuleDisplayName $USING:RuleDisplayName -Category "EventCollection" -ClassName $USING:ClassName -DataSourceModules $USING:arrDataSourceModules -WriteActionModules $USING:arrWriteActionModules -Remotable $false

<strong>Result:</strong>

After I filled out all the parameters:

<a href="http://blog.tyang.org/wp-content/uploads/2015/06/image20.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/06/image_thumb20.png" alt="image" width="512" height="442" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2015/06/image21.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/06/image_thumb21.png" alt="image" width="512" height="443" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2015/06/image22.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/06/image_thumb22.png" alt="image" width="513" height="443" border="0" /></a>

And executed the runbook:

<a href="http://blog.tyang.org/wp-content/uploads/2015/06/image23.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/06/image_thumb23.png" alt="image" width="615" height="567" border="0" /></a>

The rule was successfully created:

<a href="http://blog.tyang.org/wp-content/uploads/2015/06/image24.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/06/image_thumb24.png" alt="image" width="641" height="389" border="0" /></a>

And shortly after it, you should start seeing the log entries in your OMS workspace:

<a href="http://blog.tyang.org/wp-content/uploads/2015/06/image25.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/06/image_thumb25.png" alt="image" width="789" height="431" border="0" /></a>

&nbsp;
<h3>Conclusion</h3>
I have demonstrated how to use the <strong>OpsMgrExtended</strong> module in a SMA runbook to enable users creating large number of similar OpsMgr management pack workflows.

Given this is only part 2 of the series, and the first example I have released, maybe I should have started with something easier. The reason I've chosen this example as Part 2 is because I am going to present in the next <a href="http://mscsig.azurewebsites.net/" target="_blank">Melbourne System Center, Security, & Infrastructure user group</a> meeting next Tuesday 7th July among with 3 other MVPs (David O'Brien, James Bannan and Orin Thomas). I am going to demonstrate this very same scenario - using OpInsights to collect SCCM log files. So I thought I'll make this the 2nd instalment of the series, so people who attended the user group meeting have something to refer to. In this sample runbook, I've used a relatively more complicated activity called <strong>New-OMRule</strong> to create these event collection rules. This activity is designed as a generic method to create any types of OpsMgr rules. I will dedicate another blog post just for this one in the future.

Lastly, if you are based in Melbourne and would like to see this in action, please come to the user group meeting in the evening of 7th July. It is going to be held at Microsoft Melbourne office in South Bank. the registration details is available on the website: <a title="http://mscsig.azurewebsites.net/" href="http://mscsig.azurewebsites.net/">http://mscsig.azurewebsites.net/</a>.