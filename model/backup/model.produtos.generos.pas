unit model.produtos.generos;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, model.conexao, classe.utils, jsons, clipbrd;

  Const _insert_sql = ' insert into produtos_genero(id, descricao, obs, '+
	              ' datacriacao, dataatualizacao, matriz_id, ativo) values '+
                      ' (:_id, :_descricao, :_obs, '+
	              ' :_datacriacao, :_dataatualizacao, :_matriz_id, :_ativo) ';

        _update_sql = '';



  function produtos_genero(_ArrayItens: TJSONArray ;_data : TConexao = nil) : boolean;

implementation

function produtos_genero(_ArrayItens: TJSONArray ;_data : TConexao = nil) : boolean;
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
                 Sql.Add('select * from produtos_genero where id = '+QuotedStr(_json.Find('id').AsString));
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
           ParamByName('_matriz_id').AsInteger:= _json.Find('matriz_id').AsInteger;

           if not _inserir then
              Sql.Add(' where id  = '+QuotedStr(_json.Find('id').AsString));

           ExecSQL;
      end;

      Result := true;
   finally
     FreeAndNil(_data);
   end; }
end;

end.

