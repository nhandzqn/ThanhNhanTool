# URL raw GitHub tới tool.cmd
$Url = "https://raw.githubusercontent.com/nhandzqn/ThanhNhanTool/refs/heads/main/Tools/1.cmd"

# Tạo file tạm
$TempFile = Join-Path $env:TEMP ("tool_{0}.cmd" -f ([guid]::NewGuid().Guid.Substring(0,8)))

# Tải nội dung file .cmd
Invoke-RestMethod $Url | Set-Content -Path $TempFile -Encoding ASCII

# Chạy bằng CMD với quyền admin
Start-Process -FilePath "cmd.exe" -Verb RunAs -ArgumentList ("/c `"$TempFile`"") -Wait

# Xóa file tạm
Remove-Item $TempFile -ErrorAction SilentlyContinue
