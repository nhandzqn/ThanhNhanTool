# ===== Safety & TLS =====
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Host "PowerShell quá cũ ($($PSVersionTable.PSVersion)). Cần 5.1+." -ForegroundColor Red
    Pause
    exit 1
}
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# ===== Banner =====
$banner = @'
$$$$$$$$\ $$\                           $$\             $$\   $$\ $$\                           
\__$$  __|$$ |                          $$ |            $$$\  $$ |$$ |                          
   $$ |   $$$$$$$\   $$$$$$\  $$$$$$$\  $$$$$$$\        $$$$\ $$ |$$$$$$$\   $$$$$$\  $$$$$$$\  
   $$ |   $$  __$$\  \____$$\ $$  __$$\ $$  __$$\       $$ $$\$$ |$$  __$$\  \____$$\ $$  __$$\ 
   $$ |   $$ |  $$ | $$$$$$$ |$$ |  $$ |$$ |  $$ |      $$ \$$$$ |$$ |  $$ | $$$$$$$ |$$ |  $$ |
   $$ |   $$ |  $$ |$$  __$$ |$$ |  $$ |$$ |  $$ |      $$ |\$$$ |$$ |  $$ |$$  __$$ |$$ |  $$ |
   $$ |   $$ |  $$ |\$$$$$$$ |$$ |  $$ |$$ |  $$ |      $$ | \$$ |$$ |  $$ |\$$$$$$$ |$$ |  $$ |
   \__|   \__|  \__| \_______|\__|  \__|\__|  \__|      \__|  \__|\__|  \__| \_______|\__|  \__|
'@

function Pause-Script {
    Write-Host "Press Enter to continue..."
    while ($true) { $k=[Console]::ReadKey($true); if ($k.Key -eq "Enter"){ break } }
}

function Kill-Roblox {
    Write-Host "Closing Roblox processes..." -ForegroundColor Yellow
    "RobloxPlayerBeta.exe","RobloxStudioBeta.exe","RobloxCrashHandler.exe" | ForEach-Object {
        taskkill /F /T /IM $_ > $null 2>&1
    }
}

function Remove-Roblox {
    Kill-Roblox
    $paths = @(
        "$env:LOCALAPPDATA\Roblox",
        "$env:LOCALAPPDATA\Temp\Roblox",
        "$env:ProgramFiles\Roblox",
        "$env:ProgramFiles(x86)\Roblox"
    )
    $pkgRoot = "$env:LOCALAPPDATA\Packages"
    if (Test-Path $pkgRoot) {
        Get-ChildItem $pkgRoot -Directory |
            Where-Object { $_.Name -like "ROBLOXCORPORATION.ROBLOX*" } |
            ForEach-Object {
                $paths += "$($_.FullName)\LocalCache"
                $paths += "$($_.FullName)\LocalState"
                $paths += "$($_.FullName)\TempState"
            }
    }
    $deleted = 0
    foreach ($p in $paths) {
        if (Test-Path $p) {
            Write-Host "Deleting $p" -ForegroundColor Cyan
            try { Remove-Item -Path $p -Recurse -Force -ErrorAction Stop; $deleted++ }
            catch { Write-Warning "Unable to delete $p" }
        }
    }
    if ($deleted -gt 0) { Write-Host "Roblox cleanup completed ($deleted folders)" -ForegroundColor Green }
    else { Write-Host "No Roblox data found to delete" -ForegroundColor Yellow }
    Pause-Script
}

function Show-Menu {
    Clear-Host
    Write-Host $banner -ForegroundColor Cyan
    Write-Host ""
    Write-Host "===== MENU TOOLS ====="
    Write-Host "[1] Delete Roblox Data"
    Write-Host "======================"
    Write-Host ""
}

:MENU while ($true) {
    Show-Menu
    $choice = (Read-Host "Enter your choice").Trim().ToLower()
    switch ($choice) {
        '1'    { Remove-Roblox; continue }
        default { Write-Warning "Invalid choice"; Pause-Script }
    }
}
