---
title: Various updates for AzPolicyFactory
date: 2026-08-09 12:00
author: Tao Yang
permalink: /2026/08/09/azpolicyfactory-various-updates
summary:
categories:
  - Azure
tags:
  - Azure
  - Azure Policy

---

## Introduction

I have made various updates to the AzPolicyFactory solution over the past few months. The updates include:

- New policies for Microsoft Defender for Cloud (MDC)
- New policies for AI Landing Zone components (AI Foundry, Cosmos DB and Azure AI Search)
- New policies for Azure Kubernetes Service (AKS)
- New policies for allowing or denying resource providers
- An updated policy for restricting resource creation using `-preview` ARM API versions

## New Microsoft Defender for Cloud (MDC) Policies

I noticed that the built-in policies for Microsoft Defender for Cloud (MDC) are outdated. I have produced a new set of MDC policies that use more recent API versions and provide updated plan coverage and configuration options. They are located at:

- **Policy Definitions**: [policyDefinitions/mdc](https://github.com/Azure/AzPolicyFactory/tree/main/policyDefinitions/mdc)
- **Policy Initiatives**: [policyInitiatives/polset-mdc.json](https://github.com/Azure/AzPolicyFactory/blob/main/policyInitiatives/polset-mdc.json)

## New AI Landing Zone Policies

I have produced a new set of policies for AI Landing Zone components, including AI Foundry, Cosmos DB and Azure AI Search. They are located at:

### AI Foundry (Cognitive Services)

- **Policy Definitions**: [policyDefinitions/cognitive-service](https://github.com/Azure/AzPolicyFactory/tree/main/policyDefinitions/cognitive-service)
- **Policy Initiatives**: [policyInitiatives/polset-cognitive-service.json](https://github.com/Azure/AzPolicyFactory/blob/main/policyInitiatives/polset-cognitive-service.json)

The following policies are included for AI Foundry accounts:

- `Cognitive Services accounts should restrict public network access`: Compared with the built-in policy, this policy has one additional condition: `Microsoft.CognitiveServices/accounts/networkAcls.defaultAction` must also be set to `Deny`.
- `Cognitive Services accounts should have local authentication methods disabled`: This policy uses the `Deny` effect, whereas the built-in policy uses the `Modify` effect.
- `Cognitive Services accounts should only allow permitted model formats`: This policy ensures that only allowed LLM model formats (such as `OpenAI`, `xAI` and `Anthropic`) are deployed to AI Foundry accounts.
- `Cognitive Services accounts should only allow permitted model names`: This policy ensures that only allowed LLM model names (such as `gpt-5`, `claude-opus-4-8` and `grok-4`) for a given format are deployed to AI Foundry accounts.

The `polset-cognitive-service.json` policy initiative uses several instances of the permitted model format and model name policies. These instances ensure that only allowed model formats (vendors) and model names (including versions) can be deployed to AI Foundry accounts. You can customise this initiative to include your own allowed model formats and names.

### Cosmos DB

- **Policy Definitions**: [policyDefinitions/cosmos-db](https://github.com/Azure/AzPolicyFactory/tree/main/policyDefinitions/cosmos-db)
- **Policy Initiatives**: [policyInitiatives/polset-cosmos-db.json](https://github.com/Azure/AzPolicyFactory/blob/main/policyInitiatives/polset-cosmos-db.json)

The following policies are included for Cosmos DB:

- `Cosmos DB database accounts should have local authentication methods disabled`: We encountered issues while testing the built-in policy when `Microsoft.DocumentDB/databaseAccounts/capabilities[*]` was empty. This policy handles that scenario and also blocks deployment when no capabilities are defined for the Cosmos DB account.
- `Azure Cosmos DB accounts should have a minimum TLS version`: This policy enforces the minimum TLS version for Cosmos DB accounts.
- `Azure Cosmos DB key-based metadata write access should be disabled`: This policy uses the `Audit` or `Deny` effect, whereas the built-in policy uses `Append`. The built-in policy also hardcodes the effect rather than parameterising it.

### Azure AI Search

- **Policy Initiatives**: [policyInitiatives/polset-search.json](https://github.com/Azure/AzPolicyFactory/blob/main/policyInitiatives/polset-search.json)

This is a sample reference policy initiative for Azure AI Search.

## New AKS Policies

- **AKS Control Plane Policy Definitions**: [policyDefinitions/aks](https://github.com/Azure/AzPolicyFactory/tree/main/policyDefinitions/aks)
- **AKS Control Plane Policy Initiatives**: [policyInitiatives/polset-aks-control.json](https://github.com/Azure/AzPolicyFactory/blob/main/policyInitiatives/polset-aks-control.json)
- **AKS Data Plane Policy Initiatives**: [policyInitiatives/polset-aks-data.json](https://github.com/Azure/AzPolicyFactory/blob/main/policyInitiatives/polset-aks-data.json)

These custom policy definitions and initiatives were developed for previous customer engagements. They are all referenced in the control plane policy initiative.

To keep the initiatives simple and optimise the performance of policy integration tests, we have separated the control plane and data plane policies into two initiatives. The data plane policy initiative contains all the built-in policies for AKS that use `Microsoft.ContainerService.Data` mode.

## New Policies - Allowed Resource Providers and Deny Resource Providers

- **Deny Resource Providers**: [policyDefinitions/general/pol-deny-resource-provider.json](https://github.com/Azure/AzPolicyFactory/blob/main/policyDefinitions/general/pol-deny-resource-provider.json)
- **Allow Resource Providers**: [policyDefinitions/general/pol-allow-resource-provider.json](https://github.com/Azure/AzPolicyFactory/blob/main/policyDefinitions/general/pol-allow-resource-provider.json)

These two policies can be used to prevent resources from specified resource providers from being deployed. You can choose between an allowlist and a denylist based on your organisation's requirements.

For example, if your organisation is new to Azure, the Allowed Resource Providers policy is probably the better approach. You can start with a small set of allowed resource providers and gradually add more as your organisation grows. If your organisation has been using Azure for a while and you want to restrict certain resource providers, you can use the Deny Resource Providers policy.

## Updated Policy for restricting resource creation using `-preview` ARM API versions

- **Control usage of preview versions of Azure Resource Manager REST APIs**: [policyDefinitions/general/pol-restrict-arm-preview-api-versions.json](https://github.com/Azure/AzPolicyFactory/blob/main/policyDefinitions/general/pol-restrict-arm-preview-api-versions.json)

This is an updated version of [my previously published policy definition](https://github.com/TaoYang-Cloud/azurepolicy/blob/master/policy-definitions/arm-api-versions/control-preview-api/azurepolicy.json).

The original version uses an `array` parameter to define the list of resource types. I am not a fan of this approach because it is not possible to create an exemption for a specific resource type.

The updated version uses a `string` parameter to define a specific resource type. The policy can be included in any policy initiative, and you can define multiple instances for different resource types. You can also create an exemption for a specific resource type.

The original version also had an issue with subsequent compliance scans. Because Azure Policy always evaluates resources using the latest API version, the policy always reports a resource as `non-compliant` when the latest version is a `-preview` version. In practice, this policy should be evaluated only when a resource is created or updated. The updated version fixes this issue by adding the following condition:

```json
{
  "value": "[tryGet(requestContext().identity, 'idtyp')]",
  "in": ["user", "app"]
}
```

This condition ensures that the policy is evaluated only when an identity (`user` or `app`) initiates the request. During a compliance scan, the `idtyp` value returned by the `requestContext().identity` function is `null`, so the policy is not evaluated. This ensures that the policy is evaluated only when a resource is created or updated.
