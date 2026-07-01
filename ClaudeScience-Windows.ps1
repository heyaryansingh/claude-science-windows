#Requires -Version 5.1
<#
.SYNOPSIS
Installs, starts, and checks Claude Science on Windows through WSL 2.

.DESCRIPTION
Claude Science does not currently ship as a native Windows app. This script follows
Anthropic's WSL 2 setup path: Ubuntu 24.04, Linux dependencies, the official
Claude Science installer, and a localhost browser URL on Windows.

.EXAMPLE
.\ClaudeScience-Windows.ps1

Install dependencies, install Claude Science, start it, and open the browser.

.EXAMPLE
.\ClaudeScience-Windows.ps1 -Action doctor

Check whether Windows, WSL, Ubuntu, dependencies, and Claude Science look ready.
#>

[CmdletBinding()]
param(
  [ValidateSet('install', 'start', 'url', 'doctor', 'update', 'status', 'logs', 'stop')]
  [string]$Action = 'install',

  [ValidatePattern('^[A-Za-z0-9_.-]+$')]
  [string]$Distro = 'Ubuntu-24.04',

  [ValidateRange(1024, 65535)]
  [int]$Port = 8765,

  [switch]$NoBrowser,

  [switch]$SkipLaunch
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Info {
  param([string]$Message)
  Write-Host "[info] $Message" -ForegroundColor Cyan
}

function Write-Ok {
  param([string]$Message)
  Write-Host "[ ok ] $Message" -ForegroundColor Green
}

function Write-Warn {
  param([string]$Message)
  Write-Host "[warn] $Message" -ForegroundColor Yellow
}

function Write-Fail {
  param([string]$Message)
  Write-Host "[fail] $Message" -ForegroundColor Red
}

function Test-IsWindows {
  return [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform(
    [System.Runtime.InteropServices.OSPlatform]::Windows
  )
}

function Test-IsAdministrator {
  $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = [Security.Principal.WindowsPrincipal]::new($identity)
  return $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function Get-CommandPath {
  param([string]$Name)
  return (Get-Command $Name -ErrorAction SilentlyContinue | Select-Object -First 1).Source
}

function Get-WslDistributions {
  $raw = & wsl.exe -l -q 2>$null
  if ($LASTEXITCODE -ne 0) {
    return @()
  }

  return @(
    $raw |
      ForEach-Object { ($_ -replace "`0", '').Trim() } |
      Where-Object { $_.Length -gt 0 }
  )
}

function Get-WslListVerbose {
  $raw = & wsl.exe -l -v 2>$null
  if ($LASTEXITCODE -ne 0) {
    return ''
  }

  return (($raw | ForEach-Object { $_ -replace "`0", '' }) -join "`n")
}

function Invoke-WslBash {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Command,

    [switch]$AllowFailure
  )

  $output = & wsl.exe -d $Distro -- bash -lc $Command 2>&1
  $exitCode = $LASTEXITCODE
  $text = (($output | ForEach-Object { $_.ToString() }) -join "`n").Trim()

  if ($exitCode -ne 0 -and -not $AllowFailure) {
    throw "WSL command failed with exit code $exitCode.`n$text"
  }

  return [pscustomobject]@{
    ExitCode = $exitCode
    Text = $text
  }
}

function Assert-WindowsHost {
  if (-not (Test-IsWindows)) {
    throw 'This script must be run from Windows PowerShell or PowerShell on Windows.'
  }

  if (-not (Get-CommandPath 'wsl.exe')) {
    throw 'wsl.exe was not found. Use Windows 10/11 with Windows Subsystem for Linux available.'
  }
}

function Ensure-WslDistro {
  Assert-WindowsHost

  $distros = Get-WslDistributions
  if ($distros -contains $Distro) {
    Write-Ok "Found WSL distribution: $Distro"
  }
  else {
    Write-Warn "WSL distribution '$Distro' is not installed."
    if (-not (Test-IsAdministrator)) {
      Write-Warn 'WSL installation may ask for administrator approval or require a reboot.'
    }

    Write-Info "Installing $Distro with: wsl --install -d $Distro"
    & wsl.exe --install -d $Distro
    if ($LASTEXITCODE -ne 0) {
      throw "WSL could not install '$Distro'. Try running PowerShell as Administrator, then rerun this script."
    }

    Write-Host ''
    Write-Warn 'If Windows asked you to reboot, reboot now.'
    Write-Warn "After reboot, open '$Distro' from the Start Menu once and create your Linux username."
    Write-Warn 'Then run this script again.'
    exit 0
  }

  $verbose = Get-WslListVerbose
  $line = ($verbose -split "`n" | Where-Object { $_ -match "(^|\s)$([regex]::Escape($Distro))(\s|$)" } | Select-Object -First 1)
  if ($line -and $line -notmatch '\s2\s*$') {
    Write-Warn "$Distro is not listed as WSL version 2. Converting it to WSL 2."
    & wsl.exe --set-version $Distro 2
    if ($LASTEXITCODE -ne 0) {
      throw "Could not convert '$Distro' to WSL 2. Check 'wsl -l -v' manually."
    }
  }

  $probe = Invoke-WslBash -Command 'printf ready' -AllowFailure
  if ($probe.ExitCode -ne 0 -or $probe.Text -notmatch 'ready') {
    throw "Could not start '$Distro'. Open it from the Start Menu once, finish Linux user setup, then rerun this script."
  }
}

function Install-LinuxPrerequisites {
  Write-Info 'Installing Linux dependencies and Claude Science inside WSL. This can take a few minutes.'

  $bootstrap = @'
set -euo pipefail

if ! command -v sudo >/dev/null 2>&1; then
  echo "sudo is required inside this Ubuntu distribution."
  exit 1
fi

sudo apt-get update
sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl bubblewrap socat

export PATH="$HOME/.local/bin:$PATH"

if ! command -v claude-science >/dev/null 2>&1; then
  curl -fsSL https://claude.ai/install-claude-science.sh | bash
  export PATH="$HOME/.local/bin:$PATH"
fi

claude-science --version
'@

  $result = Invoke-WslBash -Command $bootstrap
  if ($result.Text) {
    Write-Host $result.Text
  }

  Write-Ok 'Claude Science is installed inside WSL.'
}

function Update-ClaudeScience {
  Write-Info 'Updating Claude Science inside WSL.'

  $command = @'
set -euo pipefail
export PATH="$HOME/.local/bin:$PATH"
if command -v claude-science >/dev/null 2>&1; then
  claude-science update
else
  curl -fsSL https://claude.ai/install-claude-science.sh | bash
  export PATH="$HOME/.local/bin:$PATH"
fi
claude-science --version
'@

  $result = Invoke-WslBash -Command $command
  if ($result.Text) {
    Write-Host $result.Text
  }
}

function Start-ClaudeScience {
  Write-Info "Starting Claude Science on localhost:$Port inside $Distro."

  $startCommand = 'export PATH="$HOME/.local/bin:$PATH"; claude-science serve --port {0} --no-browser --detached' -f $Port
  $start = Invoke-WslBash -Command $startCommand -AllowFailure

  if ($start.ExitCode -ne 0 -and $start.Text -notmatch 'already running') {
    throw "Claude Science did not start.`n$($start.Text)"
  }

  if ($start.Text) {
    Write-Host $start.Text
  }

  $url = Get-ClaudeScienceUrl
  if ($url) {
    Write-Ok 'Claude Science is running.'
    Write-Host ''
    Write-Host $url

    if (-not $NoBrowser) {
      Start-Process $url
    }
  }
  else {
    Write-Warn 'Claude Science started, but a sign-in URL was not available yet.'
    Write-Warn "Run: .\ClaudeScience-Windows.ps1 -Action url -Port $Port"
  }
}

function Get-ClaudeScienceUrl {
  for ($i = 1; $i -le 20; $i++) {
    $urlCommand = 'export PATH="$HOME/.local/bin:$PATH"; claude-science url'
    $result = Invoke-WslBash -Command $urlCommand -AllowFailure

    if ($result.Text) {
      $match = [regex]::Match($result.Text, 'https?://\S+')
      if ($match.Success) {
        return $match.Value.Trim()
      }
    }

    Start-Sleep -Seconds 1
  }

  return $null
}

function Show-ClaudeScienceUrl {
  $url = Get-ClaudeScienceUrl
  if (-not $url) {
    throw "No Claude Science URL is available. Start it first with '.\ClaudeScience-Windows.ps1 -Action start'."
  }

  Write-Host $url
  if (-not $NoBrowser) {
    Start-Process $url
  }
}

function Invoke-ClaudeScienceSimpleCommand {
  param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('status', 'logs', 'stop')]
    [string]$Command
  )

  $bashCommand = 'export PATH="$HOME/.local/bin:$PATH"; claude-science {0}' -f $Command
  $result = Invoke-WslBash -Command $bashCommand -AllowFailure
  if ($result.Text) {
    Write-Host $result.Text
  }

  if ($result.ExitCode -ne 0) {
    throw "claude-science $Command failed."
  }
}

