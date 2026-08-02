$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

function Invoke-Step {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Action
    )

    Write-Host "`n=== $Name ===" -ForegroundColor Cyan
    & $Action
    if ($LASTEXITCODE -ne 0) {
        throw "$Name failed with exit code $LASTEXITCODE"
    }
}

Write-Host 'Shift Calendar Engine · Flutter Engineering Fleet' -ForegroundColor Green
Write-Host "Project: $root"

Invoke-Step 'Code 1 · Restore dependencies and generate localization' {
    flutter pub get
    flutter gen-l10n
}

Invoke-Step 'Code 2 · Verify formatting' {
    dart format --output=none --set-exit-if-changed .
}

Invoke-Step 'Code 3 · Analyze Flutter application' {
    flutter analyze
}

Invoke-Step 'Code 4 · Test application and workforce core' {
    flutter test --coverage
    Push-Location packages/workforce_core
    try {
        dart pub get
        dart analyze
        dart test
    }
    finally {
        Pop-Location
    }
}

Invoke-Step 'Build 1 · Web release' {
    flutter build web --release
}

Invoke-Step 'Build 2 · Android APK release' {
    flutter build apk --release
}

if ($IsWindows) {
    Invoke-Step 'Build 3 · Windows release' {
        flutter config --enable-windows-desktop
        flutter build windows --release
    }
}
else {
    Write-Host "`n=== Build 3 · Windows release ===" -ForegroundColor Yellow
    Write-Host 'Skipped: Windows build requires Windows.'
}

if ($IsLinux) {
    Invoke-Step 'Build 4 · Linux release' {
        flutter config --enable-linux-desktop
        flutter build linux --release
    }
}
else {
    Write-Host "`n=== Build 4 · Linux release ===" -ForegroundColor Yellow
    Write-Host 'Skipped locally: Linux build runs in GitHub Actions.'
}

Write-Host "`nEngineering fleet completed successfully." -ForegroundColor Green
