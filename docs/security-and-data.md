# Security And Data Notes

This repo is a wrapper around Anthropic's documented installer. It does not contain or redistribute Claude Science.

## What the script runs

On Windows:

- `wsl.exe`
- `Start-Process` to open the local browser URL

Inside Ubuntu:

- `sudo apt-get update`
- `sudo apt-get install -y ca-certificates curl bubblewrap socat`
- `curl -fsSL https://claude.ai/install-claude-science.sh | bash`
- `claude-science serve --port 8765 --no-browser --detached`
- `claude-science url`
- `claude-science status`
- `claude-science logs`
- `claude-science stop`
- `claude-science update`

## Account and secrets

- No Anthropic API key is needed for normal Claude Science sign-in.
- Do not paste API keys, patient data, lab credentials, or SSH private keys into GitHub issues.
- Team and Enterprise users should follow their organization's Claude Science admin policy.

## Local data

Claude Science data lives in your WSL home directory under:

```text
~/.claude-science
```

That folder can contain projects, artifacts, and conversation history. Treat it as private research data.

## Network access

The installer downloads Claude Science from `https://claude.ai/install-claude-science.sh`. Claude Science itself may access services and connectors that you enable during setup.

Review connector and network choices during the Claude Science setup wizard.
