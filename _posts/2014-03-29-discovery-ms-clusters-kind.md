---
id: 2436
title: Discovery for MS Clusters of Any Kind
date: 2014-03-29T23:32:42+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=2436
permalink: /2014/03/29/discovery-ms-clusters-kind/
categories:
  - SCOM
tags:
  - MP Authoring
  - SCOM
---
Often when developing an OpsMgr management pack for server class applications, we need to be cluster-aware. Sometimes workflows don’t need to run on a cluster, sometimes, the workflow should only be executed on a cluster. (i.e. I wrote a monitor that runs on a Windows 2008 R2 Hyper-V cluster once a day and check if all virtual machines are hosted by their preferred cluster nodes.)

There are many good articles out there explaining cluster-aware discoveries in OpsMgr management packs:
<ul>
	<li><a href="http://blogs.technet.com/b/authormps/archive/2011/03/13/your-mp-discoveries-and-clustering.aspx">Your MP Discoveries and Clustering</a></li>
	<li><a href="https://social.technet.microsoft.com/wiki/contents/articles/1204.mp-best-practice-make-likely-server-roles-mscs-aware.aspx">MP Best Practice – Make likely server roles MSCS aware</a></li>
</ul>
However, in many occasions, only using the “<strong>IsVirtualNode</strong>” property from the Windows Server class (Microsoft.Windows.Server.Computer) is not enough (or granular enough) to identify the specific clusters.

I’m explain what I mean using an example.

For example, I have a 2-node SQL cluster configured as below:
<ul>
	<li>Node 1 name: <strong><em>blablabla</em>SQL01A</strong></li>
	<li>Node 2 name: <strong><em>blablabla</em>SQL01B</strong></li>
	<li>Cluster Name: <strong><em>blablabla</em>SQL01C</strong></li>
	<li>DTC Cluster Resource Access Name: <strong><em>blablabla</em>SQL01D</strong></li>
	<li>SQL Server Cluster Resource Access Name: <strong><em>blablabla</em>SQL01E</strong></li>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2014/03/image7.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2014/03/image_thumb7.png" width="580" height="254" border="0" /></a>

After installing the OpsMgr agent on both cluster nodes and enabled Agent-Proxy for them, totally 5 Windows Server objects will be discovered, one for each name mentioned above:

<a href="http://blog.tyang.org/wp-content/uploads/2014/03/image8.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2014/03/image_thumb8.png" width="580" height="174" border="0" /></a>

As shown above, other than the 2 cluster nodes, other 3 instances have “IsVirtualNode” property set to “True”.

When I looked at the “Computer” state view in the Microsoft SQL management pack, all 5 “Windows Server” are listed as the computer which has SQL installed:

<a href="http://blog.tyang.org/wp-content/uploads/2014/03/image9.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2014/03/image_thumb9.png" width="580" height="280" border="0" /></a>

If I create a discovery for SQL Clusters based on any computers have SQL DB Engine installed and is a virtual node, I would have discovered 3 instances (SQL01C, SQL01D and SQL 01E) for the same cluster.

If I only want to discover the cluster itself (<em>blablabla</em>SQL01C), I believe the discovery needs to perform the following checks:

<strong>01. The Windows Server Is Virtual Node</strong>

After a bit of digging, I found the “Windows Clustering Discovery” from Windows Cluster Library MP sets “IsVirtualNode” to True:

<a href="http://blog.tyang.org/wp-content/uploads/2014/03/image10.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2014/03/image_thumb10.png" width="397" height="304" border="0" /></a>

<strong>02. The existence of Cluster Service</strong>

I’m not sure if there are any management packs other than Windows Clustering Library out there that set IsVirtualNode to True. So , to be safe, I would also configure my discovery to look for the Cluster service.

<strong>03. The cluster is actually hosting my application</strong>

This is done via a WMI query to the MSCluster_Resource class in root\MSCluster name space.

In order to identify the cluster is hosting my application, I need to find if there are any cluster resources that has a specific resource type and also has a name that matches my search string.

