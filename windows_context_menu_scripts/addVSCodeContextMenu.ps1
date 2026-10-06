# 1. Dynamically find the VS Code executable
$vsCodePaths = @(
    "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe",
    "$env:ProgramFiles\Microsoft VS Code\Code.exe",
    "${env:ProgramFiles(x86)}\Microsoft VS Code\Code.exe"
)
$codeExe = $vsCodePaths | Where-Object { Test-Path $_ } | Select-Object -First 1

# Check for Admin rights
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as an Administrator."
    break
}

if ($codeExe) {
    # 2. Define Registry Paths
    # Directory Background (right-click on empty space)
    $bgRegPath = "Registry::HKEY_CLASSES_ROOT\Directory\Background\shell\VSCode"
    $bgCmdPath = "$bgRegPath\command"
    
    # Directory (right-click ON a folder)
    $dirRegPath = "Registry::HKEY_CLASSES_ROOT\Directory\shell\VSCode"
    $dirCmdPath = "$dirRegPath\command"

    # 3. Create Background Menu Entry
    if (!(Test-Path $bgRegPath)) { New-Item -Path $bgRegPath -Force | Out-Null }
    New-ItemProperty -Path $bgRegPath -Name "MUIVerb" -Value "Open with Code" -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $bgRegPath -Name "Icon" -Value "$codeExe" -PropertyType String -Force | Out-Null
    
    if (!(Test-Path $bgCmdPath)) { New-Item -Path $bgCmdPath -Force | Out-Null }
    Set-ItemProperty -Path $bgCmdPath -Name "(Default)" -Value "`"$codeExe`" `"%V`"" -Force | Out-Null

    # 4. Create Folder Menu Entry
    if (!(Test-Path $dirRegPath)) { New-Item -Path $dirRegPath -Force | Out-Null }
    New-ItemProperty -Path $dirRegPath -Name "MUIVerb" -Value "Open with Code" -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $dirRegPath -Name "Icon" -Value "$codeExe" -PropertyType String -Force | Out-Null

    if (!(Test-Path $dirCmdPath)) { New-Item -Path $dirCmdPath -Force | Out-Null }
    Set-ItemProperty -Path $dirCmdPath -Name "(Default)" -Value "`"$codeExe`" `"%1`"" -Force | Out-Null

    Write-Host "Success! 'Open with Code' added to folder and background menus." -ForegroundColor Green
} else {
    Write-Error "VS Code (Code.exe) was not found in standard installation paths."
}