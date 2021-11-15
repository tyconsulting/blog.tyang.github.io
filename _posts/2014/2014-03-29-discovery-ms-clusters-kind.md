---
id: 2436
title: Discovery for MS Clusters of Any Kind
date: 2014-03-29T23:32:42+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=2436
permalink: /2014/03/29/discovery-ms-clusters-kind/
categories:
  - SCOM
tags:
  - MP Authoring
  - SCOM
---
Often when developing an OpsMgr management pack for server class applications, we need to be cluster-aware. Sometimes workflows don’t need to run on a cluster, sometimes, the workflow should only be executed on a cluster. (i.e. I wrote a monitor that runs on a Windows 2008 R2 Hyper-V cluster once a day and check if all virtual machines are hosted by their preferred cluster nodes.)

There are many good articles out there explaining cluster-aware discoveries in OpsMgr management packs:

* <a href="http://blogs.technet.com/b/authormps/archive/2011/03/13/your-mp-discoveries-and-clustering.aspx">Your MP Discoveries and Clustering</a>
* <a href="https://social.technet.microsoft.com/wiki/contents/articles/1204.mp-best-practice-make-likely-server-roles-mscs-aware.aspx">MP Best Practice – Make likely server roles MSCS aware</a>

However, in many occasions, only using the "**IsVirtualNode**" property from the Windows Server class (Microsoft.Windows.Server.Computer) is not enough (or granular enough) to identify the specific clusters.

I’m explain what I mean using an example.

For example, I have a 2-node SQL cluster configured as below:

* Node 1 name: **blablablaSQL01A**
* Node 2 name: **blablablaSQL01B**
* Cluster Name: **blablablaSQL01C**
* DTC Cluster Resource Access Name: **blablablaSQL01D**
* SQL Server Cluster Resource Access Name: **blablablaSQL01E**

<a href="https://blog.tyang.org/wp-content/uploads/2014/03/image7.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2014/03/image_thumb7.png" width="580" height="254" border="0" /></a>

After installing the OpsMgr agent on both cluster nodes and enabled Agent-Proxy for them, totally 5 Windows Server objects will be discovered, one for each name mentioned above:

<a href="https://blog.tyang.org/wp-content/uploads/2014/03/image8.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2014/03/image_thumb8.png" width="580" height="174" border="0" /></a>

As shown above, other than the 2 cluster nodes, other 3 instances have "IsVirtualNode" property set to "True".

When I looked at the "Computer" state view in the Microsoft SQL management pack, all 5 "Windows Server" are listed as the computer which has SQL installed:

<a href="https://blog.tyang.org/wp-content/uploads/2014/03/image9.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2014/03/image_thumb9.png" width="580" height="280" border="0" /></a>

If I create a discovery for SQL Clusters based on any computers have SQL DB Engine installed and is a virtual node, I would have discovered 3 instances (SQL01C, SQL01D and SQL 01E) for the same cluster.

If I only want to discover the cluster itself (blablablaSQL01C), I believe the discovery needs to perform the following checks:

**01. The Windows Server Is Virtual Node**

After a bit of digging, I found the "Windows Clustering Discovery" from Windows Cluster Library MP sets "IsVirtualNode" to True:

<a href="https://blog.tyang.org/wp-content/uploads/2014/03/image10.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2014/03/image_thumb10.png" width="397" height="304" border="0" /></a>

**02. The existence of Cluster Service**

I’m not sure if there are any management packs other than Windows Clustering Library out there that set IsVirtualNode to True. So , to be safe, I would also configure my discovery to look for the Cluster service.

**03. The cluster is actually hosting my application**

This is done via a WMI query to the MSCluster_Resource class in root\MSCluster name space.

In order to identify the cluster is hosting my application, I need to find if there are any cluster resources that has a specific resource type and also has a name that matches my search string.

i.e. I have access to 3 kinds of clusters in my work environment. I’ll list the WMI query for each cluster type:

**SQL Cluster:** "Select * from MSCluster_Resource Where Type = ‘**SQL Server**’ And Name LIKE ‘**SQL Server’**"

**Hyper-V Cluster:** "Select * from MSCluster_Resource Where Type = ‘**Virtual Machine**’ And Name LIKE ‘**Virtual Machine %**’"

>**<span style="color: #ff0000;">Note:</span>** This is because each VM in Hyper-V cluster have a resource name of "Virtual Machine <VM Name>".

**OpsMgr 2007 RMS Cluster:** "Select * from MSCluster_Resource Where Type = ‘**Generic Service**’ And Name LIKE ‘**System Center Data Access**"

As you can see, I believe in order to accurately identify my application, both cluster resource type and name need to match. Only using resource type in WMI query is not enough because the resource type could be "Generic Service".

