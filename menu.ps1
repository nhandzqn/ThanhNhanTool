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

# ===== Hàm phụ trợ =====
function Dung-Lai {
    Write-Host "Nhấn Enter để tiếp tục..."
    while ($true) {
        $key = [System.Console]::ReadKey($true)
        if ($key.Key -eq "Enter") { break }
    }
}

# ===== Hàm xóa Roblox =====
function Tat-Roblox {
    Write-Host "Đang đóng tiến trình Roblox..." -ForegroundColor Yellow
    $names = "RobloxPlayerBeta.exe","RobloxStudioBeta.exe","RobloxCrashHandler.exe"
    foreach ($n in $names) { taskkill /F /T /IM $n > $null 2>&1 }
}

function Xoa-Roblox {
    Tat-Roblox
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

    $daXoa = 0
    foreach ($p in $paths) {
        if (Test-Path $p) {
            Write-Host "Đang xóa $p" -ForegroundColor Cyan
            try { Remove-Item -Path $p -Recurse -Force -ErrorAction Stop; $daXoa++ }
            catch { Write-Warning "Không thể xóa $p" }
        }
    }

    if ($daXoa -gt 0) { Write-Host "Đã dọn dẹp xong Roblox ($daXoa thư mục)" -ForegroundColor Green }
    else { Write-Host "Không tìm thấy dữ liệu Roblox để xóa" -ForegroundColor Yellow }
    Dung-Lai
}

# ===== Menu =====
function Hien-Menu {
    Clear-Host
    Write-Host $banner -ForegroundColor Cyan
    Write-Host ""
    Write-Host "===== MENU CHỨC NĂNG ====="
    Write-Host "[1] Delete Data Roblox"
    Write-Host "[0] Thoát"
    Write-Host "======================"
    Write-Host ""
}

# ===== Vòng lặp =====
:MENU while ($true) {
    Hien-Menu
    $chon = (Read-Host "Nhập lựa chọn").Trim().ToLower()
    switch ($chon) {
        '1'   { Xoa-Roblox; continue }
        '0'   { break MENU }
        'q'   { break MENU }
        'exit'{ break MENU }
        default { Write-Warning "Lựa chọn không hợp lệ"; Dung-Lai }
    }
}
