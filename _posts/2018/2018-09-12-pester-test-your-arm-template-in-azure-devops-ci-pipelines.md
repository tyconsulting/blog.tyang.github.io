---
id: 6613
title: Pester Test Your ARM Template in Azure DevOps CI Pipelines
date: 2018-09-12T21:44:34+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=6613
permalink: /2018/09/12/pester-test-your-arm-template-in-azure-devops-ci-pipelines/
categories:
  - Azure
  - PowerShell
  - VSTS
tags:
  - Azure
  - AzureDevOps
  - Pester
  - PowerShell
  - VSTS
---
<h3>Introduction</h3>
It is fair to say, I have spent a lot of time on Pester lately. I just finished up a 12 months engagement with a financial institute here in Melbourne. During this engagement, everyone in the project team had to write tests for any patterns / pipelines they are developing. I once even wrote a standalone pipeline only to perform Pester tests. One of the scenario we had to cater for is: How can you ensure the ARM template you are deploying only deploys the resources that you intended to deploy? In another word, if someone has gone rogue or mistakenly modified the template, how can you make sure it does not deploy resources that’s not supposed to be deployed (i.e. a wide open VNet without NSG rules).

To cater for this requirement, an engineer from the customer’s own cloud team has written a Pester test that validates the content of the ARM templates by parsing the JSON file. I like the idea, but since I didn’t bother (and couldn’t) keep a copy of the code, I wrote my own version, with some improvements and additional capability. The pester test I wrote performs the following tests:
<ul>
 	<li>Template file validation
<ul>
 	<li>Test if the ARM template file exists</li>
 	<li>Test if the ARM template is a valid JSON file</li>
</ul>
</li>
 	<li>Template content validation
<ul>
 	<li>Contains all required elements (defined by Microsoft’s ARM template schema)</li>
 	<li>Only contains valid elements</li>
 	<li>Has valid Content Version</li>
 	<li>Only has approved parameters</li>
 	<li>Only has approved variables</li>
 	<li>Only has approved functions</li>
 	<li>Only has approved resources</li>
 	<li>Only has approved outputs</li>
</ul>
</li>
</ul>
<a href="https://blog.tyang.org/wp-content/uploads/2018/09/image-17.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/09/image_thumb-17.png" alt="image" width="637" height="342" border="0" /></a>

For example, say I have a template that deploys a single VM. This template has the following elements defined:
<ul>
 	<li>parameters:
<ul>
 	<li>virtualMachineNamePrefix</li>
 	<li>virtualMachineSize</li>
 	<li>adminUserName</li>
 	<li>virtualNetworkResourceGroup</li>
 	<li>virtualNetworkName</li>
 	<li>adminPassword</li>
 	<li>subnetName</li>
</ul>
</li>
 	<li>variables:
<ul>
 	<li>nicName</li>
 	<li>publicIpAdressName</li>
 	<li>publicIpAddressSku</li>
 	<li>publicIpAddressType</li>
 	<li>subnetRef</li>
 	<li>virtualMachineName</li>
 	<li>vnetId</li>
</ul>
</li>
 	<li>functions:
<ul>
 	<li>namespace: tyang, member: uniqueName</li>
</ul>
</li>
 	<li>resources (of it’s type):
<ul>
 	<li>Microsoft.Compute/virtualMachines</li>
 	<li>Microsoft.Network/networkInterfaces</li>
 	<li>Microsoft.Network/publicIpAddresses</li>
</ul>
</li>
 	<li>outputs:
<ul>
 	<li>adminUserName</li>
</ul>
</li>
</ul>
Using this Pester test script, I can either be very strict and ensure ALL the elements listed above must be defined (and nothing else), or be less restrictive, only test against the required element (resources) and one or more optional elements (parameters, variables, functions and outputs).
<h3>Test.ARMTemplate.ps1</h3>
Here’s the code, hosted on GitHub:

https://gist.github.com/tyconsulting/2a6b84938f871bcfb4b896868cf37ab8

To test your template using this script, you will need to pass the following parameters in:

