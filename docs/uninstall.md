# Uninstall And Reset

Claude Science is installed inside WSL Ubuntu. This repo does not bundle a separate Windows app.

## Stop Claude Science

```powershell
.\ClaudeScience-Windows.ps1 -Action stop
```

## Remove Claude Science data

Claude Science stores projects, artifacts, configuration, and conversation history under:

```text
~/.claude-science
```

Deleting this folder is destructive. Back up anything important first.

From Ubuntu:

```bash
rm -rf ~/.claude-science
```

## Remove the Claude Science command

The official installer places `claude-science` under your Linux user files, usually in `~/.local/bin`.

From Ubuntu:

```bash
rm -f ~/.local/bin/claude-science
```

## Remove the WSL distribution

Only do this if you no longer need that Ubuntu distribution. This deletes the entire Linux environment, not just Claude Science.

From PowerShell:

```powershell
wsl --unregister Ubuntu-24.04
```
