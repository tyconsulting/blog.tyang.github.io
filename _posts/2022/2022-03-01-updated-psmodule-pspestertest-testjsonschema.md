---
title: Updated PowerShell Modules - PSPesterTest and TestJsonSchema
date: 2022-03-21 22:00
author: Tao Yang
permalink: /2022/03/01/updated-ps-module-pspestertest-testjsonschema
summary:
categories:
  - PowerShell
tags:
  - PowerShell
  - Pester

---

Few years ago, I published 2 PowerShell modules:

* **PSPesterTest** - This module simplifies PowerShell code analysis using Pester and PSScriptAnalyzer by providing pre-defined pester tests for PowerShell scripts and modules. ([GitHub](https://www.powershellgallery.com/packages/PSPesterTest/), [PSGallery](https://github.com/tyconsulting/PSPesterTest-PSModule))
* **TestJsonSchema** - Performs Pester Test for JSON schema validation ([GitHub](https://github.com/tyconsulting/TestJsonSchema-PS), [PSGallery](https://www.powershellgallery.com/packages/TestJsonSchema/))

I just realized today that both of these modules are outdated, not compatible with the latest version of Pester due to the [breaking changes](https://pester-docs.netlify.app/docs/migrations/breaking-changes-in-v5) introduced to Pester v5.

Therefore I've updated both modules to support the latest version of Pester (v5.3.1 at the time of writing). You can find both them on **GitHub** and **PowerShell Gallery**:

* **PSPesterTest** v2.0.0:

  * [GitHub](https://www.powershellgallery.com/packages/PSPesterTest/)

  * [PSGallery](https://github.com/tyconsulting/PSPesterTest-PSModule)

* **TestJsonSchema** v2.0.0:

  * [GitHub](https://github.com/tyconsulting/TestJsonSchema-PS)

  * [PSGallery](https://www.powershellgallery.com/packages/TestJsonSchema/)
