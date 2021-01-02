---
id: 7060
title: Deploying Azure Policy Definitions via Azure DevOps (Part 3)
date: 2019-05-19T23:12:41+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=7060
permalink: /2019/05/19/deploying-azure-policy-definitions-via-azure-devops-part-3/
categories:
  - Azure
tags:
  - Azure
  - Azure DevOps
  - Azure Policy
  - DevOpsAzurePolicySeries
---
<!-- wp:paragraph -->
<p>This is the 3rd and final installment of the 3-part blog series. You can find the other parts here:</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong><a href="https://blog.tyang.org/2019/05/19/deploying-azure-policy-definitions-via-azure-devops-part-1/">Part 1:</a></strong><a href="https://blog.tyang.org/2019/05/19/deploying-azure-policy-definitions-via-azure-devops-part-1/"> Custom deployment scripts for policy and initiative definitions</a></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong><a href="https://blog.tyang.org/2019/05/19/deploying-azure-policy-definitions-via-azure-devops-part-2/">Part 2:</a></strong><a href="https://blog.tyang.org/2019/05/19/deploying-azure-policy-definitions-via-azure-devops-part-2/"> Pester-test policy and initiative definitions in the build pipeline</a></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>Part 3:</strong> Configuring build (CI) and release (CD) pipelines in Azure DevOps</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>In this part, I will walk through how I configured the build and release pipelines for deploying policy and initiative definitions at scale.</p>
<!-- /wp:paragraph -->

<!-- wp:heading {"level":3} -->

## Pre-requisites

<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>The following pre-requisistes are required before start creating the pipelines:</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>1. Creating Azure AD Service Principals</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>We need to create service principals in each Azure AD tenant that you are deploying the definitions to. The Service Principals need to have permission to deploy policy and initiative definitions to the target management groups or subscriptions. the minimum Azure RBAC role required is <strong>Resource Policy Contributor</strong>. You can assign the RBAC role to the management group or subscription that you are deploying the definitions to, or to a parent management group. For me, since I will also use the same service principal in other pipelines, I have assigned Owner role on the Tenant Root management group.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>2. Publish AzPolicyTest and Pester modules to an Azure Artifacts feed</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>The <a href="https://github.com/tyconsulting/AzPolicyTest">AzPolicyTest </a>PowerShell module is required to perform pester tests in the build pipeline. both AzPolicyTest and its dependency Pester need to be publish to an Azure Artifacts feed. this is explained in details in part 2.</p>
<!-- /wp:paragraph -->

<!-- wp:heading {"level":3} -->

## Storing the definition and deployment scripts in Azure Repo

<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>Before creating the pipelines, firstly, create an Azure repo in your DevOps project and store the definition files and deployment scripts in the repo.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Again, everything I used in this blog post is stored in my public GitHub repo: <a href="https://github.com/tyconsulting/azurepolicy">https://github.com/tyconsulting/azurepolicy</a>, although the folder structure is slightly different in the Azure Repo I created. This is how I structured the files in the Azure Repo (as explained in part 1):</p>
<!-- /wp:paragraph -->

<!-- wp:image {"linkDestination":"custom"} -->
<figure class="wp-block-image"><a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-3.png"><img src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-3.png" alt="image"/></a></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>The reason I’m placing everything under the "tenant-root-mg" folder is that all these definitions are going to the tenant root management group in each tenant, I am planning to add additional definitions targeting child management groups later. by placing them in different folders, I can set triggers in build-pipeline to filter on the file path.</p>
<!-- /wp:paragraph -->

<!-- wp:heading {"level":3} -->

## Creating Service Connections

<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>you will need to create a service connection for each of the stage (environment) in the DevOps project. depending on the target, you may create the connection to a management group, or to a subscription. Use the service principal created earlier, and make sure you verify the connection before continuing to the next step.</p>
<!-- /wp:paragraph -->

<!-- wp:image {"linkDestination":"custom"} -->
<figure class="wp-block-image"><a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-4.png"><img src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-4.png" alt="image"/></a></figure>
<!-- /wp:image -->

