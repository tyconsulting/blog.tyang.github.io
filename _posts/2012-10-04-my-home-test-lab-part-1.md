---
id: 1466
title: 'My Home Test Lab &#8211; Part 1'
date: 2012-10-04T23:57:55+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=1466
permalink: /2012/10/04/my-home-test-lab-part-1/
categories:
  - Hyper-V
  - Others
tags:
  - Hyper-V
  - Lab
---
<h2><a href="http://blog.tyang.org/wp-content/uploads/2012/10/lab.jpg"><img class="alignleft  wp-image-1468" title="lab" src="http://blog.tyang.org/wp-content/uploads/2012/10/lab.jpg" alt="" width="235" height="314" /></a>Background</h2>
I started a lab environment at home around 2 years ago and I’ve been keep investing in this lab environment over the time. I often get asked how was my lab setup. And most of the time when I tried to answer the question and explain how it was setup, I often forget some components. I have been wanting to properly document it for a long time but never got around to it.

Until 2 weeks ago, I had 2 machines with 24GB RAM each running bare-metal Hyper-V 2008 R2 and another desktop with 8GB RAM running Windows 7 with VMware workstation on top which hosts couple of VMs. The capacity of the lab was running very very low ever since System Center 2012 was released earlier this year as I had to run both 2007 and 2012 environments at same time. I had to down size my 2007 environments and decommission some machines such as my Exchange 2010 box to free up some capacity.

2 weeks ago, I bought another machine with 64GB of RAM and started rebuilding the entire lab with Windows Server 2012 and Windows 8. I though it’s a good time to document and blog how the lab is setup so I’ve got my lab configuration documented and I can simply point people to this post when I get asked next time.

This topic is probably going to be too big for one post so I’m going to split it into a 2-part series.

I’m going to concentrate on the physical / hardware part of the lab in part 1.

Ever since my lab was initially setup, I’ve been using <a href="http://www.vyatta.org/">vyatta virtual router appliance</a> on the Hyper-V 2008 R2 and VMware workstation machines. During the rebuild process over the last 2 weeks, I have spent a lot of time working / discussing the routing solutions for the lab with colleagues and friends and finally implemented another what I believe a better routing solution using <a href="https://www.centos.org/">CentOS 6.3</a>. In part 2, I’ll discuss my previous experience with vyatta and go through detailed steps how I implemented CentOS as virtual routers.

<strong><span style="color: #ff0000;">Disclaimer:</span></strong>
<ul>
	<li>In this 2-part series, I’m going to touch base on Hyper-V, networking, Linux and computer hardware, which none of these that I consider myself an expert of. There might be some parts of the article that you consider to be inaccurate or there are better ways of doing it. I’m always open for suggestions and constructive feedback. At the end of the day, all of this is about sharing my personal experience with the community and documenting what I have done so far for myself.</li>
</ul>
OK. let’s start.

First of all, every piece of hardware in my lab is considered consumer grade product. which means all machines are built using PC components and there are no server computers, no UPS, no rakcs, no layer 2 / layer 3 switches, no fibre channel cards or switches, no shared storage (either iSCSI or fibre), no tape libraries…. – Funny enough, I know someone got them all at home! I’ve always been very conscious of what to put in the lab. I had an old HP DL380 server which I ended up gave away because I can’t stand the noise it generates in my study!

Secondly, All the Microsoft software I use are licensed through my TechNet subscription. For around $400 AUD a year, I get to use pretty much everything I need from Microsoft (almost everything, Visual Studio and SQL Developer edition is not covered in TechNet subscription). I know that in other countries, TechNet subscriptions are significantly cheaper than Australia. i.e. the price in USA is almost half of what we pay here! It’s good investment. not to mention you get your money back during tax return every year anyway.
<h2>Lab Diagram:</h2>
<a href="http://blog.tyang.org/wp-content/uploads/2012/10/Home-Network-Diagram.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="Home Network Diagram" src="http://blog.tyang.org/wp-content/uploads/2012/10/Home-Network-Diagram_thumb.png" alt="Home Network Diagram" width="580" height="539" border="0" /></a>

