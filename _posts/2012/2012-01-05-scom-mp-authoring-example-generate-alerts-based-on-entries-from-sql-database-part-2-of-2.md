---
id: 833
title: 'SCOM MP Authoring Example: Generate alerts based on entries from SQL Database (Part 2 of 2)'
date: 2012-01-05T18:41:11+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=833
permalink: /2012/01/05/scom-mp-authoring-example-generate-alerts-based-on-entries-from-sql-database-part-2-of-2/
categories:
  - SCOM
tags:
  - MP Authoring
  - PowerShell
  - SCOM
---
This is the 2nd part of the 2-part series.  Part 1 can be found <a title="SCOM MP Authoring Example: Generate alerts based on entries from SQL Database (Part 1 of 2)" href="http://blog.tyang.org/2012/01/04/scom-mp-authoring-example-generate-alerts-based-on-entries-from-sql-database-part-1-of-2/">here</a>.

In Part 2, I’ll cover the steps involved to create each module type and the rule in this article. all these objects will be created in SCOM 2007 R2 Authoring Console. You can create a new management pack for this or use an existing one.

Firstly, we will need create the probe action and data source modules:

## Probe Action Module

1. Under Type Library pane, go to "Probe Actions" under Module Types and click New—>"Composite Probe Action…"

2. Give it a unique identifier such as "Your.Management.pack.Prefix.Database.Catcher.Probe.Action"

3. in general tab, give it a name:

