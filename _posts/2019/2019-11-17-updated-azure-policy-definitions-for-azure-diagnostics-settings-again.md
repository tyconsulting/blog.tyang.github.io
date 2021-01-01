---
id: 7210
title: Updated Azure Policy Definitions for Azure Diagnostics Settings Again
date: 2019-11-17T20:41:41+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=7210
permalink: /2019/11/17/updated-azure-policy-definitions-for-azure-diagnostics-settings-again/
spay_email:
  - ""
categories:
  - Azure
tags:
  - Azure
  - Azure Policy
---
I firstly published a set of policy definitions for configuring Azure resource diagnostics settings last year. You can find the original post here: <a href="https://blog.tyang.org/2018/11/19/configuring-azure-resources-diagnostic-log-settings-using-azure-policy/">https://blog.tyang.org/2018/11/19/configuring-azure-resources-diagnostic-log-settings-using-azure-policy/</a>. I have been keeping them up-to-date since then.

I’ve updated the Policy Definitions for the resource Diagnostic Settings again today with the following updates:

<ul>
    <li>New Policies added:
<ul>
    <li>Azure Bastion Hosts</li>
    <li>Azure AD Domain Services</li>
</ul>
</li>
    <li>Existing Policy Updated:
<ul>
    <li>Azure App Service – with the support for the additional logs announced at Ignite 2019. Also the name of the policy file has changed.</li>
</ul>
</li>
    <li>Removed (since they were incorrectly written in the first place and never worked):
<ul>
    <li>VM</li>
    <li>VMSS</li>
</ul>
</li>
</ul>

You can find the latest version on my GitHub repo: <a href="https://github.com/tyconsulting/azurepolicy/tree/master/policy-definitions/resource-diagnostics-settings">https://github.com/tyconsulting/azurepolicy/tree/master/policy-definitions/resource-diagnostics-settings</a>