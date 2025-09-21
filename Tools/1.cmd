@echo off
setlocal enabledelayedexpansion

:menu
cls
echo ================================
echo           TOOL MENU
echo ================================
echo [1] Delete Roblox Data
echo [2] Change MAC Address [requires Admin]
echo [0] Exit
echo.
set /p choice=Select option: 

if "%choice%"=="1" goto roblox
if "%choice%"=="2" goto mac
if "%choice%"=="0" goto :eof
goto menu

:roblox
cls
echo [*] Closing Roblox processes...
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
 "Get-Process RobloxPlayerBeta,RobloxStudioBeta,RobloxCrashHandler -ErrorAction SilentlyContinue ^| Stop-Process -Force"

echo [*] Deleting Roblox folders...
REM danh sach thu muc; bo sung neu can
set "paths=%LOCALAPPDATA%\Roblox;%LOCALAPPDATA%\Temp\Roblox;%APPDATA%\Roblox"
for %%D in (%paths%) do (
  if exist "%%~D" (
    echo   - Removing "%%~D"
    powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
     "Remove-Item -LiteralPath '%%~D' -Recurse -Force -ErrorAction SilentlyContinue"
  )
)
echo [+] Done.
echo.
pause
goto menu

:mac
cls
echo List of network adapters:
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
 "Get-NetAdapter ^| Sort-Object Name ^| Format-Table -Auto Name, Status, MacAddress"
echo.
set /p nic=Enter adapter Name (exact): 
if "%nic%"=="" goto menu

echo.
set /p newmac=Enter new MAC (12 hex, blank=random): 

if "%newmac%"=="" (
  REM sinh MAC ngau nhien, bit 2 set = 2 (locally administered)
  for /f %%A in ('powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
    "$r = -join ((1..10 ^|%% { '{0:X2}' -f (Get-Random -Min 0 -Max 256) }) -join '').Substring(0,10); '02'+$r"') do set newmac=%%A
)

REM remove separators if any
set newmac=%newmac:-=%
set newmac=%newmac::=%

REM validate length
if not "!newmac:~0,12!"=="" if "!newmac:~12,1!"=="" (
  echo [*] Applying MAC !newmac! to "%nic%" ...
) else (
  echo [!] Invalid MAC format. Expect 12 hex chars.
  pause
  goto menu
)

REM set Network Address via PowerShell
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
 "$name='%nic%'; $mac='%newmac%';" ^
 "Set-NetAdapterAdvancedProperty -Name $name -DisplayName 'Network Address' -DisplayValue $mac -NoRestart -ErrorAction Stop; " ^
 "Disable-NetAdapter -Name $name -Confirm:\$false; Start-Sleep -Seconds 1; Enable-NetAdapter -Name $name -Confirm:\$false; " ^
 "Write-Host ('[+] Successfully changed MAC for {0} -> {1}' -f $name,$mac)"

echo.
pause
goto menu
