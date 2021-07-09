unit controller.devolucao;

{$mode delphi}

interface

uses
  Classes, SysUtils, jsons, BufDataset, db, Controls, wcursos, report.devolucao,
  Dialogs, clipbrd;

  type

    { TDevolucao }

    TDevolucao = Class
      private
        fativo: Boolean;
        fcredito_id: string;
        FEmissao_final: String;
        FEmissao_inicial: String;
        Fempresa_devolucao: String;
        Fempresa_venda: String;
        FId: Integer;
        fn_cliente: string;
        fn_marca: string;
        fn_operador: string;
        fn_produto: string;
        fn_vendedor: string;
        fObservacao: String;
        fproduto_id: string;
        Ftotal_devolucao: currency;
        Fvenda: TJsonObject;
      public
          Property id : Integer read FId  Write Fid;
          Property emissao_inicial : String  Read FEmissao_inicial  write FEmissao_inicial;
          Property emissao_final : String  Read FEmissao_final  write FEmissao_final;
          Property empresa_venda : String read Fempresa_venda write fempresa_venda;
          Property empresa_devolucao : String read Fempresa_devolucao write fempresa_devolucao;
          property n_vendedor : string read fn_vendedor write fn_vendedor;
          property n_operador : string read fn_operador write fn_operador;
          property n_cliente : string read fn_cliente write fn_cliente;
          property ativo : Boolean read fativo write fativo;
          property credito_id : string read fcredito_id write fcredito_id;
          property produto_id : string read fproduto_id write fproduto_id;
          property n_marca : string read fn_marca write fn_marca;
          property n_produto : string read fn_produto write fn_produto;
          property total_devolucao : currency  read Ftotal_devolucao write fTotal_devolucao;
          Property venda : TJsonObject Read Fvenda Write FVenda;
          Property Observacao : String read fObservacao write FObservacao;

          Procedure Filtrar(_query : TDataSet);
          Procedure Cancelar;
          Procedure Report(_get:boolean = true);

          Function GetVendaDevolucao(_vendaID: string) : Boolean;
          Procedure devolve(_devolve : TJsonObject);
          Procedure Seleciona;
          function Concluir : boolean;

          Constructor Create;
          Destructor Destroy; override;
    end;

implementation

uses model.request.http, ems.utils, view.condicional.criar,
  view.devolucao.selecao;


procedure TDevolucao.Filtrar(_query: TDataSet);
var _body : TJsonObject;
  _Api : TRequisicao;
begin
 try
   WCursor.SetWait;
   _body := TJsonObject.Create;
   _Api := TRequisicao.Create;

   _body.Put('ativo', self.ativo);

   if StrToIntDef(self.credito_id,0) > 0 then
      _body.Put('credito_id', self.credito_id);

   if self.emissao_inicial <> ''then
      _body.Put('emissao_inicial',FormatDateTime('yyyy-mm-dd', StrToDate(self.emissao_inicial)));

   if self.emissao_final <> ''then
      _body.Put('emissao_final',FormatDateTime('yyyy-mm-dd', StrToDate(self.emissao_final)));

   if self.empresa_devolucao <> '' then
   Begin
       with _body['empresa_devolucao'].AsArray do
           Put(self.empresa_devolucao);
   end;

   _body.Put('n_cliente', self.n_cliente);


   if _query.Active then
      ClearAllRecords(_query);

   with _Api do
   Begin
       Metodo:='post';
       Body.Text:= _body.Stringify;
       tokenBearer := GetBearerEMS;
       webservice := getEMS_Webservice(mvenda);
       rota:='vendas/devolucao';
       endpoint:='listar';
       Execute;

       if (ResponseCode in [200..207]) then
       Begin
          JsonToDataSet(_query);
          self.total_devolucao := _api.Return['total'].AsObject['total_devolucao'].AsNumber;
       end
       else
       Begin
           if _Api.Return.Find('msg') > -1 then
              messagedlg(_Api.Return['msg'].AsString,mterror,[mbok],0)
           else
              messagedlg('#149 Contate suporte: '+_Api.response.Text,mterror,[mbok],0)
       end;
   end;

 finally
   FreeAndNil(_body);
   FreeAndNil(_Api);
   WCursor.SetNormal;
 end;
end;

procedure TDevolucao.Cancelar;
var _Api : TRequisicao;
  _aux : string;
begin

 if not InputQuery('Cluster Sistemas', 'Motivo Devolução',_aux) then
    exit;

 try
    WCursor.SetWait;
   _Api := TRequisicao.Create;

   with _Api do
   Begin
       Metodo:='delete';
       tokenBearer := GetBearerEMS;
       webservice := getEMS_Webservice(mvenda);
       rota:='vendas/devolucao/'+IntToStr(self.id);
       AddHeader('motivo',_aux);
       Execute;

       if (ResponseCode in [200..207]) then
          Messagedlg('Cancelamento Efetuado com sucesso',mtInformation,[mbok],0)
       else
       Begin
           if _Api.Return.Find('msg') > -1 then
              messagedlg(_Api.Return['msg'].AsString,mterror,[mbok],0)
           else
              messagedlg('#150 Contate suporte: '+_Api.response.Text,mterror,[mbok],0)
       end;
   end;
 finally
   FreeAndNil(_Api);
   WCursor.SetNormal;
 end;
end;

