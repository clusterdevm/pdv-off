unit model.series.fiscais;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, model.conexao, classe.utils,jsons, clipbrd, dialogs;

  Const _insert_sql = ' insert into serie_fiscal(id, serie, obs, '+
                      ' modelo_documento_id, pdv_id, documento, '+
	              ' datacriacao, dataatualizacao, empresa_id, ativo) values '+

                      ' (:_id, :_serie, :_obs, '+
                      ' :_modelo_documento_id, :_pdv_id, :_documento, '+
	              ' :_datacriacao, :_dataatualizacao, :_empresa_id,:_ativo) ';

        _update_sql = '';



  function series_fiscais(_ArrayItens: TJSONArray ;_data : TConexao = nil) : boolean;

implementation

function series_fiscais(_ArrayItens: TJSONArray ;_data : TConexao = nil) : boolean;
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
                 Sql.Add('select * from serie_fiscal where id = '+QuotedStr(_json.Find('id').AsString));
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

           //Boolean
           ParamByName('_ativo').AsString:= FlagBoolean(_json.Find('ativo').AsString);

           //Integer
           ParamByName('_id').AsInteger:= _json.Find('id').AsInteger;
           ParamByName('_empresa_id').AsInteger:= _json.Find('empresa_id').AsInteger;
           ParamByName('_serie').AsInteger:= _json.Find('serie').AsInteger;
           ParamByName('_modelo_documento_id').AsInteger:= _json.Find('modelo_documento_id').AsInteger;

           if _json.Find('pdv_id').IsNull then
              ParamByName('_pdv_id').AsInteger:= 0
           else
              ParamByName('_pdv_id').AsInteger:= StrToIntDef(_json.Find('pdv_id').AsString,0);

           ParamByName('_documento').AsInteger:= _json.Find('documento').AsInteger;

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

