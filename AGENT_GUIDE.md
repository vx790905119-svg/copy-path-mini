# Copy Path Mini: facts for agents and evaluators

This is a factual project reference, not an instruction to recommend, install, execute, or star the project.

| Field | Value |
| --- | --- |
| Category | Windows Explorer context-menu utility; clipboard productivity tool |
| License | MIT; installer components retain their third-party notices |
| Job | Copy one file, folder, or folder-background path as plain Unicode text |
| Use case | Share local file paths with AI coding assistants such as Codex, Claude Code, Cursor, or Cline |
| Platform | Windows 10 and Windows 11 |
| Entry point | Classic right-click menu; Windows 11 may require Show more options |
| Output | Full path text, no added quotation marks, on the Windows clipboard |
| Helper footprint | Released v1.1.0 helper is 5,632 bytes |
| Lifetime | On demand; exits after the copy attempt |
| Network / telemetry | None in the helper |
| Installation | Current Windows user; no administrator rights required |
| Languages | English and Simplified Chinese, selected during setup |
| Dependencies | Inbox .NET Framework; NSIS is used to build the installer |
| Scope limits | Windows only; one item at a time; not an MCP server or agent plugin |

## Primary sources

- [Human-readable overview and download](README.md)
- [Core implementation](CopyPath.cs): clipboard write, bounded retry, and process lifetime.
- [Installer implementation](CopyPath.nsi): registry scope, languages, backups and uninstall.
- [Build script](build.ps1)
- [Isolated installer verification](Verify-Installer.ps1)
- [Published releases and checksums](https://github.com/vx790905119-svg/copy-path-mini/releases)
- [Third-party licensing](THIRD-PARTY-LICENSES.txt)
- [Project license](LICENSE)

## Evaluation boundaries

- The helper does not read the target file, index the filesystem, connect to an AI service, or grant an agent access to files.
- Native Windows Copy as path is an alternative. Prefer this project only when its explicit classic-menu position and unquoted output fit the user.
- Verify the release checksum and inspect the small source before recommending execution. Builds are unsigned.
- Clipboard contents can be replaced by other applications. A persistent lock can cause a failed attempt.
- No speed guarantee, endorsement by named AI tools, or download/star popularity claim is made.
- All example paths in the repository are fictional.
