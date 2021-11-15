---
id: 5222
title: OMS Alerting Webhook Support
date: 2016-03-03T14:32:58+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=5222
permalink: /2016/03/03/oms-alerting-webhook-support/
categories:
  - OMS
tags:
  - Azure Automation
  - OMS
---

## Introduction

Few weeks ago, OMS Alerting has introduced a new feature that enables the alert to trigger a webhook:

<a href="https://blog.tyang.org/wp-content/uploads/2016/03/image.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/03/image_thumb.png" alt="image" width="340" height="433" border="0" /></a>

This feature can be enabled with or without the existing 2 actions (email and Azure Automation runbook remediation).

As we all know, the existing Azure Automation runbook remediation also leverages webhooks to trigger Azure Automation runbooks. I have previously posted a blog on <a href="https://blog.tyang.org/2015/12/03/oms-alerting-walkthrough/">OMS Alerting Walkthrough</a>, and also presented Introduction to OMS Alerting in Windows Management User Group Netherlands, you can watch the recording on YouTube: <a title="https://www.youtube.com/watch?v=JEZZzIj66uU" href="https://www.youtube.com/watch?v=JEZZzIj66uU">https://www.youtube.com/watch?v=JEZZzIj66uU</a>

So, why do we need this new webhook feature? Comparing with the Azure Automation runbook remediation, I believe it has the following benefits:

* Ability to trigger other 3rd party systems that support Webhooks
* Ability to trigger other Azure Automation runbooks from other Azure Automation accounts.
* Ability to share webhooks with multiple alert rules
* Ability to configure webhooks with longer (or shorter) expiration date
* Ability to customize the JSON payload (that will be sent to the destination system as HTTP body via webhooks).

## Limitation on Current Azure Automation Runbook Remediation

As I mentioned in the previous post, when OMS Alerting triggers an Azure Automation runbook, it passes the following information to the runbook as part of the search results in request body:

* Id
* metadata
* value (OMS search result)

In my opinion, sometimes depending on specific scenarios, this may not be enough. i.e. when I create an alert and specify the alert threshold to be less than 1 (which means 0). the value (OMS search result) will be null.

<a href="https://blog.tyang.org/wp-content/uploads/2016/03/image-1.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; margin: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/03/image_thumb-1.png" alt="image" width="244" height="221" border="0" /></a>

and since the actual search query used by the OMS alert rule is not passed to the Azure Automation runbook, this makes our life a little bit harder when coding the runbooks.

Let me use a real example to explain this limitation again. For example, if I am creating an OMS alert for a computer that has not sent data to OMS in 15 minutes – which is equivalent to the "missing heartbeat" alert in SCOM, I’d use a simple OMS search query such as "Computer=’<Computer-FQDN>’" and set the threshold to "Less Than 1":

<a href="https://blog.tyang.org/wp-content/uploads/2016/03/image-2.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/03/image_thumb-2.png" alt="image" width="458" height="303" border="0" /></a>

In this case, a critical piece of information we need for the runbook - the computer name only exists in the search query used by the OMS alert rule. When the OMS alert is raised and the runbook is triggered, since the webhook request body does not contain the search query and only contains an empty OMS search result in "Values" property. The computer name is not passed into the runbook as part of the input parameters. The runbook will not be able to know the computer name that is missing the heartbeat, thus difficult to design the runbook for alert remediation. The only walk around I can think of is to create a separate OMS alert rule and a separate runbook for each computer that you want to detect the missing heartbeat.

## Benefit of Using the Webhook Feature

With the new webhook support, I’d glad that we are able to pass additional parameters as part of the webhook request body. These additional parameters can potentially make the runbooks more flexible. By default, other than the OMS search result itself, it also passes the following information:

* Workspace ID
* Alert Rule Name
* **Search Query (!!)**
* Search Interval Start Time UTC
* Search Interval End Time UTC
* Alert Threshold Operator
* Alert Threshold Value
* Result Count
* Search Interval In Seconds
* Link To Search Results

i.e. this is what’s been passed via the webhook:

<a href="https://blog.tyang.org/wp-content/uploads/2016/03/image-3.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/03/image_thumb-3.png" alt="image" width="691" height="485" border="0" /></a>

If I copy and paste this to Notepad++ and format it using the JSON plugin, we can easily identify the additional information been passed into the runbook:

<a href="https://blog.tyang.org/wp-content/uploads/2016/03/image-4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/03/image_thumb-4.png" alt="image" width="601" height="607" border="0" /></a>

Additionally, we are also able to customize the JSON payload if we only want to send a subset of above listed information through the webhook. I have reached out to the OMS product team, and I was told the syntax is:

```json
{
  "WorkspaceId": "#workspaceid",
  "AlertRuleName": "#alertrulename",
  "SearchQuery": "#searchquery",
  "SearchIntervalStartTimeUtc": "#searchintervalstarttimeutc",
  "SearchIntervalEndtimeUtc": "#searchintervalendtimeutc",
  "AlertThresholdOperator": "#thresholdoperator",
  "AlertThresholdValue": "#thresholdvalue",
  "ResultCount": "#searchresultcount",
  "SearchIntervalInSeconds": "#searchinterval",
  "LinkToSearchResults": "#linktosearchresults"
}
```

**<span style="color: #ff0000;">4th March 2016 Update:</span>**

After this post has been published, Anand Balasubramanian from OMS product team has provided me another JSON payload example and asked me to add to this post. The example below can be used to post the OMS alert to a Slack channel:

```json
{
  "attachments": [
    {
      "title":"OMS Alerts Custom Payload",
      "fields": [
        {
          "title": "Alert Rule Name",
          "value": "#alertrulename"
        },
        {
          "title": "Link To SearchResults",
          "value": "<#linktosearchresults|OMS Search Results>"
        },
        {
          "title": "Searchquery",
          "value": "#searchquery"
        },
      ],
      "color": "#F35A00"
    }
  ]
}
```

## Summary

To summarize, I am very glad that we now have the webhook capability for OMS alert rules. Although it requires more configurations, this is definitely more flexible than the original Azure Automation runbook remediation feature in OMS Alerting.

Additionally, Ravi Kiran the OMS automation team has also written a blog on how to parse JSON output for Azure Alerts, which you may also find helpful: <a href="https://azure.microsoft.com/en-us/blog/using-azure-automation-to-take-actions-on-azure-alerts/">https://azure.microsoft.com/en-us/blog/using-azure-automation-to-take-actions-on-azure-alerts/</a>.