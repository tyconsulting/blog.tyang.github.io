---
title: Azure Resource Graph Query For Network Security Rules
date: 2021-12-08 16:00
author: Tao Yang
permalink: /2021/12/08/azure-resource-graph-query-for-nsg-rules
summary: Azure Resource Graph Query For Documenting Network Security Rules
categories:
  - Azure
tags:
  - Azure
  - Azure Resource Graph
  - Azure Networking
---

Few months ago, I had a requirement to produce a process to document Network Security Group (NSG) rules. Using Azure Resource Graph seemed like a logical choice.

I was lucky enough to find an existing [Resource Graph query for NSG rules](https://blog.blksthl.com/2020/10/02/list-all-nsg-security-rules-in-one-query-using-azure-resource-graph/). However, this query has many limitations. For example, it doesn't support ASGs, multiple source and destinations, multiple ports, etc.

I ended up created an updated version based on it, here's what I have created:

### List all inbound and outbound NSG rules

```OQL
resources
| where type =~ "microsoft.network/networksecuritygroups"
| join kind=leftouter (resourcecontainers | where type =='microsoft.resources/subscriptions' | project SubscriptionName=name, subscriptionId) on subscriptionId
|mv-expand rules=properties.securityRules
|extend direction=tostring(rules.properties.direction)
|extend priority=toint(rules.properties.priority)
|extend rule_name = rules.name
|extend nsg_name = name
|extend description=rules.properties.description
|extend destination_prefix=iif(rules.properties.destinationAddressPrefixes=='[]', rules.properties.destinationAddressPrefix, strcat_array(rules.properties.destinationAddressPrefixes, ","))
|extend destination_asgs=iif(isempty(rules.properties.destinationApplicationSecurityGroups), '', strcat_array(parse_json(rules.properties.destinationApplicationSecurityGroups), ","))
|extend destination=iif(isempty(destination_asgs), destination_prefix, destination_asgs)
|extend destination=iif(destination=='*', "Any", destination)
|extend destination_port=iif(isempty(rules.properties.destinationPortRange), strcat_array(rules.properties.destinationPortRanges,","), rules.properties.destinationPortRange)
|extend source_prefix=iif(rules.properties.sourceAddressPrefixes=='[]', rules.properties.sourceAddressPrefix, strcat_array(rules.properties.sourceAddressPrefixes, ","))
|extend source_asgs=iif(isempty(rules.properties.sourceApplicationSecurityGroups), "", strcat_array(parse_json(rules.properties.sourceApplicationSecurityGroups), ","))
|extend source=iif(isempty(source_asgs), source_prefix, tostring(source_asgs))
|extend source=iif(source=='*', 'Any', source)
|extend source_port=iif(isempty(rules.properties.sourcePortRange), strcat_array(rules.properties.sourcePortRanges,","), rules.properties.sourcePortRange)
|extend action=rules.properties.access
|extend subnets = strcat_array(properties.subnets, ",")
|project SubscriptionName, resourceGroup, nsg_name, rule_name, subnets, direction, priority, action, source, source_port, destination, destination_port, description, subscriptionId, id
|sort by SubscriptionName, resourceGroup asc, nsg_name, direction asc, priority asc
```

![1](../../../../assets/images/2021/12/image13.png)

This query is also stored in my [Azure Resource Graph GitHub repo](https://github.com/tyconsulting/AzureResourceGraph) ([HERE](https://github.com/tyconsulting/AzureResourceGraph/blob/master/Queries/Network.md#list-all-inbound-and-outbound-nsg-rules))