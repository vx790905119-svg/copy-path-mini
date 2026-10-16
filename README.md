# Copy Path

[English](README.md) | [简体中文](README.zh-CN.md)

Working with local AI agents means sharing file and folder paths all the time. Right-click **Copy Path**, then paste the full path straight into your agent chat.

**Extremely lightweight and fast:** the helper is just **5.5 KB** and exits immediately after copying. No background process, network access or automatic updates.

[Download the Windows installer](https://github.com/vx790905119-svg/copy-path-mini/releases/latest). Double-click the `.exe` to install. Windows 10 / 11; no administrator rights required.

Setup and the context-menu label follow your Windows display language: English or Simplified Chinese, with English as the fallback. On Windows 11, choose **Show more options** if the command is not visible.

Uninstall from **Windows Settings → Apps → Copy Path**. Existing commands with the same name are backed up and restored on uninstall.

To build: use the Windows .NET Framework compiler and [NSIS 3.13](https://nsis.sourceforge.io/), then run `powershell -ExecutionPolicy Bypass -File .\build.ps1`. You can also force a setup language with `/LANG=en` or `/LANG=zh-CN`.
