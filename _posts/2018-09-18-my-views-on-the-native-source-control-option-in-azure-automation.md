---
id: 6635
title: My Views on the Native Source Control Option in Azure Automation
date: 2018-09-18T18:02:45+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=6635
permalink: /2018/09/18/my-views-on-the-native-source-control-option-in-azure-automation/
categories:
  - Azure
  - VSTS
tags:
  - Azure
  - Azure Automation
  - Azure DevOps
  - VSTS
---
Few weeks ago, I saw a two separate discussions in different closed community channels regarding to the Source Control option in Azure Automation accounts, more specifically – when will the support for VSTS become available.

In the Azure Portal, it has been showing "coming soon".

<a href="https://blog.tyang.org/wp-content/uploads/2018/09/image-27.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/09/image_thumb-27.png" alt="image" width="673" height="319" border="0" /></a>

According to <a href="https://en.wikipedia.org/wiki/Microsoft_Visual_Studio#Azure_DevOps">Wikipedia</a>, "Visual Studio Online" has been renamed to Visual Studio Team Services (VSTS) in November 2015:
<blockquote>On 13 November 2013, Microsoft announced the release of a software as a service offering of Visual Studio on Microsoft Azure platform; at the time, Microsoft called it Visual Studio Online. Previously announced as Team Foundation Services, it expands over Team Foundation Server by making it available on the Internet and implementing a rolling release model.[179][180]Customers could use Azure portal to subscribe to Visual Studio Online. Subscribers receive a hosted Git-compatible version control system, a load-testing service, a telemetry service and an in-browser code editor codenamed "Monaco". <span style="background-color: #ffff00;">During the Connect(); 2015 developer event on 18 November 2015, Microsoft announced that the service was rebranded as "Visual Studio Team Services (VSTS)".</span> On 10 September 2018, Microsoft announced another rebranding of the service, this time to "Azure DevOps".</blockquote>
This feature has been in the backlog for few years, nothing had been done, not even keeping up with the name changes. I guess since Ignite is only few days away, as always, we see many new capabilities been released in Ignite every year, when I checked again today, Microsoft has just released an update to this feature. This wasn’t there when I started writing this blog post few days ago:

<a href="https://blog.tyang.org/wp-content/uploads/2018/09/image-28.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/09/image_thumb-28.png" alt="image" width="948" height="515" border="0" /></a>

To describe this integration in a nutshell, it offers 2 way synchronisation for Powershell and PowerShell workflow runbooks – it allows you to manually or automatically sync runbooks located in your source code repo into your Automation Account, as well as pushing new or updated runbooks from your Automation Account to your repo.
<blockquote><strong><span style="color: #ff0000;">Note:</span></strong> at the time of writing this post, I was not able to successfully connect to an Azure DevOps (VSTS) repo, I guess because it’s still very new… so the remaining of this post is based on the GitHub integration.</blockquote>
Judging from the GitHub integration feature that is available now, I personally don’t think it’s something I am ever going to use. To be honest, the only time I have used this feature was a demo during in a presentation back in 2015. I’ve never touched it since. I’m not saying source control for your runbooks (or any artefacts you are deploying to your Azure subscriptions) are not important, it is <u>VERY</u> important, but using the built-in Source Control feature in Azure Automation is a less-ideal approach. Here are my reasons:

<strong>1. Your runbook is only one piece of the puzzle. </strong>

This is the most obvious and important reason. Based on my experience, you would almost <u>NEVER EVER</u> deploy a runbook by itself. It’s only one component of your overall solution.

Your runbooks need to be triggered. The triggers can be event-based, time-based (schedules), or manually invoked. Therefore, you would also need to deploy other resources such as Event Grid subscriptions, Azure Logic Apps, Automation schedules, or webhooks (for the runbooks), etc.

Your runbook would also need other assets and resources to support itself, such as PowerShell modules, variables and connections, certificates, Key Vault secrets.

