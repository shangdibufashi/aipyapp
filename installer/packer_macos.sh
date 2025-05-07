#!/bin/bash

set -ex
CWD=`dirname $0`

$CWD/macos/packer_macos.sh
$CWD/macos/sign-macos.sh aipy 1.27.3
$CWD/macos/dmg_builder.sh
