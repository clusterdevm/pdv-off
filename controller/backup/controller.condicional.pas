unit controller.condicional;

{$mode delphi}

interface

uses
  Classes, SysUtils, BufDataset, db, jsons, model.request.http,
   Dialogs,crt,wcursos, report.condicional, Clipbrd;

type

{ TCondicional }

TCondicional = Class
  private
    fcliente_id: integer;
    fconclusao: TDateTime;
    femissao: TDateTime;
    fempresa_id: integer;
    fid: Integer;
    fmotivo: string;
    fnome: string;
    foperador_id: integer;
    fstatus: string;
    fvendedor_id: integer;
    F_ProdutoJson: String;
  public
      property id : Integer read fid write fid;
      property nome : string read fnome write fnome;
      property status : string read fstatus write fstatus;
      property empresa_id: integer read fempresa_id write fempresa_id;
      property vendedor_id : integer read fvendedor_id write fvendedor_id;
      property cliente_id : integer read fcliente_id write fcliente_id;
      property operador_id : integer read foperador_id write foperador_id;
      Property motivo : string read fmotivo write fmotivo;
      property emissao : TDateTime read femissao write femissao;
      property conclusao : TDateTime read fconclusao write fconclusao;

      Property _ResponseContent : String Read F_ProdutoJson Write F_ProdutoJson;

      Procedure Filtrar(_query : TDataSet;  _status,_empresa,_emissaoInicial, emissaoFinal,
                        _conclusaoInicial, _conclusaoFinal: string);

      Function FindProduto(_produto : String; _gradeamento : String = '') : Boolean;

      Function registraItem(_produto : String) : Boolean;

      function Iniciar : boolean;
      Procedure get;
      function estorna(_itemID:Integer) : Boolean;

      Function Gravar :  Boolean;
      Function Report : Boolean;

      Procedure Cancelar;
end;



implementation

uses classe.utils, view.condicional;


{ TCondicional }


procedure TCondicional.Filtrar(_query: TDataSet; _status,_empresa,_emissaoInicial, emissaoFinal,
  _conclusaoInicial, _conclusaoFinal: string);
var _body : TJsonObject;
  _Api : TRequisicao;
begin
 try
   WCursor.SetWait;

   _body := TJsonObject.Create;
   _Api := TRequisicao.Create;
   _body.Put('nome_cliente', self.nome);

   with _body['status'].AsArray do
   Begin
       Put(_status);
       if LowerCase(_status) = 'pendente' then
         Put('rascunho');
   end;

   with _body['empresa'].AsArray do
       Put(_empresa);

   if _emissaoInicial <> ''then
      _body.Put('emissao_inicial',FormatDateTime('yyyy-mm-dd', StrToDate(_emissaoInicial)));

   if emissaoFinal <> ''then
      _body.Put('emissao_final',FormatDateTime('yyyy-mm-dd', StrToDate(emissaoFinal)));

   if _conclusaoInicial <> ''then
      _body.Put('conclusao_inicial',FormatDateTime('yyyy-mm-dd', StrToDate(_conclusaoInicial)));

   if _conclusaoFinal <> ''then
      _body.Put('conclusao_final',FormatDateTime('yyyy-mm-dd', StrToDate(_conclusaoFinal)));

   if _query.Active then
      ClearAllRecords(_query);

   with _Api do
   Begin
       Metodo:='post';
       Body.Text:= _body.Stringify;
       tokenBearer := GetBearerEMS;
       webservice := getEMS_Webservice(mCondicional);
       rota:='condicional';
       endpoint:='listar';
       Execute;

       if (ResponseCode in [200..207]) then
          JsonToDataSet(_query)
       else
       Begin
           if _Api.Return.Find('msg') > -1 then
              messagedlg(_Api.Return['msg'].AsString,mterror,[mbok],0)
           else
              messagedlg('#148 Contate suporte: '+_Api.response,mterror,[mbok],0)
       end;
   end;

 finally
   FreeAndNil(_body);
   FreeAndNil(_Api);
   WCursor.SetNormal;
 end;

end;

function TCondicional.FindProduto(_produto: String; _gradeamento : String = ''): Boolean;
var _api : TRequisicao;
begin
  try
    WCursor.SetWait;
    _Api := TRequisicao.Create;
    with _api do
    Begin
        Metodo:='post';
        tokenBearer := GetBearerEMS;
        webservice := getEMS_Webservice(mCondicional);
        rota:='condicional';

        if trim(_gradeamento) <> '' then
           _gradeamento:= '/'+_gradeamento;

        endpoint:=IntTostr(self.id)+'/item/'+_produto+'/search'+_gradeamento;
        Execute();

        result :=  (ResponseCode in [200..207]) ;

        if not result then
           Showmessage(_api.Return['msg'].AsString)
        else
           _ResponseContent := _api.Return['resultado'].Stringify;


    end;
  finally
     WCursor.SetNormal;
     FreeAndNil(_api);
  end;
end;

function TCondicional.registraItem(_produto: String): Boolean;
var _api : TRequisicao;
begin
  try
    WCursor.SetWait;
    _Api := TRequisicao.Create;
    with _api do
    Begin
        Metodo:='post';
        tokenBearer := GetBearerEMS;
        webservice := getEMS_Webservice(mCondicional);
        rota:='condicional';
        endpoint:=IntTostr(self.id)+'/item/'+_produto;
        Execute();

        result :=  (ResponseCode in [200..207]) ;

        if not result then
           Showmessage(_api.Return['msg'].AsString)
        else
           _ResponseContent := _api.Return['resultado'].Stringify;
    end;
  finally
     WCursor.SetNormal;
     FreeAndNil(_api);
  end;
