# Copy Path · 复制路径

[English](README.md) | [简体中文](README.zh-CN.md)

本地 Agent 协作时，经常需要提供文件或文件夹路径。右键选择“复制路径”，就能快速复制完整路径，直接粘贴给 Agent。

**极度轻量、快捷**：核心程序约 **5.5 KB**，用完即退出，不常驻后台；不联网，不自动更新。

[下载 Windows 安装包](https://github.com/vx790905119-svg/copy-path-mini/releases/latest)，双击 `.exe` 安装即可。适用于 Windows 10 / 11，无需管理员权限。

安装界面和菜单名称按 Windows 显示语言自动选择英文或简体中文，其他语言回退到英文。Windows 11 若未直接显示该菜单，请选择“显示更多选项”。

卸载：**Windows 设置 → 应用 → 复制路径**。安装前已有的同名菜单会自动备份，卸载时恢复。

源码构建：准备 Windows 自带的 .NET Framework 编译器及 [NSIS 3.13](https://nsis.sourceforge.io/)，运行 `powershell -ExecutionPolicy Bypass -File .\build.ps1`。也可通过 `/LANG=en` 或 `/LANG=zh-CN` 指定安装语言。
