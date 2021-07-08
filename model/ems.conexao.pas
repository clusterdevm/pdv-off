unit ems.conexao;

interface

uses SysUtils, Variants, Classes, // ZConnection, ZDataset,
     sqldb,
     jsons, db, BufDataset, typinfo, dialogs  ;

Type

  { TConexao }

  TConexao = Class
      Private
          Conector : TSQLConnector;
          FqryPost: TSQLQuery;
          Transaction : TSQLTransaction;
          FQuery   : TSQLQuery;
          _estruturaDB: TJsonArray;

          Procedure GetEstrutura(_tabela:string);
          function campoValido(value:string):Boolean;
          Procedure InsertObjectToSQl(_tabela:String;_Json:TJsonObject; _returnID:Boolean = false );

          Procedure CriaBaseDefault;

          Procedure ExecutaSQL(isql : string; _aux:string = '');

          procedure checaIndex(value:string; _delimiter:string ;var _index :string);



      Public
         Function TabelaExists(_tabela:string) : Boolean;
         Procedure ChecaEstrutura(_tabela:string);

         Property qrySelect : TSQLQuery      Read FQuery      Write FQuery;
         Property qryPost : TSQLQuery      Read FqryPost      Write FqryPost;


         Function getStr(value:String):String;

         function ToArrayString:TJsonArray;

         Function DataSetToArrayString(ADataset:TBufDataset; _nomeObjeto:String = ''): String;
         function ToObjectString(_nomeObjeto:String ;_first : Boolean = false):TJsonObject;

         procedure updateSQl(_tabela:String;_Json:TJsonObject);
         procedure updateSQlArray(_tabela:String;_JsonArray:TJsonArray; _forceUpdate : Boolean = false);
         Procedure ProcessaSinc(_name : String ; _jArray  : TJsonArray);


         Procedure ChecaItensArrayToSQl(_tabela:String;_JsonArray:TJsonArray);
         Procedure InserirDados(_tabela:String;_Json:TJsonObject; _returnID:Boolean = false );
         Procedure InsertArrayToSQl(_tabela:String;_jsonArray:TJsonArray;
                                    _foreignKey : String = ''
                                    ; _foreingValue:integer = 0);

         Procedure CreateTabela(_tabelaName : string; _ddl: TJsonArray);
         Procedure ChecaDDL(_tabelaName : string; _ddl: TJsonArray);

         Constructor Create;
         Destructor Destroy;override;

  end;

implementation

uses ems.utils;

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

constructor TConexao.Create;
var CriarBase : boolean;
    _PathConnection : String;
