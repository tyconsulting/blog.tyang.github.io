---
title: Generate Unique GUID in PowerShell
date: 2023-07-07 21:00
author: Tao Yang
permalink: /2023/07/07/powershell-generate-unique-guid/
summary:
categories:
  - PowerShell
tags:
  - PowerShell
---

In Azure ARM / Bicep templates, there is a function called [guid()](https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/template-functions-string#guid) which allows you to generate a unique GUID. You can use this function as many times as you want, as long as the input strings are the same, the output GUID will always be the same.

I use the `guid()` function a lot when working on Bicep code, however, few weeks ago I needed to generate unique GUIDs within a PowerShell script. I couldn't find any existing code examples, so I came up with my own:

```powershell
Function GenerateGuid {
  [CmdletBinding()]
  param (
    [parameter(Mandatory = $true)]
    [string[]]$inputStrings
  )
  $enc = [system.Text.Encoding]::UTF8
  $sha = New-Object System.Security.Cryptography.SHA1CryptoServiceProvider
  $joinedStrings = $inputStrings -join "-"
  $joinedStringsByteArray = $enc.GetBytes($joinedStrings)
  $joinedStringsHash = [system.Convert]::toBase64String($($sha.ComputeHash($joinedStringsByteArray)))
  $joinedStringsHashTruncated = $joinedStringsHash.Substring(0, 16)
  $joinedStringsHashTruncatedByteArray = $enc.GetBytes($joinedStringsHashTruncated)
  $guid = [guid]::new($joinedStringsHashTruncatedByteArray)
  $guid.tostring()
}
```
Same as the Bicep `guid()` function, as long as the array of strings (and the positions) stay the same, you will get the same GUID every time you run the function:

![1](../../../../assets/images/2023/07/powershell_unique_guid_1.jpg)
