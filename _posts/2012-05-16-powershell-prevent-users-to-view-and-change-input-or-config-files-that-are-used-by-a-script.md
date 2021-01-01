---
id: 1230
title: 'Powershell: Prevent Users To View and Change Input or Config Files That Are Used by a Script'
date: 2012-05-16T22:07:10+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=1230
permalink: /2012/05/16/powershell-prevent-users-to-view-and-change-input-or-config-files-that-are-used-by-a-script/
categories:
  - PowerShell
tags:
  - Powershell
---
Often, I use .xml or .ini files to store settings that a PowerShell script uses. When I distribute my scripts to end users, sometimes, I want to make sure users cannot manually view or change the content of these config files.

Below is what I did to achieve the goal:
<ol>
	<li>Create a password protected zip file that contains the config file (.xml or .ini).</li>
	<li>rename the zip file from xxxxxx.zip to xxxxxx.bin</li>
	<li>In powershell script, use <a href="http://www.icsharpcode.net/OpenSource/SharpZipLib/Default.aspx">ICSharpCode.SharpZipLib.dll</a> to unzip renamed zip file</li>
	<li>compile powershell script to exe so users cannot view the script to figure out the zip file password.</li>
	<li>read the content of the extracted config file</li>
	<li>delete extracted config file</li>
</ol>
To compile the powershell script, I can use one of these tools:
<ul>
	<li><a href="http://rkeithhill.wordpress.com/2010/09/21/make-ps1exewrapper/">Make-PS1ExeWrapper</a></li>
	<li><a href="http://ps2exe.codeplex.com/">PS2EXE</a></li>
</ul>
Below is a sample Powershell script (Zip-Test.PS1) I have written to read a xml file inside a renamed zip file:

[sourcecode language="PowerShell"]
param ([string]$FilePath)
$ziplib = Join-Path $FilePath &quot;ICSharpCode.SharpZipLib.dll&quot;
[System.Reflection.Assembly]::LoadFrom(&quot;$ziplib&quot;) | Out-Null
$ZipName = &quot;Health-Check.bin&quot;
$XmlName = &quot;Health-Check.xml&quot;
$xmlPath = Join-Path $FilePath $XmlName
$ZipPath = Join-Path $FilePath $ZipName
$objZip = New-Object ICSharpCode.SharpZipLib.Zip.FastZip
$objZip.Password = &quot;password&quot;
$objzip.ExtractZip($ZipPath, $FilePath, $XmlName)
if ((Test-Path $xmlPath))
{
$xml = (get-content $xmlPath)
Remove-Item $xmlPath -Force
}
$xml.configuration
[/sourcecode]


The script extracts and reads the health-check.xml file and deletes health-check.xml straightaway, it happens so fast, it won’t be possible for end users to access the file. Below is the output from above sample code (content of my XML file):

<a href="http://blog.tyang.org/wp-content/uploads/2012/05/image10.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/05/image_thumb10.png" alt="image" width="580" height="402" border="0" /></a>

One thing to keep in mind: in most of my scripts, I use

[sourcecode language="PowerShell"]
$thisScript = Split-Path $myInvocation.MyCommand.Path -Leaf
$scriptRoot = Split-Path (Resolve-Path $myInvocation.MyCommand.Path)
[/sourcecode]


To determine the script name and location. $MyInvocation does not work anymore after I converted the Powershell script to EXE. Therefore, from my above example, I’m actually passing the directory location into the script as a parameter.