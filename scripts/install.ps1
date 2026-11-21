<#
.SYNOPSIS
Installs Bouncer Ignis on Windows (x64) from the public releases at shankar-sachin/get-ignis.

.DESCRIPTION
Downloads Bouncer-Ignis-Setup-<version>-x64.exe, checks it against the release's SHA256SUMS and runs it
silently. The installer is per user (no admin): it puts Bouncer Ignis in %LOCALAPPDATA%\Programs\Bouncer Ignis,
adds it to the Start menu and puts the ignis and bi commands on your PATH.

With -CliOnly it downloads ignis-cli-<version>-windows-x64.zip instead and installs just ignis.exe and bi.exe
into %LOCALAPPDATA%\Programs\Bouncer Ignis\cli, on your PATH. No app.

No login needed. GH_TOKEN or GITHUB_TOKEN, when set, raises GitHub's API rate limit.

.PARAMETER Version
Install a specific release: v0.5.0, ignis-v0.5.0 or 0.5.0 (default: the newest). IGNIS_VERSION does the same.

.PARAMETER CliOnly
Install only the ignis and bi commands.

.PARAMETER DryRun
Look up the release and print what would happen. Nothing is downloaded or changed.

.EXAMPLE
irm https://bouncer-ai.pages.dev/ignis/install.ps1 | iex

