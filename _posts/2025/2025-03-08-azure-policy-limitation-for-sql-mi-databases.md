---
title: Azure Policy Limitation for SQL MI Databases
date: 2025-03-08 18:00
author: Tao Yang
permalink: /2025/03/08/azure-policy-limitation-for-sql-mi-databases
summary:
categories:
  - Azure
tags:
  - Azure
  - Azure Policy
---

Once a SQL Managed Instance (SQL MI) is created, you can connect to the managed instance using SQL Server Management Studio (SSMS). There are 2 ways a database can be created on the SQL MI instance:

- via Azure Resource Manager API (Azure PowerShell, Azure CLI, Bicep templates or Azure Portal)
- directly on the SQL MI instance using SSMS

If the database is created via the Azure Resource Manager API, any Azure Policies that you have assigned for the SQL MI databases will apply. However, if the database is created directly on the SQL MI instance using SSMS, the Azure Policies will not apply at all.

I have discovered this behaviour around 18 months ago and reported it to the Azure SQL product team and it was acknowledged. Unfortunately to date, this limitation has not been addressed.

To demonstrate this behaviour, I created two databases on a SQL MI instance, one via the Azure Portal and the other via SSMS. We can see the DB created via ARM API on the SSMS console and vice versa.

SSMS view:

![01](../../../../assets/images/2025/03/policy-for-sql-mi-db-01.jpg)

Azure Portal view:

![02](../../../../assets/images/2025/03/policy-for-sql-mi-db-02.jpg)

I have a `DeployIfNotExists` policy to configure Diagnostic Settings for SQL MI databases. As you can see, the policy is applied to the DB created via ARM API, but not the one created via SSMS.

![03](../../../../assets/images/2025/03/policy-for-sql-mi-db-03.jpg)

![04](../../../../assets/images/2025/03/policy-for-sql-mi-db-04.jpg)

This limitation applies to all policy effects, not just `DeployIfNotExists` policies. If you have any `Deny` policies targeting SQL MI databases, they will not apply to databases created via SSMS at creation time, since the database is then visiable via a `GET` request in ARM API, the compliance scan of Azure Policy will eventually pick it up and mark it as non-compliant.

This is a security and operational risk. If your organisation is using SQL MI and would use SSMS to create databases, you should be aware of this limitation and consider other methods to enforce your policies. In the past, I have created an Azure Function App to scan the SQL MI databases and enforce the policies. This is a workaround, not ideal, since if a `Deny` policy cannot be enforced at creation time, Policy compliance scan will not fix the non-compliant resources automatically.

P.S. The Azure Policy GitHub repo has a list of known issues documented [here](https://github.com/azure/azure-policy?tab=readme-ov-file#known-issues). This behaviour with SQL MI is not listed there.