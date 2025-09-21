@echo off
:: --- Kiểm tra quyền admin ---
net session >nul 2>&1
if %errorLevel% neq 0 (
  echo Requesting admin...
  powershell -Command "Start-Process '%~f0' -Verb RunAs"
  exit /b
)

:menu
cls
echo.
echo $$$$$$$$\ $$\                           $$\             $$\   $$\ $$\                           
echo \__$$  __|$$ |                          $$ |            $$$\  $$ |$$ |                          
echo    $$ |   $$$$$$$\   $$$$$$\  $$$$$$$\  $$$$$$$\        $$$$\ $$ |$$$$$$$\   $$$$$$\  $$$$$$$\  
echo    $$ |   $$  __$$\  \____$$\ $$  __$$\ $$  __$$\       $$ $$\$$ |$$  __$$\  \____$$\ $$  __$$\ 
echo    $$ |   $$ |  $$ | $$$$$$$ |$$ |  $$ |$$ |  $$ |      $$ \$$$$ |$$ |  $$ | $$$$$$$ |$$ |  $$ |
echo    $$ |   $$ |  $$ |$$  __$$ |$$ |  $$ |$$ |  $$ |      $$ |\$$$ |$$ |  $$ |$$  __$$ |$$ |  $$ |
echo    $$ |   $$ |  $$ |\$$$$$$$ |$$ |  $$ |$$ |  $$ |      $$ | \$$ |$$ |  $$ |\$$$$$$$ |$$ |  $$ |
echo    \__|   \__|  \__| \_______|\__|  \__|\__|  \__|      \__|  \__|\__|  \__| \_______|\__|  \__|
echo.
echo ================================
echo           TOOL MENU
echo ================================
echo [1] Delete Roblox Data
echo [2] Change MAC Address
echo [0] Exit
echo.
set /p choice=Select option: 

if "%choice%"=="1" goto roblox
if "%choice%"=="2" goto mac
if "%choice%"=="0" exit
goto menu

:roblox
cls
echo [*] Closing Roblox processes...
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
 "Get-Process RobloxPlayerBeta,RobloxStudioBeta,RobloxCrashHandler -ErrorAction SilentlyContinue ^| Stop-Process -Force"

echo [*] Deleting Roblox folders...
set "paths=%LOCALAPPDATA%\Roblox;%LOCALAPPDATA%\Temp\Roblox;%APPDATA%\Roblox"
for %%D in (%paths%) do (
  if exist "%%~D" (
    echo   - Removing "%%~D"
    powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
     "Remove-Item -LiteralPath '%%~D' -Recurse -Force -ErrorAction SilentlyContinue"
  )
)
echo [+] Done.
pause
goto menu

:mac
cls
echo Current network adapters:
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
 "Get-NetAdapter ^| Sort-Object Name ^| Format-Table -Auto Name, Status, MacAddress"
echo.
set /p nic=Enter adapter Name (exact): 
if "%nic%"=="" goto menu

echo.
set /p newmac=Enter new MAC (12 hex, blank=random): 
if "%newmac%"=="" (
  for /f %%A in ('powershell -NoLogo -NoProfile -Command ^
    "$r=(-join ((1..5)|%%{ '{0:X2}' -f (Get-Random -Min 0 -Max 256)})); '02'+$r"') do set newmac=%%A
)

set newmac=%newmac:-=%
set newmac=%newmac::=%

if not "%newmac:~12,1%"=="" (
  echo [!] Invalid MAC format.
  pause
  goto menu
)

powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
 "$name='%nic%'; $mac='%newmac%';" ^
 "Set-NetAdapterAdvancedProperty -Name $name -DisplayName 'Network Address' -DisplayValue $mac -NoRestart; " ^
 "Disable-NetAdapter -Name $name -Confirm:\$false; Start-Sleep -Seconds 1; Enable-NetAdapter -Name $name -Confirm:\$false; " ^
 "Write-Host ('[+] Changed MAC for {0} -> {1}' -f $name,$mac)"

pause
goto menu