<strong>-TemplatePath</strong>

The path to the ARM Template that needs to be tested against.

<strong>-parameters</strong>

The names of all parameters the ARM template should contain (optional).

<strong>-variables</strong>

The names of all variables the ARM template should contain (optional).

<strong>-functions</strong>

The list of all the functions (namespace.member) the ARM template should contain (optional).

<strong>-resources</strong>

The list of resources (of its type) the ARM template should contain. Only top level resources are supported. child resources defined in the templates are not supported.

<strong>-output</strong>

The names of all outputs the ARM template should contain (optional).

<strong>Examples:</strong>

Test ARM template file with parameters, variables, functions, resources and outputs:
<pre language="PowerShell">$params = @{
TemplatePath = 'c:\temp\azuredeploy.json'
parameters = 'virtualMachineNamePrefix', 'virtualMachineSize', 'adminUsername', 'virtualNetworkResourceGroup', 'virtualNetworkName', 'adminPassword', 'subnetName'
variables = 'nicName', 'publicIpAddressName', 'publicIpAddressSku', 'publicIpAddressType', 'subnetRef', 'virtualMachineName', 'vnetId'
functions = 'tyang.uniqueName'
resources = 'Microsoft.Compute/virtualMachines', 'Microsoft.Network/networkInterfaces', 'Microsoft.Network/publicIpAddresses'
outputs = 'adminUsername'
}
.\Test.ARMTemplate.ps1 @params
</pre>
Test ARM template file with only the resources elements:
<pre language="PowerShell" class="">
$params = @{
TemplatePath = 'c:\temp\azuredeploy.json'
resources = 'Microsoft.Compute/virtualMachines', 'Microsoft.Network/networkInterfaces', 'Microsoft.Network/publicIpAddresses'
}
.\Test.ARMTemplate.ps1 @params
</pre>
<h3>Using it in Azure DevOps Pipeline</h3>
To use this Pester test script in your VSTS pipeline, you can follow the steps listed below:

<strong>1. Include this script in your repository</strong>

In my Git repo, I have created a folder called "tests" and placed this script inside a sub-folder of "tests":

<a href="https://blog.tyang.org/wp-content/uploads/2018/09/image-18.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/09/image_thumb-18.png" alt="image" width="724" height="370" border="0" /></a>

<strong>2. Create a variable group and define the input parameters for the pester test script in the variable group.</strong>

<a href="https://blog.tyang.org/wp-content/uploads/2018/09/image-19.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/09/image_thumb-19.png" alt="image" width="1002" height="395" border="0" /></a>

In this demo, I name these variables "parameters", "variables", "functions", "resources" and "outputs". these variables can be arrays, you can separate each value using comma ",".

Please note that in addition to the template file path, only "resources" is the required parameter, if you don’t want to validate other template elements, you don’t need to create other variables here.

<strong>3. Link the variable group to the build pipeline</strong>

Before the build pipeline can use these variables, you need to link the variable group to the build pipeline.

<strong>4. In the build (CI) pipeline, add a "Pester Test Runner" task</strong>

<a href="https://blog.tyang.org/wp-content/uploads/2018/09/image-20.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/09/image_thumb-20.png" alt="image" width="714" height="105" border="0" /></a>

Although there are other Pester test tasks out there, this is my favourite one.

<strong>5. Configure the Pester Test Runner task</strong>

<a href="https://blog.tyang.org/wp-content/uploads/2018/09/image-21.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/09/image_thumb-21.png" alt="image" width="864" height="498" border="0" /></a>

Since the Pester test script requires input parameters, the "Script Folder or Script" field needs to be a hash table. In my demo, I’m leveraging the build-in variable $(System.DefaultWorkingDirectory) as well as my user-defined variables. It is set to:

