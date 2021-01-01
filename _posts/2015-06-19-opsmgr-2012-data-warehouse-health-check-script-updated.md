---
id: 4009
title: OpsMgr 2012 Data Warehouse Health Check Script Updated
date: 2015-06-19T21:43:04+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=4009
permalink: /2015/06/19/opsmgr-2012-data-warehouse-health-check-script-updated/
categories:
  - PowerShell
  - SCOM
tags:
  - Health Check
  - SCOM
---
Since I published the <a href="http://blog.tyang.org/2015/06/11/opsmgr-2012-data-warehouse-health-check-script/" target="_blank">OpsMgr 2012 Data Warehouse Health Check Script</a> last week, the responses I have received from the community have been overwhelming!

As I mentioned the the post that there might be potential issues when executing the script for an environment where the Data Warehouse DB is hosted on a named SQL instance, man people have reached out to me and confirmed this is indeed the case.

Over the last few days, I have been busy updating this script to address all the issues identified by the community. The version 1.1 is now ready.

I have addressed the following issues in this release:
<ul>
	<li>Fixed the issues with named SQL instances and SQL instances using non-default ports.</li>
	<li>Fixed the issue where the script failed to get management group default settings when executed in PowerShell version 5 preview.</li>
	<li>Fixed the error where incorrect Buffer Cache Hit Ratio counter is presented on the report.</li>
	<li>Additional pre-requisite check for PowerShell version. This script requires minimum version 3.0</li>
	<li>Additional pre-requisite check to test WinRM and remote WMI connectivity to each management server</li>
	<li>Fixed minor typos in the reports</li>
	<li>Additional optional parameter “-OutputDir”. You can now specify the script to write reports to a folder of your choice. This folder must be previously created by you. If the specified folder is not valid or this parameter is not used, the script will write the report files to the script root folder.</li>
</ul>
&nbsp;

<strong>I have updated the original post, the updated version of the script can now be downloaded from the original link.</strong>

<strong>Credit</strong>

I’d like to thank everyone who tested and provided valuable feedback to me. This project is truly a wonderful community effort!