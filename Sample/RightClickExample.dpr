{
  RightClickExample.dpr

  This file is part of the TB2RightClick.pas sample application.
  Info at http://flocke.vssd.de/prog/code/pascal/tb2rclk/

  Copyright (C) 2006 Volker Siebert <flocke@vssd.de>
  All rights reserved.
}

program RightClickExample;

uses
  Forms,
  TB2RightClick in '..\TB2RightClick.pas',
  main in 'main.pas' {frmMain};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
