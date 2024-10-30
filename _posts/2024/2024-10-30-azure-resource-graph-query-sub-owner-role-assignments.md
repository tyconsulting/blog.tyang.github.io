---
title: Azure Resource Graph Query for Subscription Owner Role Assignments
date: 2024-10-30 17:00
author: Tao Yang
permalink: /2024/10/30/azure-resource-graph-query-sub-owner-role-assignments
summary: Azure Resource Graph Query to count the Owner role assignments on a subscription including inherited role assignments from parent management groups.
categories:
  - Azure
tags:
  - Azure
  - Azure Resource Graph
---

In the current customer engagement, we wanted to replace the Microsoft Defender for Cloud recommendation `A maximum of 3 owners should be designated for subscriptions` with an Azure Monitor Alert rule. This is because this defender for cloud assessment cannot be customized (in terms of increase or decrease the threshold of 3). We want to [leverage Azure Resource Graph in the alert rule](https://learn.microsoft.com/en-us/azure/governance/resource-graph/alerts-query-quickstart?tabs=azure-resource-graph) by configuring the alert rule to run a pre-defined Azure Resource Graph query on a schedule.

This afternoon my colleague asked me to help with the Resource Graph query for this alert rule, since he couldn't figure out how to include the inherited role assignments for the subscription. There are many example queries I could find on the Internet, but I could only find queries that have the role assignment scoped to the subscription itself. Parent management groups and the root scope `/` are not included in any of the examples I could find.

I then spent the entire afternoon trying to figure out if it's even possible to do this natively all within Azure Resource Graph. In the end, I have figured it out. This must be one of the hardest queries I have every developed. I have tested this in my lab, the results seemed matching what I see on the portal.

The query can be found in [my GitHub repo HERE](https://github.com/tyconsulting/AzureResourceGraph/blob/master/Queries/RoleAssignment.md#list-all-owner-role-assignments-by-subscriptions-including-inherited-assignments).

Query Results:
![01](../../../../assets/images/2024/10/arg-sub-owner-01.jpg)

Portal:
![02](../../../../assets/images/2024/10/arg-sub-owner-02.jpg)

If you want to see the details of each role assignment, just remove the last `summarize` line from the query.

The role definition ID for the owner role is hardcoded in the query. you can change it to other roles if required.
