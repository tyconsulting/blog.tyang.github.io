---
title: Minimum Permissions for Azure Policy Template Deployment
date: 2022-12-18 00:00
author: Tao Yang
permalink: /2022/12/18/minimum-permissions-for-azure-policy-template-deployment/
summary: Minimum Role Permissions for Azure Policy Deployment via ARM or Bicep templates.
categories:
  - Azure
tags:
  - Azure
  - Azure Policy

---

When comes into security, a general rule of thumb is to ALWAYS use the least privilege principle when assigning permissions. I rarely come across customers that agrees to grant `Owner` role to service principals we use for our Azure Infrastructure as Code (IaC) pipelines. In this post, I will show you the minimum permissions required to deploy Azure Policy resources.

Azure provides a built-in role definition called `Resource Policy Contributor`. It has enough permissions to create Azure policy related resources. Here is the role definition in JSON:

```json
{
    "id": "/providers/Microsoft.Authorization/roleDefinitions/36243c78-bf99-498c-9df9-86d9f8d28608",
    "properties": {
        "roleName": "Resource Policy Contributor",
        "description": "Users with rights to create/modify resource policy, create support ticket and read resources/hierarchy.",
        "assignableScopes": [
            "/"
        ],
        "permissions": [
            {
                "actions": [
                    "*/read",
                    "Microsoft.Authorization/policyassignments/*",
                    "Microsoft.Authorization/policydefinitions/*",
                    "Microsoft.Authorization/policyexemptions/*",
                    "Microsoft.Authorization/policysetdefinitions/*",
                    "Microsoft.PolicyInsights/*",
                    "Microsoft.Support/*"
                ],
                "notActions": [],
                "dataActions": [],
                "notDataActions": []
            }
        ]
    }
}
```

When creating policy assignments for policy definitions with `DeployIfNotExists` (DINE) or `Modify` effects, you will also need to create necessary role assignments for the Policy Assignment's Managed Identity so the Policy Assignments have enough permissions to deploy / modify resources. Therefore in addition to the `Resource Policy Contributor` role, generally we also need to grant `User Access Administrator` role to the users, groups or Services Principals that are responsible for creating the policy resources. Here is the `User Access Administrator` role definition in JSON:

```json
{
    "id": "/providers/Microsoft.Authorization/roleDefinitions/18d7d88d-d35e-4fb5-a5c3-7773c20a72d9",
    "properties": {
        "roleName": "User Access Administrator",
        "description": "Lets you manage user access to Azure resources.",
        "assignableScopes": [
            "/"
        ],
        "permissions": [
            {
                "actions": [
                    "*/read",
                    "Microsoft.Authorization/*",
                    "Microsoft.Support/*"
                ],
                "notActions": [],
                "dataActions": [],
                "notDataActions": []
            }
        ]
    }
}
```

If you have above mentioned `Resource Policy Contributor` and `User Access Administrator` roles assigned, you should have enough permissions to create policy resources via the Azure portal. However, if you try to deploy policy resources via an ARM or Bicep template, you will get an error like this:

```text
New-AzManagementGroupDeployment: 5:03:16 pm - Error: Code=AuthorizationFailed; Message=The client '8480c4fa-d71b-4e7c-ae37-7c37c0972023' with object id '8480c4fa-d71b-4e7c-ae37-7c37c0972023' does not have authorization to perform action 'Microsoft.Resources/deployments/validate/action' over scope '/providers/Microsoft.Management/managementGroups/CONTOSO/providers/Microsoft.Resources/deployments/policyDef' or the scope is invalid. If access was recently granted, please refresh your credentials.
New-AzManagementGroupDeployment: The deployment validation failed
```

The reason for this error is because there is a gap in the built-in `Resource Policy Contributor` role definition. Unlike other contributor roles, the `Resource Policy Contributor` role does not have permissions in the `Microsoft.Resources/deployments` namespace. For example, let's compare it with the Storage Account Contributor role:

![01](../../../../assets/images/2022/12/policyPermissions01.jpg)

I'm not exactly sure what is the reason behind this design decision, it's strange to me this is missing even when some reader roles have this permission. Since most of the time we will be deploying Policy resources to a Management Group scope and at the time of writing this article, assigning custom role definitions on a Management Group scope is still in preview, we had to stick with only using built-in roles in customer's environments. When we firstly discovered this limitation at a customer's environment, my friend and colleague [Ahmad Abdalla] (https://github.com/ahmadabdalla) and I have decided to add another role definition into the mix. We have picked the `Lab Service Reader` role because it has the missing piece of the puzzle. Here's the role definition in JSON:

```json
{
    "id": "/providers/Microsoft.Authorization/roleDefinitions/2a5c394f-5eb7-4d4f-9c8e-e8eae39faebc",
    "properties": {
        "roleName": "Lab Services Reader",
        "description": "The lab services reader role",
        "assignableScopes": [
            "/"
        ],
        "permissions": [
            {
                "actions": [
                    "Microsoft.LabServices/*/read",
                    "Microsoft.Authorization/*/read",
                    "Microsoft.Resources/deployments/*",
                    "Microsoft.Resources/subscriptions/resourceGroups/read"
                ],
                "notActions": [],
                "dataActions": [],
                "notDataActions": []
            }
        ]
    }
}
```

We picked this role because it's only a reader role, and the customer does not user Azure Lab Services hence there is no impact and resistance from customer's cloud security team.

Once I have the `Lab Service Reader` role assigned, my template deployed started to work:

![02](../../../../assets/images/2022/12/policyPermissions02.jpg)
![03](../../../../assets/images/2022/12/policyPermissions03.jpg)

**TL;DR:**
In order to deploy Azure Policy resources via ARM or Bicep templates, the Azure AD identity that performs the deployment needs to have the following built-in roles assigned as a minimum:

- Resource Policy Contributor (/providers/Microsoft.Authorization/roleDefinitions/36243c78-bf99-498c-9df9-86d9f8d28608)
- User Access Administrator (/providers/Microsoft.Authorization/roleDefinitions/18d7d88d-d35e-4fb5-a5c3-7773c20a72d9)
- Lab Services Reader (/providers/Microsoft.Authorization/roleDefinitions/2a5c394f-5eb7-4d4f-9c8e-e8eae39faebc) or any additional role that has the `Microsoft.Resources/deployments/*` permission in the `Microsoft.Resources` namespace.
