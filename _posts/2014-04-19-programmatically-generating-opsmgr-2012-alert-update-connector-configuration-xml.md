---
id: 2555
title: Programmatically Generating the OpsMgr 2012 Alert Update Connector Configuration XML
date: 2014-04-19T22:55:17+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=2555
permalink: /2014/04/19/programmatically-generating-opsmgr-2012-alert-update-connector-configuration-xml/
categories:
  - SCOM
tags:
  - Powershell
  - SCOM
---
<strong>Background</strong>

After been working on a project for over a year, I’ve start to see some light at the end of the tunnel. The last task I have in order to production-transition the 4 OpsMgr 2012 R2 management groups that I have designed and built is to configure integration between our ticket logging tool and OpsMgr to allow alerts to be automatically logged as IM’s.

Back in the OpsMgr 2007 days, before I started with the organisation, one of my colleagues have designed a set of very comprehensive Opalis policies (yes, they were called policies instead of runbooks back then) to populate various information for alerts such as product types, problem types, endpoints NetBIOS names, etc. then forward alerts to the ticketing system. In my opinion, my colleague did a very good job designing those Opalis policies and it was bullet-proof back then. But as the time goes by, we have been writing / introducing new management packs to monitor additional applications. This set of Opalis policies have become a pain in the butt to update to keep up with the changes because the logics have become really complicated.

Now, it’s up to me to migrate this set of Opalis policies to Orchestrator 2012 R2 and modify them to work with each OpsMgr 2012 R2 management groups. Because we did not just build a 2012 management group for each 2007 management group and we will have different agents / management packs in each 2012 MG, also in the new environment, we are going to have different support groups managing same applications (but different groups of agents), so we are moving to a multi-tenant setup if you like. So when I opened up the old Opalis policies and had a look, I’ve decided to give the 2012 Alert Update Connector a try and see if it will help me simplifies the Orchestrator runbooks.

<strong>My Initial Experience with Alert Update Connector</strong>

Because of these two excellent blog posts, It was very easy for me to setup the connector to test:

<a href="http://blogs.technet.com/b/kevinholman/archive/2012/09/29/opsmgr-public-release-of-the-alert-update-connector.aspx">OpsMgr: Public release of the Alert Update Connector</a>

<a href="http://blogs.technet.com/b/markmanty/archive/2012/05/03/scom-alert-updater-service-connector-example-updating-scom-alerts.aspx">SCOM Alert Updater Service – connector example updating SCOM alerts</a>

In my opinion, based on my requirements, the only place that I think that needs improvement is how the configuration XML file is populated using the GUI tool(ConnectorConfiguration.exe):

<a href="http://blog.tyang.org/wp-content/uploads/2014/04/image13.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/04/image_thumb13.png" alt="image" width="516" height="362" border="0" /></a>

<strong>Improvements required in my opinion:</strong>

01. Perf and event collection rules are available for selection (i.e. all the highlighted ones above). These rules will never generate alert, There is no need to add them to the configuration XML.

02. Although I can select multiple workflows at once, and specify the fields to update, it’s still a manual process and very time consuming if I want to configure all alerts in a management group. Also, being manual means the process is prone to human error. I would love to be able to configure all alerts at once, in bulk. it’s like cherry picking using hands VS. harvesting the entire field using a harvester.

<a href="http://blog.tyang.org/wp-content/uploads/2014/04/SNAGHTML11522d3b.png"><img style="display: inline; border-width: 0px;" title="SNAGHTML11522d3b" src="http://blog.tyang.org/wp-content/uploads/2014/04/SNAGHTML11522d3b_thumb.png" alt="SNAGHTML11522d3b" width="552" height="196" border="0" /></a>

03. It’s hard to find workflows in the configuration xml which this GUI tool populated:

<a href="http://blog.tyang.org/wp-content/uploads/2014/04/image14.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/04/image_thumb14.png" alt="image" width="535" height="331" border="0" /></a>

I’ve quickly generated a XML using ConnectorConfiguration.exe as shown above. I can’t really identify the workflow by just reading it.

<strong>Solution</strong>

