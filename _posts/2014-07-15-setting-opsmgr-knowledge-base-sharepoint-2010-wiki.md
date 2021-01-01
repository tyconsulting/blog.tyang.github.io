---
id: 2934
title: Setting up OpsMgr Knowledge Base on SharePoint 2010 Wiki
date: 2014-07-15T21:29:33+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=2934
permalink: /2014/07/15/setting-opsmgr-knowledge-base-sharepoint-2010-wiki/
categories:
  - SCOM
tags:
  - SCOM
  - SharePoint
---
Previously, I blogged my opinion on <a href="http://blog.tyang.org/2014/07/06/using-external-knowledge-base-opsmgr/">using external knowledge base for OpsMgr</a>. In that article, I mentioned a <a href="http://www.systemcentercentral.com/use-sharepoint-wiki-as-scom-knowledge-base/">SharePoint 2013 Wiki solution</a> developed by Stefan Koell. As I mentioned, I successfully set it up in my home lab without issues. However, I had issues setting it up at work, which is still using SharePoint 2010.

After going through what I’ve done with the SharePoint engineer in my company, I was told the issue is with <strong>WikiRedirect.aspx</strong>. I was told this page doesn’t exist on my SharePoint 2010 Enterprise Wiki site. So to work around the issue, I had to update Stefan’s JavaScript and made it work in SharePoint 2010. The UI looks a bit different than what WikiRedirect.aspx does, but essentially the same. The script redirects to a page if it already exists, or prompt to create a new page if it doesn’t exist.

Here’s what it looks like:

Redirects to an existing page:

<a href="http://blog.tyang.org/wp-content/uploads/2014/07/image7.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/07/image_thumb7.png" alt="image" width="580" height="323" border="0" /></a>

Prompt to create a new page:

<a href="http://blog.tyang.org/wp-content/uploads/2014/07/image8.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/07/image_thumb8.png" alt="image" width="580" height="287" border="0" /></a>

And here’s the script (I named it RedirectJs.txt):

[sourcecode language="JavaScript"]
&lt;script type=&quot;text/JavaScript&quot; unselectable=&quot;on&quot;&gt;

// the path to the Enterprise Wiki Site in sharepoint
var SiteUrl = 'http://Sharepoint/Sites/SCOMKB/';

// make sure we only execute when a name is provided and when we are not in design/edit mode
var executeMain = false;
if (querystring('DisplayMode') == 'Design' || querystring('ControlMode') == 'Edit')
    executeMain = false;
else if (querystring('Name') == '' || querystring('Name') == null || querystring('Name') == undefined)
    executeMain = false;
else
    executeMain = true;

if (executeMain)
    main();

function querystring(key) {
    // helper function to access query strings
    var re=new RegExp('(?:\\?|&amp;)'+key+'=(.*?)(?=&amp;|$)','gi');
    var r=[], m;
    while ((m=re.exec(document.location.search)) != null) r.push(m[1]);
    return r;
}

function UrlExists(url)
{
    var http = new XMLHttpRequest();
    http.open('HEAD', url, false);
    http.send();
    return http.status!=404;
}
function load_url(externallink)
{
    //window.open(externallink,target='_blank');
	window.location = externallink;
}

function main()
{
	// strip &quot; # % &amp; * : &lt; &gt; ? \ / { } ~ | from name
	var name = querystring('name');
	name = unescape(name);
	name = name.replace(&quot;\&quot;&quot;, '-');
	name = name.replace('#', '-');
	name = name.replace('%', '-');
	name = name.replace('&amp;', '-');
	name = name.replace('*', '-');
	name = name.replace(':', '-');
	name = name.replace('&lt;', '-');
	name = name.replace('&gt;', '-');
	name = name.replace('?', '-');
	name = name.replace('/', '-');
	name = name.replace(&quot;\\&quot;, '-');
	name = name.replace('{', '-');
	name = name.replace('}', '-');
	name = name.replace('~', '-');
	name = name.replace('|', '-');
	// page url
	var pageName = name + '.aspx';
	var pageUrl = SiteUrl + '/Pages/' + pageName;
	var CreatePageUrl = SiteUrl + '/_layouts/CreatePage.aspx?IsDlg=1&amp;Folder=RootFolder&amp;Name=' + name;
	var pageExists = UrlExists(pageUrl);
	if (pageExists) {
		//open page
		load_url(pageUrl);
	} else {
		//Create New page
		load_url(CreatePageUrl);
	}
}
&lt;/script&gt;
[/sourcecode]

When you use this script, please update the SiteUrl variable to represent the URL of your SharePoint wiki site.

<a href="http://blog.tyang.org/wp-content/uploads/2014/07/SNAGHTMLb695c2.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTMLb695c2" src="http://blog.tyang.org/wp-content/uploads/2014/07/SNAGHTMLb695c2_thumb.png" alt="SNAGHTMLb695c2" width="580" height="201" border="0" /></a>

Please note adding scripts to a web part is different in SharePoint 2010 than 2013. The script needs to be uploaded to the site as a separate file then link the the web part. here’s a good <a href="http://sharepointadam.com/2010/08/31/insert-javascript-into-a-content-editor-web-part-cewp/">article</a> on how to do it.

<strong><span style="color: #ff0000;">Note:</span></strong> I have also tested this script on my SharePoint 2013 wiki site. Unfortunately, it does <strong><span style="color: #ff0000;">NOT</span></strong> work.

<strong>Disclaimer:</strong>

My knowledge on SharePoint and JavaScript is next to none. Therefore, when I was told wikiredirect.aspx was the problem, I had to take his word for it. And I did lots of search online and came up with this JavaScript that worked for me. I won’t get offended if someone criticise me if my statement is wrong about SharePoint and if you think the script can be improved. <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" src="http://blog.tyang.org/wp-content/uploads/2014/07/wlEmoticon-smile1.png" alt="Smile" /> Lastly, please test it and make sure it works in your environment. I don’t have another SharePoint 2010 site I can test on, the only place I made it work is on my work’s production SharePoint site.

The script can also be downloaded <a href="http://blog.tyang.org/wp-content/uploads/2014/07/RedirectJs.zip">HERE</a>.