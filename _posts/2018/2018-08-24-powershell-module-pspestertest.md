---
id: 6532
title: 'PowerShell Module: PSPesterTest'
date: 2018-08-24T00:04:00+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=6532
permalink: /2018/08/24/powershell-module-pspestertest/
categories:
  - PowerShell
tags:
  - Pester
  - PowerShell
  - PSScriptAnalyzer
---
Few weeks ago, the customer I was working for has a requirement that all the PowerShell scripts and in-house written modules must be validated against PSScriptAnalyzer as part of the build pipelines before it is implemented to their Azure environments in release pipelines. The validation must be performed using Pester so the test results can be easily consumed in the VSTS projects (i.e. dashboards).

Luckily, I found this blog post: <a title="https://blog.kilasuit.org/2016/03/29/invoking-psscriptanalyzer-in-pester-tests-for-each-rule/" href="https://blog.kilasuit.org/2016/03/29/invoking-psscriptanalyzer-in-pester-tests-for-each-rule/">https://blog.kilasuit.org/2016/03/29/invoking-psscriptanalyzer-in-pester-tests-for-each-rule/</a>, so I used this post as the starting point, and created a PowerShell module that performs pester test by invoking PS Script Analyzer rules. I named this module PSPesterTest.

This module contains 2 functions:

* Test-ImportModule
* Test-PSScriptAnalyzerRule

**Test-ImportModule**

This function tests if the module can be imported successfully.

<a href="https://blog.tyang.org/wp-content/uploads/2018/08/image-3.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/08/image_thumb-3.png" alt="image" width="1002" height="212" border="0" /></a>

**Test-PSScriptAnalyzerRule**

This function performs Pester Test to test PowerShell scripts using PowerShell Script Analzyer. By default, it tests against all the rules included in the PSScriptAnalyzer module. You can also run additional rules by specifying the –CustomRulePath parameter (i.e. the <a href="https://github.com/PowerShell/PSScriptAnalyzer/tree/development/Tests/Engine/CommunityAnalyzerRules">CommunityAnalyzerRules</a>). By default, the Pester test will flag the test is failed if the Script Analyzer rule is marked as error. There are 3 severity levels: Information, Warning and Error. You can change the minimum level by using the –MinimumSeverityLevel parameter. i.e. if you specify "Information" as the minimum level, any rules that are flagged as Information, Warning and Error will be flagged as failed in the Pester Test.

<a href="https://blog.tyang.org/wp-content/uploads/2018/08/image-4.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/08/image_thumb-4.png" alt="image" width="1002" height="1751" border="0" /></a>

This module really simplified the testing and code validation process in my VSTS pipelines. I started using it not only in the pipelines for PowerShell modules (which I will blog it in the coming days), but also in any Azure related pipelines that include PowerShell scripts (such as automation accounts and runbooks). i.e. when you publish a module to PowerShell Gallery, your code will be tested against PSScriptAnalyzer. So you should ensure PSScriptAnalyzer does not have any error flagged for your module. Using this module, it is a one liner, and when using it in VSTS pipelines, you can also create a widget displaying your test result:

<a href="https://blog.tyang.org/wp-content/uploads/2018/08/image-5.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/08/image_thumb-5.png" alt="image" width="976" height="474" border="0" /></a>

The PSPesterTest module has been published on PowerShell Gallery, and the source code is in GitHub:

* PSGallery: <a title="https://www.powershellgallery.com/packages/PSPesterTest" href="https://www.powershellgallery.com/packages/PSPesterTest">https://www.powershellgallery.com/packages/PSPesterTest</a>
* GitHub: <a title="https://github.com/tyconsulting/PSPesterTest-PSModule" href="https://github.com/tyconsulting/PSPesterTest-PSModule">https://github.com/tyconsulting/PSPesterTest-PSModule</a>

Both functions in this module is fully documented in the help file. You can use Get-Help cmdlet to access the help content.