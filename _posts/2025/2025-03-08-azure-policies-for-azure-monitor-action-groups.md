---
title: Azure Policies for Azure Monitor Action Groups
date: 2025-03-08 15:00
author: Tao Yang
permalink: /2025/03/08/azure-policies-for-azure-monitor-action-groups
summary:
categories:
  - Azure
tags:
  - Azure
  - Azure Monitor
  - Azure Policy
---

I am currently working on implementing some monitoring solutions in a customer's Azure environment. I only realised yesterday that Azure does not offer any built-in Azure Policy definitions for managing Azure Monitor Action Groups.

![01](../../../../assets/images/2025/03/action-group-policies-01.jpg)

When creating an action group, you can configure zero or more notifications as well as actions.

We need to make sure when alerts are triggered, The following controls should be put in place to prevent data exfiltration and enhance network transport security.

**Emails are only sent to authorised email addresses.**

Only email domains managed by your organisation should be used. Personal email addresses or emails of another organisation should be prohibited.

**SMS messages are only sent to authorised mobile phone numbers.**
The phone numbers used to receive SMS messages should belong to appropriate personnel. Phone numbers external to your organisation or numbers of other countries should be restricted.

**Actions that trigger another Azure resource (Azure Automation Runbook, Event Hub Namspace, Azure Function App and Azure Logic App) are only triggering resources within the same subscription or been explicitly added to the allowed list of targets.**

When the organisation does not separate Azure environments into different Entra ID tenants, this will ensure we are not potentially sending production alert data to non-production environments.

It will also allow the organisation to control which azure resources can be used to receive alert data if they are indeed located in different subscriptions of the action group.

**Only allowed Webhooks can be used to receive alert data**

The Webhook URL can belong to anyone and located anywhere in the world. It should be controlled so only allowed Webhook URLs can be used in action groups.

**Only allow Webhooks that use HTTPS**

Unencrypted data using `HTTP` protocol should be prohibited.

Fortunately the Azure Policy aliases for these properties exist already. I was able to leverage them and created the following policies and placed them in [my azure policy GitHub repo](https://github.com/tyconsulting/azurepolicy/tree/master/policy-definitions/action-groups):

- [Restrict Azure Monitor Action Group Send Email Notification to External Email Addresses](https://github.com/tyconsulting/azurepolicy/blob/master/policy-definitions/action-groups/pol-ag-deny-external-email-notification.json)
- [Restrict Azure Monitor Action Group Send SMS Notification to Unauthorized Phone Numbers](https://github.com/tyconsulting/azurepolicy/blob/master/policy-definitions/action-groups/pol-ag-deny-unauthorized-sms-notification-recipients.json)
- [Restrict Azure Monitor Action Group Trigger Actions to Cross-Subscription Azure Automation or not on the Allowed List](https://github.com/tyconsulting/azurepolicy/blob/master/policy-definitions/action-groups/pol-ag-deny-unauthorized-azure-automation-actions.json)
- [Restrict Azure Monitor Action Group Trigger Actions to Cross-Subscription Event Hubs or not on the Allowed List](https://github.com/tyconsulting/azurepolicy/blob/master/policy-definitions/action-groups/pol-ag-deny-unauthorized-event-hub-actions.json)
- [Restrict Azure Monitor Action Group Trigger Actions to Cross-Subscription Function Apps or not on the Allowed List](https://github.com/tyconsulting/azurepolicy/blob/master/policy-definitions/action-groups/pol-ag-deny-unauthorized-function-app-actions.json)
- [Restrict Azure Monitor Action Group Trigger Actions to Cross-Subscription Logic Apps or not on the Allowed List](https://github.com/tyconsulting/azurepolicy/blob/master/policy-definitions/action-groups/pol-ag-deny-unauthorized-logic-app-actions.json)
- [Restrict Azure Monitor Action Group Trigger Actions to Webhooks that are not on the Allowed List](https://github.com/tyconsulting/azurepolicy/blob/master/policy-definitions/action-groups/pol-ag-deny-unauthorized-webhooks.json)
- [Restrict Azure Monitor Action Group Trigger Actions to Webhooks that are not using HTTPS](https://github.com/tyconsulting/azurepolicy/blob/master/policy-definitions/action-groups/pol-ag-deny-http-webhooks.json)

With the policies for restricting cross-subscription function app, logic app, event hub and automation runbooks, the definitions provide an array parameter to allow a list of cross-subscription resources. You can use the `allowedAutomationAccounts`, `allowedEventHubNamespaces`, `allowedFunctionApps` and `allowedLogicApps` parameters in its respective policy to approve the use of any of these resources that are located in other subscriptions.

In the portal UI, you can also see the ITSM connection and Secure Webhook as available actions. I did not bother to develop policies for ITSM connections because according to the [documentation](https://learn.microsoft.com/azure/azure-monitor/alerts/itsmc-overview#itsm-integration-workflow), it is already deprecated.

With regards to Secure Webhook, the ARM JSON configuration is the same as normal webhook, the only difference is that you will need to specify an EntraID application's object ID and set `useAadAuth` to true. Therefore the policies for the Webhook Actions also apply to Secure Webhooks.
