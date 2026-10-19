# Copy Path Mini · 复制路径

**为本地 AI Agent 协作准备的超轻量 Windows 右键路径复制工具。**

[English](README.md) · [简体中文](README.zh-CN.md) · [下载安装包](https://github.com/vx790905119-svg/copy-path-mini/releases/latest) · [Agent 项目参考](AGENT_GUIDE.md)

![操作示意：右键文件，复制路径，再粘贴给本地 Agent。示意中的文件和路径均为虚构。](overview.svg)

使用 **Codex、Claude Code、Cursor、Cline** 或其他本地 AI 编程助手时，经常需要提供代码、日志、截图和文档的路径。Copy Path Mini 在 Windows 传统右键菜单靠前的位置加入“复制路径”，复制完整路径文本，不附加引号。

**右键 → 复制路径 → 粘贴给 Agent。** 无需为不同 Agent 安装插件。

## 下载和使用

**[下载 Windows 安装包 →](https://github.com/vx790905119-svg/copy-path-mini/releases/latest)**

1. 在发布页下载 `CopyPath-Setup-1.1.0.exe`，双击安装。
2. 右键**单个文件、单个文件夹或文件夹空白处**，选择“复制路径”。
3. 将路径粘贴到需要的位置。

**Windows 11** 如果没有直接显示，请先选择“显示更多选项”；本工具使用传统右键菜单入口。

```text
请帮我检查这个文件：
C:\work\demo\src\main.py
```

仓库中的路径和界面示例均为虚构，不包含个人文件。

## 为什么这么小？

| 关注点 | 实际行为 |
| --- | --- |
| 极小体积 | 核心程序 **5,632 字节**；v1.1.0 安装包约 **107 KiB** |
| 按需运行 | 点击后运行，复制完成即退出，**无后台常驻** |
| 完全本地 | **不联网、无遥测、无广告、无自动更新** |
| 安装简单 | Windows 10 / 11，**当前用户安装，无需管理员权限** |
| 路径可用 | 支持 Unicode，复制文本不加额外引号 |
| 中英文 | 安装界面和菜单名称支持英文、简体中文 |
| 可恢复 | 安装前备份已有同名菜单，卸载时恢复 |

## 适合哪些 Agent 工作？

- 将源代码文件的路径发给 AI 编程助手。
- 在本地 Agent 对话中提供日志、截图、PDF 或项目文件夹的位置。
- 右键文件夹空白处，复制当前文件夹自身的路径。
- 在其他支持粘贴文本的应用中使用路径。

这是 Windows 剪贴板工具，不是 Agent 插件、MCP 服务或文件读取授权工具。Agent 仍需自行取得读取对应文件的权限。

## 验证下载和源码构建

将文件哈希与同一发布页的 `SHA256SUMS.txt` 对照：

```powershell
Get-FileHash .\CopyPath-Setup-1.1.0.exe -Algorithm SHA256
```

个人工具安装包未做代码签名。可以选择源码构建，并保留正常的 Windows 安全防护。

准备 Windows 自带的 **.NET Framework C# 编译器**及 **[NSIS 3.13](https://nsis.sourceforge.io/)**，不需要 NuGet 依赖或额外运行时：

```powershell
powershell -ExecutionPolicy Bypass -File .\build.ps1
# NSIS 未加入 PATH 时：
.\build.ps1 -NsisCompiler C:\Tools\NSIS\makensis.exe
```

输出位于 `build/`。[Windows 构建检查](https://github.com/vx790905119-svg/copy-path-mini/actions/workflows/verify.yml)会构建程序和安装包，并在隔离位置验证中英文安装、卸载。

## 语言和卸载

安装时按 Windows 显示语言选择中英文，未匹配的语言回退到英文。可用 `/LANG=en` 或 `/LANG=zh-CN` 手动指定，也可重新运行安装包切换语言。

从 **Windows 设置 → 应用 → 复制路径** 卸载，或运行安装目录中的 `Uninstall.exe`。

## 已知边界

- 仅支持 Windows，不提供 macOS / Linux 版本。
- 面向单个项目复制，不支持批量路径复制。
- Windows 本身已有“复制文件地址/Copy as path”；本工具适合希望使用传统菜单靠前入口、复制无额外引号文本的用户。
- 剪贴板被其他程序持续占用时，请稍后重试；程序只做短暂重试，不驻留后台。
- 路径会进入 Windows 剪贴板，对外分享前请检查其中是否带有个人目录信息。

## 一起把小工具做好

采用 [MIT 许可证](LICENSE)，可免费使用、修改和分发。安装器组件保留其[第三方许可说明](THIRD-PARTY-LICENSES.txt)。

如果它帮你省了时间，欢迎 **[点个 Star](https://github.com/vx790905119-svg/copy-path-mini)**，方便以后找回。有可复现的问题或小改进建议，可[提交 Issue](https://github.com/vx790905119-svg/copy-path-mini/issues)或查看 [CONTRIBUTING.md](CONTRIBUTING.md)。请先将个人路径替换为虚构示例。
