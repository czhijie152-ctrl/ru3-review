# 一键更新线上网站
#
# 用法：在 PowerShell 里运行
#     E:\deepseek\大学俄语\复习工具\deploy\publish.ps1
#
# 做的事：重新生成 HTML -> 复制到 deploy\index.html -> 提交 -> 推送 -> 等 Pages 构建完成
# 前提：git 已配置好代理（见本目录 README-DEPLOY.md），且 gh / git 可用。

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$root    = Split-Path -Parent $PSScriptRoot            # E:\deepseek\大学俄语\复习工具
$srcHtml = Join-Path $root '俄语复习.html'
$dstHtml = Join-Path $PSScriptRoot 'index.html'
$git     = 'C:\Program Files\Git\cmd\git.exe'
$gh      = 'C:\Program Files\GitHub CLI\gh.exe'
$repo    = 'czhijie152-ctrl/ru3-review'
$site    = 'https://czhijie152-ctrl.github.io/ru3-review/'

Write-Host '[1/5] 重新生成 俄语复习.html ...' -ForegroundColor Cyan
python (Join-Path $root 'build.py')

Write-Host '[2/5] 复制到 deploy\index.html ...' -ForegroundColor Cyan
Copy-Item $srcHtml $dstHtml -Force
$size = (Get-Item $dstHtml).Length
Write-Host ("      {0:N0} bytes" -f $size)

Write-Host '[3/5] 提交 ...' -ForegroundColor Cyan
Push-Location $PSScriptRoot
try {
    & $git add -A
    $changed = & $git status --porcelain
    if (-not $changed) {
        Write-Host '      内容没有变化，无需更新。' -ForegroundColor Yellow
    } else {
        & $git commit -m ("更新复习工具 {0}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm')) | Out-Null

        Write-Host '[4/5] 推送到 GitHub ...' -ForegroundColor Cyan
        & $git push origin main

        Write-Host '[5/5] 等待 Pages 构建 ...' -ForegroundColor Cyan
        for ($i = 1; $i -le 20; $i++) {
            Start-Sleep -Seconds 10
            try {
                $r = Invoke-WebRequest -Uri $site -UseBasicParsing -TimeoutSec 20 -Headers @{ 'Cache-Control' = 'no-cache' }
                if ($r.StatusCode -eq 200 -and $r.RawContentLength -eq $size) {
                    Write-Host ("      ✅ 已上线（{0:N0} bytes）" -f $r.RawContentLength) -ForegroundColor Green
                    break
                }
                Write-Host ("      [{0}] 已响应 {1} bytes，等待与本地一致 ..." -f $i, $r.RawContentLength)
            } catch {
                Write-Host ("      [{0}] 还在构建 ..." -f $i)
            }
        }
    }
} finally {
    Pop-Location
}

Write-Host ''
Write-Host "网站地址： $site" -ForegroundColor Green
