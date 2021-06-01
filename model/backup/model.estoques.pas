unit model.estoques;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, model.conexao, classe.utils, jsons, clipbrd;

  Const _insert_sql = ' insert into estoques(id, localizacao, tipo_produto, '+
	              ' ultima_venda, ultima_apuracao, media_valor_unit, dias_estoque, '+
                      ' nivel_estoque_aliq, nivel_estoque, media_dia, sugerido_estoque_minimo,'+
                      ' sugerido_estoque_seguranca, sugerido_estoque_maximo, lead_time, '+
	              ' frequencia_compra, nivel_seguranca, visivel, dataatualizacao, '+
                      ' produto_id, preco_custo_id, empresa_id) values  '+
                      ' (:_id, :_localizacao, :_tipo_produto, '+
	              ' :_ultima_venda, :_ultima_apuracao, :_media_valor_unit, :_dias_estoque, '+
                      ' :_nivel_estoque_aliq, :_nivel_estoque, :_media_dia, :_sugerido_estoque_minimo,'+
                      ' :_sugerido_estoque_seguranca, :_sugerido_estoque_maximo, :_lead_time, '+
	              ' :_frequencia_compra, :_nivel_seguranca, :_visivel, :_dataatualizacao, '+
                      ' :_produto_id, :_preco_custo_id, :_empresa_id) ';


    _update_sql = '';



  function estoque_processa(_ArrayItens: TJSONArray ;_data : TConexao = nil) : boolean;

implementation

function estoque_processa(_ArrayItens: TJSONArray ;_data : TConexao = nil) : boolean;
begin
  _data.ChecaItensArrayToSQl('estoques',_ArrayItens);
  _data.InsertArrayToSQl('estoques',_ArrayItens);
  _data.updateSQlArray('estoques',_ArrayItens);

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
                 Sql.Add('select * from estoques where id = '+QuotedStr(_json.Find('id').AsString));
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
           ParamByName('_localizacao').AsString:= _json.Find('localizacao').AsString;
           ParamByName('_tipo_produto').AsString:= _json.Find('tipo_produto').AsString;
           ParamByName('_ultima_venda').AsString:= _json.Find('ultima_venda').AsString;
           ParamByName('_ultima_apuracao').AsString:= _json.Find('ultima_apuracao').AsString;
           ParamByName('_dataatualizacao').AsString:= _json.Find('dataatualizacao').AsString;

           //Boolean
           ParamByName('_visivel').AsString:= FlagBoolean(_json.Find('visivel').AsString);

           //Integer
           ParamByName('_id').AsInteger:= _json.Find('id').AsInteger;
           ParamByName('_produto_id').AsInteger:= _json.Find('produto_id').AsInteger;
           ParamByName('_dias_estoque').AsInteger:= _json.Find('dias_estoque').AsInteger;
           ParamByName('_nivel_estoque_aliq').AsInteger:= _json.Find('nivel_estoque_aliq').AsInteger;
           ParamByName('_nivel_estoque').AsInteger:= _json.Find('nivel_estoque').AsInteger;
           ParamByName('_nivel_seguranca').AsInteger:= _json.Find('nivel_seguranca').AsInteger;
           ParamByName('_lead_time').AsInteger:= _json.Find('lead_time').AsInteger;
           ParamByName('_preco_custo_id').AsInteger:= _json.Find('preco_custo_id').AsInteger;
           ParamByName('_empresa_id').AsInteger:= _json.Find('empresa_id').AsInteger;

           //Float
           ParamByName('_media_valor_unit').AsFloat := _json.Find('media_valor_unit').AsFloat;
           ParamByName('_media_dia').AsFloat := _json.Find('media_dia').AsFloat;
           ParamByName('_sugerido_estoque_minimo').AsFloat := _json.Find('sugerido_estoque_minimo').AsFloat;
           ParamByName('_sugerido_estoque_seguranca').AsFloat := _json.Find('sugerido_estoque_seguranca').AsFloat;
           ParamByName('_sugerido_estoque_maximo').AsFloat := _json.Find('sugerido_estoque_maximo').AsFloat;
           ParamByName('_frequencia_compra').AsFloat := _json.Find('frequencia_compra').AsFloat;

           if not _inserir then
              Sql.Add(' where id  = '+QuotedStr(_json.Find('id').AsString));

           ExecSQL;
      end;

      Result := true;
   finally
     FreeAndNil(_data);
   end;
        }
end;

end.

