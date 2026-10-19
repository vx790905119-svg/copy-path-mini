# Contributing

Keep Copy Path Mini small, predictable, and easy to remove. Useful fixes and clear bug reports matter more than new features.

## Report an issue

Include Windows version, Copy Path version, setup language, expected behavior, actual behavior, and minimal reproduction steps. Replace real paths with examples such as `C:\work\demo\notes.md`.

Do not post personal email addresses, usernames, private folders, tokens, clipboard contents, or unredacted desktop screenshots. If a report involves private information, explain the issue without including the data itself.

## Propose a change

- Explain the user-visible benefit and keep the change focused.
- Preserve the no-network, no-background-process helper design.
- Keep English and Simplified Chinese installer strings in sync.
- Preserve existing-menu backups and clean uninstall behavior.
- Avoid adding a runtime package, a service, a scheduled task, or a framework bundle for a small convenience.
- Use a GitHub noreply address for commits if you do not want to publish your email.

## Verify

Build with `build.ps1` and NSIS 3.13. Run `Verify-Installer.ps1` with the compiler path. The verification uses a dedicated registry namespace and temporary installation folders, not your real Explorer menu.

The GitHub Windows build workflow performs the same source build and installer verification. If you change clipboard behavior, also test real copying on a desktop, including Unicode text, folder roots, a short clipboard lock, and copy/paste after the helper exits.