begin
  try

    {$IFDEF MSWINDOWS}
        _PathConnection := '.\tabela\ems.db';
        if not DirectoryExists('.\tabela\') then
            ForceDirectories('.\tabela\');
    {$else}
        _PathConnection := './tabela/ems.db';
        if not DirectoryExists('./tabela/') then
            ForceDirectories('./tabela/');
    {$ENDIF}

     CriarBase:= not (fileexists(_PathConnection));

     Conector := TSQLConnector.Create(nil);
     Conector.LoginPrompt:= false;
     Conector.ConnectorType:= 'SQLite3';
     Conector.DataBaseName      := _PathConnection;
     Conector.HostName      := '';
     Conector.Password      := '';
     Conector.UserName          := '';
     Conector.CharSet:='utf-8';

     Transaction := TSQLTransaction.Create(nil);
     Transaction.DataBase := Conector;


     //Conector               := TZConnection.Create(nil);
     //Conector.loginprompt   := false;
     //Conector.Database      := _PathConnection;
     //Conector.HostName      := '';
     //Conector.Password      := '';
     //Conector.User          := '';
     //Conector.Protocol      := 'sqlite-3';
     //Conector.AutoCommit:= true;
     //Conector.ClientCodepage:='UTF-8';
     //{$IFDEF MSWINDOWS}
     //   Conector.LibraryLocation:='sqlite3.dll';
     //{$else}
     //   Conector.LibraryLocation:='';
     //{$ENDIF}

     Transaction.Options:= [stoUseImplicit];
     ExecutaSQL('PRAGMA journal_mode=WAL');

     FQuery := TSQLQuery.Create(nil);
     FQuery.DataBase := Conector;
     FQuery.Transaction := Transaction;
     FQuery.Options:= [sqoAutoApplyUpdates,sqoAutoCommit,sqoRefreshUsingSelect,sqoKeepOpenOnCommit];

     FqryPost := TSQLQuery.Create(nil);
     FqryPost.DataBase := Conector;
     FQuery.Transaction := Transaction;
     FqryPost.Options:= [sqoAutoApplyUpdates,sqoAutoCommit,sqoRefreshUsingSelect,sqoKeepOpenOnCommit];


    //Conector.ExecuteDirect('PRAGMA foreign_keys = OFF');

     //;

     if CriarBase then criaBaseDefault;

    GSincronizar := true;

  except
     on e:Exception do
     Begin
         RegistraLogRequest('Create Conexao:'+e.message);
     end;
  end;
end;

destructor TConexao.Destroy;
begin
    FQuery.Close;
    Conector.Connected := false;
    FreeAndNil(FQuery);
    FreeAndNil(FqryPost);
    FreeAndNil(Conector);
    inherited;
end;


procedure TConexao.GetEstrutura( _tabela: string);
var _dbEstrutura: TSQLQuery;
begin
  _dbEstrutura := TSQLQuery.Create(nil);
  _dbEstrutura.DataBase := Conector;
  _dbEstrutura.Transaction := Transaction;
  _dbEstrutura.Options:= [sqoAutoApplyUpdates,sqoAutoCommit];

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



//function TConexao.Getsql: String;
//var  i: Integer;
//  r: string;
//begin
//  Result := LowerCase(Query.SQL.Text);
//  for i := 0 to Query.Params.Count - 1 do
//  begin
//      r:= QuotedStr(Query.Params[i].AsString);
//
//      Result := StringReplace(Result, ':' + lowercase(Query.Params.Items[i].Name), r, [rfReplaceAll]);
//  end;
//end;

function TConexao.getStr(value: String): String;
begin
     Result := trim(qrySelect.FieldByName(value).AsString);
end;

function TConexao.ToArrayString : TJsonArray;
begin
     Result :=  DataSetToJsonArray(qrySelect);
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
     _array.Parse(DataSetToJsonArray(qrySelect).Stringify);
      Result := _array.Get(0).AsObject;
  end else
  Begin
      _return := TJson.Create;

      if _nomeObjeto <> '' then
         _return.Put(_nomeObjeto,DataSetToJsonArray(qrySelect));

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

   with qryPost do
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

procedure TConexao.CriaBaseDefault;
var _isql : TStringList;
begin
   try
      _isql := TStringList.Create;

       with _isql do
       Begin
            Add(' CREATE TABLE ems_pdv( ');
            Add('token_local text, ');
            Add('token_remoto text,');
            Add('apelido text,');
            Add('status text,');
            Add('primeira_sinc text,');
            Add('modelo_default integer,');
            Add('id integer);');
            ExecutaSQL(text);
       end;

       ExecutaSQL('PRAGMA journal_mode=WAL');
   finally
       FreeAndNil(_isql);
   end;
end;

procedure TConexao.ExecutaSQL(isql: string; _aux:string = '');
var iCommand :  TSQLScript;
begin
  try
      iCommand:= TSQLScript.Create(nil);
      iCommand.DataBase := Conector;
      iCommand.Transaction :=  Transaction;
      iCommand.AutoCommit:= true;
      with iCommand do
      Begin
          Script.Clear;
          Script.Add(iSql);
          try
              iCommand.Execute;
          except
              on e:Exception do
              Begin
                  RegistraLogRequest(' Command sql : '+_aux+' '+e.Message);
                  RegistraLogRequest(Script.Text);
              end;
          end;
      end;
  finally
    FreeAndNil(iCommand);
  end;
end;

procedure TConexao.checaIndex(value:string; _delimiter:string ;var _index :string);
begin
    value := LowerCase(value);
    if (value = 'id') or
       (value = 'nome') or
       (value = 'ativo') or
       (copy(value,1,4)= 'data') or
       (copy(value,1,9)= 'descricao') or
       (value = 'empresa_id') or
       (value = 'matriz_id')
    then
       _index := _Index + _delimiter +value;
end;

function TConexao.TabelaExists(_tabela: string): Boolean;
var qryCheca : TSQLQuery;
    _find : boolean;
begin
   try
       qryCheca := TSQLQuery.Create(nil);
       qryCheca.DataBase := Conector;
       qryCheca.Transaction := Transaction;
       qryCheca.Options:= [sqoAutoApplyUpdates,sqoAutoCommit];

       with qryCheca do
       Begin
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

          result := not IsEmpty;

          if not result then
            RegistraLogRequest('Tabela: '+_tabela +' Não existe localmente ');
       end;
   finally
        FreeAndNil(qryCheca);
   end;
end;

procedure TConexao.ChecaEstrutura(_tabela: string);
var qryCheca : TSQLQuery;
    _find : boolean;
begin
   try
       qryCheca := TSQLQuery.Create(nil);
       qryCheca.DataBase := Conector;
       qryCheca.Transaction := Transaction;
       qryCheca.Options:= [sqoAutoApplyUpdates,sqoAutoCommit];

       with qryCheca do
       Begin
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

          _find := true;
          if (_tabela = 'financeiro_caixa') or (_tabela = 'financeiro') or
             (_tabela = 'venda_itens') or (_tabela = 'vendas')
          then
             _find := false;
          if _find = false then
          Begin
                first;
                while not eof do
                Begin
                     if FieldByName('column_name').AsString = 'sinc_pendente' then
                     Begin
                         _find := true;
                         Break;
                     end;
                    Next;
                end;
          end;

          if not _find then
             ExecutaSQL('alter table '+_tabela+' add sinc_pendente text;');


          // Checando UUID
          _find := true;

          if (_tabela = 'financeiro_caixa') or (_tabela = 'financeiro') or
             (_tabela = 'venda_itens') or (_tabela = 'vendas')
          then
             _find := false;


          if _find = false then
          Begin
                first;
                while not eof do
                Begin
                     if FieldByName('column_name').AsString = 'uuid' then
                     Begin
                         _find := true;
                         Break;
                     end;
                    Next;
                end;
          end;

          if not _find then
             ExecutaSQL('alter table '+_tabela+' add uuid text;');


          // checando uuid_venda

          _find := true;
          if (_tabela = 'venda_itens')  then
             _find := false;

          if _find = false then
          Begin
                first;
                while not eof do
                Begin
                     if FieldByName('column_name').AsString = 'uuid_venda' then
                     Begin
                         _find := true;
                         Break;
                     end;
                    Next;
                end;
          end;

          if not _find then
             ExecutaSQL('alter table '+_tabela+' add uuid_venda text;');

       end;
   finally
     FreeAndNil(qryCheca);
   end;
end;



procedure TConexao.InsertArrayToSQl(_tabela: String; _jsonArray: TJsonArray;
     _foreignKey : String = ''; _foreingValue:integer = 0);
var i,j : Integer;
  _sql, _itemAdd, _cabecalho: String;
  _value : TStringList;
  _delimiter : String;
  _item : TJsonObject;
  _processado : boolean ;
  _count : Integer;
begin
   _sql := EmptyStr;
   _cabecalho:= '';
   _value := TStringList.Create;
   _delimiter := EmptyStr;
   _itemAdd := EmptyStr;

   GetEstrutura(_tabela);

   _count:= 0;
   _processado:= false;

   for j :=0 to _jsonArray.Count-1 do
   Begin
       _item := _jsonArray.Items[j].AsObject;

       if not _item['update'].AsBoolean then
       Begin

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


        if (_count >=250 ) then
        Begin
            if _value.Count > 0 then
            Begin
               ExecutaSql('insert into '+_tabela+' ('+_cabecalho+')'+
                          ' values '+
                          _value.Text);
            end;

            _processado := true;
            _count := 0;
            _value.Clear;
        end else
        Begin
           Inc(_count);
           _processado:= false;
        end;
   end;

   if (_count > 0) and (_processado = false) then
   Begin
       if _value.Count > 0 then
       Begin
          ExecutaSql('insert into '+_tabela+' ('+_cabecalho+')'+
                     ' values '+
                     _value.Text);
       end;
   end;

end;

procedure TConexao.CreateTabela(_tabelaName : string; _ddl: TJsonArray);
var
   _sql : TStringList;
   _item : TJsonObject;
   _line , _delimiter, _type, _notNull: String;
   _index : String;
   i : Integer;
   qTable : TSQLQuery;
begin
   _sql := TStringList.Create;
   qTable := TSQLQuery.Create(nil);
   qTable.DataBase := Conector;
   qTable.Transaction := Transaction;
   qTable.Options:= [sqoAutoApplyUpdates,sqoAutoCommit];

   _sql.add('CREATE TABLE '+_tabelaName+'(');
   _delimiter := '';
   _index:='';

    for i := 0 to _ddl.Count -1 do
    Begin
         _item := _ddl.Items[i].AsObject;

         if trim(LowerCase(_item['data_type'].AsString)) = 'integer' then
             _type := 'INTEGER'
         else
         if trim(LowerCase(_item['data_type'].AsString)) = 'numeric' then
             _type := 'REAL'
         else
             _type := 'TEXT';

         _notNull := '';

         _line := _delimiter+_item['column_name'].AsString +
                  ' '+_type+
                  ' '+ _notNull;

         if (LowerCase(_item['column_name'].AsString) = 'id') and
            (LowerCase(_tabelaName) = 'venda_itens') then
            _line:= _line + ' PRIMARY KEY AUTOINCREMENT ';

         _sql.Add(_line);

         checaIndex(_item['column_name'].AsString,_delimiter,_index);
         _delimiter := ',';
    end;
    _Sql.Add(')');

    if trim(_index) <> '' then
      _index := 'CREATE INDEX IDX_'+_tabelaName+ ' ON ' +_tabelaName + '('+
                _index+');';

    with qTable do
    Begin
        Close;
        Sql.Clear;
        Sql.Text:=_sql.Text;
        if _ddl.Count > 0 then ExecSQL;

        Close;
        Sql.Clear;
        Sql.Add(_index);
        if _index <> '' then
          if _ddl.Count > 0 then ExecSQL;
    end;

    FreeAndNil(_sql);
    FreeAndNil(qTable);
end;

procedure TConexao.ChecaDDL(_tabelaName: string; _ddl: TJsonArray);
var
   _sql : TStringList;
   _item : TJsonObject;
   _line , _delimiter, _type, _notNull: String;
   _index : String;
   i : Integer;
   qTable : TSQLQuery;

   _find : Boolean;
begin
 try
   _sql := TStringList.Create;
   qTable := TSQLQuery.Create(nil);
   qTable.DataBase := Conector;
   qTable.Transaction := Transaction;
   qTable.Options:= [sqoAutoApplyUpdates,sqoAutoCommit];

   _delimiter := '';
   _index:='';

   if _tabelaName = 'venda_itens' then
      _find := false;

    for i := 0 to _ddl.Count -1 do
    Begin
         _item := _ddl.Items[i].AsObject;
         _find := false;

         with qTable do
         Begin
            Close;
            Sql.Clear;
            Sql.Add('SELECT');
            Sql.Add('  p.name as column_name');
            Sql.Add('FROM');
            Sql.Add('  sqlite_master AS m');
            Sql.Add('JOIN');
            Sql.Add('  pragma_table_info(m.name) AS p');
            Sql.Add('  where m.name = '+QuotedStr(_tabelaName));
            Sql.Add(' and p.name = '+QuotedStr(_item['column_name'].AsString));
            open;

            _find := not IsEmpty;
         end;


         if not _find then
         Begin
               if trim(LowerCase(_item['data_type'].AsString)) = 'integer' then
                   _type := 'INTEGER'
               else
               if trim(LowerCase(_item['data_type'].AsString)) = 'numeric' then
                   _type := 'REAL'
               else
                   _type := 'TEXT';

               _notNull := '';

               _line := _delimiter+_item['column_name'].AsString +
                        ' '+_type+
                        ' '+ _notNull;

               if (LowerCase(_item['column_name'].AsString) = 'id') and
                  (LowerCase(_tabelaName) = 'venda_itens') then
                  _line:= _line + ' PRIMARY KEY AUTOINCREMENT ';

               _sql.Add('ADD '+_line);

               checaIndex(_item['column_name'].AsString,_delimiter,_index);

               _delimiter := ',';
         end;
    end;

    if trim(_index) <> '' then
      _index := 'CREATE INDEX IDX_'+_tabelaName+formatdatetime('ddmmyyhhmm',now)+ ' ON ' +_tabelaName + '('+
                _index+');';

    with qTable do
    Begin
        Close;
        Sql.Clear;
        Sql.Add('ALTER TABLE '+_tabelaName);
        Sql.Add(_sql.Text);
        Sql.Add(';');


        if _sql.Count > 0 then ExecSQL;

        Close;
        Sql.Clear;
        Sql.Add(_index);
        if _index <> '' then
          if _ddl.Count > 0 then ExecSQL;
    end;

 finally
    FreeAndNil(_sql);
    FreeAndNil(qTable);
 end;
end;

procedure TConexao.updateSQl(_tabela:String;_Json:TJsonObject);
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

   with qryPost do
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
  _count : Integer;
  _processado : Boolean;
begin
 try
   _value := TStringList.Create;
   _script := TStringList.Create;

   _delimiter := EmptyStr;
   _insert := false;

   GetEstrutura(_tabela);
   _count := 0 ;
   _processado := false;

   for j := 0 to _JsonArray.Count-1 do
   Begin
         _item := _JsonArray.Items[j].AsObject;

         if (_item['update'].AsBoolean) or (_forceUpdate) then
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

               if _delimiter <> '' then
               Begin
                   _script.Add('update '+_tabela+ ' set ');
                   _script.Add(_value.text);
                   _script.add(' where id = '+QuotedStr(_item['id'].AsString)+';');
                   _script.Add('');
               end;
               _value.Clear;
               _delimiter:='';
         end;


       if (_count >=250 ) then
       Begin
           if _script.Count > 0 then
              ExecutaSql(_script.Text);

           _processado := true;
           _count := 0;
           _script.Clear;
       end else
       Begin
          Inc(_count);
          _processado:= false;
       end;
   end;

    if (_count > 0) and (_processado = false) then
        if _script.Count > 0 then
           ExecutaSql(_script.Text);

finally
   FreeAndNil(_value);
   FreeAndNil(_script);
end;

end;

procedure TConexao.ProcessaSinc(_name: String; _jArray: TJsonArray);
var i : integer;
    iSql : TSQLScript;
begin
try
  try
    iSql:= TSQLScript.Create(nil);
    iSql.DataBase := Conector;
    iSql.Transaction :=  Transaction;
    iSql.AutoCommit:= true;

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
        RegistraLogRequest('Erro Comando Sql '+e.Message);
    end;
end;
end;

procedure TConexao.ChecaItensArrayToSQl(_tabela: String; _JsonArray:TJsonArray);
var _item : TJsonObject;
  _delimiter, s_listaID : string;
  i : Integer;
begin
try
  with qrySelect  do
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
             RegistraLogRequest(' ChecaSQL : '+_tabela+':'+e.Message);
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
      RegistraLogRequest(' insert sql : '+_tabela+' '+e.Message);
      RegistraLogRequest(qrySelect.Sql.Text);
   end;
end;
end;

procedure TConexao.InserirDados(_tabela:String;_Json:TJsonObject; _returnID:Boolean = false);
begin
    InsertObjectToSQl(_tabela,_Json,_returnID);

    if _returnID = true then
    Begin
        qryPost.Open;
        _Json['id'].AsInteger:=qryPost.FieldByName('id').AsInteger;
    end else
        qryPost.ExecSQL;
end;

end.
