---
title: Log Analytics Queries for Billable Data per Subscription
date: 2025-02-24 12:00
author: Tao Yang
permalink: /2025/02/24/og-analytics-queries-for-billable-data-per-sub
summary: Log Analytics Queries for Billable Data per Subscription that can be used to calculate and charge back the data usage to different subscriptions.
categories:
  - Azure
tags:
  - Azure
  - Azure Monitor
  - Log Analytics
  - Kusto Query Language

---

When we deploy Azure Enterprise Scale Landing Zones, We often advise our customers to use a centralised Log Analytics workspace for all their Azure resources and configure the workspace to use the [Resource-context Access Mode](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/manage-access?tabs=portal#access-mode). With this pattern, normally the cloud administrators and security teams would have been granted access on the Log Analytics workspace level. The application teams who consume the Azure resources do not need to be granted any roles to the Log Analytics workspace.

There are many benefits of using this pattern:

- Log data, table retention can be centrally managed.
- Simply the management of AMPLS (Azure Monitor Private Link Scope).
- Simply the management of Log Analytics workspace access.
- Able to apply for discounted price via [Commitment Tier](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/cost-logs#commitment-tiers) (There is a minimum volume requirement for commitment tier, which small workspaces will not be able to qualify).
- Simplify the log access, monitor and alerting configurations since all the logs are in the same location.

However, one of the challenges of using a centralised Log Analytics workspace is how to calculate and charge back the data usage to different subscriptions. In most of the billing solutions, customers normally have nominated a common tag that's associated to the internal cost centre which is used for consumption charge back.

Few days ago, I worked with my good friend [Alex Verkinderen](https://x.com/AlexVerkinderen) and came up with the following queries to calculate the total billable data per subscription. The queries are based on the assumption that the `SolutionID` tag is used to identify the cost centre for each subscription. The queries are designed to be used in any Log Analytics workspace and leverage the capability of [cross querying Azure Resource Graph](https://techcommunity.microsoft.com/blog/azuregovernanceandmanagementblog/azure-monitor-availability-alerts-using-resource-graph-queries/4096469). By cross querying Azure Resource Graph, we can get the subscription name and any tags of interest from the Azure Resource Graph and join the data with the Log Analytics data.

Here are the 2 queries we have developed:

**Total ingested volume over last month per subscription**

```OQL
arg("").ResourceContainers
| where type =~ 'microsoft.resources/subscriptions'
| project SubscriptionName = name, subscriptionId, SolutionId = tags['SolutionID']
| join kind=inner hint.remote=right (
    find where TimeGenerated between(startofday(ago(32d))..startofday(now())) project _BilledSize, _IsBillable,  _SubscriptionId
    | where _IsBillable == true
    | summarize BillableDataBytes = sum(_BilledSize) by _SubscriptionId
    | extend DataIngestedInGB = format_bytes(BillableDataBytes, 3, "GB")
    | extend subscriptionId = _SubscriptionId
) on subscriptionId
| sort by BillableDataBytes
| project SubscriptionName, subscriptionId, SolutionId, DataIngestedInGB

```

![01](../../../../assets/images/2025/02/law-queries-01.jpg)

**Daily ingestion volume over last month for a specific subscription**

```OQL
arg("").ResourceContainers
| where type =~ 'microsoft.resources/subscriptions'
| project SubscriptionName = name, subscriptionId, SolutionId = tags['SolutionID']
| join kind=inner hint.remote=right (
    find where TimeGenerated between(startofday(ago(32d))..startofday(now())) project _BilledSize, _IsBillable,  _SubscriptionId, TimeGenerated
    | where _IsBillable == true
    | summarize BillableDataBytes = sum(_BilledSize) by _SubscriptionId, bin(TimeGenerated, 1d)
    | extend DataIngestedInGB = format_bytes(BillableDataBytes, 3, "GB")
    | extend IngestionDate = bin(TimeGenerated, 1d)
    | extend subscriptionId = _SubscriptionId
) on subscriptionId
| where SubscriptionName =~ 'The-Big-MVP-Sub-2'
| sort by IngestionDate asc
| project SubscriptionName, subscriptionId, SolutionId, DataIngestedInGB, IngestionDate
```

![02](../../../../assets/images/2025/02/law-queries-02.jpg)

The billable price can be then easily calculated based on the ingested volume and price per GB.