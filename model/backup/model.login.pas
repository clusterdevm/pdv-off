unit model.login;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, model.conexao, model.request.http, classe.utils,Dialogs, jsons;

type

{ TClassLogin }

TClassLogin = Class
  private
    fapelido: string;
    femail: string;
    fsenha: string;
    fstatus: string;
    ftoken_local: string;
    ftoken_remoto: string;
      Procedure getStatusRemoto;
  published
       property email : string read femail write femail;
       property senha : string read fsenha write fsenha;
       property apelido : string read fapelido write fapelido;
       property token_local : string read ftoken_local write ftoken_local;
       property token_remoto : string read ftoken_remoto write ftoken_remoto;
       Property status : string read fstatus write fstatus;
  public
       constructor Create;
       destructor Destroy;Override;

       function enviarRegistro : Boolean;
       function checaStatusRegistro : Boolean;
       function logar : boolean;
       function Primeiro_log : Boolean;
       procedure SetPrimeiroLogFalse;
end;

implementation

procedure TClassLogin.getStatusRemoto;
var
  _api : TRequisicao;
  _data :  TConexao;
begin
   try
     _api := TRequisicao.Create;
      _api.Metodo:='get';
      _api.webservice:= getEMS_Webservice(mPDV);
      _api.AddHeader('token-pdv',self.token_remoto);
      _api.rota:='hibrido';
      _api.endpoint:='status/';
      _api.Execute;

      if _api.ResponseCode in [200..207] then
      Begin
           try
              _data := TConexao.Create;
              with _data.query do
              Begin
                  SQL.Add('update ems_pdv set status = '+QuotedStr(_api.Return['status'].AsString));
                  sql.add(' where token_remoto = '+QuotedStr(self.token_remoto));
                  ExecSQL;
              end;

           finally
                  FreeAndNil(_data);
           end;
      end;

   finally
     FreeAndNil(_api);
   end;
end;


constructor TClassLogin.Create;
begin

end;

destructor TClassLogin.Destroy;
begin
  inherited Destroy;
end;

function TClassLogin.enviarRegistro: Boolean;
var _jsonBody : TjsonObject;
  _api : TRequisicao;
  _data :  TConexao;
  _item : TJsonObject;
begin
  try
    LimpaBase;
    _api := TRequisicao.Create;

    {$IFDEF MSWINDOWS}
         self.token_local := md5Text(bioswindows);
    {$else}
         self.token_local:= md5Text(FormatDatetime('ddmmyyyyhhmmss',now));
    {$ENDIF}

    _jsonBody := TJSONObject.Create;
    _jsonBody.Put('usuario',self.email);
    _jsonBody.Put('senha',self.senha);
    _jsonBody.Put('origem','D');
    _jsonBody.Put('apelido',self.apelido);

    _api.Body.Text:= _jsonBody.Stringify;
    _api.Metodo:='post';
    _api.rota:='pdv';
    _api.endpoint:='registra_pdv';

    _api.Execute;

    if _api.ResponseCode in [200..207] then
    Begin
        try
           _item := _api.Return['resultado'].AsObject;
           self.token_remoto:= _item['token'].AsString;

          _data := TConexao.Create;
          with _data.Query do
          Begin
              Close;
              Sql.Clear;
              Sql.Add('insert into ems_pdv (token_local, token_remoto, apelido,status) values ('+
                      QuotedStr(self.token_local)+','+
                      QuotedStr(self.token_remoto)+','+
                      QuotedStr(self.apelido)+','+
                      QuotedStr('P')+
                      ')');
              ExecSQL;
          end;
        finally
          FreeAndnil(_data);
        end;

    end;

  finally
      FreeAndNil(_jsonBody);
      FreeAndNil(_api);
  end;
end;

function TClassLogin.checaStatusRegistro: Boolean;
var data : tconexao;
begin
   try

     result := false;
     self.status := 'sem registro';
     data := TConexao.Create;
     with data.Query do
     Begin
          Sql.Clear;
          Sql.Add('select * from ems_pdv ');
          open;

          if not IsEmpty then
          Begin
              self.token_remoto:= FieldByName('token_remoto').AsString;
              getStatusRemoto;

              Close;
              open;

             if (FieldByName('status').AsString = 'P')  then
                self.status := 'Aguardando liberação'
             else
             if FieldByName('status').AsString = 'B' then
                self.status := 'PDV bloqueado'
             else
             if FieldByName('status').AsString = 'I' then
                self.status := 'PDV Cancelado'
             else
             if FieldByName('status').AsString = 'A' then
                self.status := 'Liberado';

             result := true;
          end;
     end;

   finally
     FreeAndNil(data);
   end;
end;

function TClassLogin.logar: boolean;
var _db : TConexao;
begin
try
     try
       Result := false;
       _db := TConexao.Create;

       with _db.Query  do
       Begin
            Close;
            Sql.Clear;
            Sql.Add('select * from usuarios where usuario = '+QuotedStr(femail));
            Open;
            if IsEmpty then
            Begin
                  ShowMessage('Usuario não encontrado');
            end else
            Begin
                 Sessao.usuario_id:=FieldByName('id').AsInteger;
                 sessao.usuarioName:= FieldByName('nome_completo').AsString;
                 if LowerCase(FieldbyName('senha').AsString) = lowercase(fsenha) then
                    Result := true
                 else
                    SHowmessage('Senha Invalida');
            end;


           Close;
           Sql.Clear;
           Sql.Add('select * from empresa ');
           Open;

           sessao.empresalogada := FieldByName('id').AsInteger;
           sessao.cnpj := FieldByName('cnpj').AsString;
           sessao.razao := FieldByName('empresa').AsString;
           sessao.nomeFantasia := FieldByName('fantasia').AsString;
           sessao.n_unidade := FieldByName('nomeresumido').AsString;
           sessao.cidade := FieldByName('cidade').AsString;

       end;
     finally
       FreeAndNil(_db);
     end;

except
  on e: exception do
  Begin
       RegistraLogErro('Logando : '+e.message);
  end;
end;
end;

function TClassLogin.Primeiro_log: Boolean;
var _data : TConexao;
begin
  try
     result := false;
     _data := TConexao.Create;
     with _data.Query do
     Begin
          Close;
          Sql.Clear;
          Sql.Add('select * from ems_pdv ');
          open;

          Result := FieldByName('primeira_sinc').AsString = 'S';
          self.token_remoto := FieldByName('token_remoto').AsString;;

          sessao.estoque_id:= fieldByName('estoque_id').AsInteger;
          sessao.tabela_preco_id:= fieldByName('tabela_preco_id').AsInteger;

     end;
  finally
       FreeAndNil(_data);
  end;
end;

procedure TClassLogin.SetPrimeiroLogFalse;
var _db : TConexao;
begin
 try
   _db := TConexao.Create;
   with _db.Query do
   Begin
        Close;
        Sql.Clear;
        Sql.Add('update ems_pdv set status ='+QuotedStr('N'));
        Sql.Add(' where token_remoto= '+QuotedStr(token_remoto));
        ExecSQL;
   end;
 finally
      FreeAndNil(_db);
 end;
end;

end.