procedure TDevolucao.Report(_get:boolean = true);
var _Api : TRequisicao;
begin
    if _get then
    Begin
       try
         _api := TRequisicao.Create;
         WCursor.SetWait;
         with _Api do
         Begin
             Metodo:='get';
             tokenBearer := GetBearerEMS;
             AddHeader('kind-report','json');
             webservice := getEMS_Webservice(mvenda);
             rota:='vendas/devolucao';
             endpoint:=IntToStr(self.id)+'/report';
             ExecuteSynapse;

             if (ResponseCode in [200..207]) then
                self.venda.Parse(_api.Return.Stringify)
             else
             Begin
                 if _Api.Return.Find('msg') > -1 then
                    messagedlg(_Api.Return['msg'].AsString,mterror,[mbok],0)
                 else
                    messagedlg('#150 Contate suporte: '+_Api.response.Text,mterror,[mbok],0)
             end;
         end;
         finally
             FreeAndNil(_api);
             WCursor.SetNormal;
         end;
    end;

    try
       f_devolucaoReport := Tf_devolucaoReport.Create(nil);
       f_devolucaoReport.GetDevolucaoReport(self.venda);
    finally
       f_devolucaoReport.Release;
       f_devolucaoReport := nil;
    end;
end;

function TDevolucao.GetVendaDevolucao(_vendaID: string): Boolean;
var _Api : TRequisicao;
begin
 if trim(_vendaID) = '' then
    exit;
 try
    WCursor.SetWait;
   _Api := TRequisicao.Create;

   with _Api do
   Begin
       Metodo:='get';
       Result :=false;
       tokenBearer := GetBearerEMS;
       webservice := getEMS_Webservice(mvenda);
       AddHeader('protocolo',self.venda['protocolo'].AsString);
       rota:='vendas/devolucao';
       endpoint:='venda/'+_vendaID;
       ExecuteSynapse;

       if (ResponseCode in [200..207]) then
       Begin
          result := true;
          self.venda.Parse(_api.Return['resultado'].AsObject.Stringify);
       end
       else
       Begin
           if _Api.Return.Find('msg') > -1 then
              messagedlg(_Api.Return['msg'].AsString,mterror,[mbok],0)
           else
              messagedlg('#150 Contate suporte: '+_Api.response.Text,mterror,[mbok],0)
       end;
   end;

 finally
   FreeAndNil(_Api);
   WCursor.SetNormal;
 end;
end;

procedure TDevolucao.devolve(_devolve: TJsonObject);
var _Api : TRequisicao;
begin
 try
    WCursor.SetWait;
   _Api := TRequisicao.Create;

   _devolve['protocolo'].AsString:= self.venda['protocolo'].AsString;
   _devolve['venda_id'].AsInteger:= self.venda['id'].AsInteger;

   with _Api do
   Begin
       Metodo:='post';
       tokenBearer := GetBearerEMS;
       Body.Text:= _devolve.Stringify;
       webservice := getEMS_Webservice(mvenda);
       rota:='vendas/devolucao';
       endpoint:='item';
       Execute;

       if (ResponseCode in [200..207]) then
          self.venda.Parse(_api.Return['resultado'].AsObject.Stringify)
       else
       Begin
           if _Api.Return.Find('msg') > -1 then
              messagedlg(_Api.Return['msg'].AsString,mterror,[mbok],0)
           else
              messagedlg('#150 Contate suporte: '+_Api.response.Text,mterror,[mbok],0)
       end;
   end;
 finally
   FreeAndNil(_Api);
   WCursor.SetNormal;
 end;
end;

procedure TDevolucao.Seleciona;
begin
   f_devolucaoSeleciona := Tf_devolucaoSeleciona.Create(nil);
   f_devolucaoSeleciona.SetLayout(Self);
   f_devolucaoSeleciona.ShowModal;
   f_devolucaoSeleciona.Release;
   f_devolucaoSeleciona := nil;
end;

function TDevolucao.Concluir : boolean;
var _Api : TRequisicao;
     _content : TJsonObject;
begin

 try
    WCursor.SetWait;
    result := false;
   _Api := TRequisicao.Create;
   _content := TJsonObject.Create();
   _content.Put('protocolo',self.venda['protocolo'].AsString);
   _content.Put('venda_id',self.venda['id'].AsString);
   _content.put('obs',self.Observacao);

   with _Api do
   Begin
       Metodo:='post';
       Result :=false;
       tokenBearer := GetBearerEMS;
       body.Text:= _content.Stringify;
       webservice := getEMS_Webservice(mvenda);
       rota:='vendas/devolucao';
       Execute;

       if (ResponseCode in [200..207]) then
       Begin
          result := true;
          self.venda.Parse(_api.Return.Stringify);
          Report(false);
       end
       else
       Begin
           if _Api.Return.Find('msg') > -1 then
              messagedlg(_Api.Return['msg'].AsString,mterror,[mbok],0)
           else
              messagedlg('#150 Contate suporte: '+_Api.response,mterror,[mbok],0)
       end;
   end;

 finally
   FreeAndNil(_Api);
   FreeAndNil(_content);
   WCursor.SetNormal;
 end;
end;

constructor TDevolucao.Create;
begin
   Fvenda := TJsonObject.Create();
end;

destructor TDevolucao.Destroy;
begin
 FreeAndNil(Fvenda);
  inherited Destroy;
end;

end.

