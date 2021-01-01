---
id: 7350
title: Validating ARM Templates with ARM What-if Operations
date: 2020-04-26T21:48:53+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=7350
permalink: /2020/04/26/validating-arm-templates-with-arm-what-if-operations/
spay_email:
  - ""
categories:
  - Azure
tags:
  - ARM Template
  - Azure
  - What-if
---
The ARM template deployment <a href="https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/template-deploy-what-if" target="_blank" rel="noopener noreferrer">What-if API</a> was firstly announced to the general public at Ignite last year. It has finally been made available for public preview not long ago. This is a feature that I’ve been keeping close eye on ever since I heard about way before Ignite, when it was still under NDA.

In a nutshell, comparing to the existing ARM template validation capability (<a href="https://docs.microsoft.com/en-us/powershell/module/az.resources/test-azresourcegroupdeployment" target="_blank" rel="noopener noreferrer">Test-AzResourceGroupDeployment</a>, <a href="https://docs.microsoft.com/en-us/powershell/module/az.resources/test-azdeployment" target="_blank" rel="noopener noreferrer">Test-AzDeployment</a>, etc.), the what-if API provides additional capability that provides you an overview on if your template is deployed, what resources will be created / deleted and modified. Although the what-if API is still in preview and still have many rough edges, I think it’s now the time to get my hands dirty and start playing with it. I’ll share my experience and opinions in this post.

<h3>What-If API vs Existing ARM Template Validation</h3>

Prior to the What-If API, we’ve always had way to validate our ARM templates. the latest Azure Powershell module ships the following commands for validating different types of ARM template:

<ul>
    <li>Resource group level: <a href="https://docs.microsoft.com/en-us/powershell/module/az.resources/test-azresourcegroupdeployment" target="_blank" rel="noopener noreferrer">Test-AzResourceGroupDeployment</a></li>
    <li>Subscription level: <a href="https://docs.microsoft.com/en-us/powershell/module/az.resources/test-azdeployment" target="_blank" rel="noopener noreferrer">Test-AzDeployment</a></li>
    <li>Management Group level: <a href="https://docs.microsoft.com/en-us/powershell/module/az.resources/test-azmanagementgroupdeployment" target="_blank" rel="noopener noreferrer">Test-AzManagementGroupDeployment</a></li>
    <li>Tenant level: <a href="https://docs.microsoft.com/en-us/powershell/module/az.resources/test-aztenantdeployment" target="_blank" rel="noopener noreferrer">Test-AzTenantDeployment</a></li>
</ul>

Or you can also use the <a href="https://docs.microsoft.com/en-us/rest/api/resources/deployments/validate" target="_blank" rel="noopener noreferrer">REST API</a>, or <a href="https://docs.microsoft.com/en-us/cli/azure/group/deployment?view=azure-cli-latest#az-group-deployment-validate" target="_blank" rel="noopener noreferrer">Azure CLI</a>.

This validation does nothing but validating the ARM template syntax, which does not guarantee a successful deployment. The What-If API actually validate your template against your deployment target, it also detects errors specific to your environment.

for example, it detects that the deployment target has exceeded maximum deployment quota of 800 (thanks to my friend <a href="https://twitter.com/AlexVerkinderen" target="_blank" rel="noopener noreferrer">Alex Verkinderen</a> for providing this screenshot):

<a href="https://blog.tyang.org/wp-content/uploads/2020/04/image.png"><img width="787" height="245" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2020/04/image_thumb.png" border="0"></a>

It will also detect syntax errors in the template:

<a href="https://blog.tyang.org/wp-content/uploads/2020/04/image-1.png"><img width="1052" height="83" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2020/04/image_thumb-1.png" border="0"></a>

<h3>What-If API vs Terraform Plan</h3>

If you have used Terraform before, the what-if API will probably remind you of <a href="https://www.terraform.io/docs/commands/plan.html" target="_blank" rel="noopener noreferrer">terraform plan</a>, which does exactly what what-if does, but the significant difference between ARM what-if API and terraform plan is: <font style="background-color: rgb(255, 255, 0);">what-if API does not use state files</font>. This is a huge advantage comparing to Terraform.

I’ve never liked Terraform. I’ve used it (because I had to) for AWS and GCP. In my opinion, terraform and its state files are such as PITA.

When you deploy a terraform template, it stores the state of the deployment (tfstate) in a folder you specify. When you deploy an updated version of the template, or when you use "terraform destroy" command to delete previously deployed resources, terraform compares the request against the state file and figure out what exactly needs to be performed. This method only works well when working in a small project (that you are the only developer) and in a fairly static environment. In reality, there are many problems that are introduced by this terraform feature:

<strong>1. Additional admin effort to create and maintain a shared location for terraform state when working with a team of developers.</strong>

If you are part of a dev team, you will need to setup a shared location for storing terraform state files for each template, and make sure all your team members are using the shared folder.

<strong>2. Modifying resources outside of terraform template is like the end of the world.</strong>

