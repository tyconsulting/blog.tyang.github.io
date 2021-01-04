---
id: 6955
title: Extracting High Resolution Icons from the Azure Portal
date: 2019-03-08T00:34:31+10:00
author: Tao Yang
#layout: post
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

1. Login to the Azure portal (<a href="https://portal.azure.com">https://portal.azure.com</a>) using Chrome
2. Pin the service that you wish to extract the icon to the left navigation pane. I will use the Azure policy as an example here.

<a href="https://blog.tyang.org/wp-content/uploads/2019/03/image.png"><img width="834" height="371" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2019/03/image_thumb.png" border="0"></a>

{:start="3"}
3. Right-click the icon from the left navigation pane and select "Inspect"

<a href="https://blog.tyang.org/wp-content/uploads/2019/03/image-1.png"><img width="555" height="461" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2019/03/image_thumb-1.png" border="0"></a>

{:start="4"}
4. Expand the <svg> element until you see a &lt;svg&gt; element with the "viewBox" attribute, then select the &lt;svg&gt; element with viewbox attribute, and select copy—&gt;copy element

<a href="https://blog.tyang.org/wp-content/uploads/2019/03/image-2.png"><img width="1002" height="445" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2019/03/image_thumb-2.png" border="0"></a>

{:start="5"}
5. Paste the section to a text editor, and format the pasted XML code as shown below:

<a href="https://blog.tyang.org/wp-content/uploads/2019/03/image-3.png"><img width="1002" height="308" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2019/03/image_thumb-3.png" border="0"></a>

{:start="6"}
6. On the Chrome browser window, click on each of the drawing sub-element under <g> (in this case, the &lt;circle&gt; and &lt;path&gt; elements), go to "Computed" tab and copy the value in the "fill" property. The value can be either the HTML hex colour code (such as **#FF0000**), or the rgb colour code (such as <strong>rgb(255,0,0)</strong>).

<a href="https://blog.tyang.org/wp-content/uploads/2019/03/image-4.png"><img width="778" height="533" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2019/03/image_thumb-4.png" border="0"></a>

{:start="7"}
7. If the drawing sub-element has a "class" attribute, remove it, and add / update the "fill" attribute with the value you copied from the preview step.
8. In the top level \<svg\> element, remove all attributes except for the viewBox, and add **xmlns=http://www.w3.org/2000/svg**, then save the file with .svg as file extension

<a href="https://blog.tyang.org/wp-content/uploads/2019/03/image-5.png"><img width="1002" height="266" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2019/03/image_thumb-5.png" border="0"></a>

{:start="9"}
9. Open the svg file in Chrome to verify the image is the same as what you see in the portal (but much bigger)

<a href="https://blog.tyang.org/wp-content/uploads/2019/03/image-6.png"><img width="1002" height="553" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2019/03/image_thumb-6.png" border="0"></a>

{:start="10"}
10. Convert the svg to any image format if you need to.

Few notes:
* the svg code for some icons may have the "fill-rule" attributes. if this is the case, replace it with "fill" attribute and the colour code from the "Computed" tab, and remove the "class" attribute. (for example, the new Log Analytics icon):

<a href="https://blog.tyang.org/wp-content/uploads/2019/03/image-7.png"><img width="402" height="452" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2019/03/image_thumb-7.png" border="0"></a>

* You may also convert the rgb colour code to the hex colour code, and use the hex code in the "fill" attribute.
