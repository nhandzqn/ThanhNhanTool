# ================= CONFIG =================
param(
  [string]$Url = "https://raw.githubusercontent.com/nhandzqn/ThanhNhanTool/refs/heads/main/Tools/1.cmd",
  [switch]$PauseAfter           # thêm & pause để xem lỗi nếu tool đóng nhanh
)

$ErrorActionPreference = 'Stop'
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

# ================ SELF-ELEVATE ================
function Test-Admin {
  return [Security.Principal.WindowsPrincipal]([Security.Principal.WindowsIdentity]::GetCurrent()).
    IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}
if (-not (Test-Admin)) {
  # mở lại chính file này bằng quyền admin và truyền lại tham số
  $psArgs = @()
  if ($Url)       { $psArgs += "-Url `"$Url`"" }
  if ($PauseAfter){ $psArgs += "-PauseAfter" }
  Start-Process -FilePath "powershell.exe" -Verb RunAs `
    -ArgumentList "-NoLogo -NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $($psArgs -join ' ')" `
    -WindowStyle Normal
  exit
}

# ================ DOWNLOAD ================
$IsAdmin = Test-Admin
$TempDir = if ($IsAdmin) { "$env:SystemRoot\Temp" } else { "$env:TEMP" }
$TempName = "tool_{0}.cmd" -f ([guid]::NewGuid().Guid.Substring(0,8))
$TempFile = Join-Path $TempDir $TempName

Write-Host "[*] Downloading: $Url"
$content = Invoke-RestMethod -Uri $Url -Method Get -MaximumRedirection 5

if ([string]::IsNullOrWhiteSpace($content)) {
  throw "Download empty content from $Url"
}

# Ghi ASCII để tránh BOM (UTF-16 làm CMD lỗi)
# Bảo đảm CRLF để batch đọc chuẩn
$norm = ($content -replace "`r?`n","`r`n")
Set-Content -Path $TempFile -Value $norm -Encoding Ascii

if (-not (Test-Path $TempFile)) { throw "Failed to create temp file: $TempFile" }

# ================ RUN CMD ================
$ComSpec = "$env:SystemRoot\System32\cmd.exe"
# Quote chuẩn: /c "<file>" [và & pause nếu cần]
$cmdArg = if ($PauseAfter) { "/c `"$TempFile`" & pause" } else { "/c `"$TempFile`"" }

Write-Host "[*] Launching CMD: $ComSpec $cmdArg"
try {
  # Dùng chính tiến trình đang là admin nên không cần -Verb RunAs nữa
  $p = Start-Process -FilePath $ComSpec -ArgumentList $cmdArg -Wait -PassThru -WindowStyle Normal
  if ($p.ExitCode -ne 0) {
    Write-Warning ("CMD exited with code {0}" -f $p.ExitCode)
  }
}
catch {
  Write-Error ("Failed to start cmd.exe: {0}" -f $_.Exception.Message)
  throw
}
finally {
  # ================ CLEANUP ================
  try {
    if (Test-Path $TempFile) { Remove-Item $TempFile -Force -ErrorAction SilentlyContinue }
  } catch {}
}

Write-Host "[+] Done."