<span style="background-color: #ffff00;">@{Path='$(System.DefaultWorkingDirectory)\ARMDeploymentDemo\SingleVMPatternDemo\tests\ARMTemplate\Test.ARMTemplate.ps1'; Parameters=@{TemplatePath ='$(System.DefaultWorkingDirectory)\ARMDeploymentDemo\SingleVMPatternDemo\azuredeploy.json'; parameters =$(parameters); variables = $(variables); functions = $(functions); resources = $(resources); outputs = $(outputs)}}</span>

You will need to modify it to suit your needs.

6. Add a Publish Test Results task

<a href="https://blog.tyang.org/wp-content/uploads/2018/09/image-22.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/09/image_thumb-22.png" alt="image" width="779" height="582" border="0" /></a>

Make sure the Test results files pattern matches what you configured as the Results file in the previous step.

<strong>7. Configure job dependencies</strong>

<a href="https://blog.tyang.org/wp-content/uploads/2018/09/image-23.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/09/image_thumb-23.png" alt="image" width="981" height="574" border="0" /></a>

If you have any agent jobs after the Pester test, you can configure them to be depended on the Pester test job so they wont run if the Pester test has failed.

Accessing the test results

You can view the result of each individual test from the build logs:

<a href="https://blog.tyang.org/wp-content/uploads/2018/09/image-24.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/09/image_thumb-24.png" alt="image" width="949" height="882" border="0" /></a>

You can also create a widget in a dashboard and view the test results in a graph:

<a href="https://blog.tyang.org/wp-content/uploads/2018/09/image-25.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/09/image_thumb-25.png" alt="image" width="879" height="631" border="0" /></a>
<h3>Limitations</h3>
Initially, I also wanted to do a full-blown JSON schema validation by ad-hoc downloading ARM template schema, and validate the ARM template against the schema (which should be always up to date). I found this simple PowerShell script by the author of Newtonsoft.JSON libraries: <a title="https://gist.github.com/JamesNK/7e6d026c8b78c049bb1e1b6fb0ed85cf" href="https://gist.github.com/JamesNK/7e6d026c8b78c049bb1e1b6fb0ed85cf">https://gist.github.com/JamesNK/7e6d026c8b78c049bb1e1b6fb0ed85cf</a>. It was a good starting point, but since the ARM template schema contains many $ref elements that reference other schemas, I had to modify this script to use the <a href="https://www.newtonsoft.com/json/help/html/RefJsonSchemaResolver.htm">JsonSchemaResolver</a> in order to resolve these references. Based on my experience, it was a hit and miss, not all references could be resolved because I was getting errors for some specific resource types defined in the ARM template, and after I spent almost a day trying to get this working, I got an error saying I have reached the hourly limit (<a title="https://www.newtonsoft.com/store/jsonschema" href="https://www.newtonsoft.com/store/jsonschema">https://www.newtonsoft.com/store/jsonschema</a>) and I need to purchase a commercial license. This prompted me to stop exploring further because I don’t really want to develop a free solution that relies on commercial licenses. Therefore, this Pester test does not perform ARM JSON schema validation against your template. In my opinion, the best way to do it is to validate your template directly against the ARM engine (do a validation only deployment):

<a href="https://blog.tyang.org/wp-content/uploads/2018/09/image-26.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/09/image_thumb-26.png" alt="image" width="793" height="405" border="0" /></a>

Although I have not used it myself, but I just want to point out, there is also a Pester test task available for ARM test deployments: <a title="https://marketplace.visualstudio.com/items?itemName=petergroenewegen.PeterGroenewegen-Xpirit-Vsts-Build-Pester" href="https://marketplace.visualstudio.com/items?itemName=petergroenewegen.PeterGroenewegen-Xpirit-Vsts-Build-Pester">https://marketplace.visualstudio.com/items?itemName=petergroenewegen.PeterGroenewegen-Xpirit-Vsts-Build-Pester</a>

Therefore, my script does not cover the full schema validation, but performing a test deployment would achieve the same result (and more).

If anyone knows how to validate JSON against a schema with online references for free, please ping me <img class="wlEmoticon wlEmoticon-smile" src="https://blog.tyang.org/wp-content/uploads/2018/09/wlEmoticon-smile-1.png" alt="Smile" />