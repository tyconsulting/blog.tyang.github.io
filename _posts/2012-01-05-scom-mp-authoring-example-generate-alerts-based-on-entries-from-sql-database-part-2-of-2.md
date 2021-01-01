---
id: 833
title: 'SCOM MP Authoring Example: Generate alerts based on entries from SQL Database (Part 2 of 2)'
date: 2012-01-05T18:41:11+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=833
permalink: /2012/01/05/scom-mp-authoring-example-generate-alerts-based-on-entries-from-sql-database-part-2-of-2/
categories:
  - SCOM
tags:
  - MP Authoring
  - Powershell
  - SCOM
---
This is the 2nd part of the 2-part series.  Part 1 can be found <a title="SCOM MP Authoring Example: Generate alerts based on entries from SQL Database (Part 1 of 2)" href="http://blog.tyang.org/2012/01/04/scom-mp-authoring-example-generate-alerts-based-on-entries-from-sql-database-part-1-of-2/">here</a>.

In Part 2, I’ll cover the steps involved to create each module type and the rule in this article. all these objects will be created in SCOM 2007 R2 Authoring Console. You can create a new management pack for this or use an existing one.

Firstly, we will need create the probe action and data source modules:

<strong><span style="font-size: medium;">Probe Action Module:</span></strong>

1. Under Type Library pane, go to “Probe Actions” under Module Types and click New—&gt;”Composite Probe Action…”

2. Give it a unique identifier such as “Your.Management.pack.Prefix.Database.Catcher.Probe.Action”

3. in general tab, give it a name:

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image1.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb1.png" alt="image" width="466" height="462" border="0" /></a>

4. Under Member Modules, add <strong>“Microsoft.Windows.PowerShellPropertyBagTriggerOnlyProbe</strong>” and give it a Module ID of “PSScript”

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image2.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb2.png" alt="image" width="483" height="481" border="0" /></a>

5. Click on Edit

6. Enter the ScriptName and TImeoutSeconds. Then Edit again in the Configuration tab of the probe action module

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image3.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb3.png" alt="image" width="471" height="475" border="0" /></a>

6. When the text editor is launched, Enter the powershell script in between &lt;ScriptBody&gt; and &lt;/ScriptBody&gt; tags

7. Below is the script I used in my management pack. please edit it to suit your needs:

[sourcecode language="powershell"]
#-----------------------------------
#Alarms capture via AuditDB
#Name:        AuditDBAlarmCatcher.PS1
#Param 0:    SQL Database Instance Name
#Param 2:    Database name
#Param 2:    The inteval in seconds
#Author:    Tao Yang
#Date:        07/12/2011
#-----------------------------------

param([string]$SQLInstance,[String]$Database,[Int]$Interval)
$EVENT_TYPE_ERROR = 1
$EVENT_TYPE_WARNING = 2
$EVENT_TYPE_INFORMATION = 4

Function Get-LocalTime($UTCTime)
{
$strCurrentTimeZone = (Get-WmiObject win32_timezone).StandardName
$TZ = [System.TimeZoneInfo]::FindSystemTimeZoneById($strCurrentTimeZone)
$LocalTime = [System.TimeZoneInfo]::ConvertTimeFromUtc($UTCTime, $TZ)
Return $LocalTime
}

$oAPI = New-Object -ComObject &quot;MOM.ScriptAPI&quot;
$oBag = $oAPI.CreatePropertyBag()
$strServer = &quot;.\$SQLInstance&quot;

