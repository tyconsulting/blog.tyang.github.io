---
id: 1506
title: 'My Home Test Lab &#8211; Part 2'
date: 2012-10-05T22:41:35+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=1506
permalink: /2012/10/05/my-home-test-lab-part-2/
categories:
  - Hyper-V
  - Others
tags:
  - CentOS
  - Hyper-V
  - Vyatta
---
<a href="http://blog.tyang.org/wp-content/uploads/2012/10/meth-lab2.jpg"><img class="alignleft size-medium wp-image-1508" title="meth-lab2" src="http://blog.tyang.org/wp-content/uploads/2012/10/meth-lab2-240x300.jpg" alt="" width="240" height="300" /></a>This is the part 2 of my 2-part series on how my home test lab is configured.

Part 1 can be found <a href="http://blog.tyang.org/2012/10/04/my-home-test-lab-part-1/">here</a>.

In this second part, I’m going to talk about my previous experience with <a href="http://www.vyatta.org/">vyatta virtual router appliance</a> and how I replaced vyatta with <a href="https://www.centos.org/">CentOS</a>.

<strong><span style="color: #ff0000;">Disclaimer:</span></strong>

The content of this article is purely based on my personal experience and opinions. I have absolutely no intentions to criticise vyatta. To be honest, I still think it’s a great product, however, it just does not suit my needs in my lab environment.

<strong>About Vyatta:</strong>

Stefan Stranger has written a great article on <a href="http://blogs.technet.com/b/stefan_stranger/archive/2008/08/25/vyatta-virtual-router-on-hyper-v.aspx">Vyatta Virtual Router on Hyper-V</a> back in 2008. The version Stefan used in his article was 4.0 and when I am writing this article, the latest version is 6.4. It can be downloaded here: <a href="http://www.vyatta.org/downloads">http://www.vyatta.org/downloads</a>

Vyatta is extremely light-weight. In my previous environment, I only needed to assign 256MB of RAM to each Vyatta instance. It is also very easy to setup. for me to configure an instance from scratch, would take me no more than 10 minutes.

Below is a list the setup commands I had to run to configure a Vyatta from scratch (based on my previous lab configuration):
<table width="584" border="1" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td valign="top" width="582"><em>configure
set system host-name vyatta
set interfaces ethernet eth0 address 192.168.1.254/24
set interfaces ethernet eth1 address 192.168.2.254/24
set interfaces ethernet eth2 address 192.168.3.254/24
set interfaces ethernet eth3 address 192.168.6.254/24
set service ssh
set service telnet
set system name-server 192.168.2.10
set system name-server 192.168.4.10

set system gateway-address 192.168.1.1

set protocols static route 0.0.0.0/0 next-hop 192.168.1.1
set protocols static route 192.168.1.0/24 next-hop 192.168.1.254
set protocols static route 192.168.2.0/24 next-hop 192.168.2.254
set protocols static route 192.168.3.0/24 next-hop 192.168.3.254
set protocols static route 192.168.4.0/24 next-hop 192.168.1.253
set protocols static route 192.168.5.0/24 next-hop 192.168.1.253
set protocols static route 192.168.6.0/24 next-hop 192.168.6.254
set protocols static route 192.168.7.0/24 next-hop 192.168.1.252
set protocols static route 192.168.8.0/24 next-hop 192.168.1.252
set protocols static route 192.168.9.0/24 next-hop 192.168.1.252

set service snmp community public
set service dhcp-relay server 192.168.4.10
set service dhcp-relay interface eth0
set service dhcp-relay interface eth1
set service dhcp-relay interface eth2
set service dhcp-relay interface eth3

set system login user vyatta authentication plaintext-password password1234

commit
save</em></td>
</tr>
</tbody>
</table>
So why am I moving away from Vyatta? the short answer is: Vyatta does not officially support Hyper-V:

<a href="http://blog.tyang.org/wp-content/uploads/2012/10/image9.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/10/image_thumb9.png" alt="image" width="574" height="277" border="0" /></a>

Read between the lines, Hyper-V is not supported.

