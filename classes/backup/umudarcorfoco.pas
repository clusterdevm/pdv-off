unit UMudarCorFoco;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,Controls, Forms,   Graphics,ComCtrls,TypInfo;

type

{ TMudaCorFoco }

ta mais
implementation


{ TMudaCorFoco }

procedure TMudaCorFoco.execute(screen: TScreen; application: TApplication
  );
begin

end;

procedure TMudaCorFoco.MudarCorFoco(sender: TObject);
const
 {$J+}
 controle: TWinControl = nil;
 CorAnterior: TColor = clWindow;
 {$J-}
 CorComFoco = clBlue;
var
  i:integer;
begin
  try
      if fApplication.Terminated then
         exit;

      if controle <> nil then
         TMudaCorFoco(Controle).Color := CorAnterior;

    with FScreen.ActiveForm do
    begin
      if ActiveControl is TWinControl then
        begin
          CorAnterior := TMudaCorFoco(ActiveControl).Color;
          Controle := ActiveControl;
          TMudaCorFoco(Controle).Color := CorComFoco;
        end;
    end;

  except
  //
  end;
end;

end.

