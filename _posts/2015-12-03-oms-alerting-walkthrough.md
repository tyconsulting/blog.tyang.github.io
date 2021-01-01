---
id: 4934
title: OMS Alerting Walkthrough
date: 2015-12-03T22:52:16+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=4934
permalink: /2015/12/03/oms-alerting-walkthrough/
categories:
  - Azure
  - OMS
tags:
  - Azure Automation
  - OMS
---
<h3><a href="http://blog.tyang.org/wp-content/uploads/2015/12/image.png"><img style="background-image: none; float: left; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/12/image_thumb.png" alt="image" width="172" height="172" align="left" border="0" /></a>Introduction</h3>
Earlier today, the OMS product team has <a href="http://blogs.technet.com/b/momteam/archive/2015/12/02/announcing-the-oms-alerting-public-preview.aspx">announced the OMS Alerting feature has entered Public Preview</a>. This is indeed an exciting news and it is another good example that Microsoft is working very hard to close the gaps between OMS and the existing On-Prem monitoring solution - System Center Operations Manager. Alex Frankel from the OMS product team has already given a brief introduction on this feature from the announcement blog post. In this post, I will demonstrate how I used this feature to alert and auto-remediate an issue detected in my lab environment.
<h3>Background</h3>
Few months ago, I have lost my lab OpsMgr management group completely due to hardware failures. After I replaced faulty hardware and built a brand new management group, I re-configured all the servers in my lab reported to the new management group. However, I then started getting many “Failed to enable Advisor Connector on the computer” alerts in my OpsMgr environment:

<a href="http://blog.tyang.org/wp-content/uploads/2015/12/image1.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/12/image_thumb1.png" alt="image" width="637" height="371" border="0" /></a>

These alerts were raised because I did not unregister these agent computers from the previous management group (I couldn’t because it was dead), as explained in <a href="https://social.msdn.microsoft.com/Forums/azure/en-US/8e0ffa61-68a0-4669-a729-ae4cd67cffbc/advisor-connector-enable-status-monitor-failed-to-enable-advisor-connector?forum=opinsights">this</a> forum thread. To fix this issue, on each OpsMgr agent, I must delete several registry keys, reset a regkey  values and then restart the health service.

Since My OpsMgr management group is connected to an OMS workspace, and I have enabled Alert Management solution (so all OpsMgr alerts are also uploaded into OMS), I have configured using the new OMS alerting feature to automatically remediate this error for me.

