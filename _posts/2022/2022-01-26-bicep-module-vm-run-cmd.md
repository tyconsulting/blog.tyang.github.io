---
title: Azure Bicep Module for Virtual Machine Run Commands
date: 2022-01-26 16:00
author: Tao Yang
permalink: /2022/01/26/azure-bicep-vm-run-cmd
summary: Azure Bicep module for invoking commands or scripts on Virtual Machines via VM Run Command feature
categories:
  - Azure
tags:
  - Azure
  - Azure Bicep
  - Azure VM
---

## Background

One of the features I use over and over again when working with Azure VMs is [VM Run Command](https://docs.microsoft.com/en-au/azure/virtual-machines/run-command-overview). This feature allows you to invoke commands or scripts on a VM via ARM REST API without having to logon to the VM. You don't need to have administrative access to the VMs, as long as you have sufficient Azure ARM role permissions, you can use this feature.

This is great for invoking ad-hoc or once-off tasks for VMs, without having to manually logging on to the VM.

You may have seen this on the Azure portal:

![1](../../../../assets/images/2022/01/bicep-vm-run-cmd-01.jpg)

Currently there are [2 flavours of VM Run Command](https://docs.microsoft.com/en-us/azure/virtual-machines/run-command-overview):

* Action Run Commands (legacy)
* Managed Run Commands (Preview)

Quoted from [Microsoft documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/run-command-overview#when-to-use-action-or-managed-commands):

>**When to use action or managed commands**
>
>The original set of commands are action orientated. You should consider using this set of commands for situations where you need to run:
>
> * A small script to get a content from a VM
> * A script to configure a VM (set registry keys, change configuration)
> * A one time script for diagnostics
>
>The updated set of commands, currently in Public Preview, are management orientated. Consider using managed run commands if your needs align to the following examples:
>
> * Script needs to run as part of VM deployment
> * Recurrent script execution is needed
> * Multiple scripts needs to execute sequentially
> * Bootstrap a VM by running installation scripts
> * Publish custom script to be shared and reused

In the past, I have used the legacy Action Run Command feature via [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/vm/run-command?view=azure-cli-latest), [Azure PowerShell](https://docs.microsoft.com/en-us/powershell/module/az.compute/invoke-azvmruncommand), or directly invoking the [ARM REST API](https://docs.microsoft.com/en-us/rest/api/compute/virtual-machines-run-commands/run-command). I even developed a Terraform module for this feature for a customer.

One of the questions I often get asked is why not just use Azure VM [Custom Script Extension](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows)? The limitation with the Custom Script Extension is that you can only have 1 instance of this extension deployed to an Azure VM. In the projects I have worked on, often the custom script extension was used for something else (or purposely reserved for other uses). For this reason, we had to use VM Run Command for what we needed to do. i.e. in a customer's environment, I have utilized VM Run Command to create a disk volume for SQL backup drives on SQL VMs because the customer prefers backing up DBs to disks first.

In addition to the Azure CLI, PowerShell and REST API, you can also utilize the VM Run Command capability via [Bicep or ARM templates](https://docs.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines/runcommands?tabs=bicep). In the past, using ARM templates for VM Run Command might not always be a viable option because you'd have to manually wrap the script you want to execute into the JSON document for the ARM template. Thankfully, the Bicep product group created a function called [**LoadTextContent()**](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-functions-files#loadtextcontent) based on [my suggestion](https://github.com/Azure/bicep/issues/471). With ***LoadTextContent()***, we can easily have the actual script in a separate file and use this function to import the content of the file into the template by specifying the relative path and file encoding.

## Bicep Template

I have spent the last few days working on a Bicep module for Azure VM Run Command, which allows us to invoke either pre-defined commands or custom scripts on both Windows and Linux VMs. Invoking a script on a existing VM can  be as simple as:

```hcl
var scriptContent = loadTextContent('test.ps1', 'utf-8')

module win_vm_run_cmd '../modules/vm-run-cmd.bicep' = {
  name: 'winVmRunCmd'
  params: {
    name: '${vmName1}/testPwsh'
    location: location
    asyncExecution: false
    errorBlobUri: errorBlobUri
    outputBlobUri: outputBlobUri
    scriptParameters: scriptParameters
    script: scriptContent
    timeoutInSeconds: 120
  }
}
```

You can find this module from my BlogPost GitHub repo **[HERE](https://github.com/tyconsulting/BlogPosts/tree/master/Azure-Bicep/vm-run-cmd)**.

The instructions on how to use this Bicep module is documented in the BlogPost GitHub repo already, including how to configure the template parameters, commands to deploy the templates using Azure CLI. It also provided 2 sample Bicep templates coupled with parameter files files for invoking pre-defined commands and custom scripts on both Windows VMs (PowerShell script) and Linux VMs (Shell script).

## Limitations

Over the time, there have been some improvements for VM Run Command, however, there are still some frustrating limitations. Some of these limitations have prevented me from using it in some cases.

### Run As User does not work

By default, the commands or scripts are executed under LOCAL SYSTEM on Windows VMs and root on Linux VMs. Few months ago, I had a requirement to configure some folder permissions for a domain service account on a SQL VM. In order to assign permission for a domain account, the script needed to be executed under a domain user account. In the end, I had to develop an different solution not using VM Run Command feature.

I wasn't sure when was the Run As User introduced to VM Run Command. But when I started working on this Bicep module, I noticed RunAsUser and RunAsPassword parameters were documented everywhere ([Azure CLI](https://docs.microsoft.com/en-us/cli/azure/vm/run-command?view=azure-cli-latest#az-vm-run-command-create), [Azure PowerShell](https://docs.microsoft.com/en-us/powershell/module/az.compute/set-azvmruncommand?view=azps-7.1.0#parameters), [REST API](https://docs.microsoft.com/en-us/rest/api/compute/virtual-machine-run-commands/create-or-update#request-body), [Bicep](https://docs.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines/runcommands?tabs=bicep#virtualmachineruncommandproperties), [HERE](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/run-command-managed) and [HERE](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/run-command-managed)).

Looks like the Run As User capability is a new feature from the new [**Managed Run Command**](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/run-command-managed) feature which is currently in public preview at the time of writing this article. I have follow the instruction and registered this preview, however, it still doesn't work no matter which method I use (CLI, PowerShell, Bicep, etc.). I even tried different REST API versions, including the latest [undocumented version 2021-11-01](https://github.com/Azure/azure-rest-api-specs/blob/c4a86872d4f2297597260c5968d2f50a0298db01/specification/compute/resource-manager/Microsoft.Compute/stable/2021-11-01/runCommands.json).

After spent a day on this, in the end, I gave up, and accepted that I still can't use VM Run Command to execute a script under a different user.

### Script outputs are not captured in the template deployment outputs

When invoking VM Run Command via the legacy Action Run Commands via Azure CLI ([az vm run-command invoke](https://docs.microsoft.com/en-us/cli/azure/vm/run-command?view=azure-cli-latest#az-vm-run-command-invoke)) or PowerShell ([Invoke-AzVMRunCommand](https://docs.microsoft.com/en-us/powershell/module/az.compute/invoke-azvmruncommand?)) or via the Azure Portal, if the command / script generates any outputs to the error and stdout stream, they will be returned so it's visible to you.

![2](../../../../assets/images/2022/01/bicep-vm-run-cmd-02.jpg)

When using the REST API, the initial HTTP response provides an URI that you can keep pulling to get the result once the execution is finished. However, with Bicep / ARM template, the template deployment outputs do not include the script execution outputs even when I set asyncExecution to false.

For example, I executed the pre-defined command "ifconfig" with parameter "eth0" on a Linux VM, the template output only included the command line and parameter, but no outputs:

![3](../../../../assets/images/2022/01/bicep-vm-run-cmd-03.jpg)

Hence it is very important that you use a storage account to store the err and stdout outputs by using the **errorBlobUri** and **outputBlobUri** parameters. In this example, once the execution is completed, you will be able to download the output from blob container in the Storage Account:

![4](../../../../assets/images/2022/01/bicep-vm-run-cmd-04.jpg)

### Reusing same blob in mutiple deployments**

I had an issue where the output blob does not get updated when I re-deployed the Bicep template. I realised the issue was that I used a fixed name for the blob and once the blob was initially created, any subsequent template deployments would not overwrite it. To work around this behaviour, I generate a unique blob name based on the VM name and current UTC time stamp:

![5](../../../../assets/images/2022/01/bicep-vm-run-cmd-05.jpg)

So the blob container would contain all the outputs from every deployment:

![6](../../../../assets/images/2022/01/bicep-vm-run-cmd-06.jpg)

I have included the error and output blob URI in the template output, so you know which blob to check:

![7](../../../../assets/images/2022/01/bicep-vm-run-cmd-07.jpg)

## Conclusion

This Bicep module has been on my to-do list for a while. Ever since I have created a Terraform module for Azure VM Run Command for a customer a long time ago. I can see myself use this module in many future projects. I hope you find it useful. I know this is not a perfect solution. Suggestions are welcome.