**04. The computer name matches the cluster name**

Because I am only interested in the actual cluster, not client access names for cluster resource groups, the computer name of the Windows Server instance needs to match the cluster name. I can read the cluster name in registry "**HKLM\SYSTEM\CurrentControlSet\Services\ClusSvc\Parameters\ClusterName**"

In my sample MP, I created a class based on Microsoft.Windows.ComputerRole for my cluster and created a Timed Script Discovery based on the 4 criteria mentioned above.

>**<span style="color: #ff0000;">Note:</span>** I know that using a script discovery targeting a wide range (all windows servers) is not ideal. I couldn’t manage to write a custom discovery module that meets my requirements. for example, the computer name could be in capital but the cluster name could be in lower case, System.ExpressionFilter (which is used by filtered registry discovery module) does not support case insensitive regular expression match (<a href="http://support.microsoft.com/kb/2702651"><em>More Info</em></a><em>). Therefore in my script, I have many IF statements nested. for example, if the windows server is not a virtual node, at the first if statement, it would not meet the if criteria and bypass the rest of the script, jump to the end of the script and submit an empty set of discovery data. I’ve done it this way to ensure the script does not continue running if one criteria is not met.</em>

Again, using SQL clusters as an example, I created a class called "SQL Server Cluster", and only the actual clusters (name ends with letter "C") are discovered:

<a href="https://blog.tyang.org/wp-content/uploads/2014/03/image11.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2014/03/image_thumb11.png" width="580" height="182" border="0" /></a>

In order to re-use the code, I have create a snippet template in VSAE. This snippet template includes the class definition, discovery workflow and associated language pack (ENU) display strings.

Here’s the code for the snippet template:

