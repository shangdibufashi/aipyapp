# --static-libpython=yes \
# 在链接阶段，你可以使用 -Wl,-S 选项来告诉链接器删除所有的符号和重定位信息：
# ################################################################# sign
# How to run codesign for an app compiled by Nuitka on macOS?
# https://github.com/Nuitka/Nuitka/issues/1511
# --experimental=macos-sign-runtime
PYTHON_EXEC=${PYTHON_EXEC:-python3.10}
set -ex
pwd
BN='./core/workers/matting/build_numba.sh'
if [ ! -f "$BN" ]; then
    echo "file not found: $BN"
    exit 1
fi
$BN
ls -alh ./core/workers/matting/ | grep so
function convert_number() {
    num="$1"
    len=${#num}
    if (( len <= 2 )); then
        echo "0.$((10#$num))"
    elif (( len == 3 )); then
        major="0"
        minor=$((10#${num:0:1}))
        patch=$((10#${num:1}))
        echo "${major}.${minor}.${patch}"
    elif (( len == 4 )); then
        major="0"
        minor=$((10#${num:0:2}))
        patch=$((10#${num:2}))
        echo "${major}.${minor}.${patch}"
    elif (( len == 5 )); then
        major=$((10#${num:0:1}))
        minor=$((10#${num:1:2}))
        patch=$((10#${num:3}))
        echo "${major}.${minor}.${patch}"
    elif (( len >= 6 )); then
        major=$((10#${num:0:2}))
        minor=$((10#${num:2:2}))
        patch=$((10#${num:4}))
        echo "${major}.${minor}.${patch}"
    fi
}

# convert_number 100
# convert_number 101
# convert_number 1001
# convert_number 10001
# convert_number 100001
# convert_number 123
# convert_number 1234
# convert_number 6860
# convert_number 12345
# convert_number 123456

CI_PIPELINE_ID="${CI_PIPELINE_ID:-111}"
VERSION=`convert_number ${CI_PIPELINE_ID}`
echo "Version: ${VERSION}"

################################################################ installer
# https://github.com/KosalaHerath/macos-installer-builder
# https://medium.com/swlh/the-easiest-way-to-build-macos-installer-for-your-application-34a11dd08744

# https://www.python.org/downloads/macos/
export CCFLAGS='-Wl,-S'
# for macOS 10.9 and later	
# https://www.python.org/ftp/python/3.9.12/python-3.9.12-macosx10.9.pkg
# https://www.python.org/ftp/python/3.8.3/python-3.8.3-macosx10.9.pkg


$PYTHON_EXEC -m nuitka \
--jobs=16 \
--lto=no \
--remove-output \
--assume-yes-for-downloads \
--show-scons \
--disable-console \
--windows-disable-console \
--standalone  \
--python-flag=no_site,no_docstrings,isolated \
--macos-app-icon=assets/logo.png \
--include-package="certifi"  \
--include-package="PIL"  \
--include-package="websockets"  \
--include-package="glfw"  \
--include-package="pyairaw"  \
--show-progress \
\
--nofollow-import-to=astropy \
--nofollow-import-to=sympy \
--nofollow-import-to=dask \
\
--nofollow-import-to=ipywidgets \
--nofollow-import-to=ipython_genutils \
--nofollow-import-to=ipykernel \
\
--nofollow-import-to=IPython \
--nofollow-import-to=pexpect \
--nofollow-import-to=nbformat \
\
--nofollow-import-to=numpydoc \
--nofollow-import-to=matplotlib \
--nofollow-import-to=pandas \
\
--nofollow-import-to=pytest \
--noinclude-pytest-mode=nofollow \
--noinclude-setuptools-mode=nofollow \
--nofollow-import-to=nose \
--macos-create-app-bundle \
\
--include-data-dir=./assets=assets \
\
--macos-app-version=${VERSION} \
--macos-signed-app-name='com.qianyueai.engine' \
--macos-app-name=engine \
--macos-app-mode=gui \
\
--company-name='Feiyan.inc' \
--product-name='Feiyan' \
--copyright='Copyright 2023 Feiyan' \
--trademarks='Feiyan' \
--product-version=${VERSION} \
--file-version=${VERSION} \
\
--follow-imports engine.py

# rm -rf ~/Downloads/engine.app &&  mv -f engine.app ~/Downloads/
