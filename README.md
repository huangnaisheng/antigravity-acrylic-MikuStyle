<div align="center">

# 🎵 Antigravity 2.0 Cyber Acrylic Theme

<p>
  <b><a href="#-english">English</a></b> •
  <b><a href="#-简体中文">简体中文</a></b>
</p>

> Modern Acrylic Glassmorphism, 1080P 60FPS fluid video streaming background, and Wallpaper Engine style auto-pause eco engine for Google Antigravity 2.0.

![Theme Preview](docs/preview.png)

</div>

---

<a name="-english"></a>
## 🌐 English

### ✨ Key Features

- 🌊 **1080P 60FPS Smooth Video Wallpaper**: Embedded lightweight MP4 streaming (approx. 2.9MB) served via an in-process local HTTP service. GPU overhead is strictly under 2%, completely stutter-free.
- 🧊 **Acrylic Glassmorphism**: High-intensity frosted glass on sidebar (`blur(28px)`) and composer input bar (`blur(32px)`) with subtle cyber-terminal cyan/pink neon borders.
- ⚡ **Wallpaper Engine Style Eco Engine**: Automatically pauses video playback when the window is blurred, minimized, or occluded, and resumes instantly upon focus. Zero wasted CPU/GPU compute.
- 🛡️ **Cold-Boot Main Process Persistence**: Hooks into Electron's main process lifecycle (`dom-ready` and `did-finish-load`) to inject styles and start the in-process stream server. Survives restarts effortlessly.
- 🎯 **Solid Opaque Modal Fix**: Forces modals, menus, and popovers to be solid deep opaque with `z-index: 99999`, eliminating readability issues caused by blur layering over chat text.
- 📌 **Pinned Sidebar Toggle Toolbar**: Preserves the top-left toolbar position, ensuring the sidebar toggle (`◨`) and navigation arrows never drift to the right.

---

### 🚀 Quick Start Guide

#### Prerequisites
- **Windows 10 / 11**
- **PowerShell 7 (`pwsh`)** or built-in **Windows PowerShell**
- **Node.js** (v16+)

#### 1. First-Time Setup / Restore After Client Updates
Clone or download this repository to any local directory, open PowerShell, and run:

```powershell
pwsh ./Install-MikuThemePatch.ps1
```

> **Automated Workflow**:
> 1. Backs up the original untouched `app.asar` to `app.asar.bak`;
> 2. Extracts `app.asar` and injects the in-process stream server and dynamic style hook into `dist/utils.js`;
> 3. Repacks `app.asar` with unpacked node_modules support;
> 4. Deploys the theme configuration to `~/.gemini/antigravity-miku-theme.css`.  
> Takes only ~3 seconds. Launch Antigravity to enjoy the new theme!

---

#### 2. Live Theme Tweaking (No Restart Required)
If you tweak colors, border radiuses, or blur amounts in `antigravity-miku-theme.css`, hot-reload the UI instantly via Chrome DevTools Protocol (CDP):

```powershell
pwsh ./Apply-MikuTheme.ps1
```

---

#### 3. Restore to Factory Default
To revert to the official unmodded dark theme for bug isolation or troubleshooting:

```powershell
pwsh ./Restore-OriginalTheme.ps1
```

---

### 🎨 Customization

#### Use Your Own Video Background
1. Prepare any looping MP4 video (recommended: 1080P, 60fps, size < 15MB for optimal responsiveness);
2. Name it `miku_1080p_16s.mp4` or `background.mp4` in the project directory;
3. Run `pwsh ./Apply-MikuTheme.ps1` to see your new background immediately.

---

### 🔒 Privacy & Security

- **100% Local**: All stream requests and style injections run strictly on localhost (`127.0.0.1`), never transmitting data externally.
- **Privacy Shield**: Strict `.gitignore` rules prevent private chat captures, workspace screenshots, and debug logs from ever entering Git.
- **Non-Destructive**: An automatic factory backup (`app.asar.bak`) is preserved at all times.

---

<br/>

---

<a name="-简体中文"></a>
## 🇨🇳 简体中文

### ✨ 核心特性

