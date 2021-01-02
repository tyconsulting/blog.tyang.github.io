---
id: 5281
title: OMS Log Analytics Forwarder (aka OMS Gateway) Preview
date: 2016-03-17T18:13:39+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=5281
permalink: /2016/03/17/oms-log-analytics-forwarder-aka-oms-gateway-preview/
categories:
  - OMS
tags:
  - OMS
---
Over the last few days, I had the privilege to review and test a new component of the OMS family called "OMS Log Analytics Forwarder". Since this component has now been released for public preview, I’d like to dedicate this post to my experience with OMS Log Analytics Forwarder so far.

## Initial Configuration

First of all, you can download the bits and documentation from Microsoft Download site here: <a title="https://www.microsoft.com/en-us/download/details.aspx?id=51603&WT.mc" href="https://www.microsoft.com/en-us/download/details.aspx?id=51603&WT.mc">https://www.microsoft.com/en-us/download/details.aspx?id=51603&WT.mc</a>

In my lab, I have created a new VM running Windows Server 2016 TP4 Server Core. I firstly installed the OMS Direct MMA agent, then the OMS Log Analytics Forwarder using command:

msiexec /i "Microsoft OMS Log Analytics Forwarder.msi"

<a href="http://blog.tyang.org/wp-content/uploads/2016/03/image-15.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/03/image_thumb-15.png" alt="image" width="490" height="77" border="0" /></a>

Once installed, you will see the following components on the VM:
<ul>
<ul>
	<li>"Microsoft OMS Log Analytics Forwarder" service</li>
</ul>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2016/03/image-16.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; margin: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/03/image_thumb-16.png" alt="image" width="244" height="101" border="0" /></a>
<ul>
<ul>
	<li>OMS Log Analytics Forwarder Log</li>
</ul>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2016/03/image-17.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; margin: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/03/image_thumb-17.png" alt="image" width="244" height="160" border="0" /></a>
<ul>
<ul>
	<li>Various performance counters:</li>
</ul>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2016/03/image-18.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; margin: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/03/image_thumb-18.png" alt="image" width="244" height="183" border="0" /></a>

Since I already have OMS MMA agent installed and this gateway box is directly connected to one of my OMS workspace, I have configured my OMS workspace to collect these OMS Log Analytics Forwarder counters

<a href="http://blog.tyang.org/wp-content/uploads/2016/03/image-19.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/03/image_thumb-19.png" alt="image" width="390" height="321" border="0" /></a>

and I also configured my OMS workspace to collect the OMS Log Analytics Forwarder Log in the Windows Event log section:

<a href="http://blog.tyang.org/wp-content/uploads/2016/03/image-20.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/03/image_thumb-20.png" alt="image" width="379" height="148" border="0" /></a>

The <strong>Active Client Connection</strong> counter represents the number of TCP connections clients established to the OMS Log Analytics Forwarder service. This is not a true representation of number of active clients connected to the forwarder.

The <strong>Connected Client counter</strong> represent the number of clients connected (both Windows and Linux). However, if I stop the MMA agent on an agent connected to this  forwarder, the counter value will not decrease straightaway. This is because in this release, the counter only resets once a day. So you may need to wait for up to 24 hours before you see the value decreases.

## Agent Configuration

Now that the OMS Log Analytics Forwarder component has been properly installed, I started reconfiguring some existing agents to go through this forwarder (gateway) machine.

On the Direct-Attached Windows agent, I simply added it under the Proxy Settings tab:

<a href="http://blog.tyang.org/wp-content/uploads/2016/03/image-21.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/03/image_thumb-21.png" alt="image" width="402" height="338" border="0" /></a>

On the Linux agent, we can reconfigure the agent to use the proxy server using the following command (assuming the latest version of the OMS agent is installed):

sudo sh ./omsagent-1.1.0-28.universal.x86.sh --upgrade -p http://&lt;proxy user&gt;:&lt;proxy password&gt;@&lt;proxy address&gt;:&lt;proxy port&gt; –w &lt;workspaceid&gt; -s &lt;shared key&gt;

