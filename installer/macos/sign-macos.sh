#!/bin/bash

#Configuration Variables and Parameters

#Parameters
CWD=`dirname $0`
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
TARGET_DIRECTORY="$SCRIPTPATH/target"
PRODUCT=${1}
VERSION=${2}
DATE=`date +%Y-%m-%d`
TIME=`date +%H:%M:%S`
LOG_PREFIX="[$DATE $TIME]"
APPLE_DEVELOPER_CERTIFICATE_ID="Hongwei Liu"

function printSignature() {
  echo ' '
}

function printUsage() {
  echo -e "\033[1mUsage:\033[0m"
  echo "$0 [APPLICATION_NAME] [APPLICATION_VERSION]"
  echo
  echo -e "\033[1mOptions:\033[0m"
  echo "  -h (--help)"
  echo
  echo -e "\033[1mExample::\033[0m"
  echo "$0 wso2am 2.6.0"

}

#Start the generator
printSignature

#Argument validation
if [[ "$1" == "-h" ||  "$1" == "--help" ]]; then
    printUsage
    exit 1
fi
if [ -z "$1" ]; then
    echo "Please enter a valid application name for your application"
    echo
    printUsage
    exit 1
else
    echo "Application Name : $1"
fi
if [[ "$2" =~ [0-9]+.[0-9]+.[0-9]+ ]]; then
    echo "Application Version : $2"
else
    echo "Please enter a valid version for your application (format [0-9].[0-9].[0-9])"
    echo
    printUsage
    exit 1
fi

#Functions
go_to_dir() {
    pushd $1 >/dev/null 2>&1
}

log_info() {
    echo "${LOG_PREFIX}[INFO]" $1
}

log_warn() {
    echo "${LOG_PREFIX}[WARN]" $1
}

log_error() {
    echo "${LOG_PREFIX}[ERROR]" $1
}


#Main script
log_info "Installer generating process started."

function signApp(){
    APP_PATH="./aipy.app"
    ENTITLEMENTS_PATH="$CWD/entitlements.plist"

    find "${APP_PATH}" -path '*.framework/Versions/A/*' -type f -perm +111 | while read -r EXECUTABLE
    do
        codesign --force --entitlements "${ENTITLEMENTS_PATH}" --verify --verbose \
            --sign "Developer ID Application: ${APPLE_DEVELOPER_CERTIFICATE_ID}" --timestamp --options=runtime \
            "${EXECUTABLE}"
    done

    # codesign --force --entitlements "${ENTITLEMENTS_PATH}" --verify --verbose \
    #     --sign "Developer ID Application: ${APPLE_DEVELOPER_CERTIFICATE_ID}" --timestamp --options=runtime \
    #     "./aipy.app/Contents/MacOS/PySide6/Qt/lib/QtWebEngineCore.framework/Helpers/QtWebEngineProcess.app"

    codesign --deep --force --entitlements "${ENTITLEMENTS_PATH}" --verify --verbose \
        --sign "Developer ID Application: ${APPLE_DEVELOPER_CERTIFICATE_ID}" --timestamp --options=runtime \
        ${APP_PATH}

}

rm -rf /_CodeSignature
rm -rf aipy.app/Contents/MacOS/pythoncli/_CodeSignature
signApp

# create dmg
log_info "Creating dmg file"
codesign -dvvv  aipy.app  