In order to configure the alerting and remediation for this OpsMgr alert, I need to following components:
<ul>
	<li>OpsMgr management group connected to OMS</li>
	<li>OMS Alert Management solution enabled</li>
	<li>OMS Automation solution (Azure Automation) enabled</li>
	<li>At least one Azure Automation Hybrid Worker is configured (because I need to target the remediation runbook to on-premises lab servers.</li>
	<li>OMS Alerting and Alert remediation feature enabled</li>
</ul>
<h3>Creating Azure Automation Runbook</h3>
So first things first, I must create and publish the remediation runbook in the Azure Automation account before we can select it when we create the OMS alert. Although we cannot configure what parameters to pass into the runbook, the OMS alert passes the search result and some meta data into the runbook in JSON format (I will show it later). So based on my experience, in order to make the runbooks re-useable, we can some optional input parameters for the runbook, and inside the runbook, check if any of these optional parameters are null, then retrieve the value elsewhere (i.e. Azure Automation variable and credential assets).

In this case, I have created a PowerShell based runbook called Remove-SCAdvisorRegistration, the code is listed below:
<pre language="PowerShell">Param(
    [Parameter(Mandatory=$false)][object]$WebHookData,
    [Parameter(Mandatory=$false)][PSCredential]$ServerAdminCred
)

#region funcions
Function Remove-MMAAdvisorRegistration
{
    Param(
        [Parameter(Mandatory=$true)][PSCredential]$Credential,
        [Parameter(Mandatory=$true)][String]$ComputerName
    )
    $hklm = 2147483650
    $RegOMMGPath = "System\CurrentControlSet\Services\HealthService\Parameters\Management Groups"

    #Connect to remote registry via WMI
    $wmi = get-wmiobject -list "StdRegProv" -namespace root\default -computername $ComputerName -credential $Credential
    $MGSubKeys = $wmi.EnumKey($hklm, $RegOMMGPath)
    $arrMGs = @()
    Foreach ($item in $MGSubKeys.sNames)
    {
        If ($item -ne "AdvisorMonitorV2")
        {
            $arrMGs += "System\CurrentControlSet\Services\HealthService\Parameters\Management Groups\$item"
        }
    }
    If ($arrMGs.count -gt 1)
    {
        Write-Error "The computer $ComputerName is multi-homed to more than one SCOM management groups. This configuration is not supported by this runbook, please manaully remove the SC Advisor registration."
        Exit 1
    } elseif ($arrMGs.Count -eq 0)
    {
        Write-Error "The computer $ComputerName is not configured to report to any SCOM management groups."
        Exit 2
    }

    #Get the MG ID
    $MGID = $wmi.GetStringValue($hklm, $arrMGs[0], "ID").sValue

    #Check 'SOFTWARE\Microsoft\System Center Operations Manager\12\Advisor\RegisterToManagementGroup' Value
    $AdvisorRegKey = 'SOFTWARE\Microsoft\System Center Operations Manager\12\Advisor'
    $RegisterToManagementGroup = $wmi.GetStringValue($hklm, $AdvisorRegKey, "RegisterToManagementGroup").sValue

    If ($RegisterToManagementGroup -ine $MGID)
    {
        Write-Verbose "'HKLM\SOFTWARE\Microsoft\System Center Operations Manager\12\Advisor\RegisterToManagementGroup' is not set to the correct MG. Making this value blank."
        $ResetRegisterToMG = $wmi.SetStringValue($hklm, $AdvisorRegKey, "RegisterToManagementGroup", "")
        Write-Verbose "Return Value for Reset 'HKLM\SOFTWARE\Microsoft\System Center Operations Manager\12\Advisor\RegisterToManagementGroup' value: $($ResetRegisterToMG.ReturnValue)"
    
        Write-Verbose "Deleting 'SYSTEM\CurrentControlSet\services\HealthService\Parameters\Management Groups\AdvisorMonitorV2' and subtree"
        #$DeleteAdvisorMonitorV2Node = $wmi.DeleteKey($hklm, 'SYSTEM\CurrentControlSet\services\HealthService\Parameters\Management Groups\AdvisorMonitorV2')
        $DeleteAdvisorMonitorV2Node = (Get-WmiObject -ComputerName $ComputerName -Class win32_process -Credential $Credential -List).Create("$env:SystemRoot\system32\cmd.exe /c `"REG DELETE `"HKLM\SYSTEM\CurrentControlSet\services\HealthService\Parameters\Management Groups\AdvisorMonitorV2`" /f`"")
        Start-Sleep -Seconds 2
        $AdvisorMonitorV2NodeKey = $wmi.EnumKey($hklm, 'SYSTEM\CurrentControlSet\services\HealthService\Parameters\Management Groups\AdvisorMonitorV2')
        #Write-Verbose $AdvisorMonitorV2NodeKey.ReturnValue
        If ($AdvisorMonitorV2NodeKey.ReturnValue -ne 0)
        {
            $bAdvisorMonitorV2Deleted = $true
            Write-Verbose "'SYSTEM\CurrentControlSet\services\HealthService\Parameters\Management Groups\AdvisorMonitorV2' and subtree deleted."
        } else {
            $bAdvisorMonitorV2Deleted = $false
            Write-Error "Failed to delete 'SYSTEM\CurrentControlSet\services\HealthService\Parameters\Management Groups\AdvisorMonitorV2' and subtree."
        }
        
        Write-Verbose "Deleting 'SYSTEM\CurrentControlSet\services\HealthService\Parameters\Registered Connectors\{A052BD1A-7DDC-4BB1-B9F8-CEA9F31F61E7}' and subtree"
        $DeleteRegisteredConnector = $wmi.DeleteKey($hklm, 'SYSTEM\CurrentControlSet\services\HealthService\Parameters\Registered Connectors\{A052BD1A-7DDC-4BB1-B9F8-CEA9F31F61E7}')
        Write-Verbose "Return Value for Deleting 'SYSTEM\CurrentControlSet\services\HealthService\Parameters\Registered Connectors\{A052BD1A-7DDC-4BB1-B9F8-CEA9F31F61E7}' and subtree: $($DeleteRegisteredConnector.ReturnValue)"
    }

    #return boolean value based on the deletion results
    If ($ResetRegisterToMG.ReturnValue -eq 0 -and $bAdvisorMonitorV2Deleted -eq $true -and $DeleteRegisteredConnector.ReturnValue -eq 0)
    {
        Write-Verbose "Restarting Health Service on computer $ComputerName"
        Write-Verbose "Stopping health service..."
        $HealthService = Get-WmiObject -Query "Select * from Win32_Service WHERE Name='HealthService'" -ComputerName $ComputerName -Credential $Credential
        $HealthService.StopService() | Out-Null
        $i = 0
        Do
        {
            Write-Verbose "Sleeping 3 seconds..."
            Start-Sleep -Seconds 3
            $i = $i + 1
            $HealthService = Get-WmiObject -Query "Select * from Win32_Service WHERE Name='HealthService'" -ComputerName $ComputerName -Credential $Credential
        } Until ($HealthService.State -eq "Stopped" -or $i -eq 20)
        If ($HealthService.State -eq "Stopped")
        {
            Write-Verbose "Starting health service..."
            $HealthService = Get-WmiObject -Query "Select * from Win32_Service WHERE Name='HealthService'" -ComputerName $ComputerName -Credential $Credential
            $HealthService.StartService() | out-null
            $true
        } else {
            Write-Error "Unable to stop health service on computer $ComputerName."
            $false
        }
        
    } else {
        $false
    }
}
#endregion

If (!$ServerAdminCred)
{
    $ServerAdminCred = Get-AutomationPSCredential RestartServiceRunbookDefaultCred
}
#Process inputs from webhook data
Write-Verbose "Processing inputs from webhook data."
$WebhookName    =   $WebhookData.WebhookName
Write-Verbose "Webhook name: '$WebhookName'"
$WebhookHeaders =   $WebhookData.RequestHeader
$WebhookBody    =   $WebhookData.RequestBody
Write-Verbose "Webhook body:"
Write-Verbose $WebhookBody
$SearchResults = (ConvertFrom-JSON $WebhookBody).SearchResults
$SearchResultsId = $SearchResults.id
$SearchResultsValue = $SearchResults.value
Foreach ($item in $SearchResultsValue)
{
    $ComputerName = $item.SourceDisplayName
    Write-Verbose "Removing Old SC Advisor configuration from computer '$ComputerName'."
    $Removed = Remove-MMAAdvisorRegistration -Credential $ServerAdminCred -ComputerName $ComputerName
    If ($Removed)
    {
        Write-Output "SC Advisor config removed from computer '$ComputerName'."
    } else {
        Write-Error "Failed to remove SC Advisor config from computer '$ComputerName'."
    }
}
Write-Output "Done."

</pre>
Now, let’s fast forward a little bit and explain what does the input parameter from OMS alert look like. When we have configured Alert remediation during the OMS alert creation, a webhook for the runbook is automatically created. OMS uses this webhook to start the runbook. It passes a parameter called “WEBHOOKDATA”, which is in JSON format into the runook. You can see the actual input by clicking on the INPUT tile in the runbook job execution history:

<a href="http://blog.tyang.org/wp-content/uploads/2015/12/image2.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/12/image_thumb2.png" alt="image" width="674" height="390" border="0" /></a>

If you copy and paste this input into a text editor such as Notepad++ and format it as a JSON document, it looks like this:

<a href="http://blog.tyang.org/wp-content/uploads/2015/12/image3.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/12/image_thumb3.png" alt="image" width="701" height="548" border="0" /></a>

As you can see, the “SearchResults” contains 3 elements:
<ul>
	<li>id</li>
	<li>__metadata</li>
	<li>Value</li>
</ul>
The Value property is where you can retrieve the search result, and it is defined as an array. When I was writing the remediation runbook, I was able to get the offending OpsMgr agent computer name from the “SourceDisplayName” field of each item in the “Value array”.

Now the runbook is created, make sure it is published before we heading back to the OMS portal start creating the alert. Please note that we will have to come back and revisit this runbook after the alert is created.
<h3>Creating OMS Alert</h3>
The search query that I’m using for this alert is:

<strong><em><span style="background-color: #ffff00;">Type=Alert AlertState=New AlertName="Failed to enable Advisor Connector on the computer."</span></em></strong>

<a href="http://blog.tyang.org/wp-content/uploads/2015/12/image4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/12/image_thumb4.png" alt="image" width="690" height="441" border="0" /></a>

I’m creating the alert with the following parameters:
<ul>
	<li><strong>Name:</strong> Alert - Failed to enable Advisor on computer</li>
	<li><strong>Schedule:</strong> every 15 minutes</li>
	<li><strong>Generate Alert when:</strong> Greater than 0</li>
	<li><strong>Over the time window:</strong> 15 minutes</li>
	<li><strong>Send Email Notification:</strong> Yes</li>
	<li><strong>Email Subject:</strong> Failed to enable Advisor on computer alert</li>
	<li><strong>Email Address:</strong> &lt;Your email address&gt;</li>
	<li><strong>Enable Remediation:</strong> Yes</li>
	<li><strong>Remediation Runbook:</strong> Remove-SCAdvisorRegistration</li>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2015/12/SNAGHTML1a29c296.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML1a29c296" src="http://blog.tyang.org/wp-content/uploads/2015/12/SNAGHTML1a29c296_thumb.png" alt="SNAGHTML1a29c296" width="230" height="364" border="0" /></a>

After the alert is saved, you will be able to see it in the Settings/Alerts page:

<a href="http://blog.tyang.org/wp-content/uploads/2015/12/image5.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/12/image_thumb5.png" alt="image" width="518" height="257" border="0" /></a>
<h3>Reconfiguring Runbook Webhook</h3>
In this example, because the runbook must be executed against a Hybrid Worker group (as we are targeting computers in on-prem network), I must reconfigure the webhook (created by OMS alert) to target a Hybrid Worker group (instead of the default config of targeting Azure workers). You can do so by going to the webhook parameters section, and choose Hybrid Worker group from the drop down list:

<a href="http://blog.tyang.org/wp-content/uploads/2015/12/image6.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/12/image_thumb6.png" alt="image" width="618" height="278" border="0" /></a>

<strong><span style="color: #ff0000; font-size: medium;">Note:</span></strong>

Please do not modify any other input parameters for the webhooks created by OMS alerts. If you do, the changes you've made won’t be saved in Azure Automation. Based on my experience, the only change you can modify for the webhook is the “Run on” parameter (Azure VS. Hybrid Worker).

From now on, this alert will be executed every 15 minutes, and search for the result (based on the search query) created within the last 15 minutes. If the number of records returned from the search is greater than 0 (as we configured), you will get an email similar to this one:

<a href="http://blog.tyang.org/wp-content/uploads/2015/12/image7.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/12/image_thumb7.png" alt="image" width="643" height="569" border="0" /></a>

The OMS alert will also kick off the remediation runbook via the webhook. Because I have enabled verbose logging for this runbook, I was able to see some additional verbose messages:

<a href="http://blog.tyang.org/wp-content/uploads/2015/12/image8.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/12/image_thumb8.png" alt="image" width="697" height="423" border="0" /></a>
<h3>Additional Resources</h3>
<h4>Test-OMSAlertRemediation Runbook</h4>
I have also written a test runbook called Test-OMSAlertRemediation that you can use for any OMS alerts. This extracts information from the JSON input and send to you via email. It should be very helpful for you when you are authoring real remediation runbooks (so you know what kind of input data you can play with). I will publish it in the next blog post as it’s getting closer to mid night now.
<h4>New OMS Ebook – Inside the MS Operations Management Suite</h4>
Over the last few months, I have been working with Pete Zerger, Stanislav Zhelyazkov and Anders Bengtsson on a free ebook for OMS. OMS Alerting is also explained in more details in this book. It will be released very soon, so stay tuned!

<a href="http://blog.tyang.org/wp-content/uploads/2015/12/OMS_Book_Anncmt.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="OMS_Book_Anncmt" src="http://blog.tyang.org/wp-content/uploads/2015/12/OMS_Book_Anncmt_thumb.png" alt="OMS_Book_Anncmt" width="676" height="383" border="0" /></a>