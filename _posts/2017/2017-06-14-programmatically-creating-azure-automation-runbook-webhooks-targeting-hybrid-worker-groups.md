---
id: 6117
title: Programmatically Creating Azure Automation Runbook Webhooks Targeting Hybrid Worker Groups
date: 2017-06-14T11:25:25+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=6117
permalink: /2017/06/14/programmatically-creating-azure-automation-runbook-webhooks-targeting-hybrid-worker-groups/
categories:
  - Azure
  - PowerShell
tags:
  - Azure
  - Azure Automation
  - PowerShell
---
In Azure Automation, you can create a webhook for a runbook and target it to a Hybrid Worker group (as opposed to run on Azure). In the Azure portal, it is pretty easy to configure this ‘RunOn’ property when you are creating the webhook.

<a href="https://blog.tyang.org/wp-content/uploads/2017/06/image-1.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/06/image_thumb-1.png" alt="image" width="489" height="263" border="0" /></a>

However, at the time of writing this blog post, it is STILL not possible to specify where the webhook should target when creating it using the Azure Automation PowerShell module AzureRM.Automation (version 3.1.0 at the time of writing). The cmdlet New-AzureRMAutomationWebhook does not provide a parameter where you can specify the webhook "RunOn" target:

<a href="https://blog.tyang.org/wp-content/uploads/2017/06/image-2.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/06/image_thumb-2.png" alt="image" width="890" height="439" border="0" /></a>

there are several issues already logged by the community to the Azure PowerShell GitHub repo for this limitation:

 * <a title="https://github.com/Azure/azure-powershell/issues/2247" href="https://github.com/Azure/azure-powershell/issues/2247">https://github.com/Azure/azure-powershell/issues/2247</a>
 * <a title="https://github.com/Azure/azure-powershell/issues/3082" href="https://github.com/Azure/azure-powershell/issues/3082">https://github.com/Azure/azure-powershell/issues/3082</a>

I needed to create webhooks targeting Hybrid Worker groups in a PowerShell script last week, so I looked into using alternative methods. Other than the AzureRM.Automation PowerShell module, we can also create webhooks using the Azure Resource Manager (ARM) REST API and the ARM deployment templates. According to the documentations, both the REST API and template support the "RunOn" parameter. so this limitation is only related to the AzureRM.Automation PowerShell module. The REST API and ARM template documentations are located here:

 * REST API: <a title="https://docs.microsoft.com/en-us/rest/api/automation/webhook#Webhook_CreateOrUpdate" href="https://docs.microsoft.com/en-us/rest/api/automation/webhook#Webhook_CreateOrUpdate">https://docs.microsoft.com/en-us/rest/api/automation/webhook#Webhook_CreateOrUpdate</a>
 * ARM Template: <a title="https://docs.microsoft.com/en-us/azure/templates/microsoft.automation/automationaccounts/webhooks" href="https://docs.microsoft.com/en-us/azure/templates/microsoft.automation/automationaccounts/webhooks">https://docs.microsoft.com/en-us/azure/templates/microsoft.automation/automationaccounts/webhooks</a>

I ended up using the REST API in my solution and managed to create webhooks targeting Hybrid Worker Groups. Based on my experience, the documentation for the webhook Create / Update operation in the REST API is not very clear. As you can see below, The sample request body does not contain some important parameters: the ‘RunOn’ parameter for specifying where the webhook should target and the ‘parameters’ parameter for specifying the input parameters of the runbook:

<a href="https://blog.tyang.org/wp-content/uploads/2017/06/image-3.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/06/image_thumb-3.png" alt="image" width="692" height="586" border="0" /></a>

In this post, I will share the code block I used to create the webhook. For demonstration purposes, I have created a very simple Hello World runbook that takes a single input parameter call "Name":

HelloWorld Runbook:

```powershell
[CmdletBinding()]
PARAM (
[Parameter(Mandatory = $true)][String]$Name
)
Write-output "Hello $Name"
```
[Sample code](https://gist.github.com/tyconsulting/99ac239c4b7522917c89cc80be097f23) for creating the webhook on Hybrid Worker groups:

```powershell
#Function to generate Azure AD authorization token for the ARM rest API
Function Get-AADToken {
  [CmdletBinding()]
  [OutputType([string])]
  PARAM (
    [Parameter(Position=0,Mandatory=$true)]
    [ValidateScript({
      try 
      {
        [System.Guid]::Parse($_) | Out-Null
        $true
      } 
      catch 
      {
        $false
      }
    })]
    [Alias('tID')]
    [String]$TenantID,

    [Parameter(Position=1,Mandatory=$true)][Alias('cred')]
    [pscredential]
    [System.Management.Automation.CredentialAttribute()]
    $Credential,
    
    [Parameter(Position=0,Mandatory=$false)][Alias('type')]
    [ValidateSet('UserPrincipal', 'ServicePrincipal')]
    [String]$AuthenticationType = 'UserPrincipal'
  )
  Try
  {
    $Username       = $Credential.Username
    $Password       = $Credential.Password

    If ($AuthenticationType -ieq 'UserPrincipal')
    {
      # Set well-known client ID for Azure PowerShell
      $clientId = '1950a258-227b-4e31-a9cf-717495945fc2'

      # Set Resource URI to Azure Service Management API
      $resourceAppIdURI = 'https://management.azure.com/'

      # Set Authority to Azure AD Tenant
      $authority = 'https://login.microsoftonline.com/common/' + $TenantID
      Write-Verbose "Authority: $authority"

      $AADcredential = [Microsoft.IdentityModel.Clients.ActiveDirectory.UserCredential]::new($UserName, $Password)
      $authContext = [Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext]::new($authority)
      $authResult = $authContext.AcquireTokenAsync($resourceAppIdURI,$clientId,$AADcredential)
      $Token = $authResult.Result.CreateAuthorizationHeader()
    } else {
      # Set Resource URI to Azure Service Management API
      $resourceAppIdURI = 'https://management.core.windows.net/'

      # Set Authority to Azure AD Tenant
      $authority = 'https://login.windows.net/' + $TenantId

      $ClientCred = [Microsoft.IdentityModel.Clients.ActiveDirectory.ClientCredential]::new($UserName, $Password)
      $authContext = [Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext]::new($authority)
      $authResult = $authContext.AcquireTokenAsync($resourceAppIdURI,$ClientCred)
      $Token = $authResult.Result.CreateAuthorizationHeader()
    }
    
  }
  Catch
  {
    Throw $_
    $ErrorMessage = 'Failed to aquire Azure AD token.'
    Write-Error -Message 'Failed to aquire Azure AD token'
  }

  $Token
}
#Variables for your Azure subscription and Automation Account
$subscriptionId = 'specify-your-subscription-id'
$AADTenantId = 'specify-your-AAD-tenant-id'
$resourceGroup = 'specify-resource-group-name-for-azure-automation-account'
$automationAccount = 'specify-azure-automation-account-name'
$HybridWorkerGroup = 'specify-hybrid-worker-group-name'

#Specify an organization account to sign in to Azure (using AAD token)
$AzureAdminUserName = 'admin@yourcompany.onmicrosoft.com'
$AzureAdminPassword = Read-Host "Enter password for $AzureAdminUserName" -AsSecureString
$AzureAdminCred = New-object System.Management.Automation.PSCredential($AzureAdminUserName, $AzureAdminPassword)

#Generate AAD token and construct HTTP request header
$AADToken = Get-AADToken -TenantID $AADTenantId -Credential $AzureAdminCred
$RESTAPIHeaders = $RESTAPIHeaders = @{'Authorization'=$AADToken;'Accept'='application/json'; 'Content-Type'='application/json'}

#Specify Runbook information
$runbookName = 'HelloWorld'
$runbookParameters = @{
  Name = 'Tao'
}
$webhookName = "$runbookName_$HybridWorkerGroup"

#Generate webhook URI

$GenerateWebhookURIRequestURI = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.Automation/automationAccounts/$automationAccount/webhooks/generateUri?api-version=2015-10-31"
$WebhookUriRequest = Invoke-WebRequest -UseBasicParsing -Uri $GenerateWebhookURIRequestURI -Method Post -Headers $RESTAPIHeaders
If ($WebhookUriRequest.StatusCode -ge 200 -and $WebhookUriRequest.StatusCode -le 299)
{
  #request successful
  $WebhookUri = ($WebhookUriRequest.Content.TrimStart('"')).trimEnd('"')
} else {
  Throw "Failed to generate the webhook URI."
}

#Create webhook that expires in 10 years
$UTCNow = [Datetime]::UtcNow
$webhookExpiryDate = $UTCNow.AddYears(10)
$NewWebHookRequestURI = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.Automation/automationAccounts/$automationAccount/webhooks/$webhookName`?api-version=2015-10-31"
$webhookrequestbody = @{
  name = $webhookName
  properties = @{
    isEnabled = $true 
    Uri = $webhookuri
    expiryTime = $webhookExpiryDate
    runbook = @{
      name = $runbookName
    }
    runOn = $HybridWorkerGroup
    parameters = $runbookParameters
  }
}
$webhookrequestbodyjson = $webhookrequestbody | ConvertTo-Json
$NewWebhookRequest = Invoke-WebRequest -UseBasicParsing -Uri $NewWebHookRequestURI -Headers $RESTAPIHeaders -Method Put -Body $webhookrequestbodyjson

If ($NewWebhookRequest.StatusCode -ge 200 -and $NewWebhookRequest.StatusCode -le 299)
{
  Write-Output "Webhook created. URL: '$webookuri'"
} else {
  Throw "Failed to create the webhook."
}
```

**Note:** this sample script uses a function called Get-AADToken, which was discussed in my previous blog post: <a title="https://blog.tyang.org/2017/06/12/powershell-function-to-get-azure-ad-token/" href="https://blog.tyang.org/2017/06/12/powershell-function-to-get-azure-ad-token/">https://blog.tyang.org/2017/06/12/powershell-function-to-get-azure-ad-token/</a>

After I executed this block of code, a webhook is successfully created targeting my hybrid worker group with a validity period of 10 years:

<a href="https://blog.tyang.org/wp-content/uploads/2017/06/image-4.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/06/image_thumb-4.png" alt="image" width="1002" height="299" border="0" /></a>