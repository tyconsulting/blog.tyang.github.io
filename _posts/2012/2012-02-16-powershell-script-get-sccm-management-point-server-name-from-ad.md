---
id: 990
title: 'PowerShell Script: Get SCCM Management Point server name from AD'
date: 2012-02-16T10:23:05+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=990
permalink: /2012/02/16/powershell-script-get-sccm-management-point-server-name-from-ad/
categories:
  - PowerShell
  - SCCM
tags:
  - PowerShell
  - SCCM
---
I wrote this function as a part of a script that I'm working on. it searches AD for the management point server name for a particular SCCM site:

```powershell
Function Get-MPFromAD ($SiteCode)
{
  $domains = Get-AllDomains
  Foreach ($domain in $domains)
  {
    Try {
      $ADSysMgmtContainer = [ADSI]("LDAP://CN=System Management,CN=System," + "$($Domain.Properties.ncname[0])")
      $AdSearcher = [adsisearcher]"(&(Name=SMS-MP-$SiteCode-*)(objectClass=mSSMSManagementPoint))"
      $AdSearcher.SearchRoot = $ADSysMgmtContainer
      $ADManagementPoint = $AdSearcher.FindONE()
      $MP = $ADManagementPoint.Properties.mssmsmpname[0]
    } Catch {}
  }

  Return $MP
}
```

Note: This function uses another function called Get-AllDomains, which I've blogged before here: <a href="https://blog.tyang.org/2011/08/05/powershell-function-get-alldomains-in-a-forest/">https://blog.tyang.org/2011/08/05/powershell-function-get-alldomains-in-a-forest/</a> So make sure you include BOTH functions in your script.