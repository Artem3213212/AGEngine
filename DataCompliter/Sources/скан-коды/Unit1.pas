unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 Case key of
27:MessageDlg('Вы нажали клавишу с кодом '+IntToStr(key)+#13+#10 + 'Esc', mtInformation, [mbOK],0);
8:MessageDlg('Нажали клавишу с кодом '+IntToStr(key)+#13+#10 + 'BackSpace', mtInformation, [mbOK],0);
16:MessageDlg('Нажали клавишу с кодом '+IntToStr(key)+#13+#10 + 'Shift', mtInformation, [mbOK],0);
17:MessageDlg('Нажали клавишу с кодом '+IntToStr(key)+#13+#10 + 'Ctrl', mtInformation, [mbOK],0);
18:MessageDlg('Нажали клавишу с кодом '+IntToStr(key)+#13+#10 + 'Alt', mtInformation, [mbOK],0);
19:Begin
MessageDlg('Нажали клавишу с кодом '+IntToStr(key)+#13+#10 + 'Break', mtInformation, [mbOK],0);
beep;
close;
end;
20:MessageDlg('Нажали клавишу с кодом '+IntToStr(key)+#13+#10 + 'Caps Lock', mtInformation, [mbOK],0);
33:MessageDlg('Нажали клавишу с кодом '+IntToStr(key)+#13+#10 + 'PageUp', mtInformation, [mbOK],0);
34:MessageDlg('Нажали клавишу с кодом '+IntToStr(key)+#13+#10 + 'PageDown', mtInformation, [mbOK],0);
35:MessageDlg('Нажали клавишу с кодом '+IntToStr(key)+#13+#10 + 'End', mtInformation, [mbOK],0);
36:MessageDlg('Нажали клавишу с кодом '+IntToStr(key)+#13+#10 + 'Home', mtInformation, [mbOK],0);
37:MessageDlg('Нажали клавишу с кодом '+IntToStr(key)+#13+#10 + '<', mtInformation, [mbOK],0);
38:MessageDlg('Нажали клавишу с кодом '+IntToStr(key)+#13+#10 + 'Вверх', mtInformation, [mbOK],0);
39:MessageDlg('Нажали клавишу с кодом '+IntToStr(key)+#13+#10 + '>', mtInformation, [mbOK],0);
40:MessageDlg('Нажали клавишу с кодом '+IntToStr(key)+#13+#10 + 'Вниз', mtInformation, [mbOK],0);
45:MessageDlg('Нажали клавишу с кодом '+IntToStr(key)+#13+#10 + 'Insert', mtInformation, [mbOK],0);
46:MessageDlg('Нажали клавишу с кодом '+IntToStr(key)+#13+#10 + 'Delete', mtInformation, [mbOK],0);
145:MessageDlg('Нажали клавишу с кодом '+IntToStr(key)+#13+#10 + 'Scroll Lock', mtInformation, [mbOK],0);
112..120:MessageDlg('Нажали клавишу с кодом '+IntToStr(key)+#13+#10 + 'F'+ IntToStr(key-111), mtInformation, [mbOK],0);
13:MessageDlg('Нажали клавишу с кодом '+IntToStr(key)+#13+#10 + 'Enter', mtInformation, [mbOK],0);
32:MessageDlg('Нажали клавишу с кодом '+IntToStr(key)+#13+#10 + 'Space', mtInformation, [mbOK],0);
Else
MessageDlg('Нажали клавишу с кодом '+IntToStr(key)+#13+#10 + chr(key), mtInformation, [mbOK],0);
end;
end;

end.
