# Add "Open with Zed" to Windows Explorer context menu

$zed = Get-Command zed.exe -ErrorAction SilentlyContinue

if ($zed) {
    $zedPath = $zed.Source
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
    Write-Host "ERROR: Could not find zed.exe" -ForegroundColor Red
    exit 1
}

Write-Host "Using Zed:"
Write-Host $zedPath
Write-Host ""


function Add-ZedMenu {
    param (
        [string]$Key,
        [string]$Argument
    )

    New-Item -Path $Key -Force | Out-Null

    # Default menu text
    Set-Item -Path $Key -Value "Open with Zed"

    # Icon
    New-ItemProperty `
        -Path $Key `
        -Name "Icon" `
        -Value $zedPath `
        -PropertyType String `
        -Force | Out-Null

    # Command
    $commandKey = "$Key\command"

    New-Item -Path $commandKey -Force | Out-Null

    $command = "`"$zedPath`" `"$Argument`""

    Set-Item -Path $commandKey -Value $command

    Write-Host "Added: $Key"
}


# Right-click a file
Add-ZedMenu `
    "HKCU:\Software\Classes\*\shell\Zed" `
    "%1"


# Right-click a folder
Add-ZedMenu `
    "HKCU:\Software\Classes\Directory\shell\Zed" `
    "%1"


# Right-click empty space inside a folder
Add-ZedMenu `
    "HKCU:\Software\Classes\Directory\Background\shell\Zed" `
    "%V"


Write-Host ""
Write-Host "Registry entries added." -ForegroundColor Green

Write-Host "Restarting Windows Explorer..."

Stop-Process -Name explorer -Force

Start-Sleep -Seconds 1

Start-Process explorer.exe

Write-Host ""
Write-Host "Done."
Write-Host "On Windows 11 check:"
Write-Host "Right click -> Show more options -> Open with Zed"