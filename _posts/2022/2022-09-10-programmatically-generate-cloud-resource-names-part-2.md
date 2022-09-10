---
title: Programmatically Generate Cloud Resource Names - Part 2
date: 2022-09-10 18:00
author: Tao Yang
permalink: /2022/09/10/programmatically-generate-cloud-resource-names-part-2/
summary: Solution to generate cloud resource names programmatically as part of your infrastructure as code pipelines. Part 2.
categories:
  - Azure
tags:
  - Azure
  - PowerShell
  - Azure DevOps
  - DevOps
---

This is the part 2 of the 2-part series on *Programmatically Generate Cloud Resource Names*.

If you haven't read the [Part 1](https://blog.tyang.org/2022/09/10/programmatically-generate-cloud-resource-names-part-1/), make sure you read it first.

In this post, I will show you how to use the `CloudNaming` module to programmatically generate cloud resource names as part of your Infrastructure as Code (IaC) pipelines. I will use Azure DevOps YAML pipelines to demonstrate the process.

As you have seen in the previous post, I have decoupled the naming patterns from the actual PowerShell code. This allows you to easily change the naming patterns without having to change the PowerShell code. It also means that you should be confident to install the latest version of the `CloudNaming` module from a public repository such as [PowerShell Gallery](https://www.powershellgallery.com/packages/CloudNaming/) without worrying about breaking your pre-defined naming patterns.

However, if your organization prefers to have everything in 1 place, you can always choose to modify the built-in naming patterns in the `CloudNaming` module by editing the `CloudNaming.json` file inside the module directory. You can then publish your "forked" version of the module in a private PowerShell repository such as [Azure Artifacts](https://docs.microsoft.com/en-us/azure/devops/artifacts/tutorials/private-powershell-library?view=azure-devops) for your organization to use.

In this post, I am going to demonstrate 2 use cases:

1. Using a modified version from Azure Artifacts
2. Using the public version from the PowerShell Gallery with customized configuration file hosted internally inside your organization

All the source code for this post can be found in `CloudNaming` module's GitHub repository under the [pipeline-examples folder]](https://github.com/tyconsulting/CloudNaming-Module/tree/master/pipeline-examples)

## Consuming Customized Version From Azure Artifacts

In this example, I am using an organization-level Azure Artifacts feed called `PSModules` to host the feed. You can use any feeds that you have access to.

### Pipeline for Pushing the Module to Azure Artifacts

Firstly, I have created a pipeline to publish the customized version of the `CloudNaming` module to the `PSModules` feed. You can find the pipeline definition in the [GitHub repository](https://github.com/tyconsulting/CloudNaming-Module/blob/master/pipeline-examples/pipelines/azure-pipelines-install-azure-artifacts.yml)

You will make sure that you have given the following identities the contributor role to the Azure Artifacts organization-level feed:

1. (*project-name*) Build Service (*organization name*)
2. Project Collection Build Service (*organization name*)

![05](../../../../assets/images/2022/09/cloudNaming-05.jpg)

Also make sure when every time the module is updated, the version number is increased in the module manifest `CloudNaming.psd1` file.

This pipeline will perform the following tasks:

1. run [GitHub Super-Linter](https://blog.tyang.org/2020/06/27/use-github-super-linter-in-azure-pipelines/) to lint the entire repository
2. package the module into a NuGet package
3. push the NuGet package to the Azure Artifacts feed

![06](../../../../assets/images/2022/09/cloudNaming-06.jpg)

### Sample pipeline for consuming the customized version from Azure Artifacts

![07](../../../../assets/images/2022/09/cloudNaming-07.jpg)

The code for this sample pipeline can be found [HERE](https://github.com/tyconsulting/CloudNaming-Module/blob/master/pipeline-examples/pipelines/azure-pipelines-demo-1.yaml)

Scenario:

* Install CloudNaming module from a Organization-Level Azure Artifact feed (Internal to the organization).
* Use default configuration file from the module
* Generate resource names one at a time (basic usage) using a [PowerShell script](https://github.com/tyconsulting/CloudNaming-Module/blob/master/pipeline-examples/scripts/update-demo-1-parameters.ps1)
* Update the Bicep template parameter file with the generated resource names
* Publish updated parameter file
* Deploy the Bicep template with the updated parameter file to an Azure subscription

![08](../../../../assets/images/2022/09/cloudNaming-08.jpg)

## Consuming Public Version From PowerShell Gallery

![09](../../../../assets/images/2022/09/cloudNaming-09.jpg)

In this example, I am using the public version of the `CloudNaming` module from the PowerShell Gallery. I have also created a customized configuration file to configure my organization's internally approved naming standard.

The code for this sample pipeline can be found [HERE](https://github.com/tyconsulting/CloudNaming-Module/blob/master/pipeline-examples/pipelines/azure-pipelines-demo-2.yaml)

Scenario:

* Install CloudNaming module from Public PowerShell Gallery repository.
* Uses a custom configuration file from the `config` folder.
* Generate multiple resource names in one command (advanced scenario) using a [PowerShell script](https://github.com/tyconsulting/CloudNaming-Module/blob/master/pipeline-examples/scripts/update-demo-2-parameters.ps1)
* Update the Bicep template parameter file with the generated resource names
* Publish updated parameter file
* Deploy the Bicep template with the updated parameter file to an Azure subscription

![10](../../../../assets/images/2022/09/cloudNaming-10.jpg)


### Configuration File Location

If you are considering to use the public version of the `CloudNaming` module coupled with customized configuration file, please think carefully where you will place the configuration file. Ideally, the configuration should be in a centralized location serving multiple Azure DevOps projects and pipelines. i.e. You can use Azure Artifacts to host the configuration file and use the [Azure Artifacts Universal Package](https://docs.microsoft.com/en-us/azure/devops/artifacts/quickstarts/universal-packages?view=azure-devops) or placing it in a public repository within your organization's ADO or GitHub Enterprise server and have the pipeline to download the configuration file from there.

## Conclusion

This concludes the 2-part series on *Programmatically Generate Cloud Resource Names*. I hope you have found this post useful. If you have any questions or comments, please feel free to leave a comment below. Again, I welcome PRs to the GitHub repository to improve the module and the sample pipelines.
