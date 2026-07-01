# Windows Install Guide

This is the expanded version of the quick start.

## 1. Download the helper

Download `ClaudeScience-Windows.ps1` from this repo or from a GitHub release.

If you want a double-click path, download `ClaudeScience-Windows.cmd` into the same folder.

## 2. Run the installer

From PowerShell:

```powershell
cd "$env:USERPROFILE\Downloads\claude-science-windows"
powershell -ExecutionPolicy Bypass -File .\ClaudeScience-Windows.ps1
```

Or double-click `ClaudeScience-Windows.cmd`.

## 3. Finish WSL setup if prompted

If Ubuntu 24.04 is not installed, Windows may install it and then ask for a reboot.

After reboot:

1. Open `Ubuntu 24.04` from the Start Menu.
2. Create a Linux username and password.
3. Close Ubuntu.
4. Run `ClaudeScience-Windows.ps1` again.

## 4. Sign in

When the script starts Claude Science, it prints and opens a local URL. Sign in with your Claude account and complete the Claude Science setup wizard.

The URL contains a one-time sign-in token. If the browser tab is closed or expires, run:

```powershell
.\ClaudeScience-Windows.ps1 -Action url
```

## 5. Start later

After setup, start Claude Science again with:

```powershell
.\ClaudeScience-Windows.ps1 -Action start
```

If you close WSL or run `wsl --shutdown`, Claude Science stops. Run the start command again when needed.

## 6. Stop, check, or update

```powershell
# Check whether it is running
.\ClaudeScience-Windows.ps1 -Action status

# Stop it cleanly
.\ClaudeScience-Windows.ps1 -Action stop

# Show the latest log
.\ClaudeScience-Windows.ps1 -Action logs

# Update Claude Science
.\ClaudeScience-Windows.ps1 -Action update
```

## Optional flags

```powershell
# Do setup but do not launch Claude Science
.\ClaudeScience-Windows.ps1 -SkipLaunch

# Use a different WSL distro name
.\ClaudeScience-Windows.ps1 -Distro Ubuntu-24.04

# Use a different localhost port
.\ClaudeScience-Windows.ps1 -Port 8799

# Do not auto-open the browser
.\ClaudeScience-Windows.ps1 -NoBrowser
```
