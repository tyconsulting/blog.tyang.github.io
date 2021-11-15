---
id: 1392
title: 'PowerShell Function: Get-WeekDayInMonth'
date: 2012-09-03T22:37:11+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=1392
permalink: /2012/09/03/powershell-function-get-weekdayinmonth/
categories:
  - PowerShell
tags:
  - PowerShell
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

* 0: Sunday
* 1: Monday
* 2: Tuesday
* 3: Wednesday
* 4: Thursday
* 5: Friday
* 6: Saturday

**Usage:**

Example #1: to query the 2nd Tuesday of October 2012

```powershell
Get-WeekDayInMonth –month 10 –year 2012 –Weeknumber 2 –Weeday 2
```
OR

```powershell
Get-WeekDayInMonth 10 2012 2 2
```

![](https://blog.tyang.org/wp-content/uploads/2012/09/image.png)

Example #2: to query the 1st Sunday of May 2013

```powershell
Get-WeekDayInMonth –month 5 –year 2013 –Weeknumber 1 –Weeday 0
```
OR
```powershell
Get-WeekDayInMonth 5 2013 1 0
```

![](https://blog.tyang.org/wp-content/uploads/2012/09/image1.png)
