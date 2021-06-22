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
  private

  public
    var
       _avancar : Boolean;
      onlyColaborador : boolean;
       function getID : Integer;

       Function Localiza : boolean;
  end;

implementation

uses view.filtros.cliente, classe.utils, model.pessoa;

{$R *.lfm}

{ TframePessoaGet }


function TframePessoaGet.getID: Integer;
begin
 Result :=  StrToIntDef(EditID.text,0);
end;

function TframePessoaGet.Localiza : boolean;
var _pessoa : TPessoa;
begin
   result := false;

   if EditID.Text = '' then
   Begin
       frmFiltroCliente := TfrmFiltroCliente.Create(nil);

       Sessao.getID:='';
       frmFiltroCliente._FiltroID := true;
       frmFiltroCliente._OnlyCustomer:= self.onlyColaborador;
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

end.

