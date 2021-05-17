unit model.boletos.configuracoes;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, model.conexao, classe.utils, jsons, clipbrd;

  Const _insert_sql = ' insert into boletos_configuracao(id, empresa_id, banco_id, '+
                      ' agencia, conta_corrente, nome_correntista, taxa, carteira, '+
                      ' digito_cc, digito_agencia, codigo_cedente, ativo, obs, modalidade, '+
                      ' layout, protesto, datacriacao, dataatualizacao) values '+

                      ' (:_id, :_empresa_id, :_banco_id, '+
                      ' :_agencia, :_conta_corrente, :_nome_correntista, :_taxa, :_carteira, '+
                      ' :_digito_cc, :_digito_agencia, :_codigo_cedente, :_ativo, :_obs, :_modalidade, '+
                      ' :_layout, :_protesto, :_datacriacao, :_dataatualizacao) ';

        _update_sql = '';



  function boleto_config(_ArrayItens: TJSONArray ;_data : TConexao = nil) : boolean;

implementation

function boleto_config(_ArrayItens: TJSONArray ;_data : TConexao = nil) : boolean;
begin
{
   try
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
                 Sql.Add('select * from boletos_configuracao where id = '+QuotedStr(_json.Find('id').AsString));
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
           ParamByName('_obs').AsString:= _json.Find('obs').AsString;
           ParamByName('_datacriacao').AsString:= _json.Find('datacriacao').AsString;
           ParamByName('_dataatualizacao').AsString:= _json.Find('dataatualizacao').AsString;
           ParamByName('_agencia').AsString:= _json.Find('agencia').AsString;
           ParamByName('_conta_corrente').AsString:= _json.Find('conta_corrente').AsString;
           ParamByName('_nome_correntista').AsString:= _json.Find('nome_correntista').AsString;
           ParamByName('_taxa').AsString:= _json.Find('taxa').AsString;
           ParamByName('_carteira').AsString:= _json.Find('carteira').AsString;
           ParamByName('_digito_cc').AsString:= _json.Find('digito_cc').AsString;
           ParamByName('_digito_agencia').AsString:= _json.Find('digito_agencia').AsString;
           ParamByName('_codigo_cedente').AsString:= _json.Find('codigo_cedente').AsString;
           ParamByName('_modalidade').AsString:= _json.Find('modalidade').AsString;
           ParamByName('_layout').AsString:= _json.Find('layout').AsString;
           //Boolean
           ParamByName('_ativo').AsString:= FlagBoolean(_json.Find('ativo').AsString);

           //Integer
           ParamByName('_id').AsInteger:= _json.Find('id').AsInteger;
           ParamByName('_empresa_id').AsInteger:= _json.Find('empresa_id').AsInteger;
           ParamByName('_banco_id').AsInteger:= _json.Find('banco_id').AsInteger;
           ParamByName('_protesto').AsInteger:= _json.Find('protesto').AsInteger;

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