i.e. I have access to 3 kinds of clusters in my work environment. I’ll list the WMI query for each cluster type:

<strong>SQL Cluster:</strong> <em>“Select * from MSCluster_Resource Where Type = ‘<strong>SQL Server</strong>’ And Name LIKE ‘<strong>SQL Server’</strong>”</em>

<strong>Hyper-V Cluster:</strong> <em>“Select * from MSCluster_Resource Where Type = ‘<strong>Virtual Machine</strong>’ And Name LIKE ‘<strong>Virtual Machine %</strong>’”</em>
<ul>
	<li><strong><span style="color: #ff0000;">Note:</span></strong> <em>This is because each VM in Hyper-V cluster have a resource name of “Virtual Machine &lt;VM Name&gt;”.</em></li>
</ul>
<strong>OpsMgr 2007 RMS Cluster:</strong> <em>“Select * from MSCluster_Resource Where Type = ‘<strong>Generic Service</strong>’ And Name LIKE ‘<strong>System Center Data Access</strong>”</em>

As you can see, I believe in order to accurately identify my application, both cluster resource type and name need to match. Only using resource type in WMI query is not enough because the resource type could be “Generic Service”.

<strong>04. The computer name matches the cluster name</strong>

Because I am only interested in the actual cluster, not client access names for cluster resource groups, the computer name of the Windows Server instance needs to match the cluster name. I can read the cluster name in registry “<strong><em>HKLM\SYSTEM\CurrentControlSet\Services\ClusSvc\Parameters\ClusterName</em></strong>”

In my sample MP, I created a class based on Microsoft.Windows.ComputerRole for my cluster and created a Timed Script Discovery based on the 4 criteria mentioned above.

<strong><span style="color: #ff0000;">Note:</span></strong> <em>I know that using a script discovery targeting a wide range (all windows servers) is not ideal. I couldn’t manage to write a custom discovery module that meets my requirements. for example, the computer name could be in capital but the cluster name could be in lower case, System.ExpressionFilter (which is used by filtered registry discovery module) does not support case insensitive regular expression match (</em><a href="http://support.microsoft.com/kb/2702651"><em>More Info</em></a><em>). Therefore in my script, I have many IF statements nested. for example, if the windows server is not a virtual node, at the first if statement, it would not meet the if criteria and bypass the rest of the script, jump to the end of the script and submit an empty set of discovery data. I’ve done it this way to ensure the script does not continue running if one criteria is not met.</em>

Again, using SQL clusters as an example, I created a class called “SQL Server Cluster”, and only the actual clusters (name ends with letter “C”) are discovered:

<a href="http://blog.tyang.org/wp-content/uploads/2014/03/image11.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2014/03/image_thumb11.png" width="580" height="182" border="0" /></a>

In order to re-use the code, I have create a snippet template in VSAE. This snippet template includes the class definition, discovery workflow and associated language pack (ENU) display strings.

Here’s the code for the snippet template:

[code language="xml" padlinenumbers="false"]

