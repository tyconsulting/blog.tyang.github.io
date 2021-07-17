---
title: Azure Bicep, Deployment Script and Static Private IP Allocation
date: 2021-07-17 01:00
author: Tao Yang
permalink: /2021/07/17/azure-bicep-deployment-script-static-ip-example/
summary: Azure Bicep Deployment Script code example for static private IP allocations
categories:
  - Azure
tags:
  - Azure
  - Azure Bicep
---

My blog has been very quiet lately. Other than the obvious reason that I have been really busy at work, It's also because over the last 14 months, I have been using Terraform exclusively on the project that I'm working on, and it's pretty hard for me to find any positive aspects for Terraform that's worth blogging.

If you ask me what I like about Terraform, one thing I can think of is the [cidrhost function](https://www.terraform.io/docs/language/functions/cidrhost.html) in Terraform. At my current customer's environment, we use **cidrhost** to define static private IP addresses for resources such as VMs, load balancers, etc. We have used **cidrhost** function in pretty much all patterns and templates my team has developed.

For example, in the Terraform code, we would define a set of local values define the private IPs for the resources we are deploying:

```hcl
local {
  web_vm_1_ip = cidrhost(local.subnet_address_prefix, 4) #the 4th IP from the subnet
  web_vm_2_ip = cidrhost(local.subnet_address_prefix, 5) #the 5th IP from the subnet
  web_lb_ip = cidrhost(local.subnet_address_prefix, 6) #the 6th IP from the subnet
}
```

It provides the following benefits when we deploy resources and landing zones to Azure:

1. We can pre-define the IP addresses for resources before being deployed, so the team can streamline the process that other team members can work on other integration requirements such as requesting firewall rules since we already know what the IPs are going to be before the resources have been deployed.
2. We can avoid the possibilities that IP addresses may change when the resources have been destroyed and redeployed - since this may cause unnecessary outages due to the requirements of updating DNS records or firewall rules.
3. We use the cidrhost function in our bootstrap code. We don't need to hard code the IP addresses anywhere in Terraform code or variables values for different applications or landing zones. For example, based on the sample code snippet shown above, the first usable IP in the subnet (4th IP is the first usable IP in Azure) will always be allocated to web vm #1.

I really hope there is a similar function in ARM and Bicep, but unfortunately, I don't believe there is a simple way to implement this in ARM/Bicep.

I spent some time on this over the last couple of weeks. Initially I tried to leverage all existing ARM functions to calculate IP addresses but unfortunately, calculating IPs are too complicated, I couldn't get it working by only using the native ARM functions. In the end, I created a Bicep module that leverages Azure Deployment Script to calculate IPs within a subnet using PowerShell script.

You can find the module [HERE](https://github.com/tyconsulting/BlogPosts/blob/master/Azure-Bicep/static.ip.allocation/azcidrhost-function.bicep).

I have also created a complete example that deploys 2 VMs using the module. This example can be found in the same GitHub repo [HERE](https://github.com/tyconsulting/BlogPosts/tree/master/Azure-Bicep/static.ip.allocation).

The deployment script resource executes a PowerShell script. It takes the following input parameters:

* Subnet CIDR address (i.e. in this blog post, i will use '10.101.2.192/28')
* One or more indexes (i.e. '3,4' will return the 3rd and 4th **usable** IP addresses in the subnet)
 
The following information is returned from the deployment script module outputs:

* Selected IPs: object that contains all specified IPs. The key for each value is "IP\<index_number\>" i.e.
  
  ```json
  {"IP3":"10.101.2.198","IP4":"10.101.2.199"}
  ```

* SubnetSize: The number of usable IPs in the Azure subnet
* GatewayIP: The default gateway IP for the subnet, which is the first IP in the subnet
* DNSIP1: The 1st DNS server IP for the subnet. This is the 2nd IP in the subnet
* DNSIP2: The 2nd DNS server IP for the subnet. This is the 3rd IP in the subnet
* FirstUsableIP: The first usable IP in the subnet. This is the 4th IP in the subnet
* LastUsableIP: The last usable IP in the subnet

![1](../../../../assets/images/2021/07/image1.png)

In my bicep templates, I can consume the deployment script module output and use the calculated IP addresses when creating resources that requires private IPs. i.e.

```hcl
//define which usable IPs to be used for the VMs. In this example, it's the 3rd and 4th usable IP.
param vmIpIndexes string = '3,4' 

//information about the existing subnet
param vnetRG string
param vnetName string
param subnetName string

//Retrieve the address prefix of an existing subnet
var subnetId = 'subscriptions/${subId}/resourceGroups/${vnetRG}/providers/Microsoft.Network/virtualNetworks/${vnetName}/subnets/${subnetName}'
var subnetAddressPrefix = reference(subnetId, '2020-07-01', 'Full').properties.addressPrefix

//execute deployment script
module private_ip_deployment_script './azcidrhost-function.bicep' = {
  name: 'private_ip'
  scope: resourceGroup(rg.name)
  params: {
    location: location
    addressPrefix: subnetAddressPrefix
    ipIndexes: vmIpIndexes //in this case, the value for this parameter is '3,4'
    storageAccountName: storage_account.outputs.name
    storageAccountId: storage_account.outputs.id
    storageAccountApiVersion: storage_account.outputs.apiVersion
  }
}

//create VM with a static IP
module ubuntu_vm_01 './vm-ubuntu.bicep' = {
  name: 'ubuntu01'
  scope: resourceGroup(rg.name)
  params: {
    adminUsername: vmAdminUserName
    adminPasswordOrKey: vmAdminPassword
    location: location
    vmName: vmName1
    //Since the deployment script has retrieved the 3rd and 4th usable IPs, use .outputs.selectedIPs.IP3 to reference the 3rd usable IP, and .outputs.selectedIPs.IP4 to reference the 4th usable IP.
    privateIP: private_ip_deployment_script.outputs.SelectedIPs.IP3
    subnetId: subnetId
    authenticationType: 'password'
  }
}
```

As you can see below, the **privateIP** parameter value for the VM module is 10.101.2.198, which is the 3rd usable IP (or the 6th IP) for the 10.101.2.192/28 subnet.

![2](../../../../assets/images/2021/07/image2.png)

**NOTE:** Unlike the Terraform cidrhost function which does not take Azure reserved IPs into consideration, this deployment script module returns the **usable** IPs from Azure subnets. so if you pass index number 1 into this deployment script module, it would be equivalent to number **4** if you are using cidrhost in Terraform. This is because the first 3 IPs in an Azure subnet are reserved. You can read more about reserved IPs [HERE](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-faq#are-there-any-restrictions-on-using-ip-addresses-within-these-subnets).

This is all I have to share today. This is my 2nd post on using Azure Deployment Scripts and Bicep to solve real world problems that I have faced before.

Until next time, take care!