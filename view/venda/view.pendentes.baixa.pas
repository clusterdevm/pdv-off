unit view.pendentes.baixa;

{$mode delphi}

interface

uses
  Classes, SysUtils, BufDataset, DB, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, ActnList, DBGrids, jsons;

type

  { Tf_pendente }

  Tf_pendente = class(TForm)
    ac_sair: TAction;
    ac_liquidar: TAction;
    ActionList1: TActionList;
    ds: TDataSource;
    qry: TBufDataset;
    Button1: TButton;
    DBGrid1: TDBGrid;
    Panel1: TPanel;
    qrybaixar: TBooleanField;
    qrydata_emissao: TDateTimeField;
    qrydocumento: TStringField;
    qrymodelo: TStringField;
    qryn_cliente: TStringField;
    qryn_meio_pagamento: TStringField;
    qryn_vendedor: TStringField;
    qryvalor: TFloatField;
    qryvenda_id: TLongintField;
    procedure ac_liquidarExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
        Procedure Listar;
  public

  end;

var
  f_pendente: Tf_pendente;

implementation

{$R *.lfm}

uses model.request.http, ems.utils;

procedure Tf_pendente.FormShow(Sender: TObject);
begin
     qry.CreateDataset;
     qry.Open;
     Listar;
end;

procedure Tf_pendente.ac_liquidarExecute(Sender: TObject);
var _content : TJsonObject;
     _api : TRequisicao;
begin
    try
       _content := TJsonObject.Create();
       _api := TRequisicao.Create;
       _content['liquidacoes'].AsArray;

       qry.DisableControls;
       qry.First;
       while not qry.EOF do
       Begin
            if qrybaixar.Value then
            Begin
                  with _content['vendas'].AsArray do
                     Put(qryvenda_id.AsInteger);
            end;
            qry.Next;
       end;

       _content['caixa_id'].AsInteger:= sessao.GetCaixaID;

       with _api do
       Begin
           Metodo:='get';
           Body.Text:= _content.Stringify;
           tokenBearer := GetBearerEMS;
           webservice := getEMS_Webservice(mFinanceiro);
           rota:='financeiro/checkout';
           endpoint:='liquidar_vendas';
           Execute(false);
       end;

       if not ( _api.ResponseCode in [200..207]) then
          messagedlg(_api.response.Text,mtError,[mbOK],0);

    finally
       qry.First;
       qry.EnableControls;
       freeAndNIl(_api);
       FreeAndNil(_content);
    end;
end;

procedure Tf_pendente.Listar;
var _api : TRequisicao;
     _item : TJSONObject;
     i : Integer;
begin
  try
    WCursor.SetWait;
    _Api := TRequisicao.Create;
    with _api do
    Begin
        Metodo:='get';
        tokenBearer := GetBearerEMS;
        webservice := getEMS_Webservice(mFinanceiro);
        rota:='financeiro/checkout';
        endpoint:='listagem_baixa';
        ExecuteSynapse;

        if (_api.ResponseCode in [200..207]) then
        Begin
              qry.Close;
              qry.Open;

              for i := 0  to _api.Return['resultado'].AsArray.Count-1 do
              Begin
                   _item := _api.Return['resultado'].AsArray.Items[i].AsObject;
                   qry.Append;;
                   qrybaixar.Value:= false;
                   qrydata_emissao.Value:= sessao.DateToLocal(_item['data_emissao'].AsString);
                   qryn_cliente.Value:= _item['n_cliente'].AsString;
                   qryn_vendedor.Value:= _item['n_vendedor'].AsString;
                   qryvalor.Value:= _item['valor'].AsNumber;
                   qryvenda_id.Value:= _item['venda_id'].AsInteger;
                   qrydocumento.Value:= _item['documento'].AsString;
                   qryn_meio_pagamento.Value:= _item['n_meio_pagamento'].AsString;
                   qrymodelo.Value:= _item['modelo'].AsString;
                   qry.Post;
              end;

              if qry.IsEmpty then
                messagedlg('Nenhum Registro Encontrado',mtWarning,[mbok],0);
        end else
           Showmessage(_api.response.Text);
    end;
  finally
     FreeAndNil(_api);
     WCursor.SetNormal;
  end;
end;

end.

