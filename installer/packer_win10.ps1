#############################
# dos2unix packer_win10.sh
#
# fix: syntax error near unexpected token `$'{\r''
# 获取当前脚本的完整路径
$env:PYTHONUTF8 = "1"

$OutputEncoding = [System.Text.Encoding]::UTF8

$ScriptPath = $MyInvocation.MyCommand.Path

# 获取当前脚本所在的目录
$ScriptDir = Split-Path $ScriptPath -Parent
$SrcDir = $ScriptDir + "/../"
# 改变工作目录到脚本所在目录
Set-Location -Path $SrcDir

# 获取当前工作目录的路径
$CDIR = Get-Location

# 打印当前目录，验证是否正确改变了工作目录
Write-Host "Current Directory: $CDIR"
$env:CLCACHE_DIR = "C:\ccache"
$env:ENVIRON = "dev"
$env:ENVIRON_LOG = "all"
$env:PATH = "C:\Python313\;C:\Python313\Scripts\;" + $env:PATH

python -m pip install -r ../installer/requirements.txt -i https://mirrors.cloud.tencent.com/pypi/simple

# 改变工作目录到脚本所在目录
Set-Location -Path $CDIR
Write-Host "Current Directory: $CDIR"

$folderPath = "aipyapp.onefile-build"
if (Test-Path $folderPath) {
    Remove-Item $folderPath -Recurse -Force
}
$folderPath = "aipyapp.dist"
if (Test-Path $folderPath) {
    Remove-Item $folderPath -Recurse -Force
}
Get-ChildItem -Path . -Filter *.exe | Remove-Item -Force

function Convert-Number {
    param (
        [string]$num
    )
    $len = $num.Length
    if ($len -le 2) {
        Write-Output "0.$num"
    }
    elseif ($len -eq 3) {
        $major = "0"
        $minor = [convert]::ToInt32($num.Substring(0,1), 10)
        $patch = [convert]::ToInt32($num.Substring(1), 10)
        Write-Output "$major.$minor.$patch"
    }
    elseif ($len -eq 4) {
        $major = "0"
        $minor = [convert]::ToInt32($num.Substring(0,2), 10)
        $patch = [convert]::ToInt32($num.Substring(2), 10)
        Write-Output "$major.$minor.$patch"
    }
    elseif ($len -eq 5) {
        $major = [convert]::ToInt32($num.Substring(0,1), 10)
        $minor = [convert]::ToInt32($num.Substring(1,2), 10)
        $patch = [convert]::ToInt32($num.Substring(3), 10)
        Write-Output "$major.$minor.$patch"
    }
    elseif ($len -ge 6) {
        $major = [convert]::ToInt32($num.Substring(0,2), 10)
        $minor = [convert]::ToInt32($num.Substring(2,2), 10)
        $patch = [convert]::ToInt32($num.Substring(4), 10)
        Write-Output "$major.$minor.$patch"
    }
}

# Usage examples
# $version = Convert-Number -num "123"
# $version = Convert-Number -num "1234"
# $version = Convert-Number -num "6860"
# $version = Convert-Number -num "12345"
# $version = Convert-Number -num "123456"
# Write-Host "Version: $version"

$CI_PIPELINE_ID = if ($null -eq $env:CI_PIPELINE_ID) { "111" } else { $env:CI_PIPELINE_ID }
$VERSION = Convert-Number -num $CI_PIPELINE_ID
Write-Host "Version: $VERSION"
# --onefile `
# --onefile-tempdir-spec="{CACHE_DIR}/{PRODUCT}" `
# --plugin-enable=pywebview `
# --lto=yes `
python -m nuitka `
--jobs=16 `
--remove-output `
--assume-yes-for-downloads `
--show-scons `
--disable-console `
--windows-disable-console `
--standalone  `
--python-flag=no_site,no_docstrings,isolated `
--windows-icon-from-ico=aipyapp/res/aipy.ico  `
--include-package="certifi"  `
--include-package="PIL"  `
--include-package="websockets"  `
--show-progress `
`
--nofollow-import-to=astropy `
--nofollow-import-to=sympy `
--nofollow-import-to=dask `
`
--nofollow-import-to=ipywidgets `
--nofollow-import-to=ipython_genutils `
--nofollow-import-to=ipykernel `
`
--nofollow-import-to=IPython `
--nofollow-import-to=pexpect `
--nofollow-import-to=nbformat `
`
--nofollow-import-to=numpydoc `
--nofollow-import-to=matplotlib `
--nofollow-import-to=pandas `
`
--nofollow-import-to=pytest `
--noinclude-pytest-mode=nofollow `
--noinclude-setuptools-mode=nofollow `
--nofollow-import-to=nose `
--macos-create-app-bundle `
`
--include-data-dir=./res=aipyapp/res `
--include-data-dir=./python=C:\Python313_clean `
`
--macos-app-version=${VERSION} `
--macos-signed-app-name='com.knownsec.aipyapp' `
--macos-app-name=aipyapp `
--macos-app-mode=gui `
`
--company-name='knownsec.inc' `
--product-name='knownsec' `
--copyright='Copyright 2025 knownsec' `
--trademarks='knownsec' `
--product-version=${VERSION} `
--file-version=${VERSION} `
`
--follow-imports aipyapp.py

#  使用Chocolatey包管理器安装Inno Setup
#  choco install innosetup

$CDIR = $ScriptDir + "/../"
Set-Location -Path $CDIR
Write-Host "Current Directory: $CDIR"

Write-Host "Creating installer from script."
iscc /F"installer" "WindowsInnoSetup.iss"

Write-Host "uploading installer"
Write-Host "$env:CI_COMMIT_TITLE"
$env:VERSION = "$VERSION"

python installer/win/InnoSetup/upload.py

