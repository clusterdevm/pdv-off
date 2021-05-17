unit frame.cliente.localiza;

{$mode delphi}

interface


uses
  Classes, SysUtils, Forms, Controls, ExtCtrls, StdCtrls, Dialogs;


type

  { TframePessoaGet }

  TframePessoaGet = class(TFrame)
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

uses view.filtros.cliente, classe.utils, model.pessoa;

{$R *.lfm}

{ TframePessoaGet }

procedure TframePessoaGet.EditIDKeyPress(Sender: TObject; var Key: char);
var _pessoa : TPessoa;
begin
  if key = #13 then
  Begin
      key := #0;
      _avancar:= false;
      if EditID.Text = '' then
      Begin
          frmFiltroCliente := TfrmFiltroCliente.Create(nil);

          Sessao.getID:='';
          frmFiltroCliente._FiltroID := true;
          frmFiltroCliente.ShowModal;

          if Sessao.getID <> '' then
             Self.EditID.Text := Sessao.getID;
      end;

      if EditID.Text <> '' then
      Begin
          try
            _pessoa := TPessoa.Create;
            if _pessoa.get(self.EditID.text) then
            Begin
                edt_name.Text:= _pessoa.razao;
                _avancar:=true;
            end
            else
            Begin
                edt_name.text := '';
                EditID.SelectAll;
            end;

          finally
              FreeAndNil(_pessoa);
          end;
      end;
  end;
end;

function TframePessoaGet.getID: Integer;
begin
//  showmessage(EditID.text);
  StrToIntDef(EditID.text,0);
end;

end.

