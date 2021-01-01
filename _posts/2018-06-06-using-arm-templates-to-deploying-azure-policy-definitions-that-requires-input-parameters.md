---
id: 6456
title: Using ARM Templates to Deploying Azure Policy Definitions That Requires Input Parameters
date: 2018-06-06T20:56:38+10:00
author: Tao Yang
layout: post
guid: https://blog.tyang.org/?p=6456
permalink: /2018/06/06/using-arm-templates-to-deploying-azure-policy-definitions-that-requires-input-parameters/
categories:
  - Azure
tags:
  - ARM Template
  - Azure
---
Recently, Kristian Nese from Microsoft published a sample subscription level ARM template that deploys Azure Policy definition and assignment on his <a href="https://github.com/krnese/AzureDeploy/blob/master/ARM/deployments/subscriptionLevelDeployment.json">GitHub repo</a>. For me, this is good timing since I was just about to start a piece of work designing a collection of custom policy definitions. My end goal is deploying the custom definitions and assignments to multiple environment using VSTS CI/CD pipelines. After spending few days on this task, I finally got it working. During this process, I faced several challenges:
<ul>
 	<li>At the time of writing, AzureRM PowerShell module and VSTS ARM deployment task has not been updated to allow subscription-level deployment.</li>
 	<li>Defining Policy definitions that requires input parameters in ARM templates caused errors during deployments</li>
</ul>
I ended up created a separate PowerShell script that can be used in VSTS to deploy subscription-level ARM templates by calling the ARM REST API directly. I will cover this script in my next post.

The policy definition in Kristian’s example does not require any input parameters. To explain the challenges, I will use the “Allowed Role Definitions” sample definition from Azure Policy’s official GitHub repo: <a title="https://github.com/Azure/azure-policy/blob/master/samples/Authorization/allowed-role-definitions/azurepolicy.json" href="https://github.com/Azure/azure-policy/blob/master/samples/Authorization/allowed-role-definitions/azurepolicy.json">https://github.com/Azure/azure-policy/blob/master/samples/Authorization/allowed-role-definitions/azurepolicy.json</a>

In the policy definition, input parameter is defined in the <strong>parameters</strong> section and are referenced in the policy rule as <strong>“[parameters(‘parametername’)]”</strong>:

<a href="https://blog.tyang.org/wp-content/uploads/2018/06/image.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/06/image_thumb.png" alt="image" width="732" height="777" border="0" /></a>

If I simply wrap this definition in an ARM template, since <strong>parameters()</strong> is also a function in ARM template, the ARM engine will treat this as a native ARM template function and will try to look for the ARM template input parameter with the same name. Obviously, for the policy definition, this is just part of the definition, the input parameters are only passed into the definition when a policy assignment is created. So, when ARM engine tries to execute the parameters() function within the policy definition, the template deployment would fail. I would get an error similar to this:
<blockquote><span style="color: #ff0000;"> "Unable to process template language expressions for resource '/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/providers/Microsoft.Authorization/policyDefinitions/allowed-role-definitions-def' at line '10' and column '5'. <span style="background-color: #ffff00;">'The template
parameter 'roleDefinitionIds' is not found.</span></span></blockquote>
After tried few things, I managed to get it working using a workaround – in order to prevent the ARM engine from executing the parameters() function within the policy definition, I needed to pass in<strong> "[parameters('roleDefinitionIds')]"</strong> as a string. to do so, I need to define a dummy input parameter in the ARM template, and pass in the string value exactly as <span style="background-color: #ffff00;">"[parameters('roleDefinitionIds')]"</span>. so, the ARM template ended up look like below, and it is coupled with a parameter file:

<strong>Template file:</strong>

https://gist.github.com/tyconsulting/9075d3a3eef8401bdc2ba88aadd74f3c

<strong>Parameter file:</strong>

https://gist.github.com/tyconsulting/c3064a4fbdbac5b818f0012b3e360541

As you can see, i’ve defined an ARM template parameter with the same name, and defined the value in the parameter file, which is exactly how it should be displayed in the policy definition. By putting <span style="background-color: #ffff00;">"[parameters('roleDefinitionIds')]"</span> as the value of an input parameter, ARM engine treats it as string and it will not try to execute the parameters() function.

Now, I am able to deploy the template together with the parameter file to the subscription using the script that I’m going to introduce in the next post.

<a href="https://blog.tyang.org/wp-content/uploads/2018/06/image-1.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/06/image_thumb-1.png" alt="image" width="1002" height="320" border="0" /></a>

<a href="https://blog.tyang.org/wp-content/uploads/2018/06/image-2.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/06/image_thumb-2.png" alt="image" width="702" height="565" border="0" /></a>

I was also able to define other subscription level resource types such as Policy initiatives, subscription level policy assignments, custom role definitions etc. I will cover them in coming posts.