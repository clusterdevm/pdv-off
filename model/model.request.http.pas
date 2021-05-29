unit model.request.http;

{$mode delphi}{$H+}

interface

uses sysutils, classes, clipbrd, openssl, jsons,db,   zstream,
     Dialogs, fphttpclient, opensslsockets, classe.utils, DataSet.Serialize;

type

TMetodo = (rPost, rGet);

{ TConfHeader }
THeaderItens = Class(TCollectionItem)
     Private
       FCampo: String;
       FValor: String;
     Published
         Property Campo : String       Read FCampo     Write FCampo;
         Property Valor    : String       Read FValor        Write FValor;
End;


{ THeader }

THeader = Class(TCollection)
      private
          function GetItem(Index: Integer): THeaderItens;
      public
          Function Add: THeaderItens;
          Property Item[Index: Integer]: THeaderItens Read GetItem;

end;

{ TRequisicao }

TRequisicao = Class
     Private
       fAutUserName: String;
       fAutUserPass: String;
          FBody: TStringList;
          fendpoint: String;
          fgetID: String;
          FHeader: THeader;
          FMetodo: string;
          fMSg_Erro: String;
          fresponse: string;
          fresponsecode: Integer;
          FReturn: TJsonObject;
          frota: String;
          FtokenBearer: String;
          fwebservice: string;

          function getHost : String;
     Public
         Property webservice : string read fwebservice write fwebservice;
         Property ResponseCode : Integer read fresponsecode write fresponsecode;
         Property Body     : TStringList Read FBody        Write FBody;
         Property Metodo   : string      Read FMetodo      Write FMetodo;
         Property rota     : String      Read frota      Write frota;
         Property endpoint  : String      Read fendpoint      Write fendpoint;
         property tokenBearer : String read FtokenBearer write ftokenBearer;
         Property AutUserName : String read fAutUserName write fAutUserName;
         Property AutUserPass : String read fAutUserPass write fAutUserPass;
         Property Return   : TJsonObject Read FReturn      Write FReturn;
         property response : string read fresponse write fresponse;
         Property Header   : THeader  Read FHeader     Write FHeader;
         property getID : String read fgetID write fgetID;
         Property MSG_Erro : String read fMSg_Erro write Fmsg_erro;

         Function Execute: Boolean;

         procedure JsonToDataSet(aDataSet:TDataSet);
         Procedure AddHeader(campo,value:string);
         Constructor Create;
         Destructor Destroy; Override;
end;

implementation

uses model.request.jsons;

{ THeader }

Function descompactar(aSource : TStream):String;
var _descompacta : Tdecompressionstream;
    StringStream : TStringStream;
Begin
   try
      aSource.Position:= 0;
      _descompacta := Tdecompressionstream.create(aSource);

      StringStream := TStringStream.Create('');
      StringStream.Position := 0;
      StringStream.Size := 0;
      StringStream.CopyFrom(_descompacta, aSource.Size);

      Result := StringStream.DataString;
      RegistraLogErro('documento '+result);
   finally
       FreeAndNil(_descompacta);
   end;
end;

function inflate(gzipfile:TStringStream):string;
var _fileName,_name: string;
    ss : TStringStream;
     gzf : TGZFileStream;
begin
   _name := md5Text(gzipfile.DataString)+formatdatetime('hhmmssddmmyyyy',now);
  _fileName:='./temp/'+_name+'.gzip';

  if not DirectoryExists('./temp/') then
     ForceDirectories('./temp/');

   gzipfile.SaveToFile(_fileName);

   gzf := TGZFileStream.create(_fileName, gzopenread);
   ss := TStringStream.Create('');
try
  ss.CopyFrom(gzf, 0);
  result := ss.DataString;
finally
  ss.Free;
  gzf.Free;
  DeleteFile(_fileName);
end;
end;


function THeader.GetItem(Index: Integer): THeaderItens;
begin
result := inherited Items[Index] as THeaderItens;
end;

function THeader.Add: THeaderItens;
begin
result := inherited Add as THeaderItens
end;

