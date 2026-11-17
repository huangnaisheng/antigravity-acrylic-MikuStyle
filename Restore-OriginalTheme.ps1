<#
.SYNOPSIS
  一键还原反重力 (Antigravity) 到官方出厂默认主题。
#>
$ErrorActionPreference = "Stop"

$teal = "$([char]27)[38;2;57;230;194m"
$pink = "$([char]27)[38;2;255;83;181m"
$reset = "$([char]27)[0m"

Write-Host ""
Write-Host "$pink  [RESTORE] 正在恢复 Antigravity 出厂默认主题...$reset"

$resourcesDir = "$env:LOCALAPPDATA\Programs\antigravity\resources"
$backupFile = Join-Path $resourcesDir "app.asar.bak"
$targetFile = Join-Path $resourcesDir "app.asar"

if (Test-Path $backupFile) {
    Copy-Item -Path $backupFile -Destination $targetFile -Force
    Write-Host "$teal  [√] 已从官方备份还原 app.asar！$reset"
} else {
    Write-Host "$pink  [!] 未找到备份文件 app.asar.bak$reset"
}

$themeCss = Join-Path $HOME ".gemini\antigravity-miku-theme.css"
if (Test-Path $themeCss) {
    Rename-Item -Path $themeCss -NewName "antigravity-miku-theme.css.disabled" -Force
    Write-Host "$teal  [√] 已将自定义 CSS 文件重命名禁用。$reset"
}

Write-Host "$teal  [√] 还原完成，重启 Antigravity 即可恢复出厂外观。$reset"
Write-Host ""
