unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,System.IOUtils,KMD5,System.Types,System.Zlib;

type
  TfrmMain = class(TForm)
    mmo_log: TMemo;
    Label1: TLabel;
    cbb_cfg: TComboBox;
    edt_tools_path: TLabeledEdit;
    lbledt_config_latfix: TLabeledEdit;
    btn_pull: TButton;
    chk_compress_config: TCheckBox;
    mmo_configtxt: TMemo;
    btn1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btn_pullClick(Sender: TObject);
    procedure btn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    FPartConfig : TStringList;
    FTargetPath :TStringList;
    FToolsPath:String;
    FTargetJsonPath:String;
    procedure LoadPartConfig();
    procedure LoadTargetPathConfig();
    procedure UpdatePartFile();
    procedure PackConfig();
    procedure DropLuaConfigTxt(const DirName:String);
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}


function RunWait(FileName: string; WorkDir: String;
Visibility: Integer): THandle;
var
  zAppName: array [0 .. 102400] of Char;
  zCurDir: array [0 .. 255] of Char;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  ExitCode: Cardinal;
begin
  StrPCopy(zAppName, FileName);
  StrPCopy(zCurDir, WorkDir);
  FillChar(StartupInfo, SizeOf(StartupInfo), #0);
  StartupInfo.cb := SizeOf(StartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := Visibility;
  if not CreateProcess(nil, zAppName, nil, nil, False, Create_NEW_CONSOLE or
    NORMAL_PRIORITY_CLASS, nil, @zCurDir[0], StartupInfo, ProcessInfo) then
  begin
    Result := 0;
    Exit;
  end
  else
  begin
    WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
    GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);
  end;
end;

{ TfrmMain }

procedure TfrmMain.btn1Click(Sender: TObject);
begin
  DropLuaConfigTxt('Client_Bak');
  RunWait(FToolsPath + '\lua2json\lua2json.exe', FToolsPath + '\lua2json\' , 5);
end;

procedure TfrmMain.btn_pullClick(Sender: TObject);
var
  I:Integer;
begin
  FTargetJsonPath := '';
  if cbb_cfg.ItemIndex >= 0 then
  begin
    FTargetJsonPath := cbb_cfg.Items[cbb_cfg.ItemIndex];
  end;

  if not DirectoryExists(FTargetJsonPath) then
  begin
    mmo_log.Lines.Add('生成目标路径不存在无法生成....');
    Exit;
  end;


  UpdatePartFile();
  mmo_log.Lines.Add('更新配置文件完成....');

  PackConfig();
end;

procedure TfrmMain.DropLuaConfigTxt(const DirName:String);
var
  List : TStringList;
begin
  List := TStringList.Create();
  List.Assign(mmo_configtxt.Lines);
  List[26] := StringReplace(List[26],'client_bak',DirName,[rfReplaceAll]);

  List.SaveToFile(FToolsPath + '\lua2json\config.txt',TEncoding.ANSI);
  List.Free;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  LoadPartConfig();
  LoadTargetPathConfig();
end;

procedure TfrmMain.LoadPartConfig;
var
  PartConfigFileName:String;
begin
  PartConfigFileName := ExtractFilePath(GetModuleName(HInstance)) + '\PartConfig.txt';
  if not FileExists(PartConfigFileName) then
  begin
    mmo_log.Lines.Add('PartConfig.txt 文件不存在 无法读取');
    Exit;
  end;

  FPartConfig := TStringList.Create;
  FPartConfig.LoadFromFile(PartConfigFileName);

end;

procedure TfrmMain.LoadTargetPathConfig;
var
  PartConfigFileName:String;
  I:Integer;
begin
  PartConfigFileName := ExtractFilePath(GetModuleName(HInstance)) + '\H5Config.txt';

  if not FileExists(PartConfigFileName) then
  begin
    mmo_log.Lines.Add('H5Config.txt 文件不存在 无法读取');
    Exit;
  end;

  FTargetPath := TStringList.Create;
  FTargetPath.LoadFromFile(PartConfigFileName);

  for I := FTargetPath.Count - 1 downto 0 do
  begin
    if Trim(FTargetPath[i]) = '' then
      FTargetPath.Delete(i);
  end;

  if FTargetPath.Count < 2 then
  begin
    mmo_log.Lines.Add('H5Config.txt 文件行数不足两行 第一行 至倒数第二行为目标路径配置 最后一行为工具目录配置');
    FTargetPath.Free;
    FTargetPath := nil;
    Exit;
  end;


  FToolsPath := FTargetPath[FTargetPath.Count - 1];

  FTargetPath.Delete(FTargetPath.Count - 1);

  cbb_cfg.Items.Assign(FTargetPath);

  if cbb_cfg.Items.Count >= 1 then
    cbb_cfg.ItemIndex := 0;


  edt_tools_path.Text := FToolsPath;

end;

procedure TfrmMain.PackConfig;
var
  I:Integer;
  BasePath : String;
  M:TMemoryStream;
  ZOutBuffer : Pointer;
  ZOutSize : Integer;
  TargetJsonName:String;
begin
  BasePath := ExtractFilePath(GetModuleName(HInstance));
  for I := 1 to 4 do
  begin
    mmo_log.Lines.Add('打包配置: Config' + I.ToString() + ' , 是否压缩:' + chk_compress_config.Checked.ToString(True) );
    DropLuaConfigTxt('config' + I.ToString());
    RunWait(FToolsPath + '\lua2json\lua2json.exe', FToolsPath + '\lua2json\' , 5);
    if chk_compress_config.Checked then
    begin
      M := TMemoryStream.Create;
      M.LoadFromFile(FToolsPath + '\lua2json\config.json');
      ZCompress(M.Memory,M.Size,ZOutBuffer,ZOutSize);
      M.Position := 0;
      M.Size := 0;
      M.Write(ZOutBuffer^,ZOutSize);
      TargetJsonName := FTargetJsonPath + '\config' + I.ToString() + lbledt_config_latfix.Text + '.zz';
      M.SaveToFile(TargetJsonName);
      M.Free;
    end else
    begin
      TargetJsonName := FTargetJsonPath + '\config' + I.ToString() + lbledt_config_latfix.Text + '.json';
      TFile.Copy(FToolsPath + '\lua2json\config.json',TargetJsonName,true);
    end;
  end;

  mmo_log.Lines.Add('打包完毕...')
end;

procedure TfrmMain.UpdatePartFile;
var
  I:Integer;
  MoudlePath  , SourcePath , TargetPath : String;
  nPos : Integer;
begin
  MoudlePath := ExtractFilePath(GetModuleName(HInstance));
  for I := 0 to FPartConfig.Count - 1 do
  begin
    TargetPath := MoudlePath + FPartConfig[i];
    nPos := Pos('\',FPartConfig[i]);
    if nPos < 0 then
      Continue;

    SourcePath := MoudlePath + 'client' +  Copy(FPartConfig[i],nPos , Length(FPartConfig[i]));

    if not FileExists(SourcePath) then
    begin
      mmo_log.Lines.Add('未能找到更新源文件:' + SourcePath);
      Continue;
    end;

    if not DirectoryExists(ExtractFilePath(TargetPath)) then
    begin
      ForceDirectories(ExtractFilePath(TargetPath));
    end;

    if FileExists(TargetPath) then
    begin
      if KMD5.FileToMD5(SourcePath) <> KMD5.FileToMD5(TargetPath)  then
      begin
        mmo_log.Lines.Add('更新变更文件:' + TargetPath);
        TFile.Copy(SourcePath,TargetPath,True);
      end;
    end else
    begin
      mmo_log.Lines.Add('目标文件不存在直接拷贝:' + TargetPath);
      TFile.Copy(SourcePath,TargetPath,True);
    end;

  end;
end;

end.
