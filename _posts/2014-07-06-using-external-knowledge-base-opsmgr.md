---
id: 2918
title: Using an External Knowledge Base for OpsMgr
date: 2014-07-06T22:28:44+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=2918
permalink: /2014/07/06/using-external-knowledge-base-opsmgr/
categories:
  - SCOM
tags:
  - Knowledge Base
  - SCOM
---
<h3><a href="http://blog.tyang.org/wp-content/uploads/2014/07/knowledge-base.png"><img class="alignleft size-full wp-image-2920" src="http://blog.tyang.org/wp-content/uploads/2014/07/knowledge-base.png" alt="knowledge-base" width="252" height="196" /></a>Summary</h3>
I’ve been wanting to write a post on this topic for a while. Using an external knowledge base for OpsMgr is not something new. Many people have already shared their experiences on how to setup one up. My intention is to focus less on the technical side (i.e. How to set it up), but discussing what are the limitations of managing internal KB’s (company knowledge) natively within OpsMgr from both technical and organisational and social point of view and the how can we fill these gaps by using an external knowledge base management system.

<strong><span style="color: #ff0000;">Please Note: </span></strong>this post is 100% based on my own experience working on a very large OpsMgr environment which involves a mixture of 2007 and 2012 management groups and many support teams.

As I have been working for a "Customer" for the last 3 years instead of working for a solutions provider, who generally only spend a short period of time and move on to the next engagement, I am able to see the challenges within the organisation from a social and culture point of view. Hopefully you can pick up few points that also apply to your environment.
<h3>Knowledge Base Management in OpsMgr</h3>
In OpsMgr, knowledge base (KB) articles can exist in 2 places: Product Knowledge and Company Knowledge.

<strong>Product Knowledge:</strong> Written by the management pack author, generally saved in the sealed MP cannot be modified.

Operators can access product knowledge from either the alert view or the property window of the workflow:

<a href="http://blog.tyang.org/wp-content/uploads/2014/07/image1.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/07/image_thumb1.png" alt="image" width="554" height="393" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2014/07/image2.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/07/image_thumb2.png" alt="image" width="358" height="413" border="0" /></a>

<strong>Company Knowledge:</strong> Written my someone internally within your organisation. Consider it as an "Addendum" to the product knowledge. Generally OpsMgr operators use this functionality to store any organisation-specific information about the particular alert or workflow.

Company Knowledge articles can be added into the OpsMgr management group from a computer which has Operations Console, Microsoft Visual Studio Runtime for Office, and 32-bit Microsoft Word 2010 installed. These articles are saved into unsealed management packs. They can be viewed same way as product knowledge":

<a href="http://blog.tyang.org/wp-content/uploads/2014/07/image3.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/07/image_thumb3.png" alt="image" width="580" height="323" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2014/07/image4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/07/image_thumb4.png" alt="image" width="352" height="404" border="0" /></a>

<span style="color: #ff0000;"><strong>Note:</strong></span> One thing I’ve picked up while writing this article is once the company knowledge for a particular alert is created and saved into an unsealed management pack, the alert view in Operations console will show the company knowledge article instead of the original product knowledge article. – Something I’ve never noticed in the past.
<h3>Use of Company Knowledge - Pros and Cons</h3>
In my opinion, using Company Knowledge in OpsMgr has the following Pros and Cons
<h4><span style="font-weight: bold;">Pros:</span></h4>
<strong>01. Built-in Functionality within OpsMgr. No additional systems required.</strong>

<strong>02. Can be viewed within OpsMgr Operations and Web Consoles</strong>

<strong>03. Company Knowledge can be retrieved programmatically using OpsMgr SDK</strong>

i.e. <a href="http://blog.tyang.org/2012/08/16/scom-enhanced-email-notification-script-version-2/">SCOM Enhanced Email Notification Script</a> created by myself.
<h4><span style="font-weight: bold;">Cons:</span></h4>
<strong>01. Stored in Unsealed Management Packs meaning additional management pack dependencies (same as override MPs).</strong>

Company KB’s are stored the same way as product KBs, but they are stored in an Unsealed MP. The Unsealed MP therefore requires to reference the sealed MP (where the workflow for the KB is defined). This is very similar to creating overrides. As you wouldn’t save all your overrides in one single MP, same theory applies to company KB’s – We should use a dedicated unsealed MP for each product OpsMgr monitors (i.e. Company KB MP for SQL, Company KB MP for AD etc).

<strong>02. Operators requires at least OpsMgr Author access to add / manage company knowledge articles.</strong>

