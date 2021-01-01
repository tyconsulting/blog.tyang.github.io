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

<ul>
    <li>Updated the existing policy definitions for the following Azure services:</li>
<ul>
    <li>Azure Container Registry</li>
    <li>Azure Kubernetes Service</li>
    <li>Azure API Management</li>
    <li>Azure Cognitive Services</li>
    <li>Cosmos DB</li>
    <li>Azure Data Factory</li>
    <li>Event Grid Topic</li>
    <li>ExpressRoute Circuits</li>
    <li>Azure Firewall</li>
    <li>Azure HDInsight</li>
    <li>Azure Recovery Services Vault (Split Azure Backup and Azure Site Recovery into separate policies as explained in <a href="https://docs.microsoft.com/en-us/azure/backup/backup-azure-diagnostic-events?WT.mc_id=DOP-MVP-5000997">this article</a>)</li>
    <li>IoT Hub</li>
    <li>MySQL</li>
    <li>PostgreSQL</li>
    <li>Azure Relay</li>
    <li>SignalR</li>
    <li>SQL Elastic Pool</li>
    <li>Virtual Network</li>
    <li>Virtual Network Gateway (update + bugfix)</li>
    <li>Web App (Updated to exclude Function App. Function App is not included because Diagnostic settings only support Function App V3 which is still in preview, and I can’t seem to find a way to detect Function Run time version using policy aliases).</li>
</ul>
    <li>New policy definitions for:</li>
<ul>
    <li>CDN Profile</li>
    <li>Log App Integration Service Environment</li>
    <li>AppInsights</li>
    <li>App Service Environment</li>
    <li>Azure Storage Account (at the time of writing, this is still in public preview, documented in <a href="https://docs.microsoft.com/en-us/azure/azure-monitor/insights/storage-insights-overview?WT.mc_id=DOP-MVP-5000997">this article</a>)</li>
</ul>
    <li>Updated Diagnostic Setting policies that send data Log Analytics:</li>
<ul>
    <li>Added “<a href="https://docs.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure#parameter-properties?WT.mc_id=DOP-MVP-5000997">assignPermission</a>” to log analytics workspaces</li>
    <li>Added Azure Diagnostics mode vs Resource-Specific mode selection for applicable resource types (explained in <a href="https://docs.microsoft.com/en-us/azure/azure-monitor/reference/tables/azurediagnostics?WT.mc_id=DOP-MVP-5000997">this article</a>)</li>
</ul>
</ul>