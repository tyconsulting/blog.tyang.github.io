---
id: 7402
title: Deploying Containerized Socks5 Proxy Server Using ACR, ACI and Azure DevOps
date: 2020-06-16T21:02:21+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=7402
permalink: /2020/06/16/deploying-containerized-socks5-proxy-server-using-acr-aci-and-azure-devops/
spay_email:
  - ""
categories:
  - Azure
tags:
  - Azure
  - Azure DevOps
  - Container
  - Docker
---
<h3 style="text-align: left;">Background


In certain parts of the world, some of the popular apps and services that I use daily are blocked by state-owned firewalls. Couple of years ago, before we went to that part of the world for family holiday, I looked into setting up proxy servers on the public cloud so we can actually use our Android phones when we are over there. One of my high school friends told me he’s using a popular Socks5 proxy server called <a href="https://github.com/shadowsocks">Shadowsocks</a> hosted on a GCP VM instance. Shadowsocks is a Linux based server, it is extremely easy to setup, and it provides client apps for <a href="https://github.com/shadowsocks/shadowsocks-windows/releases">Windows</a>, <a href="https://github.com/shadowsocks/shadowsocks-iOS/wiki/Shadowsocks-for-OSX-Help">OSX</a>, Android (<a href="https://github.com/shadowsocks/shadowsocks-android/releases">GitHub</a>, <a href="https://play.google.com/store/apps/details?id=com.github.shadowsocks">Google Play</a>) and <a href="https://github.com/shadowsocks/shadowsocks-iOS/wiki/Help">iOS</a>.

The reason he’s using GCP was because of the price. its cheap, with the free credit you get when you sign up, it can last you few months if you have chosen a small size VM.

However, it would be against my religion if I followed his footpath and setup mine on GCP. Before our holiday, I created 3 Ubuntu VMs running Shadowsocks in 3 separate Azure regions (Australia, Singapore and USA). It turned out these VMs was extremely helpful. We used them everyday when we were up there. We’d switch between servers to get better speed if required. Without these servers, my daughter couldn’t watch her favourite cartoon on Netflix or other streaming services on her iPad, and I couldn’t install required apps onto my phone from Google Play Store nor could I play an online game I was addicted to at that time. One day I was in the middle of the CBD of a very large city that I have never visited before, I needed to use the GPS and the map to take me to where I needed to go, Google Maps wouldn’t even load unless I connected my phone to one of my Shadowsocks instances.

After our holiday, I kept those servers running for a while. My friends from Australia used it few times when they travelled to that particular country, and my friends from that country used them to access websites such as YouTube, Facebook, Twitter, etc. In the end, I shut them down to cut down my Azure consumption. Having 3 D series VMs sitting there idle do cost a bit.

Since Shadowsocks is very lightweight, and does not keep any persistent data. I thought it would be a very good candidate to be containerized so I can cut down the cost and just keep them running. I had some spare time over the last couple of weekends, and I’ve decided to try to hosted it on Azure Container Instance. After spending 2 Sunday afternoons, I managed to get it deployed and hosted on Azure Container Registry (ACR), Azure Container Instance (ACI) using Azure DevOps YAML pipelines. To be honest, I was surprised how easy it was to make the container image for it, only took me around 15 minutes to create it from scratch and have it fully tested and running on Docker running on my Mac Mini. Most of my time was spent on designing the YAML pipelines and have sufficient tests and scanning in place.

I’m going to go through how I used YAML pipelines in Azure DevOps to deploy an Azure Container Registry, then building and pushing the docker image to ACR, and created 3 container instances in 3 different Azure regions to run this image. Although I am using 2 separate projects in Azure DevOps and all my code are stored on Azure Repo, I’ve made a copy of all the code I’ve developed and stored it on a public GitHub Repo here: <a href="https://github.com/tyconsulting/containers.patterns">https://github.com/tyconsulting/containers.patterns</a>

<strong><span style="color: #ff0000;">NOTE:</span></strong> Before we continue, let me set this straight first. The purpose of this post is really to demonstrate and share my experience of deploying a simple containerized app to Azure using Azure Pipelines. Hosting Internet based proxy servers is legal. We are all law-abiding citizens, don’t hold me responsible for your inappropriate use of proxy servers.


## Pre-requisites


I’m using several Azure DevOps extensions in my pipelines. If you don’t want to use them, you can remove the steps in the pipeline:

<ul>
    <li>Microsoft Security Code Analysis: <a href="https://secdevtools.azurewebsites.net/">https://secdevtools.azurewebsites.net/</a></li>
    <li>Run ARM TTK Tests: <a href="https://marketplace.visualstudio.com/items?itemName=Sam-Cogan.ARMTTKExtension">https://marketplace.visualstudio.com/items?itemName=Sam-Cogan.ARMTTKExtension</a></li>
</ul>


## Azure Container Registry Pipeline


