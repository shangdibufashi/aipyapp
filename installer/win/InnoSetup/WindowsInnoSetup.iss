[Setup]
AppId=aipy
AppName=aipy
AppVersion=__VERSION__
AppPublisher=aipy
AppPublisherURL=http://www.aipy.com/
AppSupportURL=http://www.aipy.com/
AppUpdatesURL=http://www.aipy.com/
DefaultDirName={commonpf}\aipy
DefaultGroupName=aipy
AllowNoIcons=yes
OutputDir=./
OutputBaseFilename=aipy_x64
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
Source: "aipy.dist\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\aipy"; Filename: "{app}\aipy.exe"
Name: "{group}\{cm:UninstallProgram,aipy}"; Filename: "{uninstallexe}"
Name: "{commondesktop}\aipy"; Filename: "{app}\aipy.exe"; Tasks: desktopicon and commoninstall
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\aipy"; Filename: "{app}\aipy.exe"; Tasks: quicklaunchicon

[Run]
Filename: "{app}\aipy.exe"; Description: "start now"; Flags: nowait postinstall skipifsilent

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
  strCmdKill := Format('taskkill /f /t /im %s', [strExeName]);
  Success := Exec('cmd.exe', '/c ' + strCmdKill, '', SW_HIDE, ewWaitUntilTerminated, ExitCode);
  if not Success then
  begin
    ExitCode := 111; // 返回一个特殊的错误码表示执行失败
    Result := False;
    Exit;
  end;

  Result := True;
end;

function InitializeSetup(): Boolean;
var
  ExitCode: Integer;
begin

  // 调用 ForceTerminateRunningApp 并获取退出码
  ForceTerminateRunningApp('aipy.exe', ExitCode);
  ForceTerminateRunningApp('aipy.exe', ExitCode);
  ForceTerminateRunningApp('aipy.exe', ExitCode);

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

