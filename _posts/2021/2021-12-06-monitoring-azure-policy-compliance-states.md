---
title: Monitoring Azure Policy Compliance States - 2021 Edition
date: 2021-12-06 16:00
author: Tao Yang
permalink: /2021/12/06/monitoring-azure-policy-compliance-states-2021-edition/
summary: A Complete Monitoring Solution for Azure Policy Compliance States
categories:
  - Azure
tags:
  - Azure
  - Azure Policy
  - Azure Monitor
---

## Introduction

Back in 2019, I published a blog post on Microsoft's ITOps Talk Blog on [How to Create Azure Monitor Alerts for Non-Compliant Azure Policies](https://techcommunity.microsoft.com/t5/itops-talk-blog/how-to-create-azure-monitor-alerts-for-non-compliant-azure/ba-p/713466). Sadly, the solution I posted have stopped working a while ago because Azure Policy no longer publishes resource compliance states to Azure Activity logs.

I have been asked to update the article by the Azure Policy product team numerous times, but I didn't want to just post statement without any positive news. I wanted to develop a brand new solution for monitoring the Azure Policy compliance states using Azure Monitor. I had two possible solutions in mind and it stayed on my office whiteboard for the last 6 months or so. Due to other work commitments, I haven't had time to work on it until now.

![whiteboard](../../../../assets/images/2021/12/policy-monitor-whiteboard.jpg)

