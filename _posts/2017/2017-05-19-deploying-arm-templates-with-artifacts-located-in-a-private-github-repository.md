---
id: 6025
title: Deploying ARM Templates with Artifacts Located in a Private GitHub Repository
date: 2017-05-19T16:59:59+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=6025
permalink: /2017/05/19/deploying-arm-templates-with-artifacts-located-in-a-private-github-repository/
categories:
  - Azure
tags:
  - ARM Template
  - Azure
  - Azure Functions
---

## Background

I have spent the last few days authoring an Azure Resource Manager (ARM) template. The template is stored in a private GitHub repository. It contains several nested templates, one of which deploys an Azure Automation account with several runbooks. For the nested templates and automation runbooks, the location must be a URI. Therefore the nested templates and the Azure Automation runbooks that I wish to deploy in the ARM templates must be located in location that is accessible by Azure Resource Manager. There are many good examples in the Azure Quickstart Template GitHub repository, for example, in the <a href="https://github.com/Azure/azure-quickstart-templates/tree/master/oms-all-deploy">oms-all-deploy</a> template, these artifacts are being referenced as URIs pointing to the raw content in GitHub:

Nested Templates:

<a href="https://blog.tyang.org/wp-content/uploads/2017/05/image.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/05/image_thumb.png" alt="image" width="451" height="123" border="0" /></a>

<a href="https://blog.tyang.org/wp-content/uploads/2017/05/image-1.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/05/image_thumb-1.png" alt="image" width="459" height="292" border="0" /></a>

Azure Automation runbook:

<a href="https://blog.tyang.org/wp-content/uploads/2017/05/image-2.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/05/image_thumb-2.png" alt="image" width="458" height="99" border="0" /></a>