function Test-InWslCommand {
  param([string]$Command)

  $bashCommand = 'export PATH="$HOME/.local/bin:$PATH"; command -v {0} >/dev/null 2>&1' -f $Command
  $result = Invoke-WslBash -Command $bashCommand -AllowFailure
  return $result.ExitCode -eq 0
}

function Invoke-Doctor {
  $failed = $false

  if (Test-IsWindows) {
    Write-Ok 'Running on Windows.'
  }
  else {
    Write-Fail 'This is not Windows.'
    $failed = $true
  }

  if (Get-CommandPath 'wsl.exe') {
    Write-Ok 'wsl.exe is available.'
  }
  else {
    Write-Fail 'wsl.exe is not available.'
    $failed = $true
  }

  if ($failed) {
    exit 1
  }

  $distros = Get-WslDistributions
  if ($distros -contains $Distro) {
    Write-Ok "Found $Distro."
  }
  else {
    Write-Fail "$Distro is not installed."
    Write-Info "Install it with: wsl --install -d $Distro"
    exit 1
  }

  $verbose = Get-WslListVerbose
  $line = ($verbose -split "`n" | Where-Object { $_ -match "(^|\s)$([regex]::Escape($Distro))(\s|$)" } | Select-Object -First 1)
  if ($line -and $line -match '\s2\s*$') {
    Write-Ok "$Distro is WSL 2."
  }
  else {
    Write-Fail "$Distro is not listed as WSL 2."
    Write-Info "Convert it with: wsl --set-version $Distro 2"
    $failed = $true
  }

  $probe = Invoke-WslBash -Command 'printf ready' -AllowFailure
  if ($probe.ExitCode -eq 0 -and $probe.Text -match 'ready') {
    Write-Ok "$Distro starts correctly."
  }
  else {
    Write-Fail "$Distro did not start correctly."
    $failed = $true
  }

  foreach ($command in @('curl', 'bwrap', 'socat')) {
    if (Test-InWslCommand $command) {
      Write-Ok "Found $command inside WSL."
    }
    else {
      Write-Fail "Missing $command inside WSL."
      $failed = $true
    }
  }

  if (Test-InWslCommand 'claude-science') {
    $version = Invoke-WslBash -Command 'export PATH="$HOME/.local/bin:$PATH"; claude-science --version' -AllowFailure
    Write-Ok "Found claude-science: $($version.Text)"
  }
  else {
    Write-Fail 'claude-science is not installed inside WSL.'
    $failed = $true
  }

  if ($failed) {
    Write-Host ''
    Write-Fail 'Doctor found one or more issues.'
    exit 1
  }

  Write-Host ''
  Write-Ok 'Doctor found no blocking issues.'
}

try {
  switch ($Action) {
    'install' {
      Ensure-WslDistro
      Install-LinuxPrerequisites
      if (-not $SkipLaunch) {
        Start-ClaudeScience
      }
    }
    'start' {
      Ensure-WslDistro
      Start-ClaudeScience
    }
    'url' {
      Ensure-WslDistro
      Show-ClaudeScienceUrl
    }
    'doctor' {
      Invoke-Doctor
    }
    'update' {
      Ensure-WslDistro
      Update-ClaudeScience
    }
    'status' {
      Ensure-WslDistro
      Invoke-ClaudeScienceSimpleCommand -Command 'status'
    }
    'logs' {
      Ensure-WslDistro
      Invoke-ClaudeScienceSimpleCommand -Command 'logs'
    }
    'stop' {
      Ensure-WslDistro
      Invoke-ClaudeScienceSimpleCommand -Command 'stop'
    }
  }
}
catch {
  Write-Host ''
  Write-Fail $_.Exception.Message
  Write-Host ''
  Write-Host 'Troubleshooting: https://claude.com/docs/claude-science/run-on-windows-wsl'
  exit 1
}
