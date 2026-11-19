<#
.SYNOPSIS
  一键修补并安装 Antigravity 终端赛博动态壁纸与亚克力毛玻璃主题（V2 流畅高刷防卡顿引擎）。
  在 Antigravity 软件更新或初次安装后，只需运行本脚本即可全自动注入并恢复完整美化。
#>
$ErrorActionPreference = "Stop"

$teal  = "$([char]27)[38;2;57;230;194m"
$pink  = "$([char]27)[38;2;255;92;138m"
$blue  = "$([char]27)[38;2;101;184;255m"
$dim   = "$([char]27)[38;2;125;150;171m"
$reset = "$([char]27)[0m"

Write-Host ""
Write-Host "$teal  ╔═══════════════════════════════════════════════════════════╗$reset"
Write-Host "$teal  ║    ANTIGRAVITY CYBER ACRYLIC THEME AUTO-PATCHER (V2)      ║$reset"
Write-Host "$teal  ╚═══════════════════════════════════════════════════════════╝$reset"
Write-Host "$dim  正在准备注入无损内存流媒体、无缝循环防卡死与节能引擎...$reset"
Write-Host ""

$appDir = "$env:LOCALAPPDATA\Programs\antigravity"
$resourcesDir = Join-Path $appDir "resources"
$asarFile = Join-Path $resourcesDir "app.asar"
$backupFile = Join-Path $resourcesDir "app.asar.bak"

if (-not (Test-Path $asarFile)) {
    Write-Host "$pink[!] 未找到 Antigravity 安装目录下的 app.asar: $asarFile$reset"
    exit 1
}

# 0. 部署样式表到用户目录
$repoCss = Join-Path $PSScriptRoot "antigravity-miku-theme.css"
$geminiDir = Join-Path $HOME ".gemini"
$targetCss = Join-Path $geminiDir "antigravity-miku-theme.css"

if (Test-Path $repoCss) {
    if (-not (Test-Path $geminiDir)) {
        New-Item -ItemType Directory -Path $geminiDir -Force | Out-Null
    }
    Copy-Item -Path $repoCss -Destination $targetCss -Force
    Write-Host "$teal[0/4] 样式配置文件已部署至: $targetCss$reset"
}

# 1. 备份官方出厂原始 app.asar
if (-not (Test-Path $backupFile)) {
    Write-Host "$blue[1/4] 正在创建官方出厂备份 app.asar.bak...$reset"
    Copy-Item -Path $asarFile -Destination $backupFile -Force
} else {
    Write-Host "$dim[1/4] 官方备份 app.asar.bak 已存在。$reset"
}

# 2. 解包 app.asar
$tempUnpack = Join-Path $env:TEMP "antigravity-permanent-patch"
if (Test-Path $tempUnpack) {
    Remove-Item -Path $tempUnpack -Recurse -Force
}
New-Item -ItemType Directory -Path $tempUnpack -Force | Out-Null

Write-Host "$blue[2/4] 正在解包 app.asar 进行代码注入...$reset"
npx asar extract $asarFile $tempUnpack

$utilsFile = Join-Path $tempUnpack "dist\utils.js"
if (-not (Test-Path $utilsFile)) {
    Write-Host "$pink[!] 未能在解包文件中找到 dist\utils.js$reset"
    exit 1
}

$utilsContent = [System.IO.File]::ReadAllText($utilsFile, [System.Text.Encoding]::UTF8)

# 如果之前已有旧注入，先剔除再写入最新的 V2 引擎
$startMark = '// === ANTIGRAVITY SELF-CONTAINED CYBER ACRYLIC THEME ENGINE'
if ($utilsContent.Contains($startMark)) {
    $idx = $utilsContent.IndexOf($startMark)
    $endIdx = $utilsContent.IndexOf('void win.loadURL(url);', $idx)
    $utilsContent = $utilsContent.Substring(0, $idx) + $utilsContent.Substring($endIdx)
}

