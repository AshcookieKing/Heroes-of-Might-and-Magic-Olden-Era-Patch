; SimTurnsAI Patch installer v1.0.7

#define MyAppName "SimTurnsAI Patch"
#define MyAppVersion "1.0.8"
#define MyAppPublisher "Imagundi"
#define MyAppURL "https://steamcommunity.com/id/Imagundi/"
#define MyBoostyURL "https://boosty.to/imagundi/donate"
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
  DonePage: TWizardPage;
  DoneText: TNewStaticText;
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

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  Result := (PageID = wpFinished);
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
  WizardForm.PageNameLabel.Font.Color := ClTitle;
  WizardForm.PageNameLabel.Font.Style := [fsBold];
  WizardForm.PageDescriptionLabel.Font.Color := ClBody;
  WizardForm.StatusLabel.Font.Color := ClBody;
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

  DonePage := CreateCustomPage(wpInstalling,
    'Готово',
    'Патч установлен');

  DoneText := TNewStaticText.Create(DonePage);
  DoneText.Parent := DonePage.Surface;
  DoneText.Left := 0;
  DoneText.Top := 0;
  DoneText.Width := DonePage.SurfaceWidth;
  DoneText.Height := ScaleY(118);
  DoneText.AutoSize := False;
  DoneText.WordWrap := True;
  DoneText.Font.Color := ClBody;
  DoneText.Caption :=
    'Патч установлен.' + #13#10 + #13#10 +
    'Simultaneous turns больше не отключаются при встрече с ботами.' + #13#10 +
    'У живых игроков всё как в оригинале.' + #13#10 + #13#10 +
    'В мультиплеере патч нужен у всех.' + #13#10 +
    'После обновления Steam — запустите этот установщик снова.';

  SupportLabel := TNewStaticText.Create(DonePage);
  SupportLabel.Parent := DonePage.Surface;
  SupportLabel.Left := 0;
  SupportLabel.Top := ScaleY(124);
  SupportLabel.Width := DonePage.SurfaceWidth;
  SupportLabel.Height := ScaleY(28);
  SupportLabel.AutoSize := False;
  SupportLabel.WordWrap := True;
  SupportLabel.Font.Color := ClMuted;
  SupportLabel.Caption := 'Автор: Imagundi. Патч бесплатный — если зашло, можно поддержать:';

  SteamBtn := TNewButton.Create(DonePage);
  SteamBtn.Parent := DonePage.Surface;
  SteamBtn.Left := 0;
  SteamBtn.Top := ScaleY(158);
  SteamBtn.Width := ScaleX(170);
  SteamBtn.Height := ScaleY(27);
  SteamBtn.Caption := 'Профиль Steam';
  SteamBtn.OnClick := @SteamButtonClick;

  BoostyBtn := TNewButton.Create(DonePage);
  BoostyBtn.Parent := DonePage.Surface;
  BoostyBtn.Left := ScaleX(180);
  BoostyBtn.Top := ScaleY(158);
  BoostyBtn.Width := ScaleX(170);
  BoostyBtn.Height := ScaleY(27);
  BoostyBtn.Caption := 'Поддержать';
  BoostyBtn.OnClick := @BoostyButtonClick;
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
