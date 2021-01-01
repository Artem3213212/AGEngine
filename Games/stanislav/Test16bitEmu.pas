unit Test16bitEmu;

interface

uses
  System.Classes,System.math,System.SysUtils,System.SyncObjs,AG.Levels,AG.Game,AG.Types,AG.Graphic,AG.Windows,AG.Logs,AG.STD.Files,
  AG.STD.BitMaps,AG.STD.Types,AG.Resourcer,AG.Video,winapi.windows;

procedure LInit(Core:TAGGraphicCore);
procedure LPaint(Core:TAGGraphicCore);
procedure LDestoy(Core:TAGGraphicCore);
procedure LKeydown(key,lParam:nativeint);
procedure LStart(Core:TAGGraphicCore);
procedure LTimed;

const
  CLevelTest16bitEmuInfo:TLevelInfo=(init:LInit;start:LStart;paint:LPaint;Destroy:LDestoy;keydown:LKeydown;Timed:LTimed);

implementation

{$T-}

type     
  TFlags=packed record
      case integer of
      0:(Flags:Word);   
      1:(EFlags:Cardinal);
      2:(&Set:set of(
      CF=0,	//Carry Flag ���� �������� ���������	
      R1=1,	//��������������		
      PF=2,	//Parity Flag ���� �������� ���������	
      R3=3,	//��������������		
      AF=4,	//Auxiliary Carry Flag ��������������� ���� �������� ���������	
      R5=5,    	//��������������		
      ZF=6,	//Zero Flag ���� ���� ���������	
      SF=7,	//Sign Flag ���� ����� ���������	
      TF=8,	//Trap Flag ���� ����������� (��������� ����������) ���������	
      &IF=9,	//Interrupt Enable Flag	���� ���������� ���������� ���������	
      DF=10,	//Direction Flag ���� ����������� �����������	
      &OF=11,	//Overflow Flag	���� ������������ ���������	
      IOPL0=12,	//I/O Privilege Level ������� ���������� �����-������ ���������	80286
      IOPL1=13,
      NT=14,	//Nested Task ���� ����������� ����� ��������� 80286
      R15=15	//��������������
      ));                             
    end;
  TRegs=packed record
    ES,CS,SS,DS,FS,GS,Seg6,Seg7,IP:Word;
    Flags:TFlags;
    case integer of
    0:(AL,AH,R00,R01,CL,CH,R02,R03,DL,DH,R04,R05,BL,BH:TDefData8); 
    1:(AX,R10,CX,R11,DX,R12,BX,R13,SP,R14,BP,R15,SI,R16,DI:TDefData16);
    2:(EAX,ECX,EDX,EBX,ESP,EBP,ESI,EDI:TDefData32);
  end;

  TMem=array of TDefData8;
  TMemHelper=record helper for TMem
    function Word(Seg,Addres:Word):Word;overload;inline;     
    function Word(Addres:Cardinal):Word;overload;inline;   
    function Cardinal(Seg,Addres:Word):Word;overload;inline;     
    function Cardinal(Addres:Cardinal):Word;overload;inline; 
  end;

  TSect=array[0..511]of byte;
  PSect=^TSect; 

  TTaskType=(CallTask=0,OneTask=1,BlockTask=2,Caskad=3);
  TUseType=(Test=0,write=1,read=2);
  TDMAChanel=record
    Position,Size:Cardinal;
    Use,Shadow,LowAddres,Autoinit,NextByteHigth:boolean;
    TaskType:TTaskType;
    UseType:TUseType;
  end;
  TDMAController=record
    Chanels:array[0..3]of TDMAChanel;
    EndWord:Word;
    DACK,DREQ,WriteLoop,PriorytyLoop,zip,DMAWork,CanUseRamtoRam,RamtoRam:boolean;
    procedure Reset;
  end;
  TCMOS=record//class(TThread)          
    //section:TCriticalSection;
    portaddr:byte;
    CMOSDATA:array[byte]of byte;
    procedure Write(a:byte);inline;
    function Read:byte;inline;          
    {procedure Execute;override;
    constructor Create;overload;
    destructor Destroy;overload;override;}                                                                                                                                                         
  end;

{constructor TCMOS.Create;
begin
section:=TCriticalSection.Create;
inherited;
end;

procedure TCMOS.Execute;
var
  temp:byte;
begin
while not Terminated do
begin
  section.Enter;
  //���������� �������
  inc(CMOSDATA[$00]);//+1 �������  
  //CMOSDATA[$00] ����� ���: ������� (BCD 00-59h, HEX 00-3Bh)
  if CMOSDATA[$00] mod 16=10 then
  begin
    inc(CMOSDATA[$00],6);
    if CMOSDATA[$00]=$60 then
    begin
      //CMOSDATA[$02] ����� ���: ������ (BCD 00-59h, HEX 00-3Bh)    
      CMOSDATA[$00]:=0; 
      inc(CMOSDATA[$02]);
      if CMOSDATA[$02] mod 16=10 then
      begin
        inc(CMOSDATA[$02],6);
        if CMOSDATA[$02]=$60 then
        begin
          //CMOSDATA[$04] ����� ���: ���� (BCD 00-23h, HEX 00-17h) � 24 ������� ���� (BCD 01-12h, HEX 01-0Ch) � 12 ������� ���� (�� �������) (BCD 81-92h, HEX 81-8Ch) � 12 ������� ���� (����� �������)
          CMOSDATA[$02]:=0; 
          inc(CMOSDATA[$04]); 
          if CMOSDATA[$04] mod 16=10 then
          begin   
            inc(CMOSDATA[$04],6);
          end;
          if CMOSDATA[$04]=$24 then
          begin     
            CMOSDATA[$04]:=0; 
            //CMOSDATA[$06] ���� ������ (01-07h, 01=�����������)
            CMOSDATA[$06]:=(CMOSDATA[$06] mod 7)+1;
            //CMOSDATA[$07] ���� ������ (BCD 01-31h, HEX 01-1Fh)
            inc(CMOSDATA[$07]);  
            if CMOSDATA[$07] mod 16=10 then
            begin
              inc(CMOSDATA[$07],6);
              case CMOSDATA[$08]of
              $01,$03,$05,$07,$08,$10,$012:temp:=31;
              $04,$06,$09,$11:temp:=31;
              $02:if(CMOSDATA[$09]mod 4=0)and(CMOSDATA[$09]<>0)then
                    temp:=29
                  else
                    temp:=28;
              end;
              if CMOSDATA[$07]=temp+1 then
              begin
                CMOSDATA[$07]:=1;
                //CMOSDATA[$08] ����� (BCD 01-12h, HEX 01-0Ch)
                inc(CMOSDATA[$08]);
                if CMOSDATA[$08] mod 16=10 then
                begin      
                  inc(CMOSDATA[$08],6);
                  if CMOSDATA[$08]=13 then
                  begin             
                    CMOSDATA[$08]:=1; 
                    //CMOSDATA[$09] ��� �� ������ 100 (BCD 00-99h, HEX 00-63h)
                    inc(CMOSDATA[$09]);  
                    if CMOSDATA[$09] mod 16=10 then
                    begin      
                      inc(CMOSDATA[$09],6);
                    end;                                
                  end;                    
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  end;   
  sleep(999);
  Yield;
  section.Leave;
end;    
end;

destructor TCMOS.Destroy;
begin  
section.Enter;  
Suspend;
section.Leave;
inherited;  
FreeAndNil(section);
end;     }
    