This is documented on here: <a title="https://github.com/Microsoft/OMS-Agent-for-Linux/blob/master/docs/OMS-Agent-for-Linux.md#configuring-the-agent-for-use-with-an-http-proxy-server" href="https://github.com/Microsoft/OMS-Agent-for-Linux/blob/master/docs/OMS-Agent-for-Linux.md#configuring-the-agent-for-use-with-an-http-proxy-server">https://github.com/Microsoft/OMS-Agent-for-Linux/blob/master/docs/OMS-Agent-for-Linux.md#configuring-the-agent-for-use-with-an-http-proxy-server</a>

## Additional Configuration for Linux Agents

During my testing, the Windows agents started communicating through the gateway straightaway. This can be verified by looking for Event ID 103 in the OMS Log Analytics Forwarder Log:

<a href="http://blog.tyang.org/wp-content/uploads/2016/03/SNAGHTML21500845.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML21500845" src="http://blog.tyang.org/wp-content/uploads/2016/03/SNAGHTML21500845_thumb.png" alt="SNAGHTML21500845" width="394" height="277" border="0" /></a>

and followed by Event ID 107 indicating the connection has been successful:

<a href="http://blog.tyang.org/wp-content/uploads/2016/03/image-22.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/03/image_thumb-22.png" alt="image" width="406" height="285" border="0" /></a>

However, with the Linux agent, I get an error event (Event ID 105) right after Event ID 103:

<a href="http://blog.tyang.org/wp-content/uploads/2016/03/SNAGHTML21537d28.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML21537d28" src="http://blog.tyang.org/wp-content/uploads/2016/03/SNAGHTML21537d28_thumb.png" alt="SNAGHTML21537d28" width="407" height="285" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2016/03/image-23.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/03/image_thumb-23.png" alt="image" width="408" height="287" border="0" /></a>

If you pay close attention to the Event ID 103 events for both Windows and Linux machines, you may notice they are trying to connect to different servers. The Windows machine is trying to connect to xxxxxx.oms.opinsights.azure.com:443 whereas Linux machine is trying to connect to scus-agentservice-prod-1.azure-automation.net

To fix this issue for Linux machine, please go to the server where OMS Log Analytics Forwarder component is installed, open "C:\Program Files\Microsoft OMS Log Analytics Forwarder\allowedlist_server.txt", and add "scus-agentservice-prod-1.azure-automation.net" to this text file.

<a href="http://blog.tyang.org/wp-content/uploads/2016/03/image-24.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/03/image_thumb-24.png" alt="image" width="452" height="114" border="0" /></a>

After I saved the file and restarted the OMS Log Analytics Forwarder service, the Linux agent started communicating through this forwarder server – I verified by examining a NRT perf counter for Linux as you can see from the screenshot below, the data started coming in after I made the change:

<a href="http://blog.tyang.org/wp-content/uploads/2016/03/image-25.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/03/image_thumb-25.png" alt="image" width="516" height="128" border="0" /></a>

I am pretty sure Microsoft will fix this issue in the future (since we are still at the preview stage).

## Additional Information

Nini Ikhena, a program manager from the OMS product team has posted an excellent post on OMS blog: <a title="https://blogs.technet.microsoft.com/msoms/2016/03/17/oms-log-analytics-forwarder/" href="https://blogs.technet.microsoft.com/msoms/2016/03/17/oms-log-analytics-forwarder/">https://blogs.technet.microsoft.com/msoms/2016/03/17/oms-log-analytics-forwarder/</a>

My friend and fellow CDM MVP Daniele Grandini has also posted an excellent in-depth post few minutes ago (well, Daniele beat me this time): <a title="https://nocentdocent.wordpress.com/2016/03/17/msoms-gateway-server-preview/" href="https://nocentdocent.wordpress.com/2016/03/17/msoms-gateway-server-preview/">https://nocentdocent.wordpress.com/2016/03/17/msoms-gateway-server-preview/</a>

I strongly recommend you to go and read the above mentioned 2 blog posts as they covered some aspect that I didn’t cover in this blog post.

lastly, if you have any suggestions or issues, please feel free to provide feedback via UserVoice: <a title="https://feedback.azure.com/forums/267889-azure-operational-insights" href="https://feedback.azure.com/forums/267889-azure-operational-insights">https://feedback.azure.com/forums/267889-azure-operational-insights</a>