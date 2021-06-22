unit model.conexao;

interface

uses SysUtils, Variants, Classes, ZConnection, ZDataset,
     jsons, db, BufDataset, typinfo, dialogs,ZSqlProcessor  ;

Type

  { TConexao }

  TConexao = Class
      Private
          Conector : TZConnection;
          FQuery   : TZQuery;
          _estruturaDB: TJsonArray;

          Procedure GetEstrutura(_tabela:string);
          function campoValido(value:string):Boolean;
          Procedure InsertObjectToSQl(_tabela:String;_Json:TJsonObject; _returnID:Boolean = false );
      Public

         Property Query : TZQuery      Read FQuery      Write FQuery;

         function Execute: Boolean;
         Function Abrir : Boolean;
         Function Getsql: String;

         Function getStr(value:String):String;

         function ToArrayString:TJsonArray;

         Function DataSetToArrayString(ADataset:TBufDataset; _nomeObjeto:String = ''): String;
         function ToObjectString(_nomeObjeto:String ;_first : Boolean = false):TJsonObject;

         procedure updateSQl(_tabela:String;_Json, _jsonOlD:TJsonObject);
         procedure updateSQlArray(_tabela:String;_JsonArray:TJsonArray; _forceUpdate : Boolean = false);
         Procedure ProcessaSinc(_name : String ; _jArray  : TJsonArray);


         Procedure ChecaItensArrayToSQl(_tabela:String;_JsonArray:TJsonArray);
         Procedure InserirDados(_tabela:String;_Json:TJsonObject; _returnID:Boolean = false );
         Procedure InsertArrayToSQl(_tabela:String;_jsonArray:TJsonArray;
                                    _foreignKey : String = ''
                                    ; _foreingValue:integer = 0);

         Constructor Create;
         Destructor Destroy;override;

  end;

implementation

uses classe.utils;


function DataSetToJsonArray(pDataSet: TDataSet): TjsonArray;
  var
    _Array:TJson;
    _Itens : TJsonObject;
    I: Integer;
    pField:TField;
begin

  if pDataSet.IsEmpty then
  Begin
     Result := TJsonArray.Create();
     Result.Parse('[]');
     exit;
  end;


  try
        _Array:=TJson.Create;
        pDataSet.First;
        while not pDataSet.Eof do
        begin
            _Itens := TJsonObject.Create;

            for pField in pDataSet.Fields do
                case pField.DataType of
                  ftString: _Itens.Put(pField.FieldName,pField.AsString);
                 ftInteger: _Itens.Put(pField.FieldName,pField.AsInteger);
                 ftBoolean: _Itens.put(pField.FieldName,pField.AsBoolean);
                ftCurrency: _Itens.put(pField.FieldName,pField.AsCurrency);
                   ftFloat: _Itens.put(pField.FieldName,pField.AsFloat);
                 else //casos gerais são tratados como string
                    _Itens.put(pField.FieldName,pField.AsString);
                end;
            _Array.Put(_Itens);
            pDataSet.next;
        end;
        Result := TJsonArray.Create();
       result.Parse(_Array.Stringify)
    finally
       _Array.Free;
    end;
end;



function TConexao.Abrir: Boolean;
begin
    Result := False;
    Query.Open();
    Result := True;
end;


constructor TConexao.Create;
begin
  try
     Conector               := TZConnection.Create(nil);
     Conector.loginprompt   := false;
     Conector.Database      := './tabela/ems.db';
     Conector.HostName      := '';
     Conector.Password      := '';
     Conector.User          := '';
     Conector.Protocol      := 'sqlite-3';
     Conector.ClientCodepage:='UTF-8';
     Conector.LibraryLocation:='';

     FQuery := TZQuery.Create(nil);
     FQuery.Connection := Conector;

  except
     on e:Exception do
     Begin
         Showmessage(e.message);
     end;
  end;
end;

destructor TConexao.Destroy;
begin
    FQuery.Close;
    Conector.Connected := false;
    FreeAndNil(FQuery);
    FreeAndNil(Conector);
    inherited;
end;


procedure TConexao.GetEstrutura( _tabela: string);
var _dbEstrutura: TZQuery;
begin
  _dbEstrutura := TZQuery.Create(nil);
  _dbEstrutura.Connection := Conector;
    with _dbEstrutura do
    Begin
        //CLose;
        //Sql.Clear;
        //Sql.Add('SELECT column_name FROM INFORMATION_SCHEMA.COLUMNS ');
        //Sql.Add(' WHERE table_name = '+QuotedStr(_tabela));

        Close;
        Sql.Clear;
        Sql.Add('SELECT');
        Sql.Add('  p.name as column_name');
        Sql.Add('FROM');
        Sql.Add('  sqlite_master AS m');
        Sql.Add('JOIN');
        Sql.Add('  pragma_table_info(m.name) AS p');
        Sql.Add('  where m.name = '+QuotedStr(_tabela));
        open;

        if IsEmpty then
           raise Exception.Create('Tabela Invalida '+_tabela);

        _estruturaDB := DataSetToJsonArray(_dbEstrutura);
    end;
   _dbEstrutura.Free;
