unit model.produtos;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, model.conexao, classe.utils, clipbrd, jsons ;

  Const _insert_sql = ' insert into produtos( id, descricao , obsfisco , obs, '+
                      ' gtin, origemmercadoria, referencia, permitido_venda, '+
                      ' tipo_produto, sabor, qtde_sabor, codigo_fabricante, '+
                      ' cest, grade, nutricional_id, fabricante_id, implantacao, '+
                      ' descricaoresumida, tipo, nomeanexo, tempoimplantacao, '+
                      ' anexo, menu, similar_id, pesoliquido, pesobruto, impressora_id,'+
                      ' dias_validade, dataimagem, ecommerce, empresa_estoque_inicial_id ,'+
                      ' saldo_inicial, subgrupo_id, marca_id, unidade_id, colecao_id,'+
                      ' ncm_id, altura, largura, profundidade, datacriacao, dataatualizacao,'+
                      ' matriz_id, ativo) values '+
                      ' ( :_id, :_descricao , :_obsfisco , :_obs, '+
                      ' :_gtin, :_origemmercadoria, :_referencia, :_permitido_venda, '+
                      ' :_tipo_produto, :_sabor, :_qtde_sabor, :_codigo_fabricante, '+
                      ' :_cest, :_grade, :_nutricional_id, :_fabricante_id, :_implantacao, '+
                      ' :_descricaoresumida, :_tipo, :_nomeanexo, :_tempoimplantacao, '+
                      ' :_anexo, :_menu, :_similar_id, :_pesoliquido, :_pesobruto, :_impressora_id,'+
                      ' :_dias_validade, :_dataimagem, :_ecommerce, :_empresa_estoque_inicial_id ,'+
                      ' :_saldo_inicial, :_subgrupo_id, :_marca_id, :_unidade_id, :_colecao_id,'+
                      ' :_ncm_id, :_altura, :_largura, :_profundidade, :_datacriacao, :_dataatualizacao,'+
                      ' :_matriz_id, :_ativo) ';

    _update_sql = '';



  function produtos_processa(_ArrayItens: TJSONArray ;_data : TConexao = nil) : boolean;

implementation

function produtos_processa(_ArrayItens: TJSONArray ;_data : TConexao = nil) : boolean;
begin
  _data.ChecaItensArrayToSQl('produtos',_ArrayItens);
  _data.InsertArrayToSQl('produtos',_ArrayItens);
  _data.updateSQlArray('produtos',_ArrayItens);

{   try
      result := false;

      _json := TJSONObject(GetJSON(value_json));

      _data := TConexao.Create;

      if not _firstUpload then
      Begin
            with _data.Query  do
            Begin
                 Close;
                 Sql.Clear;
                 Sql.Add('select * from produtos where id = '+QuotedStr(_json.Find('id').AsString));
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
           ParamByName('_obsfisco').AsString:= _json.Find('obsfisco').AsString;
           ParamByName('_obs').AsString:= _json.Find('obs').AsString;
           ParamByName('_gtin').AsString:= _json.Find('gtin').AsString;
           ParamByName('_origemmercadoria').AsString:= _json.Find('origemmercadoria').AsString;
           ParamByName('_referencia').AsString:= _json.Find('referencia').AsString;
           ParamByName('_tipo_produto').AsString:= _json.Find('tipo_produto').AsString;
           ParamByName('_codigo_fabricante').AsString:= _json.Find('codigo_fabricante').AsString;
           ParamByName('_cest').AsString:= _json.Find('cest').AsString;
           ParamByName('_descricaoresumida').AsString:= _json.Find('descricaoresumida').AsString;
           ParamByName('_tipo').AsString:= _json.Find('tipo').AsString;
           ParamByName('_tempoimplantacao').AsString:= _json.Find('tempoimplantacao').AsString;
           ParamByName('_nomeanexo').AsString:= _json.Find('nomeanexo').AsString;
           ParamByName('_anexo').AsString:= _json.Find('anexo').AsString;
           ParamByName('_menu').AsString:= _json.Find('menu').AsString;
           ParamByName('_dataimagem').AsString:= _json.Find('dataimagem').AsString;
           ParamByName('_pesoliquido').AsString:= _json.Find('pesoliquido').AsString;
           ParamByName('_ncm_id').AsString:= _json.Find('ncm_id').AsString;
           ParamByName('_datacriacao').AsString:= _json.Find('datacriacao').AsString;
           ParamByName('_dataatualizacao').AsString:= _json.Find('dataatualizacao').AsString;

           //Boolean
           ParamByName('_permitido_venda').AsString:= FlagBoolean(_json.Find('permitido_venda').AsString);
           ParamByName('_sabor').AsString:= FlagBoolean(_json.Find('sabor').AsString);
           ParamByName('_grade').AsString:= FlagBoolean(_json.Find('grade').AsString);
           ParamByName('_ecommerce').AsString:= FlagBoolean(_json.Find('ecommerce').AsString);
           ParamByName('_ativo').AsString:= FlagBoolean(_json.Find('ativo').AsString);

           //Integer
           ParamByName('_id').AsInteger := _json.Find('id').AsInteger;
           ParamByName('_similar_id').AsInteger := _json.Find('similar_id').AsInteger;
           ParamByName('_qtde_sabor').AsInteger := _json.Find('qtde_sabor').AsInteger;
           ParamByName('_nutricional_id').AsInteger := _json.Find('nutricional_id').AsInteger;
           ParamByName('_fabricante_id').AsInteger := _json.Find('fabricante_id').AsInteger;
           ParamByName('_implantacao').AsInteger := _json.Find('implantacao').AsInteger;
           ParamByName('_impressora_id').AsInteger := _json.Find('impressora_id').AsInteger;
           ParamByName('_dias_validade').AsInteger := _json.Find('dias_validade').AsInteger;
           ParamByName('_empresa_estoque_inicial_id').AsInteger := _json.Find('empresa_estoque_inicial_id').AsInteger;
           ParamByName('_subgrupo_id').AsInteger := _json.Find('subgrupo_id').AsInteger;
           ParamByName('_marca_id').AsInteger := _json.Find('marca_id').AsInteger;
           ParamByName('_unidade_id').AsInteger := _json.Find('unidade_id').AsInteger;
           ParamByName('_colecao_id').AsInteger := _json.Find('colecao_id').AsInteger;
           ParamByName('_matriz_id').AsInteger := _json.Find('matriz_id').AsInteger;


           //Float
           ParamByName('_pesoliquido').AsFloat := _json.Find('pesoliquido').AsFloat;
           ParamByName('_pesobruto').AsFloat := _json.Find('pesobruto').AsFloat;
           ParamByName('_saldo_inicial').AsFloat := _json.Find('saldo_inicial').AsFloat;
           ParamByName('_altura').AsFloat := _json.Find('altura').AsFloat;
           ParamByName('_largura').AsFloat := _json.Find('largura').AsFloat;
           ParamByName('_profundidade').AsFloat := _json.Find('profundidade').AsFloat;

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

