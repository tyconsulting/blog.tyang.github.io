---
id: 6955
title: Extracting High Resolution Icons from the Azure Portal
date: 2019-03-08T00:34:31+10:00
author: Tao Yang
layout: post
guid: https://blog.tyang.org/?p=6955
permalink: /2019/03/08/extracting-high-resolution-icons-from-the-azure-portal/
categories:
  - Azure
tags:
  - Azure
---
I found myself and friends are constantly looking for high resolution icons for various Azure products when working on design documents, presentation slide decks, or designing stickers to put on our laptops. Although Microsoft provides free download for the Azure icon set, unfortunately, the icon set does not get updated often. at the time of writing this blog, the latest version of the icon set is over 1 year old (<a title="https://www.microsoft.com/en-us/download/details.aspx?id=41937" href="https://www.microsoft.com/en-us/download/details.aspx?id=41937">https://www.microsoft.com/en-us/download/details.aspx?id=41937</a>).

There are few posts out there showing you how to extract icons from the Azure portal, but they all require 3rd party tools. I had requirements for some icons that are not included in the latest version of the Azure icon set, so I spent some time and figured out a way to extract icons in svg format using only Google Chrome browser and a text editor such as Notepad or Notepad++.

Here are the steps:

<ol>
    <li>Login to the Azure portal (<a href="https://portal.azure.com">https://portal.azure.com</a>) using Chrome</li>
    <li>Pin the service that you wish to extract the icon to the left navigation pane. I will use the Azure policy as an example here.</li>
</ol>

<a href="https://blog.tyang.org/wp-content/uploads/2019/03/image.png"><img width="834" height="371" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2019/03/image_thumb.png" border="0"></a>

<ol>
    <li>Right-click the icon from the left navigation pane and select “Inspect”</li>
</ol>

<a href="https://blog.tyang.org/wp-content/uploads/2019/03/image-1.png"><img width="555" height="461" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2019/03/image_thumb-1.png" border="0"></a>

<ol>
    <li>Expand the &lt;svg&gt; element until you see a &lt;svg&gt; element with the “viewBox” attribute, then select the &lt;svg&gt; element with viewbox attribute, and select copy—&gt;copy element</li>
</ol>

<a href="https://blog.tyang.org/wp-content/uploads/2019/03/image-2.png"><img width="1002" height="445" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2019/03/image_thumb-2.png" border="0"></a>

<ol>
    <li>Paste the section to a text editor, and format the pasted XML code as shown below:</li>
</ol>

<a href="https://blog.tyang.org/wp-content/uploads/2019/03/image-3.png"><img width="1002" height="308" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2019/03/image_thumb-3.png" border="0"></a>

<ol>
    <li>On the Chrome browser window, click on each of the drawing sub-element under &lt;g&gt; (in this case, the &lt;circle&gt; and &lt;path&gt; elements), go to “Computed” tab and copy the value in the “fill” property. The value can be either the HTML hex colour code (such as <strong>#FF0000</strong>), or the rgb colour code (such as <strong>rgb(255,0,0)</strong>).</li>
</ol>

<a href="https://blog.tyang.org/wp-content/uploads/2019/03/image-4.png"><img width="778" height="533" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2019/03/image_thumb-4.png" border="0"></a>

<ol>
    <li>If the drawing sub-element has a “class” attribute, remove it, and add / update the “fill” attribute with the value you copied from the preview step.</li>
    <li>In the top level &lt;svg&gt; element, remove all attributes except for the viewBox, and add <strong>xmlns=</strong><a href="http://www.w3.org/2000/svg"><strong>http://www.w3.org/2000/svg</strong></a>, then save the file with .svg as file extension</li>
</ol>

<a href="https://blog.tyang.org/wp-content/uploads/2019/03/image-5.png"><img width="1002" height="266" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2019/03/image_thumb-5.png" border="0"></a>

<ol>
    <li>Open the svg file in Chrome to verify the image is the same as what you see in the portal (but much bigger)</li>
</ol>

<a href="https://blog.tyang.org/wp-content/uploads/2019/03/image-6.png"><img width="1002" height="553" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2019/03/image_thumb-6.png" border="0"></a>

<ol>
    <li>Convert the svg to any image format if you need to.</li>
</ol>

Few notes:

<ul>
    <li>the svg code for some icons may have the “fill-rule” attributes. if this is the case, replace it with “fill” attribute and the colour code from the “Computed” tab, and remove the “class” attribute. (for example, the new Log Analytics icon):</li>
</ul>

<a href="https://blog.tyang.org/wp-content/uploads/2019/03/image-7.png"><img width="402" height="452" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2019/03/image_thumb-7.png" border="0"></a>

<ul>
    <li>You may also convert the rgb colour code to the hex colour code, and use the hex code in the “fill” attribute.</li>
</ul>