{
  main.pas

  This file is part of the TB2RightClick.pas sample application.
  Info at http://flocke.vssd.de/prog/code/pascal/tb2merge/

  Copyright (C) 2006 Volker Siebert <flocke@vssd.de>
  All rights reserved.
}

unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ComCtrls, ExtCtrls, ImgList, TB2Item, TB2Dock, TB2Toolbar, TB2RightClick;

type
  TfrmMain = class(TForm)
    TBDock1: TTBDock;
    TBDock2: TTBDock;
    tbMainMenuBar: TTBToolbar;
    TBImageList1: TTBImageList;
    StatusBar1: TStatusBar;
    Timer1: TTimer;
    PopupMenu1: TPopupMenu;
    Insertbefore1: TMenuItem;
    Insertafter1: TMenuItem;
    Deleteitem1: TMenuItem;
    N1: TMenuItem;
    Enabled1: TMenuItem;
    Normalpopupmenu1: TMenuItem;
    procedure Enabled1Click(Sender: TObject);
    procedure Deleteitem1Click(Sender: TObject);
    procedure Insertafter1Click(Sender: TObject);
    procedure Insertbefore1Click(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TBItemClick(Sender: TObject);
  private
    { Private-Deklarationen }
    function NewMenuItem(kmi: integer): TTBItem;
    function NewSubmenuItem(ksmi: integer): TTBSubmenuItem;
  public
    { Public-Deklarationen }
    FItem: TTBCustomItem;
    procedure WMTB2RightClick(var Msg: TWMTB2RightClick);
      message WM_TB2RIGHTCLICK;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

const
  Msg = 'Use the right mouse button with the menus and menu items';

var
  Counter: Integer = 0;

const
  SChars: array [1 .. 10] of string = (
    'Alpha', 'Beta', 'Gamma', 'Delta', 'Epsilon',
    'Zeta', 'Eta', 'Theta', 'Jota', 'Kappa'
  );
  SNumbers: array [1 .. 10] of string = (
    'One', 'Two', 'Three', 'Four', 'Five',
    'Six', 'Seven', 'Eight', 'Nine', 'Ten'
  );

procedure TfrmMain.Deleteitem1Click(Sender: TObject);
begin
  if FItem = nil then
    exit;

  FItem.Parent.Remove(FItem);
  FItem := nil;
end;

procedure TfrmMain.Enabled1Click(Sender: TObject);
begin
  if FItem = nil then
    exit;

  FItem.Enabled := not FItem.Enabled;
  FItem := nil;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  ksmi: integer;
begin
  FItem := nil;
  Randomize;

  for ksmi := 1 to 10 do
    if Random(5) > 0 then
      tbMainMenuBar.Items.Add(NewSubmenuItem(ksmi));
end;

procedure TfrmMain.Insertafter1Click(Sender: TObject);
var
  idx: Integer;
begin
  if FItem = nil then
    exit;

  idx := FItem.Parent.IndexOf(FItem) + 1;
  if FItem.Parent.Tag = 0 then
    FItem.Parent.Insert(idx, NewSubmenuItem(FItem.Tag + 1))
  else
    FItem.Parent.Insert(idx, NewMenuItem(FItem.Tag + 1));
  FItem := nil;
end;

procedure TfrmMain.Insertbefore1Click(Sender: TObject);
var
  idx: Integer;
begin
  if FItem = nil then
    exit;

  idx := FItem.Parent.IndexOf(FItem);
  if FItem.Parent.Tag = 0 then
    FItem.Parent.Insert(idx, NewSubmenuItem(FItem.Tag - 1))
  else
    FItem.Parent.Insert(idx, NewMenuItem(FItem.Tag - 1));
  FItem := nil;
end;

function TfrmMain.NewMenuItem(kmi: integer): TTBItem;
begin
  Result := TTBItem.Create(Self);
  Result.Caption := SNumbers[kmi];
  Result.ImageIndex := kmi - 1 + 10;
  Result.Tag := kmi;
  Result.OnClick := TBItemClick;
end;

function TfrmMain.NewSubmenuItem(ksmi: integer): TTBSubmenuItem;
var
  kmi: integer;
begin
  Result := TTBSubmenuItem.Create(Self);
  Result.Caption := SChars[ksmi];
  Result.ImageIndex := ksmi - 1;
  Result.DisplayMode := nbdmImageAndText;
  Result.Tag := ksmi;

  for kmi := 1 to 10 do
    if Random(5) > 0 then
      Result.Add(NewMenuItem(kmi));
end;

procedure TfrmMain.PopupMenu1Popup(Sender: TObject);
var
  Prnt: TTBCustomItem;
  idx, cnt: integer;
begin
  Timer1.Enabled := false;
  StatusBar1.Panels[0].Text := Msg;

  if FItem = nil then
  begin
    Insertbefore1.Enabled := false;
    Insertafter1.Enabled := false;
    Deleteitem1.Enabled := false;
    Enabled1.Enabled := false;
  end
  else
  begin
    Prnt := FItem.Parent;
    idx := Prnt.IndexOf(FItem);
    cnt := Prnt.Count;

    Insertbefore1.Enabled :=
      ((idx = 0) and (FItem.Tag > 1)) or
      ((idx > 0) and (FItem.Tag > Prnt.Items[idx - 1].Tag + 1));
    Insertafter1.Enabled :=
      ((idx = cnt - 1) and (FItem.Tag < 10)) or
      ((idx < cnt - 1) and (FItem.Tag < Prnt.Items[idx + 1].Tag - 1));
    Deleteitem1.Enabled := cnt > 1;
    Enabled1.Checked := FItem.Enabled;
  end;
end;

procedure TfrmMain.TBItemClick(Sender: TObject);
begin
  if Sender is TTBItem then
    MessageDlg(Caption + ': ' +
      StripHotkey(TTBItem(Sender).Parent.Caption) + ' ' +
      StripHotkey(TTBItem(Sender).Caption), mtInformation, [mbOk], 0);
end;

procedure TfrmMain.Timer1Timer(Sender: TObject);
begin
  if StatusBar1.Panels[0].Text = '' then
    StatusBar1.Panels[0].Text := Msg
  else
    StatusBar1.Panels[0].Text := '';
end;

procedure TfrmMain.WMTB2RightClick(var Msg: TWMTB2RightClick);
begin
  // Msg.Item is the right clicked item
  // Msg.XPos/Msg.YPos is the mouse position in screen coordinates
  FItem := Msg.Item;
  PopupMenu1.Popup(Msg.XPos, Msg.YPos);
end;

end.
