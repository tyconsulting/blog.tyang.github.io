---
id: 5735
title: Making PowerShell Based Azure Functions to Produce HTML Outputs
date: 2016-10-13T20:53:52+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=5735
permalink: /2016/10/13/making-powershell-based-azure-functions-to-produce-html-outputs/
categories:
  - Azure
tags:
  - Azure
  - Azure Functions
  - 'C#'
  - PowerShell
---
Over the last few weeks, I’ve been working with my MVP buddy Alex Verkinderen (<a href="https://twitter.com/AlexVerkinderen">@AlexVerkinderen</a>) on some Azure Function related stuff. We have both written few PowerShell based functions that output a HTML page.

These functions use the ConvertTo-HTML cmdlet to produce the HTML output. For example, here’s a simple one that  list 2 cars in a HTML table:
```powershell
$Cars = @()
#Car #1
$CarProperties = @{
'Make' = 'BMW'
'Colour' = 'Black'
'RegistrationNumber' = 'ABC123'
}
$Cars += New-Object psobject -Property $CarProperties

#Car #2
$CarProperties = @{
'Make' = 'Toyota'
'Colour' = 'Red'
'RegistrationNumber' = 'DEF456'
}
$Cars += New-Object psobject -Property $CarProperties
$HTMLOutput = ($Cars | ConvertTo-Html -Title 'Car List') | Out-String
Out-file -encoding Ascii -FilePath $res -InputObject $HTMLOutput
```

Today we ran into an issue while preparing for our next blog posts, after some diagnostics, we realised the issue was caused by the HTML output returned from the PowerShell based functions.

If I use Invoke-WebRequest cmdlet in Powershell to trigger this PowerShell function, I am able to get the HTML output in the request output content and everything looks good:

<a href="https://blog.tyang.org/wp-content/uploads/2016/10/image-19.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/10/image_thumb-19.png" alt="image" width="650" height="104" border="0" /></a>

However, if we simply invoke this function from a browser, although the output is in HTML format, the browser does not display the HTML page. it displays the HTML source code instead:

<a href="https://blog.tyang.org/wp-content/uploads/2016/10/image-20.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/10/image_thumb-20.png" alt="image" width="522" height="183" border="0" /></a>

after some research, we found the cause of this issue – the content type returned by the PowerShell function is always set to "text/plain":

<a href="https://blog.tyang.org/wp-content/uploads/2016/10/image-21.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/10/image_thumb-21.png" alt="image" width="373" height="242" border="0" /></a>

I suspect this is because for PowerShell based functions, we have to output to a file ($res variable by default). I have tried to construct a proper HTTP response message (System.Net.Http.HttpResponseMessage), but it didn’t work in the PowerShell functions. Based on my testing results, it seems PowerShell functions cannot handle complex types.

Luckily I found this post and it pointed me to the right direction: <a title="http://anthonychu.ca/post/azure-functions-serve-html/" href="http://anthonychu.ca/post/azure-functions-serve-html/">http://anthonychu.ca/post/azure-functions-serve-html/</a>. According on this post, we can certainly serve out a proper HTML page in C# based functions.

I don’t really want to rewrite all my PowerShell functions to C#, not only because I don’t want to reinvent the wheels, but also I want to keep using the PowerShell modules in those existing functions. In the end, I came up with C# based "wrapper" function. I named this function [**HTTPTriggerProxy**](https://gist.github.com/tyconsulting/eae44357f14818006bf0ba94bf07bae1):

```cpp
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using System.IO;
using System.Text;

public static async Task<HttpResponseMessage> Run(HttpRequestMessage req, TraceWriter log)
{
  log.Info($"C# HTTP trigger proxy function processed a request. RequestUri={req.RequestUri}");

  // parse query parameter
  string requesturl = req.GetQueryNameValuePairs()
    .FirstOrDefault(q => string.Compare(q.Key, "requesturl", true) == 0)
    .Value;
  log.Info($"C# HTTP trigger proxy function is trying to get response from {requesturl}");

  Encoding outputencoding = Encoding.GetEncoding("ASCII");
  var ProxyResponse = new HttpResponseMessage();
  HttpStatusCode statuscode = new HttpStatusCode();
  
  if (requesturl == null)
  {
    statuscode = HttpStatusCode.BadRequest;
    StringContent errorcontent =new StringContent("Please pass a web request url on the query string or in the request body", outputencoding); 
    ProxyResponse = req.CreateResponse(statuscode, errorcontent);
    ProxyResponse.Content.Headers.ContentType = new MediaTypeHeaderValue("text/html");
    ProxyResponse.Content = errorcontent;
  } else {
    HttpClient client = new HttpClient();
    HttpResponseMessage response = await client.GetAsync(requesturl);
    ProxyResponse = response;
    ProxyResponse.Content.Headers.ContentType = new MediaTypeHeaderValue("text/html");
  }
  return ProxyResponse;
}
```

This C# based HTTPTriggerProxy function simply takes the URL you have specified, get the response and wrap it in a proper HTTPResponseMessage object. All you need to do is to specify the original URL that you want to request in the "RequestURL" parameter as part of the wrapper function URL:

https://\<Your Azure Function Account\>.azurewebsites.net/api/HttpTriggerProxy?code=\<Access code for Http Trigger Proxy function\><span style="background-color: #ffff00; color: #ff0000;">&RequestURL=<Your original request URL></span>.

Now if I use this wrapper to invoke the sample GetCars PowerShell function, the HTML page is displayed in the browser as expected:

<a href="https://blog.tyang.org/wp-content/uploads/2016/10/image-22.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/10/image_thumb-22.png" alt="image" width="646" height="132" border="0" /></a>

and you can see the content type is now set as "text/html":

<a href="https://blog.tyang.org/wp-content/uploads/2016/10/image-23.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/10/image_thumb-23.png" alt="image" width="692" height="256" border="0" /></a>

**<span style="background-color: #ffff00;">Note:</span>**

 * This wrapper function only supports the Get HTTP method. The Post method is not supported so you can only pass the RequestURL in the the wrapper URL (as opposed to placing it in the request body). I didn’t bother to cater the POST method in this function because what we are going to use this for only supports HTTP Get method.
 * if your original request requires authentication, then this is not going to work for you.
 * If you original URL contains the ampersand character ("**<span style="background-color: #ffff00; color: #ff0000;">&</span>**"), please replace it with "**<span style="background-color: #ffff00; color: #ff0000;">%26</span>**". for example, if your original request is https://myazurefunction.azurewebsites.net/api/GetCars?code=rgpxmm0p87fh2z1wd0a6vargfxxogb6cf<span style="background-color: #ffff00; color: #ff0000;">&</span>colour=red**, **then you need to change it to https://myazurefunction.azurewebsites.net/api/GetCars?code=rgpxmm0p87fh2z1wd0a6vargfxxogb6cf<span style="background-color: #ffff00; color: #ff0000;">%26</span>colour=red

Lastly, this is just something we came up today while making another set of posts. Please stay turned. our new posts will be published in the next day or two.