import requests
import json
import os
import shutil
import sys
import codecs
import argparse
import io
import zipfile

def create_temp_zip(source_file, zip_name):
    """将目标文件压缩为临时ZIP包"""
    with zipfile.ZipFile(zip_name, 'w', zipfile.ZIP_STORED) as zipf:
        zipf.write(source_file, arcname=os.path.basename(source_file))
    return zip_name

def decode_str(value):
    encodings = ['gbk', 'cp1252', 'utf-8']  # 常见编码列表

    for encoding in encodings:
        try:
            return value.encode().decode(encoding)
        except (UnicodeDecodeError, UnicodeEncodeError):
            continue

    # 如果所有尝试都失败，返回原始值
    return value

def decode_env_variable(var_name):
    value = os.environ.get(var_name, '')
    encodings = ['utf-8', 'gbk', 'cp1252']  # 常见编码列表

    for encoding in encodings:
        try:
            return value.encode().decode(encoding)
        except (UnicodeDecodeError, UnicodeEncodeError):
            continue

    # 如果所有尝试都失败，返回原始值
    return value

def upload_file(url, file_name):
    for _ in range(6):
        try:
            with open(file_name, 'rb') as f:
                files = {'photo': f}
                response = requests.post(url, files=files, verify=False)
                response.raise_for_status()
                print("File upload response:", response.text)
                return True
        except requests.exceptions.RequestException as e:
            print("Error during file upload:", e)
    return False

def update_version(url, version_data):
    for _ in range(6):
        try:
            response = requests.post(url, json=version_data, verify=False)
            response.raise_for_status()
            print("Version update response:", response.text)
            return True
        except requests.exceptions.RequestException as e:
            print("Error during version update:", e)
    return False
"""

$env:PATH = "C:/Users/Docker/AppData/Local/Programs/Python/Python310/;" + $env:PATH
$env:CI_COMMIT_TITLE = "test 1.13.50"
$env:VERSION = "1.13.81"
python win/InnoSetup/upload.py

"""
def main(mode:str, commit:str):
    ci_commit_title = commit
    if 'upload' not in mode:
        print("Skip upload")
        sys.exit(1)
        return
    version=os.environ.get('VERSION', None)
    if version is None:
        raise ValueError(f"version is missing")
    print(f"version={version}")
        
    # Configuration
    src_name = "installer.exe"
    file_name = f"engine-windows-installer-x64-{version}.exe"
    print(f"file_name={file_name}")
    if not os.path.isfile(file_name):
        if not os.path.isfile(src_name):
            raise ValueError(f"file not found: {src_name}")
        os.rename(src_name, file_name)
    if not os.path.isfile(file_name):
        raise ValueError(f"file not found: {file_name}")
    
    build_platform = "Windows"

    # File upload
    url = f"https://server.hulk.qianyueai.com:8443/fileserver/save/uploads/{file_name}?overwrite=true"
    if not upload_file(url, file_name):
        exit(1)

    # Version update
    file_url = f"https://server.hulk.qianyueai.com:8443/fileserver/images/uploads/{file_name}"
    print(file_url)

    zip_name = create_temp_zip(file_name, f"{file_name[:-4]}.zip")
    print(f"zip_name {zip_name}")
    url = f"https://server.hulk.qianyueai.com:8443/fileserver/save/uploads/{zip_name}?overwrite=true"
    if not upload_file(url, zip_name):
        print(f"zip({zip_name}) file upload failed")
    
    file_url = f"https://server.hulk.qianyueai.com:8443/fileserver/images/uploads/{zip_name}"
    print(file_url)
    return
    
    ci_commit_title = ci_commit_title.replace('"', '')
    version_data = {
        "version": version,
        "arch": build_platform,
        "meta": {
            "detail": ci_commit_title,
            "title": "版本更新",
            "url": file_url
        }
    }
    url = "https://server.hulk.qianyueai.com:8443/backend/version/add/"
    if not update_version(url, version_data):
        exit(1)
    print("\n", file_url, "\n")

def mode_param():
    commit_title=os.environ.get('CI_COMMIT_TITLE', '')
    print(f"env:Commit Title: {commit_title}")
    
    parser = argparse.ArgumentParser(description='Process some parameters.')
    parser.add_argument('--commit-title', type=str, help='Commit title from CI in json format', default=commit_title)
    parser.add_argument('--mode', type=str, help='working mode', default='upload')
    args = parser.parse_args()
    commit_title = args.commit_title
    mode = args.mode
    PYTHONUTF8=os.environ.get('PYTHONUTF8', '0')
    print(f"PYTHONUTF8={PYTHONUTF8}")
    print(f"Commit Title: {commit_title}")
    main(mode, commit_title)


def mode_env():
    mode = 'upload'
    PYTHONUTF8=os.environ.get('PYTHONUTF8', '0')
    commit=os.environ.get('commit_title', '')
    print(f"PYTHONUTF8={PYTHONUTF8}")
    print(f"Commit Title: {commit}")
    
    commit = json.loads(commit)
    if commit is None or 'title' not in commit:
        raise ValueError(f"commit is missing: {commit}")
    commit=commit['title']
    print(f"commit={commit}")
    main(mode, commit)
    
if __name__ == '__main__':
    mode_param()