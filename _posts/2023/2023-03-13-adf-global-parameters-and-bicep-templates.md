---
title: Azure Data Factory Global Parameters and Azure Bicep Templates
date: 2023-03-13 16:00
author: Tao Yang
permalink: /2023/03/13/adf-global-parameters-and-bicep-templates
summary:
categories:
  - Azure
  - PowerShell
tags:
  - Azure
  - Azure Bicep
  - Azure Data Factory

---

Few weeks ago, a colleague made me aware of an issue with the Bicep Template I have developed which creates an Azure Data Factory (ADF). After the ADF was created, people started using it and decided to created few Global Parameters in ADF. However those parameters would somehow be deleted after a while. After some investigation, it turned out because those Global parameters are not defined in the Bicep template, when the IaC pipeline runs again after the Global Parameters were created, the Resource Provider would delete the Global Parameters.

![1](../../../../assets/images/2023/03/adf-global-parameters-01.jpg)

At that time, my Azure Bicep template did not even have the `globalParameters` property defined ([Reference](https://learn.microsoft.com/en-us/azure/templates/microsoft.datafactory/factories?pivots=deployment-language-bicep)). I found it's odd that when you run the template to update an existing resource, why would the Resource Provider wipe out the value of a property that's not even defined in the template? We also found that if the Git integration is enabled for the ADF, the Global Parameters would not be deleted. We have only seen the delete of Global Parameters happen when the Git integration is disabled. We are using the api version `2018-06-01` for the ADF resource, which is the latest version at the time of writing this article.

In this particular environment, the team that uses ADF and the team deploys the applications via Infrastructure as Code (IaC) DevOps pipelines are different people. We can't enforce the data engineers to use our IaC pipelines to manage ADF Global parameters. So we needed to find a way to ensure our IaC pipeline does not interfere with what the data engineers have done in ADF.

The workaround is very simple, I firstly added the ADF `globalParameter` as a Bicep parameter and then added a step in my IaC pipeline to retrieve the existing Global Parameters from the ADF and save them to the Template Parameter.

I cannot share the real code here since it's part of a very complex project. But I have developed a demo to show the process. You can find the PowerShell script and Bicep Template in my [BlogPosts GitHub repo](https://github.com/tyconsulting/BlogPosts/tree/master/Azure-Bicep/adf-global-parameters).

The [deployADF.ps1](https://github.com/tyconsulting/BlogPosts/blob/master/Azure-Bicep/adf-global-parameters/deployADF.ps1) script does the following:

1. Retrieve the existing Global Parameters from the ADF
2. If the Global Parameters are not empty, save them to an Updated Template Parameter JSON file and use the Updated Parameter file for deployment
3. Deploy the ADF using the Bicep Template and Updated Parameter file if existing Global Parameters are found, otherwise use the original Parameter file

![2](../../../../assets/images/2023/03/adf-global-parameters-02.jpg)

In my real life ADO pipeline, I have implemented this approach in the Bicep build stage for each environment, Saved the updated parameter file as a build artifact, then deployed the template with the updated parameter file from the build artifact in the deployment stages.

The only potential issue with this approach is the timing. Since there could be human approvals required for different stages, the time when the template is deployed could be few hours after the Global Parameters were initially checked in the build stages. If the Global Parameters are changed in between the build and deployment stages, these updates would be lost. So it's important to let the team aware do not change the Global Parameters in ADF when the IaC pipeline is running.

P.S. I initially copied the ADF Bicep Module from Microsoft's [CARML](https://aka.ms/carml) library, it did not have the `globalParameters` property defined. I have since submitted a PR to add the property to the [ADF module](https://github.com/Azure/ResourceModules/blob/main/modules/Microsoft.DataFactory/factories/deploy.bicep). It has been merged it's available now.