# Claude Science on Windows

Windows-first helper repo for installing and running Claude Science through WSL 2.

Claude Science is currently a macOS/Linux app. On Windows, the supported path is to run the Linux build inside Windows Subsystem for Linux (WSL 2). This repo packages that flow into one PowerShell script, plus clear docs for first-time users.

## Download

Best option: download `claude-science-windows.zip` from the latest GitHub Release, unzip it, then run `ClaudeScience-Windows.cmd` or `ClaudeScience-Windows.ps1`.

If you do not want the full zip, download these two files from the repo or release:

- `ClaudeScience-Windows.ps1` - the real installer and launcher.
- `ClaudeScience-Windows.cmd` - optional double-click wrapper for people who do not want to open PowerShell first.

The `.cmd` file is only a convenience wrapper. The maintained logic is PowerShell because it gives better checks, errors, and Windows integration than a `.bat` file.

## Quick Start

Open PowerShell in the folder where you downloaded the file and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\ClaudeScience-Windows.ps1
```

Or double-click:

```text
ClaudeScience-Windows.cmd
```

The script will:

1. Check for WSL.
2. Install or verify Ubuntu 24.04.
3. Install Linux dependencies inside Ubuntu.
4. Run the official Claude Science installer.
5. Start Claude Science on `localhost:8765`.
6. Open the sign-in URL in your Windows browser.

## Requirements

- Windows 10 or Windows 11 with WSL 2 support.
- Ubuntu 24.04 in WSL. The script installs it if missing.
- A Claude account on a plan that includes Claude Science beta access.
- Team and Enterprise users may need an organization admin to enable Claude Science.
- Administrator approval may be needed once for WSL installation.

No Anthropic API key is required for Claude Science sign-in.

## Common Commands

```powershell
# Install and launch
.\ClaudeScience-Windows.ps1

# Launch after it is already installed
.\ClaudeScience-Windows.ps1 -Action start

# Print or open the current sign-in URL
.\ClaudeScience-Windows.ps1 -Action url

# Show whether Claude Science is running
.\ClaudeScience-Windows.ps1 -Action status

# Print the latest Claude Science log
.\ClaudeScience-Windows.ps1 -Action logs

# Stop Claude Science cleanly
.\ClaudeScience-Windows.ps1 -Action stop

# Check your setup
.\ClaudeScience-Windows.ps1 -Action doctor

# Update Claude Science
.\ClaudeScience-Windows.ps1 -Action update
```

Use another port if `8765` is already occupied:

```powershell
.\ClaudeScience-Windows.ps1 -Port 8799
```

## What Gets Installed

Inside WSL Ubuntu:

- `ca-certificates`
- `curl`
- `bubblewrap`
- `socat`
- Claude Science through `https://claude.ai/install-claude-science.sh`

Claude Science stores its app data in your WSL home directory under:

```text
~/.claude-science
```

Deleting that folder removes Claude Science projects, artifacts, and conversation history.

## Why WSL Instead Of A Native Windows Installer?

Anthropic does not currently ship a native Claude Science build for Windows. The official Windows path is WSL 2. A PowerShell launcher is the best Windows-native wrapper around that path because it can call WSL, check versions, open your browser, and print useful diagnostics.

## Documentation

- [Windows install guide](docs/windows-install.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Security and data notes](docs/security-and-data.md)
- [Uninstall and reset](docs/uninstall.md)
- [Publishing this repo to GitHub](docs/publishing-to-github.md)

## Official References

- Claude Science announcement: https://www.anthropic.com/news/claude-science-ai-workbench
- Claude Science get started: https://claude.com/docs/claude-science/get-started
- Run on Windows with WSL: https://claude.com/docs/claude-science/run-on-windows-wsl
- Claude Science command line settings: https://claude.com/docs/claude-science/command-line-settings

## Status

This repo is an unofficial helper around Anthropic's documented installation path. It does not bundle Claude Science and does not bypass Claude account, plan, or organization access requirements.

## Maintainers

Push a tag such as `v0.1.0` to create a GitHub Release asset automatically:

```powershell
git tag v0.1.0
git push origin main --tags
```