Therefore, it is probably not a good idea to grant normal operators access to create company KB’s because OpsMgr Author role also gives users access to create other management pack elements such as rules and monitors. However, As the nature of any knowledge base systems, you would encourage everyone to share their knowledge, not to limit the access to only fewer people (if this is the case, we might as well call this system a bulletin instead of a knowledge base).  In the past I have only given few particular users author access for this purpose – as result, not many company KB’s were created because people simply couldn’t be bothered.

<strong>03. Only text and hyper-links can be included in the knowledge articles.</strong>

Sorry, you can’t attach a script / Word documents / Visio diagrams / Pictures / Videos in OpsMgr KB articles. they are only text based.

<strong>04. Users can only create one (1) company KB per OpsMgr workflow and each Company KB is associated to only one (1) workflow</strong>

There’s a 1-to-1 relationship between KB articles and OpsMgr workflows (if the Company KB is created in the operations console). It is possible that you have many very similar monitors in your environments. i.e. In my environment, I have two (2) "Average Wait Time" monitors for SQL DB engines:

<a href="http://blog.tyang.org/wp-content/uploads/2014/07/image5.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/07/image_thumb5.png" alt="image" width="580" height="285" border="0" /></a>

One of these monitor is targeting SQL 2008 and the other one is targeting SQL 2012. If you are to write a company KB, you will need to write 2 separate ones – One for each monitor, although the content could be exactly the same.

<strong>05. The KB article is only available WITHIN the OpsMgr management group Where it is created. There is no way to share it between multiple MG’s and it cannot be access outside of OpsMgr</strong>

Often, when I introduce OpsMgr Company Knowledge to support teams, the response I get is "but we’ve already got all our KB’s in xxxxx (name of a system)." Why would they have to adopt a new system and spend the effort of migrating everything to OpsMgr? And after everything is migrated, you can only access these information when you have access in OpsMgr? Additionally, same as overrides, when you created an override in one management group, it will not automatically appear in another management group. In my employer’s environment, I’ve already lost count how many Test / Dev / Production, 2007 / 2012 management groups we have in total. to keep Company KB’s consistent among all these management groups is a nightmare!

<strong>06. KB articles are not searchable.</strong>

That’s right, unlike other knowledge base products, you cannot search for a specific phrase among all KB articles. Well, it is probably possible via a script using SDK. But it is not something a normal SCOM operators can do.

<strong>07. No versioning control</strong>

As Company KB’s are stored in unsealed MPs, version control does not apply to Unsealed MPs. Plus, once you’ve updated a Company KB, unless you’ve saved the MP before modification, there is no way you can roll back to the previous version, and it is hard to track who created / updated it.

<strong>08. It is complicated to setup a computer to enable Company KB editing</strong>

To be able to create / edit Company KB’s, the computer requires the following applications:
<ul>
	<li>OpsMgr Operations Console</li>
	<li>Visual Studio Runtime for Office</li>
	<li>32-bit Microsoft Word</li>
</ul>
I always get confused on which version of Visual Studio Runtime for Office and MS Word is required for which version of OpsMgr. I had to google the requirements when every time I need to set one up. Currently, Word 2013 is not supported. So in my lab environment, I had to install Word 2010 on one machine where Office 2013 is installed everywhere else.
<h3>Using an External Knowledge Base Solution</h3>
There are many Knowledge sharing / Wiki solutions that you can choose from such as Microsoft SharePoint, WordPress or other Wiki applications. In fact, you may have already started using an external OpsMgr KB solution that you are not aware of - There is a very well-known community initiative called "<a href="http://www.systemcentercentral.com/researchthis/">ResearchThis!</a>". Essetially, ResearchThis is a collection of OpsMgr KB articles hosted on a WordPress site (<a href="http://www.systemcentercentral.com">www.systemcentercentral.com</a>) and a MP which offers an alert task allowing OpsMgr operators to search support articles based on alert name. If you are using ResearchThis!, you have already adopted an external KB solution for your OpsMgr solution.

I believe by taking the Knowledge Base management out of OpsMgr and move to an external system that is designed for managing and sharing knowledge, we can overcome all the "Cons" I’ve listed above:

<strong>01. KB articles are not saved in management packs.</strong> less management packs = less maintenance effort.

<strong>02. Access to the Knowledge Base is controlled outside of OpsMgr.</strong> i.e. if you are using MS SharePoint, you can grant different level of access to users Active Directory IDs / Groups. People no longer needs access to OpsMgr to be able to share their knowledge. Therefore, no more excuses like "I don’t have access in SCOM" when you ask why didn’t they add a solution in the Company KB".

<strong>03. Your KB articles are no longer text based.</strong> Depending on your external KB systems, you may add pictures, videos, attachments etc. to the article.

<strong>04. You can create multiple KB articles for a single alert, or a single KB article for multiple alerts, it is flexible.</strong>

