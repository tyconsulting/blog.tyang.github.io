---
id: 7001
title: Deploying Azure Policy Definitions via Azure DevOps (Part 1)
date: 2019-05-19T22:58:59+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=7001
permalink: /2019/05/19/deploying-azure-policy-definitions-via-azure-devops-part-1/
categories:
  - Azure
tags:
  - Azure
  - Azure Policy
  - DevOpsAzurePolicySeries
  - Powershell
---
<!-- wp:heading {"level":3} -->
<h3>Introduction</h3>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>Recently I needed to deploy a large number of Azure policy and initiative definitions at customer’s environments using Azure DevOps. These definitions needed to be deployed to different environments (different Management Group hierarchies in different Azure AD Tenants).</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>I faced some difficulties when working on this solution, due to the following limitations:</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>1.  Currently templates do not support Management Groups</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>So I can’t use ARM templates in this case. But, I still needed to develop a solution no matter where should the definitions being deployed (either to a management group or a subscription).</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>2. Limitations in Azure PowerShell cmdlet New-AzPolicyDefinition and New-AzPolicySetDefinition</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Definitions files are repetitive and the input files required by these commands do not contain all the required information. (more on this later)</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>3. Not being able to use ARM template functions such as resourceId(), reference() in policy and initiative definitions.</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>This makes my task extremely difficult when defining initiative definitions that contain custom definitions that are not yet deployed.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>The end solution I developed was entirely based on Azure DevOps. I used:</p>
<!-- /wp:paragraph -->

<!-- wp:list -->
<ul><li>Azure Repo to host definition files and deployment scripts</li><li>Azure Artifacts to host PowerShell modules (as Nuget package) used by the pipelines</li><li>Azure Pipeline to test and deploy the definitions to multiple management groups in multiple tenants</li></ul>
<!-- /wp:list -->

<!-- wp:paragraph -->
<p>I won’t be able to share my experience in one blog post. I’ll cover this topic in a 3-part blog series</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>Part 1:</strong> Custom deployment scripts for policy and initiative definitions</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong><a href="https://blog.tyang.org/2019/05/19/deploying-azure-policy-definitions-via-azure-devops-part-2/">Part 2:</a></strong><a href="https://blog.tyang.org/2019/05/19/deploying-azure-policy-definitions-via-azure-devops-part-2/"> Pester-test policy and initiative definitions in the build pipeline</a></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong><a href="https://blog.tyang.org/2019/05/19/deploying-azure-policy-definitions-via-azure-devops-part-3/">Part 3:</a></strong><a href="https://blog.tyang.org/2019/05/19/deploying-azure-policy-definitions-via-azure-devops-part-3/"> Configuring build (CI) and release (CD) pipelines in Azure DevOps</a></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>NOTE:</strong> all the definitions and deployment scripts I used in this blog post series are located at:  <br><a href="https://github.com/tyconsulting/azurepolicy">https://github.com/tyconsulting/azurepolicy</a> </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>This is the part 1 of the blog series.</p>
<!-- /wp:paragraph -->