end;

function TCondicional.Iniciar: boolean;
var _api : TRequisicao;
   _body : TjsonObject;
begin
  try
    WCursor.SetWait;
    _api := TRequisicao.Create;
    _body := TJsonObject.Create;
    _body['empresa_id'].AsInteger:= Self.empresa_id;
    _body['vendedor_id'].AsInteger:= Self.vendedor_id;
    _body['cliente_id'].AsInteger:= Self.cliente_id;
    //_body['operador_id'].AsInteger:= Self.operador_id;
    _body['tabela_preco_id'].AsInteger:= Sessao.tabela_preco_id;
    _body['estoque_id'].AsInteger:= Sessao.estoque_id;

    with _api do
    Begin
        Metodo:='post';
        Body.Text:= _body.Stringify;
        tokenBearer := GetBearerEMS;
        webservice := getEMS_Webservice(mCondicional);
        rota:='condicional';
        endpoint:='criar';
        Execute();

        Result := (_api.ResponseCode in [200..207]);

        if Result then
        Begin
              f_condicional := Tf_condicional.Create(nil);
              f_condicional.dadosJson.Assign(_api.Return['resultado'].AsObject);
              WCursor.SetNormal;
              f_condicional.ShowModal;
        end else
           Showmessage(_api.response);
    end;

  finally
    FreeAndNil(_api);
    WCursor.SetNormal;
  end;
end;

procedure TCondicional.get;
var _api : TRequisicao;
begin
  try
    WCursor.SetWait;
    _Api := TRequisicao.Create;
    with _api do
    Begin
        Metodo:='get';
        tokenBearer := GetBearerEMS;
        webservice := getEMS_Webservice(mCondicional);
        rota:='condicional';
        endpoint:='';
        getID := IntToStr(self.id);
        Execute();



        if (_api.ResponseCode in [200..207]) then
        Begin
              f_condicional := Tf_condicional.Create(nil);
              f_condicional.dadosJson.Assign(_api.Return['resultado'].AsObject);
              WCursor.SetNormal;
              f_condicional.ShowModal;
        end else
           Showmessage(_api.response);
    end;
  finally
     FreeAndNil(_api);
     WCursor.SetNormal;
  end;
end;

function TCondicional.estorna(_itemID: Integer): Boolean;
var _api : TRequisicao;
    _aux : String;
begin
  result := false;

  if not InputQuery('Cluster Sistemas', 'Motivo Removação',_aux) then
      exit;

  self.motivo := _aux;

  try
    WCursor.SetWait;
    _Api := TRequisicao.Create;

    with _api do
    Begin
        Metodo:='delete';
        tokenBearer := GetBearerEMS;
        webservice := getEMS_Webservice(mCondicional);
        AddHeader('motivo',self.motivo);
        rota:='condicional';
        endpoint:=IntTostr(self.id)+'/item/'+IntTostr(_itemID);
        Execute();

        result := (ResponseCode in [200..207]);

        if not Result  then
           Showmessage(_api.Return['msg'].AsString)
        else
           _ResponseContent := _api.Return['resultado'].Stringify;
    end;
  finally
     WCursor.SetNormal;
  end;
end;

function TCondicional.Gravar: Boolean;
var _api : TRequisicao;
    f_report : Treport_condicional;
begin
  try
      WCursor.SetWait;
      _Api := TRequisicao.Create;
      with _api do
      Begin
          Metodo:='put';
          tokenBearer := GetBearerEMS;
          webservice := getEMS_Webservice(mCondicional);
          rota:='condicional';
          endpoint:=IntTostr(self.id);
          Execute();

          result := (ResponseCode in [200..207]);

          if not Result  then
             messagedlg(_api.Return['msg'].AsString,mtError,[mbok],0)
          else
              Report;
          end;

      end;
  finally
     WCursor.SetNormal;
     FreeAndNIl(_api);
  end;
end;

function TCondicional.Report: Boolean;
var _api : TRequisicao;
    f_report : Treport_condicional;
begin
  try
      WCursor.SetWait;
      _Api := TRequisicao.Create;
      with _api do
      Begin
          Metodo:='get';
          tokenBearer := GetBearerEMS;
          webservice := getEMS_Webservice(mCondicional);
          AddHeader('kind-report','json');
          rota:='condicional';
          endpoint:='report/'+IntTostr(self.id);
          ExecuteSynapse();

          result := (ResponseCode in [200..207]);

          if not Result  then
             Showmessage(_api.Return['msg'].AsString)
          else
          Begin
              try
                 f_report := Treport_condicional.Create(nil);
                 f_report.GetCondicionalReport(_Api.Return);
              finally
                 FreeAndNIl(f_report);
              end;
          end;
      end;
  finally
     WCursor.SetNormal;
     FreeAndNil(_Api);
  end;
end;

procedure TCondicional.Cancelar;
var _api : TRequisicao;
    _aux : String;
begin

  if not InputQuery('Cluster Sistemas', 'Motivo Cancelamento',_aux) then
      exit;

  self.motivo := _aux;

  try
    WCursor.SetWait;
    _Api := TRequisicao.Create;
    with _api do
    Begin
        Metodo:='delete';
        tokenBearer := GetBearerEMS;
        webservice := getEMS_Webservice(mCondicional);
        AddHeader('motivo',self.motivo);
        rota:='condicional';
        endpoint:=IntTostr(self.id);
        Execute();

        if not (ResponseCode in [200..207])  then
           Showmessage(_api.Return['msg'].AsString);

    end;
  finally
     WCursor.SetNormal;
  end;
end;


end.

