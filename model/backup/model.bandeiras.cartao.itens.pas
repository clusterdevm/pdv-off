unit model.bandeiras.cartao.itens;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, model.conexao, classe.utils, jsons, clipbrd;

  Const _insert_sql = ' insert into bandeira_cartao_itens(id, parcela, adm, '+
                      ' antec,datacriacao,dataatualizacao, ativo , bandeira_cartao_id) '+
                      ' values '+
                      ' ( :_id, :_parcela, :_adm, '+
                      ' :_antec, :_datacriacao, :_dataatualizacao, :_ativo , :_bandeira_cartao_id )';

        _update_sql = '';




  function bandeira_cartao_itens(_ArrayItens: TJSONArray ;_data : TConexao = nil) : boolean;

implementation

function bandeira_cartao_itens(_ArrayItens: TJSONArray ;_data : TConexao = nil) : boolean;
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
                 Sql.Add('select * from bandeira_cartao_itens where id = '+QuotedStr(_json.Find('id').AsString));
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
           ParamByName('_datacriacao').AsString:= _json.Find('datacriacao').AsString;
           ParamByName('_dataatualizacao').AsString:= _json.Find('dataatualizacao').AsString;

           //Boolean
           ParamByName('_ativo').AsString:= FlagBoolean(_json.Find('ativo').AsString);

           //Real
           ParamByName('_adm').AsFloat:= _json.Find('adm').AsFloat;
           ParamByName('_antec').AsFloat:= _json.Find('antec').AsFloat;

           //Integer
           ParamByName('_id').AsInteger:= _json.Find('id').AsInteger;
           ParamByName('_parcela').AsInteger:= _json.Find('parcela').AsInteger;
           ParamByName('_bandeira_cartao_id').AsInteger:= _json.Find('bandeira_cartao_id').AsInteger;


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

