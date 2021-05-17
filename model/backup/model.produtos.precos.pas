unit model.produtos.precos;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, model.conexao, classe.utils, jsons, clipbrd;

  Const _insert_sql = ' insert into produtos_preco(id, valor, comissao, '+
	              ' acima_de, valor_acima, markup, permitir_desconto, '+
                      ' estoque_id, tabela_id, dataatualizacao) values '+
                      ' (:_id, :_valor, :_comissao, '+
                      ' :_acima_de, :_valor_acima, :_markup, :_permitir_desconto, '+
                      ' :_estoque_id, :_tabela_id, :_dataatualizacao) ';

        _update_sql = '';



  function produtos_preco(_ArrayItens: TJSONArray ;_data : TConexao = nil) : boolean;

implementation

function produtos_preco(_ArrayItens: TJSONArray ;_data : TConexao = nil) : boolean;
begin
{   try
      result := false;
      _Inserir:= _firstUpload;

      _json := TJSONObject(GetJSON(value_json));

      _data := TConexao.Create;

      if not _firstUpload then
      Begin
            with _data.Query  do
            Begin
                 Close;
                 Sql.Clear;
                 Sql.Add('select * from produtos_preco where id = '+QuotedStr(_json.Find('id').AsString));
                 Open;

                 _Inserir:= IsEmpty;
            end;
      end;

      with _data.Query do
      Begin
           Close;
           Sql.Clear;

           if _Inserir then
              Sql.Add(_insert_sql)
           else
             Sql.Add(_update_sql);

           //TEXT
           ParamByName('_dataatualizacao').AsString:= _json.Find('dataatualizacao').AsString;

           //TEXT
           ParamByName('_permitir_desconto').AsString:= FlagBoolean(_json.Find('permitir_desconto').AsString);

           //Integer
           ParamByName('_id').AsInteger:= _json.Find('id').AsInteger;
           ParamByName('_estoque_id').AsInteger:= _json.Find('produto_empresa_id').AsInteger;
           ParamByName('_tabela_id').AsInteger:= _json.Find('tabela_id').AsInteger;

           //Float
           ParamByName('_valor').AsFloat:= _json.Find('valor').AsFloat;
           ParamByName('_comissao').AsFloat:= _json.Find('comissao').AsFloat;
           ParamByName('_acima_de').AsFloat:= _json.Find('acima_de').AsFloat;
           ParamByName('_valor_acima').AsFloat:= _json.Find('valor_acima').AsFloat;
           ParamByName('_markup').AsFloat:= _json.Find('markup').AsFloat;

           if not _inserir then
              Sql.Add(' where id  = '+QuotedStr(_json.Find('id').AsString));

           ExecSQL;
      end;

      Result := true;
   finally
     FreeAndNil(_data);
   end;  }
end;

end.