Above is roughly how everything hangs together at home. The original Visio diagram can be downloaded <a href="http://blog.tyang.org/wp-content/uploads/2012/10/Home-Network-Diagram.zip">here</a> if you can’t see the details in this small picture.
<h2>Computers:</h2>
<strong>HyperV01</strong>
<ul>
	<li>OS: Windows Server 2012 Data Center With Hyper-V Role</li>
	<li>Motherboard: <a href="http://www.intel.com/content/www/us/en/motherboards/desktop-motherboards/desktop-board-dx79sr.html">Intel Desktop Board DX79SR</a></li>
	<li>CPU: <a href="http://ark.intel.com/products/63698/Intel-Core-i7-3820-Processor-(10M-Cache-3_60-GHz)">Intel Core i7 3820</a></li>
	<li>Memory: 64GB (8x8GB DDR3)</li>
	<li>Hard Drive: 3x1TB SATA and 1x120GB SSD</li>
	<li>NIC: 2 Onboard Intel GB NIC and 1 Intel PCI GB NIC</li>
</ul>
<strong>HyperV02</strong>
<ul>
	<li>OS: Windows Server 2012 Data Center With Hyper-V Role</li>
	<li>Motherboard: <a href="http://www.asus.com.au/Motherboards/Intel_Socket_1366/P6X58DE/">ASUS P6X58D-E</a></li>
	<li>CPU: <a href="http://ark.intel.com/products/37150/Intel-Core-i7-950-Processor-8M-Cache-3_06-GHz-4_80-GTs-Intel-QPI">Intel Core i7 950</a></li>
	<li>Memory: 24GB (6x4GB DDR3)</li>
	<li>Hard Drive: 3x500GB SATA and 1x120GB SSD</li>
	<li>NIC: 1 Onboard Marvell GB NIC and 2 Intel PCI GB NIC</li>
</ul>
<strong>Study</strong>
<ul>
	<li>OS: Windows 8 Enterprise With Hyper-V Role</li>
	<li>Motherboard: <a href="http://www.asus.com.au/Motherboards/Intel_Socket_1366/P6X58DE/">ASUS P6X58D-E</a></li>
	<li>CPU: <a href="http://ark.intel.com/products/37150/Intel-Core-i7-950-Processor-8M-Cache-3_06-GHz-4_80-GTs-Intel-QPI">Intel Core i7 950</a></li>
	<li>Memory: 24GB (6x4GB DDR3)</li>
	<li>Hard Drive: Too many to count. 16TB in total</li>
	<li>NIC: 1 Onboard Marvell GB NIC and 1 Intel PCI GB NIC</li>
</ul>
<strong>VMM01</strong>
<ul>
	<li>OS: Windows Server 2012 Enterprise</li>
	<li>Motherboard: <a href="http://www.asus.com/Motherboards/Intel_Socket_775/P5Q_Deluxe/">ASUS P5Q Deluxe</a></li>
	<li>CPU: <a href="http://ark.intel.com/products/35365/Intel-Core2-Quad-Processor-Q9400-6M-Cache-2_66-GHz-1333-MHz-FSB">Intel Core2 Quad Q9400</a></li>
	<li>Memory: 8GB (4x2GB DDR2)</li>
	<li>Hard Drive: 1x500GB SATA</li>
	<li>NIC: 2 Onboard Marvell GB NIC</li>
</ul>
<h2>Networking Equipment:</h2>
<strong>ADSL Modem & Router with WiFi AP and 4 port switch</strong>
<ul>
	<li><a href="http://www.billion.com/product/wireless/bipac7300n-wireless-draft-11n-ADSL2-broadband-router.html">Billion BiPAC 7300N</a></li>
</ul>
<strong>Home & Lab Network 8-Port GB Switches</strong>
<ul>
	<li>2 x <a href="http://www2.netgear.com.au/au/Product/Switches/Unmanaged-Desktop-Sw/GS608">NetGear GS608</a></li>
</ul>
<strong>Lab Network 5-Port GB Switch</strong>
<ul>
	<li>1 x <a href="http://www.netgear.com/home/products/switches-and-access-points/unmanaged-switches/gs605.aspx">NetGear GS605</a></li>
</ul>
<strong>Lab Wireless Access Point</strong>
<ul>
	<li>1x <a href="http://www.netgear.com.au/service-provider/products/access-points-wireless-controllers/access-points/WN604.aspx">NetGear N150 Wireless Access Point WN604</a></li>
</ul>
So above list is pretty much what’s been used in the lab. I’ve also got 2 Windows laptop and a Macbook Pro that I can connect to the lab environment either by physically connected to the 5-port switch or via the lab WiFi. the media centre PC sitting in the rumpus room is also member of my lab AD domain and is being managed by my SCCM and SCOM infrastructure in the lab.

