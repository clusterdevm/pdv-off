unit ems.utils;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, ems.conexao, Dialogs, md5, process, Graphics,
  controls, StdCtrls, Forms, TypInfo, DateUtils, db, cluster_pdv.sessao,
  wcursos,BufDataset, math, jsons, ACBrInStore;

type
  TPathServicos = (mAutenticacao, mCondicional, mGeral, mPDV, mFinanceiro, mvenda);

const canal_token = '9b1b6b2dfcb8d4c13d4d7fcacd9aed78';
const appPDV = true;

var Sessao : TSessao;
    _sessao : TSessao;
    //f_wait : TWaitProcess;
    WCursor : TWaitCursor;
    appVersao : string;
    appProducao : boolean;
    GSincronizar : boolean;
    _response : TjsonObject;
    _status : Integer;

  function md5Text(value:string):String;
  function bioswindows : String;

  Procedure setOnEnter(form:TForm);
  procedure OnEntrar(Sender: TObject);
  procedure OnSair(Sender: TObject);
  Function FlagBoolean(value:string):String;
  Procedure RegistraLogErro(value:string; _fileName : string = '');
  Procedure RegistraLogRequest(value:string);

  function DownloadAtualizacao(var versao:string) :  boolean;


  Function getDataUTC : String;
  function prepara_valor(value: double): String;
  function FlagBool(value: Boolean): String;
  Function SubsString(text,old_value, new_value : string):String;
  function RemoveAcento( str: string): string;
  procedure _saveDebug(_text,_file:string);
  function getEMS_Webservice(value:TPathServicos): string;
  procedure ClearAllRecords(ADataset: TDataset);
  function GetBearerEMS:String;

  function GetData(value:string):TDateTime;
  Function getDataTimeZone(value : TDateTime):String;overload;
  Function getDataTimeZone(value : string) :  String;overload;

  Function getDataBanco(value : string):TDateTime;


  function FormataCNPJ(CNPJ: string): string;
  function RemoveIfens(value: string): String;

  Function Get_UUID : String;
  Function GetFloat(value:string) : Extended;
  Function ToValor(value:string) : Extended;
  Procedure Limpa(aDataSet:TBufDataset);
  function getNumeros(fField : String): String;
  Procedure CriarForm(NomeForm: TFormClass; _fullScream : Boolean = false);

  function GetAliquota(valor, desconto : double) : double;
  function GetValorAliquota(valor, aliquota: double):Double;

  function Decimal(Value: Extended; Decimals: Integer  = -1): Extended;
  function DecimalUnitario(Value: Extended; Decimals: Integer = -1): Extended;
  function DecimalQuantidade(Value: Extended; Decimals: Integer = -1): Extended;

  Procedure FinalizaProcesso(msg:string;_local : string = '' ; status_http : Integer = 500);

  procedure SeparaQuantidade(var _Codigo: String;var quantidade :Double);
  Procedure GetDadosBalanca(scodigo : String; var CodProduto : String ; var quantidade:double;var _BalancaValor : boolean);

implementation

uses model.request.http, uf_download, form.principal;

Procedure GetDadosBalanca(scodigo : String; var CodProduto : String ; var quantidade:double;var _BalancaValor : boolean);
var ACBrInStore : TACBrInStore;
Begin
try
  // Define a mascara do c??digo de barra da balan??a, e j?? acha o prefixo
  // Guardando na propriedade Prefixo.
  ACBrInStore := tACBrInStore.Create(nil);
  ACBrInStore.Codificacao := sessao.PDV_ConfBalanca;

  codProduto := scodigo;
  quantidade := 1;
  _BalancaValor := false;

  // Checa se o c??digo da balan??a tem 13 digitos
  if Length(scodigo) = 13 then
  begin
     // Verifica se o prefixo encontrado na mascara ?? igual ao
     // prefixo do c??digo de barra que veio da balan??a
     // Atendendo a essas situa????es isso quer dizer que o c??digo recebido ??
     // um c??digo gerado pela balan??a.
     if ACBrInStore.Prefixo = Copy(scodigo, 1, Length(ACBrInStore.Prefixo)) then
     begin
        ACBrInStore.Desmembrar(scodigo);

        //edtPrefixo.Text := ACBrInStore1.Prefixo;
        CodProduto  := ACBrInStore.Codigo;
        if ACBrInStore.Peso > 0 then
        Begin
            quantidade  :=  ACBrInStore.Peso;

        end
        else
        Begin
            quantidade := ACBrInStore.Total;
            _BalancaValor := true;
        end;

     end;

