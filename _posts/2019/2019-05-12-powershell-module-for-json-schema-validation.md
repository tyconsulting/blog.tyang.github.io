---
id: 6998
title: PowerShell Module For JSON Schema Validation
date: 2019-05-12T12:51:52+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=6998
permalink: /2019/05/12/powershell-module-for-json-schema-validation/
categories:
  - PowerShell
tags:
  - JSON
  - Pester
  - PowerShell
---

## Background

Few days ago, I needed to validate JSON files against a predefined schema in a build pipeline in Azure DevOps. The validation needed to be performed using the Pester framework, and fail the build if the validation failed.

In the past, I’ve always used this script (<a href="https://gist.github.com/JamesNK/7e6d026c8b78c049bb1e1b6fb0ed85cf">https://gist.github.com/JamesNK/7e6d026c8b78c049bb1e1b6fb0ed85cf</a>) from James Newton-King, which leverages the JSON.Net libraries he developed. However, this time, I couldn’t it the script working on my Windows 10 laptop. I tried different versions of the DLLs, some won’t load, and the version that loads fine on my laptop threw some errors about System.Runtime library not referenced in the C# code he embedded in the PowerShell script. Due to these difficulties, I didn’t want to go further with this approach, because I don’t want to having manage external libraries (and its nuget packages) within the pipeline for my PowerShell script, and I don’t want to deal with .Net versions either. I don’t want to be limited on what Azure Pipeline agent queues I can or cannot use because of the .Net versions – As far as I can see, the Newtonsoft.Json nuget package does not have a .Net Core version of the library. Even if I have got this script working in my pipeline, it will be too complicated and have too many limitations.

Luckily, The Microsoft.PowerShell.Utility module from PowerShell version 6 comes with a cmdlet <a href="https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/test-json?view=powershell-6" target="_blank" rel="noopener noreferrer">Test-Json</a>, which allows you to validate a JSON file against a schema file. This cmdlet is not available in Windows PowerShell version 5. I decided to go down this route, because the only dependency is that I have to use PowerShell Core, which is available in most the Azure Pipeline Microsoft-hosted agents.

I coded the script into a PowerShell module, so I can define module dependency (i.e. Pester, PowerShell version 6), and use Azure Artifacts to host it, so I can install the module from the Azure Artifacts feed to the hosted agents during the execution of the build pipeline.

I may cover how I use Azure Artifacts to host PowerShell modules and use them in CI/CD pipelines another time.

## PowerShell Module: TestJSONSchema

* GitHub: <a href="https://github.com/tyconsulting/TestJsonSchema-PS">https://github.com/tyconsulting/TestJsonSchema-PS</a>
* PowerShell Gallery: <a href="https://www.powershellgallery.com/packages/TestJsonSchema/1.0.0">https://www.powershellgallery.com/packages/TestJsonSchema/1.0.0</a>

As I mentioned earlier, this module requires PowerShell Core (version 6+), and Pester. You will need to install PowerShell Core and Pester module in PowerShell Core. The instruction is provided in the README.md file in the GitHub repo.

The module provides a function called <strong>Test-JsonSchema</strong>, it Pester tests one or more files against a specified schema file:

<a href="https://blog.tyang.org/wp-content/uploads/2019/05/image.png"><img width="722" height="438" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb.png" border="0"></a>

You can use Get-Help to read the detailed help file of this function.


>**Important Note:** This module is **NOT** designed to validate Azure Resource Manager (ARM) templates. The ARM templates support features that are not natively defined the the JSON specifications (such as single-line and multi-line comments). If your goal is to pester test your ARM templates, the ARM product group in Microsoft has provided an awesome solution, you can find it from the Azure Quickstart Templates repo: <a href="https://github.com/Azure/azure-quickstart-templates/tree/master/test/template-tests">https://github.com/Azure/azure-quickstart-templates/tree/master/test/template-tests</a>