# Contributing

Thanks for improving the Windows helper.

## Development checks

Run:

```powershell
.\scripts\Test-Repo.ps1
```

This validates PowerShell syntax and required repo files. It does not install WSL or Claude Science.

## Pull request guidelines

- Keep the PowerShell script dependency-free.
- Do not bundle Claude Science binaries.
- Prefer official Claude Science docs as the source of truth.
- Keep destructive data operations out of the script unless they require an explicit confirmation flag.
- Keep beginner-facing instructions in the README and detailed edge cases in `docs/`.
