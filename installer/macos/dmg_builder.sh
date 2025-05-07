#!/bin/bash
# 一键生成 DMG 安装包脚本（依赖 create-dmg）
# 适用场景：macOS 系统，需提前安装 Homebrew 和 Xcode 命令行工具

# 参数配置（按需修改）
APP_NAME="aipy"                # 应用名称（与.app文件名一致）
DMG_NAME="aipy_installer"      # 输出 DMG 文件名
VOLUME_NAME="AIPY Installer"   # DMG 挂载卷标名称
BACKGROUND_IMG="background.png"# 背景图片路径（建议尺寸 600x400）
ICON_SOURCE="icon.png"         # 原始图标文件（需1024x1024尺寸）

# 检查依赖
if ! command -v create-dmg &> /dev/null; then
    echo "正在安装 create-dmg..."
    brew install create-dmg || { echo "安装失败，请先安装 Homebrew"; exit 1; }
fi

# 生成 .icns 图标文件
mkdir -p .iconset
sips -z 16 16     $ICON_SOURCE --out .iconset/icon_16x16.png
sips -z 32 32     $ICON_SOURCE --out .iconset/icon_16x16@2x.png
sips -z 32 32     $ICON_SOURCE --out .iconset/icon_32x32.png
sips -z 64 64     $ICON_SOURCE --out .iconset/icon_32x32@2x.png
sips -z 128 128   $ICON_SOURCE --out .iconset/icon_128x128.png
sips -z 256 256   $ICON_SOURCE --out .iconset/icon_256x256.png
iconutil -c icns .iconset -o $APP_NAME.icns

# 清理临时目录
rm -rf ./$DMG_NAME.dmg ./temp

# 创建临时目录结构
mkdir -p temp/.background
cp -r $APP_NAME.app temp/
cp $BACKGROUND_IMG temp/.background/
cp $APP_NAME.icns temp/.VolumeIcon.icns

# 生成 DMG 文件
create-dmg \
    --volname "$VOLUME_NAME" \
    --volicon "$APP_NAME.icns" \
    --background "$BACKGROUND_IMG" \
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
rm -rf temp .iconset $APP_NAME.icns

echo "✅ DMG 文件已生成：$DMG_NAME.dmg"