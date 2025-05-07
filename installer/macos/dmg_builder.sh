#!/bin/bash
# 一键生成 DMG 安装包脚本（依赖 create-dmg）
set -xe
CWD=`dirname $0`
# 参数配置（按需修改）
arch=$(uname -m)
APP_NAME="aipy"                 # 应用名称（与.app文件名一致）
DMG_NAME="aipy_installer_${arch}"       # 输出 DMG 文件名
VOLUME_NAME="AIPY Installer"    # DMG 挂载卷标名称
BACKGROUND_IMG="background.png" # 背景图片路径（建议尺寸 600x400）
ICNS_FILE="installer/macos/aipy.icns"          # 原始图标文件（需1024x1024尺寸）

# 检查依赖
if ! command -v create-dmg &> /dev/null; then
    echo "正在安装 create-dmg..."
    brew install create-dmg || { echo "安装失败，请先安装 Homebrew"; exit 1; }
fi

# 清理临时目录
rm -rf ./$DMG_NAME.dmg ./temp

# 创建临时目录结构
mkdir -p temp/.background
rsync -a $APP_NAME.app temp/
# cp $BACKGROUND_IMG temp/.background/
cp $ICNS_FILE temp/.VolumeIcon.icns

# 生成 DMG 文件
#    --background "$BACKGROUND_IMG" \
create-dmg \
    --volname "$VOLUME_NAME" \
    --volicon "$ICNS_FILE" \
    --window-pos 200 120 \
    --window-size 600 400 \
    --icon-size 100 \
    --icon "$APP_NAME.app" 100 200 \
    --hide-extension "$APP_NAME.app" \
    --app-drop-link 400 200 \
    --no-internet-enable \
    "$DMG_NAME.dmg" \
    "temp/"

# 清理临时文件
rm -rf temp

echo "✅ DMG 文件已生成：$DMG_NAME.dmg"

codesign --force --deep --sign "Developer ID Application: Hongwei Liu" $DMG_NAME.dmg