What does it mean in my lab Hyper-V 2008 R2 hosts in the past (Based on version 6.1 that I have implemented)?
<ul>
	<li><strong>After I reboot the Vyatta VM, all configurations were lost.</strong> It needed to be reconfigured again from scratch (that’s why I became so good at its commands). To work around this issue, I created a VM snapshot after it’s fully configured and I had to revert it back to the snapshot after every reboot.</li>
	<li><strong>It does not support Hyper-V Synthetic NICs.</strong> This means I’m stuck with legacy NICs for Vyatta. Legacy NICs means 100mb/s instead of 10GB/s and I can only assign maximum 4 NICs to the Vyatta instance. This is why I’ve only got 4 virtual switches configured for each Hyper-V host in my lab.</li>
	<li><strong>Vyatta is a cut down version of Linux, I could not install Linux Integration Service for Hyper-V.</strong> Otherwise, I might have already fixed the above mentioned 2 issues.</li>
	<li>Besides myself, two of my colleagues also tried to “Install” Vyatta 6.4 on the VHD (as oppose to run the Live CD mode). All 3 of us had the same issue: it runs OK, but the <strong>network latency caused by Vyatta is unacceptable</strong>. The ping latency from subnet A to subnet B in the same Hyper-V host gets to 2-4 seconds (2000-4000ms).</li>
</ul>
My colleague Matt McGowan spent sometime over a weekend and tried all versions of Vyatta after version 6 on a Hyper-V 2012 server, according to him, <strong>none of them could even boot up without disconnect all the legacy NICs first</strong>. This has become the last straw for me to give up on Vyatta. I had to find a better solution for my Hyper-V environment.

At that time, I was seriously thinking about buying a layer 3 managed switch (<a href="http://h30094.www3.hp.com/product.asp?sku=10250372">HP 1910-16G</a>), which costs $400 AUD in my local computer shop.  In the end, I’m glad I didn’t. After spoken to my good friend Zheng Han who is a RHCE and VCP, he advised me to take a look at CentOS.

So long story short, I’m hopeless when comes to Linux / Unix. I haven’t really done much with it ever since I graduated from uni. After a week or so playing with the latest version (CentOS 6.3) and learning how to use “vi”, with Zheng’s help, I got it working.

You’ve probably already seen the network diagram for my lab from Part 1. Here’s a logical diagram for the 3 Hyper-V hosts and the CentOS router in each host:

<a href="http://blog.tyang.org/wp-content/uploads/2012/10/Hyper-V-Logical-View.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="Hyper-V Logical View" src="http://blog.tyang.org/wp-content/uploads/2012/10/Hyper-V-Logical-View_thumb.png" alt="Hyper-V Logical View" width="580" height="424" border="0" /></a>

The Visio diagram of the above view can be downloaded <a href="http://blog.tyang.org/wp-content/uploads/2012/10/Hyper-V-Logical-View.zip">here</a>.

Now, I’ll use <strong>HyperVRT01</strong> (the router on HyperV01) as an example and go through the steps of setting it up.

<strong>The following software is required:</strong>
<ol>
	<li><strong>CentOS 6.3</strong> (<a href="http://isoredirect.centos.org/centos/6/isos/x86_64/">CentOS-6.3-x86_64-bin-DVD1.iso</a>) –can be downloaded from a mirror site near you.</li>
	<li> <strong>Linux Integration Service For Hyper-V 3.4</strong> (<a href="http://www.microsoft.com/en-us/download/details.aspx?id=34603">LinuxICv34.iso</a>) – download from Microsoft.</li>
</ol>
<strong>Other Network information:</strong>

I have 2 domain controllers in my lab domain:

DC01: 192.168.4.10

DC02: 192.168.2.10

DC01 is also configured as a DHCP server serving multiple scopes in my lab. You’ll see the IP address of these 2 machines a lot in below steps.

<span style="color: #ff0000;">*Note:</span> if you are going to use CentOS and you are like me, a Linux noob, before you start, please make sure you get familiar with “vi” editor because it is heavily used.

Now, let’s start…

<strong>1. Create a new virtual machine in Hyper-V with the following settings:</strong>
<ul>
	<li>CPU: 1 virtual processor</li>
	<li>Memory: 512MB static</li>
	<li>Hard disk: 10GB (after install, I checked and only used 3GB)</li>
	<li>Assign 4 network adapters (note, <strong><span style="color: #ff0000;">DO NOT</span></strong> use legacy network adapters):</li>
	<li>Assign the 4 network adapters to virtual switches <strong>IN ORDER</strong>:
<ul>
	<li>#1: 192.168.1.0</li>
	<li>#2: 192.168.7.0</li>
	<li>#3: 192.168.8.0</li>
	<li>#4: 192.168.9.0</li>
</ul>
</li>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2012/10/image10.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/10/image_thumb10.png" alt="image" width="274" height="181" border="0" /></a>

<strong>2. Mount the <em>CentOS-6.3-x86_64-bin-DVD1.iso</em> to the VM</strong>