In order to overcome these issues, and establish a process to maintain and update the configuration XML in the years to come, I have written a PowerShell script to generate the Alert Update Connector configuration XML based on a set of policies I have defined.

This script (called “<strong>ConfigAlertUpdateConnector.ps1</strong>”) is expecting an input XML file called “<strong>ConfigAlertUpdateConnector.xml</strong>” from the same directory. The “ConfigAlertUpdateConnector.xml” stores all the policies that I have defined.

Let’s look at the finishing piece first. The output of this script looks like this:

<a href="http://blog.tyang.org/wp-content/uploads/2014/04/image15.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/04/image_thumb15.png" alt="image" width="580" height="453" border="0" /></a>

As you can see, not only every eligible rule / monitor has been populated according to the policies I defined, I added a comment line (highlighted) that contains the following information:
<ul>
	<li>Workflow type (rule or monitor)</li>
	<li>Rule / Monitor Name</li>
	<li>Rule / Monitor Display Name</li>
	<li>Target Class Name</li>
	<li>Target Class DisplayName</li>
</ul>
it would be so much easier to search for a particular alert in this XML than the one generated by the GUI interface. We can simply copy the monitor / rule display name from the Operations Console and search in XML:

Display name from the Operations console:

<a href="http://blog.tyang.org/wp-content/uploads/2014/04/SNAGHTML16816481.png"><img style="display: inline; border-width: 0px;" title="SNAGHTML16816481" src="http://blog.tyang.org/wp-content/uploads/2014/04/SNAGHTML16816481_thumb.png" alt="SNAGHTML16816481" width="412" height="368" border="0" /></a>

Search in XML:

<a href="http://blog.tyang.org/wp-content/uploads/2014/04/SNAGHTML16828dce.png"><img style="display: inline; border-width: 0px;" title="SNAGHTML16828dce" src="http://blog.tyang.org/wp-content/uploads/2014/04/SNAGHTML16828dce_thumb.png" alt="SNAGHTML16828dce" width="580" height="395" border="0" /></a>

In the script, I have also filtered out all rules and monitors that do not generate alerts so they won’t appear in the output XML.

Now let’s take a look at the “ConfigAlertUpdateConnector.xml”:

<a href="http://blog.tyang.org/wp-content/uploads/2014/04/image16.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/04/image_thumb16.png" alt="image" width="580" height="537" border="0" /></a>

Each Policy is defined within a <strong>&lt;AlertUpdateRule&gt;</strong> tag. Under &lt;AlertUpdateRule&gt;, There is a <strong>&lt;ClassSearchPhrase&gt;</strong> tag. you can specify the search phrase for either target class name or display name, or both. When both name and display name are specified, both criteria must be true during search. For any classes that have returned from the search result, the alerts generated by any workflows targeting these classes will have the properties updated as what’s defined in the <strong>&lt;PropertiesToModify&gt;</strong> tag. Note, the schema within &lt;PropertiesToModify&gt; is same as the Alert Update Connector configuration file (the output).

<strong><span style="color: #ff0000;">Hint:</span> Using Name VS Display Name in &lt;ClassSearchPhrase&gt;</strong>

The Name refers to the actual class ID from the management pack where the target class is defined. i.e. Some classes defined in VMM 2012 MP:

<a href="http://blog.tyang.org/wp-content/uploads/2014/04/image17.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/04/image_thumb17.png" alt="image" width="498" height="364" border="0" /></a>

The Display Name is what you see in the Operations Console.

<a href="http://blog.tyang.org/wp-content/uploads/2014/04/SNAGHTML1699fb1e.png"><img style="display: inline; border-width: 0px;" title="SNAGHTML1699fb1e" src="http://blog.tyang.org/wp-content/uploads/2014/04/SNAGHTML1699fb1e_thumb.png" alt="SNAGHTML1699fb1e" width="467" height="405" border="0" /></a>

As you can see, normally, all classes defined in a particular MP will have the same prefix. in this case, with SCVMM 2012, the prefix is <em>“Microsoft.SystemCenter.VirtualMachineMananager.2012”.</em>