<!-- wp:heading {"level":3} -->

## Creating Variable Groups

<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>I normally create a variable group that stores common variables that are consistent among all stages, and individual groups for values that are different in each stage.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>I created a variable group called "common", stored a variable called ArtifactsFeedName in it. As the name suggests, the value is the name of your Azure Artifacts feed name.</p>
<!-- /wp:paragraph -->

<!-- wp:image {"linkDestination":"custom"} -->
<figure class="wp-block-image"><a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-5.png"><img src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-5.png" alt="image"/></a></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>I also created a separate variable group for each stage, storing the target management group name in a variable called "MGName":</p>
<!-- /wp:paragraph -->

<!-- wp:image {"linkDestination":"custom"} -->
<figure class="wp-block-image"><a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-6.png"><img src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-6.png" alt="image"/></a></figure>
<!-- /wp:image -->

<!-- wp:heading {"level":3} -->

## Creating Build (CI) Pipeline

<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>Here’s what the build pipeline looks like:</p>
<!-- /wp:paragraph -->

<!-- wp:image {"linkDestination":"custom"} -->
<figure class="wp-block-image"><a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-7.png"><img src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-7.png" alt="image"/></a></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>Steps:</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>1. Select an agent pool for the pipeline, I’m using <em>Hosted Windows 2019 with VS2019</em></strong></p>
<!-- /wp:paragraph -->

<!-- wp:image {"linkDestination":"custom"} -->
<figure class="wp-block-image"><a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-8.png"><img src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-8.png" alt="image"/></a></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p><strong>2. Link the common variable group to the pipeline.</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>3. Get sources – select the source from the Azure Repo</strong></p>
<!-- /wp:paragraph -->

<!-- wp:image {"linkDestination":"custom"} -->
<figure class="wp-block-image"><a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-9.png"><img src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-9.png" alt="image"/></a></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p><strong>4. Create an agent job called "Test Policy and Initiative Definitions". </strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Make sure "Allow scripts to access the OAuth token" is ticked</p>
<!-- /wp:paragraph -->

<!-- wp:image {"linkDestination":"custom"} -->
<figure class="wp-block-image"><a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-10.png"><img src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-10.png" alt="image"/></a></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>This job contains a number of steps executing PowerShell scripts, and the final step publishes test results.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Yaml definition:</p>
<!-- /wp:paragraph -->

