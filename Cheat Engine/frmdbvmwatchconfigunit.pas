unit frmDBVMWatchConfigUnit;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls;

type

  { TfrmDBVMWatchConfig }

  TfrmDBVMWatchConfig = class(TForm)
    btnOK: TButton;
    Button2: TButton;
    cbLockPage: TCheckBox;
    cbMultipleRIP: TCheckBox;
    cbWholePage: TCheckBox;
    cbSaveFPU: TCheckBox;
    cbSaveStack: TCheckBox;
    edtMaxEntries: TEdit;
    GroupBox1: TGroupBox;
    lblPhysicalAddress: TLabel;
    lblVirtualAddress: TLabel;
    Label3: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    rbWriteAccess: TRadioButton;
    rbReadAccess: TRadioButton;
    procedure btnOKClick(Sender: TObject);
  private
    { private declarations }
    fAddress: qword;
    fPhysicalAddress: qword;
    procedure setAddress(a: qword);
    function getWatchType: integer;
    procedure setWatchType(t:integer);
    function getOptions: DWORD;
    procedure setOptions(o: DWORD);
    function getLockPage: boolean;
    procedure setLockPage(o: boolean);
    function getMaxEntries: integer;
    procedure setMaxEntries(m:integer);
  public
    property Address: qword read fAddress write setAddress;
    property PhysicalAddress: qword read fPhysicalAddress;
    property Watchtype: integer read getWatchType write setWatchType;
    property Options: DWORD read getOptions write setOptions;
    property LockPage: boolean read getLockPage write setLockPage;
    property MaxEntries: integer read getMaxEntries write setMaxEntries;
    { public declarations }
  end;

var
  frmDBVMWatchConfig: TfrmDBVMWatchConfig;

implementation

{$R *.lfm}

uses math,NewKernelHandler, ProcessHandlerUnit, vmxfunctions;

function TfrmDBVMWatchConfig.getMaxEntries: integer;
begin
  result:=StrToInt(edtMaxEntries.text);
end;

procedure TfrmDBVMWatchConfig.setMaxEntries(m:integer);
begin
  edtMaxEntries.text:=inttostr(m);
end;

function TfrmDBVMWatchConfig.getLockPage: boolean;
begin
  result:=cbLockPage.checked;
end;

procedure TfrmDBVMWatchConfig.setLockPage(o: boolean);
begin
  cblockpage.checked:=o;
end;

function TfrmDBVMWatchConfig.getOptions: DWORD;
begin
  result:=0;
  if cbSaveFPU.checked then result:=result or EPTO_SAVE_FXSAVE;
  if cbSaveStack.checked then result:=result or EPTO_SAVE_STACK;
  if cbMultipleRIP.checked then result:=result or EPTO_MULTIPLERIP;
  if cbWholePage.checked then result:=result or EPTO_LOG_ALL;
end;

procedure TfrmDBVMWatchConfig.setOptions(o: DWORD);
begin
  cbSaveFPU.checked:=(o and EPTO_SAVE_FXSAVE)>0;
  cbSaveStack.checked:=(o and EPTO_SAVE_STACK)>0;
  cbMultipleRIP.checked:=(o and EPTO_MULTIPLERIP)>0;
  cbWholePage.checked:=(o and EPTO_LOG_ALL)>0;
end;

function TfrmDBVMWatchConfig.getWatchType: integer;
begin
  if rbReadAccess.checked then result:=1 else result:=0;
end;

procedure TfrmDBVMWatchConfig.setWatchType(t:integer);
begin
  if t=0 then
    rbWriteAccess.checked:=true
  else
    rbReadAccess.checked:=true;
end;

procedure TfrmDBVMWatchConfig.btnOKClick(Sender: TObject);
var i: integer;
begin
  if TryStrToInt(edtMaxEntries.text,i) then
    modalresult:=mrok
  else
  begin
    beep;
    edtMaxEntries.SetFocus;
    edtMaxEntries.SelectAll;
  end;

end;

procedure TfrmDBVMWatchConfig.setAddress(a: qword);
var
  x: ptruint;
  temp: byte;
begin
  faddress:=a;
  lblVirtualAddress.caption:=format('Virtual Address=%.8x',[a]);

  if ReadProcessMemory(processhandle, pointer(a),@temp,1,x) then
  begin
    if GetPhysicalAddress(processhandle, pointer(a), fPhysicalAddress) then
    begin
      lblPhysicalAddress.caption:=format('Physical Address=%.8x',[fPhysicalAddress]);
      btnOK.Enabled:=true;
    end;
  end;

  if btnok.enabled=false then
  begin
    lblPhysicalAddress.caption:='Physical Address=invalid';
    lblPhysicalAddress.font.color:=clRed;
  end;
end;

end.