//     Showmessage(FloatToStr(quantidade));
     end;
finally
    FreeAndNil(ACBrInStore);
end;
end;

procedure SeparaQuantidade(var _Codigo: String;var quantidade :Double);
Var
  I: Integer;
  Valido: Boolean;
  sQtde: String;
  vMultiplicador: Boolean;
  _BalancaValor : boolean;
begin
  _Codigo := UpperCase(_Codigo);

  quantidade := 1;

  Valido := false;

  vMultiplicador := false;

  if (Pos('*', _Codigo) > 0) or (Pos('X', _Codigo) > 0) then
  begin
    vMultiplicador := true;
    IF (Pos('*', _Codigo) > 0) Then
      sQtde := Copy(_Codigo, 01, Pos('*', _Codigo) - 01)
    else
      sQtde := Copy(_Codigo, 01, Pos('X', _Codigo) - 01);
    Valido := true;

    for I := 1 to Length(sQtde) do
      if Pos(sQtde[I], ',0123456789') <= 0 then
        Valido := false;
    if Valido then
      IF (Pos('*', _Codigo) > 0) Then
        _Codigo := Copy(_Codigo, Pos('*', _Codigo) + 01, 20)
      ELSE
        _Codigo := Copy(_Codigo, Pos('X', _Codigo) + 01, 20);

    quantidade := StrToFloatDef(sQtde, 1);

  end;


  if Length(_Codigo) > 12 then
    if (Copy(_Codigo, 1, 1) = '2') and (not Valido) then // quando for balanca
       GetDadosBalanca(_Codigo, _codigo, Quantidade, _BalancaValor)

end;



function DecimalUnitario(Value: Extended; Decimals: Integer): Extended;
begin
  if Decimals =-1 then
     Decimals := sessao.TotalCasasUnitario;

  result :=  Decimal(Value, Decimals);
end;

function DecimalQuantidade(Value: Extended; Decimals: Integer): Extended;
begin
  if Decimals =-1 then
     Decimals := sessao.TotalCasasQuantidade;

  result :=  Decimal(Value, Decimals);
end;

function Decimal(Value: Extended; Decimals: Integer  = -1): Extended;
var
  Factor, Fraction: Extended;
begin
  if Decimals = -1 then
    Decimals:= sessao.TotalCasasDecimal;

  Factor := IntPower(10, Decimals);
  Value := StrToFloat(FloatToStr(Value * Factor));
  Result := Int(Value);
  Fraction := Frac(Value);
  if Fraction >= 0.5 then
    Result := Result + 1
  else
    if Fraction <= -0.5 then
      Result := Result - 1;
  Result := Result / Factor;
end;

procedure FinalizaProcesso(msg:string;_local : string = '' ; status_http : Integer = 500);
begin
     Messagedlg(msg,mtError,[mbok],0);
     abort;
end;

function getNumeros(fField : String): String;
var
  I : Byte;
begin
   Result := '';
   for I := 1 To Length(fField) do
       if fField [I] In ['0'..'9'] Then
            Result := Result + fField [I];
end;


procedure CriarForm(NomeForm: TFormClass; _fullScream : Boolean = false);
var
  form: TForm;
begin
  try
     form := NomeForm.Create(nil);
     form.BorderStyle := bsSizeable;
     form.BorderIcons:= form.BorderIcons-[biMinimize];
     form.Position := poScreenCenter;
     form.ShowModal;
  finally
    form.release;
    Form :=nil;
  end;
