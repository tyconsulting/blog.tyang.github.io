---
id: 3384
title: My Experience Manipulating MDT Database Using SMA, SCORCH and SharePoint
date: 2014-11-20T20:30:55+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=3384
permalink: /2014/11/20/experience-manipulating-mdt-database-using-sma-scorch-sharepoint/
categories:
  - SC Orchestrator
  - SMA
tags:
  - SCORCH
  - SharePoint
  - SMA
---
<h3>Background</h3>
At work, there is an implementation team who’s responsible for building Windows 8 tablets in a centralised location (we call it integration centre) then ship these tablets to remote locations around the country. We use SCCM 2012 R2 and MDT 2013 to build these devices using a MDT enabled task sequence in SCCM. The task sequence use MDT locations to apply site specific settings (I’m not a OSD expert, I’m not even going to try to explain exactly what these locations entries do in the task sequence).

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/SNAGHTML4d5244b.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML4d5244b" src="http://blog.tyang.org/wp-content/uploads/2014/11/SNAGHTML4d5244b_thumb.png" alt="SNAGHTML4d5244b" width="332" height="287" border="0" /></a>

In order to build these tablets for any remote sites, before kicking off the OSD build, the integration centre’s default gateway IP address must be added to the location entry for this specific site, and removed from any other locations.

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/SNAGHTML4dbe1c0.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML4dbe1c0" src="http://blog.tyang.org/wp-content/uploads/2014/11/SNAGHTML4dbe1c0_thumb.png" alt="SNAGHTML4dbe1c0" width="342" height="224" border="0" /></a>

Because our SCCM people didn’t want to give the implementation team access to MDT Deployment Workbench, my team has been manually updating the MDT locations whenever the implementation team wants to build tablets.

I wasn’t aware of this arrangement until someone in my team went on leave and asked me to take care of this when he’s not around. Soon I got really annoyed because I had to do this few times a day! Therefore I decided to automate this process using SMA, SCORCH and SharePoint so they can update the location themselves without giving them access to MDT.

The high level workflow is shown in the diagram below:

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/MDT-Automation.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="MDT Automation" src="http://blog.tyang.org/wp-content/uploads/2014/11/MDT-Automation_thumb.png" alt="MDT Automation" width="705" height="325" border="0" /></a>
<h3>Design</h3>
<strong>01. SharePoint List</strong>

Firstly, I created a list on one of our SharePoint sites, and this list only contains one item:

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/SNAGHTML52b1a8c.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML52b1a8c" src="http://blog.tyang.org/wp-content/uploads/2014/11/SNAGHTML52b1a8c_thumb.png" alt="SNAGHTML52b1a8c" width="456" height="239" border="0" /></a>

<strong>02. Orchestrator Runbook</strong>

I firstly deployed the SharePoint integration pack to the Orchestrator management servers and all the runbook servers. Then I setup a connection to the SharePoint site using a service account

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/SNAGHTML532bed6.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML532bed6" src="http://blog.tyang.org/wp-content/uploads/2014/11/SNAGHTML532bed6_thumb.png" alt="SNAGHTML532bed6" width="389" height="274" border="0" /></a>

The runbook only has 2 activities:

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/image17.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/11/image_thumb17.png" alt="image" width="406" height="183" border="0" /></a>

Monitor List Items:

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/SNAGHTML53742a6.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML53742a6" src="http://blog.tyang.org/wp-content/uploads/2014/11/SNAGHTML53742a6_thumb.png" alt="SNAGHTML53742a6" width="398" height="208" border="0" /></a>

Link:

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/SNAGHTML536dbb9.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML536dbb9" src="http://blog.tyang.org/wp-content/uploads/2014/11/SNAGHTML536dbb9_thumb.png" alt="SNAGHTML536dbb9" width="403" height="232" border="0" /></a>

The link filters the list ID. ID must equal to 1 (first item in the list). This is to prevent users adding additional item to the list. They must always edit the first (and only) item on the list.

Start SMA Runbook called “Update-MDTLocation”:

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/image18.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/11/image_thumb18.png" alt="image" width="448" height="307" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/image19.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/11/image_thumb19.png" alt="image" width="549" height="286" border="0" /></a>

This activity runs a simple PowerShell script to start the SMA runbook. The SMA connection details (user name, password, SMA web service server and web service endpoint) are all saved in Orchestrator as variables.

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/SNAGHTML53aaec0.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML53aaec0" src="http://blog.tyang.org/wp-content/uploads/2014/11/SNAGHTML53aaec0_thumb.png" alt="SNAGHTML53aaec0" width="440" height="108" border="0" /></a>

<strong>03. SMA Runbook</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/SNAGHTML5413f3c.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML5413f3c" src="http://blog.tyang.org/wp-content/uploads/2014/11/SNAGHTML5413f3c_thumb.png" alt="SNAGHTML5413f3c" width="546" height="417" border="0" /></a>

Firstly, I created few variables, credentials and connections to be used in the runbook:

Connections:
<ul>
	<li>SMTP connection from the <a href="http://blog.tyang.org/2014/10/31/simplified-way-send-emails-mobile-push-notifications-sma/">SendEmail module I posted earlier</a>.</li>
	<li>Email recipient connection from <a href="http://blog.tyang.org/2014/10/31/simplified-way-send-emails-mobile-push-notifications-sma/">SendPushNotification module I posted earlier</a>.</li>
