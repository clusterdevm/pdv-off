unit model.sinc.down;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, ExtCtrls, model.request.http, clipbrd, dialogs,
  model.conexao,  classe.utils,
  jsons, crt, model.usuarios;

Type

{ TSincDownload }

TSincDownload = class(TThread)
 private
      FMsg : String;
      FErro : String;
      Fprocessando : boolean;
      FProtocolo : String;
      FResponse : TJSONObject;
      FTokenPDV : String;
      FHistorico : TStringList;
      FPanel : TPanel;
      Fmsg_erro : string;
      _db : TConexao;

      Procedure Processa(_tabela:string; _jsonValue : TJsonArray);
      Procedure Consulta_Api(var _ok : Boolean) ;

      function valida_table(_tabelaName:string):boolean;

      function CriaTabela(_tabelaName:String):Boolean;
 protected
   procedure Execute; override;
   Procedure AtualizaLog;
 public
   Constructor Create(CreateSuspended : boolean; value : TPanel; _tokenpdv:string);
   destructor Destroy; override;
 end;

implementation

{ TSincDownload }


procedure TSincDownload.Processa(_tabela: string; _jsonValue: TJsonArray);
begin
   FMsg:='Checando Itens:'+_tabela;
   Synchronize(AtualizaLog);
   _db.ChecaItensArrayToSQl(_tabela,_jsonvalue);

   FMsg:='Inserindo Itens:'+_tabela;
   Synchronize(AtualizaLog);
   _db.InsertArrayToSQl(_tabela,_jsonvalue);

   FMsg:='Atualizando Itens :'+_tabela;
   Synchronize(AtualizaLog);
   _db.updateSQlArray(_tabela,_jsonvalue);

   FMsg:='finalizado :'+_tabela;
   Synchronize(AtualizaLog);
end;

procedure TSincDownload.Consulta_Api(var _ok: Boolean);
var _api : TRequisicao;
  _aux : String;
  _Body : TJsonObject;
begin
_ok := false;
try
    try
        _Body := TJsonObject.Create;
        _Body.Put('protocolo',FProtocolo);

        _api := TRequisicao.Create;
        _api.Metodo:= 'post';
        _api.webservice:='https://api-pdv-dev.clustererp.com.br/';
        _api.tokenBearer:=FTokenPDV;
        _api.rota:='sincronizar';
        _api.endpoint:='sync_db/';
        _api.body.Text := _Body.Stringify;
        _api.Execute;


        if not (_api.ResponseCode in [200..207]) then
        Begin
             FMsg:= _api.Return['msg'].AsString;
             Synchronize(AtualizaLog);
             _ok := false;
        end
        else
        Begin
            FResponse.Clear;
            FResponse.Parse(_api.return.Stringify);
           _ok := true;
        end;


except
  on e: exception do
  Begin
       RegistraLogErro('Consulta_Api Function : '+e.message);
       RegistraLogErro('URl : '+_api.webservice);
       RegistraLogErro('endPoint : '+_api.endpoint);
       RegistraLogErro('rota : '+_api.rota);
       RegistraLogErro('response : '+_api.response);
  end;
end;

finally
    FreeAndNil(_api);
    FreeAndNil(_Body);
end;
end;



function TSincDownload.valida_table(_tabelaName: string): boolean;
var _tabela : TConexao;
begin
try
  try
      _tabela := TConexao.Create;
      with _tabela.Query do
      Begin
         Close;
         Sql.Clear;
         Sql.Add('select name from sqlite_master where type = '+QuotedStr('table'));
         Sql.Add(' and name  = '+QuotedStr(_tabelaName));
         open;

         if IsEmpty then
            Result := CriaTabela(_tabelaName)
         else
            Result := true;
      end;
  finally
      FreeAndNil(_tabela)
  end;
except
     on e:exception do
     Begin
        RegistraLogErro('Get Lista Tabela SqLite');
     end;
end;
end;

function TSincDownload.CriaTabela(_tabelaName: String): Boolean;
var _Api : TRequisicao;
   _strutucre : TJsonArray;
   _sql : TStringList;
   _item : TJsonObject;
   _line , _delimiter, _type, _notNull: String;
   _index : String;
   i : Integer;


   procedure checaIndex(value:string);
   Begin
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

