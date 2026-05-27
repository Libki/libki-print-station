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
Filename: "{commonappdata}\Libki\Libki Print Station.ini"; Section: "font"; Key: "font_family"; String: "Arial"
Filename: "{commonappdata}\Libki\Libki Print Station.ini"; Section: "font"; Key: "font_size"; String: "14"

[Code]
var
  ServerPage: TInputQueryWizardPage;

procedure InitializeWizard;
begin
  { Create the pages }
  
  ServerPage := CreateInputQueryPage(wpWelcome,
    'Server Information', 'Libki server data',
    'Please specify the Libki server data.');
  ServerPage.Add('Address:', False);
  ServerPage.Add('API Key:', False);
  ServerPage.Values[0] := GetIniString("server", "address", "", "{commonappdata}\Libki\Libki Print Station.ini");
  ServerPage.Values[1] := GetIniString("server", "api_key", "", "{commonappdata}\Libki\Libki Print Station.ini");
end;

function GetAddress(Param: String): String;
begin
  Result := ServerPage.Values[0];
end;

function GetApiKey(Param: String): String;
begin
  Result := ServerPage.Values[1];
end;