$ADOCon = New-Object -ComObject &quot;ADODB.Connection&quot;
$oResults = New-Object -ComObject &quot;ADODB.Recordset&quot;
$adOpenStatic = 3
$adLockOptimistic = 3
$ADOCon.Provider = &quot;sqloledb&quot;
$ADOCon.ConnectionTimeout = 60
$nowInUTC = (Get-Date).ToUniversalTime()
$StartTime = $nowInUTC.AddSeconds(-$Interval)
$conString = &quot;Server=$strServer;Database=$Database;Integrated Security=SSPI&quot;
$strQuery = &quot;Select * from V_Audit Where EventTypeCaption LIKE 'Alarm triggered' AND EventDate &gt;= '$StartTime'&quot;
$ADOCon.Open($conString)
$oResults.Open($strQuery, $ADOCon, $adOpenStatic, $adLockOptimistic)
$oBag.AddValue('Interval', $Interval)
If (!$oResults.EOF)
{
If (!([appdomain]::currentdomain.getassemblies() | Where-Object {$_.FullName -ieq &quot;system.core&quot;}))
{
Try {
Write-Host &quot;Loading .NET DLL into Powershell...&quot; -ForegroundColor Green
[Void][System.Reflection.Assembly]::LoadWithPartialName(&quot;System.Core&quot;)
} Catch {
#We cannot use Write-Error cmdlet here because $ErrorActionPreference is set to &quot;SilentlyContinue&quot; so it won't display on the screen.
Write-Host &quot;Unable to load .NET Framework into Powershell, please make sure it is installed!&quot; -foregroundColor Red
Exit
}
}
$oBag.AddValue('GenerateAlert', 'True')
$arrLogEntries = @()
$oResults.MoveFirst()
Do {
$EventDate = $oResults.Fields.Item(&quot;EventDate&quot;).Value
$EventDate = Get-LocalTime $EventDate
$Description = $oResults.Fields.Item(&quot;Description&quot;).Value
$arrLogEntries += &quot;- $EventDate`: $Description&quot;
$oResults.MoveNext()
} until ($oResults.EOF)
$LogDetail = [System.String]::Join(&quot;&amp;#13;&quot;, $arrLogEntries)
$intEntryCount = $arrLogEntries.count
Remove-Variable arrLogEntries
} else {
$oBag.AddValue('GenerateAlert', 'False')
$intEntryCount = 0
}
$oResults.Close()
$ADOCon.Close()

$oBag.AddValue('LogEntry', $LogDetail)
$oBag.AddValue('LogEntryCount', $intEntryCount)
$oBag
[/sourcecode]

8. Enter below sections after &lt;/ScriptBody&gt; and before &lt;TimeoutSeoncds&gt;:

<strong>&lt;Parameters&gt;
&lt;Parameter&gt;
&lt;Name&gt;SQLInstance&lt;/Name&gt;
&lt;Value&gt;$Config/SQLInstance$&lt;/Value&gt;
&lt;/Parameter&gt;
&lt;Parameter&gt;
&lt;Name&gt;Database&lt;/Name&gt;
&lt;Value&gt;$Config/Database$&lt;/Value&gt;
&lt;/Parameter&gt;
&lt;Parameter&gt;
&lt;Name&gt;Interval&lt;/Name&gt;
&lt;Value&gt;$Config/Interval$&lt;/Value&gt;
&lt;/Parameter&gt;
&lt;/Parameters&gt;</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image4.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb4.png" alt="image" width="501" height="387" border="0" /></a>

9. Click Save in the text editor and close it. you should now see what you’ve entered in the configuration tab of the probe action module:

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image5.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb5.png" alt="image" width="580" height="582" border="0" /></a>

10. Click OK to exit the configuration tab. Under Configuration Schema tab, add 3 parameters (in same order) as shown below:

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image6.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb6.png" alt="image" width="579" height="577" border="0" /></a>

11. Under Data Types, make sure the input and output data is set as below (should be default anyway):

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image7.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb7.png" alt="image" width="580" height="575" border="0" /></a>

12. Under Options, I left Accessibility to “Internal”, but if you are going to use this module outside of this management pack, set it to public.

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image8.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb8.png" alt="image" width="580" height="256" border="0" /></a>

13. Now click OK to exit the probe module window. the probe action module is now created. Now it’s a good time to save the management pack.

<span style="font-size: medium;"><strong>Data Sources Module:</strong></span>

1. Under Type Library pane, go to “Data Sources” under Module Types and click New—&gt;”Composite Data Source…”

2. Give it a unique identifier such as “Your.Management.pack.Prefix.Database.Catcher.DataSource”

3. Open the data source module you’ve just created and give it a display name under “General” tab:

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image9.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb9.png" alt="image" width="514" height="508" border="0" /></a>

4. Add 2 member modules:
<table border="1" width="650" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td valign="top" width="158">
<p align="center"><strong>Module ID</strong></p>
</td>
<td valign="top" width="155">
<p align="center"><strong>Role</strong></p>
</td>
<td valign="top" width="232">
<p align="center"><strong>Type</strong></p>
</td>
<td valign="top" width="103">
<p align="center"><strong>Next Module</strong></p>
</td>
</tr>
<tr>
<td valign="top" width="157">Schedule</td>
<td valign="top" width="155">Data Source</td>
<td valign="top" width="232"><strong>System.SimpleScheduler</strong></td>
<td valign="top" width="103">Probe</td>
</tr>
<tr>
<td valign="top" width="158">Probe</td>
<td valign="top" width="154">Probe Action</td>
<td valign="top" width="232"><strong>Probe Action module you’ve just created</strong></td>
<td valign="top" width="103">Module Output</td>
</tr>
</tbody>
</table>
<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image10.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb10.png" alt="image" width="580" height="299" border="0" /></a>

5. Edit the SimpleScheduler module, for the IntervalSeconds value, click on “promote…”. this will set it to “$Config/IntervalSeconds$”. and leave SyncTime to blank:

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image11.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb11.png" alt="image" width="580" height="326" border="0" /></a>

6. Edit the probe action module, use promote to set values for all 3 parameters:

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image12.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb12.png" alt="image" width="580" height="587" border="0" /></a>

7. Configure “Configuration Schema” tab as below (again, make sure these parameters are in the right order"):

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image13.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb13.png" alt="image" width="580" height="575" border="0" /></a>

8. Configure Overridable Parameters as below:

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image14.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb14.png" alt="image" width="580" height="570" border="0" /></a>

9. Make sure output data type is set to <strong>System.PropertyBagData</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image15.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb15.png" alt="image" width="580" height="194" border="0" /></a>

10. Set accessibility to “public” if you are going to access this module from other management packs.

Now the data source module is complete. We are going to create the rule next.

<span style="font-size: medium;"><strong>Rule:</strong></span>

1. Under Health Model pane, go to “Rules” and click New—&gt;”Custom Rule…”

2. Give it a unique identifier such as “Your.Management.pack.Prefix.Database.Catcher.Rule”

3. Give the rule a display name  and select the target class where you want to run the rule under general tab

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image16.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb16.png" alt="image" width="580" height="573" border="0" /></a>

4. In Modules tab, create a data source module with the type of the data source module type you’ve created previously. give it a module ID of DataSource

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image17.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb17.png" alt="image" width="580" height="251" border="0" /></a>

5. Edit the data source module configuration, enter the values for all 3 parameters: <strong>SQLInstance</strong>, <strong>Database</strong> and <strong>IntervalSeconds</strong>:

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image18.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb18.png" alt="image" width="580" height="306" border="0" /></a>

According to above example, this rule will connect to the database “AuditDB” in the particular SQL instance that you specified and will run in every 5 minutes (300 seconds)

6. Now, create a condition detect module with type: <strong>System.ExpressionFilter</strong> and Module ID: <strong>Filter_AlertCondition</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image19.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb19.png" alt="image" width="576" height="576" border="0" /></a>

7. Edit the condition detection module, under configuration tab, click on Configure… button.

8. Enter the expression as below:

Parameter Name: <strong>Property[@Name='GenerateAlert']</strong>

Operator: <strong>Equals</strong>

Value: <strong>True</strong>

Click OK to save.

It looks like this when it’s done:

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image20.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb20.png" alt="image" width="554" height="559" border="0" /></a>

9. Create an Action module. Type: <strong>System.Health.GenerateAlert</strong>. ModuleID: <strong>Alert</strong>.

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image21.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb21.png" alt="image" width="580" height="572" border="0" /></a>

10. Click Edit for the Action module then click Edit again under Configuration tab to edit the XML.

11. Add below section in the XML before &lt;/Configuration&gt; tag:

<strong>&lt;AlertParameters&gt;
&lt;AlertParameter1&gt;$Target/Property[Type="System!System.Entity"]/DisplayName$&lt;/AlertParameter1&gt;
&lt;AlertParameter2&gt;$Data/Property[@Name='Interval']$&lt;/AlertParameter2&gt;
&lt;AlertParameter3&gt;$Data/Property[@Name='LogEntryCount']$&lt;/AlertParameter3&gt;
&lt;AlertParameter4&gt;$Data/Property[@Name='LogEntry']$&lt;/AlertParameter4&gt;
&lt;/AlertParameters&gt;</strong>
<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image22.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb22.png" alt="image" width="580" height="155" border="0" /></a>

12. save the XML and exit the text editor. then click on Configure to configure the alert. you may use the parameters from previous step to form the alert description.

13.Edit the Production knowledge of this rule if you like. it will also appear with the alert.

Now we are done. You can save this unsealed management pack or seal it using authoring console. please make sure you test it before import it into your production environment.

Below is a sample alert from my test environment:

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image23.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb23.png" alt="image" width="580" height="438" border="0" /></a>

<strong>Few notes:</strong>
<ol>
	<li>The database that I had to work with was a SQL Express DB. I found this free tool extremely useful since I can’t use SQL management studio to connect to SQL Express databases:  <a href="http://www.dbsoftlab.com/database-editors/database-browser/overview.html">Database Browser</a>. The database table screen capture from Part 1 of this series was from this tool.</li>
	<li>When testing the PowerShell Script, I needed to run the script under Local Systems as my account did not have access to the database. Since in my script, I connected to the database using integrated security, I had to make sure I run the script under the account which is going to be used to run the rule (in my case, Local Systems), I had to use <a href="http://technet.microsoft.com/en-us/sysinternals/bb897553">PSExec</a> from Sysinternals to launch Powershell as it allows me to run executables under Local System.</li>
	<li>Originally I used a multi-line string variable in PowerShell script to store records returned from SQL query (one record per line). It didn’t work after added the script to the management pack. I figured out i can use the special HTML character for carriage return inside the string variable in Powershell. So the line looks like this:</li>
</ol>
<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image24.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb24.png" alt="image" width="580" height="26" border="0" /></a>

My sample PowerShell script can be downloaded from <a href="http://blog.tyang.org/wp-content/uploads/2012/01/AuditDBAlarmCatcher.txt">HERE</a>.