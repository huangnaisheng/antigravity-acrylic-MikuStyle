const http = require('http');
const fs = require('fs');
const path = require('path');
const os = require('os');

// Dynamically locate video in the same directory, or via env variable
const videoPath = process.env.ANTIGRAVITY_VIDEO_PATH || 
  (fs.existsSync(path.join(__dirname, 'miku_1080p_16s.mp4')) 
    ? path.join(__dirname, 'miku_1080p_16s.mp4') 
    : path.join(__dirname, 'background.mp4'));

const PORT = parseInt(process.env.PORT, 10) || 43939;

// Preload the lightweight 2.9MB video into RAM for zero-latency streaming & smooth loops
let videoBuf = null;
try {
  if (fs.existsSync(videoPath)) {
    videoBuf = fs.readFileSync(videoPath);
    console.log(`[StreamServer] Preloaded video (${(videoBuf.length / 1024 / 1024).toFixed(2)} MB) into RAM`);
  }
} catch (e) {
  console.error('[StreamServer] Preload error:', e);
}

const server = http.createServer((req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Cache-Control', 'public, max-age=31536000, immutable');

  if (!videoBuf) {
    try {
      if (fs.existsSync(videoPath)) videoBuf = fs.readFileSync(videoPath);
    } catch (_) {}
  }

  if (!videoBuf) {
    res.writeHead(404, { 'Content-Type': 'text/plain' });
    return res.end('Video file not found.');
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

server.listen(PORT, '127.0.0.1', () => {
  console.log(`[StreamServer] 1080p zero-latency stream server active on http://127.0.0.1:${PORT}/`);
});
