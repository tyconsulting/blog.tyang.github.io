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

This is the 3rd and final installment of the 3-part blog series. You can find the other parts here:

**<a href="https://blog.tyang.org/2019/05/19/deploying-azure-policy-definitions-via-azure-devops-part-1/">Part 1:</a>**<a href="https://blog.tyang.org/2019/05/19/deploying-azure-policy-definitions-via-azure-devops-part-1/"> Custom deployment scripts for policy and initiative definitions</a>

**<a href="https://blog.tyang.org/2019/05/19/deploying-azure-policy-definitions-via-azure-devops-part-2/">Part 2:</a>**<a href="https://blog.tyang.org/2019/05/19/deploying-azure-policy-definitions-via-azure-devops-part-2/"> Pester-test policy and initiative definitions in the build pipeline</a>

**Part 3:** Configuring build (CI) and release (CD) pipelines in Azure DevOps

In this part, I will walk through how I configured the build and release pipelines for deploying policy and initiative definitions at scale.

## Pre-requisites

The following pre-requisistes are required before start creating the pipelines:

**1. Creating Azure AD Service Principals**

We need to create service principals in each Azure AD tenant that you are deploying the definitions to. The Service Principals need to have permission to deploy policy and initiative definitions to the target management groups or subscriptions. the minimum Azure RBAC role required is **Resource Policy Contributor**. You can assign the RBAC role to the management group or subscription that you are deploying the definitions to, or to a parent management group. For me, since I will also use the same service principal in other pipelines, I have assigned Owner role on the Tenant Root management group.

**2. Publish AzPolicyTest and Pester modules to an Azure Artifacts feed**

The <a href="https://github.com/tyconsulting/AzPolicyTest">AzPolicyTest </a>PowerShell module is required to perform pester tests in the build pipeline. both AzPolicyTest and its dependency Pester need to be publish to an Azure Artifacts feed. this is explained in details in part 2.

## Storing the definition and deployment scripts in Azure Repo

Before creating the pipelines, firstly, create an Azure repo in your DevOps project and store the definition files and deployment scripts in the repo.

Again, everything I used in this blog post is stored in my public GitHub repo: <a href="https://github.com/tyconsulting/azurepolicy">https://github.com/tyconsulting/azurepolicy</a>, although the folder structure is slightly different in the Azure Repo I created. This is how I structured the files in the Azure Repo (as explained in part 1):

<a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-3.png"><img src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-3.png" alt="image"/></a>

The reason I’m placing everything under the "tenant-root-mg" folder is that all these definitions are going to the tenant root management group in each tenant, I am planning to add additional definitions targeting child management groups later. by placing them in different folders, I can set triggers in build-pipeline to filter on the file path.

## Creating Service Connections

you will need to create a service connection for each of the stage (environment) in the DevOps project. depending on the target, you may create the connection to a management group, or to a subscription. Use the service principal created earlier, and make sure you verify the connection before continuing to the next step.


<a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-4.png"><img src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-4.png" alt="image"/></a>

## Creating Variable Groups

I normally create a variable group that stores common variables that are consistent among all stages, and individual groups for values that are different in each stage.

I created a variable group called "common", stored a variable called ArtifactsFeedName in it. As the name suggests, the value is the name of your Azure Artifacts feed name.

<a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-5.png"><img src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-5.png" alt="image"/></a>

I also created a separate variable group for each stage, storing the target management group name in a variable called "MGName":

<a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-6.png"><img src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-6.png" alt="image"/></a>

## Creating Build (CI) Pipeline

Here’s what the build pipeline looks like:

<a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-7.png"><img src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-7.png" alt="image"/></a>

Steps:

**1. Select an agent pool for the pipeline, I’m using Hosted Windows 2019 with VS2019**

<a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-8.png"><img src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-8.png" alt="image"/></a>

**2. Link the common variable group to the pipeline.**

**3. Get sources – select the source from the Azure Repo**

<a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-9.png"><img src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-9.png" alt="image"/></a>

**4. Create an agent job called "Test Policy and Initiative Definitions"**

Make sure "Allow scripts to access the OAuth token" is ticked

<a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-10.png"><img src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-10.png" alt="image"/></a>

