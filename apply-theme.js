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
  
  const localThemePath = path.join(__dirname, 'antigravity-miku-theme.css');
  const userThemePath = path.join(os.homedir(), '.gemini', 'antigravity-miku-theme.css');
  const themePath = fs.existsSync(localThemePath) ? localThemePath : userThemePath;
  const css = fs.existsSync(themePath) ? fs.readFileSync(themePath, 'utf8') : '';

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
              if (document.hidden) vid.pause();
              else vid.play().catch(() => {});
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
