<#
.SYNOPSIS
  一键修补并安装 Antigravity 终端赛博动态壁纸与亚克力毛玻璃主题（V3 本地 Blob 零寻道 + 帧率看门狗引擎）。
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
Write-Host "$teal  ║    ANTIGRAVITY CYBER ACRYLIC THEME AUTO-PATCHER (V3)      ║$reset"
Write-Host "$teal  ╚═══════════════════════════════════════════════════════════╝$reset"
Write-Host "$dim  正在准备注入 V3 本地 Blob 内存播放、硬件解码防死锁与节能引擎...$reset"
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

# 如果之前已有旧注入，先剔除再写入最新的 V3 引擎
$startMark = '// === ANTIGRAVITY SELF-CONTAINED CYBER ACRYLIC THEME ENGINE'
if ($utilsContent.Contains($startMark)) {
    $idx = $utilsContent.IndexOf($startMark)
    $endIdx = $utilsContent.IndexOf('void win.loadURL(url);', $idx)
    $utilsContent = $utilsContent.Substring(0, $idx) + $utilsContent.Substring($endIdx)
}

# 3. 注入 V3 本地 Blob 内存播放 + 真帧进监测看门狗引擎
$injectionCode = @'

    // === ANTIGRAVITY SELF-CONTAINED CYBER ACRYLIC THEME ENGINE (V3 BLOB + WATCHDOG) ===
    try {
        const http = require('http');
        const fs = require('fs');
        const path = require('path');
        const os = require('os');

        // 1. Singleton In-Memory Video Streaming Server (Port 43939)
        if (!global.__agyStreamServerStarted) {
            global.__agyStreamServerStarted = true;
            const possibleVideoPaths = [
                'd:\\Study\\gemini美化\\miku_1080p_16s.mp4',
                path.join(os.homedir(), '.gemini', 'miku_1080p_16s.mp4'),
                path.join(os.homedir(), '.gemini', 'background.mp4')
            ];
            let videoFile = possibleVideoPaths.find(p => fs.existsSync(p)) || possibleVideoPaths[0];
            let videoBuf = null;
            try {
                if (fs.existsSync(videoFile)) videoBuf = fs.readFileSync(videoFile);
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
                    const start = Math.max(0, parseInt(parts[0], 10) || 0);
                    const end = parts[1] ? Math.min(total - 1, parseInt(parts[1], 10)) : total - 1;
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
        }

        // 2. Auto Dynamic Theme & V3 Anti-Freeze Video Injector
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
                            'transform: translateZ(0)',
                            'will-change: transform'
                        ].join(';');
                        document.body.prepend(vid);
                    }

                    // Load full MP4 into local Blob URL once (zero network seeks on loop)
                    if (!window.__mikuVideoLoading && (!vid.src || (!vid.src.startsWith('blob:') && !vid.src.includes('43939')))) {
                        window.__mikuVideoLoading = true;
                        fetch('http://127.0.0.1:43939/video.mp4')
                            .then(r => { if (!r.ok) throw new Error('HTTP ' + r.status); return r.blob(); })
                            .then(blob => {
                                if (window.__mikuBlobUrl) {
                                    try { URL.revokeObjectURL(window.__mikuBlobUrl); } catch (_) {}
                                }
                                window.__mikuBlobUrl = URL.createObjectURL(blob);
                                vid.src = window.__mikuBlobUrl;
                                vid.play().catch(() => {});
                                window.__mikuVideoLoading = false;
                            })
                            .catch(() => {
                                vid.src = 'http://127.0.0.1:43939/video.mp4';
                                vid.play().catch(() => {});
                                window.__mikuVideoLoading = false;
                            });
                    } else if (!document.hidden && vid.paused && vid.src) {
                        vid.play().catch(() => {});
                    }

                    // === V3 Eco Mode & True currentTime Freeze-Detection Watchdog ===
                    if (window.__ecoModeCleanup) {
                        window.__ecoModeCleanup();
                    }

                    const onVisibilityChange = () => {
                        if (document.hidden) {
                            vid.pause();
                        } else {
                            vid.play().catch(() => {});
                        }
                    };
                    document.addEventListener('visibilitychange', onVisibilityChange);

                    let lastTime = -1;
                    let stuckCount = 0;
                    const watchdogInterval = setInterval(() => {
                        if (document.hidden || !vid.src) {
                            stuckCount = 0;
                            return;
                        }
                        if (vid.paused) {
                            vid.play().catch(() => {});
                            return;
                        }
                        const cur = vid.currentTime;
                        if (Math.abs(cur - lastTime) < 0.01) {
                            stuckCount++;
                            if (stuckCount === 2) {
                                const dur = vid.duration || 16;
                                vid.currentTime = (cur >= dur - 0.4) ? 0 : (cur + 0.05);
                                vid.play().catch(() => {});
                            } else if (stuckCount >= 4) {
                                const targetSrc = window.__mikuBlobUrl || 'http://127.0.0.1:43939/video.mp4';
                                vid.src = targetSrc;
                                vid.load();
                                vid.play().catch(() => {});
                                stuckCount = 0;
                            }
                        } else {
                            stuckCount = 0;
                        }
                        lastTime = cur;
                    }, 1500);

                    const onUserActivity = () => {
                        if (!document.hidden && vid.paused && vid.src) {
                            vid.play().catch(() => {});
                        }
                    };
                    window.addEventListener('pointerdown', onUserActivity, { passive: true });
                    window.addEventListener('keydown', onUserActivity, { passive: true });

                    window.__ecoModeCleanup = () => {
                        document.removeEventListener('visibilitychange', onVisibilityChange);
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
    Write-Host "$teal[3/4] 成功注入 V3 本地 Blob 防卡顿引擎到 utils.js！$reset"
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
Write-Host "$teal  [39] ANTIGRAVITY V3 引擎已永久注入！$reset"
Write-Host "$teal  请重启 Antigravity 客户端即可完全生效！$reset"
Write-Host ""