This job contains a number of steps executing PowerShell scripts, and the final step publishes test results.

Yaml definition:

```yml
pool:
   name: Hosted Windows 2019 with VS2019
steps:
- powershell: |
    $colURI = [uri]::New("$(System.TeamFoundationCollectionUri)")
    if ("$(System.TeamFoundationCollectionUri)" -match "visualstudio.com")
    {
    $org = $colURI.Authority.split('.')[0]
    $feedURI = "https://pkgs.dev.azure.com/$org/_packaging/" + "$(ArtifactsFeedName)" + "/nuget/v2"
    } else {
    $pkgAuth = "pkgs.$($colURI.Authority)"
    $feedURI = "https://$pkgAuth" + "$($colURI.AbsolutePath)" + "_packaging/" + "$(ArtifactsFeedName)" + "/nuget/v2"
    }
    Write-output "Azure Artifacts Feed URI: $feedURI"
    Write-Output ("##vso[task.setvariable variable=feedURI]$($feedURI)")
   displayName: 'Get Azure Artifact Feed URI'


- powershell: 'Register-PSRepository -Name "$(ArtifactsFeedName)" -SourceLocation "$(feedURI)" -PublishLocation "$(feedURI)" -InstallationPolicy Trusted'
   displayName: 'Register PS repository for Azure Artifacts Feed'


- powershell: |
    $pw = ConvertTo-SecureString '$(System.AccessToken)' -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential 'abc', $pw
    Install-Module Pester -Repository $(ArtifactsFeedName) -Credential $cred -force -scope CurrentUser
    Install-Module AzPolicyTest -Repository $(ArtifactsFeedName) -Credential $cred -force -scope CurrentUser
   displayName: 'Install required PowerShell modules'


- powershell: |
    Import-Module AzPolicyTest
    Test-JSONContent -path $(Build.SourcesDirectory)\tenant-root-mg\policy-definitions -OutputFile $(Build.SourcesDirectory)\TEST-tenant-root-mg-Policy.JSCONContent.XML
    Test-AzPolicyDefinition -Path $(Build.SourcesDirectory)\tenant-root-mg\policy-definitions -OutputFile $(Build.SourcesDirectory)\TEST-tenant-root-mg-PolicyDefinition.XML
   errorActionPreference: continue
   displayName: 'Pester Test Azure Policy Definitions'


- powershell: |
    Import-Module AzPolicyTest
    Test-JSONContent -path $(Build.SourcesDirectory)\tenant-root-mg\initiative-definitions -OutputFile $(Build.SourcesDirectory)\TEST-tenant-root-mg-Initiative.JSCONContent.XML
    Test-AzPolicySetDefinition -Path $(Build.SourcesDirectory)\tenant-root-mg\initiative-definitions -OutputFile $(Build.SourcesDirectory)\TEST-tenant-root-mg-InitiativeDefinition.XML
   errorActionPreference: continue
   displayName: 'Pester Test Azure Policy Initiative Definitions'


- task: PublishTestResults@2
   displayName: 'Publish Test Results **\TEST-*.xml'
   inputs:
     testResultsFormat: NUnit
     testResultsFiles: '**\TEST-*.xml'
     failTaskOnFailedTests: true
```
**5. Create Another agent Job called Publish Artifacts**

Yaml Definition:

```yml
dependsOn: Job_1
pool:
   name: Hosted Windows 2019 with VS2019
steps:
- task: CopyFiles@2
   displayName: 'Copy Files to: $(Build.ArtifactStagingDirectory)'
   inputs:
     SourceFolder: '$(Build.SourcesDirectory)'
     TargetFolder: '$(Build.ArtifactStagingDirectory)'
     CleanTargetFolder: true
     OverWrite: true
```

**6. Setup triggers:**

I enabled continuous integration, and filtered on the path:

<a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-11.png"><img src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-11.png" alt="image"/></a>

## Create Release (CD) Pipeline

In my demo environment, I have created 2 stages, for 2 separate Azure AD tenants:

<a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-12.png"><img src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-12.png" alt="image"/></a>

Steps:

**1. Select Artifacts (from the build pipeline):**

