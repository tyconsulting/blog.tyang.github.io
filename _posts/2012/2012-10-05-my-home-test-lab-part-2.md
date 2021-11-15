---
id: 1506
title: 'My Home Test Lab &#8211; Part 2'
date: 2012-10-05T22:41:35+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=1506
permalink: /2012/10/05/my-home-test-lab-part-2/
categories:
  - Hyper-V
  - Others
tags:
  - CentOS
  - Hyper-V
  - Vyatta
---
This is the part 2 of my 2-part series on how my home test lab is configured.

Part 1 can be found <a href="https://blog.tyang.org/2012/10/04/my-home-test-lab-part-1/">here</a>.

In this second part, I’m going to talk about my previous experience with <a href="http://www.vyatta.org/">vyatta virtual router appliance</a> and how I replaced vyatta with <a href="https://www.centos.org/">CentOS</a>.

**<span style="color: #ff0000;">Disclaimer:</span>**

The content of this article is purely based on my personal experience and opinions. I have absolutely no intentions to criticise vyatta. To be honest, I still think it’s a great product, however, it just does not suit my needs in my lab environment.

**About Vyatta:**

Stefan Stranger has written a great article on <a href="http://blogs.technet.com/b/stefan_stranger/archive/2008/08/25/vyatta-virtual-router-on-hyper-v.aspx">Vyatta Virtual Router on Hyper-V</a> back in 2008. The version Stefan used in his article was 4.0 and when I am writing this article, the latest version is 6.4. It can be downloaded here: <a href="http://www.vyatta.org/downloads">http://www.vyatta.org/downloads</a>

Vyatta is extremely light-weight. In my previous environment, I only needed to assign 256MB of RAM to each Vyatta instance. It is also very easy to setup. for me to configure an instance from scratch, would take me no more than 10 minutes.

Below is a list the setup commands I had to run to configure a Vyatta from scratch (based on my previous lab configuration):

```bash
configure
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
save
```
So why am I moving away from Vyatta? the short answer is: Vyatta does not officially support Hyper-V:

<a href="https://blog.tyang.org/wp-content/uploads/2012/10/image9.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2012/10/image_thumb9.png" alt="image" width="574" height="277" border="0" /></a>

Read between the lines, Hyper-V is not supported.

What does it mean in my lab Hyper-V 2008 R2 hosts in the past (Based on version 6.1 that I have implemented)?

* **After I reboot the Vyatta VM, all configurations were lost.** It needed to be reconfigured again from scratch (that’s why I became so good at its commands). To work around this issue, I created a VM snapshot after it’s fully configured and I had to revert it back to the snapshot after every reboot.
* **It does not support Hyper-V Synthetic NICs.** This means I’m stuck with legacy NICs for Vyatta. Legacy NICs means 100mb/s instead of 10GB/s and I can only assign maximum 4 NICs to the Vyatta instance. This is why I’ve only got 4 virtual switches configured for each Hyper-V host in my lab.
* **Vyatta is a cut down version of Linux, I could not install Linux Integration Service for Hyper-V.** Otherwise, I might have already fixed the above mentioned 2 issues.
* Besides myself, two of my colleagues also tried to "Install" Vyatta 6.4 on the VHD (as oppose to run the Live CD mode). All 3 of us had the same issue: it runs OK, but the **network latency caused by Vyatta is unacceptable**. The ping latency from subnet A to subnet B in the same Hyper-V host gets to 2-4 seconds (2000-4000ms).

My colleague Matt McGowan spent sometime over a weekend and tried all versions of Vyatta after version 6 on a Hyper-V 2012 server, according to him, **none of them could even boot up without disconnect all the legacy NICs first**. This has become the last straw for me to give up on Vyatta. I had to find a better solution for my Hyper-V environment.

At that time, I was seriously thinking about buying a layer 3 managed switch (<a href="http://h30094.www3.hp.com/product.asp?sku=10250372">HP 1910-16G</a>), which costs $400 AUD in my local computer shop.  In the end, I’m glad I didn’t. After spoken to my good friend Zheng Han who is a RHCE and VCP, he advised me to take a look at CentOS.

