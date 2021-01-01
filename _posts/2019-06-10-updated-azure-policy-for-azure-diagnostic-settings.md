---
id: 7089
title: Updated Azure Policy for Azure Diagnostic Settings
date: 2019-06-10T16:16:46+10:00
author: Tao Yang
layout: post
guid: https://blog.tyang.org/?p=7089
permalink: /2019/06/10/updated-azure-policy-for-azure-diagnostic-settings/
categories:
  - Azure
tags:
  - Azure
  - Azure Policy
---
Few months ago, I published a set of Azure Policy definitions to configure Azure resources diagnostic settings. You can find the original post here: <a href="https://blog.tyang.org/2018/11/19/configuring-azure-resources-diagnostic-log-settings-using-azure-policy/">https://blog.tyang.org/2018/11/19/configuring-azure-resources-diagnostic-log-settings-using-azure-policy/</a>. The definitions were offered in the form of an ARM template.

Since then, I have updated these policies, with the following updates:

<strong>Additional policies for connecting Diagnostic Settings to Azure Event Hub</strong>

In addition to policies to connect diagnostic settings to Log Analytics, I have added another set of policies to connect diagnostic settings of applicable resources to Azure Event Hubs

<strong>Added ExistenceCondition in policy definitions</strong>

ExistenceCondition detects if the resource you are trying to deploy via Azure Policy already exists. This is helpful if your Azure resource has already got diagnostic settings connected. In this condition, the policy definition will skip the deployment defined in DeployIfNotExist effect. You can read more about ExistenceCondition here: <a href="https://docs.microsoft.com/en-us/azure/governance/policy/concepts/effects#deployifnotexists">https://docs.microsoft.com/en-us/azure/governance/policy/concepts/effects#deployifnotexists</a>

<strong>Various bug fixes</strong>

I have decided not to maintain the ARM template for these policies, because it is too big (hard to maintain), and currently you can not deploy ARM templates to management groups. The updated and new definitions come in the format of individual definition files.

<strong>You can find them here: <a href="https://github.com/tyconsulting/azurepolicy/tree/master/policy-definitions/resource-diagnostics-settings">https://github.com/tyconsulting/azurepolicy/tree/master/policy-definitions/resource-diagnostics-settings</a></strong>

To bulk deploy them, I recommend you to use <a href="https://github.com/tyconsulting/azurepolicy/blob/master/scripts/deploy-policyDef.ps1" target="_blank" rel="noopener noreferrer">deploy-policyDef.ps1</a> script, which I covered my my previous post: <a href="https://blog.tyang.org/2019/05/19/deploying-azure-policy-definitions-via-azure-devops-part-1/">https://blog.tyang.org/2019/05/19/deploying-azure-policy-definitions-via-azure-devops-part-1/</a>

I have also added two Policy Initiative definitions for these policies: <a href="https://github.com/tyconsulting/azurepolicy/tree/master/initiative-definitions/resource-diagnostics-settings">https://github.com/tyconsulting/azurepolicy/tree/master/initiative-definitions/resource-diagnostics-settings</a>. To deploy these initiative definitions, you <strong>MUST</strong> use my <a href="https://github.com/tyconsulting/azurepolicy/blob/master/scripts/deploy-policySetDef.ps1" target="_blank" rel="noopener noreferrer">deploy-policySetDef.ps1</a> script, which is explained in the same post.