# --static-libpython=yes \
# 在链接阶段，你可以使用 -Wl,-S 选项来告诉链接器删除所有的符号和重定位信息：
# ################################################################# sign
# How to run codesign for an app compiled by Nuitka on macOS?
# https://github.com/Nuitka/Nuitka/issues/1511
# --experimental=macos-sign-runtime
PYTHON_EXEC=${PYTHON_EXEC:-python3.13}
set -ex
pwd
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
VERSION="1.27.3"
echo "Version: ${VERSION}"


# https://www.python.org/downloads/macos/
export CCFLAGS='-Wl,-S'
# for macOS 10.9 and later	
# https://www.python.org/ftp/python/3.9.12/python-3.9.12-macosx10.9.pkg
# https://www.python.org/ftp/python/3.8.3/python-3.8.3-macosx10.9.pkg

rm -rf aipy.app

$PYTHON_EXEC -m nuitka \
--jobs=16 \
--lto=no \
--remove-output \
--assume-yes-for-downloads \
--show-scons \
--standalone  \
--python-flag=no_site,no_docstrings,isolated \
--macos-app-icon=aipyapp/res/aipy.ico \
--include-package="certifi"  \
--include-package="PIL"  \
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
\
--nofollow-import-to=pytest \
--noinclude-pytest-mode=nofollow \
--noinclude-setuptools-mode=nofollow \
--nofollow-import-to=nose \
--macos-create-app-bundle \
\
--include-package=googleapiclient.discovery \
--include-package=google.oauth2 \
--include-package=pygments \
--include-package=term_image \
--include-package=aipyapp \
--include-package-data=aipyapp \
--enable-plugin=matplotlib \
--enable-plugin=numpy \
\
--macos-app-version=${VERSION} \
--macos-signed-app-name='com.knownsec.aipy' \
--macos-app-name=aipy \
--macos-app-mode=gui \
\
--company-name='knownsec.inc' \
--product-name='knownsec' \
--copyright='Copyright 2025 knownsec' \
--trademarks='knownsec' \
--product-version=${VERSION} \
--file-version=${VERSION} \
\
--follow-imports aipy.py

rsync -av python aipy.app/Contents/MacOS/pythoncli

# rm -rf ~/Downloads/aipy.app &&  mv -f aipy.app ~/Downloads/