</ul>
Credential:
<ul>
	<li>Windows Credential that has access to the MDT database (we have MDT DB located on the SCCM SQL server, so it only accepts Windows authentication). I named the credential “ProdMDTDB”</li>
</ul>
Variables:
<ul>
	<li>MDT Database SQL Server address. I named it “CM12SQLServer”</li>
	<li>Gateway IP address. I named it “GatewayIP”</li>
</ul>
&nbsp;

Here’s the code for the SMA runbook:
<pre language="PowerShell" class="">Workflow Update-MDTLocation
{
PARAM (
[Parameter(Mandatory=$true,HelpMessage='Please enter the new location')][Alias('l')][String]$Location
)
$SQLServer = Get-AutomationVariable -Name 'CM12SQLServer'
$SQLInstance = 'MSSQLSERVER'
$DBName = 'MDT'
$CredName = 'ProdMDTDB'
Write-Verbose "SQL Server: $SQLServer"
Write-Verbose "SQL Instalce: $SQLInstance"
Write-Verbose "Database: $DBName"
Write-Verbose "Retrieving saved SMA credential $CredName"
$SQLCred = Get-AutomationPSCredential -Name $CredName
$SQLUserName = $SQLCred.UserName
Write-Verbose "Connecting to $SQLServer using account $SQLUserName"
$ConnString = "Server=$SQLServer\$SQLInstannce;Database=$DBName;Integrated Security=SSPI"
$GatewayIP = Get-AutomationVariable -Name 'GatewayIP'
$strQuery = @"
USE $DBName
Declare @Gateway Varchar(max)
Declare @NewLocation Varchar(max)
Declare @NewLocationID int
Set @Gateway = `'$GatewayIP`'
Set @NewLocation = `'$Location`'
Set @NewLocationID = (Select L.ID From LocationIdentity L Where L.Location = @NewLocation)
Update LocationIdentity_DefaultGateway Set ID = @NewLocationID Where DefaultGateway = @Gateway
"@
Write-Verbose "Executing SQL query: $strQuery"
$Result = InlineScript
{
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $USING:ConnString
$connection.Open()
$command = $connection.CreateCommand()
$command.CommandText = $USING:strQuery
$result = $command.ExecuteNonQuery()
$result
} -PSComputerName $SQLServer -PSCredential $SQLCred
Write-Output "$result row(s) updated."
if ($result -gt 0)
{
$EmailMessage = "MDT location updated for $result site(s). New Location specified: $Location."
} else {
$EmailMessage = "MDT location did not get updated. Please contact STS to investigate further."
}

#Email result
$SMTPSettings = Get-AutomationConnection -Name '[SMTP connection name]'
$Recipient = Get-AutomationConnection -Name '[email recipient’s connection name]'
Write-Verbose "Emailing result to $Recipient.Email"
Send-Email -SMTPSettings $SMTPSettings -To $Recipient.Email -Subject 'MDT Location Gateway address update result' -Body $EmailMessage -HTMLBody $False
}
</pre>
<h3>Putting Everything Together</h3>
As demonstrated in the diagram in the beginning of this post, here’s how the whole workflow works:
<ol>
	<li>User login to the SharePoint site and update the only item in the list. He / She enters  the new location in the “New Gateway IP Location” field.</li>
	<li>The Orchestrator runbook checks updated items in this SharePoint list every 15 seconds.</li>
	<li>if the Orchestrator runbook detects the first (and only) item has been updated, it takes the new location value, start the SMA runbook and pass the new value to the SMA runbook.</li>
	<li>SMA runbook runs a PowerShell script to update the gateway location directly from the MDT database.</li>
	<li>SMA runbook sends email to a nominated email address when the MDT database is updated.</li>
</ol>
The email looks like this:

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/SNAGHTML197a0f95.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML197a0f95" src="http://blog.tyang.org/wp-content/uploads/2014/11/SNAGHTML197a0f95_thumb.png" alt="SNAGHTML197a0f95" width="505" height="179" border="0" /></a>

The Orchestrator runbook and the SMA runbook execution history can also be viewed in Orchestrator and WAP admin portal:

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/image20.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/11/image_thumb20.png" alt="image" width="525" height="466" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/image21.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/11/image_thumb21.png" alt="image" width="520" height="344" border="0" /></a>
<h3>Room for Improvement</h3>
I created this automation process in a quick and easy way to get them off my back. I know in this process, there are a lot of areas can be improved. i.e.
<ul>
	<li>Using a SMA runbook to monitor SharePoint list direct so Orchestrator is no longer required (i.e. using the script from <a href="http://blogs.technet.com/b/systemcenter/archive/2014/01/14/service-management-automation-and-sharepoint-mvp.aspx">this article</a>. – Credit to Christian Booth and Ryan Andorfer).</li>
	<li>User input validation</li>
	<li>Look up AD to retrieve user’s email address instead of hardcoding it in a variable.</li>
</ul>
Maybe in the future when I have spare time, I’ll go back and make it better , but for now, the implementers are happy, my team mates are happier because it is one less thing off our plate <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" src="http://blog.tyang.org/wp-content/uploads/2014/11/wlEmoticon-smile.png" alt="Smile" />.
<h3>Conclusion</h3>
I hope you find my experience in this piece of work useful. I am still very new in SMA (and I know nothing about MDT). So, if you have any suggestions or critics, please feel free to drop me an email.