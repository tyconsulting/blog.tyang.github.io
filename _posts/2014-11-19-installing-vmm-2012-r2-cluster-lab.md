---
id: 3346
title: Installing VMM 2012 R2 Cluster in My Lab
date: 2014-11-19T21:45:50+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=3346
permalink: /2014/11/19/installing-vmm-2012-r2-cluster-lab/
categories:
  - SCVMM
tags:
  - VMM
---
I needed to build a 2-node VMM 2012 R2 cluster in my lab in order to test an OpsMgr management pack that I’m working on. I was having difficulties getting it installed on a cluster based on 2 Hyper-V guest VMs, and I couldn’t find a real step-to-step detailed dummy guide. So after many failed attempts and finally got it installed, I’ll document the steps I took in this post, in case I need to do it again in the future.
<h3>AD Computer accounts:</h3>
I pre-staged 4 computer accounts in the existing OU where my existing VMM infrastructure is located:
<ul>
	<li>VMM01 – VMM cluster node #1</li>
	<li>VMM02 – VMM cluster node #2</li>
	<li>VMMCL01 – VMM cluster</li>
	<li>HAVMM – Cluster Resource for VMM cluster</li>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2014/11/SNAGHTML14878767.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML14878767" src="http://blog.tyang.org/wp-content/uploads/2014/11/SNAGHTML14878767_thumb.png" alt="SNAGHTML14878767" width="598" height="252" border="0" /></a>

I assign VMMCL01 full control permission to the HAVMM (Cluster resource) computer AD account:

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/SNAGHTML148c6725.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML148c6725" src="http://blog.tyang.org/wp-content/uploads/2014/11/SNAGHTML148c6725_thumb.png" alt="SNAGHTML148c6725" width="342" height="381" border="0" /></a>
<h3>IP Addresses:</h3>
I allocated 4 IP addresses, one for each computer account listed above:

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/image1.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/11/image_thumb1.png" alt="image" width="592" height="75" border="0" /></a>
<h3>Guest VMs for Cluster Nodes</h3>
I created 2 identical VMs (VMM01 and VMM02) located in the same VLAN. There is no requirement for shared storage between these cluster nodes.
<h3>Cluster Creation</h3>
I installed failover cluster role on both VMs and created a cluster.

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/image2.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/11/image_thumb2.png" alt="image" width="432" height="238" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/image3.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/11/image_thumb3.png" alt="image" width="442" height="179" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/image4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/11/image_thumb4.png" alt="image" width="443" height="234" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/image5.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/11/image_thumb5.png" alt="image" width="452" height="249" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/image6.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/11/image_thumb6.png" alt="image" width="455" height="218" border="0" /></a>
<h3>VMM 2012 R2 Installation</h3>
When installing VMM management server on a cluster node, the installation will prompt if you want to install a highly available VMM instance, select yes when prompted. Also, the SQL server hosting the VMM database must be a standalone SQL server or a SQL cluster, the SQL server cannot be installed on one of the VMM cluster node.

DB Configuration

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/image7.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/11/image_thumb7.png" alt="image" width="518" height="389" border="0" /></a>

Cluster Configuration

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/image8.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/11/image_thumb8.png" alt="image" width="518" height="389" border="0" /></a>

DKM Configuration

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/image9.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/11/image_thumb9.png" alt="image" width="516" height="391" border="0" /></a>

Port configuration (left as default)

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/image10.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/11/image_thumb10.png" alt="image" width="512" height="390" border="0" /></a>

Library configuration (need to configure manually later)

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/image11.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/11/image_thumb11.png" alt="image" width="511" height="387" border="0" /></a>

Completion

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/image12.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/11/image_thumb12.png" alt="image" width="498" height="377" border="0" /></a>

Run VMM install again on the second cluster node.

As instructed in the completion window, run ConfigureSCPTool<strong>.exe –AddNode HAVMM.corp.tyang.org CORP\HAVMM$</strong>

Cluster Role is now created and can be started:

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/image13.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/11/image_thumb13.png" alt="image" width="528" height="168" border="0" /></a>
<h3>OpsMgr components</h3>
In order to integrate VMM and OpsMgr, OpsMgr agent and console need to be installed on both VMM cluster node. I pointed the OpsMgr agent to my existing management group in the lab, approved manually installed agent and enabled agent proxy for both node (required for monitoring clusters).
<h3>Installing Update Rollup</h3>
After OpsMgr components are installed, I then installed the following updates from the latest System Center 2012 R2 Update Rollup (UR 4 at the time of writing):
<ul>
	<li>OpsMgr agent update</li>
	<li>OpsMgr console update</li>
	<li>VMM management server update</li>
	<li>VMM console update</li>
</ul>
<h3>Connect VMM to OpsMgr</h3>
I configured OpsMgr connection in VMM console:

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/2014-11-19_22-29-43.jpg"><img class="alignnone  wp-image-3350" src="http://blog.tyang.org/wp-content/uploads/2014/11/2014-11-19_22-29-43.jpg" alt="2014-11-19_22-29-43" width="537" height="399" /></a>

&nbsp;
<h3>Conclusion</h3>
The intention of this post is simply to dump all the screenshots that I’ve taken during the install, and document the "correct" way to install VMM cluster that worked in my lab after so many failed attempts.

The biggest hold up for me was without realising I need to create a separate computer account and allocate a separate IP address for the cluster role (HAVMM). I was using the cluster name (VMMCL01) and its IP address in the cluster configuration screen and the installation failed:

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/image15.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/11/image_thumb15.png" alt="image" width="477" height="361" border="0" /></a>

After going to through the install log, I realised I couldn’t use the existing cluster name:

<a href="http://blog.tyang.org/wp-content/uploads/2014/11/image16.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/11/image_thumb16.png" alt="image" width="547" height="225" border="0" /></a>

When I ran the install again using different name and IP address for the cluster role, the installation completed successfully.