<strong>05. For systems like WordPress and MS Sharepoint, not only you are able to search, but you can also use tags to further categorise your KB articles.</strong>

<strong>06. If you are running multiple OpsMgr management groups, you don’t need to have multiple instances of your KB solution of the choice.</strong> You can use a centralised knowledge base across all your management groups (and systems other than OpsMgr). personally, this is the what interests me the most based on my experience with my current employer. Not only we have many management groups (mixture of 2007 and 2012), but we also have different teams supporting same / similar systems. i.e. different support teams supporting Windows OS and other LOB applications. Some of these teams are located in different sites and they don’t know each other. By creating a centralised knowledge base will help different support teams to share their knowledge and increase productivity. – Or help to create a virtual team as what management would like to say.

<strong>07. Version Control is a standard feature in most of these systems (i.e. WordPress or MS SharePoint). </strong>You can easily roll back to previous versions and audit who created / updated the particular article.

08. <strong>No additional configuration is required on OpsMgr operators PCs.</strong> Well, it is probably more complicated to setup a SharePoint Wiki than to install all required components on a PC to enable Company KB editing. but the good thing is, you only need to do it once.

<strong>09. it is easy to extend your external KB solution to other OpsMgr management groups.</strong> i.e. If you would like to use "ResearchThis!", all you have to do is to import the ResearchThis MP, which only contains few console tasks.
<h3>How To Setup an External Knowledge Base</h3>
Well, it depends on what type of system you’d like to implement. I don’t think anyone can write a single guide to cover it. Having said that, there are few examples out there we can refer to:

WordPress Example: <a href="http://www.systemcentercentral.com/researchthis/">ResearchThis!</a>

Sharepoint Example: <a href="http://www.systemcentercentral.com/use-sharepoint-wiki-as-scom-knowledge-base/">Use SharePoint Wiki as SCOM Knowledge Base (by Stefan Koell)</a>

In my lab, I have setup a SharePoint 2013 Enterprise Wiki site as per Stefan Koell’s post.

<a href="http://blog.tyang.org/wp-content/uploads/2014/07/image6.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/07/image_thumb6.png" alt="image" width="580" height="357" border="0" /></a>

Additionally I created a management pack which contains 4 tasks:
<ul>
	<li>Open Knowledge Base (as per Stefan’s post)</li>
	<li>Search Knowledge Base (Search the SharePoint Wiki Site)</li>
	<li>Search in Google</li>
	<li>Search in Bing</li>
	<li>Search in ResearchThis!</li>
</ul>
The reason I didn’t use ResearchThis MP is because tasks in ResearchThis! MP only launches Internet Explorer (as Shown below):

<a href="http://blog.tyang.org/wp-content/uploads/2014/07/SNAGHTML1bf56eb.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML1bf56eb" src="http://blog.tyang.org/wp-content/uploads/2014/07/SNAGHTML1bf56eb_thumb.png" alt="SNAGHTML1bf56eb" width="418" height="275" border="0" /></a>

And I created same tasks that launches user’s default web browser:

<a href="http://blog.tyang.org/wp-content/uploads/2014/07/SNAGHTML1c1dab8.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML1c1dab8" src="http://blog.tyang.org/wp-content/uploads/2014/07/SNAGHTML1c1dab8_thumb.png" alt="SNAGHTML1c1dab8" width="418" height="308" border="0" /></a>

I have created this MP in VSAE and sealed it with a key. In a real life environment, I’d probably do the same and included this MP as a standard MP which should be imported into all the management groups within an organisation.

<strong><span style="color: #ff0000;">Tip:</span></strong> If you’d like to use ResearchThis! MP, but you don’t want OpsMgr operators to accidentally post sensitive information to the ResearchThis! KB because of the security concerns, you can simply remove the "Share This" task from ResearchThis! MP since it is unsealed.

Marnix Wolf has written an good article on how to create this type of console tasks a long time ago: <a title="http://thoughtsonopsmgr.blogspot.com.au/2010/09/scom-tasks-part-iv-lets-create-simple.html" href="http://thoughtsonopsmgr.blogspot.com.au/2010/09/scom-tasks-part-iv-lets-create-simple.html">http://thoughtsonopsmgr.blogspot.com.au/2010/09/scom-tasks-part-iv-lets-create-simple.html</a>. If you’d like to use your default browser instead of IE, please use the command line from Rikard Ronnkvist’s comment in this post (the first comment).

<strong>Conclusion</strong>

As I stated in the beginning, this post is not a "How-To" guide. The intention is to help people making design decisions when designing OpsMgr solutions. This post is 100% based on my own experience and opinion. Please feel free to contact me if you want to a further discussion on this topic.