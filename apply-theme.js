const fs = require('fs');
const path = require('path');
const os = require('os');

async function main() {
  const devToolsFile = path.join(process.env.APPDATA, 'Antigravity', 'DevToolsActivePort');
  if (!fs.existsSync(devToolsFile)) {
    console.error('DEVTOOLS_PORT_NOT_FOUND');
    process.exit(1);
  }

  const port = fs.readFileSync(devToolsFile, 'utf8').trim().split('\n')[0].trim();
  
  // Prioritize local repository theme css, fallback to user home directory
  const localThemePath = path.join(__dirname, 'antigravity-miku-theme.css');
  const userThemePath = path.join(os.homedir(), '.gemini', 'antigravity-miku-theme.css');
  const themePath = fs.existsSync(localThemePath) ? localThemePath : userThemePath;
  const css = fs.existsSync(themePath) ? fs.readFileSync(themePath, 'utf8') : '';

  // Keep home directory synced if running from repository
  if (fs.existsSync(localThemePath)) {
    try {
      const geminiDir = path.join(os.homedir(), '.gemini');
      if (!fs.existsSync(geminiDir)) fs.mkdirSync(geminiDir, { recursive: true });
      fs.writeFileSync(userThemePath, css, 'utf8');
    } catch (_) {}
  }

  try {
    const targets = await fetch(`http://127.0.0.1:${port}/json/list`).then(r => r.json());
    const mainTarget = targets.find(t => t.type === 'page' && t.url && t.url.includes('127.0.0.1')) || targets[0];
    if (!mainTarget) {
      console.error('NO_TARGETS_FOUND');
      process.exit(1);
    }

    const ws = new WebSocket(mainTarget.webSocketDebuggerUrl);
    ws.onopen = () => {
      ws.send(JSON.stringify({
        id: 1,
        method: 'Runtime.evaluate',
        params: {
          expression: `(() => {
            let bgLayer = document.getElementById('miku-background-layer');
            if (bgLayer) bgLayer.remove();

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

            // === Eco Mode (Wallpaper Engine Style Auto-Pause) ===
            if (window.__ecoModeCleanup) {
              window.__ecoModeCleanup();
            }
            const onVisibilityChange = () => {
              if (document.hidden) vid.pause();
              else vid.play().catch(() => {});
            };
            const onWindowBlur = () => {
              vid.pause();
            };
            const onWindowFocus = () => {
              if (!document.hidden) vid.play().catch(() => {});
            };
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
            styleEl.textContent = ${JSON.stringify(css)};

            if (!document.getElementById('miku-status-pill')) {
              const pill = document.createElement('div');
              pill.id = 'miku-status-pill';
              pill.innerHTML = '<span class="pulse-dot"></span><span>39 // ECO AUTO-PAUSE</span><span class="pink-tag">>_</span>';
              document.body.appendChild(pill);
            }
            return 'OK';
          })()`,
          returnByValue: true
        }
      }));
    };

    ws.onmessage = (event) => {
      const data = JSON.parse(event.data);
      if (data.id === 1) {
        console.log('RELOAD_OK');
        ws.close();
        process.exit(0);
      }
    };

    ws.onerror = (err) => {
      console.error('WS_ERROR', err);
      process.exit(1);
    };
  } catch (err) {
    console.error('FETCH_OR_CONN_ERROR', err);
    process.exit(1);
  }
}

main();