# 3. 注入 V2 高性能内存流媒体与防卡顿守护引擎
$injectionCode = @'

    // === ANTIGRAVITY SELF-CONTAINED CYBER ACRYLIC THEME ENGINE (V2 SMOOTH) ===
    try {
        const http = require('http');
        const fs = require('fs');
        const path = require('path');
        const os = require('os');

        // 1. Native In-Memory High-Performance Video Streaming Server (Port 43939)
        const possibleVideoPaths = [
            'd:\\Study\\gemini美化\\miku_1080p_16s.mp4',
            path.join(os.homedir(), '.gemini', 'miku_1080p_16s.mp4'),
            path.join(os.homedir(), '.gemini', 'background.mp4')
        ];
        let videoFile = possibleVideoPaths.find(p => fs.existsSync(p)) || possibleVideoPaths[0];
        
        // Pre-load the 2.9MB video into RAM buffer for zero-latency instant streaming
        let videoBuf = null;
        try {
            if (fs.existsSync(videoFile)) {
                videoBuf = fs.readFileSync(videoFile);
            }
        } catch (_) {}

        const streamServer = http.createServer((req, res) => {
            res.setHeader('Access-Control-Allow-Origin', '*');
            res.setHeader('Cache-Control', 'public, max-age=31536000, immutable');
            
            if (!videoBuf) {
                try {
                    if (fs.existsSync(videoFile)) videoBuf = fs.readFileSync(videoFile);
                } catch (_) {}
            }
            if (!videoBuf) {
                res.writeHead(404);
                return res.end();
            }

            const total = videoBuf.length;
            const range = req.headers.range;
            if (range) {
                const parts = range.replace(/bytes=/, "").split("-");
                const start = parseInt(parts[0], 10);
                const end = parts[1] ? parseInt(parts[1], 10) : total - 1;
                const chunksize = (end - start) + 1;
                res.writeHead(206, {
                    'Content-Range': `bytes ${start}-${end}/${total}`,
                    'Accept-Ranges': 'bytes',
                    'Content-Length': chunksize,
                    'Content-Type': 'video/mp4',
                });
                res.end(videoBuf.subarray(start, end + 1));
            } else {
                res.writeHead(200, {
                    'Content-Length': total,
                    'Content-Type': 'video/mp4',
                    'Accept-Ranges': 'bytes',
                });
                res.end(videoBuf);
            }
        });
        streamServer.on('error', () => {});
        streamServer.listen(43939, '127.0.0.1');

        // 2. Auto Dynamic Theme & Smooth Playback Injector on Page Load
        const themeCssPath = path.join(os.homedir(), '.gemini', 'antigravity-miku-theme.css');
        const injectCustomTheme = () => {
            try {
                let cssContent = '';
                if (fs.existsSync(themeCssPath)) {
                    cssContent = fs.readFileSync(themeCssPath, 'utf8');
                }

                const js = `(() => {
                    let vid = document.getElementById('miku-background-video');
                    if (!vid) {
                        vid = document.createElement('video');
                        vid.id = 'miku-background-video';
                        vid.autoplay = true;
                        vid.loop = true;
                        vid.muted = true;
                        vid.playsInline = true;
                        vid.setAttribute('preload', 'auto');
                        document.body.prepend(vid);
                    }
                    vid.src = 'http://127.0.0.1:43939/video.mp4';
                    vid.style.cssText = [
                        'position: fixed',
                        'top: 0',
                        'left: 0',
                        'width: 100vw',
                        'height: 100vh',
                        'object-fit: cover',
                        'opacity: 0.5',
                        'pointer-events: none',
                        'z-index: 0',
                        'filter: saturate(1.2) contrast(1.05)'
                    ].join(';');
                    vid.play().catch(() => {});

                    // === Eco Mode & Anti-Stall Watchdog ===
                    if (window.__ecoModeCleanup) {
                        window.__ecoModeCleanup();
                    }

                    // 1. Precise Visibility Handling (Pauses only when truly hidden/minimized)
                    const onVisibilityChange = () => {
                        if (document.hidden) {
                            vid.pause();
                        } else {
                            vid.play().catch(() => {});
                        }
                    };
                    document.addEventListener('visibilitychange', onVisibilityChange);

                    // 2. Seamless Loop Handler (Prevents EOF freeze)
                    const onEnded = () => {
                        vid.currentTime = 0;
                        vid.play().catch(() => {});
                    };
                    vid.addEventListener('ended', onEnded);

                    // 3. Stalled / Waiting Auto-Recovery
                    const onStalled = () => {
                        if (!document.hidden && vid.paused) {
                            vid.play().catch(() => {});
                        }
                    };
                    vid.addEventListener('stalled', onStalled);
                    vid.addEventListener('waiting', onStalled);

                    // 4. Anti-Freeze Watchdog (Ensures it never stays paused while window is visible)
                    const watchdogInterval = setInterval(() => {
                        if (!document.hidden && vid.paused) {
                            vid.play().catch(() => {});
                        }
                    }, 2000);

                    // 5. User Interaction Wakeup (Instant resume on click/key if paused)
                    const onUserActivity = () => {
                        if (!document.hidden && vid.paused) {
                            vid.play().catch(() => {});
                        }
                    };
                    window.addEventListener('pointerdown', onUserActivity, { passive: true });
                    window.addEventListener('keydown', onUserActivity, { passive: true });

                    window.__ecoModeCleanup = () => {
                        document.removeEventListener('visibilitychange', onVisibilityChange);
                        vid.removeEventListener('ended', onEnded);
                        vid.removeEventListener('stalled', onStalled);
                        vid.removeEventListener('waiting', onStalled);
                        clearInterval(watchdogInterval);
                        window.removeEventListener('pointerdown', onUserActivity);
                        window.removeEventListener('keydown', onUserActivity);
                    };

                    let styleEl = document.getElementById('antigravity-miku-theme');
                    if (!styleEl) {
                        styleEl = document.createElement('style');
                        styleEl.id = 'antigravity-miku-theme';
                        document.head.appendChild(styleEl);
                    }
                    styleEl.textContent = ${JSON.stringify(cssContent)};

                    if (!document.getElementById('miku-status-pill')) {
                        const pill = document.createElement('div');
                        pill.id = 'miku-status-pill';
                        pill.innerHTML = '<span class="pulse-dot"></span><span>39 // ECO AUTO-PAUSE</span><span class="pink-tag">>_</span>';
                        document.body.appendChild(pill);
                    }
                })()`;

                hubContents.executeJavaScript(js).catch(() => {});
            } catch (err) {}
        };

        hubContents.on('dom-ready', injectCustomTheme);
        hubContents.on('did-finish-load', injectCustomTheme);
    } catch (e) {}
