---
id: 4900
title: 'Azure Automation Runbook: New-FakeVirus'
date: 2015-11-28T21:12:24+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=4900
permalink: /2015/11/28/azure-automation-runbook-new-fakevirus/
categories:
  - Azure
  - OMS
tags:
  - Azure Automation
  - OMS
  - PowerShell
---
Often when you are playing with security related products, you would need to create dummy/fake viruses on your computers. The most common way to do this is to create a EICAR test file (<a title="https://en.wikipedia.org/wiki/EICAR_test_file" href="https://en.wikipedia.org/wiki/EICAR_test_file">https://en.wikipedia.org/wiki/EICAR_test_file</a>).

I have used this method in the past when testing the Microsoft Forefront Endpoint Protection management pack in OpsMgr. Today I needed to use it again when I was preparing a demo for the OMS Malware Assessment. I thought, why not make an Azure Automation runbook that automatically create the EICAR test file for me on remote computers, so I can trigger it manually or schedule it to run on a regular basis? So here’s what I came up with.

<strong><span style="color: #ff0000;">CAUTION:</span></strong> Use it at your own risk! And obviously, this runbook is designed to run on hybrid workers <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" src="http://blog.tyang.org/wp-content/uploads/2015/11/wlEmoticon-smile1.png" alt="Smile" />.
<h3>Runbook: New-FakeVirus</h3>
<pre language="PowerShell">#=========================================================
# AUTHOR:  Tao Yang 
# DATE:    28/11/2015
# SCRIPT:  New-FakeVirus.ps1
# Version: 1.0
# Comment: Create a fake EICAR test virus on a computer
#=========================================================
PARAM (
    [Parameter(Mandatory=$false,HelpMessage="Please specify the remote computer" )][ValidateScript({Test-Connection -ComputerName $_ -Count 1 -Quiet})][string]$ComputerName=$env:ComputerName,
    [Parameter(Mandatory=$false,HelpMessage="Please specifiy location for the test EICAR virus file" )][String]$Folder,
    [Parameter(Mandatory=$false,HelpMessage="Please enter the administrative credential for the target computer")][PSCredential]$Credential
)

#Since ^ is the escape character in Windows cmd. the string 'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*' will be 'X5O!P%@AP[4\PZX54(P^^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*'
$EICARString = 'X5O!P%@AP[4\PZX54(P^^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*'
$now = Get-Date -Format yyyy-MMM-dd-HH-mm-ss
#Use System environment variable TEMP if $Folder is not specified
If (!$Folder)
{
    $Folder = (Get-WmiObject -ComputerName $ComputerName -Credential $Credential -Query "Select * from Win32_Environment Where Name='TEMP' AND UserName=''").VariableValue
}
$FilePath = Join-Path $Folder "EICAR_$now.txt"
Write-Verbose "Writing test EICAR file to '$FilePath' on computer '$ComputerName'."

$CreateFile = (Get-WmiObject -ComputerName $ComputerName -Class win32_process -Credential $Credential -List).Create("$env:SystemRoot\system32\cmd.exe /c `"ECHO $EICARString > $FilePath`"")
$ReturnValue = $CreateFile.ReturnValue
If ($ReturnValue -eq 0)
{
    Write-Output "The EICAR test virus file written to computer '$ComputerName' on '$FilePath'."
} else {
    Write-Error "failed to write EICAR test virus file '$FilePath' on computer '$ComputerName'. The return code is $ReturnCode."
}

</pre>
You will need to specify 3 optional input parameters:

<a href="http://blog.tyang.org/wp-content/uploads/2015/11/image6.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/11/image_thumb6.png" alt="image" width="211" height="342" border="0" /></a>
<ul>
	<li>Credential: The name of the credential asset saved in your Azure Automation account – If you need to use an alternative credential to connect to the target computer (via WMI)</li>
	<li>ComputerName: The target computer of where the fake virus is going to be created, if not specified, it will be created on the runbook worker itself.</li>
	<li>Folder: the folder of where the file is going to be created on the target computer. If not specified, the runbook will use the System environment variable %TEMP%.</li>
</ul>
<h3>Runbook Output:</h3>
<a href="http://blog.tyang.org/wp-content/uploads/2015/11/image7.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/11/image_thumb7.png" alt="image" width="672" height="243" border="0" /></a>

If your Windows Defender or System Center Endpoint Protection (SCEP) is working correctly, you will see this on your target computer straightaway:

<a href="http://blog.tyang.org/wp-content/uploads/2015/11/image8.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/11/image_thumb8.png" alt="image" width="514" height="402" border="0" /></a>

If the target computer is monitored by OpsMgr and you have imported the Forefront Endpoint Protection (FEP) 2010 MP, you’ll get an alert:

<a href="http://blog.tyang.org/wp-content/uploads/2015/11/image9.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/11/image_thumb9.png" alt="image" width="486" height="167" border="0" /></a>

And you will also see in the OMS Malware Assessment dashboard shortly:

<a href="http://blog.tyang.org/wp-content/uploads/2015/11/image10.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/11/image_thumb10.png" alt="image" width="511" height="281" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2015/11/image11.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/11/image_thumb11.png" alt="image" width="480" height="351" border="0" /></a>