Firstly, I created a pipeline to deploy an container registry to host the docker image. The pattern is located in the <a href="https://github.com/tyconsulting/containers.patterns/tree/master/acr">acr folder</a> in the repo. The <a href="https://github.com/tyconsulting/containers.patterns/blob/master/acr/azure.pipelines.yaml">YAML pipeline</a> deploys an <a href="https://github.com/tyconsulting/containers.patterns/blob/master/acr/templates/azuredeploy.json">ARM template</a>, which contains an ACR and key vault (for storing ACR admin credential).

This pipeline uses several service connections for connecting to my Azure subscriptions (one for Dev and one for Prod). I named these connections sub-workload-dev and sub-workload-prod. It also uses 2 variable groups called "variables – acr (dev)" and "variables – acr (prod)". the following variables are stored in these variable groups:

<a href="https://blog.tyang.org/wp-content/uploads/2020/06/image.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2020/06/image_thumb.png" alt="image" width="485" height="590" border="0" /></a>

<ul>
    <li>acrLocation</li>
    <li>acrName</li>
    <li>acrReplicationLocation</li>
    <li>resourceGroup</li>
</ul>

I also created 2 environments called "dev" and "prod" in my project, which is required for the YAML pipeline:

<a href="https://blog.tyang.org/wp-content/uploads/2020/06/image-1.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2020/06/image_thumb-1.png" alt="image" width="656" height="289" border="0" /></a>

<a href="https://blog.tyang.org/wp-content/uploads/2020/06/image-2.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2020/06/image_thumb-2.png" alt="image" width="674" height="417" border="0" /></a>

The pipeline contains the following stages:

<table border="0" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td valign="top" width="40%"><a href="https://blog.tyang.org/wp-content/uploads/2020/06/image-3.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2020/06/image_thumb-3.png" alt="image" width="228" height="743" border="0" /></a></td>
<td valign="top"><strong>Test and Build</strong>
<ul>
    <li>Security Scan – AV and credential scan using Microsoft Security Code Analysis extension</li>
    <li>Pester Tests – Run <a href="https://www.powershellgallery.com/packages/PSScriptAnalyzer">PSScriptAnalyzer</a> against PS scripts used by the pipeline, and <a href="https://github.com/azure/arm-ttk">ARM-TTK</a> against the ARM template</li>
    <li>ARM Deployment Validation – Test ARM deployment in dev environment</li>
</ul>
<strong>Deploy Dev Stage</strong>
<ul>
    <li>Deploy the ARM template to Dev environment</li>
    <li>Add the ACR credential to newly created key vault</li>
</ul>
<strong>Deploy Prod Stage</strong>
<ul>
    <li>Deploy the ARM template to Prod stage</li>
    <li>Add the ACR credential to newly created key vault</li>
</ul>
</td>
</tr>
</tbody>
</table>

This pipeline is pretty straightforward, once completed, I’m ready to continue with the second pipeline.


## Docker Image


As part of the ACI pipeline, the docker image is built, scanned and pushed to ACR from the <a href="https://github.com/tyconsulting/containers.patterns/blob/master/containers/shadowsocks/Dockerfile">Dockerfile</a> I’ve created. it basically performs the following steps:

<ul>
    <li>use base image Ubuntu 18.04 and install shadowsocks-libev using apt-get</li>
    <li>run apt-get upgrade</li>
    <li>clean up</li>
    <li>copy the shadowsocks config file <a href="https://github.com/tyconsulting/containers.patterns/blob/master/containers/shadowsocks/config.json">config.json</a> located in the same directory of the docker file to the image.</li>
    <li>configure the image to start shadowsocks-libev service when starts up</li>
</ul>

The config file controls various settings such as port mapping, encryption method, and password when connecting to the shadowsocks server. I don’t really consider the password here a secret because it’s generic that everyone who connect to my instance would use. I’d put a very simple phrase here so it’s not too hard for people to enter when setting up profile on their client apps.


## Azure Container Instance Pipeline


The ACI pattern is located in the <a href="https://github.com/tyconsulting/containers.patterns/tree/master/containers/shadowsocks">container/shadowsocks</a> folder of my GitHub repo. Similar to the ACR pipeline, I needed to create some variable groups, service connections and environments to support the ACI pipeline:

<strong>Service Connections:</strong>

<ul>
    <li>sub-workload-dev (Azure Resource Manager)</li>
    <li>acr-taodev (Docker Registry)</li>
</ul>

<a href="https://blog.tyang.org/wp-content/uploads/2020/06/image-4.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2020/06/image_thumb-4.png" alt="image" width="278" height="304" border="0" /></a>

<strong>Variable Groups:</strong>

<a href="https://blog.tyang.org/wp-content/uploads/2020/06/image-5.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2020/06/image_thumb-5.png" alt="image" width="439" height="325" border="0" /></a>

<ul>
    <li>secrets – acr (linked to the key vault created by previous pipeline and added the secrets acrUseName & acrPassword as variables)</li>
</ul>

<a href="https://blog.tyang.org/wp-content/uploads/2020/06/image-6.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2020/06/image_thumb-6.png" alt="image" width="526" height="415" border="0" /></a>

<ul>
    <li>variables – shadowsocks (common)