Now that since I’ve mentioned my media centre PC is being managed by System Center, I’d like to remind you that if you want to do the same at home and use SCCM to patch your media centre machine, please keep in mind <strong>DO NOT</strong> set the SCCM maintenance window for this machine to be every Friday or Saturday night! I was once watching a movie with my wife on a Saturday night and a message box popped up saying the machine is going to be patched and I couldn’t cancel it because it has passed the deadline of the update deployment! In the end, we had to wait for it to complete… It made me look stupid in front of my wife… <img class="wlEmoticon wlEmoticon-sadsmile" style="border-style: none;" src="http://blog.tyang.org/wp-content/uploads/2012/10/wlEmoticon-sadsmile.png" alt="Sad smile" />

Anyways, now let me explain the setup in details.
<h2>PC Hardware</h2>
<strong>Motherboard & Memory</strong>

The original 2 Hyper-V hosts were running on the ASUS P6X58D-E motherboard with 24GB (6x4GB) of RAM. I bought these 2 machines back in 2010 and 2011. Back then, I couldn’t find any PC motherboard that has more than 6 memory slots and the biggest PC memory stick I could get in the computer shops were 4GB sticks. Therefore the 2 PCs with this ASUS motherboard have 24GB each. In the ASUS website, it stated the maximum memory this board supports is 24GB. which is based on 6 slots x 4GB. I have actually tested 8GB sticks on this board and it worked just fine. so when I’m running out of capacity again in the future, I can upgrade the RAM on these board to 48GB (6x8GB).

I have to say, I’m really impressed with the new motherboard that I’ve just got: <a href="http://www.intel.com/content/www/us/en/motherboards/desktop-motherboards/desktop-board-dx79sr.html">Intel DX79SR</a>. it has 8 memory slots, 4xUSB 3 ports on the back panel and 1 for the front. 2xIntel onboard GB NICs, 4x6Gb/s SATA connectors, 4x3Gb/s SATA connectors. It even comes with a WiFi/bluethooth module which you can optionally attach to the case (connected to a USB 2 connector on the motherboard). It has pretty much everything I need for the Hyper-V box. There’s no need to connect the WiFi and bluetooth module to the Hyper-V server. Since it’s connecting to the motherboard using a USB port, I’ve connected this to my desktop machine:

<a href="http://blog.tyang.org/wp-content/uploads/2012/10/image.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/10/image_thumb.png" alt="image" width="580" height="83" border="0" /></a>

<strong>Hard Disks</strong>

I’ve got 3 traditional SATA drives on each Hyper-V host to spread the Disk I/O for virtual machines. I’ve also added a 120GB SSD for each host to host VHDs used for SQL databases. for example, when I created a VM to run SQL for SCOM, I’ve created 2 separate VHDs on the SSD drive to host the SQL data and log files.

<a href="http://blog.tyang.org/wp-content/uploads/2012/10/image1.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/10/image_thumb1.png" alt="image" width="580" height="150" border="0" /></a>

<strong>Video Card</strong>

None of these motherboards have onboard video. I just bought whatever the cheapest NVidia card I could find for each machine. At the end of the day, I RDP to these machines 99% of the time and I don’t play with RemoteFX so there’s no need to utilise the GPU on servers.
<h2>Networking</h2>
In HyperV01, I’ve configured 4 virtual switches. one virtual switch (192.168.1.0) is connected to the physical network using a teamed connection (Now Windows Server 2012 supports NIC teaming natively). The rest are internal switches:

<strong>Hyperv01:</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2012/10/image2.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/10/image_thumb2.png" alt="image" width="429" height="303" border="0" /></a>

In Hyperv02, it’s very similar to Hyperv01. However I have 2 external connections. 192.168.1.0 is my physical network shared with the rest of home network. 192.168.6.0 network is connected to a physical NIC which is connected to the 5-Port Lab GB switch. I’ve configured it this way so I can physically connect my laptops to the lab using this connection and play with PXE boot and OSD in SCCM <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" src="http://blog.tyang.org/wp-content/uploads/2012/10/wlEmoticon-smile.png" alt="Smile" />. I’ve also connected a WiFi access point to 5-port switch so I can connect the laptop wirelessly.

<strong>Hyperv02:</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2012/10/image3.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/10/image_thumb3.png" alt="image" width="443" height="256" border="0" /></a>

<span style="color: #ff0000;"><strong>*Note:</strong> At the time of writing this article, Hyperv02 is still running bare metal Hyper-V 2008 R2. thus above screenshot looks a little bit different.</span>

Another reason why I added the 5-port switch and WiFi access point to the lab environment is because the issue with name resolution.

