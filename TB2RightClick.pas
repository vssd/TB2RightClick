{
  TB2RightClick.pas

  Delphi unit to be able to be notified of right clicks on Toolbar2000
  items, e.g. to have popup menus for menu items.

  Version 1.0a - always find the most current version at
  http://flocke.vssd.de/prog/code/pascal/tb2rclk/

  Copyright (C) 2006 Volker Siebert <flocke@vssd.de>
  All rights reserved.

  Permission is hereby granted, free of charge, to any person obtaining a
  copy of this software and associated documentation files (the "Software"),
  to deal in the Software without restriction, including without limitation
  the rights to use, copy, modify, merge, publish, distribute, sublicense,
  and/or sell copies of the Software, and to permit persons to whom the
  Software is furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
  DEALINGS IN THE SOFTWARE.
}

unit TB2RightClick;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, TB2Item, TB2Toolbar;

{
  Usage:

  1. Add this unit to your project or store it anywhere in your search
     path and add it to the uses-list of your main form's unit:

  +----------------------------------------------------------------------
  | uses
  |   ...., TB2RightClick;
  +----------------------------------------------------------------------

  2. Add a message handler to your main form:

  +----------------------------------------------------------------------
  | type
  |   TForm1 = class(TForm)
  |   ...
  |   public
  >     procedure WMTB2RightClick(var Msg: TWMTB2RightClick);
  >       message WM_TB2RIGHTCLICK;
  |     ...
  |   end;
  +----------------------------------------------------------------------

  3. Implement your action in that handler

  +----------------------------------------------------------------------
  | procedure TForm1.WMTB2RightClick(var Msg: TWMTB2RightClick);
  | begin
  |   // Msg.Item is the right clicked item
  |   // Msg.XPos/Msg.YPos is the mouse position in screen coordinates
  |   PopupMenu1.Tag := integer(Msg.Item);
  |   PopupMenu1.Popup(Msg.XPos, Msg.YPos);
  | end;
  +----------------------------------------------------------------------
}

const
  WM_TB2RIGHTCLICK = WM_APP + 42;

type
  TWMTB2RightClick = packed record
    Msg: Cardinal;
    Item: TTBCustomItem;
    case Integer of
      0: (
        XPos: Smallint;
        YPos: Smallint);
      1: (
        Pos: TSmallPoint;
        Result: Longint);
  end;

var
  TB2RightClick_NotifyForm: TWinControl;
  TB2RightClick_HookHandle: THandle;
  TB2RightClick_Message:    integer;

implementation

{$B-,R-}

function HookRightButton(nCode: Integer; wp: WPARAM; lp: LPARAM): LRESULT;
  stdcall;
var
  Wnd: TWinControl;
  Frm: TWinControl;
  View: TTBView;
  Item: TTBItemViewer;
  Found: TTBCustomItem;
  Pnt: TPoint;
begin
  if nCode = HC_ACTION then
    with PMsg(lp)^ do
      if message = WM_RBUTTONDOWN then
      begin
        Wnd := FindControl(hWnd);
        if Wnd is TTBToolbar then
        begin
          Pnt.X := TSmallPoint(lParam).X;
          Pnt.Y := TSmallPoint(lParam).Y;
          ClientToScreen(hWnd, Pnt);

          Frm := TB2RightClick_NotifyForm;
          if Frm = nil then
          begin
            Frm := Wnd.Parent;
            while (Frm <> nil) and not (Frm is TCustomForm) do
              Frm := Frm.Parent;
            if Frm = nil then
              Frm := Application.MainForm;
          end;

          if Frm <> nil then
          begin
            View := TTBToolbar(Wnd).View;
            Found := nil;
            while View <> nil do
            begin
              Item := View.ViewerFromPoint(View.Window.ScreenToClient(Pnt));
              if Assigned(Item) then
                Found := Item.Item;

              if Assigned(View.OpenViewerView) and (View <> View.OpenViewerView) then
                View := View.OpenViewerView
              else if Assigned(View.Selected) and
                      Assigned(View.Selected.View) and (View <> View.Selected.View) then
                View := View.Selected.View
              else
                View := nil;
            end;

            if Found <> nil then
              PostMessage(Frm.Handle, TB2RightClick_Message, UINT(Found),
                MAKELPARAM(Pnt.X, Pnt.Y));
          end;
        end;
      end;

  Result := CallNextHookEx(TB2RightClick_HookHandle, nCode, wp, lp);
end;

initialization
  TB2RightClick_Message := WM_TB2RIGHTCLICK;
  TB2RightClick_HookHandle := SetWindowsHookEx(WH_GETMESSAGE, @HookRightButton,
    0, GetCurrentThreadId);
finalization
  UnhookWindowsHookEx(TB2RightClick_HookHandle);
end.
