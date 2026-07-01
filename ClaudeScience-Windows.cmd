@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "SCRIPT=%SCRIPT_DIR%ClaudeScience-Windows.ps1"

if not exist "%SCRIPT%" (
  echo Could not find "%SCRIPT%".
  echo Keep ClaudeScience-Windows.cmd beside ClaudeScience-Windows.ps1.
  pause
  exit /b 1
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -NoExit -File "%SCRIPT%" %*
