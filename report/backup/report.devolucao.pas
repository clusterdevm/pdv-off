unit report.devolucao;

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, RLReport, RLBarcode,
  RLPDFFilter, jsons;

type

  { Tf_devolucaoReport }

  Tf_devolucaoReport = class(TForm)
    bandCabecalho: TRLBand;
    BandHeader: TRLBand;
    bandInfoCondicional: TRLBand;
    bandRodape: TRLBand;
    bandSumary: TRLBand;
    lblcodigo4: TRLLabel;
    lblCodigoFaturado: TRLLabel;
    lblCondicionalID: TRLLabel;
    lblDadosCliente: TRLMemo;
    lblDadosVendedor: TRLMemo;
    lblData: TRLLabel;
    lblDescricao5: TRLLabel;
    lblDescricaoFaturado: TRLLabel;
    lblEmissao: TRLLabel;
    lblItensFaturado: TRLLabel;
    lblSubTotalFaturado: TRLLabel;
    lblValor5: TRLLabel;
    lblValorFaturado: TRLLabel;
    lDadosVenda: TRLMemo;
    lEndereco: TRLMemo;
    lNomeFantasia: TRLMemo;
    lRazaoSocial: TRLMemo;
    lSistema: TRLLabel;
    lSistema1: TRLLabel;
    lTelefone: TRLMemo;
    lUnidade: TRLMemo;
    qrCode: TRLBarcode;
    RLBand5: TRLBand;
    RLLabel1: TRLLabel;
    RLLabel11: TRLLabel;
    RLLabel12: TRLLabel;
    RLLabel28: TRLLabel;
    RLLabel29: TRLLabel;
    RLLabel3: TRLLabel;
    RLLabel30: TRLLabel;
    RLMemo1: TRLMemo;
    RLPanel1: TRLPanel;
    RLPanel4: TRLPanel;
    RLPDFFilter1: TRLPDFFilter;
    RLReport1: TRLReport;
    procedure bandCabecalhoBeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure bandInfoCondicionalBeforePrint(Sender: TObject;
      var PrintIt: Boolean);
    procedure bandRodapeBeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure RLBand5BeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure RLPanel4BeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure RLReport1NeedData(Sender: TObject; var MoreData: Boolean);
  private
       _objeto : TJsonObject;
         _valor, _quantidade : Double;
       _rowItens : Integer;
  public
        Procedure GetDevolucaoReport(_dados:TJsonObject);
  end;

var
  f_devolucaoReport: Tf_devolucaoReport;

implementation

{$R *.lfm}

uses classe.utils;

procedure Tf_devolucaoReport.RLReport1NeedData(Sender: TObject;
  var MoreData: Boolean);
begin
  MoreData:= _rowItens < _Objeto['itens'].AsArray.Count;
end;

procedure Tf_devolucaoReport.RLPanel4BeforePrint(Sender: TObject;
  var PrintIt: Boolean);
begin
  lblItensFaturado.Caption := FormatFloat(Sessao.formatquantidade, _quantidade);
  lblSubTotalFaturado.Caption := FormatFloat(sessao.formatsubtotal(), _valor);
end;

procedure Tf_devolucaoReport.RLBand5BeforePrint(Sender: TObject;
  var PrintIt: Boolean);
begin
  with _objeto['itens'].AsArray.Items[_rowItens] do
  Begin
      lblCodigoFaturado.Caption := AsObject['produto_id'].AsString;
      lblDescricaoFaturado.Caption := AsObject['descricao'].AsString;
      lblValorFaturado.Caption := FormatFloat(sessao.formatsubtotal(),
                                     AsObject['sub_total'].AsNumber);

     _valor := _valor + AsObject['sub_total'].AsNumber;
     _quantidade := _quantidade + AsObject['quantidade'].AsNumber;
  End;
  Inc(_rowItens);
end;

procedure Tf_devolucaoReport.bandRodapeBeforePrint(Sender: TObject;
  var PrintIt: Boolean);
begin
  qrcode.Caption := FormatFloat('00000000000',_Objeto['credito_id'].AsInteger);
  lblData.Caption:= 'Usuario: '+ sessao.usuarioName
                    +' - Impresso em :'+ FormatDateTime('dd/mm/yyyy hh:mm', now);
end;

procedure Tf_devolucaoReport.bandInfoCondicionalBeforePrint(Sender: TObject;
  var PrintIt: Boolean);
begin
  lblEmissao.Caption:= 'Emissão: '+
   FormatDateTime('dd/mm/yyyy hh:mm',sessao.DateToLocal(_Objeto['data_emissao'].AsString));

   lblCondicionalID.caption := 'Numero: '+_Objeto['id'].AsString;
   lblDadosVendedor.Lines.Text := 'Vendedor(a): ('+_Objeto['vendedor_id'].AsString+
                                           ') '+_Objeto['n_vendedor'].AsString;

   lblDadosCliente.Lines.Text := 'Cliente: ('+_Objeto['cliente_id'].AsString+
                                        ') '+_Objeto['n_cliente'].AsString ;

   lDadosVenda.Lines.Text := 'Venda ID: ('+_Objeto['venda_id'].AsString+
                                        ') ';
end;

procedure Tf_devolucaoReport.bandCabecalhoBeforePrint(Sender: TObject;
  var PrintIt: Boolean);
begin
  lNomeFantasia.Lines.Text :=  _objeto['empresa'].AsObject['fantasia'].AsString;
  lUnidade.Lines.Text :=  _objeto['empresa'].AsObject['nomeresumido'].AsString;
  lRazaoSocial.Lines.Text :=  _objeto['empresa'].AsObject['empresa'].AsString;
  lEndereco.Lines.Text :=  _objeto['empresa'].AsObject['endereco'].AsString +','+
                          _objeto['empresa'].AsObject['numero'].AsString;
  lTelefone.Lines.Text :=  _objeto['empresa'].AsObject['telefone'].AsString;
end;

procedure Tf_devolucaoReport.GetDevolucaoReport(_dados: TJsonObject);
begin
  _objeto := _dados;
  RLReport1.PageBreaking := pbNone;
  RLReport1.PageSetup.PaperSize   := fpCustom ;
  RLReport1.UnlimitedHeight:= true;

  _quantidade := 0;
  _valor := 0;
  _rowItens := 0;

  RLReport1.PreviewModal;
end;

end.

