[Setup]
AppName=ElectricalAI Pro
AppVersion=1.0.1
AppPublisher=Mohamed Eltoukhy
AppPublisherURL=https://github.com/L2kee/ElectricalAI-Pro
AppSupportURL=https://github.com/L2kee/ElectricalAI-Pro
AppUpdatesURL=https://github.com/L2kee/ElectricalAI-Pro
DefaultDirName={autopf}\ElectricalAI Pro
DefaultGroupName=ElectricalAI Pro
OutputBaseFilename=ElectricalAI-Pro-Setup
Compression=lzma2
SolidCompression=yes
OutputDir=.
SetupIconFile=..\frontend\windows\runner\resources\app_icon.ico
PrivilegesRequired=lowest
CreateAppDir=yes
UninstallDisplayIcon={app}\ElectricalAI-Pro.exe
VersionInfoVersion=1.0.1
VersionInfoDescription=ElectricalAI Pro
VersionInfoProductName=ElectricalAI Pro
VersionInfoCompany=Mohamed Eltoukhy
VersionInfoCopyright=Copyright (C) 2026 Mohamed Eltoukhy

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "..\release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\ElectricalAI Pro"; Filename: "{app}\ElectricalAI-Pro.exe"
Name: "{autodesktop}\ElectricalAI Pro"; Filename: "{app}\ElectricalAI-Pro.exe"

[Run]
Filename: "{app}\ElectricalAI-Pro.exe"; Description: "Launch ElectricalAI Pro"; Flags: nowait postinstall skipifsilent
