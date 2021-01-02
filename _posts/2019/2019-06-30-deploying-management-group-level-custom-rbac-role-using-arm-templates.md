---
id: 7119
title: Deploying Management Group Level Custom RBAC Role Using ARM Templates
date: 2019-06-30T17:23:01+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=7119
permalink: /2019/06/30/deploying-management-group-level-custom-rbac-role-using-arm-templates/
categories:
  - Azure
tags:
  - ARM Template
  - Azure
---
Although custom RBAC roles can be deployed using subscription-level ARM templates, they are actually tenant level resources. When you deploy a custom RBAC role using a subscription-level template for the first time, it will work, but if you deploy the same custom role again to another subscription within the same tenant, the deployment will fail because the role already exists. To make the role available in additional subscriptions, you must modify the assignment scope of the role definition, making it available to other subscriptions.

Recently, Microsoft has made custom RBAC roles available on Management Groups level. This greatly simplified the process of deploying custom RBAC roles in large environments that have many subscriptions. Once you have deployed the role definition and made it available for a management group, it automatically becomes available for all subscriptions under the management group hierarchy. Although at the time of writing this blog post, we still cannot deploy ARM templates to management groups, but we can now use subscription-level ARM template to deploy role definitions and make them available on the management group levels.

Last week, I needed to deploy a custom role for enabling referencing key vault during ARM template deployments. the role is documented here: <a href="https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-manager-keyvault-parameter#grant-access-to-the-secrets">https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-manager-keyvault-parameter#grant-access-to-the-secrets</a>

I managed to deploy the role and make it available on the tenant root MG using the following ARM template:

<pre language="JSON">{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {},
  "variables": {
    "kvARMDeploymentOperatorRoleId": "[guid('customRole-kv-arm-deployment-operator')]"
  },
  "resources": [
    {
      "type": "Microsoft.Authorization/roleDefinitions",
      "name": "[variables('kvARMDeploymentOperatorRoleId')]",
      "apiVersion": "2017-05-01",
      "dependsOn": [],
      "properties": {
        "roleName": "Key Vault resource manager template deployment operator",
        "id": "[variables('kvARMDeploymentOperatorRoleId')]",
        "IsCustom": true,
        "description": "Lets you deploy a resource manager template with the access to the secrets in the Key Vault.",
        "permissions": [
          {
            "actions": [
              "Microsoft.KeyVault/vaults/deploy/action"
            ],
            "notActions": []
          }
        ],
        "assignableScopes": [
          "[subscription().id]",
          "[concat('providers/Microsoft.Management/managementGroups/', subscription().tenantId)]"
        ]
      }
    }
  ]
}

```

Few things to note here:

<ol>
    <li>You can simply deploy this subscription-level template to any subscription in your tenant. The assignment scope includes the tenant root MG, which covers all subscriptions in your tenant.</li>
    <li>I had to include [subscription().id] in the assignableScope otherwise the deployment will fail.</li>
    <li>During my tests, and I think it’s a known portal bug at this stage – after the role is deployed, in Azure portal, you may not be able to see the role definition in a subscription (other than the one you deployed the template to). However, you can still use PowerShell or ARM REST API to view and assign the role.</li>
</ol>