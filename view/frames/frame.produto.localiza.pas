unit frame.produto.localiza;

{$mode delphi}

interface


uses
  Classes, SysUtils, Forms, Controls, ExtCtrls, StdCtrls, Dialogs;


type

  { TframeProdutoGet }

  TframeProdutoGet = class(TFrame)
    EditID: TEdit;
    edt_name: TEdit;
    Label1: TLabel;
    Panel1: TPanel;
  private

  public
    var
       _avancar : Boolean;

       function getID : Integer;
  end;

implementation

uses ems.utils;

{$R *.lfm}

{ TframeProdutoGet }

function TframeProdutoGet.getID: Integer;
begin
  result := StrToIntDef(EditID.text,0);
end;

end.