begin
try
  Result := false;
  try
    _api := TRequisicao.Create;
    _api.Metodo:= 'get';
    _Api.AddHeader('table-name',_tabelaName);
    _api.webservice:= getEMS_Webservice(mAutenticacao);
    _Api.AutUserName:= Sessao.usuario;
    _Api.AutUserPass:= Sessao.senha;
    _api.rota:='autenticacao/table';
    _api.endpoint:='estrutura';
    _api.Execute;

    if _api.ResponseCode in [200..207] then
    Begin
       _strutucre := _Api.Return['resultado'].asArray;
       _sql := TStringList.Create;

       _sql.add('CREATE TABLE '+_tabelaName+'(');
       _delimiter := '';
       _index:='';

       for i := 0 to _strutucre.Count -1 do
       Begin
            _item := _strutucre.Items[i].AsObject;

            if trim(LowerCase(_item['data_type'].AsString)) = 'integer' then
                _type := 'INTEGER'
            else
            if trim(LowerCase(_item['data_type'].AsString)) = 'numeric' then
                _type := 'REAL'
            else
                _type := 'TEXT';

            //if LowerCase(_item['is_nullable'].AsString) = 'no' then
            //   _notNull := 'NOT NULL'
            //else
            _notNull := '';

            _line := _delimiter+_item['column_name'].AsString +
                     ' '+_type+
                     ' '+ _notNull;

            _sql.Add(_line);

            checaIndex(_item['column_name'].AsString);
            _delimiter := ',';
       end;
       _Sql.Add(')');

       _index := 'CREATE INDEX IDX_'+_tabelaName+ ' ON ' +_tabelaName + '('+
                 _index+');';

       with _db.Query do
       Begin
           Close;
           Sql.Clear;
           Sql.Text:=_sql.Text;
           ExecSQL;

           Close;
           Sql.Clear;
           Sql.Add(_index);
           ExecSQL;
       end;
       Result := true;
       FreeAndNil(_sql);
    end;

  finally
      FreeAndNil(_api);
  end;
except
     on e:exception do
     Begin
           RegistraLogErro('Criar Tabela '+e.message);
     end;
end;
end;

procedure TSincDownload.Execute;
var
   _itensJson : TJsonObject;
    j,i : Integer;
    _name : String;
    _ok : Boolean;
    iCount : Integer;
    _time: Integer;
begin
  iCount := 0;

  while Fprocessando do
  Begin
      FMsg:= 'Conectando ao Servidor';
      Synchronize(AtualizaLog);
      Consulta_Api(_ok);

      _time := 0;

      if (FResponse['finalizado'].AsBoolean = false) and (_ok) then
      Begin
         _itensJson := FResponse['itens'].AsObject;
         for I := 0 to _itensJson.Count - 1 do
         begin
             _name := _itensJson.Items[i].Name;
             FMsg:= _name;
             Synchronize(AtualizaLog);

             if valida_table(_name) then
             Begin
                 Processa(_name,
                         _itensJson[_name].AsArray
                         );
                 icount := iCount + _itensJson[_name].AsArray.Count-1;
             end
             else
                 RegistraLogErro('Tabela inexistente '+ _name);
         end;

         if _ok then
         Begin
             Fprocessando := not FResponse['finalizado'].AsBoolean;
             FProtocolo := FResponse['protocolo'].AsString;
             _time:= 1000;
         end
         else
            Fprocessando:= false;

      end
      else
      Begin
         Fprocessando:= false;

         if _ok then
         Begin
             if not Fprocessando then
             Begin
                if icount >  0 then
                   FMsg:= 'Registros Atualizados ('+IntToStr(iCount)+')' + FormatdateTime('hh:mm:ss',now)
                else
                   FMsg:= 'Ultima Sincronização: '+ FormatdateTime('hh:mm:ss',now);
                Synchronize(AtualizaLog);
                _time:= 30000;
             end;
         end else
            _time := 5000;
      end;

      if (Sessao.segundoplano) then
      Begin
           Fprocessando:= true;
           Delay(_time);

           if _time = 30000 then
             iCount := 0;
      end;
  end; // While _processado
end;

procedure TSincDownload.AtualizaLog;
begin

  FPanel.Caption:= FMsg+'  ';
  FPanel.Repaint;
  fpanel.enabled := true;

  if not FPanel.Visible then
     FPanel.Visible:= true;



  if FErro <> '' then
  Begin
     FHistorico.Add(ferro);
     //RegistraLogErro(FHistorico.Text);
     FErro:= '';
  end;
end;

constructor TSincDownload.Create(CreateSuspended: boolean; value: TPanel; _tokenpdv:string);
begin
  FHistorico := TStringList.Create;
  FProcessando := true;
  FProtocolo:= '';
  FPanel := value;
  FTokenPDV := _tokenpdv;
  FreeOnTerminate := true;

  FResponse := TJsonObject.Create;

  _db := TConexao.Create;

  inherited Create(CreateSuspended);
end;

destructor TSincDownload.Destroy;
begin
  FMsg:= 'Sincronismo encerrado';
  Synchronize(AtualizaLog);
  FreeAndNil(FResponse);
  FreeAndNIl(FHistorico);
  inherited Destroy;
end;

end.