procedure TCMOS.Write(a:byte);
begin
{0Ah	������� ��������� A ����� ��������� �������:
��� 7: ����������, ���� ����/����� �����������
���� 6-4: ������� ������� ������� ������� (22 stage divider), �� ��������� 010b=32.768��
���� 3-0: ����� ������� ����������, 0000 � �� ������������� 0011 � 122 ������������ (�������)
1111 � 500 ����������� 0110 � 976.562 ������������ =1024�� (�� ���������)
0Bh	������� ��������� B ����� ��������� �������: ��� 7: =0 ���������� ����������, =1 ��������� ���������� ��� 6: ���������� ������������� ���������� ��� 5: ���������� ���������� ���������� ��� 4: ���������� ���������� ����� ���������� ��� 3: ���������� ������������� ��������� ��� 2: ����� ���� (=0 BCD, =1 HEX) ��� 1: (=0 12 ������� ����, =1 24 ������� ����)
��� 0: =1 ��������� ������� �� ������ �����
0Ch	������� ��������� C ����� ��������� �������: ��� 7: ���� Interrupt Request =1 ����� ����� ��� ��� � 6 �� 4 ���� � 1 � appropriate enables (������� ��������� B) ���������-�� � 1, ������������ ���������� 8 ��� ������������; ��� 6: ���� Periodic Interrupt; ��� 5: ���� Alarm Interrupt; ��� 4: ���� Update-Enable Interrupt
0Dh	������� ��������� D ����� ��������� �������: ��� 7: ������� �������
�� 0Dh �������� � CMOS ������ ���� �������� ���������� ���������� � ����� � ���������. ����� 0Dh � ����������� �� ����� ������������� (AMSTRAD, IBM PS/2, AMI, PHOENIX � �.�.) ���������� ������.
0Eh	(PS/2) Diagnostic Status Byte ��� 7: =1 indicates clock has lost power ��� 6: =1 indicates incorrect checksum ��� 5: =1 indicates equipment configuration is incorrect Power-on check requires that atleast one floppy be installed ��� 4: =1 indicates error in memory size ��� 3: =1 indicates controller or disk drive faileDInitialization ��� 2: =1 indicates time is invalid ��� 1: =1 indicates installed adaptors do not match configuration ��� 0: =1 indicates a time-out while reading adaptor ID
0Eh-13h	(AMSTRAD) ����� � ���� ���������� ������������� ������
0Fh	Reset Code (IBM PS/2 �Shutdown Status Byte�)
10h	���� 7-4 ��� ������� ������-��������� ���� 3-0 ��� ������� ������-���������
=0 ��� ���������, =1 � 360 �� 5,24 �����, =2 � 1.2 �� 5,24 �����, =3 � 720 �� 3,5 �����, =4 � 1.4 �� 3,5 �����,
11h	(IBM-PS/2) First Fixed Disk Drive Type Byte (00-FFh) Note: if IBM ESDI or SCSI drive controller is used, CMOS drive type will be zero (00 -no drive) � ���������� 13h will be directed to controller ROM.
11h	(AMI) Keyboard Typematic Data ��� 7 Enable Typematic (1 = On) ���� 6-5 Typematic Delay (wait before begin repeating) =0 250 ms, =1 500 ms, =2 750 ms, =3 100 ms ���� 4-0 Typematic Rate char/sec e.g. 01010b = 12.0 cps 00 �300 01 -267 02 -240 03 -218 04 -200 05 -185	06 �171 07 �160 08 -159 09 -133 0Ah -120 0Bh -109	0Ch �100 0Dh �92 0Eh -86 0Fh -80 10h -75 11h -67	12h -60
13h -55 14h -50 15h -46 16h -43 17h -40	18h � 37 19h � 33 1Ah -30 1Bh -27 1Ch -25 1Dh -23	1Eh �21 1Fh -20
12h	���� 7-4 ��� ������� ����������, ���� =Fh �� ���������� ���-����� �� ������ 19h 
���� 3-0 ��� ������� ����������, ���� =Fh �� ���������� ���-����� �� ������ 1Ah
13h	(AMI) Advanced Setup Options ��� 7 ������� ���� ��� 6 ���� ������ ������������� ���� 1 M����� ��� 5 �������� ������ �� ����� �������� ������ ��� 4 �������� ������ �������� ������ ��� 3 ���������� �������� ������ �������� �� <Esc> ��� 2 ������� ���� ������������ ������������� (1 = ��� 47 data area at address 0:300h) ��� 1 �������� ������� �� <F1> ��� ������ ��������� �� ������� ��� 0 �������� ��������� Num Lock On ��� �������� 
14h	���������: ���� 7-6: =0 1 ������ ��������, =1 2 ������ ���-������; ���� 5-4: =0 VGA ��� EGA �������, =1 CGA 40x25 �����, =2 CGA 80x25 �����, =3 ����������� ������� ��� 3 Display Enabled, ��� 2 Keyboard Enabled ��� 1 ������� ������������ ��� 0 ������� ������-���������
14h (AMSTRAD) ����������� ����� ��� ������������ 
15h	������� ������ � ���������� (������� ����)
15h-16h	(AMSTRAD) ����-��� /��� ASCII ������� Enter
16h	������� ������ � ���������� (������� ����)
17h	����������� ������ � ���������� (������� ����)
17h-18h	(AMSTRAD) ����-��� /��� ASCII ������� Backspace
18h	����������� ������ � ���������� (������� ����)
19h	��� ������� ���������� (not in original AT specification but now nearly universally used except for PS/2). �������� �� 0 �� Fh �� ������������ (would not require extension. Note: this has the effect making type 0Fh (15d) unavailable. �������� �� 10h �� FFh ��� ������� ���������� �� 16d �� 255d ����������� ����-������������� ���������� ��������� ��-�� 47d ��� 49d � "��� ��������� �������������" � ��������� are stored elsewhere in the CMOS.
19h-1Ah	(AMSTRAD) ����-��� /��� ASCII ������ 1 ��������� ����-�����, �� ���������: FFFFh -(no translation)
1Ah	��� ������� ���������� (�������� 19h) 
1Bh	(AMI) ������ ������� ���� ������������ ������������� (��� 47): ����� ���������, LSB 
1Bh	(PHOENIX) LSB of Word to 82335 RC1 roll compare register
1Bh-1Ch	(AMSTRAD) ����-��� /��� ASCII ���������� ������ 2 ����-����� ���������, �� ���������: FFFFh -(no translation)
1Ch	(AMI) ������ ������� ���� ������������ �������������: ����� ��������� (������� ����)
1Ch	(PHOENIX) MSB of Word to 82335 RC1 roll compare register
1Dh	(AMI) ������ ������� ���� ������������ �������������: ����� ������� 
1Dh-1Eh	(AMSTRAD) ����-��� /��� ASCII 1-�� ������� ���� �� ���������: FFFFh -(no translation)
1Dh	(Zenith Z-200 monitor) ����� ���������� ��� �������� ������� ���� 6-5: =0 -MFM Monitor, =1 � �������� � ������� (� : ) =2 �������� � ���������� ( � : ) =3 �������� � ������� ���� �� ������ ��������� (�� ���������)
1Dh	(PHOENIX) LSB of Word to 82335 RC2 roll compare register 
1Eh	(AMI) ������ ������� ���� ������������ �������������: ������� � �������� ���������� ����������� ������� (������� ����) 
1Eh	(PHOENIX) MSB of Word to 82335 RC2 roll compare register
1Fh	(AMI) ������ ������� ���� ������������ �������������: ������� � �������� ���������� ����������� ������� (������� ����)
1Fh-20h	(AMSTRAD) ����-��� /��� ASCII 2-�� ������� ����
20h	(AMI) ������ ������� ���� ������������ �������������: Control Byte (����� 80h ���� ���������� ������� ����� ��� ������ 8) 
20h	(PHOENIX) ������ ������� ���� ������������ ������������� (��� 48) ���������� ��������� LSB
21h	(AMI) ������ ������� ���� ������������ �������������: ���� �������� (������� ����) 
21h	(PHOENIX) ������ ������� ���� ������������ ������������� (��� 48) ���������� ��������� MSB
21h	(AMSTRAD) ������� X ����, �� ���������: 0Ah
22h	(AMI) ������ ������� ���� ������������ �������������: ���� �������� (������� ����)
22h	(PHOENIX) ������ ������� ���� ������������ ������������� (��� 48) ���������� �������
22h	(AMSTRAD) Y ������� ����, �� ���������: 0Ah
23h	(AMI) ������ ������� ���� ������������ �������������: ���������� �������� �� ����� ������� 
23h	(PHOENIX) ������ ������� ���� ������������ ������������� (��� 48) ����������� �������. LSB
23h	(AMSTRAD) BYTE initial VDU mode and drive count default: 20h
��� 7: enables extended serial flow control (NB this is buggy) ��� 6: set if two floppy drives installed ���� 5-4: (from Amstrad 1640 tech ref) 00 Internal video adapter; 01 CGA ������� � 40x25 �����;
10 CGA ������� � 80x25 �����; 11 ����������� ������� �80x25 �����
24h	(AMI) ������ ������� ���� ������������ �������������: ���������� ��������� (������� ����)
24h	(AMSTRAD) BYTE initial VDU character attribute, default: 7h
24h	(PHOENIX) ������ ������� ���� ������������ ������������� (��� 48) ����������� �������. MSB
25h	(AMI) ������ ������� ���� ������������ �������������: ���������� ��������� (������� ����)
25h	(AMSTRAD) BYTE size of RAM disk in 2K blocks default: 0 -only used by the RAMDISK software supplied.
25h	(PHOENIX) ������ ������� ���� ������������ ������������� (��� 48) ���� ������� ������� LSB
26h	(AMI) ������ ������� ���� ������������ �������������: ���������� �������
26h	(AMSTRAD) BYTE initial system UART setup byte �� ���������: E3h � ������ ����� ��� ��� 14h ���������� ������� 0
26h	(PHOENIX) ������ ������� ���� ������������ ������������� (��� 48) ���� ������� ������� MSB
27h	(AMI) ������ ������� ���� ������������ �������������: �������, � �������� ���������� ����������� ������� (������� ����)
27h	(AMSTRAD) BYTE initial external UART setup byte �� ���������: E3h � ������ ����� ��� ��� 0 ������� ���������� 14h 14h ���������� ������� 0 � ���������������� ���������������� ���� AL ��������� ����� 7-5 ��� -�������� ��������, 4-3 ��� � �������� ��������, 2 ��� � ���������� ����-�����, 1-0 ��� � �����, DX ����� ����� (00-03)
27h	(PHOENIX) ������ ������� ���� ������������ ������������� (��� 48) ���������� �������� �� ����� �������
28h	(AMI) ������ ������� ���� ������������ �������������: ������� � �������� ���������� ����������� ������� (������� ����)
28h	(HP Vectra) checksum over words 29h-2Dh
28h-3Fh	(AMSTRAD) 24 ����� user applications �� ���������: ����
29h	(AMI) ������ ������� ���� ������������ �������������: Control Byte (����� 80h ���� ���������� ������� ����� ��� ������ 8)
29h	(PHOENIX) LSB word to Intel 82335 CC0 compare register
2Ah	(AMI) ������ ������� ���� ������������ �������������: ���� �������� (������� ����)
2Ah	(PHOENIX) MSB word to Intel 82335 CC0 compare register
2Bh	(AMI) ������ ������� ���� ������������ �������������: ���� �������� (������� ����)
2Bh	(PHOENIX) LSB word to Intel 82335 CC1 compare register
2Ch	(AMI) ������ ������� ���� ������������ �������������: ��-�������� �������� �� ����� �������
2Ch	(COMPAQ) ��� 6: ��������/��������� ��������� numlock ��� ��������
2Ch	(PHOENIX) MSB word to Intel 82335 CC1 compare register
2Dh	(AMI) Configuration Options ��� 7 ���� =1 � ������������ ����������� ����� Weitek
��� 6 Floppy Drive Seek ��������� ��� ������� �������� ��� 5 ������� �������� =0 � �������� � ����������, � ����� � ������; =1 �������� � ������, � ����� � ���������� ��� 4 �������� �������� (0 � ������; 1 ��������) ��� 3 External Cache Enable (1 = On) ��� 2 Internal Cache Enable (1 = On) ��� 1 Use Fast Gate A20 after boot (1 = On) ��� 0 ������������� ������ 
2Dh	(PHOENIX) Checks for values AAh or CCh
2Eh	Standard CMOS Checksum (������� ����)
2Fh	Standard CMOS Checksum, (������� ����)
30h	������ ����� 1 ��������� (������� ����)
31h	������ ����� 1 ��������� (������� ����)
32h	(IBM-PS2) Configuration CRC (������� ����). CRC for range 10h-31h
33h	�������������� ���� ��� 7 128K (??? believe this indicates the presence of the special 128k memory expansion board for the AT to boost the "stock" 512k to 640k -all machines surveyed have this ��� set) ���� 6-0 ???
33h (IBM PS/2) Configuration CRC (������� ����) (see entry for 32h)
33h	(PHOENIX) ��� 4 ���������� 4-�� ���� �������� ��������-������� CP0
34h	(AMI) ������ ������� ������ � ����� ������ ��������
���� 7-6 ����� ������: =0 ��������, =1 ����������, =2 ��������������, =3 ������ �� �������� ������� 
���� 5-0 ������ ������� ������ ���: ��� 5 C8000h, ��� 4 CC000h, ��� 3 D0000h, ��� 2 D4000h, ��� 1 D8000h, ��� 0 DC000h
35h	(AMI) ������ ������� ������: ��� 7 � E0000h, ��� 6 � E4000h, ��� 5 � E8000h, ��� 4 � EC000h, ��� 3 � F0000h, ��� 2 � C0000h, ��� 1 � C4000h, ��� 0 � ��������������
35h	(PHOENIX) ������ ������� ���� ������������ ������������� (��� 48) ����������� ��������� LSB ����������: ��������-���� � ��� ������ ����� ������ � ����� PS/2 �� ����� �������.
36h	(PHOENIX) ������ ������� ���� ������������ ����������-��� (��� 48) � ���������� ��������� MSB. ����������: ������������ � ��� ������ ����� ������ � ����� PS/2 �� ����� �������.
37h	(IBM PS/2) ���� ��������
37h	(PHOENIX) ������ ������� ���� ������������ ������������� (��� 48) � ����� �������. ����������: ������������ � ��� ������ ����� ������ � ����� PS/2 �� ����� �������.
38h-3Dh	(AMI) ������������� ������
38h-3Fh	??? (IBM PS/2) ������������� ������. ���������������� 00h � ���� ������. �������� �� 1 �� 7 ����-�����.
38h	(PHOENIX) ������ ������� ���� ������������ ������������� (��� 48) � ����������� �������. LSB. ����������: ������������ � ��� ������ ����� ������ � ����� PS/2 �� ����� �������.
39h	(PHOENIX) ������ ������� ���� ������������ ������������� (��� 48) � ����������� �������. MSB. ����������: ������������ � ��� ������ ����� ������ � ����� PS/2 �� ����� �������.
3Ah	(PHOENIX) ������ ������� ���� ������������ ������������� (��� 48) � ���� ������� ������� LSB. ����������: ������������ � ��� ������ ����� ������ � ����� PS/2 �� ����� �������.
3Bh (PHOENIX) ������ ������� ���� ������������ ������������� (��� 48) � ���� ������� ������� MSB. ����������: ������������ � ��� ������ ����� ������ � ����� PS/2 �� ����� �������.
3Ch (PHOENIX) ������ ������� ���� ������������ ������������� (��� 48) � ���������� �������� �� ����� �������. ����������: ������������ � ��� ������ ����� ������ � ����� PS/2 �� ����� �������.
3Eh (AMI) Extended CMOS Checksum (������� ����) (includes 34h -3Dh)
3Fh (AMI) Extended CMOS Checksum (������� ����) (includes 34h -3Dh)}
CMOSDATA[portaddr]:=a;
end;

function TCMOS.Read:byte;  
begin  
Result:=CMOSDATA[portaddr];
end; 
    
procedure TDMAController.Reset;
begin 
EndWord:=0;
DACK:=False;
DREQ:=False;
WriteLoop:=False;
PriorytyLoop:=False;
zip:=False;
DMAWork:=False;
CanUseRamtoRam:=False;
RamtoRam:=False;  
Chanels[0].Position:=0;
Chanels[0].Size:=0;
Chanels[0].Use:=False;
Chanels[0].Shadow:=False;
Chanels[0].LowAddres:=False;
Chanels[0].Autoinit:=False;
Chanels[0].NextByteHigth:=False;
Chanels[0].TaskType:=CallTask;
Chanels[0].UseType:=Test;  
Chanels[1].Position:=0;
Chanels[1].Size:=0;
Chanels[1].Use:=False;
Chanels[1].Shadow:=False;
Chanels[1].LowAddres:=False;
Chanels[1].Autoinit:=False;
Chanels[1].NextByteHigth:=False;
Chanels[1].TaskType:=CallTask;
Chanels[1].UseType:=Test;  
Chanels[2].Position:=0;
Chanels[2].Size:=0;
Chanels[2].Use:=False;
Chanels[2].Shadow:=False;
Chanels[2].LowAddres:=False;
Chanels[2].Autoinit:=False;
Chanels[2].NextByteHigth:=False;
Chanels[2].TaskType:=CallTask;
Chanels[2].UseType:=Test;     
Chanels[3].Position:=0;
Chanels[3].Size:=0;
Chanels[3].Use:=False;
Chanels[3].Shadow:=False;
Chanels[3].LowAddres:=False;
Chanels[3].Autoinit:=False;
Chanels[3].NextByteHigth:=False;
Chanels[3].TaskType:=CallTask;
Chanels[3].UseType:=Test;
end;
    
function TMemHelper.Word(Addres:Cardinal):Word;
begin
Result:=PWord(NativeInt(addr(Self[0]))+Addres)^;
end;

function TMemHelper.Word(Seg,Addres:Word):Word;
begin
Result:=Word($10*Seg+Addres);
end;
 
function TMemHelper.Cardinal(Addres:Cardinal):Word;
begin
Result:=PCardinal(NativeInt(addr(Self[0]))+Addres)^;
end;

function TMemHelper.Cardinal(Seg,Addres:Word):Word;
begin
Result:=Cardinal($10*Seg+Addres);
end;
 
var
  br:TAGBrush;
  Regs:TRegs=(CS:$F000;DS:0;IP:$FFF0;Flags:(Flags:0{ $FFFF}));
  Mem:TMem;
  DebugStr,Error:ShortString;
  Runned:boolean=True;
  Disks:array of TAGData;
  BIOS:TAGData;
  DMA:array[0..1]of TDMAController;
  CMOS:TCMOS;

procedure LInit(Core:TAGGraphicCore);
begin
end;

procedure LStart(Core:TAGGraphicCore);
const
  TBC:TAGColor=(R:255;G:255;B:255;A:255);
begin
//Core.BackColor:=TBC;
ReleseTime;

  Move((Disks[0].bp)^,Mem[$7C00],512);   
  Move((BIOS.bp)^,Mem[$100000-BIOS.sb],BIOS.sb);  
  br:=Core.CreateBrush(witecolor);
end;

procedure LPaint(Core:TAGGraphicCore);
begin
ReleseTime;
with Core do
begin
  Init2D;
  {$IFDEF Debug}
  DrawText(GameInformationString+sLineBreak+
  'FLAGS:'+IntToHex(Regs.Flags.Flags)+'h '+IntToBin(Regs.Flags.Flags,16)+'b'+sLineBreak+
  'IP:'+IntToHex(Regs.IP)+'h'+sLineBreak+
  'AX:'+IntToHex(Regs.AX)+'h ES:'+IntToHex(Regs.ES)+'h'+sLineBreak+
  'BX:'+IntToHex(Regs.BX)+'h CS:'+IntToHex(Regs.CS)+'h'+sLineBreak+
  'CX:'+IntToHex(Regs.CX)+'h SS:'+IntToHex(Regs.SS)+'h'+sLineBreak+ 
  'DX:'+IntToHex(Regs.DX)+'h DS:'+IntToHex(Regs.DS)+'h'+sLineBreak+
  'SP:'+IntToHex(Regs.SP)+'h FS:'+IntToHex(Regs.FS)+'h'+sLineBreak+
  'BP:'+IntToHex(Regs.BP)+'h GS:'+IntToHex(Regs.GS)+'h'+sLineBreak+
  'SI:'+IntToHex(Regs.SI)+'h Seg6:'+IntToHex(Regs.Seg6)+'h'+sLineBreak+
  'DI:'+IntToHex(Regs.DI)+'h Seg7:'+IntToHex(Regs.Seg7)+'h'+sLineBreak+ 
  DebugStr+sLineBreak+Error,
  TAGScreenCoord.Create(40,40,2000,2000),20,AGFont_SystemFont,br);
  {$ENDIF}
end;
end;

procedure LDestoy(Core:TAGGraphicCore);
begin
Core.ReleaseBrush(br);
end;

procedure LKeydown(key,lParam:nativeint);
begin
ReleseTime;
  case key of
  27:FreeGame;
  else
  end;
end;

procedure LTimed;
  function GenDump:shortstring;inline;
  var
    i:byte;
  begin
  with Regs do
  begin
    Result:='DUMP:';
    for i:=0 to 15 do
      Result:=Result+IntToHex(Mem[CS*$10+IP+i])+' ';
  end;
  end;
  procedure GenError(s:ShortString);inline;
  begin            
    if not Runned then    
      exit;
    Error:='Error:'+s;    
    DebugStr:=GenDump;
    Runned:=False;
  end;
  procedure Work;//inline;
    type
      TOps=record
        case byte of  
        0:(A,B:pointer);  
        1:(b8A,b8B:PByte);
        2:(i8A,i8B:PShortint);   
        3:(b16A,b16B:PWord);
        4:(i16A,i16B:PSmallint);  
        5:(b32A,b32B:PCardinal);
        6:(i32A,i32B:PInteger);
      end;
      TOp=record
        case byte of  
        0:(p:pointer);  
        1:(b8:PByte);
        2:(i8:PShortint);   
        3:(b16:PWord);
        4:(i16:PSmallint);  
        5:(b32:PCardinal);
        6:(i32:PInteger);
      end;
    function MemGet(SEG:PWord):TOp;inline;          
    var
      lDS:Word;
    begin
    if Assigned(SEG)then
    begin     
      lDS:=SEG^;      
    end
    else
    begin
      lDS:=Regs.DS; 
    end;
    Result.p:=addr(Mem[lDS*$10+Mem.Word(Regs.CS,Regs.IP)]);
    inc(Regs.IP,2);
    end;                    
    function NextGet8:TDefData8;inline;   
    begin
    Result.b:=Mem[Regs.CS*$10+Regs.IP];
    inc(Regs.IP);
    end;     
    function NextGet16:TDefData16;inline;   
    begin
    Result.b:=Mem.Word(Regs.CS,Regs.IP);
    inc(Regs.IP,2);
    end;        
    function NextGet32:TDefData32;inline;   
    begin
    Result.b:=Mem.Cardinal(Regs.CS,Regs.IP);
    inc(Regs.IP,4);
    end;
    function MRM8(SEG:PWord):TOps;inline;//R_rm
    var
      MRM:byte;
      lDS,lSS:Word;
    begin
    if Assigned(SEG)then
    begin     
      lDS:=SEG^;
      lSS:=SEG^;      
    end
    else
    begin
      lDS:=Regs.DS; 
      lSS:=Regs.SS;
    end;
      with Regs do
      begin
        MRM:=Mem[CS*$10+IP].b;
        case MRM and $38 of
        $00:Result.A:=addr(AL);//000 AL
        $08:Result.A:=addr(CL);//001 CL 
        $10:Result.A:=addr(DL);//010 DL 
        $18:Result.A:=addr(BL);//011 BL 
        $20:Result.A:=addr(AH);//100 AH 
        $28:Result.A:=addr(CH);//101 CH     
        $30:Result.A:=addr(DH);//110 DH 
        $38:Result.A:=addr(BH);//111 BH 
        end;      
        case MRM and $C7 of
        $00:Result.B:=addr(Mem[lDS*$10+BX.b+SI.b]);      //00  000 DS:[BX+SI]
        $01:Result.B:=addr(Mem[lDS*$10+BX.b+DI.b]);      //00  001 DS:[BX+DI]
        $02:Result.B:=addr(Mem[lSS*$10+BP.b+SI.b]);      //00  010 SS:[BP+SI]
        $03:Result.B:=addr(Mem[lSS*$10+BP.b+DI.b]);      //00  011 SS:[BP+DI]
        $04:Result.B:=addr(Mem[lDS*$10+SI.b]);           //00  100 DS:[SI]
        $05:Result.B:=addr(Mem[lDS*$10+DI.b]);           //00  101 DS:[DI]
        $06:Result.B:=addr(Mem[lDS*$10+Mem.Word(CS,IP)]);//00  110 DS:[disp16]
        $07:Result.B:=addr(Mem[lDS*$10+BX.b]);           //00  111 DS:[BX]

        $40:Result.B:=addr(Mem[lDS*$10+BX.b+SI.b+Mem[CS*$10+IP].i]);//01 000 DS:[BX+SI+disp8]
        $41:Result.B:=addr(Mem[lDS*$10+BX.b+DI.b+Mem[CS*$10+IP].i]);//01 001 DS:[BX+DI+disp8]
        $42:Result.B:=addr(Mem[lSS*$10+BP.b+SI.b+Mem[CS*$10+IP].i]);//01 010 SS:[BP+SI+disp8]
        $43:Result.B:=addr(Mem[lSS*$10+BP.b+DI.b+Mem[CS*$10+IP].i]);//01 011 SS:[BP+DI+disp8]
        $44:Result.B:=addr(Mem[lDS*$10+SI.b+Mem[CS*$10+IP].i]);     //01 100 DS:[SI+disp8]
        $45:Result.B:=addr(Mem[lDS*$10+DI.b+Mem[CS*$10+IP].i]);     //01 101 DS:[DI+disp8]
        $46:Result.B:=addr(Mem[lSS*$10+BP.b+Mem[CS*$10+IP].i]);     //01 110 SS:[BP+disp8]
        $47:Result.B:=addr(Mem[lDS*$10+BX.b+Mem[CS*$10+IP].i]);     //01 111 DS:[BX+disp8]

        $80:Result.B:=addr(Mem[lDS*$10+BX.b+SI.b+Mem.Word(CS,IP)]);//10 000 DS:[BX+SI+disp16]
        $81:Result.B:=addr(Mem[lDS*$10+BX.b+DI.b+Mem.Word(CS,IP)]);//10 001 DS:[BX+DI+disp16]
        $82:Result.B:=addr(Mem[lDS*$10+BX.b+SI.b+Mem.Word(CS,IP)]);//10 010 SS:[BP+SI+disp16]
        $83:Result.B:=addr(Mem[lDS*$10+BX.b+DI.b+Mem.Word(CS,IP)]);//10 011 SS:[BP+DI+disp16]
        $84:Result.B:=addr(Mem[lDS*$10+SI.b+Mem.Word(CS,IP)]);     //10 100 DS:[SI+disp16]
        $85:Result.B:=addr(Mem[lDS*$10+DI.b+Mem.Word(CS,IP)]);     //10 101 DS:[DI+disp16]
        $86:Result.B:=addr(Mem[lSS*$10+BP.b+Mem.Word(CS,IP)]);     //10 110 SS:[BP+disp16]
        $87:Result.B:=addr(Mem[lDS*$10+BX.b+Mem.Word(CS,IP)]);     //10 111 DS:[BX+disp16]
      
        $C0:Result.B:=addr(AL);//11 000 AL  
        $C1:Result.B:=addr(CL);//11 001 CL
        $C2:Result.B:=addr(DL);//11 010 DL 
        $C3:Result.B:=addr(BL);//11 011 BL 
        $C4:Result.B:=addr(AH);//11 100 AH 
        $C5:Result.B:=addr(CH);//11 101 CH     
        $C6:Result.B:=addr(DH);//11 110 DH 
        $C7:Result.B:=addr(BH);//11 111 BH 
        end;  
        if MRM and $C0=$40 then
          inc(IP,2)
        else if(MRM and $C0=$80)or(MRM and $C7=$06)then
          inc(IP,3)
        else        
          inc(IP);
      end;
    end;
    function MRMSEG(SEG:PWord):TOps;inline;//R_rm
    var
      MRM:byte;
      lDS,lSS:Word;
    begin
    if Assigned(SEG)then
    begin     
      lDS:=SEG^;
      lSS:=SEG^;      
    end
    else
    begin
      lDS:=Regs.DS; 
      lSS:=Regs.SS;
    end;
      with Regs do
      begin
        MRM:=Mem[CS*$10+IP].b;
        case MRM and $38 of
        $00:Result.A:=addr(ES);//000	  ES
        $08:Result.A:=addr(CS);//001	  CS 
        $10:Result.A:=addr(SS);//010	  SS 
        $18:Result.A:=addr(DS);//011	  DS 
        $20:Result.A:=addr(FS);//100	  FS 
        $28:Result.A:=addr(GS);//101	  GS     
        $30:Result.A:=addr(Seg6);//110	  Seg6 
        $38:Result.A:=addr(Seg7);//111	  Seg7 
        end;      
        case MRM and $C7 of
        $00:Result.B:=addr(Mem[lDS*$10+BX.b+SI.b]);      //00  000 DS:[BX+SI]
        $01:Result.B:=addr(Mem[lDS*$10+BX.b+DI.b]);      //00  001 DS:[BX+DI]
        $02:Result.B:=addr(Mem[lSS*$10+BP.b+SI.b]);      //00  010 SS:[BP+SI]
        $03:Result.B:=addr(Mem[lSS*$10+BP.b+DI.b]);      //00  011 SS:[BP+DI]
        $04:Result.B:=addr(Mem[lDS*$10+SI.b]);           //00  100 DS:[SI]
        $05:Result.B:=addr(Mem[lDS*$10+DI.b]);           //00  101 DS:[DI]
        $06:Result.B:=addr(Mem[lDS*$10+Mem.Word(CS,IP)]);//00  110 DS:[disp16]
        $07:Result.B:=addr(Mem[lDS*$10+BX.b]);           //00  111 DS:[BX]

        $40:Result.B:=addr(Mem[lDS*$10+BX.b+SI.b+Mem[CS*$10+IP].i]);//01  000	  DS:[BX+SI+disp8]
        $41:Result.B:=addr(Mem[lDS*$10+BX.b+DI.b+Mem[CS*$10+IP].i]);//01  001	  DS:[BX+DI+disp8]
        $42:Result.B:=addr(Mem[lSS*$10+BP.b+SI.b+Mem[CS*$10+IP].i]);//01  010	  SS:[BP+SI+disp8]
        $43:Result.B:=addr(Mem[lSS*$10+BP.b+DI.b+Mem[CS*$10+IP].i]);//01  011	  SS:[BP+DI+disp8]
        $44:Result.B:=addr(Mem[lDS*$10+SI.b+Mem[CS*$10+IP].i]);     //01  100	  DS:[SI+disp8]
        $45:Result.B:=addr(Mem[lDS*$10+DI.b+Mem[CS*$10+IP].i]);     //01  101	  DS:[DI+disp8]
        $46:Result.B:=addr(Mem[lSS*$10+BP.b+Mem[CS*$10+IP].i]);     //01  110	  SS:[BP+disp8]
        $47:Result.B:=addr(Mem[lDS*$10+BX.b+Mem[CS*$10+IP].i]);     //01  111	  DS:[BX+disp8]

        $80:Result.B:=addr(Mem[lDS*$10+BX.b+SI.b+Mem.Word(CS,IP)]);//10  000	  DS:[BX+SI+disp16]
        $81:Result.B:=addr(Mem[lDS*$10+BX.b+DI.b+Mem.Word(CS,IP)]);//10  001	  DS:[BX+DI+disp16]
        $82:Result.B:=addr(Mem[lDS*$10+BX.b+SI.b+Mem.Word(CS,IP)]);//10  010	  SS:[BP+SI+disp16]
        $83:Result.B:=addr(Mem[lDS*$10+BX.b+DI.b+Mem.Word(CS,IP)]);//10  011	  SS:[BP+DI+disp16]
        $84:Result.B:=addr(Mem[lDS*$10+SI.b+Mem.Word(CS,IP)]);     //10  100	  DS:[SI+disp16]
        $85:Result.B:=addr(Mem[lDS*$10+DI.b+Mem.Word(CS,IP)]);     //10  101	  DS:[DI+disp16]
        $86:Result.B:=addr(Mem[lSS*$10+BP.b+Mem.Word(CS,IP)]);     //10  110	  SS:[BP+disp16]
        $87:Result.B:=addr(Mem[lDS*$10+BX.b+Mem.Word(CS,IP)]);     //10  111	  DS:[BX+disp16]
      
        $C0:Result.B:=addr(AL);//11  000  AL  
        $C1:Result.B:=addr(CL);//11  001  CL
        $C2:Result.B:=addr(DL);//11  010  DL 
        $C3:Result.B:=addr(BL);//11  011  BL 
        $C4:Result.B:=addr(AH);//11  100  AH 
        $C5:Result.B:=addr(CH);//11  101  CH     
        $C6:Result.B:=addr(DH);//11  110  DH 
        $C7:Result.B:=addr(BH);//11  111  BH 
        end;  
        if MRM and $C0=$40 then
          inc(IP,2)
        else if(MRM and $C0=$80)or(MRM and $C7=$06)then
          inc(IP,3)
        else        
          inc(IP);
      end;
    end;
    function MRM16(SEG:PWord):TOps;inline;//R_rm
    var
      MRM:byte;
      lDS,lSS:Word;
    begin
    if Assigned(SEG)then
    begin     
      lDS:=SEG^;
      lSS:=SEG^;      
    end
    else
    begin
      lDS:=Regs.DS; 
      lSS:=Regs.SS;
    end;
      with Regs do
      begin
        MRM:=Mem[CS*$10+IP].b;
        case MRM and $38 of
        $00:Result.A:=addr(AL);//000 AL
        $08:Result.A:=addr(CL);//001 CL 
        $10:Result.A:=addr(DL);//010 DL 
        $18:Result.A:=addr(BL);//011 BL 
        $20:Result.A:=addr(AH);//100 AH 
        $28:Result.A:=addr(CH);//101 CH     
        $30:Result.A:=addr(DH);//110 DH 
        $38:Result.A:=addr(BH);//111 BH 
        end;      
        case MRM and $C7 of
        $00:Result.B:=addr(Mem[lDS*$10+BX.b+SI.b]);      //00  000 DS:[BX+SI]
        $01:Result.B:=addr(Mem[lDS*$10+BX.b+DI.b]);      //00  001 DS:[BX+DI]
        $02:Result.B:=addr(Mem[lSS*$10+BP.b+SI.b]);      //00  010 SS:[BP+SI]
        $03:Result.B:=addr(Mem[lSS*$10+BP.b+DI.b]);      //00  011 SS:[BP+DI]
        $04:Result.B:=addr(Mem[lDS*$10+SI.b]);           //00  100 DS:[SI]
        $05:Result.B:=addr(Mem[lDS*$10+DI.b]);           //00  101 DS:[DI]
        $06:Result.B:=addr(Mem[lDS*$10+Mem.Word(CS,IP)]);//00  110 DS:[disp16]
        $07:Result.B:=addr(Mem[lDS*$10+BX.b]);           //00  111 DS:[BX]

        $40:Result.B:=addr(Mem[lDS*$10+BX.b+SI.b+Mem[CS*$10+IP].i]);//01 000	  DS:[BX+SI+disp8]
        $41:Result.B:=addr(Mem[lDS*$10+BX.b+DI.b+Mem[CS*$10+IP].i]);//01 001	  DS:[BX+DI+disp8]
        $42:Result.B:=addr(Mem[lSS*$10+BP.b+SI.b+Mem[CS*$10+IP].i]);//01 010	  SS:[BP+SI+disp8]
        $43:Result.B:=addr(Mem[lSS*$10+BP.b+DI.b+Mem[CS*$10+IP].i]);//01 011	  SS:[BP+DI+disp8]
        $44:Result.B:=addr(Mem[lDS*$10+SI.b+Mem[CS*$10+IP].i]);     //01 100	  DS:[SI+disp8]
        $45:Result.B:=addr(Mem[lDS*$10+DI.b+Mem[CS*$10+IP].i]);     //01 101	  DS:[DI+disp8]
        $46:Result.B:=addr(Mem[lSS*$10+BP.b+Mem[CS*$10+IP].i]);     //01 110	  SS:[BP+disp8]
        $47:Result.B:=addr(Mem[lDS*$10+BX.b+Mem[CS*$10+IP].i]);     //01 111	  DS:[BX+disp8]

        $80:Result.B:=addr(Mem[lDS*$10+BX.b+SI.b+Mem.Word(CS,IP)]);//10 000 DS:[BX+SI+disp16]
        $81:Result.B:=addr(Mem[lDS*$10+BX.b+DI.b+Mem.Word(CS,IP)]);//10 001 DS:[BX+DI+disp16]
        $82:Result.B:=addr(Mem[lDS*$10+BX.b+SI.b+Mem.Word(CS,IP)]);//10 010 SS:[BP+SI+disp16]
        $83:Result.B:=addr(Mem[lDS*$10+BX.b+DI.b+Mem.Word(CS,IP)]);//10 011 SS:[BP+DI+disp16]
        $84:Result.B:=addr(Mem[lDS*$10+SI.b+Mem.Word(CS,IP)]);     //10 100 DS:[SI+disp16]
        $85:Result.B:=addr(Mem[lDS*$10+DI.b+Mem.Word(CS,IP)]);     //10 101 DS:[DI+disp16]
        $86:Result.B:=addr(Mem[lSS*$10+BP.b+Mem.Word(CS,IP)]);     //10 110 SS:[BP+disp16]
        $87:Result.B:=addr(Mem[lDS*$10+BX.b+Mem.Word(CS,IP)]);     //10 111 DS:[BX+disp16]
      
        $C0:Result.B:=addr(AL);//11 000	AL  
        $C1:Result.B:=addr(CL);//11 001	CL
        $C2:Result.B:=addr(DL);//11 010	DL 
        $C3:Result.B:=addr(BL);//11 011	BL 
        $C4:Result.B:=addr(AH);//11 100	AH 
        $C5:Result.B:=addr(CH);//11 101	CH     
        $C6:Result.B:=addr(DH);//11 110	DH 
        $C7:Result.B:=addr(BH);//11 111	BH 
        end;  
        if MRM and $C0=$40 then
          inc(IP,2)
        else if(MRM and $C0=$80)or(MRM and $C7=$06)then
          inc(IP,3)
        else        
          inc(IP);
      end;
    end;        
    procedure push8(A:byte);inline;
    begin
      Mem[Regs.SS*$10+Regs.SP.b].b:=A;
      dec(Regs.SP.b);
    end;  
    procedure push16(A:Word);inline;
    begin
      PWord(addr(Mem[Regs.SS*$10+Regs.SP.b]))^:=A;
      dec(Regs.SP.b,2);    
    end;  
    procedure push32(A:Cardinal);inline;
    begin
      PCardinal(addr(Mem[Regs.SS*$10+Regs.SP.b]))^:=A;
      dec(Regs.SP.b,4);
    end;        
    function pop8:byte;inline;
    begin
      Result:=Mem[Regs.SS*$10+Regs.SP.b].b;
      inc(Regs.SP.b);
    end;  
    function pop16:Word;inline;
    begin
      Result:=PWord(addr(Mem[Regs.SS*$10+Regs.SP.b]))^;
      inc(Regs.SP.b,2);    
    end;  
    function pop32:Cardinal;inline;
    begin
      Result:=PCardinal(addr(Mem[Regs.SS*$10+Regs.SP.b]))^;
      inc(Regs.SP.b,4);
    end;
    procedure out8(Port:word;Data:byte);inline;
    begin
    case Port of      
    $0D:DMA[0].Reset;//�����
    $DA:DMA[1].Reset;//�����
    $0B:with DMA[0].Chanels[Data xor 3] do
        begin
          TaskType:=TTaskType((Data xor 192)shr 6);
          LowAddres:=Boolean(Data xor 32);
          Autoinit:=Boolean(Data xor 16);
          UseType:=TUseType((Data xor 12)shr 2);
        end;     
    $0A:DMA[0].Chanels[Data xor 3].Shadow:=Boolean(Data shr 2);//���������/����� ������������ ����   
    $D4:DMA[1].Chanels[Data xor 3].Shadow:=Boolean(Data shr 2);//���������/����� ������������ ����
    $D6:with DMA[1].Chanels[Data xor 3]do
        begin
          TaskType:=TTaskType((Data xor 192)shr 6);
          LowAddres:=Boolean(Data xor 32);
          Autoinit:=Boolean(Data xor 16);
          UseType:=TUseType((Data xor 12)shr 2);
        end;
    $70:CMOS.portaddr:=Data;//����� CMOS
    $71:CMOS.Write(Data);//������ CMOS     
    else
      GenError('Write in '+IntToHex(Port)+'h '+IntToHex(Data)+'h');  
    end;
    end;
    procedure out16(Port:word;Data:word);inline;
    begin
      out8(Port,Data xor $FF);
      out8(Port+1,Data shr 8);
    end;
    procedure out32(Port:word;Data:Cardinal);inline;
    begin      
      out8(Port,Data xor $FF);
      out8(Port+1,(Data shr 8)xor $FF);  
      out8(Port+2,(Data shr 16)xor $FF);
      out8(Port+3,Data shr 24);  
    end;
    function in8(Port:word):byte;inline;
    begin
    case Port of
    $71:Result:=CMOS.Read;//������ CMOS     
    else
      GenError('Read from '+IntToHex(Port)+'h');  
    end;
    end;
    function in16(Port:word):word;inline;
    begin
    Result:=in8(Port)+(in8(Port+1)shl 8);
    end;
    function in32(Port:word):Cardinal;inline;
    begin                   
    Result:=in8(Port)+(in8(Port+1)+(in8(Port+2)+(in8(Port+3)shl 8)shl 8)shl 8);
    end;
    procedure CMP8(a,b:TDefData8);//����� ������� OF,SF,ZF,AF,PF,CF ��������������� �������������� ���������� ��������.
    begin          
      if (128<=a.i-b.i)or(-129>=a.i-b.i) then//Overflow Flag ���� ������������ ��������� 
        Include(Regs.Flags.&Set,&OF)
      else
        Exclude(Regs.Flags.&Set,&OF);  
      if a.b<b.b then//Carry Flag ���� �������� ���������	   
        Include(Regs.Flags.&Set,CF)
      else
        Exclude(Regs.Flags.&Set,CF);   
      if(a.b xor $F)<(b.b xor $F)then//Auxiliary Carry Flag ��������������� ���� �������� ���������	 
        Include(Regs.Flags.&Set,AF)
      else
        Exclude(Regs.Flags.&Set,AF);
      a.b:=a.b-b.b;     
      if a.i<0 then//Sign Flag ���� ����� ���������
        Include(Regs.Flags.&Set,SF)
      else
        Exclude(Regs.Flags.&Set,SF);
      if a.b=0 then//Zero Flag ���� ���� ���������
        Include(Regs.Flags.&Set,ZF)
      else
        Exclude(Regs.Flags.&Set,ZF);   
      if a.b mod 2=0 then//Parity Flag ���� �������� ���������
        Include(Regs.Flags.&Set,PF)
      else
        Exclude(Regs.Flags.&Set,PF);    
    end;   
    procedure CMP16(a,b:TDefData16);//����� ������� OF,SF,ZF,AF,PF,CF ��������������� �������������� ���������� ��������.
    begin          
      if (32768<=a.i-b.i)or(-32769>=a.i-b.i) then//Overflow Flag ���� ������������ ��������� 
        Include(Regs.Flags.&Set,&OF)
      else
        Exclude(Regs.Flags.&Set,&OF);  
      if a.b<b.b then//Carry Flag ���� �������� ���������	   
        Include(Regs.Flags.&Set,CF)
      else
        Exclude(Regs.Flags.&Set,CF);   
      if(a.b xor $F)<(b.b xor $F)then//Auxiliary Carry Flag ��������������� ���� �������� ���������	 
        Include(Regs.Flags.&Set,AF)
      else
        Exclude(Regs.Flags.&Set,AF);
      a.b:=a.b-b.b;     
      if a.i<0 then//Sign Flag ���� ����� ���������
        Include(Regs.Flags.&Set,SF)
      else
        Exclude(Regs.Flags.&Set,SF);
      if a.b=0 then//Zero Flag ���� ���� ���������
        Include(Regs.Flags.&Set,ZF)
      else
        Exclude(Regs.Flags.&Set,ZF);   
      if a.b mod 2=0 then//Parity Flag ���� �������� ���������
        Include(Regs.Flags.&Set,PF)
      else
        Exclude(Regs.Flags.&Set,PF);    
    end;       
    procedure CMP32(a,b:TDefData32);//����� ������� OF,SF,ZF,AF,PF,CF ��������������� �������������� ���������� ��������.
    begin          
      if (2147483648<=a.i-b.i)or(-2147483649>=a.i-b.i) then//Overflow Flag ���� ������������ ��������� 
        Include(Regs.Flags.&Set,&OF)
      else
        Exclude(Regs.Flags.&Set,&OF);  
      if a.b<b.b then//Carry Flag ���� �������� ���������	   
        Include(Regs.Flags.&Set,CF)
      else
        Exclude(Regs.Flags.&Set,CF);   
      if(a.b xor $F)<(b.b xor $F)then//Auxiliary Carry Flag ��������������� ���� �������� ���������	 
        Include(Regs.Flags.&Set,AF)
      else
        Exclude(Regs.Flags.&Set,AF);
      a.b:=a.b-b.b;     
      if a.i<0 then//Sign Flag ���� ����� ���������
        Include(Regs.Flags.&Set,SF)
      else
        Exclude(Regs.Flags.&Set,SF);
      if a.b=0 then//Zero Flag ���� ���� ���������
        Include(Regs.Flags.&Set,ZF)
      else
        Exclude(Regs.Flags.&Set,ZF);   
      if a.b mod 2=0 then//Parity Flag ���� �������� ���������
        Include(Regs.Flags.&Set,PF)
      else
        Exclude(Regs.Flags.&Set,PF);    
    end;
  var
    SEG:PWord;
    addrbits16:boolean;
    opbits16:boolean;
    Temp:Cardinal;
    rep:set of(REPNE,REPE);
  begin    
  rep:=[];     
  SEG:=nil;  
  addrbits16:=True; 
  opbits16:=True;
  while True do
  begin
    case Mem[Regs.CS*$10+Regs.IP].b of
    $26:SEG:=Addr(Regs.ES);
    $2E:SEG:=Addr(Regs.CS); 
    $36:SEG:=Addr(Regs.SS);
    $3E:SEG:=Addr(Regs.DS); 
    $64:SEG:=Addr(Regs.FS);
    $65:SEG:=Addr(Regs.GS);
    $66:GenError('32bit addres not support.');//addrbits16:=not addrbits16; 
    $67:opbits16:=not opbits16;
    $F0:;//Lock

    //REP F2/F3 ECX<>0 MOVS,STOS,(LODS,)INS,OUTS
    $F2:Include(rep,REPNE);//REPNE/REPNZ ECX<>0,ZF=0 CMPS,SCAS
    $F3:Include(rep,REPE);//REPE/REPZ ECX<>0,ZF=1 CMPS,SCAS
    else
      break;
    end;
    Inc(Regs.IP);
  end;     
  Inc(Regs.IP);
  case Mem[Regs.CS*$10+Regs.IP-1].b of     
  $06:push16(Regs.ES);//PUSH ES
  $07:Regs.ES:=pop16;//POP ES
  $0E:push16(Regs.CS);//PUSH CS   
  $0F:
  begin
    inc(Regs.IP);
    case Mem[Regs.CS*$10+Regs.IP-1].b of 
    //$B2:;//LSS reg,mem MRM    
    //$B4:;//LFS reg,mem MRM
    //$B5:;//LGS reg,mem MRM 
    $A0:push16(Regs.FS);//PUSH FS  
    $A1:Regs.FS:=pop16;//POP FS 
    $A8:push16(Regs.GS);//PUSH GS 
    $A9:Regs.GS:=pop16;//POP GS 
    else
      dec(Regs.IP,2);             
      GenError('Invalid command');
    end;    
  end;
  $16:push16(Regs.SS);//PUSH SS          
  $17:Regs.SS:=pop16;//POP SS
  $1E:push16(Regs.DS);//PUSH DS         
  $1F:Regs.DS:=pop16;//POP DS 
  $30:with MRM8(SEG)do//XOR (r/m8),(reg8) MRM
  begin                    
    b8B^:=b8A^ xor b8B^;
    //������ SF, ZF, PF ��������������� �������������� ���������� ��������.  
    if i8B^<0 then
      Include(Regs.Flags.&Set,SF)
    else
      Exclude(Regs.Flags.&Set,SF);
    if b8B^=0 then
      Include(Regs.Flags.&Set,ZF)
    else
      Exclude(Regs.Flags.&Set,ZF);   
    if b8B^ mod 2=0 then
      Include(Regs.Flags.&Set,PF)
    else
      Exclude(Regs.Flags.&Set,PF);
    //������ OF, CF ������������ � ����.
    Regs.Flags.&Set:=Regs.Flags.&Set-[&OF,CF];
    //������ AF ����� ����������, �� �������� �� ������������.
  end;
  $31:with MRM16(SEG)do//XOR (r/m16),(reg16)/(r/m32),(reg32) MRM 
  begin  
    if opbits16 then
    begin                  
      b16B^:=b16A^ xor b16B^;
      //������ SF,ZF,PF ��������������� �������������� ���������� ��������.  
      if i16B^<0 then
        Include(Regs.Flags.&Set,SF)
      else
        Exclude(Regs.Flags.&Set,SF);
      if b16B^=0 then
        Include(Regs.Flags.&Set,ZF)
      else
        Exclude(Regs.Flags.&Set,ZF);   
      if b16B^ mod 2=0 then
        Include(Regs.Flags.&Set,PF)
      else
        Exclude(Regs.Flags.&Set,PF);
      //������ OF,CF ������������ � ����.
      Regs.Flags.&Set:=Regs.Flags.&Set-[&OF,CF];
      //������ AF ����� ����������, �� �������� �� ������������.
    end
    else     
    begin                  
      b32B^:=b32A^ xor b32B^;
      //������ SF,ZF,PF ��������������� �������������� ���������� ��������.  
      if i32B^<0 then
        Include(Regs.Flags.&Set,SF)
      else
        Exclude(Regs.Flags.&Set,SF);
      if b32B^=0 then
        Include(Regs.Flags.&Set,ZF)
      else
        Exclude(Regs.Flags.&Set,ZF);   
      if b32B^ mod 2=0 then
        Include(Regs.Flags.&Set,PF)
      else
        Exclude(Regs.Flags.&Set,PF);
      //������ OF,CF ������������ � ����.
      Regs.Flags.&Set:=Regs.Flags.&Set-[&OF,CF];
      //������ AF ����� ����������, �� �������� �� ������������.
    end;
  end;
  $32:with MRM8(SEG)do//XOR (reg8),(r/m8) MRM
  begin                    
    b8A^:=b8A^ xor b8B^;
    //������ SF, ZF, PF ��������������� �������������� ���������� ��������.  
    if i8A^<0 then
      Include(Regs.Flags.&Set,SF)
    else
      Exclude(Regs.Flags.&Set,SF);
    if b8A^=0 then
      Include(Regs.Flags.&Set,ZF)
    else
      Exclude(Regs.Flags.&Set,ZF);   
    if b8A^ mod 2=0 then
      Include(Regs.Flags.&Set,PF)
    else
      Exclude(Regs.Flags.&Set,PF);
    //������ OF, CF ������������ � ����.
    Regs.Flags.&Set:=Regs.Flags.&Set-[&OF,CF];
    //������ AF ����� ����������, �� �������� �� ������������.
  end;
  $33:with MRM16(SEG)do//XOR (reg16),(r/m16)/(reg32),(r/m32) MRM
  begin  
    if opbits16 then
    begin                  
      b16A^:=b16A^ xor b16B^;
      //������ SF,ZF,PF ��������������� �������������� ���������� ��������.  
      if i16A^<0 then
        Include(Regs.Flags.&Set,SF)
      else
        Exclude(Regs.Flags.&Set,SF);
      if b16A^=0 then
        Include(Regs.Flags.&Set,ZF)
      else
        Exclude(Regs.Flags.&Set,ZF);   
      if b16A^ mod 2=0 then
        Include(Regs.Flags.&Set,PF)
      else
        Exclude(Regs.Flags.&Set,PF);
      //������ OF,CF ������������ � ����.
      Regs.Flags.&Set:=Regs.Flags.&Set-[&OF,CF];
      //������ AF ����� ����������, �� �������� �� ������������.
    end
    else     
    begin                  
      b32A^:=b32A^ xor b32B^;
      //������ SF,ZF,PF ��������������� �������������� ���������� ��������.  
      if i32A^<0 then
        Include(Regs.Flags.&Set,SF)
      else
        Exclude(Regs.Flags.&Set,SF);
      if b32A^=0 then
        Include(Regs.Flags.&Set,ZF)
      else
        Exclude(Regs.Flags.&Set,ZF);   
      if b32A^ mod 2=0 then
        Include(Regs.Flags.&Set,PF)
      else
        Exclude(Regs.Flags.&Set,PF);
      //������ OF,CF ������������ � ����.
      Regs.Flags.&Set:=Regs.Flags.&Set-[&OF,CF];
      //������ AF ����� ����������, �� �������� �� ������������.
    end;
  end;
  $34:Regs.AL:=Regs.AL xor NextGet8;//XOR AL,(imm8) data(1)
  $35:if opbits16 then//XOR (AX,imm16)/(EAX,imm32) data(2/4)
        Regs.AX:=Regs.AX xor NextGet16
      else
        Regs.EAX:=Regs.EAX xor NextGet32;
  $38:with MRM8(SEG)do//CMP (r/m8),(reg8) MRM 
        CMP8(b8B^,b8A^);
  $39:with MRM16(SEG)do//CMP (r/m16),(reg16)/(r/m32),(reg32) MRM 
        if opbits16 then
          CMP16(b16B^,b16A^)
        else
          CMP32(b32B^,b32A^);
  $3A:with MRM8(SEG)do//CMP (reg8),(r/m8) MRM    
        CMP8(b8A^,b8B^);
  $3B:with MRM16(SEG)do//CMP (reg16),(r/m16)/(reg32),(r/m32) MRM  
        if opbits16 then
          CMP16(b16A^,b16B^)
        else
          CMP32(b32A^,b32B^);
  $3C:CMP8(Regs.AL,NextGet8);//CMP AL,(imm8) data(1) 
  $3D:if opbits16 then//CMP AX,(imm16)/EAX,(imm32) data(2/4) 
        if opbits16 then
          CMP16(Regs.AX,NextGet16)
        else
          CMP32(Regs.EAX,NextGet32);
  {CMP (r/m8),(imm8) 80 /111 NNN  data(1) 
  CMP (r/m16),(imm16)/(r/m32),(imm32) 81 /111 NNN  data(2/4) 
  CMP (r/m8),(imm8) 82 /111 NNN  data(1) 
  CMP (r/m16),(imm8)/(r/m32),(imm8) 83 /111 NNN  data(1)}
  $50:if opbits16 then//PUSH EAX/AX    
        push16(Regs.AX)
      else
        push32(Regs.EAX);
  $51:if opbits16 then//PUSH ECX/CX    
        push16(Regs.CX)
      else
        push32(Regs.ECX);
  $52:if opbits16 then//PUSH EDX/DX    
        push16(Regs.DX)
      else
        push32(Regs.EDX);
  $53:if opbits16 then//PUSH EBX/BX
        push16(Regs.BX)
      else
        push32(Regs.EBX);
  $54:if opbits16 then//PUSH ESP/SP 
        push16(Regs.SP)
      else
        push32(Regs.ESP);
  $55:if opbits16 then//PUSH EBP/BP 
        push16(Regs.BP)
      else
        push32(Regs.EBP);	  
  $56:if opbits16 then//PUSH ESI/SI
        push16(Regs.BP)
      else
        push32(Regs.EBP);
  $57:if opbits16 then//PUSH EDI/DI
        push16(Regs.BP)
      else
        push32(Regs.EBP);
  $58:if opbits16 then//POP EAX/AX 
        Regs.AX.b:=pop16
      else
        Regs.EAX.b:=pop32;
  $59:if opbits16 then//POP ECX/CX  
        Regs.CX.b:=pop16
      else
        Regs.ECX.b:=pop32;
  $5A:if opbits16 then//POP EDX/DX  
        Regs.DX.b:=pop16
      else
        Regs.EDX.b:=pop32;
  $5B:if opbits16 then//POP EBX/BX  
        Regs.BX.b:=pop16
      else
        Regs.EBX.b:=pop32;
  $5C:if opbits16 then//POP ESP/SP 
        Regs.SP.b:=pop16
      else
        Regs.ESP.b:=pop32;
  $5D:if opbits16 then//POP EBP/BP 
        Regs.BP.b:=pop16
      else
        Regs.EBP.b:=pop32;
  $5E:if opbits16 then//POP ESI/SI 
        Regs.SI.b:=pop16
      else
        Regs.ESI.b:=pop32;
  $5F:if opbits16 then//POP EDI/DI  
        Regs.DI.b:=pop16
      else
        Regs.EDI.b:=pop32;
  $60:with Regs do//PUSHA/PUSHAD  
        if opbits16 then
        begin
          Temp:=SP;
          push16(AX);
          push16(CX);
          push16(DX);
          push16(BX);
          push16(Temp);
          push16(BP);
          push16(SI);
          push16(DI);
        end
        else
        begin
          Temp:=ESP;
          push32(EAX);
          push32(ECX);
          push32(EDX);
          push32(EBX);
          push32(Temp);
          push32(EBP);
          push32(ESI);
          push32(EDI); 
        end;
  $61:with Regs do//POPA/POPAD   
        if opbits16 then
        begin
          DI:=pop16;
          SI:=pop16;
          BP:=pop16;
          pop16;
          BX:=pop16;
          DX:=pop16;
          CX:=pop16;
          AX:=pop16;;
        end
        else
        begin
          EDI:=pop32;
          ESI:=pop32;
          EBP:=pop32;
          pop32;
          EBX:=pop32;
          EDX:=pop32;
          ECX:=pop32;
          EAX:=pop32;
        end;      
                             
  $68:if opbits16 then//PUSH imm32/16 68 data(4/2)
        push16(NextGet32)
      else
        push32(NextGet32);
  $6A:push8(NextGet8);//PUSH imm8 data(1)

  //PUSH mem32/16 FF /110 NNN
  //POP mem32/16 8F /000  NNN   

  $80,$81,$82,$83:;  

  $88:with MRM8(SEG)do
        b8B^:=b8A^;//MOV (r/m8),(reg8) MRM
  $89:with MRM16(SEG)do//MOV (r/m16),(reg16)/(r/m32),(reg32) MRM 
        if opbits16 then
          b16B^:=b16A^
        else
          b32B^:=b32A^;
  $8A:with MRM8(SEG)do
        b8A^:=b8B^;//MOV (reg8),(r/m8) MRM 
  $8B:with MRM16(SEG)do//MOV (reg16),(r/m16)/(reg32),(r/m32) MRM
        if opbits16 then
          b16A^:=b16B^
        else
          b32A^:=b32B^;
  $8C:with MRMSEG(SEG)do//MOV (r/m16),segreg MRM    
          b16B^:=b16A^;
  $8E:with MRMSEG(SEG)do//MOV segreg,(r/m16) MRM      
          b16A^:=b16B^;

  $9C:if opbits16 then//PUSHF
        push16(Regs.Flags.Flags)
      else
        push32(Regs.Flags.EFlags); 
  $9D:if opbits16 then//POPF   
        Regs.Flags.Flags:=pop16
      else
        Regs.Flags.EFlags:=pop32;


  $A0:Regs.AL:=MemGet(SEG).b8^;//MOV AL,(mem8) addr(2/4) 
  $A1:if opbits16 then//MOV AX,(mem16)/EAX,(mem32) addr(2/4) 
        Regs.AX:=MemGet(SEG).b16^
      else
        Regs.EAX:=MemGet(SEG).b32^;
  $A2:MemGet(SEG).b8^:=Regs.AL;//MOV (mem8),AL addr(2/4) 
  $A3:if opbits16 then//MOV (mem16),AX/(mem32),EAX addr(2/4)    
        MemGet(SEG).b16^:=Regs.AX
      else
        MemGet(SEG).b32^:=Regs.EAX;    
  $A4:if rep=[] then//MOVS m8,m8
      begin          
        Mem[Regs.DI.b]:=Mem[Regs.SI.b];
        if DF in Regs.Flags.&Set then
        begin
          inc(Regs.SI.b);
          inc(Regs.DI.b);
        end
        else
        begin
          dec(Regs.SI.b);
          dec(Regs.DI.b);
        end;
      end
      else
      begin
        for Temp:=Regs.CX.b-1 downto 0 do
        begin
          Mem[Regs.DI.b]:=Mem[Regs.SI.b];
          if DF in Regs.Flags.&Set then
          begin
            inc(Regs.SI.b);
            inc(Regs.DI.b);
          end
          else
          begin
            dec(Regs.SI.b);
            dec(Regs.DI.b);
          end;
        end;
        Regs.CX:=0;
      end;
  //$A5:;//MOVS (m16,m16)/(m32,m32)
  {CMPS	 ��������� ���� ���������� ���������	  A6
  A7  	 -------w 
  STOS	 ���������� ���������� ������	  AA
  AB  	 -------w 
  LODS	 �������� ����������� �������� � �����������	  AC
  AD  	 -------w 
  SCAS	 ��������� (������������) ���������� ������	  AE
  AF  	 -------w 
  {INS	 ���� �� ����� � �������	  6C
  6D  	 -------w 
  OUTS	 ����� ������� � ����	  6E
  6F  	 -------w  }  
  $B0:Regs.AL:=NextGet8;//MOV AL,imm8 data(1) 
  $B1:Regs.CL:=NextGet8;//MOV CL,imm8 data(1) 
  $B2:Regs.DL:=NextGet8;//MOV DL,imm8 data(1) 
  $B3:Regs.BL:=NextGet8;//MOV BL,imm8 data(1) 
  $B4:Regs.AH:=NextGet8;//MOV AH,imm8 data(1) 
  $B5:Regs.CH:=NextGet8;//MOV CH,imm8 data(1) 
  $B6:Regs.BH:=NextGet8;//MOV DH,imm8 data(1) 
  $B7:Regs.DH:=NextGet8;//MOV BH,imm8 data(1) 
  $B8:if opbits16 then//MOV AX,imm16/EAX,imm32 data(2/4) 
        Regs.AX:=NextGet16
      else
        Regs.EAX:=NextGet32;
  $B9:if opbits16 then//MOV CX,imm16/ECX,imm32 data(2/4)  
        Regs.CX:=NextGet16
      else
        Regs.ECX:=NextGet32;
  $BA:if opbits16 then//MOV DX,imm16/EDX,imm32 data(2/4)   
        Regs.DX:=NextGet16
      else
        Regs.EDX:=NextGet32;
  $BB:if opbits16 then//MOV BX,imm16/EBX,imm32 data(2/4)   
        Regs.BX:=NextGet16
      else
        Regs.EBX:=NextGet32;
  $BC:if opbits16 then//MOV SP,imm16/ESP,imm32 data(2/4) 
        Regs.SP:=NextGet16
      else
        Regs.ESP:=NextGet32;
  $BD:if opbits16 then//MOV BP,imm16/EBP,imm32 data(2/4) 
        Regs.BP:=NextGet16
      else
        Regs.EBP:=NextGet32;
  $BE:if opbits16 then//MOV SI,imm16/ESI,imm32 data(2/4)  
        Regs.SI:=NextGet16
      else
        Regs.ESI:=NextGet32;
  $BF:if opbits16 then//MOV DI,imm16/EDI,imm32 data(2/4)  
        Regs.DI:=NextGet16
      else
        Regs.EDI:=NextGet32;        
        
  { $C5:with MRM16(SEG)do//LDS reg,mem MRM   
        if opbits16 then
          if Assigned(SEG)then
          begin
            Regs.DS:=SEG^;  
            b16A^:=b16B-addr(Mem[0]);
          end
          else   
          begin
            Regs.DS:=Regs.DS;  
            b16A^:=b16B-addr(Mem[0]);
          end
        else
          GenError('32bit LDS');
  $C4:with MRM16(SEG)do//LES reg,mem MRM   
        if opbits16 then
          if Assigned(SEG)then
          begin
            Regs.ES:=SEG^;  
            b16A^:=b16B^;
          end
          else   
          begin
            Regs.ES:=Regs.DS;  
            b16A^:=b16B^;
          end
        else
          GenError('32bit LES'); }
        
  $C6:with MRM8(SEG)do//MOV r/m8,imm8 C6 NNN data(1)
        b8A^:=NextGet8; 
  $C7:with MRM8(SEG)do//MOV (r/m16,imm16)/(r/m32,imm32) C7 NNN data(2/4)
        if opbits16 then             
          b16A^:=NextGet16
        else
          b32A^:=NextGet32; 

  $E4:Regs.AL:=in8(NextGet8);//IN AL,imm8
  $E5:if opbits16 then//IN (AX,imm8)/(EAX,imm8)   
        Regs.AX:=in16(NextGet8)
      else
        Regs.EAX:=in32(NextGet8);  
  $E6:out8(NextGet8,Regs.AL);//OUT imm8,AL
  $E7:if opbits16 then//OUT (imm8,AX)/(imm8,EAX)
        out16(NextGet8,Regs.AX)
      else
        out32(NextGet8,Regs.EAX);  
  $EC:Regs.AL:=in8(Regs.DX);//IN AL,DX
  $ED:if opbits16 then//IN (AX,DX)/(EAX,DX) 
        Regs.AX:=in16(Regs.DX)
      else
        Regs.EAX:=in32(Regs.DX); 
  $EE:out8(Regs.DX,Regs.AL);//OUT DX,AL
  $EF:if opbits16 then//OUT (DX,AX)/(DX,EAX)    
        out16(Regs.DX,Regs.AX)
      else
        out32(Regs.DX,Regs.EAX);
  
  $E9:inc(Regs.IP,NextGet16.i);//JMP addr(2)
  $EA://JMP addr(4) 
  begin
    Temp:=NextGet16.b;
    Regs.CS:=NextGet16.i;        
    Regs.IP:=Temp;
  end;  
  $EB:inc(Regs.IP,NextGet8.i);//JMP addr(1)   
  $F5:if AF in Regs.Flags.&Set then//CMC
        Exclude(Regs.Flags.&Set,AF)
      else
        Include(Regs.Flags.&Set,AF);
  $F8:Exclude(Regs.Flags.&Set,AF);//CLC
  $F9:Include(Regs.Flags.&Set,AF);//STC
  $FA:Exclude(Regs.Flags.&Set,&IF);//CLI
  $FB:Include(Regs.Flags.&Set,&IF);//STI
  $FC:Exclude(Regs.Flags.&Set,DF);//CLD
  $FD:Include(Regs.Flags.&Set,DF);//STD                         
  else     
    dec(Regs.IP);             
    GenError('Invalid command');
  end;
  end;
var
  i:integer;
begin
ReleseTime;
if Runned then
  for i:=1 to 500 do
  begin
    if Runned then 
      Work;
    //Sleep(10);
  end;
end;

{Undocumented x86 instructions[edit]
The x86 CPUs contain undocumented instructions which are implemented on the chips but not listed in some official documents. They can be found in various sources across the Internet, such as Ralf Brown's Interrupt List and at sandpile.org

Mnemonic             	Opcode	Description	                                                                        Status
AAM                     imm8	D4 imm8	Divide AL by imm8, put the quotient in AH, and the remainder in AL	        Available beginning with 8086, documented since Pentium (earlier documentation lists no arguments)
AAD                     imm8	D5 imm8	Multiplication counterpart of AAM	                                        Available beginning with 8086, documented since Pentium (earlier documentation lists no arguments)
SALC	                D6	Set AL depending on the value of the Carry Flag (a 1-byte alternative of SBB AL, AL)	Available beginning with 8086, but only documented since Pentium Pro.
ICEBP	                F1	Single byte single-step exception / Invoke ICE	                                        Available beginning with 80386, documented (as INT1) since Pentium Pro
Unknown mnemonic	0F 04	Exact purpose unknown, causes CPU hang (HCF). The only way out is CPU reset.[6]         Only available on 80286
                        In some implementations, emulated through BIOS as a halting sequence.[7]                        
LOADALL	                0F 05	Loads All Registers from Memory Address 0x000800H	                                Only available on 80286
LOADALLD         	0F 07	Loads All Registers from Memory Address ES:EDI	                                        Only available on 80386
UD1	                0F B9	Intentionally undefined instruction, but unlike UD2 this was not published}

initialization
SetLength(Mem,(16*(256*256-1)+256*256));
SetLength(Disks,1);   
BIOS:=AG.STD.Files.AGRead('W:\HaTsKer\Res\BIOS-bochs-legacy'); 
Disks[0]:=AG.STD.Files.AGRead('W:\HaTsKer\Res\MSDos\disk1.IMA');
//CMOS:=TCMOS.Create;
AGRead('W:\HaTsKer\Res\CMOS.bin',Pointer(addr(CMOS.CMOSDATA[0])),$100);
finalization
AGWrite('W:\HaTsKer\Res\CMOS.bin',TAGData.Comp(Pointer(addr(CMOS.CMOSDATA[0])),$100));
//FreeAndNil(CMOS);      
end.
