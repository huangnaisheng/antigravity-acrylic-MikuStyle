const http = require('http');
const fs = require('fs');
const path = require('path');

// Dynamically locate video in the same directory, or via env variable
const videoPath = process.env.ANTIGRAVITY_VIDEO_PATH || 
  (fs.existsSync(path.join(__dirname, 'miku_1080p_16s.mp4')) 
    ? path.join(__dirname, 'miku_1080p_16s.mp4') 
    : path.join(__dirname, 'background.mp4'));

const PORT = parseInt(process.env.PORT, 10) || 43939;

const server = http.createServer((req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  if (!fs.existsSync(videoPath)) {
    res.writeHead(404, { 'Content-Type': 'text/plain' });
    return res.end('Video file not found. Please place miku_1080p_16s.mp4 or background.mp4 in the server directory.');
  }

  const stat = fs.statSync(videoPath);
  const range = req.headers.range;

  if (range) {
    const parts = range.replace(/bytes=/, "").split("-");
    const start = parseInt(parts[0], 10);
    const end = parts[1] ? parseInt(parts[1], 10) : stat.size - 1;
    const chunksize = (end - start) + 1;
    const file = fs.createReadStream(videoPath, { start, end });
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
    fs.createReadStream(videoPath).pipe(res);
  }
});

server.listen(PORT, '127.0.0.1', () => {
  console.log(`[StreamServer] 1080p stream server active on http://127.0.0.1:${PORT}/`);
});