So long story short, I’m hopeless when comes to Linux / Unix. I haven’t really done much with it ever since I graduated from uni. After a week or so playing with the latest version (CentOS 6.3) and learning how to use "vi", with Zheng’s help, I got it working.

You’ve probably already seen the network diagram for my lab from Part 1. Here’s a logical diagram for the 3 Hyper-V hosts and the CentOS router in each host:

<a href="https://blog.tyang.org/wp-content/uploads/2012/10/Hyper-V-Logical-View.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="Hyper-V Logical View" src="https://blog.tyang.org/wp-content/uploads/2012/10/Hyper-V-Logical-View_thumb.png" alt="Hyper-V Logical View" width="580" height="424" border="0" /></a>

The Visio diagram of the above view can be downloaded <a href="https://blog.tyang.org/wp-content/uploads/2012/10/Hyper-V-Logical-View.zip">here</a>.

Now, I’ll use **HyperVRT01** (the router on HyperV01) as an example and go through the steps of setting it up.

**The following software is required:**

* **CentOS 6.3** (<a href="http://isoredirect.centos.org/centos/6/isos/x86_64/">CentOS-6.3-x86_64-bin-DVD1.iso</a>) –can be downloaded from a mirror site near you.
* **Linux Integration Service For Hyper-V 3.4** (<a href="http://www.microsoft.com/en-us/download/details.aspx?id=34603">LinuxICv34.iso</a>) – download from Microsoft.

**Other Network information:**

I have 2 domain controllers in my lab domain:

* DC01: 192.168.4.10
* DC02: 192.168.2.10

DC01 is also configured as a DHCP server serving multiple scopes in my lab. You’ll see the IP address of these 2 machines a lot in below steps.

<span style="color: #ff0000;">*Note:</span> if you are going to use CentOS and you are like me, a Linux noob, before you start, please make sure you get familiar with "vi" editor because it is heavily used.

Now, let’s start…

**1. Create a new virtual machine in Hyper-V with the following settings:**

* CPU: 1 virtual processor
* Memory: 512MB static
* Hard disk: 10GB (after install, I checked and only used 3GB)
* Assign 4 network adapters (note, **<span style="color: #ff0000;">DO NOT</span>** use legacy network adapters):
* Assign the 4 network adapters to virtual switches **IN ORDER**:

* #1: 192.168.1.0
* #2: 192.168.7.0
* #3: 192.168.8.0
* #4: 192.168.9.0


<a href="https://blog.tyang.org/wp-content/uploads/2012/10/image10.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2012/10/image_thumb10.png" alt="image" width="274" height="181" border="0" /></a>

**2. Mount the CentOS-6.3-x86_64-bin-DVD1.iso to the VM**

**3. Power on the VM to start installing CentOS**

* Choose "Install system with basic video driver"

<a href="https://blog.tyang.org/wp-content/uploads/2012/10/image11.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2012/10/image_thumb11.png" alt="image" width="525" height="396" border="0" /></a>

<span style="color: #ff0000;">*Note:</span> if you choose the first option to use the GUI based install wizard, you’ll need to assign minimum 1GB of memory to the VM. GUI based install won’t run on 512MB RAM.

* the rest of the install process is pretty much fool proof. I won’t waste my time going through the entire CentOS 6 install here.

Assume now CentOS is installed.

**4. Install Linux Integration Service for Hyper-V:**

* Mount **LinuxICv34.ISO** to the guest OS (HyperVRT01)
* Use the following command to install:


```bash
mount /dev/cdrom /media
cd /media/RHEL63
./install.sh
reboot
```

**5. Disable Firewall**

```bash
service iptables stop
chkconfig iptables off</td>
```

**6. Configure DNS**

```bash
echo "nameserver 192.168.4.10" &gt;/etc/resolv.conf
echo "nameserver 192.168.2.10" &gt;&gt;/etc/resolv.conf</td>
```

**7. Network settings**

```bash
vi /etc/sysconfig/network
```

**then insert**

```bash
HOSTNAME="hypervrt01.corp.tyang.org"
NETWORKING=yes
NETWORKING_IPV6=no
GATEWAYDEV=eth0
GATEWAY=192.168.1.1
```

