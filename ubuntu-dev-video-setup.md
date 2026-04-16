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