If you quickly modify your resources using PowerShell, or via the portal, or any other method, the terraform state (which is cached offline) will be out of sync from the real state of the resources. Now, think about what’s going to happen if you also use Azure Policy to deploy additional resources after your initial terraform deployments have already completed (i.e. Policies that use <a href="https://docs.microsoft.com/en-us/azure/governance/policy/how-to/remediate-resources" target="_blank" rel="noopener noreferrer">deployIfNotExists effect</a> to deploy VM Extensions or diagnostic settings, etc.)?

I’ve seen people addressed this issue by not giving administrators / developers any administrative rights in any environment to enforce the use of Terraform (in this case, Terraform Enterprise, see my next point). When you are debugging an issue, or when shit hits the fan and you are fixing a production issue, sometimes you just want to quickly make a small change manually. Sorry, I’m afraid you can’t do this if you are operating in a Terraform shop. Once you’ve deployed a pattern with Terraform, you are locked in with it.

<strong>3. What about the Enterprise Solution for Terraform?</strong>

To tackle the problem with sharing state files between multiple developers, Hashicorp has an enterprise version of Terraform called Terraform Enterprise (TFE). TFE offers a web portal and a set of REST APIs that allows people to upload the terraform templates to your TFE workspace, and it will deploy the template and maintain the state for you. It becomes a central deployment server in your environment. Although it fixes one problem, it sure introduced other risks: it becomes a single point of failure. If it fails, you won’t be able to deploy / update your cloud environments. Since it also stores templates, secrets, etc, it becomes a great target for attacks – especially in a multi-cloud environment. In a large enterprise, your security team will sure hate this platform.

So, what about the ARM What-if API? it <strong>DOES NOT use any kind of offline state files</strong>. When you use it to evaluate your ARM template, it compares what’s defined in your template with what’s deployed in your Azure environment in real life. This is a HUGE advantage. I’ve heard so many people bragging about how useful terraform plan output is, and now, Microsoft just introduced the same capability in native ARM APIs, and removed the complexity of having to maintain offline state files.

<h3>What-If in Action</h3>

To test it out, I’ve created a simple ARM template that creates the following resources:

<ul>
    <li>a VNet with several subnets</li>
    <li>a Network Security Group (NSG) for the subnets</li>
</ul>

When I validated it using the What-If API via PowerShell (<strong><em>Get-AzResouceGroupDeploymentWhatIfResult</em></strong>), since it’s never been deployed, the result showed me the resources that will be created (in green):

<a href="https://blog.tyang.org/wp-content/uploads/2020/04/image-2.png"><img width="1023" height="1355" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2020/04/image_thumb-2.png" border="0"></a>

I then deployed the template, the deployment completed successfully.

After the initial successful deployment, I’ve updated the template to add the a bastion host to the VNet. The following resources were added to the template:

<ul>
    <li>Bastion Host</li>
    <li>Subnet for the Bastion Host</li>
    <li>Public IP for the Bastion Host</li>
    <li>NSG for the Bastion Host subnet</li>
</ul>

I validated the updated template again, it showed me what will be deleted / created / modified and not changed (represented in different colours and symbols):

<a href="https://blog.tyang.org/wp-content/uploads/2020/04/image-3.png"><img width="952" height="3073" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2020/04/image_thumb-3.png" border="0"></a>

if you want to programmatically manipulate the changes, you can access them as the properties of the result object

<a href="https://blog.tyang.org/wp-content/uploads/2020/04/image-4.png"><img width="523" height="266" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2020/04/image_thumb-4.png" border="0"></a>

<a href="https://blog.tyang.org/wp-content/uploads/2020/04/image-5.png"><img width="650" height="491" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2020/04/image_thumb-5.png" border="0"></a>

<h3>Reducing Noise</h3>

Since the What-if API is still in preview, it’s not perfect. It is only as good as how well each Azure Resource Provider is implemented. You will see some false positive depending on the resource types. For example, from my previous screenshot for the result when adding bastion hosts, it has shown all the subnets will be deleted. Obviously, this is not the case. What-If leverages a purposely built noise reduction service in Azure to calculate the result when you call it. The product group is still working on reducing the false positivise. It is explained here why does noise occur: <a href="https://github.com/Azure/arm-template-whatif#why-does-noise-occur">https://github.com/Azure/arm-template-whatif#why-does-noise-occur</a>.

I strongly encourage you to try it out, file issues if you’ve experienced false positives or other bugs at it’s GitHub repo: <a href="https://aka.ms/whatifissues">https://aka.ms/whatifissues</a>

<h3>What’s Next?</h3>

As this API gradually become more and more mature, I will definitely try to incorporate into my CI/CD pipelines. Once I’ve got something worth showing, i will post my solution here.

If you want to learn more about what-if, check out <a href="https://www.youtube.com/watch?v=XWip40dc1rY">this YouTube video</a> from the <a href="https://twitter.com/adotfrank">Alex Frankel</a>, who’s the PM responsible for this API at Microsoft.