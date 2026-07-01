# Troubleshooting

Run the built-in checks first:

```powershell
.\ClaudeScience-Windows.ps1 -Action doctor
```

## `wsl.exe was not found`

Install Windows Subsystem for Linux:

```powershell
wsl --install -d Ubuntu-24.04
```

Reboot if Windows asks.

## Ubuntu opens and asks for a username

That is expected on first install. Create a Linux username and password, close Ubuntu, then rerun:

```powershell
.\ClaudeScience-Windows.ps1
```

## `bwrap too old`

Use Ubuntu 24.04 or newer. Ubuntu 22.04 ships an older `bubblewrap` than Claude Science needs.

Check your distro:

```powershell
wsl -l -v
```

Install Ubuntu 24.04:

```powershell
wsl --install -d Ubuntu-24.04
```

## `daemon already running on port 8765`

Claude Science is already running. Print a fresh URL:

```powershell
.\ClaudeScience-Windows.ps1 -Action url
```

Or use another port:

```powershell
.\ClaudeScience-Windows.ps1 -Action start -Port 8799
```

## Browser opens but sign-in fails

Common causes:

- Your Claude account does not have Claude Science beta access.
- Your organization has not enabled Claude Science.
- The one-time URL expired. Run `.\ClaudeScience-Windows.ps1 -Action url`.
- Custom WSL networking or firewall settings are blocking `localhost`. Check `.\ClaudeScience-Windows.ps1 -Action status` for the port, then inspect your WSL networking configuration.

## `claude-science: command not found`

Reload the WSL profile or rerun the installer:

```powershell
.\ClaudeScience-Windows.ps1 -Action update
```

The script also adds `~/.local/bin` to PATH for each command it runs.

## Need logs

Run:

```powershell
.\ClaudeScience-Windows.ps1 -Action logs
```

For live log following, open Ubuntu and run:

```bash
claude-science logs --tail
```

## Resetting Claude Science data

Claude Science stores projects, artifacts, and history under `~/.claude-science` in your WSL home directory. Deleting that folder removes that data.

The repo does not automate deletion because it is destructive. If you intentionally want to remove the data, do it manually inside Ubuntu after backing up anything important.