end;

function TConexao.campoValido(value: string): Boolean;
var i : Integer;
    _item : TJsonObject;
begin
  result := false;
  for i := 0 to _estruturaDB.Count-1 do
  Begin
       _item := _estruturaDB.Items[i].AsObject;
       if trim(LowerCase(_item['column_name'].AsString)) = trim(LowerCase(value)) then
       Begin
           Result := true;
           Break;
       end;
  end;
end;

function TConexao.Execute: Boolean;
begin
    Result := False;
    Query.ExecSQL;
    Result := true;
    Query.Active:=false;
end;

function TConexao.Getsql: String;
var  i: Integer;
  r: string;
begin
  Result := LowerCase(Query.SQL.Text);
  for i := 0 to Query.Params.Count - 1 do
  begin
      r:= QuotedStr(Query.Params[i].AsString);

      Result := StringReplace(Result, ':' + lowercase(Query.Params.Items[i].Name), r, [rfReplaceAll]);
  end;
end;

function TConexao.getStr(value: String): String;
begin
     Result := trim(Query.FieldByName(value).AsString);
end;

function TConexao.ToArrayString : TJsonArray;
begin
     Result :=  DataSetToJsonArray(Query);
end;

function TConexao.DataSetToArrayString(ADataset: TBufDataset;
  _nomeObjeto: String): String;
var _Return : TJson;
begin
  _Return := TJson.Create;

  if ADataset.IsEmpty then
  Begin
     if _nomeObjeto = '' then
        Result := '[]'
     else
     Begin
         _Return[_nomeObjeto].AsArray;
         Result := _return.Stringify;
     end;
  end
  else
  Begin
      if _nomeObjeto = '' then
         Result := DataSetToJsonArray(ADataset).Stringify
      else
      Begin
          with _Return[_nomeObjeto].AsArray do
               put(DataSetToJsonArray(ADataset));

          Result := _Return.Stringify;

      end;
  end;

end;

function TConexao.ToObjectString(_nomeObjeto:String ;_first : Boolean = false):TJsonObject;
var _array : TJson;
  _return : TJson;
begin
  if _first then
  Begin
     _array := TJson.Create;
     _array.Parse(DataSetToJsonArray(query).Stringify);
      Result := _array.Get(0).AsObject;
  end else
  Begin
      _return := TJson.Create;

      if _nomeObjeto <> '' then
         _return.Put(_nomeObjeto,DataSetToJsonArray(query));

      Result := _return.JsonObject;
  end;

end;

procedure TConexao.InsertObjectToSQl(_tabela: String; _Json: TJsonObject;
  _returnID: Boolean);
var i : Integer;
  _sql : String;
  _value : String;
  _delimiter : String;
begin
   _sql := EmptyStr;
   _value := EmptyStr;
   _delimiter := EmptyStr;

   GetEstrutura(_tabela);

   for i :=0 to _Json.Count-1 do
   Begin
       if campoValido(_Json.Items[i].Name) then
       Begin
           _sql:= _sql + _delimiter + _Json.Items[i].Name;

           case _Json.Items[i].Value.ValueType of
               jvNumber:
                 _value:= _value + _delimiter + QuotedStr(prepara_valor(_Json.Items[i].Value.AsNumber));
              jvBoolean:
                 _value:= _value + _delimiter + QuotedStr(FlagBool(_Json.Items[i].Value.AsBoolean));
              else
                 _value:= _value + _delimiter + QuotedStr(_Json.Items[i].Value.AsString);
           end;
           _delimiter:=',';
       end;
   end;

   with Query do
   Begin
       Sql.Clear;
       Sql.Add('insert into '+_tabela+ '(' +_sql+')');
       Sql.Add(' values ' ) ;
       Sql.Add('('+_value+')');
       if _returnID then
          Sql.Add('returning id ');

       sql.text := UTF8Encode(sql.text);
   end;
end;

procedure TConexao.InsertArrayToSQl(_tabela: String; _jsonArray: TJsonArray;
     _foreignKey : String = ''; _foreingValue:integer = 0);
var i,j : Integer;
  _sql, _itemAdd, _cabecalho: String;
  _value : TStringList;
  _delimiter : String;
  _item : TJsonObject;
  iSql : TZSQLProcessor;
