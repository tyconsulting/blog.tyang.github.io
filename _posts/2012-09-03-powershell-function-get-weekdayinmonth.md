---
id: 1392
title: 'PowerShell Function: Get-WeekDayInMonth'
date: 2012-09-03T22:37:11+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=1392
permalink: /2012/09/03/powershell-function-get-weekdayinmonth/
categories:
  - PowerShell
tags:
  - Powershell
---
Often, IT admins need to workout the first/second/third/fourth Mon/Tue/Wed/Thur/Fri/Sat/Sun of any given month. some good examples are:
<ul>
	<li>Prepare themselves for Microsoft’s patching Tuesday of each month</li>
	<li>Planning for any admin tasks caused by Day Light Saving time change</li>
</ul>
So I wrote this simple function today to calculate the date for any given month & year.

Here’s the function:

```powershell
Function Get-WeekDayInMonth ([int]$Month, [int]$year, [int]$WeekNumber, [int]$WeekDay)
{

$FirstDayOfMonth = Get-Date -Year $year -Month $Month -Day 1 -Hour 0 -Minute 0 -Second 0
#First week day of the month (i.e. first monday of the month)
[int]$FirstDayofMonthDay = $FirstDayOfMonth.DayOfWeek
$Difference = $WeekDay - $FirstDayofMonthDay
If ($Difference -lt 0)
{
$DaysToAdd = 7 - ($FirstDayofMonthDay - $WeekDay)
} elseif ($difference -eq 0 )
{
$DaysToAdd = 0
}else {
$DaysToAdd = $Difference
}
$FirstWeekDayofMonth = $FirstDayOfMonth.AddDays($DaysToAdd)
Remove-Variable DaysToAdd
#Add Weeks
$DaysToAdd = ($WeekNumber -1)*7
$TheDay = $FirstWeekDayofMonth.AddDays($DaysToAdd)
If (!($TheDay.Month -eq $Month -and $TheDay.Year -eq $Year))
{
$TheDay = $null
}
$TheDay
}
```


the $weekday variable represents the week day you after:
<div align="center">
<table width="238" border="0" cellspacing="0" cellpadding="2" align="center">
<tbody>
<tr>
<td valign="top" width="76">0</td>
<td valign="top" width="160">Sunday</td>
</tr>
<tr>
<td valign="top" width="76">1</td>
<td valign="top" width="160">Monday</td>
</tr>
<tr>
<td valign="top" width="76">2</td>
<td valign="top" width="160">Tuesday</td>
</tr>
<tr>
<td valign="top" width="76">3</td>
<td valign="top" width="160">Wednesday</td>
</tr>
<tr>
<td valign="top" width="76">4</td>
<td valign="top" width="160">Thursday</td>
</tr>
<tr>
<td valign="top" width="76">5</td>
<td valign="top" width="160">Friday</td>
</tr>
<tr>
<td valign="top" width="76">6</td>
<td valign="top" width="160">Saturday</td>
</tr>
</tbody>
</table>
</div>
<div align="left"><strong>Usage:</strong></div>
<div align="left"></div>
<div align="left">Example #1: to query the <strong>2nd Tuesday of October 2012</strong>:</div>
<div align="left"><strong>Get-WeekDayInMonth –month 10 –year 2012 –Weeknumber 2 –Weeday 2</strong></div>
<div align="left">OR</div>
<div align="left"><strong>Get-WeekDayInMonth 10 2012 2 2</strong></div>
<div align="left"><a href="http://blog.tyang.org/wp-content/uploads/2012/09/image.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/09/image_thumb.png" alt="image" width="637" height="117" border="0" /></a></div>
<div align="left">Example #2: to query the 1st<strong> Sunday of May 2013</strong>:</div>
<div align="left"><strong>Get-WeekDayInMonth –month 5 –year 2013 –Weeknumber 1 –Weeday 0</strong></div>
<div align="left">OR</div>
<div align="left"><strong>Get-WeekDayInMonth 5 2013 1 0</strong></div>
<a href="http://blog.tyang.org/wp-content/uploads/2012/09/image1.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/09/image_thumb1.png" alt="image" width="580" height="114" border="0" /></a>