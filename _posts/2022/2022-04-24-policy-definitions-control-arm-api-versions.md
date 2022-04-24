---
title: Azure Policy Definitions for Controlling ARM API versions
date: 2022-04-24 16:00
author: Tao Yang
permalink: /2022/04/24/policy-definitions-control-arm-api-versions/
summary:
categories:
  - Azure
tags:
  - Azure
  - Azure Policy
---

In a previous engagement, we had requirements to control ARM API versions used to create / update Azure resources. To address these requirements, I have developed 3 policy definitions that can be used to:

1. [Control usage of preview versions of Azure Resource Manager REST APIs](https://github.com/tyconsulting/azurepolicy/tree/master/policy-definitions/arm-api-versions/control-preview-api)
2. [Required minimum Azure Resource Manager REST API version for a resource type](https://github.com/tyconsulting/azurepolicy/tree/master/policy-definitions/arm-api-versions/required-minimum-api-version)
3. [Restrict to specific Azure Resource Manager REST API versions for a resource type](https://github.com/tyconsulting/azurepolicy/tree/master/policy-definitions/arm-api-versions/restrict-to-specific-api-version)

With new features added the newer ARM API versions all the time, you may have requirements to enforce users only use approved versions for particular resource types, or limit users from using preview API versions.

I totally forgot about these policy definitions that I wrote almost 2 years ago. I thought I should publish them.
