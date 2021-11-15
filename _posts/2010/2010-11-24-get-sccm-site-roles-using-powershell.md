---
id: 304
title: Get SCCM site roles using Powershell
date: 2010-11-24T15:33:21+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/2010/11/24/get-sccm-site-roles-using-powershell/
permalink: /2010/11/24/get-sccm-site-roles-using-powershell/
categories:
  - PowerShell
  - SCCM
tags:
  - PowerShell
  - SCCM
  - Site Roles
---
You can run the following on the site server to find out the servers holding each SCCM role:

```powershell
$SMSProvider = get-wmiobject sms_providerlocation -namespace root\sms -filter "ProviderForLocalSite = True"
$SiteCode = $SMSProvider.SiteCode
$ProviderMachine = $SMSProvider.Machine
get-wmiobject -Class SMS_SystemResourceList -NameSpace root\sms\site_$SiteCode -Computername $ProviderMachine | format-list RoleName,ServerRemoteName,SiteCode
```

<a href="https://blog.tyang.org/wp-content/uploads/2010/11/image1.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2010/11/image_thumb1.png" border="0" alt="image" width="518" height="743" /></a>