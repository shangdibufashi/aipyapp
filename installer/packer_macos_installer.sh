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
VERSION=`convert_number ${CI_PIPELINE_ID}`
echo "Version: ${VERSION}"
echo "build_platform: ${build_platform}"

# docker pull registry.cn-hangzhou.aliyuncs.com/raised/hulk:hulk-macos-installer-builder
set -ex

[ ! -d macOS-x64 ] && rm -rf macOS-x64
git clone https://$CI_GIT_USER:$CI_GIT_PASS@git.raisedtech.cn/zeus/hulk/hulk-macos-installer-builder.git/
# docker run  --rm  -v `pwd`:/data registry.cn-hangzhou.aliyuncs.com/raised/hulk:hulk-macos-installer-builder cp -rf /app/macOS-x64 /data/
cp -rf hulk-macos-installer-builder/macOS-x64 macOS-x64
rm -rf hulk-macos-installer-builder
ls -alh  macOS-x64/application/
#[ ! -f macOS-x64/application/engine.app ] && ln -s  engine.app macOS-x64/application/
mv engine.app macOS-x64/application/
chmod +x ./macOS-x64/build-macos-aipy.sh
./macOS-x64/build-macos-aipy.sh engine ${VERSION}

ls -lhr ./macOS-x64/target

du -h -d 2 ./macOS-x64/target

