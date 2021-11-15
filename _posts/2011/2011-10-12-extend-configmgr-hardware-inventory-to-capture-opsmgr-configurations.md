---
id: 730
title: Extend ConfigMgr Hardware Inventory to capture OpsMgr configurations
date: 2011-10-12T18:40:52+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=730
permalink: /2011/10/12/extend-configmgr-hardware-inventory-to-capture-opsmgr-configurations/
categories:
  - SCCM
  - SCOM
tags:
  - Hardware Inventory
  - SCCM
  - SCOM
---
<strong>Download</strong>: <a href="https://blog.tyang.org/wp-content/uploads/2011/10/OpsMgr-2007-MOF.zip">MOF Extension for OpsMgr Configurations</a>

I’ve been wanting to do this for a while now and finally found some spare time for it. I want to be able to target OpsMgr (SCOM) agents and servers in ConfigMgr (SCCM) in a more granular way (i.e. all OpsMgr agents that are reporting to a OpsMgr Management Server, or all OpsMgr agents within a OpsMgr management group or All OpsMgr management servers)

Therefore, I created these extensions for <strong>configuration.mof</strong> and <strong>sms_def.mof</strong> so OpsMgr settings are captured as part of ConfigMgr client hardware inventory.

Once loaded in to ConfigMgr and after clients have retrieved new policy and performed hardware inventory, you will be able to see this in Resource Explorer:

<strong>For OpsMgr Agents:</strong>

<a href="https://blog.tyang.org/wp-content/uploads/2011/10/image13.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2011/10/image_thumb13.png" alt="image" width="580" height="429" border="0" /></a>

<strong>For OpsMgr Servers:</strong>

<a href="https://blog.tyang.org/wp-content/uploads/2011/10/image14.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2011/10/image_thumb14.png" alt="image" width="580" height="407" border="0" /></a>

<strong>Note:</strong> As always, make sure backup both mof files before editing them. once saved, monitor dataldr.log to make sure they are successfully compiled.

Please refer to my <a href="https://blog.tyang.org/2011/10/09/clean-up-old-hardware-inventory-data/">previous blog </a>if you decide to remove this mof extention from your ConfigMgr environment.

<strong>More Reading about ConfigMgr Hinv (Hardware Inventory):</strong>

<a href="http://technet.microsoft.com/en-us/library/bb632896.aspx">Technet: About MOF Files Used by Hardware Inventory</a>

<a href="http://blogs.technet.com/b/smsandmom/archive/2007/08/30/how-to-extend-your-hardware-inventory-using-the-sms-def-mof-file.aspx">Technet Blog: How to Extend Your Hardware Inventory Using the SMS_DEF.MOF File</a>

<strong>Collection Query Samples:</strong>

All OpsMgr agents in Management Group TYANG:

```sql
select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_CUSTOM_OPSMGR_2007_AGENT_SETTING_2_0 on SMS_G_System_CUSTOM_OPSMGR_2007_AGENT_SETTING_2_0.ResourceId = SMS_R_System.ResourceId where SMS_G_System_CUSTOM_OPSMGR_2007_AGENT_SETTING_2_0.ManagementGroup = "TYANG"
```

All OpsMgr agents managed by OpsMgr Management Server SCOM02:

```sql
select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_CUSTOM_OPSMGR_2007_AGENT_SETTING_2_0 on SMS_G_System_CUSTOM_OPSMGR_2007_AGENT_SETTING_2_0.ResourceId = SMS_R_System.ResourceId where SMS_G_System_CUSTOM_OPSMGR_2007_AGENT_SETTING_2_0.ManagementServer = "SCOM02.corp.tyang.org"
```

All OpsMgr Management Servers:

```sql
select *  from  SMS_R_System inner join SMS_G_System_CUSTOM_OPSMGR_2007_SERVER_SETTING_2_0 on SMS_G_System_CUSTOM_OPSMGR_2007_SERVER_SETTING_2_0.ResourceId = SMS_R_System.ResourceId where SMS_G_System_CUSTOM_OPSMGR_2007_SERVER_SETTING_2_0.IsServer = 1
```