<a href="https://blog.tyang.org/wp-content/uploads/2012/10/image12.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2012/10/image_thumb12.png" alt="image" width="427" height="138" border="0" /></a>

**8. Set IP Address:**

* **Start up all NICs:**

```bash
ifconfig eth0 up
ifconfig eth1 up
ifconfig eth2 up
ifconfig eth3 up
```

* **eth0**

```bash
vi /etc/sysconfig/network-scripts/ifcfg-eth0
```
**then insert**

```
DEVICE=eth0
IPADDR=192.168.1.252
NETMASK=255.255.255.0
GATEWAY=192.168.1.1
BROADCAST=192.168.1.255
DNS1=192.168.4.10
DNS2=192.168.2.10
ONBOOT=yes
NAME=External
TYPE="Ethernet"
IPV6INIT=no
```

<a href="https://blog.tyang.org/wp-content/uploads/2012/10/image13.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2012/10/image_thumb13.png" alt="image" width="398" height="380" border="0" /></a>

<span style="color: #ff0000;">*Hint:</span> Configure the first NIC eth0, then you can use Putty to connect via SSH. once in Putty, you can copy & paste commands.

* **eth1**

```bash
vi /etc/sysconfig/network-scripts/ifcfg-eth1 
```
**then insert**

```bash
DEVICE=eth1
IPADDR=192.168.7.254
NETMASK=255.255.255.0
BROADCAST=192.168.7.255
GATEWAY=192.168.1.252
DNS1=192.168.4.10
DNS2=192.168.2.10
ONBOOT=yes
NAME=VLAN7
TYPE="Ethernet"
IPV6INIT=no
```

* **eth2**

```bash
vi /etc/sysconfig/network-scripts/ifcfg-eth2
```
**then insert**

```bash
DEVICE=eth2
IPADDR=192.168.8.254
NETMASK=255.255.255.0
BROADCAST=192.168.8.255
GATEWAY=192.168.1.252
DNS1=192.168.4.10
DNS2=192.168.2.10
ONBOOT=yes
NAME=VLAN8
TYPE="Ethernet"
IPV6INIT=no
```

* **eth3**

```bash
vi /etc/sysconfig/network-scripts/ifcfg-eth3
```

**then insert**

```bash
DEVICE=eth3
IPADDR=192.168.9.254
NETMASK=255.255.255.0
BROADCAST=192.168.9.255
GATEWAY=192.168.1.252
DNS1=192.168.4.10
DNS2=192.168.2.10
ONBOOT=yes
NAME=VLAN9
TYPE="Ethernet"
IPV6INIT=no
```

* **Restart network service**

```bash
service network restart
```

Make sure all NICs start up OK:

<a href="https://blog.tyang.org/wp-content/uploads/2012/10/image14.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2012/10/image_thumb14.png" alt="image" width="580" height="194" border="0" /></a>

**9. OS Update**

```bash
yum update
```

**10. Enable IP forwarding (Routing)**

* Check if routing is enabled:

```bash
cat /proc/sys/net/ipv4/ip_forward
```

	* 0 = disabled
	* 1 = enabled

* To enable routing:

```bash
vi /etc/sysctl.conf
```
**Then Edit:**

```bash
net.ipv4.ip_forward = 1
```

<a href="https://blog.tyang.org/wp-content/uploads/2012/10/SNAGHTMLf993100.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLf993100" src="https://blog.tyang.org/wp-content/uploads/2012/10/SNAGHTMLf993100_thumb.png" alt="SNAGHTMLf993100" width="580" height="304" border="0" /></a>

**11. Configure Route:**

```bash
vi /etc/sysconfig/network-scripts/route-eth0
```

**and insert:**

```bash
192.168.2.0/24 via 192.168.1.254 dev eth0
192.168.3.0/24 via 192.168.1.254 dev eth0
192.168.4.0/24 via 192.168.1.253 dev eth0
192.168.5.0/24 via 192.168.1.253 dev eth0
192.168.6.0/24 via 192.168.1.254 dev eth0
```

<a href="https://blog.tyang.org/wp-content/uploads/2012/10/image15.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2012/10/image_thumb15.png" alt="image" width="504" height="133" border="0" /></a>