.EXAMPLE
& ([scriptblock]::Create((irm https://bouncer-ai.pages.dev/ignis/install.ps1))) -DryRun
#>
[CmdletBinding()]
param(
    [string]$Version = $env:IGNIS_VERSION,
    [switch]$CliOnly,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$Repo = 'shankar-sachin/get-ignis'
$Api = "https://api.github.com/repos/$Repo"
$ReleasesUrl = "https://github.com/$Repo/releases"

function Stop-Install([string]$Message) {
    Write-Host "install.ps1: error: $Message" -ForegroundColor Red
    # Under `irm | iex`, `exit` would close the PowerShell window, so only exit when this is a script file.
    if ($PSCommandPath) { exit 1 }
    $global:LASTEXITCODE = 1
    throw $Message
}

function Write-Step([string]$Message) { Write-Host "==> $Message" }

function Get-Headers([string]$Accept) {
    $h = @{ Accept = $Accept; 'User-Agent' = 'bouncer-ignis-installer' }
    $token = if ($env:GH_TOKEN) { $env:GH_TOKEN } else { $env:GITHUB_TOKEN }
    if ($token) { $h.Authorization = "Bearer $token" }
    $h
}

function Invoke-Api([string]$Path) {
    try {
        Invoke-RestMethod -Uri "$Api/$Path" -Headers (Get-Headers 'application/vnd.github+json')
    } catch {
        Stop-Install "GitHub API request failed: $Path (no such release, or the API rate limit; set GH_TOKEN to raise it)"
    }
}

function Save-Asset($Asset, [string]$Path) {
    Invoke-WebRequest -Uri $Asset.url -Headers (Get-Headers 'application/octet-stream') -OutFile $Path
    Write-Step "downloaded $($Asset.name)"
}

if ([Environment]::OSVersion.Platform -ne 'Win32NT') {
    Stop-Install 'This installer is for Windows. On macOS and Linux use install.sh.'
}
if (-not [Environment]::Is64BitOperatingSystem) {
    Stop-Install "Bouncer Ignis needs 64-bit Windows. See $ReleasesUrl"
}
if ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64') {
    Write-Host 'note: this is Windows on Arm; the x64 build runs under emulation.'
}

if ($DryRun) { Write-Step 'dry run: the release is looked up, nothing is downloaded or changed' }
Write-Step "repository: $Repo"

if ($Version) {
    $tag = if ($Version -like 'ignis-v*') { $Version } elseif ($Version -like 'v*') { "ignis-$Version" } else { "ignis-v$Version" }
} else {
    $list = Invoke-Api 'releases?per_page=30'
    $tag = ($list | Where-Object { -not $_.draft -and -not $_.prerelease -and $_.tag_name -like 'ignis-v*' } |
        Select-Object -First 1).tag_name
    if (-not $tag) { Stop-Install "Bouncer Ignis has no published release yet. Watch $ReleasesUrl" }
}
$release = Invoke-Api "releases/tags/$tag"
$ver = $tag.Substring('ignis-v'.Length)
Write-Step "release: $tag (windows x64)"

$name = if ($CliOnly) { "ignis-cli-$ver-windows-x64.zip" } else { "Bouncer-Ignis-Setup-$ver-x64.exe" }
$asset = $release.assets | Where-Object { $_.name -eq $name } | Select-Object -First 1
if (-not $asset) {
    Stop-Install "$tag has no Windows build named $name. Available: $(($release.assets | ForEach-Object name) -join ' ')"
}
$sums = $release.assets | Where-Object { $_.name -eq 'SHA256SUMS' } | Select-Object -First 1
if (-not $sums) { Stop-Install "$tag has no SHA256SUMS asset, so $name can't be verified. Nothing was installed." }

$programs = Join-Path $env:LOCALAPPDATA 'Programs\Bouncer Ignis'
$cliDir = Join-Path $programs 'cli'
if ($DryRun) {
    Write-Host "would download: $name and SHA256SUMS"
    Write-Host 'would verify: SHA-256 against SHA256SUMS (stops on a mismatch)'
    if ($CliOnly) {
        Write-Host "would install: $cliDir\ignis.exe and bi.exe, and add $cliDir to your PATH"
    } else {
        Write-Host "would run: $name /S (per user, into $programs, Start menu entry, ignis and bi on your PATH)"
    }
    Write-Host 'would not ask for admin rights'
    Write-Host 'dry run: nothing was downloaded or installed'
    return
}

$tmp = Join-Path ([IO.Path]::GetTempPath()) ("ignis-install-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tmp | Out-Null
try {
    $file = Join-Path $tmp $name
    Save-Asset $asset $file
    Save-Asset $sums (Join-Path $tmp 'SHA256SUMS')
    $expected = Get-Content (Join-Path $tmp 'SHA256SUMS') | ForEach-Object {
        $parts = $_ -split '\s+', 2
        if ($parts.Count -eq 2 -and $parts[1].TrimStart('*') -eq $name) { $parts[0].ToLower() }
    } | Select-Object -First 1
    if (-not $expected) { Stop-Install "SHA256SUMS has no entry for $name" }
    $actual = (Get-FileHash -Algorithm SHA256 $file).Hash.ToLower()
    if ($expected -ne $actual) { Stop-Install "checksum mismatch for $name (expected $expected, got $actual)" }
    Write-Step "sha256 verified for $name"

    if ($CliOnly) {
        $existing = Join-Path $cliDir 'ignis.exe'
        if (Test-Path $existing) { & $existing stop *> $null }
        Expand-Archive -Path $file -DestinationPath (Join-Path $tmp 'cli') -Force
        $ignis = Get-ChildItem -Path (Join-Path $tmp 'cli') -Recurse -Filter 'ignis.exe' | Select-Object -First 1
        $bi = Get-ChildItem -Path (Join-Path $tmp 'cli') -Recurse -Filter 'bi.exe' | Select-Object -First 1
        if (-not $ignis -or -not $bi) { Stop-Install "ignis.exe and bi.exe were not found inside $name" }
        New-Item -ItemType Directory -Path $cliDir -Force | Out-Null
        Copy-Item $ignis.FullName, $bi.FullName -Destination $cliDir -Force
        $path = [Environment]::GetEnvironmentVariable('Path', 'User')
        if (-not $path) { $path = '' }
        if (-not (($path -split ';') -contains $cliDir)) {
            [Environment]::SetEnvironmentVariable('Path', (($path.TrimEnd(';') + ';' + $cliDir).TrimStart(';')), 'User')
            Write-Step "added $cliDir to your PATH (open a new terminal to use it)"
        }
        Write-Step "installed ignis and bi in $cliDir"
    } else {
        Write-Step 'running the installer'
        $p = Start-Process -FilePath $file -ArgumentList '/S' -Wait -PassThru
        if ($p.ExitCode -ne 0) { Stop-Install "the installer stopped with code $($p.ExitCode)" }
        Write-Step "installed Bouncer Ignis in $programs"
        Write-Host 'Open it from the Start menu. In a new terminal: ignis --help, or bi "hello".'
    }
} finally {
    Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
}