end;

function RemoveIfens(value: string): String;
begin
   Result := SubsString(value,'-','');
   Result := SubsString(Result,'"','');
   Result := SubsString(Result,'.','');
   Result := SubsString(Result,',','');
   Result := SubsString(Result,'/','');
end;

function Get_UUID: String;
var _out : TGuid;
    res : Integer;
begin
  res := CreateGUID(_out);
  Result := (GUIDToString(_out))
end;

function GetFloat(value: string): Extended;
begin
  //value := SubsString(value,',','.');
  result := StrToFloat(value);
end;


function FormataCNPJ(CNPJ: string): string;
begin
  cnpj := RemoveIfens(cnpj);

  Result :=Copy(CNPJ,1,2)+'.'+Copy(CNPJ,3,3)+'.'+Copy(CNPJ,6,3)+'/'+

    Copy(CNPJ,9,4)+'-'+Copy(CNPJ,13,2);

end;

procedure ClearAllRecords(ADataset: TDataset);
begin
  ADataset.DisableControls;
  try
    ADataset.First;
    while not ADataset.EoF do
      ADataset.Delete;
  finally
    ADataset.EnableControls;
  end;
end;

function GetBearerEMS:String;
var _api : TRequisicao;
begin
   if sessao.bearerems= '' then
   Begin
       _api:= TRequisicao.Create;
       _api.webservice := getEMS_Webservice(mAutenticacao);
       _api.AutUserName := sessao.usuario;
       _api.AutUserPass := sessao.senha;
       _api.AddHeader('empresa-id',IntToStr(sessao.empresalogada));
       _api.AddHeader('canal-token',canal_token);
       _api.Metodo:= 'get';
       _api.rota := 'autenticacao';
       _api.endpoint := 'token/';
       _api.Execute();


       if (_api.ResponseCode in [200..207]) then
           sessao.bearerems:= _api.Return['token'].AsString
       else
       Begin
           RegistraLogErro('Erro: Linha 129 '+_api.response.Text);
           Showmessage('Erro Checar Arquivo de Log');
       end;
  end;
   Result := sessao.bearerems;

end;

function GetData(value: string): TdateTime;
var
   aux : String;
begin
   aux := copy(value,9,2);
   aux := aux + '/'+copy(value,6,2)+'/';
   aux := aux + copy(value,1,4);
   aux := aux + copy(value,11,8);
   result := StrToDateTime(aux);
end;

function getDataTimeZone(value: TDateTime): String;
begin
 Result := DateToISO8601(value);
end;

function getDataTimeZone(value: string): String;
begin
    if value = '' then
    Begin
        Result := '';
        exit
    end;

    try
       result := getDataTimeZone(ISO8601ToDate(value));
    except
        Result := '';
    end;
end;

function getDataBanco(value: string): TDateTime;
begin
  result := ISO8601ToDate(value);
end;


procedure OnEntrar(Sender: TObject);
var
  Prop: PPropInfo;
begin
  Prop := GetPropInfo(Sender, 'Color');
  if (Assigned(Prop)) then
  begin
    SetPropValue(Sender, 'Color', clWindow);
  end;
end;

procedure OnSair(Sender: TObject);
var
  Prop: PPropInfo;
begin
  Prop := GetPropInfo(Sender, 'Color');
  if (Assigned(Prop)) then
  begin
    SetPropValue(Sender, 'Color', clGradientActiveCaption);
  end;
end;

function FlagBoolean(value: string): String;
begin
   result := trim(LowerCase(value));
end;

procedure RegistraLogErro(value: string; _fileName : string = '');
var _text : TStringList;
    _diretorio,_file : String;