<span style="color: #ff0000;">*Note:</span> above list represent all subnets in the other 2 Hyper-V servers in my lab.

**12. Restart Network Service again**

```bash
service network restart
```

**13. Configure DHCP Relay**

* **Install DHCP**

```bash
yum install dhcp
```

* **Configure DHCP Relay service (dhcrelay)**

```bash
vi /etc/sysconfig/dhcrelay
```
**and Modify:**

```bash
INTERFACES="eth0 eth1 eth2 eth3"
DHCPSERVERS="192.168.4.10" 
```

<a href="https://blog.tyang.org/wp-content/uploads/2012/10/SNAGHTMLf9fb07b.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLf9fb07b" src="https://blog.tyang.org/wp-content/uploads/2012/10/SNAGHTMLf9fb07b_thumb.png" alt="SNAGHTMLf9fb07b" width="512" height="300" border="0" /></a>

* **Start DHCP Relay service (dhcrelay)**

```bash
chkconfig dhcrelay on
service dhcrelay start
```

**14. Configure SNMP (Optional)**

* **Install SNMP:**

```bash
yum install net-snmp-utils
yum install net-snmp
```

* **Backup SNMP Config File**

```bash
mv /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf.org
```

* **Create new config file :**

```bash
vi /etc/snmp/snmpd.conf
```

**and insert:**

```bash
rocommunity  public
syslocation  "TYANG.ORG Head Office"
syscontact  your@email.com
```

* **Start SNMP service**

```bash
service snmpd start
chkconfig snmpd on
```

**15. Install Webmin (Optional)**

* **Install the GPG key**

```bash
rpm --import http://www.webmin.com/jcameron-key.asc
```

* **Add webmin repository**

```bash
vi /etc/yum.repos.d/webmin.repo
```

**and add:**

```bash
[Webmin]
name=Webmin Distribution Neutral
#baseurl=http://download.webmin.com/download/yum
mirrorlist=http://download.webmin.com/download/yum/mirrorlist
enabled=1
```

<a href="https://blog.tyang.org/wp-content/uploads/2012/10/image16.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2012/10/image_thumb16.png" alt="image" width="580" height="126" border="0" /></a>

* **update the repos:**

```bash
yum update
```
* **Install webmin**

```bash
yum install webmin
```

* **access webmin page:**

http://ipaddress:10000

**<span style="color: #ff0000;">This is it. the router is now setup!</span>**

After setup, check system status via webmin:

<a href="https://blog.tyang.org/wp-content/uploads/2012/10/image17.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2012/10/image_thumb17.png" alt="image" width="580" height="342" border="0" /></a>

As you can see, after everything is configured, it only uses 136MB of memory and 3GB of disk space.

**Routing and Gateways:**

<a href="https://blog.tyang.org/wp-content/uploads/2012/10/SNAGHTMLfafef30.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLfafef30" src="https://blog.tyang.org/wp-content/uploads/2012/10/SNAGHTMLfafef30_thumb.png" alt="SNAGHTMLfafef30" width="580" height="381" border="0" /></a>

**NIC configurations:**

<a href="https://blog.tyang.org/wp-content/uploads/2012/10/image18.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2012/10/image_thumb18.png" alt="image" width="574" height="282" border="0" /></a>

Additional, I made sure a windows client OS could obtain an IP address from the DHCP server (which is located on another Hyper-V host). and I was able to ping / trace route other VMs in other Hyper-V servers (I have already demonstrated it in part 1).

This concludes this 2-part series. Before I go, I have to reiterate, there is nothing wrong with the Vyatta product, it’s just it does not integrate with Hyper-V too well. Unlike Vyatta, CentOS 6 is a fully supported guest OS in Hyper-V (With Linux Integration Service for Hyper-V 3.4) and CentOS 5 and 6 are also supported in SCOM 2012 SP1 beta! Having said that, Vyatta was running perfectly fine in my VMware workstation previously. If Vyatta adds support to Hyper-V in the future, I would definitely consider it again.

Lastly, please feel free to get in touch with me if you believe there are anything inaccurate in this series or you need more information in regards to the CentOS router setup.