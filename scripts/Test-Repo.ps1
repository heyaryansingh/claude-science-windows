#Requires -Version 5.1
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$requiredFiles = @(
  'README.md',
  'ClaudeScience-Windows.ps1',
  'ClaudeScience-Windows.cmd',
  'LICENSE',
  'SECURITY.md',
  'CONTRIBUTING.md',
  'docs/windows-install.md',
  'docs/troubleshooting.md',
  'docs/security-and-data.md',
  'docs/uninstall.md',
  'docs/publishing-to-github.md',
  '.github/workflows/validate.yml'
)

foreach ($relativePath in $requiredFiles) {
  $path = Join-Path $repoRoot $relativePath
  if (-not (Test-Path -LiteralPath $path)) {
    throw "Missing required file: $relativePath"
  }
}

$psFiles = Get-ChildItem -LiteralPath $repoRoot -Recurse -Filter '*.ps1' |
  Where-Object { $_.FullName -notmatch '\\dist\\' }

foreach ($file in $psFiles) {
  $tokens = $null
  $errors = $null
  [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$errors) | Out-Null

  if ($errors.Count -gt 0) {
    $messages = $errors | ForEach-Object { "$($_.Extent.File):$($_.Extent.StartLineNumber): $($_.Message)" }
    throw "PowerShell parse errors:`n$($messages -join "`n")"
  }
}

$readme = Get-Content -Raw -LiteralPath (Join-Path $repoRoot 'README.md')
foreach ($needle in @('ClaudeScience-Windows.ps1', 'WSL 2', 'Ubuntu 24.04', 'claude-science')) {
  if ($readme -notmatch [regex]::Escape($needle)) {
    throw "README is missing expected text: $needle"
  }
}

Write-Host 'Repository validation passed.'
