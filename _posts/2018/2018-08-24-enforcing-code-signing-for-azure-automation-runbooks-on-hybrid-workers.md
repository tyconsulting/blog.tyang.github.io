---
id: 6544
title: Enforcing Code Signing for Azure Automation Runbooks on Hybrid Workers
date: 2018-08-24T23:42:10+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=6544
permalink: /2018/08/24/enforcing-code-signing-for-azure-automation-runbooks-on-hybrid-workers/
categories:
  - Azure
tags:
  - Azure
  - Azure Automation
  - PowerShell
---
Towards the end of last year, in order to solve a specific issue, we were planning to introduce Azure Automation Hybrid Workers to the customer I was working for back then. We planned to place the Hybrid Workers inside the on-prem network and execute several runbooks that required to run on-prem. The security team had some concerns – what if the Automation Accounts or Azure subscriptions get compromised? Then the bad guys can run malicious runbooks targeting on-prem machines. long story short, in the end, we managed to get the Hybrid Worker pattern approved and implemented because we can configure Hybrid Workers to only execute runbooks that are signed by code-signing certs that you have picked. Since then, I have developed many runbooks targeting Hybrid Workers using this control and worked great. I wish I could blog this sooner, but I had to keep my mouth shut because of the MVP NDA. Now that Microsoft has finally announced this feature (well, it’s been few weeks, but I’ve been really busy): <a title="https://docs.microsoft.com/en-us/azure/automation/automation-hrw-run-runbooks#run-only-signed-runbooks" href="https://docs.microsoft.com/en-us/azure/automation/automation-hrw-run-runbooks#run-only-signed-runbooks">https://docs.microsoft.com/en-us/azure/automation/automation-hrw-run-runbooks#run-only-signed-runbooks</a>, I can now share my experience here.

Basically, once you have enabled this feature, you can only execute runbooks signed by configured certs on configured Hybrid Workers:

Executing signed runbook:

<a href="https://blog.tyang.org/wp-content/uploads/2018/08/image-6.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/08/image_thumb-6.png" alt="image" width="600" height="957" border="0" /></a>

<a href="https://blog.tyang.org/wp-content/uploads/2018/08/image-7.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/08/image_thumb-7.png" alt="image" width="893" height="678" border="0" /></a>

Executing Unsigned runbook:

<a href="https://blog.tyang.org/wp-content/uploads/2018/08/image-8.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/08/image_thumb-8.png" alt="image" width="756" height="233" border="0" /></a>

<a href="https://blog.tyang.org/wp-content/uploads/2018/08/image-9.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/08/image_thumb-9.png" alt="image" width="592" height="732" border="0" /></a>

I will not repeat how to sign runbooks and configure Hybrid Workers since it’s already documented in the article listed above. My intention is to share some gotcha and recommendations here.

<strong>01. Do not install the private key of the code-signing cert to the hybrid workers.</strong>

The Hybrid Workers only need the public key of the certs, so only import the .cer file to the cert store. Although it works, but do not import the .pfx file into the hybrid worker servers. This is more secure – people will not be able to export your code-signing cert from your Hybrid Workers, then sign runbooks using the exported cert, and you don’t have to give the entire cert to your server admins who’s responsibility is installing Hybrid Worker servers, not signing code.

<strong>02. Do not try to modify the runbook in the portal</strong>

Any modifications you have done in the portal would void the signature, as the result, the runbook will not run on the Hybrid Workers after the modification. When the code is signed, there’s an empty line at the end of the script after the signature. if you remove the line, the runbook will not run again. so be VERY careful when handling the signed runbooks. This has happened to me before, it took me long time to figure out what happened.

<strong>03. Do not store the signing certificates in Azure</strong>

There are several places you can store certificates in your Azure subscriptions: i.e. in an Azure Key Vault, or as a certificate asset in your Automation Account. If you are concerned about running malicious code after your subscription is compromised, do not place the signing cert in a place where the bad guys can easily get to. So, keep the cert in a safe location, outside of your Azure subscriptions.

<strong>Conclusion</strong>

The enforcement of code signing for Hybrid Worker provides a great control over only allowing genuine code to be executed in your on-premises network. You can also considering integrate the code-signing process in your CICD pipeline, which automate the signing process after the code has been reviewed (part of pull request merging into the branch that your pipeline is targeting), and tested (i.e. using Pester and PSScriptAnalyzer to make sure there are no potential risks in your code).