---
id: 6265
title: Azure Resource Policy to Restrict ALL ASM Resources
date: 2017-10-21T23:16:44+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=6265
permalink: /2017/10/21/azure-resource-policy-to-restrict-all-asm-resources/
categories:
  - Azure
tags:
  - Azure
  - Azure Resource Policy
---
I needed to find a way to restrict ALL Azure Service Manager (ASM, aka Classic) resources on the subscription level. Azure Resource Policy seems to be a logical choice. So I quickly developed [a very simple Policy Definition](https://gist.github.com/tyconsulting/5d48530f5a7a58d50fc8c83bd3995c99):

```json
{
  "if": {
    "field": "type",
    "like": "Microsoft.Classic*"
  },
  "then": {
    "effect": "Deny"
  }
}
```

Once I have deployed the definition and assigned it to the subscription level (using PowerShell commands listed below), I could no longer deploy ASM resources:

```powershell
#Set the Subscription ID
$subscriptionId = '7c6bd10f-ab0d-4a8b-9c32-548589e1142b'

Add-AzureRmAccount
Select-AzureRmSubscription -Subscription $subscriptionId

$definition = New-AzureRmPolicyDefinition -Name "restrict-all-asm-resources" -DisplayName "Restrict All ASM Resources" -description "This policy enables you to restrict ALL Azure Service Manager (ASM, aka Classic) resources." -Policy '.\Restrict-ALL-ASM-Resources.json'  -Mode All
$definition
$assignment = New-AzureRMPolicyAssignment -Name 'Restrict All ASM Resources' -PolicyDefinition $definition -Scope "/subscriptions/$subscriptionId"
$assignment
```
i.e. when I tried to create a classic VNet, I could not pass the validation:

<a href="https://blog.tyang.org/wp-content/uploads/2017/10/image-3.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/10/image_thumb-3.png" alt="image" width="1002" height="528" border="0" /></a>