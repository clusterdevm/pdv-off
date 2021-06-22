unit model.sinc.down;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, ExtCtrls, model.request.http, clipbrd, dialogs,
  model.conexao,  classe.utils, Graphics,
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
      FErro_Processamento : boolean;
      _db : TConexao;
      FFalhou : boolean;

      Procedure Processa(_tabela:string; _jsonValue : TJsonArray);
      Procedure Consulta_Api(var _ok : Boolean) ;
      function valida_table(_tabelaName:string):boolean;
      function CriaTabela(_tabelaName:String):Boolean;

      Procedure SendUpload(_upload : TJsonObject);
      Procedure PreparaUpload(_upload : TJsonObject);
      Procedure ProcessarUpdate(Return:TJsonObject);
      Procedure Concluir ;
 protected
   procedure Execute; override;
   Procedure AtualizaLog ;
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
begin
_ok := false;
try
    try
        _api := TRequisicao.Create;
        _api.Metodo:= 'post';
        _api.webservice:= getEMS_Webservice(mPDV);
        _api.AddHeader('token-pdv',FTokenPDV);
        _api.rota:='hibrido';
        _api.endpoint:= 'download';
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
            if _api.ResponseCode <> 204 then
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
    _Api.AddHeader('canal-token',canal_token);
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
           RegistraLogErro('Criar Tabela '+_tabelaName+' ' +e.message);
           RegistraLogErro(_sql.Text);
     end;
end;
end;

procedure TSincDownload.SendUpload(_upload : TJsonObject);
var _api : TRequisicao;
begin
  try
    try
        _api := TRequisicao.Create;
         _api.Metodo:= 'post';
         _api.Body.Text:= _upload.Stringify;
         _api.webservice:= getEMS_Webservice(mPDV);
         _api.AddHeader('token-pdv',FTokenPDV);
         _api.rota:='hibrido';
         _api.endpoint:= 'upload';

         FMsg:= 'Enviando Dados para Servidor';
         Synchronize(AtualizaLog());
         _api.Execute;

         if _api.ResponseCode in [200..207] then
         Begin
               ProcessarUpdate(_api.Return);
         end else
           FFalhou:= true;
    finally
         FreeAndnil(_api);
    end;
  except
       on e: exception do
       Begin
            RegistraLogErro('Consulta_Api Function : '+e.message);
            RegistraLogErro('URl : '+_api.webservice);
            RegistraLogErro('endPoint : '+_api.endpoint);
            RegistraLogErro('rota : '+_api.rota);
            RegistraLogErro('response : '+_api.response);
            FMsg:= 'Falha Ao enviar Consulte log';
            FFalhou:= true;
            Synchronize(AtualizaLog);
       end;
  end;
end;

procedure TSincDownload.PreparaUpload(_upload: TJsonObject);
begin
    with _db.Query do
    Begin
         Close;
         Sql.Clear;
         Sql.Add('select * from financeiro_caixa ');
         Sql.Add(' where sinc_pendente <> ''N'' ');
         open;
         _upload['itens'].AsObject.Put('financeiro_caixa',_db.ToArrayString);
    end;
end;

procedure TSincDownload.ProcessarUpdate(Return: TJsonObject);
var i : Integer;
   _name : String;
begin
   FMsg:= 'Iniciando Confirmação de Updates';
   Synchronize(AtualizaLog);

   for i:= 0 to return['itens'].AsObject.Count-1 do
   Begin
      _name := return['itens'].AsObject.Items[i].Name;
      FMsg:= _name;
      Synchronize(AtualizaLog);

      _db.ProcessaSinc(_name, Return['itens'].AsObject[_name].AsArray);
   end;

end;

procedure TSincDownload.Concluir;
var _api : TRequisicao;
    _aux : String;
begin
try
     try
        _api := TRequisicao.Create;
        _api.Metodo:= 'post';
        _api.webservice:= getEMS_Webservice(mPDV);
        _api.AddHeader('protocolo',FProtocolo);
        _saveDebug(FProtocolo,'prototoclo');
        _api.rota:='hibrido';
        _api.endpoint:= 'confirmadownload';
        _api.Execute;

        if not (_api.ResponseCode in [200..207]) then
        Begin
           FMsg:= _api.Return['msg'].AsString;
           FProtocolo:= '';
           Synchronize(AtualizaLog);
        end
        else
        Begin
            FResponse.Clear;
            FResponse.Parse(_api.return.Stringify);
        end;
     finally
           FreeAndNil(_api);
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
end;


procedure TSincDownload.Execute;
var
   _itensJson : TJsonObject;
    j,i : Integer;
    _name : String;
    _ok : Boolean;
    _time: Integer;
begin

  while Fprocessando do
  Begin
      try
            FMsg:= 'Conectando ao Servidor';
            Synchronize(AtualizaLog);
            Consulta_Api(_ok);
            _time := 0;

            FProtocolo:= FResponse['resultado'].AsObject['protocolo'].AsString;
            FResponse['resultado'].AsObject.Delete('protocolo');
            FResponse['resultado'].AsObject.Delete('registros');

            RegistraLogErro('response: '+FResponse.Stringify);

           if (_ok) and (FResponse.Stringify <> '{}') then
           Begin
               _itensJson := FResponse['resultado'].AsObject;
               FErro_Processamento:= false;
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
                   end
                   else
                   Begin
                       FErro_Processamento:= true;
                       RegistraLogErro('Tabela inexistente '+ _name);
                   end;
               end;

               Fprocessando:= false;

           end;

           if (i >= 0 ) and (_ok) then
           Begin
               if FResponse.Stringify= '{}' then
               Begin
                   FMsg:= 'Ultima Sicronização '+ FormatDateTime('dd/mm/yyyy hh:mm:ss',now);
                  _time:= 30000;
               end
               else
               Begin
                  if NOT Fprocessando then
                  Begin
                       FMsg:= 'Ultima Sicronização '+ FormatDateTime('dd/mm/yyyy hh:mm:ss',now);
                      _time:= 30000;

                      if (not FErro_Processamento) and (_itensJson.Count> 0) then
                         Concluir;

                      FFalhou:= FErro_Processamento;
                  end else
                    _time:= 5000;
               end;
               Fprocessando := not FResponse['finalizado'].AsBoolean;
               Synchronize(AtualizaLog);
           end
           else
              Fprocessando:= false;

            FResponse.Clear;
            _itensJson := TJsonObject.Create();
            PreparaUpload(_itensJson);

            if _itensJson['itens'].AsObject.Count > 0 then
               SendUpload(_itensJson);
            FreeAndNil(_itensJson);


            if (Sessao.segundoplano) then
            Begin
                 Fprocessando:= true;
                 Delay(_time);
            end;
      except
            Fprocessando:= true;
            FMsg:= 'Erro ao Processar';
            Synchronize(AtualizaLog);
           _time := 1000;
           Delay(_time);
      end;
  end;
end;

procedure TSincDownload.AtualizaLog;
begin

  FPanel.Caption:= FMsg+'  ';
  FPanel.Repaint;
  fpanel.enabled := true;

  if FFalhou then
     FPanel.Font.Color := clred
  else
    FPanel.Font.Color := clwhite;

  if not FPanel.Visible then
     FPanel.Visible:= true;

  if FErro <> '' then
  Begin
     FHistorico.Add(ferro);
     //RegistraLogErro(FHistorico.Text);
     FErro:= '';
  end;

  FFalhou:= false;
end;

constructor TSincDownload.Create(CreateSuspended: boolean; value: TPanel; _tokenpdv:string);
begin
FFalhou:= false;
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