<a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-13.png"><img src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-13.png" alt="image"/></a>

**2. Create a stage:**

<a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-14.png"><img src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-14.png" alt="image"/></a>

**3. Link the stage-specific variable group that contains the MGName to this stage:**

<a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-15.png"><img src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-15.png" alt="image"/></a>

**4. In the stage, create an agent job called "Deploy Policy Definition"**

It contains a single step that uses Azure PowerShell task to bulk deploy policy definitions to the target management group (or subscription). Here’s the Yaml definition for the "Deploy Policy Definitions to MG" task:

```yml
steps:
- task: AzurePowerShell@4
   displayName: 'Deploy Policy Definitions to MG'
   inputs:
     azureSubscription: 'mg-tenant-root-ty-lab'
     ScriptPath: '$(System.DefaultWorkingDirectory)/_Azure.Policy-CI/drop/scripts/deploy-policyDef.ps1'
     ScriptArguments: '-folderpath "$(System.DefaultWorkingDirectory)/_Azure.Policy-CI/drop/tenant-root-mg/policy-definitions" -recurse -managementGroupName "$(MGName)" -silent'
     FailOnStandardError: true
     azurePowerShellVersion: LatestVersion
```

>**Note:** You must use version 4 of this task because previous versions don’t support the new Azure PowerShell Az modules, and make sure you select the correct Service Connection (that you created earlier)

**5. Create another agent job to deploy initiative definitions.**

Make sure it’s configured to only run when all previous jobs have succeeded. This ensures all custom policy definitions are deployed before you group them into initiatives (potentially):

<a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-16.png"><img src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-16.png" alt="image"/></a>

For reach Initiative definition, create an Azure PowerShell task (version 4). The Yaml definition for the step is similar to this:


```yml
steps:
- task: AzurePowerShell@4
   displayName: 'Initiative: resource-diag-settings-LA'
   inputs:
     azureSubscription: 'mg-tenant-root-ty-lab'
     ScriptPath: '$(System.DefaultWorkingDirectory)/_Azure.Policy-CI/drop/scripts/deploy-policySetDef.ps1'
     ScriptArguments: '-definitionFile "$(System.DefaultWorkingDirectory)/_Azure.Policy-CI/drop/tenant-root-mg/initiative-definitions/resource-diagnostics-settings/log-analytics/azurepolicyset-la.json" -managementGroupName "$(MGName)" -PolicyLocations @{policyLocationResourceId1 = ''/providers/Microsoft.Management/managementGroups/$(MGName)'} -silent'
     FailOnStandardError: true
     azurePowerShellVersion: LatestVersion
```

**6. Repeat Step 5 for each initiative definition that you wish to deploy**

**7. Repeat step 2-6 for each stage, and chain the stages together**

**8. You might want to setup pre-approval for certain stages (i.e. production stage)**

<a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-17.png"><img src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-17.png" alt="image"/></a>

## Executing the pipelines:

Build:

<a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-18.png"><img src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-18.png" alt="image"/></a>

Release:

<a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-19.png"><img src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-19.png" alt="image"/></a>

<a href="https://blog.tyang.org/wp-content/uploads/2019/05/image-20.png"><img src="https://blog.tyang.org/wp-content/uploads/2019/05/image_thumb-20.png" alt="image"/></a>

## Conclusion

Please only use the above steps as a reference since each environment is different. But the pipelines are pretty easy to setup. For me, the most time consuming part is to develop the deployment scripts (part 1), and the Pester test module (part 2).

In this demo, I have deployed 100+ custom policy and 3 initiative definitions to 2 tenant root management groups in 2 separate Azure AD tenants.

In the build pipeline, I was able to use a single command to pester test syntax of all policy definitions and another one-liner for all initiative syntax. It can’t get easier than that.

By using the custom deployment scripts, I managed to deploy all the policy  and initiatives definitions to a management group in around 2 and half minutes. Previously, when I was using ARM template to deploy around 50 definitions (for resource diagnostic settings), it took a lot longer than that.

I have spent couple of weeks working on this solution, I though I’m obligated to share my experience with the greater community. I hope you’ll find this blog series helpful. I am certainly going to re-use the code I shared here in the future.