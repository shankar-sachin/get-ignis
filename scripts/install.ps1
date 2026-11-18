<#
.SYNOPSIS
Bouncer Ignis is not available for Windows yet.

.DESCRIPTION
Bouncer Ignis ships for macOS on Apple silicon only. This script prints that and the releases link, then
exits with code 1. It takes the same parameters the Bouncer installer does (-Version, -DryRun) so it can
grow into a real installer when a Windows build exists.

.PARAMETER Version
Ignored for now. Will install a specific version, e.g. v0.2.0.

.PARAMETER DryRun
Ignored for now. Will print what would happen and change nothing.

.EXAMPLE
irm https://bouncer-ai.pages.dev/ignis/install.ps1 | iex
#>
[CmdletBinding()]
param(
    [string]$Version = $env:IGNIS_VERSION,
    [switch]$DryRun
)

$Repo = 'shankar-sachin/get-ignis'

Write-Host "Bouncer Ignis is not available for Windows yet."
Write-Host "It runs on macOS with Apple silicon today. Intel Macs, Windows and Linux are planned."
Write-Host "Watch https://github.com/$Repo/releases for new builds."
Write-Host "Bouncer, the full app, runs on Windows: https://bouncer-ai.pages.dev"

# Under `irm | iex`, `exit` would close the PowerShell window, so only exit when this is a script file.
if ($PSCommandPath) {
    exit 1
}
$global:LASTEXITCODE = 1