begin
   _sql := EmptyStr;
   _cabecalho:= '';
   _value := TStringList.Create;
   _delimiter := EmptyStr;
   _itemAdd := EmptyStr;

   GetEstrutura(_tabela);

   for j :=0 to _jsonArray.Count-1 do
   Begin
       _item := _jsonArray.Items[j].AsObject;

       if not _item['update'].AsBoolean then
       Begin
            //if _item['id'].AsInteger = 0 then
            //Begin
            //   _item['datacriacao'].AsString:= getDataUTC;
            //   _item['dataatualizacao'].AsString:= getDataUTC;
            //end;

            if _foreignKey <> '' then
               _item.put(_foreignKey,_foreingValue);

            for i :=0 to _item.Count-1 do
            Begin
                 if (campoValido(_item.Items[i].Name)) then
                 Begin
                    if _cabecalho = '' then
                        _sql:= _sql + _delimiter + _item.Items[i].Name;

                     case _item.Items[i].Value.ValueType of
                         jvNumber:
                           _itemAdd:= _itemAdd + _delimiter + QuotedStr(prepara_valor(_item.Items[i].Value.AsNumber));
                        jvBoolean:
                           _itemAdd:= _itemAdd + _delimiter + QuotedStr(FlagBool(_item.Items[i].Value.AsBoolean));
                        else
                           _itemAdd:= _itemAdd + _delimiter + QuotedStr(_item.Items[i].Value.AsString);
                     end;

                     _delimiter:=',';
                 end;
             end;

            _delimiter:= EmptyStr;
             if _value.Count > 0  then
                _delimiter:= ',';

             if trim(_itemAdd) <> '' then
                _value.Add(_delimiter +'('+ _itemAdd+')');

             _delimiter:= EmptyStr;
             _itemAdd := EmptyStr;
             _cabecalho:=_sql;
       end;

   end;

   try
       iSql:= TZSQLProcessor.Create(nil);
       iSql.Connection := Conector;
       with iSql do
       Begin
           Script.Clear;
           Script.Add('insert into '+_tabela+' ('+_cabecalho+')' );
           Script.Add(' values ');
           Script.add(_value.Text);

           Script.text := UTF8Encode(Script.text);
           if _value.Count > 0 then
           Begin
               try
                 iSql.Execute;
               except
                  on e:Exception do
                  Begin
                     RegistraLogErro(' insert sql : '+_tabela+' '+e.Message);
                     RegistraLogErro(Script.Text);
                  end;
               end;
           end;
       end;
   finally
     FreeAndNil(iSql);
   end;
end;

procedure TConexao.updateSQl(_tabela:String;_Json, _jsonOlD:TJsonObject);
var i : Integer;
   _value : TStringlist;
  _delimiter : String;
begin
   _value := TStringList.Create;
   _delimiter := EmptyStr;

   GetEstrutura(_tabela);

   _Json.Delete('datacriacao');

   for i :=0 to _Json.Count-1 do
   Begin
       if (_Json.Items[i].Name<>'id') and (campoValido(_Json.Items[i].Name)) then
       Begin
           case _Json.Items[i].Value.ValueType of
               jvNumber:
                 _value.Add(_delimiter+_Json.Items[i].Name+'='+ QuotedStr(prepara_valor(_Json.Items[i].Value.AsNumber)));
              jvBoolean:
                 _value.Add(_delimiter+_Json.Items[i].Name+'='+ QuotedStr(FlagBool(_Json.Items[i].Value.AsBoolean)));
              else
                 _value.Add(_delimiter+_Json.Items[i].Name+'='+ QuotedStr(_Json.Items[i].Value.AsString));
           end;
           _delimiter:=',';
       end;
   end;

   with Query do
   Begin
       close;
       Sql.Clear;
       Sql.Add('update '+_tabela+ ' set ');
       Sql.Add(_value.text);
       Sql.add(' where id = '+QuotedStr(_Json['id'].AsString));
       sql.text := UTF8Encode(sql.text);
       ExecSQL;
   end;

end;

procedure TConexao.updateSQlArray(_tabela: String; _JsonArray:TJsonArray; _forceUpdate : Boolean = false);
var i ,j: Integer;
   _value, _script: TStringlist;
  _delimiter : String;
  _item : TJsonObject;
  _insert : boolean;
  iSql : TZSQLProcessor;