begin
  try
     _text := TStringList.Create;
     _diretorio := extractfiledir(paramstr(0));// ExtractFileDir(ApplicationName);

     if _fileName = '' then
       _fileName := 'log.txt'
     else
        _fileName := _fileName+'.txt';

     {$IFDEF MSWINDOWS}
        _file := _diretorio+'\'+_fileName;
     {$else}
        _file := _diretorio+'/'+_file;;
     {$ENDIF}

     if FileExists(_file) then
        _text.LoadFromFile(_file);

     _text.Add(formatdatetime('dd-mm-yyyy hh:mm:ss',now)+' '+value);

     _text.SaveToFile(_file);
  finally
     FreeAndNil(_text);
  end;
end;

procedure RegistraLogRequest(value: string);
var _text : TStringList;
    _diretorio,_file : String;
begin
  try
     _text := TStringList.Create;
     _diretorio := extractfiledir(paramstr(0));// ExtractFileDir(ApplicationName);

     {$IFDEF MSWINDOWS}
        _file := _diretorio+'\log_request.txt';
     {$else}
        _file := _diretorio+'/log_request.txt';
     {$ENDIF}

     if FileExists(_file) then
        _text.LoadFromFile(_file);

     _text.Add(formatdatetime('dd-mm-yyyy hh:mm:ss',now)+' '+value);

     _text.SaveToFile(_file);
  finally
     FreeAndNil(_text);
  end;

end;

function DownloadAtualizacao(var versao: string): boolean;
var _api : TRequisicao;
begin
  try
     _api := TRequisicao.Create;
     _api.AddHeader('canal-token',canal_token);
     _api.webservice:= getEMS_Webservice(mAutenticacao);
     _api.Metodo:='get';
     _api.rota:='autenticacao/versao';
     _api.ExecuteSynapse;

     Result := false;

       if _api.ResponseCode in [200..207] then
       Begin
            if versao <> _api.Return['resultado'].AsObject['versao'].AsString then
            Begin
               f_download := Tf_download.Create(nil);
               f_download.Sucesso:= false;
               f_download.ShowModal;
               Result := f_download.Sucesso;
               f_download.release;
               f_download.Free;
            end;

            if result then
               versao := _api.Return['resultado'].AsObject['versao'].AsString;
       end;
  finally
      FreeAndNil(_api);
  end;
end;

function getDataUTC: String;
begin
  Result := DateToISO8601(LocalTimeToUniversal(now));
end;

function prepara_valor(value: double): String;
var aux:string;
begin
       if value > 500000000 then
          value := 0
       else
          aux:=formatfloat('#0.0000000',(value));

       aux:=SubsString(aux,',','.');
       result:=aux;

       if result = '' then
          result := '0';


       if Length(result) > 17 then
          result := '0';
end;

function FlagBool(value: Boolean): String;
begin
 if value then
    result := 'true'
 else
    result := 'false';
end;

function SubsString(text, old_value, new_value: string): String;
begin
 Result:=  stringReplace(text , old_value, new_value ,[rfReplaceAll, rfIgnoreCase]);
end;

function RemoveAcento(str: string): string;
const
  AccentedChars :array[0..25] of string =
                 ('??','??','??','??','??','??','??','??','??','??','??','??','??',
                  '??','??','??','??','??','??','??','??','??','??','??','??','??');
  NormalChars :array[0..25] of string =
                 ('a','a','a','a','a','e','e','e','e','i','i','i','i',
                  'o','o','o','o','o','u','u','u','u','c','n','y','y');
var
   i: Integer;
begin
   Result := str;
   for i := 0 to 25 do
      Result := StringReplace(Result, AccentedChars[i], NormalChars[i], [rfReplaceAll]);
end;

procedure _saveDebug(_text, _file: string);
var _save : TStringList;
begin
  try
     _save := TStringList.Create;
     _save.Text:=_text;
     _save.SaveToFile('/home/log_webservice/'+_file+'.txt');
  finally
     FreeAndNil(_save);
  end;
end;

function GetAliquota(valor, desconto: double) : double;
begin
try
     result := desconto / valor;
     result := result * 100;
except
   result := 0
end;
end;


