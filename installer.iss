; SimTurnsAI Patch installer v1.0.5

#define MyAppName "SimTurnsAI Patch"
#define MyAppVersion "1.0.5"
#define MyAppPublisher "Imagundi"
#define MyAppURL "https://steamcommunity.com/id/Imagundi/"
#define MyBoostyURL "https://boosty.to/imagundi"
#define AssetDir "installer_assets"

[Setup]
AppId={{A7B3C9E1-4F2D-4A8B-9C1E-SIMTURNSAI01}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
DefaultDirName={autopf}\SimTurnsAI Patch
DisableDirPage=yes
DisableProgramGroupPage=yes
OutputBaseFilename=SimTurnsAI_Patch_Setup_v{#MyAppVersion}
OutputDir=..
Compression=lzma2
SolidCompression=yes
WizardStyle=classic
PrivilegesRequired=lowest
ShowLanguageDialog=no
SetupIconFile={#AssetDir}\setup_icon.ico
UninstallDisplayIcon={#AssetDir}\setup_icon.ico
WizardImageFile={#AssetDir}\wizard_side.bmp
WizardSmallImageFile={#AssetDir}\wizard_small.bmp

[Languages]
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"

[Files]
Source: "patch_core.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "apply_from_setup.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "Setup.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "Setup.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "restore.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "restore_launcher.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "status.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "VERSION.txt"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\{#MyAppName}\Povtornaya ustanovka"; Filename: "{app}\Setup.bat"; IconFilename: "{#AssetDir}\setup_icon.ico"; WorkingDir: "{app}"
Name: "{autoprograms}\{#MyAppName}\Otkat patcha"; Filename: "{app}\restore_launcher.bat"; IconFilename: "{#AssetDir}\setup_icon.ico"; WorkingDir: "{app}"

[Code]
var
  GamePage: TInputDirWizardPage;
  FinishPanel: TNewStaticText;
  SupportLabel: TNewStaticText;
  SteamBtn: TNewButton;
  BoostyBtn: TNewButton;

const
  ClForm = $00B0A494;
  ClInner = $00C8BCA8;
  ClTitle = $00305078;
  ClBody = $00282018;
  ClMuted = $00484030;

function GameFolderValid(const Path: String): Boolean;
begin
  Result := FileExists(Path + '\HeroesOldenEra.exe') and FileExists(Path + '\GameAssembly.dll');
end;

procedure SteamButtonClick(Sender: TObject);
var
  ErrorCode: Integer;
begin
  ShellExec('open', '{#MyAppURL}', '', '', SW_SHOW, ewNoWait, ErrorCode);
end;

procedure BoostyButtonClick(Sender: TObject);
var
  ErrorCode: Integer;
begin
  ShellExec('open', '{#MyBoostyURL}', '', '', SW_SHOW, ewNoWait, ErrorCode);
end;

procedure ApplyTheme;
begin
  WizardForm.Color := ClForm;
  WizardForm.InnerPage.Color := ClInner;
  WizardForm.WelcomeLabel1.Font.Color := ClTitle;
  WizardForm.WelcomeLabel1.Font.Style := [fsBold];
  WizardForm.WelcomeLabel2.Font.Color := ClBody;
  WizardForm.FinishedLabel.Font.Color := ClBody;
  WizardForm.PageNameLabel.Font.Color := ClTitle;
  WizardForm.PageNameLabel.Font.Style := [fsBold];
  WizardForm.PageDescriptionLabel.Font.Color := ClBody;
  WizardForm.StatusLabel.Font.Color := ClBody;
end;

procedure LayoutFinishControls;
var
  TopY: Integer;
begin
  TopY := ScaleY(108);
  FinishPanel.Top := TopY;
  FinishPanel.Width := WizardForm.InnerPage.Width - ScaleX(12);

  SupportLabel.Top := TopY + ScaleY(92);
  SupportLabel.Width := WizardForm.InnerPage.Width - ScaleX(12);

  SteamBtn.Top := TopY + ScaleY(132);
  BoostyBtn.Top := TopY + ScaleY(168);
end;

procedure SetFinishExtrasVisible(Visible: Boolean);
begin
  FinishPanel.Visible := Visible;
  SupportLabel.Visible := Visible;
  SteamBtn.Visible := Visible;
  BoostyBtn.Visible := Visible;
  if Visible then
    WizardForm.FinishedLabel.Visible := False;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = wpFinished then
  begin
    LayoutFinishControls;
    SetFinishExtrasVisible(True);
  end
  else
  begin
    SetFinishExtrasVisible(False);
    WizardForm.FinishedLabel.Visible := True;
  end;
end;

procedure InitializeWizard;
begin
  ApplyTheme;

  GamePage := CreateInputDirPage(wpWelcome,
    'Папка игры',
    'Heroes of Might and Magic: Olden Era',
    'Укажите папку, где лежат HeroesOldenEra.exe и GameAssembly.dll.' + #13#10 +
    'Игра должна быть закрыта.',
    False, 'New Folder');
  GamePage.Add('Путь:');
  GamePage.Values[0] := ExpandConstant('{src}');
  if not GameFolderValid(GamePage.Values[0]) then
    GamePage.Values[0] := '';

  FinishPanel := TNewStaticText.Create(WizardForm);
  FinishPanel.Parent := WizardForm.InnerPage;
  FinishPanel.Left := ScaleX(0);
  FinishPanel.AutoSize := False;
  FinishPanel.WordWrap := True;
  FinishPanel.Font.Color := ClBody;
  FinishPanel.Caption :=
    'Патч установлен.' + #13#10 + #13#10 +
    'Одновременные ходы больше не отключаются при встрече с ботами.' + #13#10 +
    'У живых игроков всё как в оригинале.' + #13#10 + #13#10 +
    'В мультиплеере патч нужен у всех.' + #13#10 +
    'После обновления Steam — запустите установщик ещё раз.';
  FinishPanel.Visible := False;

  SupportLabel := TNewStaticText.Create(WizardForm);
  SupportLabel.Parent := WizardForm.InnerPage;
  SupportLabel.Left := ScaleX(0);
  SupportLabel.AutoSize := False;
  SupportLabel.WordWrap := True;
  SupportLabel.Font.Color := ClMuted;
  SupportLabel.Caption := 'Автор: Imagundi. Патч бесплатный — если зашло, можно кинуть на печенье:';
  SupportLabel.Visible := False;

  SteamBtn := TNewButton.Create(WizardForm);
  SteamBtn.Parent := WizardForm.InnerPage;
  SteamBtn.Left := ScaleX(0);
  SteamBtn.Width := ScaleX(175);
  SteamBtn.Height := ScaleY(25);
  SteamBtn.Caption := 'Профиль Steam';
  SteamBtn.OnClick := @SteamButtonClick;
  SteamBtn.Visible := False;

  BoostyBtn := TNewButton.Create(WizardForm);
  BoostyBtn.Parent := WizardForm.InnerPage;
  BoostyBtn.Left := ScaleX(185);
  BoostyBtn.Width := ScaleX(175);
  BoostyBtn.Height := ScaleY(25);
  BoostyBtn.Caption := 'Печенье на Boosty';
  BoostyBtn.OnClick := @BoostyButtonClick;
  BoostyBtn.Visible := False;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  if CurPageID = GamePage.ID then
  begin
    if not GameFolderValid(GamePage.Values[0]) then
    begin
      MsgBox('В папке нет HeroesOldenEra.exe или GameAssembly.dll.' + #13#10 +
        'Выберите корень игры (Steam / Epic).', mbError, MB_OK);
      Result := False;
    end;
  end;
end;

function ApplyPatch(const GamePath: String): Boolean;
var
  ResultCode: Integer;
  PsCmd: String;
begin
  PsCmd := '-NoProfile -ExecutionPolicy Bypass -File "' +
    ExpandConstant('{app}\apply_from_setup.ps1') + '" -GameRoot "' + GamePath + '"';
  Result := Exec('powershell.exe', PsCmd, '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  if not Result then
  begin
    MsgBox('Не удалось запустить PowerShell.', mbError, MB_OK);
    Exit;
  end;
  if ResultCode <> 0 then
  begin
    MsgBox('Патч не применился (код ' + IntToStr(ResultCode) + ').' + #13#10 +
      'Закройте игру и повторите.', mbError, MB_OK);
    Exit;
  end;
  Result := True;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
    ApplyPatch(GamePage.Values[0]);
end;

[Messages]
russian.SetupWindowTitle=SimTurnsAI Patch
russian.WelcomeLabel1=Установка патча
russian.WelcomeLabel2=Патч для [name] [version].%n%nВ ваниле simultaneous turns вырубаются, когда вы видите бота — так же, как живого игрока. После патча у ИИ realtime остаётся, у людей без изменений.%n%nДальше укажите папку игры — всё остальное само.
russian.FinishedHeadingLabel=Готово
russian.FinishedLabel=
russian.ButtonNext=Далее
russian.ButtonInstall=Установить
russian.ButtonFinish=Закрыть
russian.StatusCreateDirs=Копируем файлы...
russian.StatusExtractFiles=Распаковка...
russian.StatusRunProgram=Патчим GameAssembly.dll...
russian.SelectDirLabel3=Служебная папка:
russian.SelectDirBrowseLabel=Обзор

[UninstallDelete]
Type: files; Name: "{app}\SimTurnsAI_Patch.installed"
