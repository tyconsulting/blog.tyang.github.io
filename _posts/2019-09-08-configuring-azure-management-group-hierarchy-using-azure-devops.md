---
id: 7171
title: Configuring Azure Management Group Hierarchy Using Azure DevOps
date: 2019-09-08T18:08:12+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=7171
permalink: /2019/09/08/configuring-azure-management-group-hierarchy-using-azure-devops/
categories:
  - Azure
tags:
  - Azure DevOps
  - Azure Governance
  - Powershell
---
Previously, I have published a 3-part blog series on deploying Azure Policy Definitions via Azure DevOps (<a href="https://blog.tyang.org/2019/05/19/deploying-azure-policy-definitions-via-azure-devops-part-1/">Part 1</a>, <a href="https://blog.tyang.org/2019/05/19/deploying-azure-policy-definitions-via-azure-devops-part-2/">Part 2</a>, <a href="https://blog.tyang.org/2019/05/19/deploying-azure-policy-definitions-via-azure-devops-part-3/">Part 3</a>). It covered one aspect of implementing Azure Governance using code and pipelines. There are at least 2 additional areas I haven’t covered:

<ol>
    <li>Configuring Management Group hierarchy</li>
    <li>Policy & Initiative assignments</li>
</ol>

In this post, I’ll cover how I managed to implement the management group hierarchy using Azure DevOps. I will cover policy & initiative assignment in a future blog post.

<h3>Problem Statement</h3>

Before I dive into the technical details, I’d like to firstly explain why is this required?

In an enterprise environment, subscriptions get created, renamed, disabled all the time. your cloud team may create Enterprise Agreement or Dev Test subscriptions from the EA accounts, some users may have sponsorship or MSDN subscriptions that they have enabled in the organisation’s Azure AD tenant and others may even have created free trial subscriptions also under the organisation’s tenant. For example, your tenant may look something like this:

<a href="https://blog.tyang.org/wp-content/uploads/2019/09/image.png"><img width="491" height="629" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2019/09/image_thumb.png" border="0"></a>

