# WSL Fedora 崩溃修复指南

## 问题描述

Fedora 40 升级到 43 未成功，回退到 Fedora 42 后，WSL 运行一段时间后会不定时崩溃。

### 关键错误日志

```
WSL (277) ERROR: CheckConnection: getaddrinfo() failed: -5
Exception: Operation canceled @p9io.cpp:258 (AcceptAsync)
WSL (1 - init()) ERROR: InitEntryUtilityVm:2510: Init has exited. Terminating distribution
```

## 问题分析

### 1. p9 文件系统通信问题

p9 (9P协议) 是 WSL2 用于 Windows 和 Linux 之间文件共享的关键组件。p9io.cpp 异常通常与以下因素有关：
- WSL2 虚拟机资源压力
- 跨文件系统频繁访问
- Windows 端 WSL 服务问题

### 2. Fedora 升级后遗症

`rpm -Va` 检查发现大量文件权限/状态异常：
- `/etc/grub.d/` 目录权限问题
- `polkit` 目录权限问题
- 多个配置文件缺失或损坏

### 3. 系统资源状况

- 内存：充足（31GB 总计，29GB 可用）
- C 盘：89% 使用率（35GB 可用）- 偏紧张
- WSL 虚拟磁盘：66GB/1007GB

## 修复步骤

### 阶段一：Windows 端操作（推荐优先执行）

#### 1. 重启 WSL 服务

```powershell
# 以管理员打开 PowerShell
wsl --shutdown
# 等待 10 秒
# 重新打开 WSL
```

#### 2. 添加 WSL 内存限制

在 Windows 用户目录 `%USERPROFILE%\.wslconfig` 创建文件：

```ini
[wsl2]
memory=8GB
processors=4
swap=4GB
localhostForwarding=true
```

然后重启：
```powershell
wsl --shutdown
```

#### 3. 更新 WSL 内核

```powershell
wsl --update
```

#### 4. 检查 Windows 事件日志

```powershell
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-WindowsSubsystemForLinux/Operational'; StartTime=(Get-Date).AddDays(-1)} -MaxEvents 30
```

#### 5. 清理 Windows C 盘空间（降低磁盘压力）

```powershell
# 清理 Windows 更新缓存
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase

# 清理临时文件
cleanmgr /d C
```

### 阶段二：Fedora 系统修复（WSL 内部操作）

#### 1. 修复 DNF 缓存

```bash
mkdir -p /var/cache/dnf
dnf clean all
dnf makecache
```

#### 2. 重建 RPM 数据库

```bash
rm -f /var/lib/rpm/__db.*
rpm --rebuilddb
dnf check
```

#### 3. 同步系统包到正确版本

```bash
dnf distro-sync --refresh
```

#### 4. 修复 polkit 目录权限

```bash
mkdir -p /etc/polkit-1/localauthority/10-vendor.d
mkdir -p /etc/polkit-1/localauthority/20-org.d
mkdir -p /etc/polkit-1/localauthority/30-site.d
mkdir -p /etc/polkit-1/localauthority/50-local.d
mkdir -p /etc/polkit-1/localauthority/90-mandatory.d
chown -R polkitd:polkitd /etc/polkit-1/localauthority
chmod 700 /etc/polkit-1/localauthority
```

### 阶段三：重建 WSL 实例（终极方案）

如果以上方法无效，执行以下操作：

```powershell
# 1. 导出当前发行版
wsl --export Fedora42 D:\fedora42_backup.tar

# 2. 注销当前发行版
wsl --unregister Fedora42

# 3. 重新导入
wsl --import Fedora42 D:\wsl\fedora42 D:\fedora42_backup.tar

# 4. 设置默认用户（如果需要）
ubuntu config --default-user username
```

## 资源清理建议

### 重启 Docker（清理长期运行的容器）

```bash
sudo systemctl restart docker
```

或清理不需要的容器：
```bash
docker container prune -f
docker image prune -f
```

### 关闭不需要的 VSCode 远程连接

在 VSCode 中关闭不需要的远程窗口，减少资源占用。

## 预防措施

1. **避免中断升级过程**：Fedora 升级时确保电源稳定，不要强制重启
2. **定期清理 Windows 磁盘空间**：保持 C 盘至少 20% 空闲
3. **监控 WSL 资源使用**：通过 `.wslconfig` 限制内存防止过度使用
4. **重要数据定期备份**：使用 `wsl --export` 备份

## 注意事项

- WSL2 使用自己的内置 Linux 内核，不依赖传统 GRUB 引导
- Fedora 在 WSL 中的 systemd 支持需要通过 `/etc/wsl.conf` 启用
- 如果使用 Docker Desktop for Windows，确保 WSL 与 Docker 资源分配合理
