
function convert_number() {
    num="$1"
    len="${#num}"
    if [ "$len" -le 2 ]; then
        echo "0.$((10#$num))"
    elif [ "$len" -eq 3 ]; then
        major="0"
        minor=$((10#$(echo "$num" | cut -c1)))
        patch=$((10#$(echo "$num" | cut -c2-)))
        echo "${major}.${minor}.${patch}"
    elif [ "$len" -eq 4 ]; then
        major="0"
        minor=$((10#$(echo "$num" | cut -c1-2)))
        patch=$((10#$(echo "$num" | cut -c3-)))
        echo "${major}.${minor}.${patch}"
    elif [ "$len" -eq 5 ]; then
        major=$((10#$(echo "$num" | cut -c1)))
        minor=$((10#$(echo "$num" | cut -c2-3)))
        patch=$((10#$(echo "$num" | cut -c4-)))
        echo "${major}.${minor}.${patch}"
    elif [ "$len" -ge 6 ]; then
        major=$((10#$(echo "$num" | cut -c1-2)))
        minor=$((10#$(echo "$num" | cut -c3-4)))
        patch=$((10#$(echo "$num" | cut -c5-)))
        echo "${major}.${minor}.${patch}"
    fi
}
CI_PIPELINE_ID="${CI_PIPELINE_ID:-111}"
VERSION=`convert_number ${CI_PIPELINE_ID}`
echo "Version: ${VERSION}"

FILE_NAME="engine-windows-installer-x64-$VERSION.exe"
build_platform="Windows"
FILE_URL="https://server.hulk.qianyueai.com:8443/fileserver/images/uploads/${FILE_NAME}"
CI_COMMIT_TITLE=$(echo "$CI_COMMIT_TITLE" | sed 's/"//g')

VERSION_DATA='{"version": "'$VERSION'", "arch": "'$build_platform'", "meta":{"detail": "'$CI_COMMIT_TITLE'", "title":"版本更新", "url": "'$FILE_URL'"}}'
echo "Version data: ${VERSION_DATA}"
URL="https://server.hulk.qianyueai.com:8443/backend/version/add/"
curl --fail -X POST "$URL" -H "Content-Type: application/json" -d "${VERSION_DATA}"  --insecure
if [ $? -ne 0 ]; then
    curl --fail -X POST "$URL" -H "Content-Type: application/json" -d "${VERSION_DATA}"  --insecure
    if [ $? -ne 0 ]; then
        curl --fail -X POST "$URL" -H "Content-Type: application/json" -d "${VERSION_DATA}"  --insecure
        if [ $? -ne 0 ]; then
            curl --fail -X POST "$URL" -H "Content-Type: application/json" -d "${VERSION_DATA}"  --insecure
            if [ $? -ne 0 ]; then
                curl --fail -X POST "$URL" -H "Content-Type: application/json" -d "${VERSION_DATA}"  --insecure
                if [ $? -ne 0 ]; then
                    curl --fail -X POST "$URL" -H "Content-Type: application/json" -d "${VERSION_DATA}"  --insecure
                    if [ $? -ne 0 ]; then
                        exit 1
                    fi
                fi
            fi
        fi
    fi
fi