<!-- wp:preformatted -->
<pre class="wp-block-preformatted">pool:<br>&nbsp;&nbsp; name: Hosted Windows 2019 with VS2019
<p>steps:<br>- powershell: |<br>&nbsp;&nbsp;&nbsp; $colURI = [uri]::New("$(System.TeamFoundationCollectionUri)")<br>&nbsp;&nbsp;&nbsp; if ("$(System.TeamFoundationCollectionUri)" -match "visualstudio.com")<br>&nbsp;&nbsp;&nbsp; {<br>&nbsp;&nbsp;&nbsp; $org = $colURI.Authority.split('.')[0]<br>&nbsp;&nbsp;&nbsp; $feedURI = "<a href="https://pkgs.dev.azure.com/">https://pkgs.dev.azure.com/</a>$org/_packaging/" + "$(ArtifactsFeedName)" + "/nuget/v2"<br>&nbsp;&nbsp;&nbsp; } else {<br>&nbsp;&nbsp;&nbsp; $pkgAuth = "pkgs.$($colURI.Authority)"<br>&nbsp;&nbsp;&nbsp; $feedURI = "<a href="https://$pkgAuth"">https://$pkgAuth"</a> + "$($colURI.AbsolutePath)" + "_packaging/" + "$(ArtifactsFeedName)" + "/nuget/v2"<br>&nbsp;&nbsp;&nbsp; }<br>&nbsp;&nbsp;&nbsp; Write-output "Azure Artifacts Feed URI: $feedURI"<br>&nbsp;&nbsp;&nbsp; Write-Output ("##vso[task.setvariable variable=feedURI]$($feedURI)")<br>&nbsp;&nbsp; displayName: 'Get Azure Artifact Feed URI'</p>
<p>- powershell: 'Register-PSRepository -Name "$(ArtifactsFeedName)" -SourceLocation "$(feedURI)" -PublishLocation "$(feedURI)" -InstallationPolicy Trusted'<br>&nbsp;&nbsp; displayName: 'Register PS repository for Azure Artifacts Feed'</p>
<p>- powershell: |<br>&nbsp;&nbsp;&nbsp; $pw = ConvertTo-SecureString '$(System.AccessToken)' -AsPlainText -Force<br>&nbsp;&nbsp;&nbsp; $cred = New-Object System.Management.Automation.PSCredential 'abc', $pw<br>&nbsp;&nbsp;&nbsp; Install-Module Pester -Repository $(ArtifactsFeedName) -Credential $cred -force -scope CurrentUser<br>&nbsp;&nbsp;&nbsp; Install-Module AzPolicyTest -Repository $(ArtifactsFeedName) -Credential $cred -force -scope CurrentUser<br>&nbsp;&nbsp; displayName: 'Install required PowerShell modules'</p>
<p>- powershell: |<br>&nbsp;&nbsp;&nbsp; Import-Module AzPolicyTest<br>&nbsp;&nbsp;&nbsp; Test-JSONContent -path $(Build.SourcesDirectory)\tenant-root-mg\policy-definitions -OutputFile $(Build.SourcesDirectory)\TEST-tenant-root-mg-Policy.JSCONContent.XML<br>&nbsp;&nbsp;&nbsp; Test-AzPolicyDefinition -Path $(Build.SourcesDirectory)\tenant-root-mg\policy-definitions -OutputFile $(Build.SourcesDirectory)\TEST-tenant-root-mg-PolicyDefinition.XML<br>&nbsp;&nbsp; errorActionPreference: continue<br>&nbsp;&nbsp; displayName: 'Pester Test Azure Policy Definitions'</p>
<p>- powershell: |<br>&nbsp;&nbsp;&nbsp; Import-Module AzPolicyTest<br>&nbsp;&nbsp;&nbsp; Test-JSONContent -path $(Build.SourcesDirectory)\tenant-root-mg\initiative-definitions -OutputFile $(Build.SourcesDirectory)\TEST-tenant-root-mg-Initiative.JSCONContent.XML<br>&nbsp;&nbsp;&nbsp; Test-AzPolicySetDefinition -Path $(Build.SourcesDirectory)\tenant-root-mg\initiative-definitions -OutputFile $(Build.SourcesDirectory)\TEST-tenant-root-mg-InitiativeDefinition.XML<br>&nbsp;&nbsp; errorActionPreference: continue<br>&nbsp;&nbsp; displayName: 'Pester Test Azure Policy Initiative Definitions'</p>
<p>- task: PublishTestResults@2<br>&nbsp;&nbsp; displayName: 'Publish Test Results **\TEST-*.xml'<br>&nbsp;&nbsp; inputs:<br>&nbsp;&nbsp;&nbsp;&nbsp; testResultsFormat: NUnit<br>&nbsp;&nbsp;&nbsp;&nbsp; testResultsFiles: '**\TEST-*.xml'<br>&nbsp;&nbsp;&nbsp;&nbsp; failTaskOnFailedTests: true</p>
```
<!-- /wp:preformatted -->

<!-- wp:paragraph -->
<p><strong>5. Create Another agent Job called Publish Artifacts</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Yaml Definition:</p>
<!-- /wp:paragraph -->

<!-- wp:preformatted -->
<pre class="wp-block-preformatted">dependsOn: Job_1
pool:
&nbsp;&nbsp; name: Hosted Windows 2019 with VS2019
steps:
- task: CopyFiles@2
&nbsp;&nbsp; displayName: 'Copy Files to: $(Build.ArtifactStagingDirectory)'
&nbsp;&nbsp; inputs:
&nbsp;&nbsp;&nbsp;&nbsp; SourceFolder: '$(Build.SourcesDirectory)'
&nbsp;&nbsp;&nbsp;&nbsp; TargetFolder: '$(Build.ArtifactStagingDirectory)'
&nbsp;&nbsp;&nbsp;&nbsp; CleanTargetFolder: true
&nbsp;&nbsp;&nbsp;&nbsp; OverWrite: true
```
<!-- /wp:preformatted -->

<!-- wp:paragraph -->
<p><strong>6. Setup triggers:</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>I enabled continuous integration, and filtered on the path:</p>
<!-- /wp:paragraph -->

<!-- wp:image {"linkDestination":"custom"} -->
<figure class="wp-block-image"><a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-11.png"><img src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-11.png" alt="image"/></a></figure>
<!-- /wp:image -->

<!-- wp:heading {"level":3} -->

## Create Release (CD) Pipeline

<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>In my demo environment, I have created 2 stages, for 2 separate Azure AD tenants:</p>
<!-- /wp:paragraph -->

<!-- wp:image {"linkDestination":"custom"} -->
<figure class="wp-block-image"><a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-12.png"><img src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-12.png" alt="image"/></a></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>Steps:</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>1. Select Artifacts (from the build pipeline):</strong></p>
<!-- /wp:paragraph -->

<!-- wp:image {"linkDestination":"custom"} -->
<figure class="wp-block-image"><a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-13.png"><img src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-13.png" alt="image"/></a></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p><strong>2. Create a stage:</strong></p>
<!-- /wp:paragraph -->

<!-- wp:image {"linkDestination":"custom"} -->
<figure class="wp-block-image"><a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-14.png"><img src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-14.png" alt="image"/></a></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p><strong>3. Link the stage-specific variable group that contains the MGName to this stage:</strong></p>
<!-- /wp:paragraph -->

<!-- wp:image {"linkDestination":"custom"} -->
<figure class="wp-block-image"><a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-15.png"><img src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-15.png" alt="image"/></a></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p><strong>4. In the stage, create an agent job called "Deploy Policy Definition". </strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>It contains a single step that uses Azure PowerShell task to bulk deploy policy definitions to the target management group (or subscription). Here’s the Yaml definition for the "Deploy Policy Definitions to MG" task:
</p>
<!-- /wp:paragraph -->

<!-- wp:preformatted -->
<pre class="wp-block-preformatted">steps:
- task: AzurePowerShell@4
&nbsp;&nbsp; displayName: 'Deploy Policy Definitions to MG'
&nbsp;&nbsp; inputs:
&nbsp;&nbsp;&nbsp;&nbsp; azureSubscription: 'mg-tenant-root-ty-lab'
&nbsp;&nbsp;&nbsp;&nbsp; ScriptPath: '$(System.DefaultWorkingDirectory)/_Azure.Policy-CI/drop/scripts/deploy-policyDef.ps1'
&nbsp;&nbsp;&nbsp;&nbsp; ScriptArguments: '-folderpath "$(System.DefaultWorkingDirectory)/_Azure.Policy-CI/drop/tenant-root-mg/policy-definitions" -recurse -managementGroupName "$(MGName)" -silent'
&nbsp;&nbsp;&nbsp;&nbsp; FailOnStandardError: true
&nbsp;&nbsp;&nbsp;&nbsp; azurePowerShellVersion: LatestVersion
```
<!-- /wp:preformatted -->

<!-- wp:quote -->
<blockquote class="wp-block-quote"><p><strong>Note:</strong> You must use version 4 of this task because previous versions don’t support the new Azure PowerShell Az modules, and make sure you select the correct Service Connection (that you created earlier)</p></blockquote>
<!-- /wp:quote -->

<!-- wp:paragraph -->
<p><strong>5. Create another agent job to deploy initiative definitions.</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Make sure it’s configured to only run when all previous jobs have succeeded. This ensures all custom policy definitions are deployed before you group them into initiatives (potentially):</p>
<!-- /wp:paragraph -->

<!-- wp:image {"linkDestination":"custom"} -->
<figure class="wp-block-image"><a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-16.png"><img src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-16.png" alt="image"/></a></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>For reach Initiative definition, create an Azure PowerShell task (version 4). The Yaml definition for the step is similar to this:</p>
<!-- /wp:paragraph -->

<!-- wp:html -->
<pre language="YAML">
<p>steps:<br>- task: AzurePowerShell@4<br>&nbsp;&nbsp; displayName: 'Initiative: resource-diag-settings-LA'<br>&nbsp;&nbsp; inputs:<br>&nbsp;&nbsp;&nbsp;&nbsp; azureSubscription: 'mg-tenant-root-ty-lab'<br>&nbsp;&nbsp;&nbsp;&nbsp; ScriptPath: '$(System.DefaultWorkingDirectory)/_Azure.Policy-CI/drop/scripts/deploy-policySetDef.ps1'<br>&nbsp;&nbsp;&nbsp;&nbsp; ScriptArguments: '-definitionFile "$(System.DefaultWorkingDirectory)/_Azure.Policy-CI/drop/tenant-root-mg/initiative-definitions/resource-diagnostics-settings/log-analytics/azurepolicyset-la.json" -managementGroupName "$(MGName)" -PolicyLocations @{policyLocationResourceId1 = ''/providers/Microsoft.Management/managementGroups/$(MGName)'} -silent'<br>&nbsp;&nbsp;&nbsp;&nbsp; FailOnStandardError: true<br>&nbsp;&nbsp;&nbsp;&nbsp; azurePowerShellVersion: LatestVersion</p>

```
<!-- /wp:html -->

<!-- wp:paragraph -->
<p>6. Repeat Step 5 for each initiative definition that you wish to deploy</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>7. Repeat step 2-6 for each stage, and chain the stages together</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>8. You might want to setup pre-approval for certain stages (i.e. production stage)</p>
<!-- /wp:paragraph -->

<!-- wp:image {"linkDestination":"custom"} -->
<figure class="wp-block-image"><a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-17.png"><img src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-17.png" alt="image"/></a></figure>
<!-- /wp:image -->

<!-- wp:heading {"level":3} -->

## Executing the pipelines:

<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>Build:</p>
<!-- /wp:paragraph -->

<!-- wp:image {"linkDestination":"custom"} -->
<figure class="wp-block-image"><a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-18.png"><img src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-18.png" alt="image"/></a></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>Release:</p>
<!-- /wp:paragraph -->

<!-- wp:image {"linkDestination":"custom"} -->
<figure class="wp-block-image"><a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-19.png"><img src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-19.png" alt="image"/></a></figure>
<!-- /wp:image -->

<!-- wp:image {"linkDestination":"custom"} -->
<figure class="wp-block-image"><a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-20.png"><img src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-20.png" alt="image"/></a></figure>
<!-- /wp:image -->

<!-- wp:heading {"level":3} -->

## Conclusion

<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>Please only use the above steps as a reference since each environment is different. But the pipelines are pretty easy to setup. For me, the most time consuming part is to develop the deployment scripts (part 1), and the Pester test module (part 2).</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>In this demo, I have deployed 100+ custom policy and 3 initiative definitions to 2 tenant root management groups in 2 separate Azure AD tenants.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>In the build pipeline, I was able to use a single command to pester test syntax of all policy definitions and another one-liner for all initiative syntax. It can’t get easier than that.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>By using the custom deployment scripts, I managed to deploy all the policy  and initiatives definitions to a management group in around 2 and half minutes. Previously, when I was using ARM template to deploy around 50 definitions (for resource diagnostic settings), it took a lot longer than that.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>I have spent couple of weeks working on this solution, I though I’m obligated to share my experience with the greater community. I hope you’ll find this blog series helpful. I am certainly going to re-use the code I shared here in the future.</p>
<!-- /wp:paragraph -->