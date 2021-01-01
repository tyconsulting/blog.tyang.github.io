---
id: 379
title: Powershell Functions do not return single element arrays
date: 2011-02-24T16:51:00+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=379
permalink: /2011/02/24/powershell-functions-do-not-return-single-element-arrays/
categories:
  - PowerShell
tags:
  - array
  - arraylist
  - functions
---
<p>I came across an interesting problem today that a function I wrote to return all SCCM primary sites worked at work but did not work at home. the difference between 2 SCCM environments is that I only have 1 single SCCM site in my home environment comparing to large multi-tier SCCM infrastructure at work. after some investigation I found out this common issue with Powershell when comes to returning arrays from a function.</p>  <p>For example:</p>  <p><a href="http://blog.tyang.org/wp-content/uploads/2011/02/image.png"><img style="background-image: none; border-right-width: 0px; padding-left: 0px; padding-right: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; border-left-width: 0px; padding-top: 0px" title="image" border="0" alt="image" src="http://blog.tyang.org/wp-content/uploads/2011/02/image_thumb.png" width="580" height="443" /></a></p>  <p>The first function <strong>foo</strong> <strong>should</strong> returns a single element arraylist, and the variable it returned has the same type as the type of the only element in the arraylist.</p>  <p>The second function <strong>boo</strong> <strong>should</strong> returns a two-element arraylist but the type of returned variable has changed from .NET arraylist to normal powershell array.</p>  <p>So how should I get Powershell to return the <strong>same variable type</strong> in a function when it’s some sort of array?</p>  <p>In the return statement inside of the function, <strong>add a comma (“,”) in front of variable:</strong></p>  <p><strong>.NET ArrayList:</strong></p>  <p><a href="http://blog.tyang.org/wp-content/uploads/2011/02/image2.png"><img style="background-image: none; border-bottom: 0px; border-left: 0px; padding-left: 0px; padding-right: 0px; display: inline; border-top: 0px; border-right: 0px; padding-top: 0px" title="image" border="0" alt="image" src="http://blog.tyang.org/wp-content/uploads/2011/02/image_thumb2.png" width="580" height="426" /></a></p>  <p>&#160;</p>  <p><strong>Normal Powershell arrays:</strong></p>  <p><a href="http://blog.tyang.org/wp-content/uploads/2011/02/image3.png"><img style="background-image: none; border-bottom: 0px; border-left: 0px; padding-left: 0px; padding-right: 0px; display: inline; border-top: 0px; border-right: 0px; padding-top: 0px" title="image" border="0" alt="image" src="http://blog.tyang.org/wp-content/uploads/2011/02/image_thumb3.png" width="572" height="456" /></a></p>  <p>More readings about this <a href="http://blogs.msdn.com/b/powershell/archive/2009/02/27/converting-to-array.aspx">here</a> and <a href="http://keithhill.spaces.live.com/Blog/cns!5A8D2641E0963A97!811.entry">here</a></p>