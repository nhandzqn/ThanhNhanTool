<#
fetch-run.ps1
Tải .cmd từ GitHub → chạy bằng CMD (admin) → xóa file tạm
#>

# ========== CONFIG ==========
# Thay link raw GitHub của bạn vào đây:
$Url = "https://raw.githubusercontent.com/nhandzqn/ThanhNhanTool/main/Tools/1.cmd"

# ========== AUTO ELEVATE ==========
function Test-Admin {
  $wi = [Security.Principal.WindowsIdentity]::GetCurrent()
  $pr = New-Object Security.Principal.WindowsPrincipal($wi)
  return $pr.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}
if (-not (Test-Admin)) {
  Write-Host "[*] Re-launching with Administrator rights..."
  Start-Process powershell -Verb RunAs -ArgumentList "-NoLogo -NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
  exit
}

# ========== DOWNLOAD ==========
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

$TempFile = Join-Path $env:TEMP ("tool_{0}.cmd" -f ([guid]::NewGuid().Guid.Substring(0,8)))
Write-Host "[*] Downloading $Url"
$content = Invoke-RestMethod -Uri $Url -Method Get

if ([string]::IsNullOrWhiteSpace($content)) {
  throw "Download failed or file empty"
}

# Normalize line endings, ghi ASCII để tránh BOM
$content = ($content -replace "`r?`n","`r`n")
Set-Content -Path $TempFile -Value $content -Encoding Ascii

if (-not (Test-Path $TempFile)) {
  throw "Failed to save temp file $TempFile"
}

# ========== RUN CMD ==========
$ComSpec = "$env:SystemRoot\System32\cmd.exe"
$cmdArgs = "/c `"$TempFile`""
Write-Host "[*] Running: $ComSpec $cmdArgs"
Start-Process -FilePath $ComSpec -ArgumentList $cmdArgs -Wait

# ========== CLEANUP ==========
Remove-Item $TempFile -Force -ErrorAction SilentlyContinue
Write-Host "[+] Done. Temp file deleted."
