---
id: 7254
title: Puppet Facts Detecting Cloud Providers for Windows VMs
date: 2020-02-27T16:48:07+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=7254
permalink: /2020/02/27/puppet-facts-detecting-cloud-providers-for-windows-vms/
spay_email:
  - ""
categories:
  - Azure
  - PowerShell
tags:
  - Azure
  - Powershell
---
I’m currently working on a Puppet Module for Windows Server. This module needs to detect which public cloud platform is the Windows server running on. More specifically, Azure, or GCP or AWS.

To do so, I can either write a custom Puppet fact in Ruby, or an external fact (i.e. in PowerShell). So I’ve written both.

The custom fact (cloud.rb) is placed in the <em><strong>lib/facter</strong></em> folder in the module. The external fact (cloud.ps1) is placed in the <em><strong>facts.d</strong></em> folder in the module.

<strong>Custom Fact:</strong>

https://gist.github.com/tyconsulting/610dbe8953417b2b5184a7a7a2696329

<strong>External Fact:</strong>

https://gist.github.com/tyconsulting/72da9fbbe49ce6b468e7703340c7a1f6

To test, you can add a debug message in your Puppet manifest:

<pre>#Custom Fact:

$cloud_provider = $::cloud['provider'],

notify{"cloud provider: ${cloud_provider}":}

#External Fact:

$cloud_provider_1 = $::cloud_provider,

notify{"cloud provider PS: ${cloud_provider_1}":}
</pre>

On the Puppet agent, when you apply the config using –debug flag, you will see it in the output:

<a href="https://blog.tyang.org/wp-content/uploads/2020/02/image.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2020/02/image_thumb.png" alt="image" width="582" height="120" border="0" /></a>

<a href="https://blog.tyang.org/wp-content/uploads/2020/02/image-1.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2020/02/image_thumb-1.png" alt="image" width="583" height="115" border="0" /></a>

So how does it work? for GCP and AWS, it’s pretty easy. All I needed to check is the VM serial number from the Win32_Bios WMI class. The AWS VM serial number starts with “ec2”, and the GCP VM starts with “GoogleCloud”.

Azure VM is a bit of complicated. You won’t be able to differentiate Hyper-V VM or Azure VM by querying WMI. However, Azure VMs are shipped with a built-in REST Endpoint called Azure Instance Metadata service (<a href="https://docs.microsoft.com/en-us/azure/virtual-machines/linux/instance-metadata-service">https://docs.microsoft.com/en-us/azure/virtual-machines/linux/instance-metadata-service</a>). By using querying this local endpoint on an Azure VM, you can retrieve metadata of the VM, i.e. location, resource Id, resource Group, etc. So the Puppet facts I developed simply query this endpoint, if the HTTP response code is 200, then it’s an Azure VM.