'@

$targetString = "void win.loadURL(url);"
if ($utilsContent.Contains($targetString)) {
    $utilsContent = $utilsContent.Replace($targetString, "$injectionCode`n    void win.loadURL(url);")
    [System.IO.File]::WriteAllText($utilsFile, $utilsContent, [System.Text.Encoding]::UTF8)
    Write-Host "$teal[3/4] 成功注入 V2 高性能防卡顿引擎到 utils.js！$reset"
} else {
    Write-Host "$pink[!] 未找到挂载锚点 void win.loadURL(url);$reset"
    exit 1
}

# 4. 禁用静默后台自动覆盖 (updater.js)
$updaterFile = Join-Path $tempUnpack "dist\updater.js"
if (Test-Path $updaterFile) {
    $upContent = [System.IO.File]::ReadAllText($updaterFile, [System.Text.Encoding]::UTF8)
    $upContent = $upContent -replace "autoDownload\s*=\s*true;", "autoDownload = false;"
    $upContent = $upContent -replace "autoInstallOnAppQuit\s*=\s*electron_1\.app\.isPackaged;", "autoInstallOnAppQuit = false;"
    $upContent = $upContent -replace "function startAutoUpdateChecks\(\)\s*\{", "function startAutoUpdateChecks() { return;"
    [System.IO.File]::WriteAllText($updaterFile, $upContent, [System.Text.Encoding]::UTF8)
    Write-Host "$teal[3/4+] 已禁用静默后台自动下载与覆盖！$reset"
}

# 5. 重新打包为 app.asar
Write-Host "$blue[4/4] 正在重新打包 app.asar...$reset"
$repackedAsar = Join-Path $resourcesDir "app.asar.patched"
npx asar pack $tempUnpack $repackedAsar --unpack "node_modules/**"
Copy-Item -Path $repackedAsar -Destination $asarFile -Force
Remove-Item -Path $repackedAsar -Force -ErrorAction SilentlyContinue
Remove-Item -Path $tempUnpack -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "$teal  [39] ANTIGRAVITY V2 高刷防卡顿引擎已永久注入！$reset"
Write-Host "$teal  请重启 Antigravity 客户端即可完全生效！$reset"
Write-Host ""
