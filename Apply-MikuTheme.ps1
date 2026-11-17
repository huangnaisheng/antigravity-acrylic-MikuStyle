<#
.SYNOPSIS
  一键重新加载 / 应用初音未来 (Hatsune Miku // PowerShell 7) 主题到反重力 (Antigravity)。
#>
$teal = "$([char]27)[38;2;57;230;194m"
$pink = "$([char]27)[38;2;255;83;181m"
$dim  = "$([char]27)[38;2;125;150;171m"
$reset = "$([char]27)[0m"

Write-Host ""
Write-Host "$teal  [39] HATSUNE MIKU // ANTIGRAVITY THEME RELOADER$reset"
Write-Host "$dim  teal signal online | 正在同步样式到反重力...$reset"

$jsFile = Join-Path $PSScriptRoot "apply-theme.js"
$result = node $jsFile 2>&1

if ($result -match "RELOAD_OK") {
    Write-Host "$teal  [√] 赛博终端亚克力风格主题已成功应用并热刷新！$reset"
} else {
    Write-Host "$pink  [!] 热重载提示: $result$reset"
}
Write-Host ""
