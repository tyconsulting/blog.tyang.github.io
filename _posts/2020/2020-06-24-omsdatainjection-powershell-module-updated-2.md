---
id: 7406
title: OMSDataInjection PowerShell Module Updated
date: 2020-06-24T21:23:49+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=7406
permalink: /2020/06/24/omsdatainjection-powershell-module-updated-2/
categories:
  - Azure
  - PowerShell
tags:
  - Azure
  - Log Analytics
  - Powershell
---
I’ve just pushed a small update to my old OMSDataInection PowerShell module. This module is designed to send custom logs to a Log Analytics workspace via its HTTP Data Collector API. The last update was back in 2016, when it was still called OMS.

In this version (v1.3.0), I’ve added an additional optional input parameter to allow users to add an Azure Resource Id to the log entry. This is required when the workspace is configured to use resource-context RBAC model. By specifying a valid Azure Resource Id, the user can control who has access to the log entry. This is explained in Microsoft’ docs: <a href="https://docs.microsoft.com/en-us/azure/azure-monitor/platform/manage-access#custom-logs">https://docs.microsoft.com/en-us/azure/azure-monitor/platform/manage-access#custom-logs</a>

This module is available on PowerShell Gallery: <a href="https://www.powershellgallery.com/packages/OMSDataInjection">https://www.powershellgallery.com/packages/OMSDataInjection</a>

and GitHub: <a href="https://github.com/tyconsulting/OMSDataInjection-PSModule">https://github.com/tyconsulting/OMSDataInjection-PSModule</a>