<!-- wp:heading {"level":3} -->
<h3>Bulk Deploying Policy and Initiative Definition using PowerShell Scripts</h3>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p><strong>Deploying Policy Definitions using deploy-PolicyDef.ps1</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>As I mentioned earlier, ARM templates is out of the picture, because they can’t be deployed to management groups at this stage. Also, I’m deploying 100+ custom policy definitions, it’s hard to put so many definitions in one or few templates. I prefer having them in individual files so it’s easier to read, develop, update and re-use.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>If you take a look at the official Azure Policy GitHub repo, it’s contribution guide (<a href="https://github.com/Azure/azure-policy/tree/master/1-contribution-guide">https://github.com/Azure/azure-policy/tree/master/1-contribution-guide</a>) mandates that you need to provide 3 files for each policy:</p>
<!-- /wp:paragraph -->

<!-- wp:list -->
<ul><li>azurepolicy.rules.json</li><li>azurepolicy.parameters.json</li><li>azurepolicy.json
<ul><!--EndFragment--></ul>
</li></ul>
<!-- /wp:list -->

<!-- wp:paragraph -->
<p>If you look at these files closely, you will find:</p>
<!-- /wp:paragraph -->

<!-- wp:list -->
<ul><li>azurepolicy.rules.json contains policy rule</li><li>azurepolicy.parameters.json contains parameter definitions (if the policy requires input parameters)</li><li>azurepolicy.json contains
<ul>
<li><span style="background-color: #ffff00;">policy rule</span></li>
<li><span style="background-color: #ffff00;">parameter definitions</span></li>
<li><span style="background-color: #00ff00;">name (it will become a part of of resource Id once deployed)</span></li>
<li><span style="background-color: #00ff00;">display name</span></li>
<li><span style="background-color: #00ff00;">description</span></li>
<li><span style="background-color: #00ff00;">metadata (i.e. policy category, such as Compute, Storage, Monitoring, etc.)</span></li>
</ul>
</li></ul>
<!-- /wp:list -->

<!-- wp:paragraph -->
<p>When using the <strong>New-AzPolicyDefinition</strong> cmdlet to deploy a definition, the cmdlet input parameters expect:</p>
<!-- /wp:paragraph -->

<!-- wp:list -->
<ul><li><span style="background-color: #ffff00;">the policy rule definition (azurepolicy.rules.json)</span></li><li><span style="background-color: #ffff00;">the policy parameter definitions (azurepolicy.parameter.json)</span></li><li><span style="background-color: #00ff00;">name</span></li><li><span style="background-color: #00ff00;">display name</span></li><li><span style="background-color: #00ff00;">description</span></li><li><span style="background-color: #00ff00;">metadata</span></li></ul>
<!-- /wp:list -->

<!-- wp:paragraph -->
<p>So, if the azurepolicy.json already contains everything it needs to create a new definition, why can’t I just pass this file to the cmdlet instead of a mixture of <span style="background-color: #ffff00;">input files</span> and other <span style="background-color: #00ff00;">string inputs</span>? The answer is I can't, the cmdlet does not support it!</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>If I adopt Microsoft’s practice according to the official repo contribution guide, I will need to duplicate the contents of some files, and the file that actually contains everything is not actually been used by the cmdlet!? if I use the New-AzPolicyDefinition cmdlet in my pipeline, not only I need to repeat it over 100 times, but also I need to store name, display name, description and metadata outside of the actual policy definition artifacts (i.e. maybe a variable group in Azure DevOps project). This can become extremely time consuming to configure and maintain the pipeline, because the artifacts doesn’t not contain all the information required.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>As you can imagine, I am not happy with how the New-AzPolicyDefinition is implemented. For those who know me well, you probably have heard me telling people over and over again – Just invoke ARM REST API directly from the PowerShell scripts instead of using the official Azure PowerShell modules.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><s>However, in this case, since I’m use Azure Pipeline to deploy these artifacts, and when using the Azure PowerShell task in Azure Pipeline, the Azure AD oAuth token is protected, I won’t be able to get the token from the sign in context, which means, I would need to generate my own token, which means I need to store a Service Principal key to a key vault, and link the key vault to a variable group in my Azure DevOps project.</s> This is also too complicated. I have done it in the past, it’s hard to maintain, especially you want a group of people to look after the pipeline after initial setup.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>[17/11/2019]: Stefan Stranger has pointed out it is possible to retrieve the AAD token from context token cache using Azure PowerShell task in Azure Pipelines.</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>This led me to create a custom deployment script (<a href="https://github.com/tyconsulting/azurepolicy/blob/master/scripts/deploy-policyDef.ps1" target="_blank" rel="noopener noreferrer">deploy-policyDef.ps1</a>) that leverages New-AzPolicyDefinition, but the script uses azurepolicy.json since it contains all the information that’s needed for creating the policy definition. The script also supports:</p>
<!-- /wp:paragraph -->

<!-- wp:list -->
<ul><li>Supports both management groups and subscriptions</li><li>Deploy multiple policy definitions if multiple file paths are passed in</li><li>Deploy all policy definitions in a folder</li><li>Deploy all policy definitions in a folder and its sub-folders if –recurse switch is used</li><li>If you place policy and initiative definitions all in one folder, it can detect which ones are policy definitions, which ones are initiative definitions</li><li>Supports running it interactively (prompt you to sign in to Azure if not already signed in, or ask you if you want to use the current login context if you’ve already signed in using Connect-AzAccount cmdlet)</li><li>Supports running it in silent mode, which requires an existing login context and no interactive prompt. This is required so I can use the script in a pipeline</li><li>Supports –verbose switch. Many messages have been configured to go to the verbose stream output, to help you troubleshoot issues.</li></ul>
<!-- /wp:list -->

<!-- wp:paragraph -->
<p>For example:</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Deploy a single policy definition to a subscription (interactive mode)</p>
<!-- /wp:paragraph -->

<!-- wp:preformatted -->
<pre class="wp-block-preformatted">./deploy-policyDef.ps1 -definitionFile C:\Temp\azurepolicy.json -subscriptionId cd45c044-18c4-4abe-a908-1e0b79f45003</pre>
<!-- /wp:preformatted -->

<!-- wp:paragraph -->
<p>Deploy all policy definitions in a folder and its sub folders to a management group (silent mode, i.e. in a CI/CD pipeline):</p>
<!-- /wp:paragraph -->

<!-- wp:preformatted -->
<pre class="wp-block-preformatted">./deploy-policyDef.ps1 -FolderPath C:\Temp -recurse -managementGroupName myMG -silent</pre>
<!-- /wp:preformatted -->

<!-- wp:paragraph -->
<p>In my repo, I structured the policy definitions in the file system as shown below:</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>├───policy-definition-root-folder
<br>│&nbsp;&nbsp; ├───target-management-group-name<br>│&nbsp;&nbsp; │&nbsp;&nbsp; ├───policy-1-folder<br>│&nbsp;&nbsp; │&nbsp;&nbsp; └───policy-2-folder</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>In the pipeline, all I needed is to specify the path to the target-management-group-name as the folder path, and use –recurse switch. A one-liner deploys over 100 policy definitions within couple of minutes!</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>Deploying Initiative Definitions using deploy-policySetDef.ps1</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>When working with initiative (policy set) definitions, I’m facing the exact same challenge – the samples in the official repo contribution all contain the following 3 files:</p>
<!-- /wp:paragraph -->

<!-- wp:list -->
<ul><li>azurepolicyset.definitions.json – contains the list of policies included in the initiative</li><li>azurepolicyset.parameters.json – input parameters definitions</li><li>azurepolicyset.json – contains everything</li></ul>
<!-- /wp:list -->

<!-- wp:paragraph -->
<p>Following the same logic, the azurepolicyset.json contains everything, well almost everything! if you look at the sample initiatives, you’ll find some of the azurepolicyset.json files contain the "name" attribute, some don’t. A bit inconsistent there. The "name" is absolutely required when deploy the initiative definition. Similar to policy definitions, the New-PolicySetDefinition cmdlet from Azure PowerShell modules takes the definition and parameters from separate inputs, with some additional string inputs such as name, metadata, etc.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>I wrote a similar script to deploy initiative definitions, called <a href="https://github.com/tyconsulting/azurepolicy/blob/master/scripts/deploy-policySetDef.ps1" target="_blank" rel="noopener noreferrer">deploy-policySetDef.ps1</a>. This script allows you to deploy a single initiative definition using the azurepolicyset.json file.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>I also needed to address the issue that I need to be able to reference custom policy definitions in initiative definitions – the resource Ids for for these custom policy definitions are not static (depending on the target management groups or subscriptions of the deployment) and may even be unknown at the time when the initiatives are defined. The workaround I came up with is replacing a section of resource Ids for policy definitions with a string in the initiative definition, and replace the string at the time of deployment</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>For example, Replace</p>
<!-- /wp:paragraph -->

<!-- wp:preformatted -->
<pre class="wp-block-preformatted">"policyDefinitionid": "/providers/Microsoft.Management/managementgroups/myMG/providers/Microsoft.Authorization/policyDefinitions/restrict-public-storageAccounts-policyDef"</pre>
<!-- /wp:preformatted -->

<!-- wp:paragraph -->
<p>with</p>
<!-- /wp:paragraph -->

<!-- wp:preformatted -->
<pre class="wp-block-preformatted">"policyDefinitionid": "<strong>{policyLocationResourceId1}</strong>/providers/Microsoft.Authorization/policyDefinitions/restrict-public-storageAccounts-policyDef"</pre>
<!-- /wp:preformatted -->

<!-- wp:paragraph -->
<p>The <strong>{policyLocationResourceId1}</strong> represents the actual resource Id for the management group, in this case <strong>/providers/Microsoft.Management/managementgroups/myMG</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>The deploy-policyDef.ps1 is designed to that policy location as a hash table input parameter. i.e.</p>
<!-- /wp:paragraph -->

<!-- wp:preformatted -->
<pre class="wp-block-preformatted">./deploy-policyDef.ps1 -definitionFile C:\Temp\azurepolicyset.json -managementGroupName myMG -PolicyLocations @{policyLocationResourceId1 = '/providers/Microsoft.Management/managementGroups/myMG'}</pre>
<!-- /wp:preformatted -->

<!-- wp:paragraph -->
<p>The <em>-PolicyLocationId</em> parameter expects a hashtable input, you can list one or more replaceable strings, such as: <strong>@{policyLocationResourceId1 = '/providers/Microsoft.Management/managementGroups/myMG'; policyLocationResourceId2 = '/subscriptions/4fa56034-7d12-4ab9-8d9c-1eae722376e9'}</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>When -PolicyLocations parameter is used, the <strong>deploy-policySetDefinition.ps1</strong> script searches strings wrapped in "{}" that match each key from the input hashtable and replaces with the value associated to the key from the hashtable.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>This method enables us to define the initiative definition once, and deploy it to multiple environments in a CI/CD pipeline. It also enables us to deploy the policy definitions that are members of the initiative in the same pipeline by using -PolicyLocation parameter to variableize the deployment destination.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>This concludes the 1st part of this blog series. In the next instalment, I will walk through how I configured Pester tests for policy and initiative definitions.</p>
<!-- /wp:paragraph -->