The two integration points for Azure Policy that I thought I could use are [Azure Event Grid](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/event-overview) and [Azure Resource Graph](https://docs.microsoft.com/en-us/azure/governance/policy/samples/resource-graph-samples?tabs=azure-cli). In the end, I have decided to take the Event Grid option because I believe it's inexpensive, easier to implement, and scales better in a large environment.

I have spent last few days coding the solution, from the high-level, it looks like the diagram below in the Azure Enterprise-Scale framework.

![diagram](../../../../assets/images/2021/12/policy-monitor-diagram.png)

The solution consists of the following components:

1. Bicep Template for Azure Function App
    * App Service Plan
    * Function App
    * Key Vault
    * App Insights
    * Storage Account

2. Bicep Template for Event Grid
    * Event Grid System Topic
    * Event Grid Subscription

3. Python function fo passing the PolicyInsights events from Event Grid to a Log Analytics workspace via the [Log Analytics Data Collector REST API](https://docs.microsoft.com/en-us/azure/azure-monitor/logs/data-collector-api)

4. A YAML pipeline for Azure DevOps to deploy the entire solution

The solution is published in my GitHub repo [azure.policy.monitor](https://github.com/tyconsulting/azure.policy.monitor).

## Deployment Instruction

Since I have included Bicep templates for deploying all required Azure resources, as well as the source code for the Python function, you can deploy them using your deployment tool of choice, or use the Azure DevOps YAML pipeline included from my repo as a starting point.

There are some pre-requisites for my YAML pipeline that you need to have them ready first.

### Pre-requisites

#### 1. Log Analytics workspaces

Have at least one Log Analytics workspace in each Azure AD tenant that you wish to implement this solution.

#### 2. Azure DevOps

Have an Azure DevOps account (or an Azure DevOps server, although I have not tested this pipeline on Azure DevOps servers. some modifications on the pipeline may be required.)

#### 3. Azure AD Service Principals

Have at least one Azure AD Service Principal in each Azure AD tenant that you wish to implement this solution. The Service Principal is used to deploy all required Azure resources used by this solution. It requires at least Contributor role on all subscriptions that you are deploying the solution to - this includes the management subscription and all landing zone subscriptions. In my lab, I have created the role assignment for the service principals on a Management Group level that all subscriptions are under in the Management Group hierarchy.

>**NOTE:** If the Log Analytics workspace you are using is not located on any of the subscriptions you wish to monitor, then the Service Principal also need permission to look up the Log Analytics workspace and it's Workspace Id and keys.

### Create A Project in Azure DevOps

A project is required in Azure DevOps to host the code and pipeline. You will also need to create the following objects within the Azure DevOps project.

#### Service Connections

Create a Azure Resource Manager service connection for each Azure subscriptions including the Management and all landing zone subscriptions in each environment. My pipeline is expecting the service connections with the following names:

![1](../../../../assets/images/2021/12/image01.png)

* sub-mgmt-dev
* sub-lz-dev-1
* sub-mgmt-prod
* sub-lz-prod-1

Use the service principals created earlier for these Service Connections.

#### Environments

I have created 2 environments in the Azure DevOps project:

![2](../../../../assets/images/2021/12/image02.png)

* Dev
* Prod

I have configured approvals and checks for the Prod environment

![3](../../../../assets/images/2021/12/image03.png)

#### Variable Groups

![4](../../../../assets/images/2021/12/image04.png)

I have created a variable group for each environment (in this case, they are called **variables - dev** and **variables - prod**). The following variables are stored in each variable group:

![5](../../../../assets/images/2021/12/image05.png)

* **appInsightsName** - The name of the Application Insights instance
* **appServicePlanName** - App Service Plan name for the function app
* **appServicePlanSku** - App Service Plan SKU. *Y1* is the Consumption plan
* **eventGridSubName** - Event Grid subscription name
* **functionAppName** - Function App Name
* **keyVaultName** - Key Vault Name
* **keyVaultSku** - Key Vault SKU
* **location** - Azure location where the resources are deployed
* **logAnalyticsWorkspaceResourceId** - The resource Id for the existing Log Analytics workspace where the Policy events are sent to
* **resourceGroupName** - The name of the resource group to be created
* **storageAccountName** - The name of the storage account used by the Function App
* **storageSku** - Storage account SKU
* **topicName** - The name of the Event Grid System Topic for Microsoft.PolicyInsights

#### Prepare code in repo

clone my GitHub repo and then copy everything to the Git repo in your Azure DevOps project.

#### Modify the pipeline

![6](../../../../assets/images/2021/12/image06.png)

Modify the Azure Pipeline (azure-pipelines.yml) to suit your needs (for example, adding additional tests, create more stages for additional environments, adding jobs for additional landing zone subscriptions etc.)

My pipeline contains the following stages and jobs

![7](../../../../assets/images/2021/12/image07.png)

* Stage: **Test and Build**
    * Job: **Lint Tests** - Lint test using GitHub Super Linter (more info on [my previous blog post](https://blog.tyang.org/2020/06/27/use-github-super-linter-in-azure-pipelines/))
    * Job: **ARM Deployment Validation** - Performing template validation and collect what-if results for Bicep templates using Azure CLI
    * Job: **Build Function App** - Build the Python function
    * Job **Publish Pattern** - Publish artifacts
* Stage: **Deploy Dev Stage**
    * Job: **Deploy Function App to Dev Management Subscription** - Deploying the Function app and the python function to Dev Mgmt subscription
    * Job: **Deploy Event Grid Topic and Subscription to Dev Management Subscription** - Deploy the Event Grid system topic nad subscription to Dev Mgmt subscription
    * Job: **Deploy Event Grid Topic and Subscription to Dev Landing Zone #1 Subscription** - Deploy the Event Grid system topic nad subscription to Dev Landing Zone #1 subscription
* Stage: **Deploy Prod Stage** - repeat the Dev stage on prod environment. However this stage will only be deployed from the main branch of the Git repo.

>**NOTE**: You will need to modify the condition for the *Deploy Prod Stage* if your default branch name is not main or you prefer using another branch for production deployments.

Once the **azure-pipelines.yml** file is updated and ready to use. create a new pipeline using this file and execute it.

## Creating Azure Monitor Alert rules

Once the solution is deployed, Event Grid will start invoking the Python function when new events are sent from Azure Policy.

![8](../../../../assets/images/2021/12/image08.png)

You will start seeing the logs with type **PolicyInsights_CL** in the Log Analytics workspaces

![9](../../../../assets/images/2021/12/image09.png)

You may use a refined query such as below for your Azure Monitor alert rules:

```OQL
PolicyInsights_CL
| where event_type_s =~ "Microsoft.PolicyInsights.PolicyStateCreated" or event_type_s =~ "Microsoft.PolicyInsights.PolicyStateChanged"
| where data_complianceState_s =~ "NonCompliant"
| extend Time_Stamp=data_timestamp_t
| extend Resource_Id = subject_s
| extend Subscription_Id = data_subscriptionId_g
| extend Compliance_state = data_complianceState_s
| extend Policy_Definition = data_policyDefinitionId_s
| extend Policy_Assignment = data_policyAssignmentId_s
| extend Compliance_Reason_Code = data_complianceReasonCode_s
| project Time_Stamp, Resource_Id, Subscription_Id, Policy_Assignment, Policy_Definition, Compliance_state, Compliance_Reason_Code
```

![10](../../../../assets/images/2021/12/image10.png)

This query returns the following columns:

* **Time_Stamp** - when the event was generated by Azure Policy
* **Resource_Id** - the resource Id for the non-compliant Azure resource
* **Subscription_id** - the subscription Id for the non-compliant Azure resource
* **Policy_Assignment** - the resource Id for the Policy assignment
* **Policy_Definition** - the resource Id for the Policy definition
* **Compliance_state** - the compliance state
* **Compliance_Reason_Code** - the Compliance reason code (if exists)

I have configured the alert rule based on Log Analytics custom log search with the following configuration:

![11](../../../../assets/images/2021/12/image11.png)

* Logic: Number of results greater than 0
* Period: 5 minutes
* Frequency: 5 minutes

Alert Email Example:

![12](../../../../assets/images/2021/12/image12.png)

>**NOTE:** Creating Azure Monitor alert rules are out of scope for this blog post. if you are planning to create Alert rules using Azure DevOps and YAML pipelines, you may find [my previous post](https://blog.tyang.org/2020/07/25/recording-for-inside-azure-management-virtual-summit-now-available/) on this topic useful.

## Potential Improvements

Due to time constraints, I have not tested this solution in a more secured environments. Most of the resources deployed can be connected to Azure Private Link. i.e. App Service Plan with a Premium SKU, storage account, key vault and even the Log Analytics workspace used to store the logs can all be configured to use Azure Private Link. If your security requirements mandate the use of Private Endpoints, you may consider configuring these resources to use Azure Private Link. However, I have not tested it in my lab at this stage.