```xml
<ManagementPackFragment SchemaVersion="1.0">
 <TypeDefinitions>
 <EntityTypes>
 <ClassTypes>
 <ClassType ID="#text('MP Id')#.#text('Cluster Type')#.Cluster.ComputerRole" Base="#alias('Microsoft.Windows.Library')#!Microsoft.Windows.ComputerRole" Accessibility="Public" Abstract="false" Hosted="true" Singleton="false">
 <Property ID="ClusterName" Key="false" Type="string" />
 </ClassType>
 </ClassTypes>
 </EntityTypes>
 </TypeDefinitions>
 <Monitoring>
 <Discoveries>
 <Discovery ID="#text('MP Id')#.#text('Cluster Type')#.Cluster.ComputerRole.Discovery" Target="#alias('Microsoft.Windows.Library')#!Microsoft.Windows.Server.Computer" Enabled="true" ConfirmDelivery="false" Remotable="true" Priority="Normal">
 <Category>Discovery</Category>
 <DiscoveryTypes>
 <DiscoveryClass TypeID="#text('MP Id')#.#text('Cluster Type')#.Cluster.ComputerRole">
 <Property TypeID="#text('MP Id')#.#text('Cluster Type')#.Cluster.ComputerRole" PropertyID="ClusterName" />
 </DiscoveryClass>
 </DiscoveryTypes>
 <DataSource ID="DS" TypeID="#alias('Microsoft.Windows.Library')#!Microsoft.Windows.TimedScript.DiscoveryProvider">
 <IntervalSeconds>3600</IntervalSeconds>
 <SyncTime />
 <ScriptName>ClusterDiscovery.vbs</ScriptName>
 <Arguments>$MPElement$ $Target/Id$ $Target/Property[Type="#alias('Microsoft.Windows.Library')#!Microsoft.Windows.Computer"]/PrincipalName$ "#text('Cluster Resource Type')#" "#text('Cluster Resource Name Search String')#" "$Target/Property[Type="#alias('Microsoft.Windows.Library')#!Microsoft.Windows.Server.Computer"]/IsVirtualNode$"</Arguments>
 <ScriptBody>
 <![CDATA[
'========================================================
' AUTHOR: Tao Yang
' Script Name: ClusterDiscovery.vbs
' DATE: 20/03/2014
' Version: 1.0
' COMMENT: Script to discover failover clusters
'========================================================
On Error Resume Next
SourceID = WScript.Arguments(0)
ManagedEntityID = WScript.Arguments(1)
strComputer = WScript.Arguments(2)
strCLResType = WScript.Arguments(3)
strCLResName = WScript.Arguments(4)
'IsVirtualNode property from Windows.Server.Computer class is either true or empty. never false
IF NOT IsNull(WScript.Arguments(5)) THEN
bIsVirtualNode = WScript.Arguments(5)
END IF

'Declare variables
const HKEY_LOCAL_MACHINE = &H80000002

Set oAPI = CreateObject("MOM.ScriptAPI")
Set oDiscoveryData = oAPI.CreateDiscoveryData(0,SourceID,ManagedEntityID)

'Only continue if IsVirtualNode = "True"
IF UCase(bIsVirtualNode) = "TRUE" Then
 'Check if Failover Cluster service exists
 strKeyPath = "SYSTEM\CurrentControlSet\Services\ClusSvc"
 'connect to the registry provider
 Set oReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\default:StdRegProv")
 If oReg.EnumKey(HKEY_LOCAL_MACHINE, strKeyPath, arrSubKeys) = 0 Then
 'Cluster Service exists, continue, check if specified cluster resource exists
 bCLRes = False
 CLResWMIQuery = "Select * from MSCluster_Resource Where Type = '" & strCLResType &"' AND Name LIKE '" & strCLResName & "'"
 Set objWMICluster = GetObject("winmgmts:\\" & strComputer & "\root\MSCluster")
 Set ColCLRes = objWMICluster.ExecQuery (CLResWMIQuery)
 For Each objCLRes in ColCLRes
 bCLRes = TRUE
 Next

'NetBIOS Computer Name
 ComputerName = Split(strComputer, ".", -1)(0)
 'Read Cluster name from registry
 strCLKeyPath = "SYSTEM\CurrentControlSet\Services\ClusSvc\Parameters"
 strCLNameValue = "ClusterName"
 oReg.GetStringValue HKEY_LOCAL_MACHINE,strCLKeyPath, strCLNameValue,strClusterName

'Proceed if NetBIOS Computer Name equals to cluster name
 If UCase(ComputerName) = UCase(strClusterName) Then
 IF bCLRes = TRUE THEN
 Set oInstance = oDiscoveryData.CreateClassInstance("$MPElement[Name='#text('MP Id')#.#text('Cluster Type')#.Cluster.ComputerRole']$")
 oInstance.AddProperty "$MPElement[Name='#alias('Microsoft.Windows.Library')#!Microsoft.Windows.Computer']/PrincipalName$", strComputer
 oInstance.AddProperty "$MPElement[Name='System!System.Entity']/DisplayName$", strComputer
 oInstance.AddProperty "$MPElement[Name='#text('MP Id')#.#text('Cluster Type')#.Cluster.ComputerRole']/ClusterName$", UCase(strClusterName)
 oDiscoveryData.AddInstance(oInstance)
 END IF
 END IF
 End If
END IF
oAPI.Return oDiscoveryData
 ]]></ScriptBody>
 <TimeoutSeconds>120</TimeoutSeconds>
 </DataSource>
 </Discovery>
 </Discoveries>
 </Monitoring>
 <LanguagePacks>
 <LanguagePack ID="ENU" IsDefault="true">
 <DisplayStrings>
 <DisplayString ElementID="#text('MP Id')#.#text('Cluster Type')#.Cluster.ComputerRole">
 <Name>#text('Class DisplayName')#</Name>
 <Description></Description>
 </DisplayString>
 <DisplayString ElementID="#text('MP Id')#.#text('Cluster Type')#.Cluster.ComputerRole" SubElementID="ClusterName">
 <Name>Cluster Name</Name>
 <Description></Description>
 </DisplayString>
 <DisplayString ElementID="#text('MP Id')#.#text('Cluster Type')#.Cluster.ComputerRole.Discovery">
 <Name>#text('Class DisplayName')# Discovery</Name>
 <Description>Script discovery for #text('Class DisplayName')#</Description>
 </DisplayString>
 </DisplayStrings>
 </LanguagePack>
 </LanguagePacks>
</ManagementPackFragment>

```

When using this template, for each cluster that you want to define and discover in your MP, simply supply the following information:

<a href="https://blog.tyang.org/wp-content/uploads/2014/03/image12.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2014/03/image_thumb12.png" width="580" height="114" border="0" /></a>

* **MP Id:** the ID (or the prefix) of your MP. this is going to be used as the prefix for all the items defined in the snippet.
* **Cluster Type:** the type (or common name) of your cluster. i.e. SQL, Hyper-V, etc.
* **Cluster Resource Type:** The value of the "Type" property of the MSCluster_Resource WMI instance.

<a href="https://blog.tyang.org/wp-content/uploads/2014/03/image13.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2014/03/image_thumb13.png" width="580" height="395" border="0" /></a>

* **Cluster Resource Name Search String:** the search string for the cluster resource name.

<a href="https://blog.tyang.org/wp-content/uploads/2014/03/image14.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2014/03/image_thumb14.png" width="562" height="348" border="0" /></a>

The "SQL Server Cluster" discovered in the previous screenshot is created using this snippet template.

You can also download the snippet template <a href="https://blog.tyang.org/wp-content/uploads/2014/03/Cluster.templatesnippet.zip">here</a>.