<ul>
    <li>acr (the name of the ACR created by previous pipeline)</li>
    <li>acr-connection (the name of the acr service connection)</li>
    <li>imageName</li>
</ul>
</li>
</ul>

<a href="https://blog.tyang.org/wp-content/uploads/2020/06/image-7.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2020/06/image_thumb-7.png" alt="image" width="403" height="371" border="0" /></a>

<ul>
    <li>variables – shadowsocks (australia | usa | singapore)
<ul>
    <li>aciName</li>
    <li>location</li>
    <li>resourceGroup</li>
</ul>
</li>
</ul>

<a href="https://blog.tyang.org/wp-content/uploads/2020/06/image-8.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2020/06/image_thumb-8.png" alt="image" width="416" height="445" border="0" /></a>

<strong>Environments:</strong>

<ul>
    <li>australia</li>
    <li>singapore</li>
    <li>usa</li>
</ul>

Unlike the ACR pipeline, I’m only deploying container instances to a single subscription (which is my dev subscription). I’m using different stages for each location. so I’m using environment to separate locations, instead of dev / prod environments.

<a href="https://blog.tyang.org/wp-content/uploads/2020/06/image-9.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2020/06/image_thumb-9.png" alt="image" width="717" height="340" border="0" /></a>

The pipeline performs the following tasks:

<table style="height: 1418px;" border="0" width="707" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td valign="top" width="30%"><a href="https://blog.tyang.org/wp-content/uploads/2020/06/image-10.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2020/06/image_thumb-10.png" alt="image" width="183" height="1402" border="0" /></a></td>
<td valign="top" width="50%"><strong>Build and Test</strong>
<ul>
    <li>Security Scan – AV and credential scan using Microsoft Security Code Analysis extension</li>
    <li>Pester Tests – Run <a href="https://github.com/azure/arm-ttk">ARM-TTK</a> against the ARM template</li>
    <li>Build and Push Docker image – build image, use an open source container vulnerability scanner <a href="https://github.com/aquasecurity/trivy">Trivy</a> to scan the docker image for high and critical vulnerabilities, then push the docker image to ACR if the vulnerability scan is passed.</li>
    <li>ARM Deployment Validation – Test ARM deployment in dev environment</li>
    <li>Publish build artifacts</li>
</ul>
<strong>Deploy to Australia East</strong>
<ul>
    <li>Deploy the an ACI to run the Shadowsocks image in Australia East region (Sydney)</li>
</ul>
<strong>Deploy to Southeast Asia</strong>
<ul>
    <li>Deploy the an ACI to run the Shadowsocks image in Southeast Asia region (Singapore)</li>
</ul>
<strong>Deploy to USA</strong>
<ul>
    <li>Deploy the an ACI to run the Shadowsocks image in East US 2region (USA)</li>
</ul>
</td>
</tr>
</tbody>
</table>

Once the pipeline is completed, I can get the the public IP address for each container instance from the Azure portal.

<a href="https://blog.tyang.org/wp-content/uploads/2020/06/image-11.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2020/06/image_thumb-11.png" alt="image" width="765" height="286" border="0" /></a>

<a href="https://blog.tyang.org/wp-content/uploads/2020/06/image-12.png"><img class="" style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2020/06/image_thumb-12.png" alt="image" width="680" height="331" border="0" /></a>

I can then configure my Shadowsocks client app using the public IP address assigned to the container group, and the password specified in the Shadowsocks config file:

<a href="https://blog.tyang.org/wp-content/uploads/2020/06/image-13.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2020/06/image_thumb-13.png" alt="image" width="366" height="363" border="0" /></a>

<a href="https://blog.tyang.org/wp-content/uploads/2020/06/image-14.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2020/06/image_thumb-14.png" alt="image" width="337" height="408" border="0" /></a>

To test, I connected the Shadowsocks client to one of the profiles (i.e. the instance located in Singapore), and browsed to <a href="https://whatismyipaddress.com/">https://whatismyipaddress.com/</a>. I can see the IP address is not my home broadband IP address (since I’m home right now and my phone is connected to the home wifi), and it’s located in Singapore, and belongs to Microsoft (since it’s running on Azure):

<a href="https://blog.tyang.org/wp-content/uploads/2020/06/image-15.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2020/06/image_thumb-15.png" alt="image" width="286" height="615" border="0" /></a>


## Conclusion


I also found something interesting when playing with Shadowsocks. Based on my testing, I noticed some video streaming providers have different content for different regions. For example, since I’m based in Australia, I am able to watch an Aussie comedy called <a href="https://www.imdb.com/title/tt2401525/">Upper Middle Bogan</a> on Netflix. but if I connect my phone to my Shadowsocks instance in USA, I am not able to find the show on Netflix:

<a href="https://blog.tyang.org/wp-content/uploads/2020/06/image-16.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2020/06/image_thumb-16.png" alt="image" width="763" height="507" border="0" /></a>

Having my dedicated proxy servers across different part of the world definitely have its use cases beyond bypassing internet censorship.

I hope you find this post useful. feel free to reach out to me via Social media or GitHub.