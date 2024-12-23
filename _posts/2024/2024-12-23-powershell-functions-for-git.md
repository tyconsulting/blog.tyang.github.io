---
title: Various PowerShell Functions for Git
date: 2024-12-23 00:00
author: Tao Yang
permalink: /2024/12/23/powershell-functions-for-git
summary: Several PowerShell helper functions for Git commands
categories:
  - PowerShell
tags:
  - PowerShell
  - Git

---

I hope I am not the only one who's struggling with git commands and parsing the results in PowerShell scripts.

I have created a few PowerShell functions that interact with Git commands in PowerShell scripts over time. I thought I'd share them here in case they are useful to someone else.

I have bundled them into a PowerShell module file [git-functions.psm1](https://github.com/tyconsulting/BlogPosts/blob/master/Scripts/misc/git-functions.psm1). Before using them, firstly import the module in PowerShell: `import-module ./git-functions.psm1'.

I use some of these functions in pipeline scripts and some interactively when I'm using my laptops. I have tested these with the latest Git version `2.47.1` on Windows 11, Ubuntu (WSL) and MacOS Sequoia 15.2.

Here are the functions in the module:

- `Get-GitRoot`: Gets the root directory of the current Git repository.
- `Enter-GitRoot`: Changes the current directory to the root directory of the current Git repository.
- `Get-GitDefaultBranchFromRemote`: Gets the default branch name from the specified remote of a Git repository.
- `Get-GitBranch`: Gets the name of the current Git branch.
- `Get-GitCommitId`: Gets the commit ID of the specified branch or tag.
- `Get-AllGitBranchDetail`: Gets detailed information about all Git branches.
- `Test-BranchName`: Tests if a branch with the specified name exists.
- `Get-CurrentGitRef`: Gets the current Git reference (branch or tag).
- `Get-GitTagSourceBranch`: Gets the source branch of the specified Git tag.
- `Find-CommitIdInBranch`: Checks if a specified commit ID exists in a given branch.

## Get-GitRoot

The `Get-GitRoot` function retrieves the root directory of the current Git repository by running the `git rev-parse --show-toplevel` command. If the directory is found, it returns the absolute path of the Git root directory.

When I am inside of a Git repository (no matter how deep the current working directory is in the folder hierarchy), I can use `Get-GitRoot` to find where the Git root directory is:
![01](../../../../assets/images/2024/12/git-functions-01.jpg)

## Enter-GitRoot

The `Enter-GitRoot` function changes the current directory to the root directory of the current Git repository by calling the `Get-GitRoot` function. If the Git root directory is found, it sets the location to that directory. Otherwise, it displays a warning message.

I have also created an alias `cdgr` for `Enter-GitRoot`. I found I frequently need to go back to the git root command when I'm using the command prompt. So I added the following to my PowerShell profile:

![02](../../../../assets/images/2024/12/git-functions-02.jpg)

I can use the alias `cdgr` to go back to the git root directory when I'm in any sub directories in the repo:

![03](../../../../assets/images/2024/12/git-functions-03.jpg)

## Get-GitDefaultBranchFromRemote

The `Get-GitDefaultBranchFromRemote` function retrieves the default branch name from the specified remote Git repository by running the `git remote show` command and parsing the output. If the branch name is found, it returns the name of the default branch. Otherwise, it throws an error.

![04](../../../../assets/images/2024/12/git-functions-04.jpg)

## Get-GitBranch

The `Get-GitBranch` function retrieves the name of the current Git branch by running the `git branch --show-current` command. It returns the name of the branch as a string.

![05](../../../../assets/images/2024/12/git-functions-05.jpg)

## Get-GitCommitId

The `Get-GitCommitId` function retrieves the commit ID of the specified branch or tag by running the `git rev-list -n 1` command. It returns the commit ID as a string.

![06](../../../../assets/images/2024/12/git-functions-06.jpg)

## Get-AllGitBranchDetail

The `Get-AllGitBranchDetail` function retrieves detailed information about all Git branches by running the `git branch -va` command. It fetches the latest branch information, parses the output, and returns an array of custom objects containing branch details such as name, commit ID, commit message, and whether the branch is current, default, remote, or local.

![07](../../../../assets/images/2024/12/git-functions-07.jpg)

## Test-BranchName

The `Test-BranchName` function checks if a branch with the specified name exists by retrieving detailed information about all Git branches using the `Get-AllGitBranchDetail` function. It returns a boolean value indicating whether the branch exists.

![08](../../../../assets/images/2024/12/git-functions-08.jpg)

## Get-CurrentGitRef

The `Get-CurrentGitRef` function retrieves the current Git reference, which can be either a branch or a tag. It first attempts to get the branch name using the `git branch --show-current` command. If no branch name is found, it tries to get the tag name using the `git describe --tags --exact-match` command. If neither is found, it checks for pre-defined environment variables from GitHub Actions or Azure DevOps to determine the reference. It returns a custom object containing the reference name and its type (branch or tag).

![09](../../../../assets/images/2024/12/git-functions-09.jpg)

## Get-GitTagSourceBranch

The `Get-GitTagSourceBranch` function retrieves the source branch of the specified Git tag by running the `git branch --contains` command. It filters out any lines indicating a detached HEAD state and validates the branch names. It returns an array of branch names that contain the specified tag.

![10](../../../../assets/images/2024/12/git-functions-10.jpg)

## Find-CommitIdInBranch

The `Find-CommitIdInBranch` function checks if a specified commit ID exists in a given branch by retrieving all commit IDs of the branch using the `git rev-list` command. It returns a boolean value indicating whether the commit ID is found in the branch.

![11](../../../../assets/images/2024/12/git-functions-11.jpg)

