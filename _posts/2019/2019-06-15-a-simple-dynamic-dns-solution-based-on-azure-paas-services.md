---
id: 7096
title: A Simple Dynamic DNS Solution Based on Azure PaaS Services
date: 2019-06-15T19:51:10+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=7096
permalink: /2019/06/15/a-simple-dynamic-dns-solution-based-on-azure-paas-services/
categories:
  - Azure
tags:
  - Azure
  - Azure Automation
  - Azure DNS
  - Log Analytics
---

### Background

Many of us have used some kind of dynamic DNS services in the past. It is particularly useful for home network since it is very rare that ISPs provide static IP addresses free of charge nowadays.

Most of the home broadband modem and routers support some kind of dynamic DNS services. I’ve used a popular dynamic DNS provider many years ago. Back then, it was free. Then they started charging people for using their service. I think having to pay $50+ per year is too much for such simple service. Luckily my home broadband plan came with a static IP so I didn’t really need it.

I’ve changed my ISP few months ago. Currently, this new ISP charges $10 per month for a static IP. Right now a piece of work I’m working on requires me to connect back to my home lab when I’m not home. I don’t want sign up for another dynamic DNS service and nor do I want to pay $10 per month for a static IP. So I came up with a solution leveraging the existing resources I have setup in Azure, and build a very simple dynamic DNS service in my Azure subscription. It only took me couple of hours.

### Solution

Here’s what I’ve done:

In my home lab, I have multiple VMs managed by an Azure Log Analytics workspace in one of my subscriptions. I have previously purchased a .cloud domain name from GoDaddy and created an Azure DNS zone using this domain name.

My lab VMs are sending heartbeat logs to Azure Log Analytics workspace. In the Heartbeat logs, the "ComputerIP" field for all my lab VMs are identical – it is the public IP address dynamically assigned to my home broadband connection. This IP address changes from time to time because my home broadband gets disconnected every now and then.

Since the public IP address for my home broadband connection is stored in my Log Analytics workspace, and I have an Azure DNS zone, all I needed to build is an automation runbook that runs on a schedule, retrieve the most recent public IP from Log Analytics, and update the Azure DNS record set if it’s necessary.

For me, the benefits of using this solution are:

**1. It’s cheap, super cheap!!!**

I have multiple free Azure subscriptions from the MVP program. Since the DNS name has already been purchased previously. This solution does not cost me anything.

But if I do have to pay for everything myself, this is the cost breakdown (in US Dollars):

* A .cloud domain name costs approx. $5 per year
* Azure Consumption:
  * Log Analytics workspace: $0/month – Heartbeat data is free, it won’t get charged. so a free-tier workspace will do the job.
  * Automation Account: ~$0.44/month – First 500 minutes (of runbook execution) is free. The runbook takes less than a minute to run. if it’s schedule to run once per hour, I will need to pay approx. additional 220 minutes per month
  * Azure DNS: USD $0.9/month – $0.5 for hosted DNS zone, and $0.4 for first 1 million queries. I doubt anyone will have more than 1 million queries per month for the home network

<font style="background-color: rgb(255, 255, 0);">Total cost per year: ($0.44 + $0.9) x 12 + $5 = <strong>$21.08</strong></font>

I can further reduce the cost by scheduling the runbook to run less frequent. For example, if I configure the runbook to run once every 2 hours, I’d cut down the required automation minutes by half, and will be less than 500 minutes, and therefore Azure Automation would be free of charge.

I’d assume most of readers of my blog would have free Azure subscriptions that come with their MSDN subscriptions. If you have a MSDN subscription, the only out of pocket cost for you is a domain name.

**2. More flexible**

With those dynamic DNS providers, you’d have to use their DNS domain. This solution provides more flexibility. You can purchase a domain name that you actually like to use, something cool! And you get to pick what host name you want to use, and the TTL value. For me, I configured the TTY for my record to as low as 15 minutes and picked a host name "mancave.[my-domain-name]".

**3. No Requirements with networking devices**

In the past, whenever I get a new modem / router, I needed to make sure it supports the particular dynamic DNS provider that I was using. Currently I’m using Ubiquiti Unifi equipment at home. Before I started coding, my fellow MVP and friend Dieter Wijckmans pointed me to a forum post for configuring Ubiquiti Unifi Security Gateway working with Duck DNS. I simply couldn’t be bothered to use another service provider, and having to maintain a dependency with my network equipment moving forward.

### Setup Instruction

If you are interested to use my solution, and need to setup everything from scratch, here’s the high-level instruction:

1. Create an Azure Log Analytics workspace in your subscription. You may choose free-tier if you want to. Make sure Agent Heartbeat solution is enabled.
2. Deploy the Log Analytics agent to at least one computer in your home network. make sure it sends Heartbeat data to your workspace.
3. Create an Azure DNS zone in the same subscription as your Log Analytics workspace. This process is differs depending on your domain registrar, but overall, very simple.
4. Create an Azure Automation Account. Make sure you also create an Azure Run As Account. If you created it via the Azure portal, it will have Contributor role on the subscription level. This role has enough permission required for the runbook.
5. Make sure the following Az PowerShell modules are installed in the Azure Automation account:
  * Az.Accounts
  * Az.Dns
  * Az.OperationalInsights
6. Create the **update-dns record** runbook. Here’s the source code:

{%gist b485ce73e70c0b1b2fadf31ffbea2fdb %}

{:start="7"}
7. Schedule the runbook to run based on your requirements (i.e. hourly)

The runbook takes the following input parameters, which you will need to specify when creating the schedule:

* **AzureConnectionName** – (Optional) The name of the Azure RunAs connection. By default, if you created the Run As account via the portal, the name is "AzureRunAsConnection". If you don’t specify it, the default name will be used.
* **WorkspaceName** - Azure Log Analytics workspace name
* **WorkspaceResourceGroup** - Azure Log Analytics workspace resource group
* **DNSZone** - name of the Azure DNZ zone
* **DNSRecordSet** - Azure DNZ record set name (the host name you’d like to use)
* **TTLMinute** – (optional) Azure DNS record set TTL in minute. Default value set to 10
* **ComputerNameSearchString** - Computer name search string used in Log Analytics search query when searching for heartbeat record. the query uses endswith operator (case insensitive). You can either use the FQDN of a specific computer, or domain name if you have a AD domain at home and have installed Log Analytics agent on multiple computers.
* **MaxAllowedLogAnalyticsRecordAgeMinute** – (optional) Maximum allowed age (in minute) for the Log Analytics heartbeat record. If the most recent record is older than this value, DNS record set will not be updated. This parameter prevents the runbook update the DNS record with a stale IP (in case of an internet outage).

As shown below, the runbook took less than 1 minute to run, and it updates the DNS record if required

<a href="https://blog.tyang.org/wp-content/uploads/2019/06/image-3.png"><img width="947" height="735" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2019/06/image_thumb-3.png" border="0"></a>

After the runbook execution, I was able to resolve the host name with correct IP address using nslookup:

<a href="https://blog.tyang.org/wp-content/uploads/2019/06/image-4.png"><img width="569" height="185" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2019/06/image_thumb-4.png" border="0"></a>

I hope you find this solution helpful. Feel free to share your thoughts and suggestions.