{ TRequisicao }



constructor TRequisicao.Create;
begin
    FMetodo:= 'post';
    FBody     := TStringList.Create;
    FHeader   := THeader.Create(THeaderItens);
    FReturn := TJsonObject.Create;
end;

destructor TRequisicao.Destroy;
begin
  FreeAndNil(FBody);

  if Assigned(Return) then
     FreeAndNil(FReturn);

  inherited;
end;

function TRequisicao.getHost: String;
begin

     if trim(fwebservice) = '' then
        fwebservice := 'https://api-dev.clustererp.com.br/';

     if trim(self.rota) <> '' then
         result := fwebservice +
                   trim(self.rota)+'/'+
                   trim(self.endpoint)
     else
         result := fwebservice +
                   trim(self.endpoint);



     if trim(self.getID) <> '' then
        result := result + self.getID+'/';

end;

function TRequisicao.Execute: Boolean;
var
_Requisicao :  TFPHttpClient;
  _response : TStringStream;
      i : Integer;
      _contentEnconding:string;
Begin
try
  try
     InitSSLInterface();
     _contentEnconding := '';

    _Requisicao := TFPHttpClient.Create(nil);
    _Requisicao.AllowRedirect := true;

    if trim(self.FtokenBearer) <> '' then
       _Requisicao.AddHeader('Authorization', 'Bearer '+trim(Self.tokenBearer));

    _Requisicao.AddHeader('Accept', '*/*');
    _Requisicao.AddHeader('Content-Type', 'application/json');
    _Requisicao.AddHeader('Accept-Encoding','gzip');

    _response := TStringStream.Create('');

    if (AutUserPass <>'') and (AutUserName <>'') then
    Begin
       _Requisicao.UserName  := self.AutUserName;
       _Requisicao.Password  := self.AutUserPass;
    end;

    for i := 0 to Header.Count-1  do
      _Requisicao.AddHeader(Header.Item[i].Campo, Header.Item[i].Valor);

       if self.Metodo = 'post' then
       Begin
          _Requisicao.RequestBody := TStringStream.Create( UTF8Encode(self.Body.Text) );
          _Requisicao.Post(getHost, _response);
       end else
       if self.Metodo = 'delete' then
           _Requisicao.Delete(getHost,_response)
       else
          _Requisicao.Get(getHost,_response);

       result := (_Requisicao.ResponseStatusCode in [200..207]);
       self.ResponseCode:= _Requisicao.ResponseStatusCode;


       for i := 0 to _requisicao.ResponseHeaders.Count-1 do
       Begin
            if LowerCase(copy(_Requisicao.ResponseHeaders[i],1,16))='content-encoding' then
            Begin
               _contentEnconding := trim(copy(_Requisicao.ResponseHeaders[i],18,
                                     Length(_Requisicao.ResponseHeaders[i])));
                break;
            end;
       end;


        if _contentEnconding <> '' then
            fresponse:= inflate(_response)
        else
           fresponse:= _response.DataString;

       if trim(copy(fresponse,1,1)) = '{' then
          Return.Parse(fresponse)
       else
          Return.Put('json_error',fresponse);

except
     on e:Exception do
     Begin
       RegistraLogErro('====================================');
       RegistraLogErro('host '+ getHost);
       //RegistraLogErro('response : '+_response.DataString);
       RegistraLogErro('Error Request : '+e.message);
       RegistraLogErro('teste 2: '+fresponse);
     end;
end;

finally
    FreeAndNil( _Requisicao ) ;
    //FreeAndNil( _response ) ;
end;
end;

procedure TRequisicao.JsonToDataSet(aDataSet: TDataSet);
begin
   aDataSet.LoadFromJSON(jsonToFPJsonArray(Return['resultado'].AsArray.Stringify),false);
end;

procedure TRequisicao.AddHeader(campo, value: string);
begin
Header.Add;
Header.Item[Header.Count-1].Campo := campo;
Header.Item[Header.Count-1].Valor := value;
end;



end.
