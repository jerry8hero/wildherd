#!/bin/bash
# 启动脚本 - 支持在 WSLg 中使用 Windows 端输入法

export GTK_IM_MODULE=xim
export QT_IM_MODULE=xim
export XMODIFIERS=@im=xim

flutter run -d linux "$@"
