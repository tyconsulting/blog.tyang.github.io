---
id: 704
title: Adding New Network Devices to SCOM Using PowerShell
date: 2011-10-01T23:16:18+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=704
permalink: /2011/10/01/adding-new-network-devices-to-scom-using-powershell/
categories:
  - PowerShell
  - SCOM
tags:
  - SCOM; Network Devices
---
Last week, I needed to write a PowerShell script to add iSCSI SAN devices into SCOM 2007 as network devices. I thought the script would be very straight forward, until I realised there is a limitation using SCOM PowerShell snap-in.

To explain it, let me firstly go through how to do this in SCOM console and then I’ll compare this process with using SCOM PowerShell cmdlets.

So, to add a new network device using SCOM console, it’s pretty easy:

1. Launch Discovery Wizard and choose “Network Devices”

2. Enter the network device information

<a href="http://blog.tyang.org/wp-content/uploads/2011/10/image.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/10/image_thumb.png" alt="image" width="580" height="551" border="0" /></a>

3. Select the device from discovery result and choose a <strong>proxy agent</strong> for this network device

<a href="http://blog.tyang.org/wp-content/uploads/2011/10/image1.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/10/image_thumb1.png" alt="image" width="489" height="465" border="0" /></a>

Please note the default proxy agent is set to the management server from previous step. it can be changed by click on Change button

<a href="http://blog.tyang.org/wp-content/uploads/2011/10/image2.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/10/image_thumb2.png" alt="image" width="449" height="449" border="0" /></a>

It lists all possible proxy agents. There are 3 management servers in my test environment, <strong>SCOM01</strong> is my RMS, <strong>SCOM02</strong> is a management server and <strong>SCOMGW01</strong> is a gateway server located in another untrusted forest. I have highlighted these 3 servers, notice the icon for management servers is different than other normal agents.

4. continue on and complete the rest steps of the wizard.

<strong>Now, let’s look at how to do this in PowerShell:</strong>

1. Get Network Device monitoring class

[sourcecode language="powershell"]$networkdeviceclass = get-monitoringclass -name 'System.NetworkDevice'[/sourcecode]

2. Create a new DeviceDiscoveryConfiguration object

[sourcecode language="powershell"]$dc = new-devicediscoveryconfiguration -monitoringclass $networkdeviceclass –fromipaddress “192.168.1.253” -toipaddress “192.168.1.253”[/sourcecode]

3. Define SNMP community string

[sourcecode language="powershell"]$encoding = new-object System.Text.UnicodeEncoding

$encodedCommunityString = $encoding.GetBytes(&quot;tyang&quot;)

$dc.ReadOnlyCommunity = [System.Convert]::ToBase64String($encodedCommunityString)[/sourcecode]

4. Default SNMP version is 2, if the network device requires version 1, set the device discovery configuration to use SNMP version 1:

[sourcecode language="powershell"]$dc.snmpversion = 1[/sourcecode]

5. Define the management server to be used in the discovery

[sourcecode language="powershell"]$NWDeviceMS = Get-ManagementServer | Where-object {$_.displayname –ieq “SCOM02.corp.tyang.org”}[/sourcecode]

6. Start discovery using the management server defined in step 5

[sourcecode language="powershell"]$DiscoveryResult = Start-Discovery -managementserver $NWDeviceMS -DeviceDiscoveryConfiguration $dc[/sourcecode]

7. If discovery is successful, add the device into SCOM.

[sourcecode language="powershell"]if ($discoveryresult.monitoringtaskresults[0].status -ieq &quot;succeeded&quot;)
{
#code to add the device into SCOM
}[/sourcecode]

Well, here’s the issue:

<strong><span style="color: #ff0000;">if you use the Add-RemotelyManagedDevice cmdlet, you have to use a SCOM AGENT as the proxy agent. You CANNOT choose a management server as the proxy agent for the network devices you are about to add.</span></strong>

<a href="http://blog.tyang.org/wp-content/uploads/2011/10/image3.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/10/image_thumb3.png" alt="image" width="580" height="268" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2011/10/image4.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/10/image_thumb4.png" alt="image" width="580" height="160" border="0" /></a>

The management server is not an agent, get-agent cmdlet does not return management servers:

<a href="http://blog.tyang.org/wp-content/uploads/2011/10/image5.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/10/image_thumb5.png" alt="image" width="580" height="122" border="0" /></a>

And if I use the management server in Add-RemotelyManagedDevice cmdlet, it will fail:

<a href="http://blog.tyang.org/wp-content/uploads/2011/10/image6.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/10/image_thumb6.png" alt="image" width="580" height="208" border="0" /></a>

Basically, object type mismatch...

So, if we want to use a management server as the proxy agent for network devices, we <strong>CANNOT</strong> use Add-RemotelyManagedDevice cmdlet. It is a limitation in SCOM PowerShell snap-in. Instead, There is a method in the management server object called “<span style="color: #ff0000;"><strong>InsertRemotelymanagedDevices</strong></span>”:

<a href="http://blog.tyang.org/wp-content/uploads/2011/10/image7.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/10/image_thumb7.png" alt="image" width="450" height="565" border="0" /></a>

we have to use this method to add network devices.  Therefore, the script for step 7 should be:

[sourcecode language="powershell"]if ($discoveryresult.monitoringtaskresults[0].status -ieq &quot;succeeded&quot;)
{
$NWDeviceMS.InsertRemotelyManagedDevices($DiscoveryResult.custommonitoringobjects)
}[/sourcecode]

8. Check result:

<a href="http://blog.tyang.org/wp-content/uploads/2011/10/image8.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/10/image_thumb8.png" alt="image" width="580" height="266" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2011/10/image9.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/10/image_thumb9.png" alt="image" width="579" height="303" border="0" /></a>

As you can see, the device has been successfully added.