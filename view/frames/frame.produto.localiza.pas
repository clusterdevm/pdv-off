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
    procedure EditIDKeyPress(Sender: TObject; var Key: char);
  private

  public
    var
       _avancar : Boolean;

       function getID : Integer;
  end;

implementation

uses classe.utils;

{$R *.lfm}

{ TframeProdutoGet }

procedure TframeProdutoGet.EditIDKeyPress(Sender: TObject; var Key: char);
begin

end;

function TframeProdutoGet.getID: Integer;
begin
  result := StrToIntDef(EditID.text,0);
end;

end.

