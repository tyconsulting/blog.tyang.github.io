---
title: Configure PowerShell extension in VSCode on macOS
date: 2025-04-02 12:00
author: Tao Yang
permalink: /2025/04/02/2025-04-02-configure-powershell-vscode-on-macos
summary: Configure PowerShell extension in VSCode on macOS
categories:
  - MacOS
  - PowerShell
  - VSCode
tags:
  - MacOS
  - PowerShell
  - VSCode

---

I have 3 Mac computers running on the latest version of MacOS, and PowerShell is installed on all of them using Homebrew:

```bash
brew install powershell/tap/powershell
```
I also have VSCode and the PowerShell extension installed on all of them.

I noticed the other day that I wasn't able to get vscode to format PowerShell script on one of the Mac computers. I then tried on the other two and none of them worked. Looks like it's a common issue across all my Mac computers.

When I tried to format the script, I got the prompt to search and install a formatter.

![01](../../../../assets/images/2025/04/pwsh-vscode-mac-config-01.jpg)

To Troubleshoot this, I opened the integrated terminal in VSCode checked the output from PowerShell extension. I found the following error message:

![02](../../../../assets/images/2025/04/pwsh-vscode-mac-config-02.jpg)

It seems that VScode doesn't know the path to the PowerShell executable.

To fix it, I found the location in a terminal window using the `where` command:

![03](../../../../assets/images/2025/04/pwsh-vscode-mac-config-03.jpg)

Then configured the `powershell.powerShellAdditionalExePaths` setting in VSCode as the error message suggested and pointed it to the location of the PowerShell executable. I also followed [this instruction](https://learn.microsoft.com/en-us/powershell/scripting/dev-cross-plat/vscode/using-vscode?view=powershell-7.5#adding-your-own-powershell-paths-to-the-session-menu) and added `powershell.powerShellDefaultVersion` setting in the `settings.json` file.

![04](../../../../assets/images/2025/04/pwsh-vscode-mac-config-04.jpg)

After this, I restarted VSCode and opened the PowerShell script again. This time, I was able to format the script without any issues. The output from the integrated terminal also showed that the PowerShell extension was able to find the PowerShell executable.
![05](../../../../assets/images/2025/04/pwsh-vscode-mac-config-05.jpg)

Since I also have to use Windows and Ubuntu (WSL) for work, I don't want these settings to be sync'd to my Windows laptop because the PowerShell path would be different on Ubuntu and Windows. So I have configured the settings sync to ignore these settings in the `settings.json` file. I added the following lines to the `settings.json` file:

```json
"settingsSync.ignoredSettings": [
  "powershell.powerShellAdditionalExePaths",
  "powershell.powerShellDefaultVersion"
],
```

