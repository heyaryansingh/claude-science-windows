#Requires -Version 5.1
[CmdletBinding()]
param(
  [string]$OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$dist = Join-Path $repoRoot 'dist'
if (-not (Test-Path -LiteralPath $dist)) {
  New-Item -ItemType Directory -Path $dist | Out-Null
}

if (-not $OutputPath) {
  $OutputPath = Join-Path $dist 'claude-science-windows.zip'
}

if (Test-Path -LiteralPath $OutputPath) {
  Remove-Item -LiteralPath $OutputPath -Force
}

$packageName = 'claude-science-windows'
$staging = Join-Path $dist $packageName
if (Test-Path -LiteralPath $staging) {
  Remove-Item -LiteralPath $staging -Recurse -Force
}

New-Item -ItemType Directory -Path $staging | Out-Null

$items = @(
  'ClaudeScience-Windows.ps1',
  'ClaudeScience-Windows.cmd',
  'README.md',
  'LICENSE',
  'SECURITY.md',
  'CHANGELOG.md',
  'docs/windows-install.md',
  'docs/troubleshooting.md',
  'docs/security-and-data.md',
  'docs/uninstall.md'
)

foreach ($item in $items) {
  $source = Join-Path $repoRoot $item
  $destination = Join-Path $staging $item
  $destinationDirectory = Split-Path -Parent $destination

  if (-not (Test-Path -LiteralPath $destinationDirectory)) {
    New-Item -ItemType Directory -Path $destinationDirectory -Force | Out-Null
  }

  Copy-Item -LiteralPath $source -Destination $destination
}

Compress-Archive -Path $staging -DestinationPath $OutputPath -Force
Remove-Item -LiteralPath $staging -Recurse -Force

Write-Host "Wrote $OutputPath"