begin
 try
   _value := TStringList.Create;
   _script := TStringList.Create;
   iSql:= TZSQLProcessor.Create(nil);
   iSql.Connection := Conector;

   _delimiter := EmptyStr;
   _insert := false;

   GetEstrutura(_tabela);


   for j := 0 to _JsonArray.Count-1 do
   Begin
         _item := _JsonArray.Items[j].AsObject;

         if (_item['update'].AsBoolean then
         Begin
               for i :=0 to _item.Count-1 do
               Begin
                   if (_item.Items[i].Name<>'id') and (campoValido(_item.Items[i].Name)) and (_item['id'].AsInteger > 0) then
                   Begin
                       case _item.Items[i].Value.ValueType of
                           jvNumber:
                             _value.Add(_delimiter+_item.Items[i].Name+'='+ QuotedStr(prepara_valor(_item.Items[i].Value.AsNumber)));
                          jvBoolean:
                             _value.Add(_delimiter+_item.Items[i].Name+'='+ QuotedStr(FlagBool(_item.Items[i].Value.AsBoolean)));
                          else
                             _value.Add(_delimiter+_item.Items[i].Name+'='+ QuotedStr(_item.Items[i].Value.AsString));
                       end;
                       _delimiter:=',';
                       _insert := true;
                   end;
               end;

               with iSql do
               Begin
                   if _delimiter <> '' then
                   Begin
                       _script.Add('update '+_tabela+ ' set ');
                       _script.Add(_value.text);
                       _script.add(' where id = '+QuotedStr(_item['id'].AsString)+';');
                       _script.Add('');
                   end;
               end;
               _value.Clear;
               _delimiter:='';
         end;

   end;

   with iSql do
   Begin
       Script.text := UTF8Encode(_script.text);
       if _script.Count > 0 then
       Begin
           try
              iSql.Execute;
           except
              on e:Exception do
              Begin
                  RegistraLogErro(' update sql : '+_tabela+' '+e.Message);
                  RegistraLogErro(Script.Text);
              end;
           end;
       end;
   end;
finally
   FreeAndNil(iSql);
end;

end;

procedure TConexao.ProcessaSinc(_name: String; _jArray: TJsonArray);
var i : integer;
    iSql : TZSQLProcessor;
begin
try
  try
    iSql:= TZSQLProcessor.Create(nil);
    iSql.Connection := Conector;
    for i := 0 to _jArray.Count-1 do
    Begin
         if _jArray.Items[i].AsObject['remover'].AsBoolean  then
            isql.Script.Add('delete from '+_name+' where uuid = '+QuotedStr(_jArray.Items[i].AsObject['uuid'].AsString)+';')
         else
            with isql.Script do
            Begin
                Add('update '+_name+' set sinc_pendente = ''N'' '+
                    ', id = '+QuotedStr(_jArray.Items[i].AsObject['id'].AsString)+
                    ' where uuid = '+QuotedStr(_jArray.Items[i].AsObject['uuid'].AsString)+
                    ' and (sinc_pendente =''S'' or sinc_pendente is null); ');
            end;
    end;

    if isql.Script.Count > 0 then
      isql.Execute;
  finally
      FreeAndnil(isql);
  end;

except
    on e:exception do
    Begin
        RegistraLogErro('Erro Comando Sql '+e.Message);
    end;
end;
end;

procedure TConexao.ChecaItensArrayToSQl(_tabela: String; _JsonArray:TJsonArray);
var _item : TJsonObject;
  _delimiter, s_listaID : string;
  i : Integer;
begin
try
  with Query  do
  Begin
       Close;
       Sql.Clear;
       Sql.Add('select id from '+_tabela+' where id in (');
       s_listaID:= '';

       for i := 0 to _JsonArray.Count -1 do
       Begin
           _item := _JsonArray.Items[i].AsObject;
           s_listaID:= s_listaID +_delimiter + _item['id'].AsString;
          _delimiter:= ',';
       end;

       Sql.Add(s_listaID);
       Sql.add(')');

       try
          Open;
       except
          on e:Exception do
             RegistraLogErro(' ChecaSQL : '+_tabela+':'+e.Message);
       end;

       first;

       while not eof do
       Begin
            for i := 0 to _JsonArray.count -1 do
            Begin
                _item := _JsonArray.Items[i].AsObject;
                if _item['id'].AsInteger = FieldByName('id').AsInteger then
                Begin
                     _item['update'].AsBoolean:= true;
                     break;
                end;
            end;
            Next;
       end;
  end;

except
   on e:Exception do
   Begin
      RegistraLogErro(' insert sql : '+_tabela+' '+e.Message);
      RegistraLogErro(Query.Sql.Text);
   end;
end;
end;

procedure TConexao.InserirDados(_tabela:String;_Json:TJsonObject; _returnID:Boolean = false);
begin
    InsertObjectToSQl(_tabela,_Json,_returnID);

    if _returnID = true then
    Begin
        query.Open;
        _Json['id'].AsInteger:=Query.FieldByName('id').AsInteger;
    end else
        query.ExecSQL;
end;

end.