You achieve very little by only deploying and storing runbooks in a Git repo. This is like going to a restaurant and ordered a meal. The restaurant not only need to provide you the food you’ve ordered, but also need to provide you with table and chairs, plates, cups, knives and forks (or chopsticks), serviette, etc. Without these supporting artefacts, there is no way you can consume the food you’ve ordered. So when you are deploying your solution from a source control repo, you would deploy the whole solution, not just a tiny component.

<strong>2. Resource Lock can break runbook synchronisations</strong>

<a href="https://blog.tyang.org/wp-content/uploads/2018/09/image-29.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/09/image_thumb-29.png" alt="image" width="612" height="541" border="0" /></a>

If you have resource locks making the Automation Account read-only, you will not be able to synchronise from your GitHub repo. Depending your privilege within the resource group where the Automation Account is located, you may not have permission to delete the resource lock (so you can sync the runbooks).

<strong>3 Protected Git branches</strong>

Often in order to protect the integrity and uphold the quality of the code, many organisations configure restrictions on Git branches. This is ensure code has gone through different stages of thorough review and testing before the "golden copy" has been updated and released to production. In GitHub, you can create branch protection rules that restrict direct merge into the branch (instead, updates can only be made into the branch using Pull Requests):

<a href="https://blog.tyang.org/wp-content/uploads/2018/09/image-30.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/09/image_thumb-30.png" alt="image" width="688" height="528" border="0" /></a>

You can apply the same restriction in Azure DevOps (VSTS) by configuring branch policies:

<a href="https://blog.tyang.org/wp-content/uploads/2018/09/image-31.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/09/image_thumb-31.png" alt="image" width="724" height="775" border="0" /></a>

These restrictions would potentially prevent you from directly merging updates into the branch that your Automation Account is connected to.

<strong>4. What happens to tests and code reviews?</strong>

What is stopping the crappy code from being released into your production? what if someone stored a secret or sensitive information in clear text in a runbook (I have seen it many many times in PowerShell scripts), and then checked into the Git repository via the Source Control integration in Azure Automation account? or vice versa, pushed the same crappy code from Git repo to your Automation account? If this happens, the consequences are serious - 1. being a source control system, once the secret has been committed, you can always retrieve it by going through the history even if you’ve corrected your code, removed the secret and updated the branches. 2. If a runbook contains a secret and has been executed at least once, you can always get the particular runbook jobs before the correction and view the snapshot of the source code been executed in the job. so even if you’ve corrected the crappy code, your secrets are still exposed in clear text regardless the direction of source code synchronization.

This is why code review and tests are <span style="background-color: #ffff00;"><u>VERY IMPORTANT</u></span>. i.e. If you have implemented a test to run PS Script Analyzer against your runbooks as part of your build & release process, it would most likely to pick up clear text passwords and therefore prevented the crappy code from being released into production.

Since there is no test and review process in this Source Control feature. It can be potentially dangerous – we are all humans, we make mistakes. sometimes I have test parameters stored within the script so I can easily test my scripts during development phase. these test parameters may include clear text password, server names, IDs, etc. If I forgot to remove them before code commit, and without having a good branch policy in place, I could potentially have sensitive information stored in a Git repo that I cannot delete.

<strong>The missing piece</strong>

In my opinion, there is a missing piece between your source code and deployed artefacts – that is your CI/CD pipelines. With your build and release pipelines, together with thoroughly designed branching strategy, you can resolve all of the items I have listed above.

If you are seriously thinking about implementing source control and full CI/CD capability of your Azure based solutions (not just Azure Automation), you can use the example shown below as a starting point.

For example, If I am deploying an Automation account, I would have the following artefacts:
<ul>
 	<li>ARM templates that includes automation accounts, variables, modules, runbooks, connections, etc.</li>
 	<li>Runbook (i.e. PowerShell scripts), certificates</li>
 	<li>secrets (i.e. keys, passwords) stored in the Automation accounts</li>
 	<li>Webhooks</li>
 	<li>Resource locks</li>
 	<li>PowerShell modules (located in external NuGet feeds such as PowerShell Gallery)</li>
 	<li>Pester tests</li>
