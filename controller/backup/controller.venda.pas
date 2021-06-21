unit controller.venda;

{$mode delphi}

interface

uses
  Classes, SysUtils, jsons;


implementation

uses model.conexao, classe.utils;

function GetCaixaABerto: boolean;
var _db : TConexao;
begin
  try
      _db := TConexao.Create;
      result := false;

      With _db.Query do
      Begin
         Close;
         Sql.Clear;
         Sql.Add('select *  financeiro_caixa ');
         Sql.Add(' where operador_id = '+QuotedStr(IntToStr(sessao.usuario_id)));
         Open;

         if not IsEmpty then
         Begin
             Sessao.caixa_id:= FieldByName('id').AsInteger;
             Result := true;
         end;

      end;
  finally
    FreeAndNil(_db);
  end;
end;

end.

