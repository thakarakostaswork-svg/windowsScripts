# Dynamically resolve the path using the LocalAppData environment variable
$basePath = "$env:LOCALAPPDATA\Programs\Antigravity\_"
$exePath = "$basePath\Antigravity.exe"

# Elevation check
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run PowerShell as Administrator to modify the Registry."
    exit 1
}

# Verify the file exists before making registry changes
if (-not (Test-Path $exePath)) {
    Write-Error "Could not find Antigravity.exe at '$exePath'. Please check the installation."
    exit 1
}

# Define all three context menu targets
$contexts = @(
    @{
        RegistryPath = "Registry::HKEY_CLASSES_ROOT\*\shell\Antigravity"
        Command      = "`"$exePath`" `"%1`""
        Label        = "files"
    },
    @{
        RegistryPath = "Registry::HKEY_CLASSES_ROOT\Directory\shell\Antigravity"
        Command      = "`"$exePath`" `"%1`""
        Label        = "folders"
    },
    @{
        RegistryPath = "Registry::HKEY_CLASSES_ROOT\Directory\Background\shell\Antigravity"
        Command      = "`"$exePath`" `"%V`""
        Label        = "folder background"
    }
)

foreach ($ctx in $contexts) {
    $regPath = $ctx.RegistryPath
    $cmdPath = "$regPath\command"

    # Create the menu entry key if it doesn't exist
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    Set-ItemProperty -Path $regPath -Name "(Default)" -Value "Open with Antigravity"
    Set-ItemProperty -Path $regPath -Name "Icon"      -Value $exePath

    # Create the command key if it doesn't exist
    if (-not (Test-Path $cmdPath)) {
        New-Item -Path $cmdPath -Force | Out-Null
    }
    Set-ItemProperty -Path $cmdPath -Name "(Default)" -Value $ctx.Command

    Write-Host "Registered for $($ctx.Label)" -ForegroundColor Green
}

Write-Host "`nAntigravity successfully registered for all contexts at: $exePath" -ForegroundColor Cyan