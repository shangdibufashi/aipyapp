# coding: utf-8

# init dynamical pip package path
import os
import sys
from pathlib import Path
config_dir = Path.home() / f".aipy_packages"
config_dir.mkdir(parents=True, exist_ok=True)
pos=int(os.environ.get('PATH_POS', -1))
if pos < 0:
    sys.path.append(str(config_dir.resolve()))
else:
    sys.path.insert(pos, str(config_dir.resolve()))
print(f'sys.path={sys.path}')
os.environ['pip_packages'] = str(config_dir.resolve())
pwd = os.path.dirname((os.path.abspath(__file__)))
ext = '.exe' if sys.platform == 'win32' else ''
pythonexe = Path(pwd) / 'python' / f'python{ext}'
if pythonexe.exists():
    os.environ['pythonexe'] = str(pythonexe)

# 强制引用
# 预装的第三方模块有：`requests`、`numpy`、`pandas`、`matplotlib`、`seaborn`、`bs4`、`googleapiclient`。
import matplotlib
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import googleapiclient as gg
import bs4
import requests

from loguru import logger
from aipyapp.gui.main import main as aipy_main
from aipyapp.aipy.config import CONFIG_DIR


# 日志配置
logger.remove()
logger.add(CONFIG_DIR / "aipyapp.log", format="{time:HH:mm:ss} | {level} | {message} | {extra}", level='INFO')

class Logger:
    def __init__(self, file_path=os.devnull):
        self.terminal = sys.stdout
        self.log = open(file_path, "a", encoding="utf-8")

    def write(self, message):
        self.terminal.write(message)
        self.log.write(message)

    def flush(self):
        self.terminal.flush()
        self.log.flush()

def parse_args():
    import argparse
    
    config_help_message = (
        f"Specify the configuration directory.\nDefaults to {CONFIG_DIR} if not provided."
    )

    parser = argparse.ArgumentParser(description="Python use - AIPython", formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument("-c", '--config-dir', type=str, help=config_help_message)
    parser.add_argument('--level', type=str, default='INFO', help="Log level")
    parser.add_argument('-p', '--python', default=False, action='store_true', help="Python mode")
    parser.add_argument('-g', '--gui', default=False, action='store_true', help="GUI mode")
    parser.add_argument('--debug', default=False, action='store_true', help="Debug mode")
    parser.add_argument('-f', '--fetch-config', default=False, action='store_true', help="login to trustoken and fetch token config")
    parser.add_argument('cmd', nargs='?', default=None, help="Task to execute, e.g. 'Who are you?'")
    args = parser.parse_args()
    logger.level(args.level)
    return args

def env_pkg_debug():
    print(f"pip package: {str(config_dir.resolve())}")
    print(f"paths: {sys.path}")
    print('pythonexe', os.environ.get('pythonexe', ''))
    print('pip_packages', os.environ.get('pip_packages', ''))
    cmd = [
        os.environ.get('pythonexe', ''),
        '-m',
        'pip',
        'install',
        '-q',
        '--target',
        os.environ.get('pip_packages', ''),
        'tqdm', 
    ]
    
    import subprocess
    print(" ".join(cmd))
    cp = subprocess.run(cmd)
    assert cp.returncode == 0
    from tqdm import tqdm

def mainw():
    args = parse_args()
    if not args.debug:
        sys.stdout = Logger()
        sys.stderr = Logger()
    else:
        env_pkg_debug()
    aipy_main(args)

if __name__ == '__main__':
    mainw()