function GetValorAliquota(valor, aliquota: double): Double;
begin
try
    result := aliquota * valor;
    result := result / 100;
except
   result := 0
end;
end;

function getEMS_Webservice(value:TPathServicos): string;
begin

 //case value of
 //  mGeral :
 //     result := 'http://localhost/api/v1/';
 //  mCondicional :
 //     result := 'http://localhost/api/v1/';
 //  mAutenticacao :
 //     result := 'http://localhost/api/v1/';
 //  mPDV :
 //     result := 'http://localhost/api/v1/cadastro/';
 //  mFinanceiro :
 //     result := 'http://localhost/api/v1/';
 //  mVenda :
 //     result := 'http://localhost/api/v1/';
 //end;
 //
 //  exit;
   if appProducao then
   Begin
    case value of
      mGeral :
         result := 'https://api.clustererp.com.br/api/v1/';
      mCondicional :
         result := 'https://api.clustererp.com.br/api/v1/';
      mAutenticacao :
         result := 'https://api.clustererp.com.br/api/v1/';
      mPDV :
         result := 'https://api.clustererp.com.br/api/v1/cadastro/';
      mFinanceiro :
         result := 'https://api.clustererp.com.br/api/v1/';
      mVenda :
         result := 'https://api.clustererp.com.br/api/v1/';
    end;
   end else
   Begin
     case value of
       mGeral :
          result := 'https://api-dev.clustererp.com.br/api/v1/';
       mCondicional :
          result := 'https://api-dev.clustererp.com.br/api/v1/';
       mAutenticacao :
          result := 'https://api-dev.clustererp.com.br/api/v1/';
       mPDV :
          result := 'https://api-dev.clustererp.com.br/api/v1/cadastro/';
          //result := 'http://localhost/api/v1/cadastro/';
       mFinanceiro :
          result := 'https://api-dev.clustererp.com.br/api/v1/';
       mVenda :
          //result := 'http://localhost/api/v1/';
          result := 'https://api-dev.clustererp.com.br/api/v1/';
     end;
   end;
end;

function ToValor(value: string): Extended;
begin
//
//  {$IFDEF MSWINDOWS}
//      //value := SubsString(value,',','.');
//  {$else}
//      value := SubsString(value,',','.');
//  {$ENDIF}


   Result := strToFloat(value);
//   TryStrToFloat(value, result);
end;

Procedure Limpa(aDataSet:TBufDataset);
Begin

   aDataSet.Close;
   aDataSet.Open;
   //try
   //    aDataSet.DisableControls;
   //    while not aDataSet.eof do
   //        aDataSet.Delete;
   //finally
   //   aDataSet.EnableControls;
   //end;
end;

function bioswindows : String;
var
  AProcess: TProcess;
  info : TStringList;
begin
 try
  AProcess := TProcess.Create(nil);
  info := TStringList.Create;
  AProcess.Executable := 'wmic';
  AProcess.Parameters.Add('bios');
  AProcess.Parameters.Add('get');
  AProcess.Parameters.Add('serialnumber');
  AProcess.Options := AProcess.Options + [poWaitOnExit, poUsePipes];
  AProcess.ShowWindow := swoHIDE;
  AProcess.Execute;
  info.LoadFromStream(AProcess.Output);
  Result := info.text;
  finally
     FreeAndNil(AProcess);
     FreeAndNil(info);
  end;
end;


procedure setOnEnter(form: TForm);
var
   i:integer;
begin
{     for i:=0 to form.ComponentCount-1 do
     begin
          if (form.Components[i]).ClassType = TEdit then
          Begin
            if (form.Components[i] as TEdit).Tag = 0 then
            Begin
                (form.Components[i] as TEdit).OnEnter:= OnEntrar;
                (form.Components[i] as TEdit).OnExit:= @OnSair;
            end;
          end;
     end;  }
end;

function md5Text(value: string): String;
begin
   Result := MD5Print(MD5String(value));
end;




end.

