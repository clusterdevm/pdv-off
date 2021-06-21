unit model.usuarios;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, model.conexao, classe.utils, jsons, clipbrd;

  Const _insert_sql = ' insert into usuarios(id, senha, usuario, observacao'+
	              ' datacriacao, dataatualizacao,arquivo_id ) values '+
                      ' (:_id, :_senha, :_usuario, :_observacao'+
	              ' :_datacriacao, :_dataatualizacao, :_arquivo_id ) ';

        _update_sql = '';



  function usuarios(_ArrayItens: TJSONArray ;_data : TConexao = nil) : boolean;

implementation

function usuarios(_ArrayItens: TJSONArray ;_data : TConexao = nil) : boolean;
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
                 Sql.Add('select * from usuarios where id = '+QuotedStr(_json.Find('id').AsString));
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
           ParamByName('_senha').AsString:= _json.Find('senha').AsString;
           ParamByName('_usuario').AsString:= _json.Find('usuario').AsString;
           ParamByName('_observacao').AsString:= _json.Find('observacao').AsString;
           ParamByName('_datacriacao').AsString:= _json.Find('datacriacao').AsString;
           ParamByName('_dataatualizacao').AsString:= _json.Find('dataatualizacao').AsString;

           //Integer
           ParamByName('_id').AsInteger:= _json.Find('id').AsInteger;
           ParamByName('_arquivo_id').AsInteger:= _json.Find('arquivo_id').AsInteger;

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

