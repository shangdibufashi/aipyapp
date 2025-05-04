[Setup]
AppId=aipyapp
AppName=aipyapp
AppVersion=__VERSION__
AppPublisher=aipyapp
AppPublisherURL=http://www.aipyapp.com/
AppSupportURL=http://www.aipyapp.com/
AppUpdatesURL=http://www.aipyapp.com/
DefaultDirName={commonpf}\aipyapp
DefaultGroupName=aipyapp
AllowNoIcons=yes
OutputDir=./
OutputBaseFilename=aipyapp_x64
SetupIconFile=aipyapp/res/aipy.ico
WizardImageFile=./installer/win/InnoSetup/installerStrip.bmp
Compression=lzma
SolidCompression=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=none



[Tasks]
Name: "commoninstall"; Description: "Anyone who uses this computer (Multi-User Install)"; GroupDescription: "Install RawTherapee for:"; Flags: exclusive; Check: IsElevatedUser
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; 
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}";

[Files]
Source: "aipyapp\aipyapp.dist\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\aipyapp"; Filename: "{app}\aipyapp.exe"
Name: "{group}\{cm:UninstallProgram,aipyapp}"; Filename: "{uninstallexe}"
Name: "{commondesktop}\aipyapp"; Filename: "{app}\engine.exe"; Tasks: desktopicon and commoninstall
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\aipyapp"; Filename: "{app}\engine.exe"; Tasks: quicklaunchicon

[Run]
Filename: "{app}\aipyapp.exe"; Description: "start now"; Flags: nowait postinstall skipifsilent

[Code]
function IsElevatedUser(): Boolean;
begin
  Result := IsAdminInstallMode or IsPowerUserLoggedOn;
end;

// 自定义函数，用于检测并立即强制终止指定的软件（不提示用户）
function ForceTerminateRunningApp(strExeName: String; var ExitCode: Integer): Boolean;
var
  strCmdKill: String; // 终止软件命令
  Success: Boolean;
begin
  // 构建 taskkill 命令以强制终止指定的 .exe 文件
  strCmdKill := Format('taskkill /f /t /im %s', [strExeName]);
  
  // 使用 Exec 执行 cmd 命令，参数说明：
  // 'cmd.exe' 是指代 Windows 命令提示符的位置。
  // '/c ' + strCmdKill 是要执行的具体命令字符串。
  // '' 表示工作目录为空。
  // SW_HIDE 隐藏窗口。
  // ewWaitUntilTerminated 等待命令完成再返回控制权给安装程序。
  Success := Exec('cmd.exe', '/c ' + strCmdKill, '', SW_HIDE, ewWaitUntilTerminated, ExitCode);
  
  // 检查 Exec 执行结果
  // taskkill 返回码解释:
  // 0 - 成功终止一个或多个进程
  // 1 - 指定的进程没有找到
  // 2 - 访问被拒绝
  // 3 - 其他错误

  // 检查 Exec 执行结果
  if not Success then
  begin
    ExitCode := 111; // 返回一个特殊的错误码表示执行失败
    Result := False;
    Exit;
  end;

  // 返回 True 表示命令成功执行
  Result := True;
end;

// 在 InitializeSetup 事件中调用 ForceTerminateRunningApp 函数
function InitializeSetup(): Boolean;
var
  ExitCode: Integer;
begin

  // 调用 ForceTerminateRunningApp 并获取退出码
  ForceTerminateRunningApp('engine.exe', ExitCode);
  ForceTerminateRunningApp('engine.exe', ExitCode);
  ForceTerminateRunningApp('engine.exe', ExitCode);

  // 根据退出码处理不同的情况
  case ExitCode of
    0:
      begin
        Result := True;
      end;
    1:
      begin
        Result := True;
      end;
    else
      begin
        // MsgBox(Format('无法终止正在运行的程序。请重启后并重试安装 (Return code: %d)', [ExitCode]), mbError, MB_OK);
        Result := True;
      end;
  end;

end;

