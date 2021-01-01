---
id: 7493
title: October 2020 Update for Azure Diagnostic Settings Policy Definitions
date: 2020-10-12T22:09:55+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=7493
permalink: /2020/10/12/october-2020-update-for-azure-diagnostic-settings-policy-definitions/
spay_email:
  - ""
categories:
  - Azure
tags:
  - Azure
  - Azure Policy
---
Over the last couple years, I’ve been maintaining a set of custom Azure Policy Definitions for deploying Diagnostic Settings for applicable Azure services. You can find them in my GitHub repo: <a title="https://github.com/tyconsulting/azurepolicy/tree/master/policy-definitions/resource-diagnostics-settings" href="https://github.com/tyconsulting/azurepolicy/tree/master/policy-definitions/resource-diagnostics-settings">https://github.com/tyconsulting/azurepolicy/tree/master/policy-definitions/resource-diagnostics-settings</a>

I’ve updated them again over the last couple of weeks. This is what’s changed:

<strong>Diagnostic Settings Policies:</strong>

<ol>
    <li>Minor bug fix for the Diagnostic Settings policies for Azure Automation Account</li>
    <li>Updated policies for Event Hub – included additional log categories that weren’t available when the policy was firstly written.</li>
    <li>Also updated policies for Recovery Services Vault – added additional log categories</li>
    <li>Updated policies for SQL Managed Instance – added additional log categories</li>
    <li>Updated policies for SQL database – added detection to exclude master db and Synapse (formally SQL DW) since Synapse has different log categories than normal SQL DB. Also updated metrics and log categories.</li>
    <li>New Policies for SQL Managed Databases (DBs on Managed Instances)</li>
    <li>New policies for Azure Synapse SQL Pool (Formally SQL DB)</li>
    <li>New policies for Azure Log Analytics Workspaces itself – Log Analytics can now be configured to produce audit logs</li>
</ol>

<strong>SQL PaaS Server Auditing Settings Policies</strong>

In addition to the Diagnostics Settings policy updates, I have also created a set of brand new policy for Azure SQL Server (PaaS) Auditing Settings with destination to Log Analytics or Event Hub (at the time of writing, it’s still in preview).

<a href="https://blog.tyang.org/wp-content/uploads/2020/10/image.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2020/10/image_thumb.png" alt="image" width="538" height="289" border="0" /></a>

To enable SQL Server auditing for Log Analytics or Event Hub, there are 2 components needs to be configured:

<ol>
    <li>Enable SQL Server Auditing setting with the audit actions and groups of your choice (the audit actions and groups can only be defined using code, not available via the portal UI, you can find the full list on this article: <a href="https://docs.microsoft.com/en-us/sql/relational-databases/security/auditing/sql-server-audit-action-groups-and-actions?view=sql-server-ver15&amp;&amp;WT.mc_id=DOP-MVP-5000997">SQL Server Audit Action Groups and Actions</a>).</li>
    <li>Enable Diagnostics Settings on for the master database.</li>
</ol>

the SQL Server Auditing settings policies are located in a different folder in the same GitHub repo: <a title="https://github.com/tyconsulting/azurepolicy/tree/master/policy-definitions/sql-server-auditing" href="https://github.com/tyconsulting/azurepolicy/tree/master/policy-definitions/sql-server-auditing">https://github.com/tyconsulting/azurepolicy/tree/master/policy-definitions/sql-server-auditing</a>