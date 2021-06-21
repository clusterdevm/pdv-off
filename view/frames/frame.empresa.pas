unit frame.empresa;

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, CheckLst, ComboEx;

type

  { TFrame1 }

  TFrame1 = class(TFrame)
    cb_empresa: TComboBox;
    Label1: TLabel;
  private

  public
       function GetArray : String;
       function GetItem : String;
       Procedure carregaEmpresa;
  end;

implementation

{$R *.lfm}

{ TFrame1 }

function TFrame1.GetArray: String;
begin
     result := IntTostr(StrToInt(copy(cb_empresa.Text,1,6)));
end;

function TFrame1.GetItem: String;
begin
     result := IntTostr(StrToInt(copy(cb_empresa.Text,1,6)));
end;

procedure TFrame1.carregaEmpresa;
begin
  cb_empresa.Items.Clear;
  cb_empresa.Items.Add('000006 Empresa X');
  cb_empresa.ItemIndex:= 0;
end;

end.