My ADSL router is also configured as a DHCP server serving other devices at home (i.e. tablets, phones, Xbox, Wii and laptops when they are not connected to the lab). The DNS servers configured in the ADSL router DHCP scope are pointed to my ISP’s DNS servers. I cannot set conditional forwarding on my ADSL router to forward DNS requests for my lab machines to the domain controllers in my lab. I don’t really want to use my lab DCs for name resolution for all other devices at home because it means I’ll have to make sure these 2 DCs I have in the lab have to be always on. Therefore, to be able to login to the lab domain, the DNS settings on the machine has to be statically configured (which I’ve done for my media centre PC), or the IP configuration has to come from the DHCP server in my lab (which is one of my DCs). Therefore, I’ve added the 5-port switch and WiFi access point in the lab environment.

In my study PC, I’ve only configured 2 internal networks:

<strong>Study:</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2012/10/image4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/10/image_thumb4.png" alt="image" width="472" height="232" border="0" /></a>

So all up, I’ve got 9 subnets: 192.168.1.0 – 192.168.9.0

Now, here is where the virtual routers come in. I need to be able to route the network traffic across each virtual network inside virtual hosts. I don’t have lay 3 switches or routers at home to allow me to do so.

In each Hyper-V host, I’ve also configured a virtual router device (I used to use vyatta but now I’ve switched to CentOS. This is going to be covered in part 2). Take Hyperv01 for example, there’s a virtual machine called HyperVRT01, which is the virtual router for this host (running CentOS):

<a href="http://blog.tyang.org/wp-content/uploads/2012/10/image5.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/10/image_thumb5.png" alt="image" width="580" height="227" border="0" /></a>

For each virtual switch on HyperV01, I’ve configured a Network Adapter for the router HyperVRT01:

<a href="http://blog.tyang.org/wp-content/uploads/2012/10/image6.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/10/image_thumb6.png" alt="image" width="264" height="477" border="0" /></a>

Since I have 3 virtual hosts in total, I now have 3 CentOS instances running, each of them has been configured one connection to 192.168.1.0 (which is my physical network). each of these 3 connections has been given an IP address:

HyperVRT01 (hosted by HyperV01): 192.168.1.252

HyperVRT02 (hosted by HyperV02): 192.168.1.254

StudyRT01 (hosted by Study): 192.168.1.253

these 3 IP addresses becomes the ultimate gateway for all virtual networks inside the Hyper-V host to the outside world.

I then configure the static routes within CentOS (again, to be explained in Part 2).

<strong>ADSL Router:</strong>

Additionally, I’ve configured static routes in my ADSL router:

<a href="http://blog.tyang.org/wp-content/uploads/2012/10/image7.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/10/image_thumb7.png" alt="image" width="580" height="182" border="0" /></a>

This allows the rest of the home network to communicate to the lab (via IP address).

*Note: The network speed on the 4-Port switch on the ADSL router is only 100MB. However, since I’ve configured the static routes in each CentOS instance, traffic between each Hyper-V host does not go over the ADSL router (192.168.1.1). i.e. if I trace route from a VM from HyperV01 to a VM in Study:

<a href="http://blog.tyang.org/wp-content/uploads/2012/10/image8.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/10/image_thumb8.png" alt="image" width="580" height="450" border="0" /></a>

As shown above, the traffic went straight from one CentOS router to the other CentOS router.

<strong>Remote Access:</strong>

I often need to access my lab when I’m not at home (i.e. in the office). This is pretty easy to configure. I firstly register a dynamic DNS name from a provider supported by my router (i.e. dyndns). I then configure port mapping on the router. i.e. external TCP port 3390 points back to port 3389 of a VM in the lab (3389 = RDP port). or external TCPport 8888 to port 22 of a CentOS instance (22 = SSH port). When I’m in the office, I use my laptop with a wireless boardband device to connect back to home lab environment.

<strong>Other Advise:</strong>

If you are working in IT infrastructure space, you are probably that’s it’s common for organisations to keep track of their IP address allocations. Since day one, I’ve been using an Excel spreadsheet to track how are IP addresses used in my lab. In the spreadsheet, I’ve create a sheet (tab) for each subnet. it’s been working great for me. If you have a complex environment and you don’t have a way to track your IP addresses, I’d suggest you to do the same!

OK, this is pretty much all I have for part 1 of the series. In part 2, I’ll go through the background and experience on why I went away from vyatta and steps I setup each CentOS instances as virtual routers. Stay tuned!

05/10/2012: <a href="http://blog.tyang.org/2012/10/05/my-home-test-lab-part-2/">Continue to Part 2</a>!