---
id: 6878
title: Configuring Azure Resources Diagnostic Log Settings Using Azure Policy
date: 2018-11-19T23:38:10+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=6878
permalink: /2018/11/19/configuring-azure-resources-diagnostic-log-settings-using-azure-policy/
categories:
  - Azure
tags:
  - Azure
  - Azure Monitor
  - Azure Policy
  - Log Analytics
---
In an Azure Policy definition, the "effect" section defines the behaviour of the policy if defined conditions are met. For example, the "Deny" effect will block the resource from being deployed in the first place, "Append" will add a set of properties to the resource you are deploying before being deployed by the ARM engine, and "DeployIfNotExists" deploys a resource if it does not already exist. In the old days, the biggest limitation I have faced was the use of "DeployIfNotExists" effect was only limited to built-in policies. In another word, If Microsoft hasn’t already created a policy for you, you can’t create one to suit your requirements.

At the 2018 North America Ignite, the Azure Governance team has announced that the Azure Policy effect "DeployIfNotExists" became available for custom policy definitions. This is a very exciting news for me, I have been waiting for this day for a long time, and it would have made my life a lot easier if it was available sooner.

A customer of mine had a requirement that all eligible resources should automatically forward all logs and metrics to an Azure Log Analytics workspace. i.e.

<a href="https://blog.tyang.org/wp-content/uploads/2018/11/image.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/11/image_thumb.png" alt="image" width="779" height="823" border="0" /></a>

At the time of my engagement, this was not possible using a native method. Although for me, it was not hard to develop a custom automation solution for this requirement, but the customer wanted something native, obviously they didn’t want to create a technology debt that ended up having someone to support a custom solution after I’m gone.

Now since the "DeployIfNotExists" Azure Policy effect has been made available for general public, we are able to use custom Policy definitions to automatically configure applicable Azure resources to send logs and metrics to Log Analytics workspace.

Over the last few days, I have spent A LOT OF time developing an ARM template to deploy custom policy and initiative definitions for this purpose. Initially I thought there were only around 20 Azure resource types that are capable of sending diagnostic logs and metrics to Log Analytics. I was very wrong. I couldn’t find any documentation that has a COMPLETE list, and also couldn’t find a way to query what logs and metrics are available for each resources. In the end, the template I developed covered 47 resource types, by consolidating the following sources:

* Microsoft docs: <a href="https://docs.microsoft.com/en-us/azure/log-analytics/log-analytics-azure-storage">Collect Azure service logs and metrics for use in Log Analytics</a> (currently dated Dec 2017, so really outdated)
* Microsoft docs: <a href="https://docs.microsoft.com/en-us/azure/monitoring-and-diagnostics/monitoring-diagnostic-logs-schema">Supported services, schemas and categories for Azure Diagnostic Logs</a> (not sure if this is 100% the complete list)
* Sample policies from <a href="https://github.com/krnese/AzureDeploy/tree/master/ARM/policies/Mgmt/AzureMonitor">Kristian Nese’s GitHub repo</a> (I did find few bugs and issues during my testing)

Over the last 3-4 days, I was up until 2am each day working on this template due to the lack of documentation. I have **PERSONALLY** tested all 47 resources included in this template by creating resources and monitoring the subsequent deployments initiated by the Azure Policy engine. In the end, this 5000+ line gigantic template is born. You can find the link to my GitHub repo that contains the template at the end of this post.

I’m almost certain this is not THE complete list to date, but it’s the best I can do for now:

