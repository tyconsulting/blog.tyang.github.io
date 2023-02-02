---
title: Generating README for Bicep Files
date: 2023-02-02 22:30
author: Tao Yang
permalink: /2023/02/02/generating-readme-for-bicep/
summary: Generating README for Bicep Files using PowerShell module PSDocs
categories:
  - Azure
  - PowerShell
tags:
  - Azure
  - PowerShell
  - Azure Bicep

---

## Introduction

[PSDocs](https://github.com/microsoft/PSDocs) is a tool developed by Microsoft's [Bernie White](https://github.com/BernieWhite), who is also the creator of my favourite tool [PSRules](https://github.com/microsoft/PSRule). PSDocs is a PowerShell module that you can use to generate `README.md` files for your Azure Resource Manager (ARM) templates. I have used it in several projects, to make sure all my bicep templates and modules are documented. I have created a script that uses `PSDocs` to generate README files for any bicep files, all you need is a `metadata.json` file in the same folder as your bicep file. The script will generate a `README.md` file for the bicep file you have specified.

You can find the script `generateBicepReadme.ps1`[here](https://github.com/tyconsulting/BlogPosts/blob/master/Scripts/psDocs/generateBicepReadme.ps1)

## How to use the script

Before running the script, you will need:

1. Azure CLI with Bicep extension installed ([Instruction](https://learn.microsoft.com/en-us/cli/azure/bicep?view=azure-cli-latest#az-bicep-install))
2. PsDocs PowerShell module installed ([Source](https://www.powershellgallery.com/packages/PSDocs/0.9.0))
3. PsDocs.Azure PowerShell module installed ([Source](https://www.powershellgallery.com/packages/PSDocs.Azure/0.3.0))
4. a `metadata.json` file in the same folder as your bicep file. this file must contain the following sections:

```json
{
  "itemDisplayName": "Display Name of the Template",
  "description": "Template Discription.",
  "summary": "Summary describing the Bicep template."
}
```

To generate the `README.md` file, simply run the script with the following parameters:

```PowerShell
./generateBicepReadme.ps1 -templatePath .<path-to-bicep-file> -verbose
```

![1](../../../../assets/images/2023/02/psdocs-01.jpg)

The script will generate a `README.md` file in the same folder as the bicep file. Then you can add and commit the `README.md` file to your git repository.

![2](../../../../assets/images/2023/02/psdocs-02.jpg)

This example can be found in my GitHub repo [here](https://github.com/tyconsulting/BlogPosts/tree/master/Azure-Bicep/vnet-isolated-cloud-shell)

## Conclusion

It's a common ask for the customers to have all our code documented. PSDocs is a great tool to automatically document our Bicep IaC code. It has saved me a lot of time and effort. All I needed to do is to run this script for each bicep file I have developed. In the IaC pipelines I have developed, I have even created a Pester test to check if the `README.md` file is generated for each bicep file and all required sections are included.

If you code in Bicep and haven't used it before, I highly recommend you to give it a try.
