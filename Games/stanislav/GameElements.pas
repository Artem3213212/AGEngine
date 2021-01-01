unit GameElements;

interface

uses System.SysUtils,AG.ProcessIncluder,System.IniFiles;  

var
  Qemu:TAGIncludedProcessControl;
  Config:TMemIniFile;

implementation

initialization
Config:=TMemIniFile.Create('../Data/Config.ini');
finalization
if Assigned(Qemu) then 
  Qemu.Suspended:=True;
FreeAndNil(Qemu);        
FreeAndNil(Config);
end.