- 🌊 **1080P 60FPS 流畅视频背景**：内置轻量高清视频流（约 2.9MB），由主进程原生微服务提供分段传输，GPU 占用率低于 2%，丝滑不卡顿。
- 🧊 **亚克力磨砂玻璃（Backdrop Glassmorphism）**：侧边栏 `blur(28px)`、输入框胶囊 `blur(32px)`，对话卡片半透明浮动，文字清晰可读。
- ⚡ **Wallpaper Engine 式自动休眠感知（Eco Mode）**：软件最小化、失去焦点或切入后台时，自动暂停（Pause）视频解码，切回前台秒级无感唤醒，真正 0 无效耗电。
- 🛡️ **主进程冷启动持久化机制**：将内嵌微流媒体服务与动态加载钩子注入 Electron 主进程，应用重启依然稳定自启生效。
- 🎯 **设置弹窗防穿透实体化 & 左上角工具栏防漂移**：弹窗设定为实体底色与高层级，彻底消除毛玻璃重叠与排版推挤问题。

---

### 🚀 极速安装与使用指南

#### 前置环境要求
- **Windows 10 / 11**
- **PowerShell 7 (`pwsh`)** 或系统自带 **Windows PowerShell**
- **Node.js** (v16+)

#### 1. 初次安装 / 软件大版本更新后一键恢复
将本项目克隆或下载到本地任意目录，在仓库根目录下打开 PowerShell 并执行：

```powershell
pwsh ./Install-MikuThemePatch.ps1
```

> **自动化执行流程**：
> 1. 自动备份官方出厂原始包 `app.asar.bak`；
> 2. 自动解包并在 `dist/utils.js` 窗口创建函数前注入原生流媒体引擎与动态样式钩子；
> 3. 重新封包为 `app.asar`；
> 4. 自动部署全局样式至 `~/.gemini/antigravity-miku-theme.css`。  
> 耗时仅约 3 秒，重启客户端即刻享受完整美化！

---

#### 2. 日常调节样式：一键热刷新（无需重启软件）
如果你在 `antigravity-miku-theme.css` 中微调了配色、毛玻璃模糊度或边框颜色，无需重启客户端，只需执行：

```powershell
pwsh ./Apply-MikuTheme.ps1
```

---

#### 3. 一键还原官方出厂纯净默认状态
如果你需要排查官方 Bug 或临时换回官方出厂黑灰默认主题，只需执行：

```powershell
pwsh ./Restore-OriginalTheme.ps1
```

---

### 🎨 自定义壁纸与进阶配置

#### 更换你自己的视频动态壁纸
1. 准备任意你喜欢的循环 MP4 视频（推荐分辨率 1080P，帧率 60fps，大小控制在 15MB 以内以获得最佳性能）；
2. 将其命名为 `miku_1080p_16s.mp4` 或 `background.mp4` 替换仓库根目录下的同名文件；
3. 运行 `pwsh ./Apply-MikuTheme.ps1` 即可即时看到新壁纸效果。

---

### 📂 项目结构

```text
├── antigravity-miku-theme.css  # 全局核心样式表（配色系统、亚克力毛玻璃、实体化防穿透规则）
├── miku_1080p_16s.mp4          # 1080P 60FPS 流式背景视频（轻量 2.9MB）
├── stream_server.js            # 本地轻量 HTTP 206 范围串流守护服务
├── Install-MikuThemePatch.ps1  # 【核心】一键修补并安装/还原美化的自动化脚本
├── Apply-MikuTheme.ps1         # 免重启样式热刷新执行脚本
├── apply-theme.js              # CDP 热重载注入脚本
├── Restore-OriginalTheme.ps1   # 官方出厂默认主题还原脚本
├── docs/
│   └── preview.png             # 效果展示截图
├── .gitignore                  # 隐私分离规则（严格过滤私有截图与临时日志）
└── README.md                   # 双语使用与架构说明
```

---

### 🔒 隐私与安全性保障 (Privacy & Security)

- **完全本地化**：所有视频串流与样式注入仅监听本地环回地址 (`127.0.0.1`)，不向任何外部网络发送或请求数据。
- **隐私隔离**：配置有严格的 `.gitignore` 规则，确保开发期间的会话截屏、聊天记录、调试脚本及私有资产永不进入 Git 追踪。
- **无破坏性修改**：安装脚本在初次运行时会自动对官方原始 `app.asar` 创建独立备份（`app.asar.bak`），随时支持无损一键还原。

---

### 📄 开源许可证

本项目基于 [MIT License](LICENSE) 开源。