![1](http://blog.tyang.org/wp-content/uploads/2012/01/image1.png)

{:start="4"}
4. Under Member Modules, add **Microsoft.Windows.PowerShellPropertyBagTriggerOnlyProbe** and give it a Module ID of "PSScript"

![2](http://blog.tyang.org/wp-content/uploads/2012/01/image2.png)

{:start="5"}
5. Click on Edit

6. Enter the ScriptName and TImeoutSeconds. Then Edit again in the Configuration tab of the probe action module

![3](http://blog.tyang.org/wp-content/uploads/2012/01/image3.png)

{:start="7"}
7. When the text editor is launched, Enter the powershell script in between <ScriptBody> and </ScriptBody> tags

8. Below is the script I used in my management pack. please edit it to suit your needs:

```powershell
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

$oAPI = New-Object -ComObject "MOM.ScriptAPI"
$oBag = $oAPI.CreatePropertyBag()
$strServer = ".\$SQLInstance"

$ADOCon = New-Object -ComObject "ADODB.Connection"
$oResults = New-Object -ComObject "ADODB.Recordset"
$adOpenStatic = 3
$adLockOptimistic = 3
$ADOCon.Provider = "sqloledb"
$ADOCon.ConnectionTimeout = 60
$nowInUTC = (Get-Date).ToUniversalTime()
$StartTime = $nowInUTC.AddSeconds(-$Interval)
$conString = "Server=$strServer;Database=$Database;Integrated Security=SSPI"
$strQuery = "Select * from V_Audit Where EventTypeCaption LIKE 'Alarm triggered' AND EventDate >= '$StartTime'"
$ADOCon.Open($conString)
$oResults.Open($strQuery, $ADOCon, $adOpenStatic, $adLockOptimistic)
$oBag.AddValue('Interval', $Interval)
If (!$oResults.EOF)
{
  If (!([appdomain]::currentdomain.getassemblies() | Where-Object {$_.FullName -ieq "system.core"}))
  {
    Try {
      Write-Host "Loading .NET DLL into Powershell..." -ForegroundColor Green
      [Void][System.Reflection.Assembly]::LoadWithPartialName("System.Core")
    } Catch {
      #We cannot use Write-Error cmdlet here because $ErrorActionPreference is set to "SilentlyContinue" so it won't display on the screen.
      Write-Host "Unable to load .NET Framework into Powershell, please make sure it is installed!" -foregroundColor Red
      Exit
    }
  }
  $oBag.AddValue('GenerateAlert', 'True')
  $arrLogEntries = @()
  $oResults.MoveFirst()
  Do {
    $EventDate = $oResults.Fields.Item("EventDate").Value
    $EventDate = Get-LocalTime $EventDate
    $Description = $oResults.Fields.Item("Description").Value
    $arrLogEntries += "- $EventDate`: $Description"
    $oResults.MoveNext()
  } until ($oResults.EOF)
  $LogDetail = [System.String]::Join("&#13;", $arrLogEntries)
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
```
{:start="9"}
9. Enter below sections after </ScriptBody> and before <TimeoutSeoncds>:

**<Parameters><Parameter><Name>SQLInstance</Name><Value>$Config/SQLInstance$</Value></Parameter><Parameter><Name>Database</Name><Value>$Config/Database$</Value></Parameter><Parameter><Name>Interval</Name><Value>$Config/Interval$</Value></Parameter></Parameters>**

![4](http://blog.tyang.org/wp-content/uploads/2012/01/image4.png)

{:start="10"}
10. Click Save in the text editor and close it. you should now see what you’ve entered in the configuration tab of the probe action module:

![5](http://blog.tyang.org/wp-content/uploads/2012/01/image5.png)

{:start="11"}
11. Click OK to exit the configuration tab. Under Configuration Schema tab, add 3 parameters (in same order) as shown below:

![6](http://blog.tyang.org/wp-content/uploads/2012/01/image6.png)

{:start="12"}
12. Under Data Types, make sure the input and output data is set as below (should be default anyway):

![7](http://blog.tyang.org/wp-content/uploads/2012/01/image7.png)

{:start="13"}
13. Under Options, I left Accessibility to "Internal", but if you are going to use this module outside of this management pack, set it to public.

![8](http://blog.tyang.org/wp-content/uploads/2012/01/image8.png)

{:start="14"}
14. Now click OK to exit the probe module window. the probe action module is now created. Now it’s a good time to save the management pack.

## Data Sources Module

1. Under Type Library pane, go to "Data Sources" under Module Types and click New—>"Composite Data Source…"

2. Give it a unique identifier such as "Your.Management.pack.Prefix.Database.Catcher.DataSource"

3. Open the data source module you’ve just created and give it a display name under "General" tab:

![9](http://blog.tyang.org/wp-content/uploads/2012/01/image9.png)

{:start="4"}
4. Add 2 member modules:

| Module ID | Role         | Type                                        | Next Module   |
| --------- | ------------ | ------------------------------------------- | ------------- |
| Schedule  | Data Source  | **System.SimpleScheduler**                  | Probe         |
| Probe     | Probe Action | **Probe Action module you’ve just created** | Module Output |

![10](http://blog.tyang.org/wp-content/uploads/2012/01/image10.png)

{:start="5"}
5. Edit the SimpleScheduler module, for the IntervalSeconds value, click on "promote…". this will set it to "$Config/IntervalSeconds$". and leave SyncTime to blank:

![11](http://blog.tyang.org/wp-content/uploads/2012/01/image11.png)

{:start="6"}
6. Edit the probe action module, use promote to set values for all 3 parameters:

![12](http://blog.tyang.org/wp-content/uploads/2012/01/image12.png)

{:start="7"}
7. Configure "Configuration Schema" tab as below (again, make sure these parameters are in the right order"):

![13](http://blog.tyang.org/wp-content/uploads/2012/01/image13.png)

{:start="8"}
8. Configure Overridable Parameters as below:

![14](http://blog.tyang.org/wp-content/uploads/2012/01/image14.png)

{:start="9"}
9. Make sure output data type is set to **System.PropertyBagData**

![15](http://blog.tyang.org/wp-content/uploads/2012/01/image15.png)

{:start="10"}
10. Set accessibility to "public" if you are going to access this module from other management packs.

Now the data source module is complete. We are going to create the rule next.

## Rule

1. Under Health Model pane, go to "Rules" and click New—>"Custom Rule…"

2. Give it a unique identifier such as "Your.Management.pack.Prefix.Database.Catcher.Rule"

3. Give the rule a display name  and select the target class where you want to run the rule under general tab

![16](http://blog.tyang.org/wp-content/uploads/2012/01/image16.png)

{:start="4"}
4. In Modules tab, create a data source module with the type of the data source module type you’ve created previously. give it a module ID of DataSource

![17](http://blog.tyang.org/wp-content/uploads/2012/01/image17.png)

{:start="5"}
5. Edit the data source module configuration, enter the values for all 3 parameters: **SQLInstance**, **Database** and **IntervalSeconds**:

![18](http://blog.tyang.org/wp-content/uploads/2012/01/image18.png)

According to above example, this rule will connect to the database "AuditDB" in the particular SQL instance that you specified and will run in every 5 minutes (300 seconds)

{:start="6"}
6. Now, create a condition detect module with type: **System.ExpressionFilter** and Module ID: **Filter_AlertCondition**

![19](http://blog.tyang.org/wp-content/uploads/2012/01/image19.png)

{:start="7"}
7. Edit the condition detection module, under configuration tab, click on Configure… button.

8. Enter the expression as below:

  * Parameter Name: **Property[@Name='GenerateAlert']**
  * Operator: **Equals**
  * Value: **True**

Click OK to save.

It looks like this when it’s done:

![20](http://blog.tyang.org/wp-content/uploads/2012/01/image20.png)

{:start="9"}
9. Create an Action module. Type: **System.Health.GenerateAlert**. ModuleID: **Alert**.

![21](http://blog.tyang.org/wp-content/uploads/2012/01/image21.png)

{:start="10"}
10. Click Edit for the Action module then click Edit again under Configuration tab to edit the XML.

11. Add below section in the XML before </Configuration> tag:

```xml
<AlertParameters>
  <AlertParameter1>$Target/Property[Type="System!System.Entity"]/DisplayName$</AlertParameter1>
  <AlertParameter2>$Data/Property[@Name='Interval']$</AlertParameter2>
  <AlertParameter3>$Data/Property[@Name='LogEntryCount']$</AlertParameter3>
  <AlertParameter4>$Data/Property[@Name='LogEntry']$</AlertParameter4>
</AlertParameters>
```
![22](http://blog.tyang.org/wp-content/uploads/2012/01/image22.png)

{:start="12"}
12. save the XML and exit the text editor. then click on Configure to configure the alert. you may use the parameters from previous step to form the alert description.

13. Edit the Production knowledge of this rule if you like. it will also appear with the alert.

Now we are done. You can save this unsealed management pack or seal it using authoring console. please make sure you test it before import it into your production environment.

Below is a sample alert from my test environment:

![23](http://blog.tyang.org/wp-content/uploads/2012/01/image23.png)

**Few notes:**

* The database that I had to work with was a SQL Express DB. I found this free tool extremely useful since I can’t use SQL management studio to connect to SQL Express databases:  <a href="http://www.dbsoftlab.com/database-editors/database-browser/overview.html">Database Browser</a>. The database table screen capture from Part 1 of this series was from this tool.</li>
* When testing the PowerShell Script, I needed to run the script under Local Systems as my account did not have access to the database. Since in my script, I connected to the database using integrated security, I had to make sure I run the script under the account which is going to be used to run the rule (in my case, Local Systems), I had to use <a href="http://technet.microsoft.com/en-us/sysinternals/bb897553">PSExec</a> from Sysinternals to launch Powershell as it allows me to run executables under Local System.</li>
* Originally I used a multi-line string variable in PowerShell script to store records returned from SQL query (one record per line). It didn’t work after added the script to the management pack. I figured out i can use the special HTML character for carriage return inside the string variable in Powershell. So the line looks like this:</li>

![24](http://blog.tyang.org/wp-content/uploads/2012/01/image24.png)


My sample PowerShell script can be downloaded from [HERE](http://blog.tyang.org/wp-content/uploads/2012/01/AuditDBAlarmCatcher.txt)