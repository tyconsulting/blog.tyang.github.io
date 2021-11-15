---
id: 5799
title: OMS Search Queries to Extract Rules from Various Assessment Solutions
date: 2016-12-16T15:09:19+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=5799
permalink: /2016/12/16/oms-search-queries-to-extract-rules-from-various-assessment-solutions/
categories:
  - OMS
tags:
  - OMS
---
Currently in OMS, there are 3 assessment solutions for various Microsoft products. They are:

 * Active Directory Assessment Solution
 * SQL Server Assessment Solution
 * SCOM Assessment Solution

Few days ago, I needed to export the assessment rules from each solution and handover to a customer (so they know exactly what areas are being assessed). So I developed the following queries to extract the details of the assessment rules:

**AD Assessment Solution query:**

```text
Type=ADAssessmentRecommendation | Dedup Recommendation | select FocusArea,AffectedObjectType,Recommendation,Description | Sort FocusArea
```

**SQL Server Assessment Solution query:**

```text
Type=SQLAssessmentRecommendation | Dedup Recommendation | select FocusArea,AffectedObjectType,Recommendation,Description | Sort FocusArea
```

**SCOM Assessment Solution query:**

```text
Type=SCOMAssessmentRecommendation | Dedup Recommendation | select FocusArea,AffectedObjectType,Recommendation,Description | Sort FocusArea
```
In order to use these queries, you need to make sure these solutions are enabled and already collecting data. You may also need to change the search time window to at least last 7 days because by default, assessment solutions only run once a week.

Once you get the result in the OMS portal, you can easily export it to CSV file by hitting the Export button.