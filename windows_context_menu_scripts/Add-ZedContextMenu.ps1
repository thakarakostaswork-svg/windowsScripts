# Add "Open with Zed" to Windows Explorer context menus

$zedCommand = Get-Command zed.exe -ErrorAction SilentlyContinue

if ($zedCommand) {
    $zedPath = $zedCommand.Source
}
else {
    $possiblePaths = @(
        "$env:LOCALAPPDATA\Programs\Zed\Zed.exe",
        "$env:LOCALAPPDATA\Zed\Zed.exe",
        "$env:ProgramFiles\Zed\Zed.exe"
    )

    $zedPath = $possiblePaths |
        Where-Object { Test-Path $_ } |
        Select-Object -First 1
}

if (-not $zedPath) {
    Write-Host "Zed.exe could not be found." -ForegroundColor Red
    Write-Host "Edit this script and manually set `$zedPath to your Zed.exe location."
    exit 1
}

Write-Host "Found Zed:"
Write-Host $zedPath
Write-Host ""

# ----------------------------------------
# File context menu
# ----------------------------------------

$fileKey = "HKCU:\Software\Classes\*\shell\Zed"

New-Item -Path $fileKey -Force | Out-Null
Set-ItemProperty -Path $fileKey -Name "(Default)" -Value "Open with Zed"
Set-ItemProperty -Path $fileKey -Name "Icon" -Value $zedPath

New-Item -Path "$fileKey\command" -Force | Out-Null
Set-ItemProperty `
    -Path "$fileKey\command" `
    -Name "(Default)" `
    -Value "`"$zedPath`" `"%1`""


# ----------------------------------------
# Folder context menu
# ----------------------------------------

$folderKey = "HKCU:\Software\Classes\Directory\shell\Zed"

New-Item -Path $folderKey -Force | Out-Null
Set-ItemProperty -Path $folderKey -Name "(Default)" -Value "Open with Zed"
Set-ItemProperty -Path $folderKey -Name "Icon" -Value $zedPath

New-Item -Path "$folderKey\command" -Force | Out-Null
Set-ItemProperty `
    -Path "$folderKey\command" `
    -Name "(Default)" `
    -Value "`"$zedPath`" `"%1`""


# ----------------------------------------
# Folder background context menu
# ----------------------------------------

$backgroundKey = "HKCU:\Software\Classes\Directory\Background\shell\Zed"

New-Item -Path $backgroundKey -Force | Out-Null
Set-ItemProperty -Path $backgroundKey -Name "(Default)" -Value "Open with Zed"
Set-ItemProperty -Path $backgroundKey -Name "Icon" -Value $zedPath

New-Item -Path "$backgroundKey\command" -Force | Out-Null
Set-ItemProperty `
    -Path "$backgroundKey\command" `
    -Name "(Default)" `
    -Value "`"$zedPath`" `"%V`""


Write-Host ""
Write-Host "Open with Zed was added successfully." -ForegroundColor Green
Write-Host ""
Write-Host "On Windows 11 it may appear under:"
Write-Host "Right click -> Show more options -> Open with Zed"