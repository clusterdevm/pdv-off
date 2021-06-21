unit model.conta.corrente;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, model.conexao, classe.utils, jsons, clipbrd;

  Const _insert_sql = ' insert into conta_corrente(id, descricao, obs, '+
	              ' datacriacao, dataatualizacao, empresa_id, ativo,saldoinicial) values '+
                      ' (:_id, :_descricao, :_obs, '+
	              ' :_datacriacao, :_dataatualizacao, :_empresa_id, :_ativo, :_saldoinicial) ';

        _update_sql = '';



  function conta_corrente(_ArrayItens: TJSONArray ;_data : TConexao = nil) : boolean;

implementation

function conta_corrente(_ArrayItens: TJSONArray ;_data : TConexao = nil) : boolean;
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
                 Sql.Add('select * from conta_corrente where id = '+QuotedStr(_json.Find('id').AsString));
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

           //Real
           ParamByName('_saldoinicial').AsFloat:= _json.Find('saldoinicial').AsFloat;

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

