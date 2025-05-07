#!/bin/bash

set -ex
CWD=`dirname $0`

$CWD/macos/packer_macos.sh
$CWD/macos/sign-macos.sh
$CWD/macos/dmg_builder.sh
