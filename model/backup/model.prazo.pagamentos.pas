unit model.prazo.pagamentos;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, model.conexao, classe.utils, jsons, clipbrd;

  Const _insert_sql = ' INSERT INTO prazo_pagamento(                      '+
	              ' id, matriz_id, descricao, obs, qtde_parcela,      '+
                      ' primeiro_vencimento, venciveis_de, ativo,         '+
                      ' aliq_desconto, aliq_acrescimo, datacriacao,       '+
                      ' dataatualizacao, tipo_forma) values               '+

                      ' (:_id, :_matriz_id, :_descricao, :_obs, :_qtde_parcela, '+
                      ' :_primeiro_vencimento, :_venciveis_de, :_ativo,         '+
                      ' :_aliq_desconto, :_aliq_acrescimo, :_datacriacao,       '+
                      ' :_dataatualizacao, :_tipo_forma) ';

        _update_sql = '';



  function prazo_pagamento(_ArrayItens: TJSONArray ;_data : TConexao = nil) : boolean;

implementation

function prazo_pagamento(_ArrayItens: TJSONArray ;_data : TConexao = nil) : boolean;
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
                 Sql.Add('select * from prazo_pagamento where id = '+QuotedStr(_json.Find('id').AsString));
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
           ParamByName('_descricao').AsString:= _json.Find('descricao').AsString;
           ParamByName('_obs').AsString:= _json.Find('obs').AsString;
           ParamByName('_ativo').AsString:= FlagBoolean(_json.Find('ativo').AsString);
           ParamByName('_dataatualizacao').AsString:= _json.Find('dataatualizacao').AsString;
           ParamByName('_datacriacao').AsString:= _json.Find('datacriacao').AsString;
           ParamByName('_tipo_forma').AsString:= _json.Find('tipo_forma').AsString;

           //Integer
           ParamByName('_id').AsInteger:= _json.Find('id').AsInteger;
           ParamByName('_matriz_id').AsInteger:= _json.Find('matriz_id').AsInteger;
           ParamByName('_qtde_parcela').AsInteger:= _json.Find('qtde_parcela').AsInteger;
           ParamByName('_primeiro_vencimento').AsInteger:= _json.Find('primeiro_vencimento').AsInteger;
           ParamByName('_venciveis_de').AsInteger:= _json.Find('venciveis_de').AsInteger;

           //Float
           ParamByName('_aliq_desconto').AsFloat:= _json.Find('aliq_desconto').AsFloat;
           ParamByName('_aliq_acrescimo').AsFloat:= _json.Find('aliq_acrescimo').AsFloat;

           if not _inserir then
              Sql.Add(' where id  = '+QuotedStr(_json.Find('id').AsString));

           ExecSQL;
      end;

      Result := true;
   finally
     FreeAndNil(_data);
   end;    }
end;

end.