<strong>3. Power on the VM to start installing CentOS</strong>
<ul>
	<li>Choose “Install system with basic video driver”</li>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2012/10/image11.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/10/image_thumb11.png" alt="image" width="525" height="396" border="0" /></a>

<span style="color: #ff0000;">*Note:</span> if you choose the first option to use the GUI based install wizard, you’ll need to assign minimum 1GB of memory to the VM. GUI based install won’t run on 512MB RAM.
<ul>
	<li>the rest of the install process is pretty much fool proof. I won’t waste my time going through the entire CentOS 6 install here.</li>
</ul>
Assume now CentOS is installed.

<strong>4. Install Linux Integration Service for Hyper-V:</strong>
<ol>
	<li>Mount <strong><em>LinuxICv34.ISO</em></strong> to the guest OS (HyperVRT01)</li>
	<li>Use the following command to install:</li>
</ol>
<table width="289" border="1" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td valign="top" width="287"><em>mount /dev/cdrom /media
cd /media/RHEL63
./install.sh
reboot</em></td>
</tr>
</tbody>
</table>
<strong>5. Disable Firewall</strong>
<table width="400" border="1" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td valign="top" width="400"><em>service iptables stop
chkconfig iptables off</em></td>
</tr>
</tbody>
</table>
<strong>6. Configure DNS</strong>
<table width="495" border="1" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td valign="top" width="493"><em>echo "nameserver 192.168.4.10" &gt;/etc/resolv.conf
echo "nameserver 192.168.2.10" &gt;&gt;/etc/resolv.conf</em></td>
</tr>
</tbody>
</table>
<strong>7. Network settings</strong>

<em>vi /etc/sysconfig/network</em> <strong>then insert</strong>
<table width="400" border="1" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td valign="top" width="400"><em>HOSTNAME="hypervrt01.corp.tyang.org"
NETWORKING=yes
NETWORKING_IPV6=no
GATEWAYDEV=eth0
GATEWAY=192.168.1.1</em></td>
</tr>
</tbody>
</table>
<a href="http://blog.tyang.org/wp-content/uploads/2012/10/image12.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/10/image_thumb12.png" alt="image" width="427" height="138" border="0" /></a>

<strong>8. Set IP Address:</strong>
<ul>
	<li><strong>Start up all NICs:</strong></li>
</ul>
<table width="400" border="1" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td valign="top" width="400"><em>ifconfig eth0 up
ifconfig eth1 up
ifconfig eth2 up
ifconfig eth3 up</em></td>
</tr>
</tbody>
</table>
<ul>
	<li><strong>eth0</strong></li>
</ul>
<em>vi /etc/sysconfig/network-scripts/ifcfg-eth0</em> <strong>then insert</strong>
<table width="400" border="1" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td valign="top" width="400"><em>DEVICE=eth0
IPADDR=192.168.1.252
NETMASK=255.255.255.0
GATEWAY=192.168.1.1
BROADCAST=192.168.1.255
DNS1=192.168.4.10
DNS2=192.168.2.10
ONBOOT=yes
NAME=External
TYPE="Ethernet"
IPV6INIT=no</em></td>
</tr>
</tbody>
</table>
<a href="http://blog.tyang.org/wp-content/uploads/2012/10/image13.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/10/image_thumb13.png" alt="image" width="398" height="380" border="0" /></a>

<span style="color: #ff0000;">*Hint:</span> Configure the first NIC eth0, then you can use Putty to connect via SSH. once in Putty, you can copy &amp; paste commands.
<ul>
	<li><strong>eth1</strong></li>
</ul>
<em>vi /etc/sysconfig/network-scripts/ifcfg-eth1</em> <strong>then insert</strong>
<table width="400" border="1" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td valign="top" width="400"><em>DEVICE=eth1
IPADDR=192.168.7.254
NETMASK=255.255.255.0
BROADCAST=192.168.7.255
GATEWAY=192.168.1.252
DNS1=192.168.4.10
DNS2=192.168.2.10
ONBOOT=yes
NAME=VLAN7
TYPE="Ethernet"
IPV6INIT=no</em></td>
</tr>
</tbody>
</table>
<ul>
	<li><strong>eth2</strong></li>
</ul>
<em>vi /etc/sysconfig/network-scripts/ifcfg-eth2</em> <strong>then insert</strong>
<table width="400" border="1" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td valign="top" width="400">DEVICE=eth2
IPADDR=192.168.8.254
NETMASK=255.255.255.0
BROADCAST=192.168.8.255
GATEWAY=192.168.1.252
DNS1=192.168.4.10
DNS2=192.168.2.10
ONBOOT=yes
NAME=VLAN8
TYPE="Ethernet"
IPV6INIT=no</td>
</tr>
</tbody>
</table>
<ul>
	<li><strong>eth3</strong></li>
