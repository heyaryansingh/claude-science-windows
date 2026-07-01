# Publishing To GitHub

This repo is ready to push as a normal GitHub repository.

## Create the local commit

```powershell
git init
git add .
git commit -m "Initial Claude Science Windows helper"
```

## Create a GitHub repo

With GitHub CLI:

```powershell
gh repo create claude-science-windows --public --source . --remote origin --push
```

Without GitHub CLI:

1. Create a new empty repository on GitHub named `claude-science-windows`.
2. Copy the commands GitHub shows for pushing an existing local repo.
3. Run those commands from this folder.

## Create a release zip

```powershell
.\scripts\New-ReleaseZip.ps1
```

Upload `dist\claude-science-windows.zip` as a GitHub Release asset.

Recommended release text:

```text
Windows helper for Claude Science through WSL 2.

Download:
- claude-science-windows.zip for the complete helper package.
- ClaudeScience-Windows.ps1 if you only want the one-file installer.
```

## Suggested repo description

```text
Windows PowerShell helper for installing and running Claude Science through WSL 2.
```
