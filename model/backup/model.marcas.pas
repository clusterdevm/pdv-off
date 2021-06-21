unit model.marcas;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, model.conexao, classe.utils, clipbrd, jsons;

  Const _insert_sql = ' insert into marcas(id, descricao, obs, '+
	              ' datacriacao, dataatualizacao, matriz_id, ativo) values '+
                      ' (:_id, :_descricao, :_obs, '+
	              ' :_datacriacao, :_dataatualizacao, :_matriz_id, :_ativo) ';

        _update_sql = '';



procedure marcas(_ArrayItens: TJSONArray ;_data : TConexao = nil);

implementation

procedure marcas(_ArrayItens: TJSONArray ;_data : TConexao = nil);
begin
  _data.ChecaItensArrayToSQl('marcas',_ArrayItens);
  _data.InsertArrayToSQl('marcas',_ArrayItens);
  _data.updateSQlArray('marcas',_ArrayItens);

  {
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
  end;}
end;

end.

