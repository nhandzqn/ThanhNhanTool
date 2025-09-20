# menu.ps1

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

# ===== Helper function =====
function Pause-Script {
    Write-Host "Press Enter to continue..."
    while ($true) {
        $key = [System.Console]::ReadKey($true)
        if ($key.Key -eq "Enter") { break }
    }
}

# ===== Roblox termination =====
function Kill-Roblox {
    Write-Host "Closing Roblox processes..." -ForegroundColor Yellow
    $names = "RobloxPlayerBeta.exe","RobloxStudioBeta.exe","RobloxCrashHandler.exe"
    foreach ($n in $names) { taskkill /F /T /IM $n > $null 2>&1 }
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

# ===== Menu =====
function Show-Menu {
    Clear-Host
    Write-Host $banner -ForegroundColor Cyan
    Write-Host ""
    Write-Host "===== FUNCTION MENU ====="
    Write-Host "[1] Delete Roblox Data"
    Write-Host "[0] Exit"
    Write-Host "========================="
    Write-Host ""
}

# ===== Loop =====
:MENU while ($true) {
    Show-Menu
    $choice = (Read-Host "Enter your choice").Trim().ToLower()
    switch ($choice) {
        '1'   { Remove-Roblox; continue }
        '0'   { break MENU }
        'q'   { break MENU }
        'exit'{ break MENU }
        default { Write-Warning "Invalid choice"; Pause-Script }
    }
}
