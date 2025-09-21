# === cấu hình ===
# Đổi URL raw GitHub của bạn vào đây:
$Url = "https://raw.githubusercontent.com/nhandzqn/ThanhNhanTool/refs/heads/main/Tools/1.cmd"
# ví dụ: https://raw.githubusercontent.com/nhandzqn/ThanhNhanTool/main/tools/tool.cmd

# (tuỳ chọn) đặt hash SHA-256 để kiểm toàn vẹn, để trống nếu không dùng
$Sha256Expected = ""

# === logic ===
$ErrorActionPreference = 'Stop'
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

# chọn thư mục tạm
$IsAdmin = [bool]([Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544')
$TempDir = if ($IsAdmin) { "$env:SystemRoot\Temp" } else { "$env:USERPROFILE\AppData\Local\Temp" }
$TempFile = Join-Path $TempDir ("tool_{0}.cmd" -f ([guid]::NewGuid().Guid.Substring(0,8)))

# tải nội dung .cmd
$response = Invoke-RestMethod -Uri $Url
if (-not $response) { throw "Failed to download content from $Url" }

# kiểm hash nếu có
if ($Sha256Expected) {
  $bytes = [Text.Encoding]::ASCII.GetBytes($response)
  $hash  = [BitConverter]::ToString([Security.Cryptography.SHA256]::Create().ComputeHash($bytes)) -replace '-'
  if ($hash -ne $Sha256Expected) { throw "SHA-256 mismatch. Expected $Sha256Expected, got $hash" }
}

# ghi file .cmd (ASCII để tránh BOM)
Set-Content -Path $TempFile -Value $response -Encoding ASCII
if (-not (Test-Path $TempFile)) { throw "Failed to create $TempFile" }

# chạy bằng cmd.exe rồi xoá dù có lỗi
try {
  $ComSpec = "$env:SystemRoot\System32\cmd.exe"
  Start-Process -FilePath $ComSpec -ArgumentList ('/c "{0}"' -f $TempFile) -Wait
}
finally {
  Remove-Item $TempFile -ErrorAction SilentlyContinue
}
