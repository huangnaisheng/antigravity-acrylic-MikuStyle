<#
.SYNOPSIS
  一键修补并安装 Antigravity 终端赛博动态壁纸与亚克力毛玻璃主题。
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
Write-Host "$teal  ║    ANTIGRAVITY CYBER ACRYLIC THEME AUTO-PATCHER (39)     ║$reset"
Write-Host "$teal  ╚═══════════════════════════════════════════════════════════╝$reset"
Write-Host "$dim  正在准备注入动态壁纸、亚克力磨砂毛玻璃与节能引擎...$reset"
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

# 3. 注入自包含视频流微服务器与动态主题挂载钩子
$injectionCode = @'

    // === ANTIGRAVITY SELF-CONTAINED CYBER ACRYLIC THEME ENGINE ===
    try {
        const http = require('http');
        const fs = require('fs');
        const path = require('path');
        const os = require('os');

        // 1. Native In-Process Video Streaming Server (Port 43939)
        const possibleVideoPaths = [
            'd:\\Study\\gemini美化\\miku_1080p_16s.mp4',
            path.join(os.homedir(), '.gemini', 'miku_1080p_16s.mp4'),
            path.join(os.homedir(), '.gemini', 'background.mp4')
        ];
        let videoFile = possibleVideoPaths.find(p => fs.existsSync(p)) || possibleVideoPaths[0];

        const streamServer = http.createServer((req, res) => {
            res.setHeader('Access-Control-Allow-Origin', '*');
            if (!fs.existsSync(videoFile)) {
                res.writeHead(404);
                return res.end();
            }
            const stat = fs.statSync(videoFile);
            const range = req.headers.range;
            if (range) {
                const parts = range.replace(/bytes=/, "").split("-");
                const start = parseInt(parts[0], 10);
                const end = parts[1] ? parseInt(parts[1], 10) : stat.size - 1;
                const chunksize = (end - start) + 1;
                const file = fs.createReadStream(videoFile, { start, end });
                res.writeHead(206, {
                    'Content-Range': `bytes ${start}-${end}/${stat.size}`,
                    'Accept-Ranges': 'bytes',
                    'Content-Length': chunksize,
                    'Content-Type': 'video/mp4',
                });
                file.pipe(res);
            } else {
                res.writeHead(200, {
                    'Content-Length': stat.size,
                    'Content-Type': 'video/mp4',
                });
                fs.createReadStream(videoFile).pipe(res);
            }
        });
        streamServer.on('error', () => {});
        streamServer.listen(43939, '127.0.0.1');

        // 2. Auto Dynamic Theme Injector on Page Load
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

                    // Eco Mode (Wallpaper Engine Style Auto-Pause)
                    if (window.__ecoModeCleanup) {
                        window.__ecoModeCleanup();
                    }
                    const onVisibilityChange = () => {
                        if (document.hidden) vid.pause();
                        else vid.play().catch(() => {});
                    };
                    const onWindowBlur = () => { vid.pause(); };
                    const onWindowFocus = () => { if (!document.hidden) vid.play().catch(() => {}); };
                    document.addEventListener('visibilitychange', onVisibilityChange);
                    window.addEventListener('blur', onWindowBlur);
                    window.addEventListener('focus', onWindowFocus);
                    window.__ecoModeCleanup = () => {
                        document.removeEventListener('visibilitychange', onVisibilityChange);
                        window.removeEventListener('blur', onWindowBlur);
                        window.removeEventListener('focus', onWindowFocus);
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

if (-not ($utilsContent -match "injectCustomTheme")) {
    $targetString = "void win.loadURL(url);"
    if ($utilsContent.Contains($targetString)) {
        $utilsContent = $utilsContent.Replace($targetString, "$injectionCode`n    void win.loadURL(url);")
        [System.IO.File]::WriteAllText($utilsFile, $utilsContent, [System.Text.Encoding]::UTF8)
        Write-Host "$teal[3/4] 成功注入自包含原生引擎到 createWindow / utils.js！$reset"
    } else {
        Write-Host "$pink[!] 未找到挂载锚点 void win.loadURL(url);$reset"
        exit 1
    }
} else {
    Write-Host "$dim[3/4] utils.js 中已包含注入代码。$reset"
}

# 4. 重新打包为 app.asar
Write-Host "$blue[4/4] 正在重新打包 app.asar...$reset"
$repackedAsar = Join-Path $resourcesDir "app.asar.patched"
npx asar pack $tempUnpack $repackedAsar --unpack "node_modules/**"
Copy-Item -Path $repackedAsar -Destination $asarFile -Force
Remove-Item -Path $repackedAsar -Force -ErrorAction SilentlyContinue
Remove-Item -Path $tempUnpack -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "$teal  [39] ANTIGRAVITY 自包含美化补丁已永久注入！$reset"
Write-Host "$teal  无需运行外部后台服务，启动 Antigravity 即可全天候自动生效！$reset"
Write-Host ""
