#define AppVer GetFileVersion('windows/LibkiPrintStation.exe')

[Setup]
AppName=Libki Jamex Client
AppVersion={#AppVer}
AppPublisher=Kyle M Hall
AppPublisherURL=http://kylehall.info/
AppSupportURL=http://libki.org/
AppUpdatesURL=http://libki.org/
DefaultDirName={pf}\LibkiPrintStation
DefaultGroupName=Libki Print Station
OutputBaseFilename=Libki_Print_Station_Installer
Compression=lzma
AllowNoIcons=yes

[Files]
Source: "windows\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs

[Dirs]
Name: {app}\logs

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Icons]
Name: "{userdesktop}\Libki Print Station"; Filename: "{app}\LibkiPrintStation.exe"; Tasks: desktopicon

[CustomMessages]
NameAndVersion=%1 version %2
AdditionalIcons=Additional icons:
CreateDesktopIcon=Create a &desktop icon
CreateQuickLaunchIcon=Create a &Quick Launch icon
ProgramOnTheWeb=%1 on the Web
UninstallProgram=Uninstall %1
LaunchProgram=Launch %1
AssocFileExtension=&Associate %1 with the %2 file extension
AssocingFileExtension=Associating %1 with the %2 file extension...

[INI]
Filename: "{commonappdata}\Libki\Libki Print Station.ini"; Section: "server"; Key: "address"; String: "{code:GetAddress}"
Filename: "{commonappdata}\Libki\Libki Print Station.ini"; Section: "server"; Key: "api_key"; String: "{code:GetApiKey}"
Filename: "{commonappdata}\Libki\Libki Print Station.ini"; Section: "server"; Key: "customHeaderName"; String: "{code:GetCustomHeaderName}"
Filename: "{commonappdata}\Libki\Libki Print Station.ini"; Section: "server"; Key: "customHeaderValue"; String: "{code:GetCustomHeaderValue}"
Filename: "{commonappdata}\Libki\Libki Print Station.ini"; Section: "font"; Key: "font_family"; String: "Arial"
Filename: "{commonappdata}\Libki\Libki Print Station.ini"; Section: "font"; Key: "font_size"; String: "14"

[Code]
var
  ServerPage: TInputQueryWizardPage;
  IniPath: string;

procedure InitializeWizard;
begin
  IniPath := ExpandConstant('{commonappdata}\Libki\Libki Print Station.ini');
  { Create the pages }
  
  ServerPage := CreateInputQueryPage(wpWelcome,
    'Server Information', 'Libki server data',
    'Please specify the Libki server data.');
  ServerPage.Add('Address:', False);
  ServerPage.Add('API Key:', False);
  ServerPage.Add('API Request Header Name:', False);
  ServerPage.Add('API Request Header Value:', False);
  ServerPage.Values[0] := GetIniString('server', 'address', '', IniPath);
  ServerPage.Values[1] := GetIniString('server', 'api_key', '', IniPath);
  ServerPage.Values[2] := GetIniString('server', 'customHeaderName', '', IniPath);
  ServerPage.Values[3] := GetIniString('server', 'customHeaderValue', '', IniPath);
end;

function GetAddress(Param: String): String;
begin
  Result := ServerPage.Values[0];
end;

function GetApiKey(Param: String): String;
begin
  Result := ServerPage.Values[1];
end;

function GetCustomHeaderName(Param: String): String;
begin
  Result := ServerPage.Values[2];
end;

function GetCustomHeaderValue(Param: String): String;
begin
  Result := ServerPage.Values[3];
end;
