---
id: 625
title: 'Powershell Function: Get-AllDomains (in a forest)'
date: 2011-08-05T15:47:42+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=625
permalink: /2011/08/05/powershell-function-get-alldomains-in-a-forest/
categories:
  - Active Directory
  - PowerShell
tags:
  - Active Directory
  - ADSI
  - Powershell
---
I wrote this Powershell function today as part of a script I’m working on. It is to get a list of Active Directory domains within an Active Directory forest using ADSI:
[sourcecode language="Powershell"]
Function Get-AllDomains
{
$Root = [ADSI]&quot;LDAP://RootDSE&quot;
$oForestConfig = $Root.Get(&quot;configurationNamingContext&quot;)
$oSearchRoot = [ADSI](&quot;LDAP://CN=Partitions,&quot; + $oForestConfig)
$AdSearcher = [adsisearcher]&quot;(&amp;(objectcategory=crossref)(netbiosname=*))&quot;
$AdSearcher.SearchRoot = $oSearchRoot
$domains = $AdSearcher.FindAll()
return $domains
}
[/sourcecode]
<a href="http://blog.tyang.org/wp-content/uploads/2011/08/image2.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/08/image_thumb2.png" alt="image" width="580" height="129" border="0" /></a>

I don’t have any child domains in my test environment, but if you run this on a domain member computer, it will list all child domains as well as the parent forest domain (I’ve tested in the production environment).