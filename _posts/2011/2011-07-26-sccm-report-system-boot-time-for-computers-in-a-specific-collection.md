---
id: 610
title: 'SCCM Report: &ldquo;System Boot Time for Computers in a Specific Collection'
date: 2011-07-26T11:28:13+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=610
permalink: /2011/07/26/sccm-report-system-boot-time-for-computers-in-a-specific-collection/
categories:
  - SCCM
tags:
  - SCCM Reports
---
This is a report I wrote last week:

## System Boot Time for Computers in a Specific Collection

**SQL Statement:**
```sql
select  distinct
v_R_System_Valid.ResourceID,
v_R_System_Valid.Netbios_Name0 AS [Computer Name],
V_GS_OPERATING_SYSTEM.LastBootUpTime0 AS [Last Boot Time],
v_R_System_Valid.Resource_Domain_OR_Workgr0 AS [Domain/Workgroup],
v_Site.SiteCode as [SMS Site Code]
from v_R_System_Valid
inner join v_GS_OPERATING_SYSTEM on (v_GS_OPERATING_SYSTEM.ResourceID = v_R_System_Valid.ResourceID)
inner join v_FullCollectionMembership on (v_FullCollectionMembership.ResourceID = v_R_System_Valid.ResourceID)
left  join v_Site on (v_FullCollectionMembership.SiteCode = v_Site.SiteCode)
Where v_FullCollectionMembership.CollectionID = @CollectionID
Order by v_R_System_Valid.Netbios_Name0
```

**Prompts:**

* **Name**: CollectionID
* **Prompt Text**: Collection

**Prompt SQL Statement:**

```sql
begin
if (@__filterwildcard = '')
select v_Collection.CollectionID, v_Collection.Name from v_Collection order by v_Collection.Name
else
select v_Collection.CollectionID, v_Collection.Name from v_Collection
WHERE v_Collection.CollectionID like @__filterwildcard
order by v_Collection.Name
end
```


Please note the system boot time is collected from LastBootUpTime in Win32_OperatingSystem via SCCM client hardware inventory. Therefore the information is as current as SCCM client’s last hardware inventory.

**Example:**

![1](../../../../wp-content/uploads/2011/07/image6.png)
