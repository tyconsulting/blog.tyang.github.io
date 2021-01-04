---
id: 867
title: 'SCOM: Powershell Property Bag Trigger Only Probe VS Windows Script Property Bag Probe'
date: 2012-01-27T09:44:56+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=867
permalink: /2012/01/27/scom-powershell-property-bag-trigger-only-probe-vs-windows-script-property-bag-probe/
categories:
  - SCOM
tags:
  - MP Authoring
  - SCOM
---
When writing a Probe Action Module to run a trigger only PowerShell script and return property bags, <strong>Microsoft.Windows.PowerShellPropertyBagTriggerOnlyProbe</strong> module can be used. However, there is no trigger only probe module if you want to run VBScript.

Below are 2 examples how to create trigger only probe modules for both PowerShell and VBScript:
<h2><span style="font-weight: bold;">1. PowerShell</span></h2>

## Member Modules:

<strong>Microsoft.Windows.PowerShellPropertyBagTriggerOnlyProbe</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image27.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb27.png" alt="image" width="580" height="455" border="0" /></a>

## Data Types:

Input: Trigger Only

Output: System.PropertyBag Data

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image28.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb28.png" alt="image" width="580" height="455" border="0" /></a>
<h2><span style="font-weight: bold;">2. VBScript:</span></h2>

## Member Modules:

<strong>System.PassThroughProbe</strong>

<strong>Microsoft.Windows.ScriptPropertyBagProbe</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image29.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb29.png" alt="image" width="580" height="455" border="0" /></a>

## Data Type:

Input: Trigger Only

Output: System.PropertyBag Data

<a href="http://blog.tyang.org/wp-content/uploads/2012/01/image30.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/01/image_thumb30.png" alt="image" width="580" height="450" border="0" /></a>