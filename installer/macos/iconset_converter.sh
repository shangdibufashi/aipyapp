#!/bin/bash

set -ex
CWD=`dirname $0`
cd $CWD

# 定义变量
ICON_SOURCE=aipy.png
APP_NAME=aipy

# 生成 .icns 图标文件
rm -rf my.iconset
mkdir -p my.iconset
# sips -g pixelWidth -g pixelHeight $ICON_SOURCE
sips -z 16 16 $ICON_SOURCE --out my.iconset/icon_16x16.png
sips -z 32 32 $ICON_SOURCE --out my.iconset/icon_16x16@2x.png
sips -z 32 32 $ICON_SOURCE --out my.iconset/icon_32x32.png
sips -z 64 64 $ICON_SOURCE --out my.iconset/icon_32x32@2x.png
sips -z 128 128 $ICON_SOURCE --out my.iconset/icon_128x128.png
sips -z 256 256 $ICON_SOURCE --out my.iconset/icon_128x128@2x.png
sips -z 256 256 $ICON_SOURCE --out my.iconset/icon_256x256.png
sips -z 512 512 $ICON_SOURCE --out my.iconset/icon_256x256@2x.png
sips -z 512 512 $ICON_SOURCE --out my.iconset/icon_512x512.png
sips -z 1024 1024 $ICON_SOURCE --out my.iconset/icon_512x512@2x.png
# sips -g pixelWidth -g pixelHeight my.iconset/*
ls -alh my.iconset
iconutil -c icns my.iconset -o $APP_NAME.icns
rm -rf my.iconset
