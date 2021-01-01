---
id: 6836
title: Sneak Peak of Azure Blueprints
date: 2018-10-26T13:43:54+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=6836
permalink: /2018/10/26/sneak-peak-of-azure-blueprints/
categories:
  - Azure
tags:
  - Azure
  - Azure Blueprints
  - Azure Governance
---
Azure Blueprints have been announced and made available for public preview last month at Microsoft Ignite 2018. I have been on the private preview for few months now, and I’m really excited that it’s finally gone public and we can start talking about it.

If you haven’t heard of Blueprints, according to the Blueprints PM Alex Frankel, Blueprints is designed for:
<blockquote>deploy and update cloud environments in a repeatable manner using composable artifacts.</blockquote>
I have heard an analogy before – An Azure subscription is just like an empty canvas, and your developers are like painters. But we all know that we can’t just allow our users to deploy anything they like in their Azure subscriptions. You, as the cloud engineer will need to lay down some foundation work and set some rules (i.e. vnets, NSG and firewalls, policies and role assignments, etc.). This is where you would utilize Blueprints. So think about Azure Blueprints as your cookie cutters. You develop blueprints so you can quickly provision consistent environments for your users to consume Azure resources.

You may find the following resources useful if you wish to learn more about Azure Blueprints:

Microsoft Docs: <a href="https://aka.ms/whatareblueprints">https://aka.ms/whatareblueprints</a>

Ignite session recordings:
<ul>
 	<li><a href="https://www.youtube.com/watch?v=ZuDg9-z8uuY">BRK3062 - Architecting Security and Governance Across your Azure Subscriptions</a></li>
 	<li><a href="https://www.youtube.com/watch?v=d6c1nfoySLI">BRK3085 - Deep dive into Implementing governance at scale through Azure Policy</a></li>
</ul>
Alex Frankel’s GitHub Repo: <a title="https://github.com/ajf214/personal-arm-templates" href="https://github.com/ajf214/personal-arm-templates">https://github.com/ajf214/personal-arm-templates</a>

I’ve spent some time over the last few days testing it’s capabilities, I’ll share my experience in this post.
<blockquote><strong>Note:</strong> Please keep in mind Azure Blueprints is still in preview, its capability is still limited at this stage.</blockquote>
Currently, you can add the following types of artifacts in a blueprint:
<ul>
 	<li>Policy Assignment</li>
 	<li>Role Assignment</li>
 	<li>Azure Subscription Level ARM template</li>
 	<li>Azure resource group</li>
 	<li>Azure resource group level ARM template</li>
</ul>
In my lab, I have created a blueprint with the following artifacts:

<a href="https://blog.tyang.org/wp-content/uploads/2018/10/image.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/10/image_thumb.png" alt="image" width="952" height="711" border="0" /></a>
<ul>
 	<li>A subscription level ARM template that deploys custom policy and initiative definitions, as well as a subscription level policy assignment</li>
 	<li>Role assignment – assigning an AAD group to subscription owner role</li>
 	<li>A subscription level ARM template that deploys custom role definitions</li>
 	<li>A resource group called “rg-network”</li>
 	<li>A resource group level ARM template that deploys:
<ul>
 	<li>A hub and spoke vnet pattern that hub (management) vnet contains various subnets and a VPN gateway. A spoke (workload) vnet that is peered to the hub vnet.</li>
 	<li>A NSG that is associated to all applicable subnets in both vnets.</li>
</ul>
</li>
</ul>
When creating the blueprint, I have the options to either specify (hardcode) some of the values, or choose the option to enter the value during assignment. In this case, I have hardcoded the resource group name for the networking pattern to “rg-network”, but information such as resource group location, and local (on-prem) gateway IP address will need to be entered when the blueprint is assigned.

<a href="https://blog.tyang.org/wp-content/uploads/2018/10/image-1.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/10/image_thumb-1.png" alt="image" width="934" height="1443" border="0" /></a>

Once assigned, depending on your artifacts, it may take a while for blueprint to be deployed. You can check the status in Assigned Blueprints blade:

<a href="https://blog.tyang.org/wp-content/uploads/2018/10/image-2.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/10/image_thumb-2.png" alt="image" width="951" height="332" border="0" /></a>

You may noticed that there is a “Lock” option when you are configuring the assignment. The lock prevents people from modifying / deleting resources deployed by the blueprint. This is different than the Azure resource lock that we are all familiar with. The blueprint team implemented this feature without leveraging the resource lock because resource locks can be deleted by people who have access to (i.e. subscription owners). In order to prevent users from modifying and deleting this resources regardless what roles they have within the subscription, the Blueprint product team implemented the locking using Azure RBAC. According to the <a href="https://docs.microsoft.com/en-us/azure/governance/blueprints/concepts/resource-locking">Blueprints resource locking doc</a>:
<blockquote>An RBAC role <code><span style="background-color: #ffff00;">denyAssignments</span></code> is applied to artifact resources during assignment of a blueprint if the assignment selected the <strong>Lock</strong> option. The role is added by the managed identity of the blueprint assignment and can only be removed from the artifact resources by the same managed identity.</blockquote>
At the time of writing this article, some capabilities are only available via <a href="https://docs.microsoft.com/en-us/azure/governance/blueprints/create-blueprint-rest-api">Blueprints REST API</a>, they have yet been exposed to the Azure portal since Blueprints is still in preview. i.e. When authoring a blueprint in the Azure portal, you do not have the ability to define deployment sequence (dependencies between artifacts), but it is possible using the <a href="https://docs.microsoft.com/en-us/azure/governance/blueprints/concepts/sequencing-order">REST API</a>. Alex has demonstrated this in details in his Ignite talk BRK3085 <a href="https://www.youtube.com/watch?v=d6c1nfoySLI&amp;t=47m11s">- Deep dive into Implementing governance at scale through Azure Policy</a>.

Lastly, you can submit your ideas and feedback via Uservoice: <a title="https://feedback.azure.com/forums/915958-azure-governance" href="https://feedback.azure.com/forums/915958-azure-governance">https://feedback.azure.com/forums/915958-azure-governance</a>

20 November 2018 Update: The export of the my sample blueprint used in this post is stored in Alex's GitHub repo: <a href="https://github.com/ajf214/personal-arm-templates/tree/master/Example%20Blueprints/managementSubConfig">https://github.com/ajf214/personal-arm-templates/tree/master/Example%20Blueprints/managementSubConfig</a>