&lt;ManagementPackFragment SchemaVersion=&quot;1.0&quot;&gt;
 &lt;TypeDefinitions&gt;
 &lt;EntityTypes&gt;
 &lt;ClassTypes&gt;
 &lt;ClassType ID=&quot;#text('MP Id')#.#text('Cluster Type')#.Cluster.ComputerRole&quot; Base=&quot;#alias('Microsoft.Windows.Library')#!Microsoft.Windows.ComputerRole&quot; Accessibility=&quot;Public&quot; Abstract=&quot;false&quot; Hosted=&quot;true&quot; Singleton=&quot;false&quot;&gt;
 &lt;Property ID=&quot;ClusterName&quot; Key=&quot;false&quot; Type=&quot;string&quot; /&gt;
 &lt;/ClassType&gt;
 &lt;/ClassTypes&gt;
 &lt;/EntityTypes&gt;
 &lt;/TypeDefinitions&gt;
 &lt;Monitoring&gt;
 &lt;Discoveries&gt;
 &lt;Discovery ID=&quot;#text('MP Id')#.#text('Cluster Type')#.Cluster.ComputerRole.Discovery&quot; Target=&quot;#alias('Microsoft.Windows.Library')#!Microsoft.Windows.Server.Computer&quot; Enabled=&quot;true&quot; ConfirmDelivery=&quot;false&quot; Remotable=&quot;true&quot; Priority=&quot;Normal&quot;&gt;
 &lt;Category&gt;Discovery&lt;/Category&gt;
 &lt;DiscoveryTypes&gt;
 &lt;DiscoveryClass TypeID=&quot;#text('MP Id')#.#text('Cluster Type')#.Cluster.ComputerRole&quot;&gt;
 &lt;Property TypeID=&quot;#text('MP Id')#.#text('Cluster Type')#.Cluster.ComputerRole&quot; PropertyID=&quot;ClusterName&quot; /&gt;
 &lt;/DiscoveryClass&gt;
 &lt;/DiscoveryTypes&gt;
 &lt;DataSource ID=&quot;DS&quot; TypeID=&quot;#alias('Microsoft.Windows.Library')#!Microsoft.Windows.TimedScript.DiscoveryProvider&quot;&gt;
 &lt;IntervalSeconds&gt;3600&lt;/IntervalSeconds&gt;
 &lt;SyncTime /&gt;
 &lt;ScriptName&gt;ClusterDiscovery.vbs&lt;/ScriptName&gt;
 &lt;Arguments&gt;$MPElement$ $Target/Id$ $Target/Property[Type=&quot;#alias('Microsoft.Windows.Library')#!Microsoft.Windows.Computer&quot;]/PrincipalName$ &quot;#text('Cluster Resource Type')#&quot; &quot;#text('Cluster Resource Name Search String')#&quot; &quot;$Target/Property[Type=&quot;#alias('Microsoft.Windows.Library')#!Microsoft.Windows.Server.Computer&quot;]/IsVirtualNode$&quot;&lt;/Arguments&gt;
 &lt;ScriptBody&gt;
 &lt;![CDATA[
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
const HKEY_LOCAL_MACHINE = &amp;H80000002

Set oAPI = CreateObject(&quot;MOM.ScriptAPI&quot;)
Set oDiscoveryData = oAPI.CreateDiscoveryData(0,SourceID,ManagedEntityID)

'Only continue if IsVirtualNode = &quot;True&quot;
IF UCase(bIsVirtualNode) = &quot;TRUE&quot; Then
 'Check if Failover Cluster service exists
 strKeyPath = &quot;SYSTEM\CurrentControlSet\Services\ClusSvc&quot;
 'connect to the registry provider
 Set oReg=GetObject(&quot;winmgmts:{impersonationLevel=impersonate}!\\&quot; &amp; strComputer &amp; &quot;\root\default:StdRegProv&quot;)
 If oReg.EnumKey(HKEY_LOCAL_MACHINE, strKeyPath, arrSubKeys) = 0 Then
 'Cluster Service exists, continue, check if specified cluster resource exists
 bCLRes = False
 CLResWMIQuery = &quot;Select * from MSCluster_Resource Where Type = '&quot; &amp; strCLResType &amp;&quot;' AND Name LIKE '&quot; &amp; strCLResName &amp; &quot;'&quot;
 Set objWMICluster = GetObject(&quot;winmgmts:\\&quot; &amp; strComputer &amp; &quot;\root\MSCluster&quot;)
 Set ColCLRes = objWMICluster.ExecQuery (CLResWMIQuery)
 For Each objCLRes in ColCLRes
 bCLRes = TRUE
 Next

'NetBIOS Computer Name
 ComputerName = Split(strComputer, &quot;.&quot;, -1)(0)
 'Read Cluster name from registry
 strCLKeyPath = &quot;SYSTEM\CurrentControlSet\Services\ClusSvc\Parameters&quot;
 strCLNameValue = &quot;ClusterName&quot;
 oReg.GetStringValue HKEY_LOCAL_MACHINE,strCLKeyPath, strCLNameValue,strClusterName

'Proceed if NetBIOS Computer Name equals to cluster name
 If UCase(ComputerName) = UCase(strClusterName) Then
 IF bCLRes = TRUE THEN
 Set oInstance = oDiscoveryData.CreateClassInstance(&quot;$MPElement[Name='#text('MP Id')#.#text('Cluster Type')#.Cluster.ComputerRole']$&quot;)
 oInstance.AddProperty &quot;$MPElement[Name='#alias('Microsoft.Windows.Library')#!Microsoft.Windows.Computer']/PrincipalName$&quot;, strComputer
 oInstance.AddProperty &quot;$MPElement[Name='System!System.Entity']/DisplayName$&quot;, strComputer
 oInstance.AddProperty &quot;$MPElement[Name='#text('MP Id')#.#text('Cluster Type')#.Cluster.ComputerRole']/ClusterName$&quot;, UCase(strClusterName)
 oDiscoveryData.AddInstance(oInstance)
 END IF
 END IF
 End If
END IF
oAPI.Return oDiscoveryData
 ]]&gt;&lt;/ScriptBody&gt;
 &lt;TimeoutSeconds&gt;120&lt;/TimeoutSeconds&gt;
 &lt;/DataSource&gt;
 &lt;/Discovery&gt;
 &lt;/Discoveries&gt;
 &lt;/Monitoring&gt;
 &lt;LanguagePacks&gt;
 &lt;LanguagePack ID=&quot;ENU&quot; IsDefault=&quot;true&quot;&gt;
 &lt;DisplayStrings&gt;
 &lt;DisplayString ElementID=&quot;#text('MP Id')#.#text('Cluster Type')#.Cluster.ComputerRole&quot;&gt;
 &lt;Name&gt;#text('Class DisplayName')#&lt;/Name&gt;
 &lt;Description&gt;&lt;/Description&gt;
 &lt;/DisplayString&gt;
 &lt;DisplayString ElementID=&quot;#text('MP Id')#.#text('Cluster Type')#.Cluster.ComputerRole&quot; SubElementID=&quot;ClusterName&quot;&gt;
 &lt;Name&gt;Cluster Name&lt;/Name&gt;
 &lt;Description&gt;&lt;/Description&gt;
 &lt;/DisplayString&gt;
 &lt;DisplayString ElementID=&quot;#text('MP Id')#.#text('Cluster Type')#.Cluster.ComputerRole.Discovery&quot;&gt;
 &lt;Name&gt;#text('Class DisplayName')# Discovery&lt;/Name&gt;
 &lt;Description&gt;Script discovery for #text('Class DisplayName')#&lt;/Description&gt;
 &lt;/DisplayString&gt;
 &lt;/DisplayStrings&gt;
 &lt;/LanguagePack&gt;
 &lt;/LanguagePacks&gt;
&lt;/ManagementPackFragment&gt;

[/code]

When using this template, for each cluster that you want to define and discover in your MP, simply supply the following information:

<a href="http://blog.tyang.org/wp-content/uploads/2014/03/image12.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2014/03/image_thumb12.png" width="580" height="114" border="0" /></a>
<ul>
	<li><strong>MP Id:</strong> the ID (or the prefix) of your MP. this is going to be used as the prefix for all the items defined in the snippet.</li>
	<li><strong>Cluster Type:</strong> the type (or common name) of your cluster. i.e. SQL, Hyper-V, etc.</li>
	<li><strong>Cluster Resource Type:</strong> The value of the “Type” property of the MSCluster_Resource WMI instance.</li>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2014/03/image13.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2014/03/image_thumb13.png" width="580" height="395" border="0" /></a>
<ul>
	<li><strong>Cluster Resource Name Search String:</strong> the search string for the cluster resource name.</li>
</ul>
<a href="http://blog.tyang.org/wp-content/uploads/2014/03/image14.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2014/03/image_thumb14.png" width="562" height="348" border="0" /></a>

The “SQL Server Cluster” discovered in the previous screenshot is created using this snippet template.

You can also download the snippet template <a href="http://blog.tyang.org/wp-content/uploads/2014/03/Cluster.templatesnippet.zip">here</a>.