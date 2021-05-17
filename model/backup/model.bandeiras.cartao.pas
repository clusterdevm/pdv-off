unit model.bandeiras.cartao;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, model.conexao, classe.utils, jsons, clipbrd;

  Const _insert_sql = ' insert into bandeira_cartao(id, descricao, obs, '+
                      ' adquirente_id, conta_corrente_id, prazo_debito, prazo_credito, '+
	              ' datacriacao, dataatualizacao, empresa_id, ativo) values '+
                      ' (:_id, :_descricao, :_obs, '+
                      ' :_adquirente_id, :_conta_corrente_id, :_prazo_debito, :_prazo_credito, '+
	              ' :_datacriacao, :_dataatualizacao, :_empresa_id, :_ativo)';

        _update_sql = '';



  function bandeira_cartao(_ArrayItens: TJSONArray ;_data : TConexao = nil) : boolean;

implementation

function bandeira_cartao(_ArrayItens: TJSONArray ;_data : TConexao = nil) : boolean;
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
                 Sql.Add('select * from bandeira_cartao where id = '+QuotedStr(_json.Find('id').AsString));
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
           ParamByName('_datacriacao').AsString:= _json.Find('datacriacao').AsString;
           ParamByName('_dataatualizacao').AsString:= _json.Find('dataatualizacao').AsString;

           //Boolean
           ParamByName('_ativo').AsString:= FlagBoolean(_json.Find('ativo').AsString);

           //Integer
           ParamByName('_id').AsInteger:= _json.Find('id').AsInteger;
           ParamByName('_empresa_id').AsInteger:= _json.Find('empresa_id').AsInteger;
           ParamByName('_adquirente_id').AsInteger:= _json.Find('adquirente_id').AsInteger;
           ParamByName('_conta_corrente_id').AsInteger:= _json.Find('conta_corrente_id').AsInteger;
           ParamByName('_prazo_debito').AsInteger:= _json.Find('prazo_debito').AsInteger;
           ParamByName('_prazo_credito').AsInteger:= _json.Find('prazo_credito').AsInteger;

           if not _inserir then
              Sql.Add(' where id  = '+QuotedStr(_json.Find('id').AsString));

           ExecSQL;
      end;

      Result := true;
   finally
     FreeAndNil(_data);
   end;   }
end;

end.

