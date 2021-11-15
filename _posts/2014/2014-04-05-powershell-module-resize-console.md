---
id: 2466
title: 'PowerShell Module: Resize-Console'
date: 2014-04-05T21:55:35+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=2466
permalink: /2014/04/05/powershell-module-resize-console/
categories:
  - PowerShell
tags:
  - PowerShell
  - PowerShell Web Access
---
I’m currently working on a solution that relies on PowerShell Web Access (Hopefully I can finish tonight and blog it in next couple of days).

I have been a bit hesitate to use use PWSA every since I firstly tried it out briefly back in 2012 (and blogged my experience [here](https://blog.tyang.org/2012/11/10/my-first-impression-on-powershell-web-access)).

Why am I hesitated? this is why:

![](https://blog.tyang.org/wp-content/uploads/2014/04/image6.png)

The interface is just not that user-friendly with such a small window and that much useless space. There is no way to easily resize the window.

In my original blog post, I posted a simple script to increase the size. Today, I spent a little bit more time, wrote a module based on the original code, and of course made it more flexible.

This module has only one function called Resize-Console:

```powershell
Function Resize-Console
{
<# 
 .Synopsis
  Resize PowerShell console window

 .Description
  Resize PowerShell console window. Make it bigger, smaller or increase / reduce the width and height by a specified number

 .Parameter -Bigger
  Increase the window's both width and height by 10.

 .Parameter -Smaller
  Reduce the window's both width and height by 10.

 .Parameter Width
  Resize the window's width by passing in an integer.

 .Parameter Height
  Resize the window's height by passing in an integer.

 .Example
   # Make the window bigger.
   Resize-Console -bigger
 .Example
   # Make the window smaller.
   Resize-Console -smaller
 .Example
   # Increase the width by 15.
   Resize-Console -Width 15
 .Example
   # Reduce the Height by 10.
   Resize-Console -Height -10
 .Example
   # Reduce the Width by 5 and Increase Height by 10.
   Resize-Console -Width -5 -Height 10
#>

  [CmdletBinding()]
  PARAM (
      [Parameter(Mandatory=$false,HelpMessage="Increase Width and Height by 10")][Switch] $Bigger,
      [Parameter(Mandatory=$false,HelpMessage="Reduce Width and Height by 10")][Switch] $Smaller,
      [Parameter(Mandatory=$false,HelpMessage="Increase / Reduce Width" )][Int32] $Width,
      [Parameter(Mandatory=$false,HelpMessage="Increase / Reduce Height" )][Int32] $Height
  )

  #Get Current Buffer Size and Window Size
  $bufferSize = $Host.UI.RawUI.BufferSize
  $WindowSize = $host.UI.RawUI.WindowSize
  If ($Bigger -and $Smaller)
  {
    Write-Error "Please make up your mind, you can't go bigger and smaller at the same time!"
  } else {
    if ($Bigger)
    {
      $NewWindowWidth = $WindowSize.Width + 10
      $NewWindowHeight = $WindowSize.Height + 10

      #Buffer size cannot be smaller than Window size
      If ($bufferSize.Width -lt $NewWindowWidth)
      {
        $bufferSize.Width = $NewWindowWidth
      }
      if ($bufferSize.Height -lt $NewWindowHeight)
      {
        $bufferSize.Height = $NewWindowHeight
      }
      $WindowSize.Width = $NewWindowWidth
      $WindowSize.Height = $NewWindowHeight
    } elseif ($Smaller)
    {
      $NewWindowWidth = $WindowSize.Width - 10
      $NewWindowHeight = $WindowSize.Height - 10
      $WindowSize.Width = $NewWindowWidth
      $WindowSize.Height = $NewWindowHeight
    }

    if ($Width)
    {
      #Resize Width
      $NewWindowWidth = $WindowSize.Width + $Width
      If ($bufferSize.Width -lt $NewWindowWidth)
      {
          $bufferSize.Width = $NewWindowWidth
      }
      $WindowSize.Width = $NewWindowWidth
    }
    if ($Height)
    {
      #Resize Height
      $NewWindowHeight = $WindowSize.Height + $Height
      If ($bufferSize.Height -lt $NewWindowHeight)
      {
          $bufferSize.Height = $NewWindowHeight
      }
      $WindowSize.Height = $NewWindowHeight

    }
    
    #commit resize
    $host.UI.RawUI.BufferSize = $buffersize
    $host.UI.RawUI.WindowSize = $WindowSize
  }
}
```

<a href="https://blog.tyang.org/wp-content/uploads/2014/04/image7.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="https://blog.tyang.org/wp-content/uploads/2014/04/image_thumb7.png" width="580" height="874" border="0" /></a>

I have copied the folder containing this module to **C:\Windows\System32\PowerShell\v1.0\Modules** folder on the server hosting PSWA site so it is available for everyone.

Here’s a screen video capture if you want to see it in action:
<iframe src="//www.youtube.com/embed/HwS20Ahe2lc" height="375" width="640" allowfullscreen="" frameborder="0"></iframe>
<span style="color: #ff0000;">**Note:**</span> Please watch this video in full screen (by double-clicking the video) and choose 720P if you can. Otherwise you might not see much in such a small window.

This module also works on normal PowerShell prompt windows. You can download this PSConsole module [HERE](https://blog.tyang.org/wp-content/uploads/2014/04/PSConsole.zip). to set it up, simply copy to the folder I mentioned above.