As you can see from the examples above, the template is referencing these artifacts as the raw file content in github (located in https://raw.githubusercontent.com). This method works well when your templates and artifacts are stored in a public GitHub repository, but it won’t work when they are stored in a private repository. For example, if I click on the "Raw" button for a file stored in a private repo like shown below:

<a href="https://blog.tyang.org/wp-content/uploads/2017/05/image-3.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/05/image_thumb-3.png" alt="image" width="341" height="194" border="0" /></a>

you will see a token was added to the raw file content URI:

<a href="https://blog.tyang.org/wp-content/uploads/2017/05/image-4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/05/image_thumb-4.png" alt="image" width="660" height="242" border="0" /></a>

This token was generated for your current session once you’ve logged in to GitHub. Although as most of you guys already know that you can generate Personal Access token in GitHub, you can not replace this token in the URL with the Personal Access Token you have generated. The personal access token must be added as part of the authorization header in the HTTP request, and you also need to add another header "Accept": "application/vnd.github.VERSION.raw". Obviously we cannot add HTTP headers in ARM templates, therefore we cannot reference artifacts located in a private GitHub repositories out of the box. Someone has already started a thread in the MSDN forum: <a title="https://social.msdn.microsoft.com/Forums/sqlserver/en-US/54876f00-4bf4-4d84-81af-e7a1128ac6f7/linking-arm-templates-in-private-github-repo?forum=windowsazurewebsitespreview" href="https://social.msdn.microsoft.com/Forums/sqlserver/en-US/54876f00-4bf4-4d84-81af-e7a1128ac6f7/linking-arm-templates-in-private-github-repo?forum=windowsazurewebsitespreview">https://social.msdn.microsoft.com/Forums/sqlserver/en-US/54876f00-4bf4-4d84-81af-e7a1128ac6f7/linking-arm-templates-in-private-github-repo?forum=windowsazurewebsitespreview</a>. the workaround they came up with was building a HTTP proxy server and add the required headers in the proxy server. This to me seems awfully complicated and it also brings limitations that you can only deploy the templates in the network that you can access such a proxy server.

## Solution

I spent most of my day yesterday trying to figure out if there is a way to deploy artifacts located in a private GitHub repository and I couldn’t find a way to use the Personal Access Token as a parameter in the HTTP GET request. As I accepted the fact that I wouldn’t be able to do it and started removing all nested templates in my project, I had a light bulb moment when I was driving to the supermarket yesterday afternoon, and the idea I came up with is super simple:  since I cannot pass the personal access token in the URL, I can just write a very simple "proxy" Azure Function app that accept the GitHub personal access token from the URL parameter, then construct the HTTP header, make the request to GitHub, and return the HTTP response it received from GitHub. Once this function is written, we can use the URI to the function as the artifact location instead of the GitHub URI.

### GitHubPrivateRepoFileFetcher Azure Function 

I’ve written something similar before, so this HTTP Trigger C# Azure function app literally took me 10 minutes to write. I named this function GitHubPrivateRepoFileFetcher:

https://gist.github.com/tyconsulting/f8de503de3df164a6163a3299656d516

This function requires 2 parameters to be passed in from the URL:

 * githuburi – the original URI to the raw GitHub file content
 * githubaccesstoken – the GitHub personal access token you have generated

Since the function does not contain any sensitive information, and I’d like to ensure the function URI is not too long, I have configured the function Authorization level to Anonymous so I don't have to use an authorization code to invoke the Azure Function.

<a href="https://blog.tyang.org/wp-content/uploads/2017/05/image-5.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/05/image_thumb-5.png" alt="image" width="535" height="320" border="0" /></a>

To call this function, you need to construct the URL as the following:

**https://\<Function App Name\>.azurewebsites.net/api/GitHubPrivateRepoFileFecher?githuburi=https://raw.githubusercontent.com/\<GitHub User Name\>/\<Repository\>/\<branch\>/\<path to the file\>&githubaccesstoken=\<GitHub Person Access Token\>**

i.e.

```
https://myfunctionapp.azurewebsites.net/api/GitHubPrivateRepoFileFecher?githuburi=https://raw.githubusercontent.com/tyconsulting/TestPrivateRepo/master/DemoNestedTemplates/azuredeploy.json&githubaccesstoken=e82dc3df60b92147c81a9924042da8d7f0bc78c8
```

### GitHub Personal Access Token 

Before start using the GitHubPrivateRepoFileFetcher function, you will firstly need to generate a GitHub personal access token if you don’t already have one. The token must have access to repo as shown below:

<a href="https://blog.tyang.org/wp-content/uploads/2017/05/image-6.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/05/image_thumb-6.png" alt="image" width="449" height="501" border="0" /></a>

### Constructing ARM Templates 

In the ARM templates, define the following parameters (and define the default value to match your environment):
```json
"GitHubFetcherWebServiceURI" :{
  "type": "string",
  "defaultValue": "https://myfunctionapp.azurewebsites.net/api/GitHubPrivateRepoFileFetcher",
  "metadata": {
    "description": "The GitHub Private Repository File Fetcher Web Service URI"
  }
},
"_GitHubLocation": {
  "type": "string",
  "defaultValue": "https://raw.githubusercontent.com/tyconsulting/TestPrivateRepo/master/DemoNestedTemplates",
  "metadata": {
    "description": "The base URI where artifacts required by this template are located"
  }
},
"_GitHubAccessToken": {
  "type": "securestring"
}
```

define the linked template URL in the variables section:
```json
  "variables": {
    "nestedTemplates": {
      "SQL": "[concat(parameters('GitHubFetcherWebServiceURI'), '?githuburi=', parameters('_GitHubLocation'), '/nestedtemplates/SQL.json', '&githubaccesstoken=', parameters('_GitHubAccessToken'))]",
      "AzureAutomation": "[concat(parameters('GitHubFetcherWebServiceURI'), '?githuburi=', parameters('_GitHubLocation'), '/nestedtemplates/AzureAutomation.json', '&githubaccesstoken=', parameters('_GitHubAccessToken'))]"
    },
},

```
For the Azure Automation runbook that I am planning to deploy, define the URI to the script in the variables section similar to the previous example:
```json
"runbooks": {
  "helloWorldScript": {
    "name": "HelloWorld",
    "version": "1.0.0.0",
    "description": "Hello World Runbook",
    "type": "PowerShell",
    "Id": "",
    "scriptUri": "[concat(parameters('GitHubFetcherWebServiceURI'), '?githuburi=', parameters('_GitHubLocation'), '/runbooks/helloworld.ps1', '&githubaccesstoken=', parameters('_GitHubAccessToken'))]"
  }
}

```
For the Azure Automation runbook resource, use the variable defined above in the script uri property:
```json
"resources": [
  {
    "name": "[variables('runbooks').helloWorldScript.name]",
    "type": "runbooks",
    "apiVersion": "2015-10-31",
    "location": "[parameters('AzureAutomationRegion')]",
    "dependsOn": [
      "[concat('Microsoft.Automation/automationAccounts/', variables('AzureAutomationAccountName'))]"
    ],
    "tags": { },
    "properties": {
      "runbookType": "[variables('runbooks').helloWorldScript.type]",
      "logProgress": "false",
      "logVerbose": "false",
      "description": "[variables('runbooks').helloWorldScript.description]",
      "publishContentLink": {
        "uri": "[variables('runbooks').helloWorldScript.scriptUri]",
        "version": "[variables('runbooks').helloWorldScript.version]"
      }
    }
  }
]
```

### **GitHub README.md** 

Most of the ARM template repositories contains the "Deploy to Azure" and "Visualize" buttons as shown below:

<a href="https://blog.tyang.org/wp-content/uploads/2017/05/image-7.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/05/image_thumb-7.png" alt="image" width="329" height="164" border="0" /></a>

To add the "Deploy to Azure" button to your README.md markdown file, you will need to add the following code to the markdown (modify the URL to suit your environment):

```markdown
[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fmyfunctionapp.azurewebsites.net%2Fapi%2FGitHubPrivateRepoFileFetcher%3Fgithuburi%3Dhttps%3A%2F%2Fraw.githubusercontent.com%2Ftyconsulting%2FTestPrivateRepo%2Fmaster%2FDemoNestedTemplates%2Fazuredeploy.json%26githubaccesstoken%3De82dc3df60b92147c81a9924042da8d7f0bc78c8)

```
For the "Visualize" button, add the following code in the markdown:

```html
<a href="http://armviz.io/#/?load=https%3A%2F%2Fmyfunctionapp.azurewebsites.net%2Fapi%2FGitHubPrivateRepoFileFetcher%3Fgithuburi%3Dhttps%3A%2F%2Fraw.githubusercontent.com%2Ftyconsulting%2FTestPrivateRepo%2Fmaster%2FDemoNestedTemplates%2Fazuredeploy.json%26githubaccesstoken%3De82dc3df60b92147c81a9924042da8d7f0bc78c8" target="_blank">
<img src="http://armviz.io/visualizebutton.png"/>
```

Basically, add the Azure Function URL with required parameters as the parameter to the azure custom deployment and armviz.io URIs. you will need to encode the function URI. you can use an an online encoder utility such as <a title="http://www.url-encode-decode.com/" href="http://www.url-encode-decode.com/">http://www.url-encode-decode.com/</a> to encode the original Azure Function URI.

When you click the "Deploy to Azure" button, you will be redirected to the Azure portal:

<a href="https://blog.tyang.org/wp-content/uploads/2017/05/image-8.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/05/image_thumb-8.png" alt="image" width="306" height="518" border="0" /></a>

When the deployment is completed, the resources defined in the ARM templates are created:

<a href="https://blog.tyang.org/wp-content/uploads/2017/05/image-9.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/05/image_thumb-9.png" alt="image" width="407" height="202" border="0" /></a>

### Conclusion 

By using the "proxy" Azure Function GitHubPrivateRepoFileFetcher, you can easily retrieve the content of a file in private GitHub repo without having to use custom headers in HTTP request. This "proxy" Azure Function is generic that you can use for any Azure subscriptions and any GitHub private repositories. If you regularly use GitHub private repositories for ARM templates, I strongly recommend you to create such a Azure function to assist you with your deployments.

If you have any questions or recommendations, please feel free to contact me.