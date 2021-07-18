unit report.dav;

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, RLReport, RLBarcode;

type

  { Tf_DavReport }

  Tf_DavReport = class(TForm)
    bandCabecalho: TRLBand;
    bandCLiente: TRLBand;
    bandInfReport: TRLBand;
    bandItens: TRLBand;
    bandItensCabecalho: TRLBand;
    bandRodape: TRLBand;
    bandTotal: TRLBand;
    lblData: TRLLabel;
    lCliente: TRLMemo;
    lClienteDocumento: TRLMemo;
    lClienteEndereco: TRLMemo;
    lClienteTelefone: TRLMemo;
    lDesconto: TRLLabel;
    lDescricao: TRLMemo;
    lDocumento: TRLLabel;
    lEmissao: TRLLabel;
    lEndereco: TRLMemo;
    lFrete: TRLLabel;
    lICMSSt: TRLLabel;
    lIPI: TRLLabel;
    lLABEL: TRLLabel;
    lNomeFantasia: TRLMemo;
    lOutros: TRLLabel;
    lProdutoCodigo: TRLLabel;
    lQuantidade: TRLLabel;
    lRazaoSocial: TRLMemo;
    lSistema: TRLLabel;
    lSistema1: TRLLabel;
    lSubtotal: TRLLabel;
    lTelefone: TRLMemo;
    lTotal: TRLLabel;
    lTotalItens: TRLMemo;
    lTotalProdutos: TRLLabel;
    lUnidade: TRLMemo;
    lVendedor: TRLMemo;
    pnlData: TRLPanel;
    pnlTotalDesconto: TRLPanel;
    pnlTotalFrete: TRLPanel;
    pnlTotalGeral: TRLPanel;
    pnlTotalOutros: TRLPanel;
    pnlTotalProdutos: TRLPanel;
    qrCode: TRLBarcode;
    RLLabel1: TRLLabel;
    RLLabel10: TRLLabel;
    RLLabel11: TRLLabel;
    RLLabel14: TRLLabel;
    RLLabel16: TRLLabel;
    RLLabel2: TRLLabel;
    RLLabel28: TRLLabel;
    RLLabel3: TRLLabel;
    RLLabel30: TRLLabel;
    RLLabel4: TRLLabel;
    RLLabel5: TRLLabel;
    RLLabel6: TRLLabel;
    RLLabel7: TRLLabel;
    RLLabel8: TRLLabel;
    RLMemo1: TRLMemo;
    RLPanel1: TRLPanel;
    RLPanel2: TRLPanel;
    RLPanel3: TRLPanel;
    RLPanel4: TRLPanel;
    RLPanel5: TRLPanel;
    RLPanel6: TRLPanel;
    RLReport1: TRLReport;
    subItens: TRLSubDetail;
    procedure subItensNeedData(Sender: TObject; var MoreData: Boolean);
  private
    _rowItens  : Integer;
    _totalItens : Currency;
  public
      Procedure GetReport(_content : TJsonObject);
  end;

var
  f_DavReport: Tf_DavReport;

implementation

{$R *.lfm}

{ Tf_DavReport }

procedure Tf_DavReport.GetReport;
var _report : TRLReport;
begin
  try
    _rowItens := 1;
    _totalItens := 0;
    _Objeto['modelo'].AsString := lowerCase(_Objeto['modelo'].AsString);

    if _Objeto['modelo'].AsString = 'padrao' then
    Begin
       RLReport1.PageBreaking := pbNone;
       RLReport1.PageSetup.PaperSize   := fpCustom ;
       RLReport1.UnlimitedHeight:= true;
       _report := RLReport1;
    end
    else
    if _Objeto['modelo'].AsString = 'matricial' then
    Begin

    end
    else
    if _Objeto['modelo'].AsString = 'a4' then
    Begin
       _report := RLReport1
    end
    else
    if _Objeto['modelo'].AsString = 'espelho' then
    Begin
       _report := RLReport1
    end
    else
         FinalizaRequisicao('Modelo não informado','Dav GetReport');

    _report.prepare;
    _report.SaveToFile(_JWT.FileName);
  except
     on e:Exception do
     Begin
         RegistraLogErro('GetReport: Dav:'+e.Message);
     End;
  end;
end;

procedure Tf_DavReport.subItensNeedData(Sender: TObject; var MoreData: Boolean);
begin
  MoreData:= _rowItens <= _Objeto['itens'].AsArray.Count;
end;

procedure Tf_DavReport.GetReport(_content: TJsonObject);
begin

end;

end.