</ul>
<em>vi /etc/sysconfig/network-scripts/ifcfg-eth3</em> <strong>then insert</strong>
<table width="400" border="1" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td valign="top" width="400"><em>DEVICE=eth3
IPADDR=192.168.9.254
NETMASK=255.255.255.0
BROADCAST=192.168.9.255
GATEWAY=192.168.1.252
DNS1=192.168.4.10
DNS2=192.168.2.10
ONBOOT=yes
NAME=VLAN9
TYPE="Ethernet"
IPV6INIT=no</em></td>
</tr>
</tbody>
</table>
<ul>
	<li><strong>Restart network service</strong></li>
</ul>
<table width="400" border="1" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td valign="top" width="400"><em>service network restart</em></td>
</tr>
</tbody>
</table>
Make sure all NICs start up OK:

<a href="http://blog.tyang.org/wp-content/uploads/2012/10/image14.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/10/image_thumb14.png" alt="image" width="580" height="194" border="0" /></a>

<strong>9. OS Update</strong>
<table width="400" border="1" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td valign="top" width="400"><em>yum update</em></td>
</tr>
</tbody>
</table>
<strong>10. Enable IP forwarding (Routing)</strong>
<ul>
	<li>Check if routing is enabled:</li>
</ul>
<table width="400" border="1" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td valign="top" width="400"><em>cat /proc/sys/net/ipv4/ip_forward</em></td>
</tr>
</tbody>
</table>
0 = disabled

1 = enabled
<ul>
	<li>To enable routing:</li>
</ul>
<em>vi /etc/sysctl.conf </em><strong>Then Edit:</strong>
<table width="400" border="1" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td valign="top" width="400"><em>net.ipv4.ip_forward = 1</em></td>
</tr>
</tbody>
</table>
<a href="http://blog.tyang.org/wp-content/uploads/2012/10/SNAGHTMLf993100.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLf993100" src="http://blog.tyang.org/wp-content/uploads/2012/10/SNAGHTMLf993100_thumb.png" alt="SNAGHTMLf993100" width="580" height="304" border="0" /></a>

<strong>11. Configure Route:</strong>

<em>vi /etc/sysconfig/network-scripts/route-eth0</em> <strong>and insert:</strong>
<table width="400" border="1" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td valign="top" width="400"><em>192.168.2.0/24 via 192.168.1.254 dev eth0
192.168.3.0/24 via 192.168.1.254 dev eth0
192.168.4.0/24 via 192.168.1.253 dev eth0
192.168.5.0/24 via 192.168.1.253 dev eth0
192.168.6.0/24 via 192.168.1.254 dev eth0</em></td>
</tr>
</tbody>
</table>
<a href="http://blog.tyang.org/wp-content/uploads/2012/10/image15.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/10/image_thumb15.png" alt="image" width="504" height="133" border="0" /></a>

<span style="color: #ff0000;">*Note:</span> above list represent all subnets in the other 2 Hyper-V servers in my lab.

<strong>12. Restart Network Service again</strong>
<table width="400" border="1" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td valign="top" width="400"><em>service network restart</em></td>
</tr>
</tbody>
</table>
<strong>13. Configure DHCP Relay</strong>
<ul>
	<li><strong>Install DHCP</strong></li>
</ul>
<table width="400" border="1" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td valign="top" width="400"><em>yum install dhcp</em></td>
</tr>
</tbody>
</table>
<ul>
	<li><strong>Configure DHCP Relay service (dhcrelay)</strong></li>
</ul>
<em>vi /etc/sysconfig/dhcrelay </em><strong>and Modify:</strong>
<table width="400" border="1" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td valign="top" width="400"><em>INTERFACES="eth0 eth1 eth2 eth3"
DHCPSERVERS="192.168.4.10" </em></td>
</tr>
</tbody>
</table>
<a href="http://blog.tyang.org/wp-content/uploads/2012/10/SNAGHTMLf9fb07b.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLf9fb07b" src="http://blog.tyang.org/wp-content/uploads/2012/10/SNAGHTMLf9fb07b_thumb.png" alt="SNAGHTMLf9fb07b" width="512" height="300" border="0" /></a>
<ul>
	<li><strong>Start DHCP Relay service (dhcrelay)</strong></li>
