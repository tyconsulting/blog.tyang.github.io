---
id: 978
title: 'SCCM Report: Site Boundaries'
date: 2012-02-02T08:34:48+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=978
permalink: /2012/02/02/sccm-report-site-boundaries/
categories:
  - SCCM
tags:
  - SCCM
  - SCCM Reports
---
I wrote this simple report yesterday to list and search site boundaries:

Report Name: SCCM Site Boundaries

<strong>SQL Query:</strong>

```sql
SELECT distinct
v_BoundaryInfo.DisplayName AS [Boundary Name],
Case v_BoundaryInfo.BoundaryType
When 0 then 'IP Subnet'
When 1 then 'AD Site'
When 2 then 'IPV6 Prefix'
When 3 then 'IP Range'
End As 'Type',
v_BoundaryInfo.Value AS [Value],
v_BoundaryInfo.SiteCode AS [Site Code]
From v_BoundaryInfo WHERE DisplayName LIKE @BoundaryName
```

&nbsp;

<strong>Prompts:</strong>

Name: BoundaryName

Prompt Text: Boundary Name

Prompt SQL Statement:

```sql
begin
if (@__filterwildcard = '')
Select DisplayName from v_BoundaryInfo order by DisplayName
else
Select DisplayName from v_BoundaryInfo where DisplayName LIKE @__filterwildcard order by DisplayName
end
```