---
id: 477
title: Setting SMS_INSTALL_DIR_PATH Environment variable on SCCM site servers for SCOM SCCM management pack
date: 2011-05-05T18:25:36+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=477
permalink: /2011/05/05/setting-sms_install_dir_path-environment-variable-on-sccm-site-servers-for-scom-sccm-management-pack/
categories:
  - SCCM
  - SCOM
  - VBScript
tags:
  - SCCM
  - SCOM Management Pack
  - SMS_INSTALL_DIR_PATH
  - VBScript
---
According to the [Configuration Manager 2007 SP2 Management Pack User’s Guide for Operations Manager 2007 R2 and Operations Manager 2007 SP1](http://www.microsoft.com/downloads/en/details.aspx?FamilyID=a8443173-46c2-4581-b3b8-ce67160f627b&displaylang=en)(for MP version 6.0.6000.2), An environment variable named "SMS_INSTALL_DIR_PATH" needs to be created on all SCCM site servers.

I had to do this on 80+ site servers, so I thought why not do this using a script and let SCCM to push it out to all site servers?

Therefore, I wrote a VBScript [Set-EnvirVar-For-SCOM.vbs](https://blog.tyang.org/wp-content/uploads/2011/05/Set-EnvirVar-For-SCOM.zip) (I didn’t use PowerShell this time because it is easier to push out VBScripts via SCCM).

Source Code:
```vb
Set objWMIService = GetObject("winmgmts:" _
& "{impersonationLevel=impersonate}!\\.\root\cimv2")
Set colServices = objWMIService.ExecQuery _
("Select * from Win32_service Where Name = 'SMS_SITE_COMPONENT_MANAGER'")

For each item in colServices
ServicePath = item.PathName
Next

IF Left(ServicePath,1) = Chr(34) THEN
ServicePath = Right(ServicePath, Len(ServicePath)-1)
END IF
IF Right(ServicePath,1) = Chr(34) THEN
ServicePath = Left(ServicePath, Len(ServicePath)-1)
END IF

InstDir = Replace(ServicePath,"\bin\i386\sitecomp.exe","")

EnvVarName = "SMS_INSTALL_DIR_PATH"
IF LEN(InstDir)&gt;0 THEN
Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")
Set objVariable = objWMIService.Get("Win32_Environment").SpawnInstance_
objVariable.Name = EnvVarName
objVariable.UserName = "&lt;System&gt;"
objVariable.VariableValue = InstDir
objVariable.Put_
ELSE
'Wscript.Echo "This is not a SCCM Site Server"
END IF

'Wscript.Echo "Done"
```

This script retrieves the path of the executable (sitecomp.exe) for the SMS_SITE_COMPONENT_MANAGER service via WMI class Win32_Service, and determine the SMS Install Path based on the path to the executable. It then create a new system environment variable if the path is valid. – This means you can run this script against non-SCCM Site servers and it will not create the environment variable on these machines.

Once I’ve tested the script by manually running in on different servers, I then create a SCCM collection called "SCCM Site Servers". This collection is a query based collection that looks for machines running SMS_SITE_COMPONENT_MANAGER" service.

Finally, I created a package and deployed it out to this collection.