</ul>
<table width="400" border="1" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td valign="top" width="400">chkconfig dhcrelay on
service dhcrelay start</td>
</tr>
</tbody>
</table>
<strong>14. Configure SNMP (Optional)</strong>
<ul>
	<li><strong>Install SNMP:</strong></li>
</ul>
<table width="400" border="1" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td valign="top" width="400"><em>yum install net-snmp-utils
yum install net-snmp</em></td>
</tr>
</tbody>
</table>
<ul>
	<li><strong>Backup SNMP Config File</strong></li>
</ul>
<em>mv /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf.org</em>
<ul>
	<li><strong>Create new config file :</strong></li>
</ul>
<em>vi /etc/snmp/snmpd.conf</em> <strong>and insert:</strong>
<table width="400" border="1" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td valign="top" width="400">rocommunity  public
syslocation  "TYANG.ORG Head Office"
syscontact  <a href="mailto:your@email.com">your@email.com</a></td>
</tr>
</tbody>
</table>
<ul>
	<li><strong>Start SNMP service</strong></li>
</ul>
<table width="400" border="1" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td valign="top" width="400"><em>service snmpd start
chkconfig snmpd on</em></td>
</tr>
</tbody>
</table>
<strong>15. Install Webmin (Optional)</strong>
<ul>
	<li><strong>Install the GPG key</strong></li>
</ul>
<table width="569" border="1" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td valign="top" width="567"><strong><em>rpm --import </em></strong><a href="http://www.webmin.com/jcameron-key.asc"><strong><em>http://www.webmin.com/jcameron-key.asc</em></strong></a></td>
</tr>
</tbody>
</table>
<ul>
	<li><strong>Add webmin repository</strong>
<em>vi /etc/yum.repos.d/webmin.repo</em> <strong>and add:</strong></li>
</ul>
<table width="400" border="1" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td valign="top" width="400"><em>[Webmin]
name=Webmin Distribution Neutral
#baseurl=http://download.webmin.com/download/yum
mirrorlist=http://download.webmin.com/download/yum/mirrorlist
enabled=1</em></td>
</tr>
</tbody>
</table>
<a href="http://blog.tyang.org/wp-content/uploads/2012/10/image16.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/10/image_thumb16.png" alt="image" width="580" height="126" border="0" /></a>
<ul>
	<li><strong>update the repos:</strong></li>
</ul>
<table width="400" border="1" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td valign="top" width="400"><em>yum update</em></td>
</tr>
</tbody>
</table>
<ul>
	<li><strong>Install webmin</strong></li>
</ul>
<table width="400" border="1" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td valign="top" width="400"><em>yum install webmin</em></td>
</tr>
</tbody>
</table>
<ul>
	<li><strong>access webmin page:</strong></li>
</ul>
http://&lt;ipaddress&gt;:10000

<strong><span style="color: #ff0000;">This is it. the router is now setup!</span></strong>

After setup, check system status via webmin:

<a href="http://blog.tyang.org/wp-content/uploads/2012/10/image17.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/10/image_thumb17.png" alt="image" width="580" height="342" border="0" /></a>

As you can see, after everything is configured, it only uses 136MB of memory and 3GB of disk space.

<strong>Routing and Gateways:</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2012/10/SNAGHTMLfafef30.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLfafef30" src="http://blog.tyang.org/wp-content/uploads/2012/10/SNAGHTMLfafef30_thumb.png" alt="SNAGHTMLfafef30" width="580" height="381" border="0" /></a>

<strong>NIC configurations:</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2012/10/image18.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2012/10/image_thumb18.png" alt="image" width="574" height="282" border="0" /></a>

Additional, I made sure a windows client OS could obtain an IP address from the DHCP server (which is located on another Hyper-V host). and I was able to ping / trace route other VMs in other Hyper-V servers (I have already demonstrated it in part 1).

This concludes this 2-part series. Before I go, I have to reiterate, there is nothing wrong with the Vyatta product, it’s just it does not integrate with Hyper-V too well. Unlike Vyatta, CentOS 6 is a fully supported guest OS in Hyper-V (With Linux Integration Service for Hyper-V 3.4) and CentOS 5 and 6 are also supported in SCOM 2012 SP1 beta! Having said that, Vyatta was running perfectly fine in my VMware workstation previously. If Vyatta adds support to Hyper-V in the future, I would definitely consider it again.

Lastly, please feel free to get in touch with me if you believe there are anything inaccurate in this series or you need more information in regards to the CentOS router setup.