When new subscriptions are joining your organisations tenants so frequently, you will need to make sure these subscriptions are automatically placed into appropriate management groups so you can apply appropriate policy and RBAC role assignments to them. It is not enough that you only manage the subscriptions that you know of. In the environment from the screenshot above, no one knew there are so many free trial and MSDN subscriptions in this particular tenant, until I enabled User Access Administrator role for myself(<a href="https://docs.microsoft.com/en-us/azure/role-based-access-control/elevate-access-global-admin">https://docs.microsoft.com/en-us/azure/role-based-access-control/elevate-access-global-admin</a>).

So why do I care about these subscriptions? In the subscriptions under the management of the cloud team, we have many restrictions in place – for example, normal users cannot create vnets, public-facing storage accounts, etc. but these users can do whatever they want in their own MSDN or free trial subscriptions. users can also move resources between subscriptions (<a href="https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-move-resources">https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-move-resources</a>). This can be a potential security risk, if you do nothing about these user-owned subscriptions.

<h3>Solution</h3>

Since everything should be driven by code and templates, Using Azure DevOps to implement the overall management group hierarchy makes perfect sense.

<strong><font style="background-color: rgb(255, 255, 0);">All the source code for my solution can be found at my GitHub repo: </font></strong><a href="https://github.com/tyconsulting/Azure.ManagementGroup.Hierarchy.Config"><strong><font style="background-color: rgb(255, 255, 0);">https://github.com/tyconsulting/Azure.ManagementGroup.Hierarchy.Config</font></strong></a>

In my solution, the pipeline performs 2 tasks:

<ol>
    <li>Create the management group hierarchy for the tenant</li>
    <li>Move subscriptions to appropriate management groups based on subscription names and types</li>
</ol>

The management group hierarchy and subscription placement rules are defined in a JSON definition file, a PowerShell script called configure-managementGroups.ps1 reads the definition file, firstly create the management group hierarchy, then scan through all the subscriptions in the tenant and place them based on the placement rules defined in the definition file.

Here’s a sample definition file:

<pre language="JSON">{
    "tenantRootDisplayName": "Tao Yang Lab Root",
    "managementGroups":[
        {
            "name":"mg-mgmt-root",
            "displayName": "Management Root"
        },
        {
            "name":"mg-wl-root",
            "displayName": "Workload Root"
        },
        {
            "name":"mg-scf-root",
            "displayName": "Scaffolding Root"
        },
        {
            "name":"mg-scf-mgmt",
            "displayName": "Scaffolding Management",
            "parent": "mg-scf-root"
        },
        {
            "name":"mg-scf-wl",
            "displayName": "Scaffolding Workload",
            "parent": "mg-scf-root"
        },
        {
            "name":"mg-quarantine",
            "displayName": "Quarantine"
        }
    ],
    "subscriptionPlacements": [
        {
            "subNameRegex": "^the-big*",
            "subQuotaIdRegex": "^sponsored*",
            "managementGroup": "mg-wl-root"
        },
        {
            "subNameRegex": "^mvp*",
            "subQuotaIdRegex": "^msdn*",
            "managementGroup": "mg-mgmt-root"
        }
    ],
    "defaultManagementGroup": "mg-quarantine"
}
</pre>

the definition file contains the following sections:

<ul>
    <li>Display name for the tenant root management group</li>
    <li>Management group hierachy (in the managementGroups section). this section defines the management groups to be created. each item contains the mandatory attributes of name and displayName. if the parent attribute is not specified, it will be placed under the tenant root MG.</li>
    <li>subscription placement rules (in the subscriptionPlacements section). Each rule contains 3 mandatory fields:</li>
<ul>
    <li>subNameRegex: the regular expression for the subscription name</li>
    <li>subQuotaIdRegex: the regular expression for the subscription quota Id (more on this later)</li>
    <li>managementGroup: the management group that the subscription is placed under when BOTH name and quota Id regex are matched.</li>
</ul>
    <li>Default Management group: defines which management group should the subscription be placed under if it does not match any of the subscription placement rules.</li>
</ul>

<h4>Subscription Quota Id</h4>

Initially, I wanted to use the subscription Offer Id to identify the type of subscription (as shown below):

<a href="https://blog.tyang.org/wp-content/uploads/2019/09/image-1.png"><img width="636" height="183" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2019/09/image_thumb-1.png" border="0"></a>

Then I learned that this offer Id is not exposed in any of the REST APIs (or at least I haven’t been able to find a way to query this field). Luckily, the <a href="https://docs.microsoft.com/en-us/rest/api/resources/subscriptions/list">list subscriptions ARM REST API</a> exposed a similar attribute called quota Id. If you try to invoke this API from the docs site, you can quickly find out the corresponding quota Id for your subscriptions:

<a href="https://blog.tyang.org/wp-content/uploads/2019/09/image-2.png"><img width="898" height="418" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2019/09/image_thumb-2.png" border="0"></a>

For example, I have few Azure Sponsorship subs, the quota Id for those subs is "<em>Sponsored_2016-01-01</em>", and my MSDN sub is "<em>MSDN_2014-09-01</em>". An EA sub is "<em>EnterpriseAgreement_2014-09-01</em>", and an Enterprise MSDN Dev/Test sub is "<em>MSDNDevTest_2014-09-01</em>".

Once you get the the subscription quota Id, you are able to build the regular expression for it. for example, a valid regex for enterprise sub can be "<strong><em>^EnterpriseAgreement_<em></em></strong>", and for sponsorship sub: "<strong><em>^Sponsored_</em></em></strong>".

<h4>Subscription placement rules</h4>

if your "management" subscriptions are created as EA subs and have a naming convention of "sub-mgmt-xxxx" and you wish to place these subs into a management group called "mg-mgmt-root", the rule can be something like:

<pre language="JSON">{
    "subNameRegex": "^sub-mgmt-*",
    "subQuotaIdRegex": "^EnterpriseAgreement_*",
    "managementGroup": "mg-mgmt-root"
}
</pre>

Or if you want to place all users MSDN subscriptions into a management group called "mg-msdn", the rule can be something like:

<pre language="JSON">{
    "subNameRegex": "*",
    "subQuotaIdRegex": "^msdn_*",
    "managementGroup": "mg-msdn"
}
</pre>

In order to be placed into the defined management group, the subscription must match <strong>both</strong> the name regex and quota Id regex. The script uses case insensitive match for the regex. so it doesn’t matter if you define your regex as "^msdn_<em>" or "^MSDN_</em>".

<h3>Building the Pipelines</h3>

Before building the pipelines, there are some pre-requisites need to be taken care of first.

<h4>Pre-requisites</h4>

<strong>Azure AD App and Service Principal</strong>

You will need to create an Azure AD application with a service principal for each tenant that you are going to configure the management group hierarchy for. The service principal will need to have the <strong>owner role</strong> assigned at the tenant root management group level.

You may use my <a href="https://gist.github.com/tyconsulting/91c3899224f80f9b098e20ba8ec1da16">New-AADServivcePrincipal.ps1</a> script to create the&nbsp; service principal. For Example:

<pre language="PowerShell">New-AADServicePrinicipal.ps1 –AADAppName AzDevOpsConnection –KeyType ‘Key’
</pre>

<strong>Service Connection in Azure DevOps project</strong>

Once the service principal is created, you will need to create a service connection in the Azure DevOps project (for each tenant you are deploying this solution to):

<ul>
    <li>Scope level: ManagementGroup</li>
    <li>Management Group ID: &lt;same as your tenant Id&gt;</li>
</ul>

<a href="https://blog.tyang.org/wp-content/uploads/2019/09/image-3.png"><img width="418" height="489" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2019/09/image_thumb-3.png" border="0"></a>

<h4>Build Pipeline</h4>

The build (CI) pipeline is defined in the <a href="https://github.com/tyconsulting/Azure.ManagementGroup.Hierarchy.Config/blob/master/pipelines/build-pipeline.yaml">pipelines/build-pipeline.yaml</a> file in the GitHub repo. you can simply import it, it should work without any modifications.

<a href="https://blog.tyang.org/wp-content/uploads/2019/09/image-4.png"><img width="1061" height="831" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2019/09/image_thumb-4.png" border="0"></a>

It performs the following tasks:

<ol>
    <li>installing required PowerShell modules from PowerShell Gallery (since I’m using Microsoft-hosted Azure DevOps agents here)</li>
    <li>Validate the schema of all input files located in the "config-files" folder.</li>
    <li>Publish test results</li>
    <li>Publish pattern (copying artifacts to build staging directory for release pipelines)</li>
</ol>

<h4>Release Pipelines</h4>

Since subscriptions gets added to the tenant all the time, this script needs to run on a schedule (via Azure Pipelines). With the recent introduction of <a href="https://devblogs.microsoft.com/devops/whats-new-with-azure-pipelines/">multi-stage YAML pipeline</a> in Azure DevOps, we are able to combine build and releases in one YAML pipeline. However, because I am planning to schedule the release pipeline to run twice daily with the same build artifacts, there is no point creating a new build each time the pipeline runs. Therefore, I have separated the release pipeline from the build YAML pipeline, and used the classic pipeline instead, so I can only run the release pipeline on a schedule, using the same build artifacts.

<a href="https://blog.tyang.org/wp-content/uploads/2019/09/image-5.png"><img width="823" height="362" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2019/09/image_thumb-5.png" border="0"></a>

I have enabled continuous deployment, and created two schedules:

<a href="https://blog.tyang.org/wp-content/uploads/2019/09/image-6.png"><img width="507" height="325" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2019/09/image_thumb-6.png" border="0"></a>

<a href="https://blog.tyang.org/wp-content/uploads/2019/09/image-7.png"><img width="535" height="319" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2019/09/image_thumb-7.png" border="0"></a>

For each stage in the release pipeline, I run 2 Azure PowerShell tasks:

<ol>
    <li>The first task executes configure-managementGroups.ps1 with the –whatif switch to perform a dry run against the input file provided for the stage. It ensures there are no errors with the given input file before continuing to the next step.</li>
    <li>If the first task completes successful, the second task performs the "real-run" to configure the hierarchy and placing subscriptions in management groups.</li>
</ol>

<strong>Step 1: What-if Dry run:</strong>

<a href="https://blog.tyang.org/wp-content/uploads/2019/09/image-8.png"><img width="963" height="568" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2019/09/image_thumb-8.png" border="0"></a>

<ul>
    <li>Task Version: 4.* – make sure you choose 4 (or later) so the task supports the Az PowerShell module (instead of AzureRM)</li>
    <li>Script Path: path to the config-managementGroups.ps1 script, which is copied to the build staging folder by the build pipeline. use the "…" button to browse to the file.</li>
    <li>Script Arguments: –inputFile &lt;path to the input file for the stage&gt; <font style="background-color: rgb(255, 255, 0);">–silent –whatif</font></li>
    <li>ErrorActionPreference: Stop. So if the dry run fails, the pipeline will not move the next step</li>
    <li>Azure PowerShell Version: Latest installed version</li>
</ul>

<strong>Step 2: The "Real run"</strong>

<a href="https://blog.tyang.org/wp-content/uploads/2019/09/image-9.png"><img width="976" height="560" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2019/09/image_thumb-9.png" border="0"></a>

This is pretty much the same as the first step, except the "-whatif" argument has been removed from the script arguments.

<strong>NOTE:</strong> When this step runs, the scripts will skip any existing management groups that are defined in the input file, and skip any subscriptions that are already placed in the correct management group. The script will <strong>DO NOTHING</strong> to any existing management groups that are not defined in the input file.

<h3>Conclusion</h3>

In this post, I have explained the solution that I have developed to implement Azure Management Group hierarchy in a very dynamic enterprise environment. Before implementing this solution, probably is better to firstly draw up your management group hierarchy design, figure out where in the hierarchy you are going to create RBAC assignments, custom policy / initiative definitions, and assigning policies / initiatives. If you have subscriptions created outside of your control, consider what kind of restrictions you wish to apply to these subs, and potentially advise your users move their non-EA subs to their own tenants.

In the future, it would be good if we can restrict our tenants to only allow certain types of subscriptions. But as far as I know, at the time of writing, I don’t believe we can configure this by ourselves.