---
id: 7496
title: November 2020 Update for Azure Diagnostic Settings Policy Definitions
date: 2020-11-22T13:48:29+10:00
author: Tao Yang
##layout: post
guid: https://blog.tyang.org/?p=7496
permalink: /2020/11/22/november-2020-update-for-azure-diagnostic-settings-policy-definitions/
spay_email:
  - ""
categories:
  - Azure
tags:
  - Azure
  - Azure Policy
---
Last month, I released some updates to the <a href="https://github.com/tyconsulting/azurepolicy/tree/master/policy-definitions/resource-diagnostics-settings">Azure Policy definitions for Diagnostics Settings</a>. After that update, there was a requirement for me to revisit and revalidate all existing policy definitions, so I have spent few days and have gone through them all, making sure they are still up-to-date. I have also added few definitions for few additional Azure services.

Here’s a the change log:

* Updated the existing policy definitions for the following Azure services:
  * Azure Container Registry
  * Azure Kubernetes Service
  * Azure API Management
  * Azure Cognitive Services
  * Cosmos DB
  * Azure Data Factory
  * Event Grid Topic
  * ExpressRoute Circuits
  * Azure Firewall
  * Azure HDInsight
  * Azure Recovery Services Vault (Split Azure Backup and Azure Site Recovery into separate policies as explained in <a href="https://docs.microsoft.com/en-us/azure/backup/backup-azure-diagnostic-events?WT.mc_id=DOP-MVP-5000997">this article</a>)
  * IoT Hub
  * MySQL
  * PostgreSQL
  * Azure Relay
  * SignalR
  * SQL Elastic Pool
  * Virtual Network
  * Virtual Network Gateway (update + bugfix)
  * Web App (Updated to exclude Function App. Function App is not included because Diagnostic settings only support Function App V3 which is still in preview, and I can’t seem to find a way to detect Function Run time version using policy aliases).
* New policy definitions for:
  * CDN Profile
  * Log App Integration Service Environment
  * AppInsights
  * App Service Environment
  * Azure Storage Account (at the time of writing, this is still in public preview, documented in <a href="https://docs.microsoft.com/en-us/azure/azure-monitor/insights/storage-insights-overview?WT.mc_id=DOP-MVP-5000997">this article</a>)
* Updated Diagnostic Setting policies that send data Log Analytics:
  * Added "<a href="https://docs.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure#parameter-properties?WT.mc_id=DOP-MVP-5000997">assignPermission</a>" to log analytics workspaces
  * Added Azure Diagnostics mode vs Resource-Specific mode selection for applicable resource types (explained in <a href="https://docs.microsoft.com/en-us/azure/azure-monitor/reference/tables/azurediagnostics?WT.mc_id=DOP-MVP-5000997">this article</a>)