| Name                            | Resource Type                               |
| ------------------------------- | ------------------------------------------- |
| Analysis Services               | Microsoft.AnalysisServices/servers          |
| API Management                  | Microsoft.ApiManagement/service             |
| Application Gateway             | Microsoft.Network/applicationGateways       |
| Automation account              | Microsoft.Automation/automationAccounts     |
| Azure Container Instance        | Microsoft.ContainerInstance/containerGroups |
| Azure Container Registry        | Microsoft.ContainerRegistry/registrie       |
| Azure Kubernetes Service        | Microsoft.ContainerService/managedClusters  |
| Batch                           | Microsoft.Batch/batchAccounts               |
| CDN Endpoint                    | Microsoft.Cdn/profiles/endpoints            |
| Cognitive service               | Microsoft.CognitiveServices/accounts        |
| Cosmos DB                       | Microsoft.DocumentDB/databaseAccounts       |
| Data Factory                    | Microsoft.DataFactory/factories             |
| Data lake analytics             | Microsoft.DataLakeAnalytics/accounts"       |
| Data Lake storage               | Microsoft.DataLakeStore/accounts            |
| Event Grid Subscriptions        | Microsoft.EventGrid/eventSubscriptions      |
| Event Grid Topics               | Microsoft.EventGrid/topics                  |
| Event hub                       | Microsoft.EventHub/namespaces"              |
| Express Route Circuit           | Microsoft.Network/expressRouteCircuits      |
| Firewall                        | Microsoft.Network/azureFirewalls            |
| HDInsight                       | Microsoft.HDInsight/clusters                |
| Iot hub                         | Microsoft.Devices/IotHubs                   |
| Key vault                       | Microsoft.KeyVault/vaults                   |
| Load balancer                   | Microsoft.Network/loadBalancers             |
| Logic Apps Integration Accounts | Microsoft.Logic/integrationAccounts         |
| Logic Apps Workflow             | Microsoft.Logic/workflows                   |
| MySQL DB                        | Microsoft.DBforMySQL/servers                |
| Network Interface Card (NIC)    | Microsoft.Network/networkInterfaces         |
| Network Security Group          | Microsoft.Network/networkSecurityGroups     |
| PostgreSQL DB                   | Microsoft.DBforPostgreSQL/servers           |
| Power BI Embedded               | Microsoft.PowerBIDedicated/capacities       |
| Public ip                       | Microsoft.Network/publicIPAddresse          |
| Recovery Vault                  | Microsoft.RecoveryServices/vaults           |
| Redis Cache                     | Microsoft.Cache/redis                       |
| Relay                           | Microsoft.Relay/namespaces                  |
| Search Services                 | Microsoft.Search/searchServices             |
| Service Bus                     | Microsoft.ServiceBus/namespaces             |
| SignalR                         | Microsoft.SignalRService/SignalR            |
| SQL DBs                         | Microsoft.Sql/servers/databases             |
| SQL Elastic Pools               | Microsoft.Sql/servers/elasticPools          |
| Stream Analytics                | Microsoft.StreamAnalytics/streamingjobs     |
| Time Series Insights            | Microsoft.TimeSeriesInsights/environments   |
| Traffic Manager                 | Microsoft.Network/trafficManagerProfiles    |
| Azure Bastion Hosts             | Microsoft.Network/bastionHosts              |
| Azure AD Domain Services        | Microsoft.AAD/domainServices                |
| Virtual Network                 | Microsoft.Network/virtualNetworks           |
| Virtual Network Gateway         | Microsoft.Network/virtualNetworkGateways    |
| App Services                    | Microsoft.Web/sites                         |

><del>**Note:** I could not test and build the DDoS Protection resource type into my template, which is listed in one of the links above. This is because the starting price for DDoS protection is around USD $2950 per month and it is charged per month. I can’t afford to create this resource in my lab subscriptions. If anyone is using it, and happy to run some tests for me, please let me know and I can add it to my template.</del>

Since policy and initiative definitions are subscription-level resources, this ARM template is a subscription-level template. Unlike resource group level templates, to deploy subscription-level templates, you must use the "<a href="https://docs.microsoft.com/en-us/powershell/module/azurerm.resources/new-azurermdeployment">New-azurermdeployment</a>" cmdlet instead. i.e.

New-azurermdeployment -name 'diag-policies' –templatefile ‘C:\Temp\policy.definition.azuredeploy.json' -location 'australiasoutheast' –verbose

As shown below, the template deploys 47 policies and 1 initiative:

<a href="https://blog.tyang.org/wp-content/uploads/2018/11/image-1.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/11/image_thumb-1.png" alt="image" width="1002" height="561" border="0" /></a>

When configuring policy assignments, in addition to creating the assignment itself, you may also need to configure permissions to the Log Analytics workspace of your choice. According to the <a href="https://docs.microsoft.com/en-us/azure/governance/policy/how-to/remediate-resources">Microsoft documentation</a> for policy remediations, a Managed Identity (MSI) is created for each policy assignment that contains DeployIfNotExists effects in the definitions. The required permission for the target assignment scope is managed automatically. However, if the remediation tasks need to interact with resources outside of the assignment scope, you will need to manually configure the required permissions. In our case, if the Log Analytics workspace you have specified in the assignment is located outside of the assignment scope (i.e. in another resource group, or another subscription in the same AAD tenant), you will need to manually configure the permission as documented in the doco. The required role for the assignment MSI is "Log Analytics Contributor".

For example, in my lab, I assigned the initiative to a resource group, and the Log Analytics workspace is located in another resource group:

Initiative Assignment:

<a href="https://blog.tyang.org/wp-content/uploads/2018/11/image-2.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/11/image_thumb-2.png" alt="image" width="524" height="481" border="0" /></a>

Log Analytics Resource Group IAM:

<a href="https://blog.tyang.org/wp-content/uploads/2018/11/image-3.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/11/image_thumb-3.png" alt="image" width="1002" height="491" border="0" /></a>

Please keep in mind, for any resources deployed as the result of "DeployIfNotExists" effect, the Azure Policy engine waits approximately 10 minutes after the initial deployment. Therefore, you will not see the policy-triggered ARM deployments straightaway. This is by design.

<a href="https://blog.tyang.org/wp-content/uploads/2018/11/image-4.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/11/image_thumb-4.png" alt="image" width="973" height="375" border="0" /></a>

You can find the template from my GitHub repo here: <a title="https://github.com/tyconsulting/azurepolicy/tree/master/arm-templates/diagnostic-settings" href="https://github.com/tyconsulting/azurepolicy/tree/master/arm-templates/diagnostic-settings">https://github.com/tyconsulting/azurepolicy/tree/master/arm-templates/diagnostic-settings</a>

Lastly, please feel free to fork and raise PR if you’ve found any bugs or missing resource types.