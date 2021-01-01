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

<ul>
    <li>Microsoft docs: <a href="https://docs.microsoft.com/en-us/azure/log-analytics/log-analytics-azure-storage">Collect Azure service logs and metrics for use in Log Analytics</a> (currently dated Dec 2017, so really outdated)</li>
    <li>Microsoft docs: <a href="https://docs.microsoft.com/en-us/azure/monitoring-and-diagnostics/monitoring-diagnostic-logs-schema">Supported services, schemas and categories for Azure Diagnostic Logs</a> (not sure if this is 100% the complete list)</li>
    <li>Sample policies from <a href="https://github.com/krnese/AzureDeploy/tree/master/ARM/policies/Mgmt/AzureMonitor">Kristian Nese’s GitHub repo</a> (I did find few bugs and issues during my testing)</li>
</ul>

Over the last 3-4 days, I was up until 2am each day working on this template due to the lack of documentation. I have <strong>PERSONALLY</strong> tested all 47 resources included in this template by creating resources and monitoring the subsequent deployments initiated by the Azure Policy engine. In the end, this 5000+ line gigantic template is born. You can find the link to my GitHub repo that contains the template at the end of this post.

I’m almost certain this is not THE complete list to date, but it’s the best I can do for now:

<strong> </strong>

<table style="line-height: normal; border-collapse: collapse; table-layout: auto;" border="0" width="744" cellspacing="0" cellpadding="0"><colgroup> <col style="mso-width-source: userset; mso-width-alt: 7051;" width="304" /> <col style="mso-width-source: userset; mso-width-alt: 10240;" width="440" /></colgroup>
<tbody>
<tr style="height: 14.5pt;">
<td class="xl65" style="padding: 1px; vertical-align: bottom; white-space: nowrap;" align="center" width="304" height="29"><span style="font-size: 11pt;"><strong>Name</strong></span></td>
<td class="xl65" style="padding: 1px; vertical-align: bottom; white-space: nowrap;" align="center" width="440"><span style="font-size: 11pt;"><strong>Resource Type</strong></span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">Analysis Services</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.AnalysisServices/servers</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">API Management</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.ApiManagement/service</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">Application Gateway</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.Network/applicationGateways</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">Automation account</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.Automation/automationAccounts</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">Azure Container Instance</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.ContainerInstance/containerGroups</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">Azure Container Registry</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.ContainerRegistry/registrie</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">Azure Kubernetes Service</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.ContainerService/managedClusters</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">Batch</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.Batch/batchAccounts</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">CDN Endpoint</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.Cdn/profiles/endpoints</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">Cognitive service</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.CognitiveServices/accounts</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">Cosmos DB</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.DocumentDB/databaseAccounts</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">Data Factory</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.DataFactory/factories</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">Data lake analytics</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.DataLakeAnalytics/accounts"</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">Data Lake storage</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.DataLakeStore/accounts</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">Event Grid Subscriptions</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.EventGrid/eventSubscriptions</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">Event Grid Topics</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.EventGrid/topics</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">Event hub</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.EventHub/namespaces"</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">Express Route Circuit</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.Network/expressRouteCircuits</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">Firewall</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.Network/azureFirewalls</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">HDInsight</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.HDInsight/clusters</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">Iot hub</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.Devices/IotHubs</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">Key vault</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.KeyVault/vaults</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">Load balancer</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.Network/loadBalancers</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">Logic Apps Integration Accounts</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.Logic/integrationAccounts</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">Logic Apps Workflow</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.Logic/workflows</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">MySQL DB</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.DBforMySQL/servers</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">Network Interface Card (NIC)</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.Network/networkInterfaces</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">Network Security Group</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.Network/networkSecurityGroups</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">PostgreSQL DB</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.DBforPostgreSQL/servers</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">Power BI Embedded</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.PowerBIDedicated/capacities</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">Public ip</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.Network/publicIPAddresse</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">Recovery Vault</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.RecoveryServices/vaults</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">Redis Cache</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.Cache/redis</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">Relay</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.Relay/namespaces</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">Search Services</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.Search/searchServices</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">Service Bus</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.ServiceBus/namespaces</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">SignalR</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.SignalRService/SignalR</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">SQL DBs</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.Sql/servers/databases</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">SQL Elastic Pools</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.Sql/servers/elasticPools</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">Stream Analytics</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.StreamAnalytics/streamingjobs</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">Time Series Insights</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.TimeSeriesInsights/environments</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">Traffic Manager</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.Network/trafficManagerProfiles</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">Azure Bastion Hosts</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.Network/bastionHosts</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">Azure AD Domain Services</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.AAD/domainServices</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">Virtual Network</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.Network/virtualNetworks</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">Virtual Network Gateway</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.Network/virtualNetworkGateways</span></td>
</tr>
<tr style="height: 14.5pt;">
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;" height="29"><span style="font-size: 11pt;">App Services</span></td>
<td style="padding: 1px; vertical-align: bottom; white-space: nowrap;"><span style="font-size: 11pt;">Microsoft.Web/sites</span></td>
</tr>
</tbody>
</table>

<blockquote><del><strong>Note:</strong> I could not test and build the DDoS Protection resource type into my template, which is listed in one of the links above. This is because the starting price for DDoS protection is around USD $2950 per month and it is charged per month. I can’t afford to create this resource in my lab subscriptions. If anyone is using it, and happy to run some tests for me, please let me know and I can add it to my template.</del></blockquote>

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