# Ubuntu 代码开发 + 视频剪辑必装软件

## 代码开发

| 类别 | 推荐软件 | 安装方式 |
|------|----------|----------|
| **IDE** | VS Code 或 Cursor（基于 VS Code） | snap install code / snap install cursor |
| **终端** | Terminator（多分屏） | apt install terminator |
| **Shell** | Oh My Zsh | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" |
| **Git** | 通常已预装，没有则 apt install git |
| **Docker** | 见 docker.com 官方文档 | |
| **语言运行时** | Node.js, Python3, Go 等 | 按需安装 |
| **SSH** | openssh-client | apt install openssh-client |
| **压缩** | p7zip-full, unzip | apt install p7zip-full unzip |

## 视频剪辑

| 类别 | 推荐软件 | 安装方式 |
|------|----------|----------|
| **专业剪辑** | DaVinci Resolve（免费版够用） | 官网下载 .run 安装器 |
| **开源替代** | Kdenlive、Shotcut | snap install kdenlive |
| **录屏** | OBS Studio | snap install obs-studio |
| **格式转换** | HandBrake | snap install handbrake |
| **核心工具** | FFmpeg | apt install ffmpeg |
| **素材库** | Pexels/Pixabay 下载器 | yt-dlp 或 corgutils |

## 协同创作（腾讯系）

| 类别 | 推荐软件 | 说明 |
|------|----------|------|
| **企业协同** | 企业微信 | 无 Linux 版，网页版仅限管理员使用，普通员工需客户端 |
| **视频会议** | 腾讯会议 | 无官方 Linux 版，可使用网页版 |
| **轻量办公** | TIM（QQ 办公版） | snap install tim 或者官网下载 |
| **即时通讯** | 微信 | 社区 DeepinWine 版 or 网页版 |
| **文档协作** | 腾讯文档 | 浏览器访问 docs.qq.com |

```bash
# TIM（QQ 办公版）
snap install tim
# 或下载 .deb: https://tim.qq.com/download.html

# 微信（DeepinWine 兼容层）
# 社区维护版本，如：https://github.com/zq1997/deepin-wine
```

> **备注**：腾讯系软件对 Linux 支持较弱，企业微信、腾讯会议均无官方 Linux 桌面版。企业微信网页版（work.weixin.qq.com）仅供管理员登录，普通员工无法使用。建议搭配移动端或虚拟机使用。

## 其他必备

```bash
# 截图
apt install flameshot

# 字体（可选）
apt install fonts-noto-color-emoji

# 科学上网（如需要）
# 自行配置 Clash 或 V2Ray

# WiFi 驱动（如有需求）
apt install firmware-iwlwifi  # Intel 无线网卡
```

## 快速初始化脚本

```bash
# 开发基础
sudo apt update && sudo apt install -y git curl wget terminator zsh build-essential cmake

# 常用工具
sudo apt install -y p7zip-full unzip htop bpytop tree xclip

# 安装 VS Code
sudo snap install code --classic

# 安装 Docker
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# 安装 OBS 和 FFmpeg
sudo snap install obs-studio
sudo apt install ffmpeg
```