all VMM 2008 classes will have <em>“Microsoft.SystemCenter.VirtualMachineMananager.2008”</em>. So if I want to update all the alerts generated from Microsoft’s VMM MPs regardless the version, I’d use <em>“Microsoft.SystemCenter.VirtualMachineMananager”</em> as the NAME search phrase.

Another example, if I want to update any alerts generated for any “disks” related classes defined in Windows ServerOS MPs, I’d use both Name and Display search phrase:
<ul>
	<li>DisplayName=”disk”</li>
	<li>Name=”Microsoft.Windows.Server”</li>
</ul>
This leads to another issue. I thought I had everything covered, until I configured Fujitsu PRIMERGY server MP (sorry to use Fujitsu as an example in my blog again :P).

<strong>Use of Exceptions</strong>

If I open up Fujitsu MP version 6.0.0.5 in MP Viewer, there are many server components have been defined, such Network component:

<a href="http://blog.tyang.org/wp-content/uploads/2014/04/image18.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/04/image_thumb18.png" alt="image" width="580" height="366" border="0" /></a>

But when I looked at the rules in this MP, all the ones related to the network component are targeting the top level Fujitsu PRIMERGY Server class rather than the Network component:

<a href="http://blog.tyang.org/wp-content/uploads/2014/04/image19.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/04/image_thumb19.png" alt="image" width="580" height="287" border="0" /></a>

In fact, all the rules in this MP are targeting the Server class. I’m not sure how many MPs out there are targeting workflows in “less-appropriate” classes, so in order to work around this issue, I have coded my script to also process exceptions. This is why in my screenshot for “ConfigAlertConnector.xml” above, in the Fujitsu section, I have a lot of exceptions defined:

<a href="http://blog.tyang.org/wp-content/uploads/2014/04/image20.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/04/image_thumb20.png" alt="image" width="579" height="687" border="0" /></a>

As shown above, by default, any Fujitsu alerts will have CustomField1 updated to “FUJ_MISC”, which is the default value. However, if the <strong>workflow’s (rule / monitor) Display Name</strong> contains the phrase “network”, the value for CustomField1 will be set to “FUJ_NIC”. The other 2 default properties defined (ResolutionState and Owner”) will remain the same. In the output xml file, it looks like this:

<a href="http://blog.tyang.org/wp-content/uploads/2014/04/image21.png"><img style="display: inline; border-width: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/04/image_thumb21.png" alt="image" width="580" height="182" border="0" /></a>

The first one have the “network” exception applied so the value has set to “FUJ_NIC”. the second one does not have any exceptions applied so it has the default value of “FUJ_MISC”.

<strong><span style="color: #ff0000;">Note:</span></strong> When exceptions are specified in the policies, the script will only apply an exception if both property <strong>name</strong> and <strong>GroupIdFilter</strong> match the default value:

<a href="http://blog.tyang.org/wp-content/uploads/2014/04/image22.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/04/image_thumb22.png" alt="image" width="580" height="208" border="0" /></a>

<strong>Executing “ConfigAlertUpdateConnector.ps1”</strong>

Once all the policies have been configured in “ConfigAlertUpdateConnector.xml”, and this XML file is placed at the same folder as the ps1 script, we can simply run the script without any parameters. If the output file already exists in the script directory, the script will append the output file name with the current time stamp and move it to a sub folder called “Archive”. In my work’s fully tuned test management group, this script took less than 2 minutes to run, and generated the config file containing just less than 3000 workflows for Alert Update Connector.

In future, when we add new management packs or update / delete existing management packs, we can simply make minor modifications to the existing policies in “ConfigAlertUpdateConnector.xml” and re-run this script to generate the config file for Alert Update Connector.

You can download the script, the sample “ConfigAlertUpdateConnector.xml” and the sample output file <a href="http://blog.tyang.org/wp-content/uploads/2014/06/ConfigAlertUpdateConnector.zip">HERE</a>.

Lastly, I encourage anyone using the OpsMgr 2012 Alert Update Connector to try this script and any feedbacks are welcome. I believe I have covered everything in terms of how to configure the input xml (“ConfigAlertUpdateConnector.xml”). If I have missed anything, please feel free to drop me an email.