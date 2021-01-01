---
id: 7421
title: Use GitHub Super Linter in Azure Pipelines
date: 2020-06-27T00:33:22+10:00
author: Tao Yang
layout: post
guid: https://blog.tyang.org/?p=7421
permalink: /2020/06/27/use-github-super-linter-in-azure-pipelines/
spay_email:
  - ""
categories:
  - Azure
  - Azure DevOps
  - DevOps
tags:
  - Azure
  - Azure DevOps
  - GitHub
---
Recently, GitHub has released an open-sourced tool called Super Linter (<a href="https://github.blog/2020-06-18-introducing-github-super-linter-one-linter-to-rule-them-all/">Blog</a>, <a href="https://github.com/github/super-linter">Repo</a>). It’s basically a swiss army knife of linters for a collection of languages. This is really cool since I can replace many language-specific tests with a single tool. At the time of writing this article, it already supports many popular languages such as Dockerfile, Golang, JavaScript, JSON, Markdown, YAML, Python3, PHP, Terraform, PowerShell, bash, and many more. The full list is documented on the README file on the GitHub repo.

Although the GitHub Super Linter is designed to be used in GitHub Actions, it runs on a container under the hood, and it allows you to run locally using docker. This capability enabled me to use it as part of my Azure DevOps pipeline (or potentially any other CI/CD tools).

It is really easy to incorporate it in your Azure Pipelines. I added it to one of my existing pipelines and replaced a task that runs PSScriptAnalyzer, and it worked the first attempt. Assuming you are using YAML pipeline, here’s the code snippet:

<pre>  - job: lint_tests
    displayName: Lint Tests
    pool:
      vmImage: ubuntu-latest
    steps:
    - script: |
        docker pull github/super-linter:latest
        docker run -e RUN_LOCAL=true -v $(System.DefaultWorkingDirectory):/tmp/lint github/super-linter
      displayName: 'Code Scan using GitHub Super-Linter'
</pre>

the syntax for running the Super Linter container is documented on it’s GitHub repo: <a href="https://github.com/github/super-linter/blob/master/docs/run-linter-locally.md">https://github.com/github/super-linter/blob/master/docs/run-linter-locally.md</a>. In my example, I’m scanning everything in $(System.DefaultWorkingDirectory) (which means everything in my git repo). You can adjust it according to your requirements.

If any issues are found within your code, the task will fail, for example:

Dockerfile:

<a href="https://blog.tyang.org/wp-content/uploads/2020/06/image-17.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2020/06/image_thumb-17.png" alt="image" width="778" height="694" border="0" /></a>

PowerShell scripts:

<a href="https://blog.tyang.org/wp-content/uploads/2020/06/image-18.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2020/06/image_thumb-18.png" alt="image" width="773" height="690" border="0" /></a>

For most of my pipelines, if there are ARM templates involved, I’m also using <a href="https://github.com/azure/arm-ttk">ARM TTK</a> to validate them. I hope one day ARM TTK makes it’s way to GitHub Super Linter, but since it’s open sourced, I might try to figure out how to do it myself if I can find spare time.

But for now, I’m pretty happy with the result, it’s so easy to use it in Azure Pipelines, I encourage everyone to give it a try.

P.S. GitHub Super Linter even found some syntax errors from the default README file created by Azure Repo (i.e. trailing spaces at the end of the line, etc.). Make sure you update the default README file in your repo or you’ll definitely going to fail the the tests first time.