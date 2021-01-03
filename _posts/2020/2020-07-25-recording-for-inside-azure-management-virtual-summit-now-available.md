---
id: 7438
title: Recording for Inside Azure Management Virtual Summit Now Available
date: 2020-07-25T23:02:18+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=7438
permalink: /2020/07/25/recording-for-inside-azure-management-virtual-summit-now-available/
spay_email:
  - ""
categories:
  - Azure
  - Azure DevOps
tags:
  - Azure
  - Azure DevOps
  - Azure Monitor
  - Community Events
  - Speaking Events
---
This week, on July 23rd (US time), we had a one-day 17-hour free online event <a href="https://insideazuremgmt.com/">Inside Azure Management Virtual Summit</a>. I have teamed up with my buddy Alex Verkinderen <a href="https://twitter.com/AlexVerkinderen">(@AlexVerkinderen</a>) again, and delivered an updated version of our talk at Microsoft Ignite the Tour Sydney in February 2020: <a href="https://insideazuremgmt.com/session/azure-monitor-design-and-implement-monitoring-solution-with-arm-and-ci-cd/">Azure Monitor – Design and Implement Monitoring Solution with ARM and CI/CD</a>.

In our session, we have covered and demonstrated the following in the Azure Pipeline:

1. Using <a href="https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/template-deploy-what-if?tabs=azure-powershell">ARM What-If API</a> in the PR build so approvers can see what changes will be made to your Azure environments.
2. Using <a href="https://docs.microsoft.com/en-us/azure/security/develop/security-code-analysis-overview">Microsoft Security Code Analysis extension</a> to run AV scan and credential scan against your Git repositories.
3. <a href="https://blog.tyang.org/2020/06/27/use-github-super-linter-in-azure-pipelines/">Using GitHub Super Linter</a> to run all available linter tests against your source code.

I have never covered topics of Microsoft Security Code Analysis extension or using ARM What-If API in Azure Pipelines in my blog posts. I was planning to write a post for the What-If API, but then I’ve decided to drop it from my to-do list because we were going to demonstrate it in our session, and the session have been recorded and been made available on YouTube.

All the sessions from this event have been uploaded to Inside Azure Management’s YouTube channel <a href="https://bit.ly/azurevideos">https://bit.ly/azurevideos</a>

Here’s he link to our session:

<iframe src="//www.youtube.com/embed/jnE25JXIUZI" height="375" width="640" allowfullscreen="" frameborder="0"></iframe>

As we mentioned in the session, all the code, links, etc. from the session can be found in my GitHub repo <a href="https://bit.ly/azmonitorcicd">https://bit.ly/azmonitorcicd</a>

Lastly, big thanks to our good friend Pete Zerger (<a href="https://twitter.com/pzerger">@pzerger</a>) for organising this amazing event, and thanks to all the talented speakers. I think it’s fair to say, it has been a huge success!