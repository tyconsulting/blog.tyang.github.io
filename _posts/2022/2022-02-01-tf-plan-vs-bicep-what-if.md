---
title: Comparing Terraform Plan and Azure Resource Manager What-If
date: 2022-02-01 16:00
author: Tao Yang
permalink: /2022/02/01/tf-plan-vs-bicep-what-if
summary: Comparing Terraform Plan and Azure Resource Manager What-If API
categories:
  - Azure
tags:
  - Azure
  - Terraform
  - Azure Bicep
---

## Introduction

When it comes to Infrastructure as Code (IaC) for Azure, Terraform and Azure Resource Manager (ARM) templates (or it's successor Azure Bicep) are probably the two most popular solutions out there. I have used both in various projects.

In the past, one of the main factors that people choose Terraform over ARM / Bicep is the capability of know what **would** happen when you apply your template code via the `terraform plan` command.

Few years ago Microsoft has started developing a new capability for ARM aiming to close this gap. The result is the release of the [ARM What-If API](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-what-if). ARM What-If generates similar results to  `terraform plan`. it shows you what changes would be applied to your target prior the actual deployment of your template. You can invoke it via Azure CLI, Azure PowerShell, or directly calling the REST API for both your ARM templates or Bicep templates.

It is hard to say which one is better between `terraform plan' and ARM What-If. In this article, I will try to compare the two based on the following scenarios from my past experiences:

* [Azure Policy Evaluation](#azure-policy-evaulation)
* [Evaluating Subscription Quota](#evaluating-subscription-quota)
* [Network Security Group Rules Validation](#network-security-group-rules-validation)
* [Use of Module Outputs](#use-of-module-outputs)
* [Parsing Outputs](#parsing-outputs)

>**NOTE:** All the sample Bicep and Terraform templates I have used in this blog post can be found on my GitHub repository [HERE](https://github.com/tyconsulting/tf.vs.bicep).

The following tools and software are used. All of these should be at the latest version at the time writing this article:

| Name | Version |
| :--- | :------ |
| Terraform | v1.1.4 |
| Terraform AzureRM provider | v2.94.0 |
| Azure CLI | v2.32.0 |
| Azure CLI Bicep Extension | v0.4.1124 |

## Scenarios

### Azure Policy Evaluation

| Tool | Capable |
| :--- | :------ |
| Terraform | No |
| Bicep and ARM What-If | Yes |

**[Sample templates](https://github.com/tyconsulting/tf.vs.bicep/tree/master/Storage-Account)**

Azure Policy has the ability to audit, modify or block your deployments. During the template development and testing phase, it is very important that we understand if the resources we are deploying are compliant with the Policies assigned to the target environment. `terraform plan` does not evaluate Azure Policy assignments on the target environments.

On the other hand, ARM What-If does. Although it does not support all the [Azure Policy effects](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/effects), the [**Deny**](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/effects#deny) effect is supported - which is the most critical one when we are evaluating the templates.

To test, I have created a policy assignment that blocks storage accounts from being created if its Service Endpoint is not enabled. The poilcy definition can be found [HERE](https://github.com/tyconsulting/azurepolicy/tree/master/policy-definitions/restrict-public-storageAccount).

When I ran `terraform plan`, the result indicates a storage account and a blob container will be created successfully:

![1](../../../../assets/images/2022/02/tf-vs-bicep-01.jpg)

When I invoked ARM What-If against the Bicep template using `az deployment group what-if` command, the result indeed showed me Azure Policy would block the deployment:

![2](../../../../assets/images/2022/02/tf-vs-bicep-02.jpg)

### Evaluating Subscription Quota

| Tool | Capable |
| :--- | :------ |
| Terraform | No |
| Bicep and ARM What-If | Yes |

**[Sample templates](https://github.com/tyconsulting/tf.vs.bicep/tree/master/Public-IP)**

In a previous engagement, it occurred to me several times that a production deployment with Terraform failed because the subscription quotas have been reached. i.e. the number of CPU cores for a particular VM family reached the limit for the subscription we use. To raise the the limit, we would have manually raise the request via the portal and normally the turn around is few hours (if we are lucky). This had a great impact with the original change window that we had planned. I have developed a habit to check the quota before the change start date, to ensure the deployment would not be blocked by the quota. This could be easily avoided if `terraform plan` checks the subscription quotas.

To test, I have maxed out the number of Public IP resources in one of my subscriptions so we can't create any more Public IPs.

![3](../../../../assets/images/2022/02/tf-vs-bicep-03.jpg)

I then tried to create another Public IP resource using Terraform . The plan result returned with no errors, however, an error was returned when you try to run `terraform apply`:

![4](../../../../assets/images/2022/02/tf-vs-bicep-04.jpg)

With Bicep, the What-If result indicated the quota has reached, which is what I want to see:

![5](../../../../assets/images/2022/02/tf-vs-bicep-05.jpg)

### Network Security Group Rules Validation

In the past when we create Azure landing zones, NSG rules can be very complicated. It is very time consuming to validate the code for all the NSG rules. Based on my past experience, the two most common errors we experienced when deploying our code are the overlapping IP ranges within the same NSG rule and duplicate priority numbers between multiple rules (error caused by copy and paste). Unfortunately, based on my tests, both Terraform and ARM What-If failed to detect overlapping IP ranges and duplicate priority numbers for NSG rules.

#### Overlapping IPs

| Tool | Capable |
| :--- | :------ |
| Terraform | No |
| Bicep and ARM What-If | NO |

**[Sample templates](https://github.com/tyconsulting/tf.vs.bicep/tree/master/NSG-Rules-Overlapping-IPs)**

To test, I have 2 CIDR ranges in as the source addresses, where the 2nd range "10.1.0.0/16" is already included in the first range "10.0.0.0/8". This deployment will fail but both `terraform plan` and ARM What-If ran successfully without errors:

Terraform:

![6](../../../../assets/images/2022/02/tf-vs-bicep-06.jpg)

Bicep What-If:

![7](../../../../assets/images/2022/02/tf-vs-bicep-07.jpg)

#### Duplicate Rule Priority Numbers

| Tool | Capable |
| :--- | :------ |
| Terraform | No |
| Bicep and ARM What-If | No |

**[Sample templates](https://github.com/tyconsulting/tf.vs.bicep/tree/master/NSG-Rules-Duplicate-Priority)**

To test, I have defined 2 inbound rules defined with same priority number. The deployments will fail but both `terraform plan` and ARM What-If ran successfully without errors:

Terraform:

![8](../../../../assets/images/2022/02/tf-vs-bicep-08.jpg)

Bicep What-If:

![9](../../../../assets/images/2022/02/tf-vs-bicep-09.jpg)

### Use of Module Outputs

| Tool | Capable |
| :--- | :------ |
| Terraform | Yes |
| Bicep and ARM What-If | No |

**[Sample templates](https://github.com/tyconsulting/tf.vs.bicep/tree/master/Storage-Account)**

Recently, I noticed a strange behavior that the What-If result does not list all the resources to be created by my Bicep template. I have spent few hours and managed to narrow down the issue, and I was able to reproduce this in a brand new Bicep template.

For example, I have a Bicep template that calls 2 modules (storage-account module and blob-container module). If I pass an output from the storage-account module as an input for the blob-container module as shown below:

![10](../../../../assets/images/2022/02/tf-vs-bicep-10.jpg)

The What-If result will only show resources created by the storage-account module (which is the storage account itself). It does not show the blob container resource:

![11](../../../../assets/images/2022/02/tf-vs-bicep-11.jpg)

If I update the template to not use the storage-account module output, and also manually define the dependency, the What-If result is correctly displayed:

Updated code:

![12](../../../../assets/images/2022/02/tf-vs-bicep-12.jpg)

What-If result:

![13](../../../../assets/images/2022/02/tf-vs-bicep-13.jpg)

On the other hand, Terraform does not have this issue. I was able to use the storage-account module output in the blob-container module, and `terraform plan` result is correct.

Code:

![14](../../../../assets/images/2022/02/tf-vs-bicep-14.jpg)

`terraform plan` result:

![15](../../../../assets/images/2022/02/tf-vs-bicep-15.jpg)

This is most likely a bug with the What-If API. I will try to reach out to the ARM product team and report this error.

### Parsing Output

| Tool | Capable |
| :--- | :------ |
| Terraform | Yes |
| Bicep and ARM What-If | Yes |

By default, both `terraform plan` and Azure CLI / PowerShell displays the plan or what-if result in a color-coded human-friendly format. They are both easy to read. But what if we want to consume these results programmatically? For example, we can write some Pester tests to evaluate the `terraform plan` or ARM what-if results.

Both ARM What-If and Terraform Plan can generate JSON outputs.

#### Parsing Outputs in Terraform

If you are using terraform with command line, you can export the plan result into a binary file, then display it in JSON format. You also pipe the output to a json parser (i.e. `jq` in bash or `ConvertFrom-Json` in PowerShell)

```bash
terraform plan -out plan.bin
terraform show -json plan.bin | jq
```

![16](../../../../assets/images/2022/02/tf-vs-bicep-16.jpg)

If you are using Terraform Cloud or Terraform Enterprise (TFE), you will need to use the [Plan REST API](https://www.terraform.io/cloud-docs/api-docs/plans) to retrieve the plan result. This API supports exporting the results into JSON format. However, in order to get the JSON format, the token you are using to call the API must have admin level access to the Terraform workspace as documented [HERE](https://www.terraform.io/cloud-docs/api-docs/plans#retrieve-the-json-execution-plan):

![17](../../../../assets/images/2022/02/tf-vs-bicep-17.jpg)

This requirement was a show stopper for us once when we were trying to develop tests for a pipeline in a customer's environment because we could not obtain such access.

#### Parsing ARM What-If Outputs

Not only you can retrieve the What-If results in JSON format, there are few additional formats you can choose from as well. This is documented in the help:

```bash
az deployment group what-if --help
```

![18](../../../../assets/images/2022/02/tf-vs-bicep-18.jpg)

To get the result in the default JSON format:

```bash
az deployment group what-if --resource-group $rg --template-file main.bicep --no-pretty-print
```

![19](../../../../assets/images/2022/02/tf-vs-bicep-19.jpg)

To get the result in YAML format:

```bash
az deployment group what-if --resource-group $rg --template-file main.bicep --no-pretty-print --output yaml
```

![20](../../../../assets/images/2022/02/tf-vs-bicep-20.jpg)

Clearly, when comes to parsing outputs, ARM What-If is the winner here because it's easier to work with, and supports multiple file format.

## Conclusion

This is by no mean a complete comparison for the planning capability between the 2 IaC templating language for Azure. the purpose of this article is just share some past experiences when dealing with planning results in Terraform and ARM / Bicep.

One important fact I forgot to mention in this article is that Terraform Plan always compare the template with the Terraform offline state file, which can potentially be outdated from the live environment. Whereas ARM What-If always compares your template with the **REAL** environment. Therefore theoretically the ARM What-If results are always more accurate.

Personally, I prefer using Bicep, because it's easier to maintain, there is no offline state file to manage. And if you are working on Azure, most likely you'd already have Azure CLI or Azure Powershell modules installed, so no additional tools are required when using ARM What-If. But this is just my 2c. Please use your own judgement, and choose the right tool for your job.