</ul>
My build (CI) pipeline would be something like this:

<a href="https://blog.tyang.org/wp-content/uploads/2018/09/image-32.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/09/image_thumb-32.png" alt="image" width="495" height="988" border="0" /></a>

In this build pipeline, I perform 3 tests before publishing the build artefacts:
<ol>
 	<li>I am using the <a href="https://blog.tyang.org/2018/08/24/powershell-module-pspestertest/">PSPesterTest module</a> developed by myself to validate my runbooks against PSScriptAnalyzer</li>
 	<li>I’m using the <a href="https://blog.tyang.org/2018/09/12/pester-test-your-arm-template-in-azure-devops-ci-pipelines/">Test.ARMTemplate.ps1</a> script developed by myself to validate the ARM template and making sure it only deploys the intended resources.</li>
 	<li>I’m running a test deployment against ARM engine and making sure my ARM template is valid</li>
</ol>
My release pipeline looks like this:

<a href="https://blog.tyang.org/wp-content/uploads/2018/09/image-33.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/09/image_thumb-33.png" alt="image" width="361" height="380" border="0" /></a>

In this pipeline, I perform the following tasks:
<ol>
 	<li>Copy the runbooks from the build artefacts to an Azure storage account</li>
 	<li>Check and remove the Azure resource lock on the target resource group</li>
 	<li>Deploy the ARM template, the runbooks deployed by the template are already copied to a storage account, ARM template references these runbooks using the blob storage URI and the storage account SAS key. The blob storage URI and the SAS key are the outputs of the blob file copy task</li>
 	<li>Recreate the resource lock after the deployment</li>
</ol>
If I want to, I can also add another task to delete the runbooks from the blob storage after the deployment, and depending on your requirements, you can add additional steps in this pipeline, such as scripts to create webhooks for runbooks and store the webhook URI into an Azure Key Vault, or configure RBAC permissions to the resource group, etc.

My pipelines requires the following supporting resources in my Azure subscription:
<ol>
 	<li>A service connection to your Azure subscription (using Azure AD Service Principal)</li>
 	<li>A key vault that stores secrets are to be deployed by the ARM template (i.e. such as keys, passwords, etc.)</li>
 	<li>A storage account that are used for temporarily storing runbooks during the ARM template deployment phase.</li>
</ol>
In DevOps (VSTS) project, I have created variable groups that are linked to key vault and so the key vault secrets can be retrieved and presented to my pipelines as variables:

<a href="https://blog.tyang.org/wp-content/uploads/2018/09/image-34.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/09/image_thumb-34.png" alt="image" width="543" height="442" border="0" /></a>

<strong>Conclusion</strong>

I spend a lot of my spare time on history books and documentaries. Ever since when I was a kid, I’ve always find history fascinating, Chinese history especially. There is a well known metaphor from the Chinese <a href="https://en.wikipedia.org/wiki/Three_Kingdoms">three kingdoms era</a> - 鸡肋:食之无味，弃之可惜(chicken ribs: unappetizing, but yet not bad enough to be thrown out). It it used to describe something that has a little value, but also reluctant to be given up. This is exactly how I feel about the Source Control feature in Azure Automation – just like chicken ribs. What you really need is something more comprehensive, something you can use to test, validate and deploy your complete automation solutions, such as Azure DevOps pipelines.  I know comparing to the native Source Control capability, it is a lot more work to develop and configure the pipelines end to end. But once you have done it once, its a lot quicker to do it next time. Your pipeline becomes your pattern.
<blockquote><span style="color: #ff0000;"><strong>Disclamer:</strong></span> This post is 100% based on my own opinion and experience. In my opinion, comparing to the native source control options within Azure Automation, there are better options out there (such as Azure DevOps pipelines). I just want to point out you should consider all available options before making your decisions.</blockquote>