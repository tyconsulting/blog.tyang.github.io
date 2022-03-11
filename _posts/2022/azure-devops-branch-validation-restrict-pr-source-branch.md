---
title: Using Azure DevOps Branch Policy To Restrict PR Source Branch
date: 2022-03-11 21:00
author: Tao Yang
permalink: /2022/03/11/ado-branch-policy-restrict-pr-source-branch
summary:
categories:
  - Azure DevOps
tags:
  - Azure DevOps
  - Azure Pipeline
  - DevOps
  - Infrastructure As Code

---

Today I had a requirement to protect a Git branch in an Azure DevOps repo that only allow merging from a specific source branch. i.e. An **archive** branch must only be updated from the default **main** branch.

When I looked into the Branch Policies in Azure DevOps, it doesn't look like there is a native way to achieve this. So I created a simple build validation pipeline that checks the PR source branch and configured it to be triggered automatically in the Branch Policies for the branch that I want to protect.

![01](../../../../assets/images/2022/03/ado-build-validation-01.jpg)

The pipeline uses a reusable YAML pipeline template so it's easy to create such pipelines for multiple branches if required.

**Pipeline Template**

```yml
#template-branch-policy-validation.yml
parameters:
- name: agentPoolName
  displayName: "Agent Pool Name"
  type: string
  default: "windows-latest"
- name: allowedSourceBranchName
  displayName: Allowed Source branch name
  type: string
  default: "refs/heads/main"

stages:
- stage: branch_policy_build_validation
  displayName: "Branch Policy Build Validation"
  jobs:
  - job: source_branch_validation
    displayName: Source Branch Validation
    pool:
      vmImage: "${{parameters.agentPoolName}}"
    steps:
      - pwsh: |
          if ('$(System.PullRequest.SourceBranch)' -ieq '${{parameters.allowedSourceBranchName}}' -or '$(System.PullRequest.SourceBranch)' -ieq 'refs/heads/${{parameters.allowedSourceBranchName}}') {
            Write-Host "Source branch '$(System.PullRequest.SourceBranch)' is allowed"
          } else {
            Throw "Source branch '$(System.PullRequest.SourceBranch)' is not allowed. Only the '${{parameters.allowedSourceBranchName}}' branch is allowed."
            exit 1
          }
        displayName: "Check Build Source Branch"
        errorActionPreference: Stop
      
```

**Build Validation Pipeline**

>**NOTE**: In this example, the YAML pipeline template folder is placed in the `templates/` sub-folder of where the YAML pipeline is located.

```yml
#azure-pipelines-archive-branch-build-validation.yml
name: $(BuildDefinitionName)_$(SourceBranchName)_$(Date:yyyyMMdd)$(Rev:.r)
trigger: none

stages:
  - template: templates/template-branch-policy-validation.yml
    parameters:
      allowedSourceBranchName: "main"
```

Once this is setup, I can only merge into this **archive** branch from **main** branch:

![02](../../../../assets/images/2022/03/ado-build-validation-02.jpg)
![03](../../../../assets/images/2022/03/ado-build-validation-03.jpg)

If I create a PR from a branch other than **main**, the validation will fail and I am not able to complete the PR and merge the code:

![04](../../../../assets/images/2022/03/ado-build-validation-04.jpg)
![05](../../../../assets/images/2022/03/ado-build-validation-05.jpg)

The YAML pipeline and pipeline template can also be found from my BlogPost GitHub repo **[HERE](https://github.com/tyconsulting/BlogPosts/tree/master/azure-pipelines/build-validation)**.
