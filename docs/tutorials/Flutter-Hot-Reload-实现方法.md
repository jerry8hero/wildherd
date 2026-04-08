# Flutter Hot Reload 实现方法

## 概述

Flutter 提供了多种高效的开发和测试方案，相比每次重装应用，Hot Reload 能大幅提升开发效率。

---

## 一、USB 有线连接（最简单）

### 步骤

```bash
# 1. 手机开启开发者选项 -> USB调试
# 2. 连接电脑，终端运行
flutter devices              # 查看已连接的设备

flutter run                   # 运行并启用Hot Reload
```

### 快捷键

| 操作 | Windows/Linux | macOS |
|------|---------------|-------|
| Hot Reload | `r` | `r` |
| Hot Restart | `R` | `R` |
| 退出 | `q` | `q` |

---

## 二、无线连接（推荐）

### 方法1：adb 无线调试

```bash
# 步骤1：USB连接手机，开启开发者选项
# 步骤2：设置TCPIP模式
adb tcpip 5555

# 步骤3：获取手机IP地址
# Android设置 -> 关于手机 -> IP地址

# 步骤4：断开USB，通过IP连接
adb connect 192.168.1.xxx:5555   # 替换为你的手机IP

# 步骤5：验证连接
flutter devices

# 步骤6：运行
flutter run
```

### 方法2：IDE 配置

#### VS Code

1. 按 `F5` 或点击调试按钮
2. 选择设备（无线连接的设备）
3. 修改代码后按 `F5` 或点击 Hot Reload 图标

#### Android Studio

1. `Run` → `Edit Configurations`
2. 添加 Flutter 设备（已无线连接的设备）
3. 调试运行

---

## 三、Hot Reload vs Hot Restart

| 类型 | 速度 | 状态保留 | 适用场景 |
|------|------|----------|----------|
| Hot Reload | ~1秒 | ✅ 保留 | UI调整、布局修改、代码逻辑修改 |
| Hot Restart | ~5秒 | ✅ 保留 | 初始化代码、static 变量修改 |

---

## 四、VS Code 快捷键

| 操作 | Windows/Linux | macOS |
|------|---------------|-------|
| Hot Reload | `Ctrl + Shift + \` | `Cmd + Shift + \` |
| Hot Restart | `Ctrl + F5` | `Cmd + F5` |
| 全量Reload | `Ctrl + Shift + F5` | `Cmd + Shift + F5` |

---

## 五、常见问题

| 问题 | 解决方案 |
|------|----------|
| adb找不到设备 | 确保手机已开启USB调试，可能需要授权 |
| 无线连接失败 | 确保手机和电脑在同一WiFi下 |
| Hot Reload不生效 | 部分底层代码修改需要Full Restart |

---

## 六、最佳实践

```bash
# 推荐工作流

# 1. 首次配置：USB连接手机，运行一次
flutter run

# 2. 启用无线调试
adb tcpip 5555
adb connect 手机IP:5555

# 3. 后续开发全部无线
flutter run

# 4. 修改代码后按 r 或 F5 热重载
```

---

## 七、不需要重装的替代方案

如果需要分发给测试人员或实现"不重装就更新"，可以考虑：

| 方案 | 说明 |
|------|------|
| **Shorebird** | Flutter 官方热更新方案，可更新 Dart 代码 |
| **Firebase App Distribution** | 免费内测分发 |
| **Codemagic** | Flutter 专用 CI/CD |

