unit report.condicional;

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, RLReport,
  RLPDFFilter, jsons, RLTypes, RLBarcode;

type

  { Treport_condicional }

  Treport_condicional = class(TForm)
    bandCabecalho: TRLBand;
    bandInfoCondicional: TRLBand;
    bandRodape: TRLBand;
    detailDevolvidos: TRLSubDetail;
    detailFaturado: TRLSubDetail;
    detailPendente: TRLSubDetail;
    lblcodigo1: TRLLabel;
    lblcodigo3: TRLLabel;
    lblcodigo4: TRLLabel;
    lblCodigoDevolvido: TRLLabel;
    lblCodigoFaturado: TRLLabel;
    lblCodigoPendente: TRLLabel;
    lblCondicionalID: TRLLabel;
    lblDadosCliente: TRLMemo;
    lblDadosVendedor: TRLMemo;
    lblData: TRLLabel;
    lblDescricao1: TRLLabel;
    lblDescricao3: TRLLabel;
    lblDescricao5: TRLLabel;
    lblDescricaoDevolvido: TRLLabel;
    lblDescricaoFaturado: TRLLabel;
    lblDescricaoPendente: TRLLabel;
    lblEmissao: TRLLabel;
    lblItensDevolvido: TRLLabel;
    lblItensFaturado: TRLLabel;
    lblItensPendente: TRLLabel;
    lblSubTotalDevolvido: TRLLabel;
    lblSubTotalFaturado: TRLLabel;
    lblSubTotalPendente: TRLLabel;
    lblValor1: TRLLabel;
    lblValor3: TRLLabel;
    lblValor5: TRLLabel;
    lblValorDevolvido: TRLLabel;
    lblValorFaturado: TRLLabel;
    lblValorPendente: TRLLabel;
    lEndereco: TRLMemo;
    ListBox1: TListBox;
    lNomeFantasia: TRLMemo;
    lRazaoSocial: TRLMemo;
    lSistema: TRLLabel;
    lSistema1: TRLLabel;
    lTelefone: TRLMemo;
    lUnidade: TRLMemo;
    qrcode: TRLBarcode;
    RLBand1: TRLBand;
    RLBand10: TRLBand;
    RLBand2: TRLBand;
    RLBand3: TRLBand;
    RLBand4: TRLBand;
    RLBand5: TRLBand;
    RLBand6: TRLBand;
    RLBand8: TRLBand;
    RLBand9: TRLBand;
    RLDraw1: TRLDraw;
    RLLabel1: TRLLabel;
    RLLabel10: TRLLabel;
    RLLabel11: TRLLabel;
    RLLabel12: TRLLabel;
    RLLabel28: TRLLabel;
    RLLabel29: TRLLabel;
    RLLabel3: TRLLabel;
    RLLabel30: TRLLabel;
    RLLabel31: TRLLabel;
    RLLabel32: TRLLabel;
    RLLabel33: TRLLabel;
    RLLabel4: TRLLabel;
    RLLabel7: TRLLabel;
    RLLabel8: TRLLabel;
    RLLabel9: TRLLabel;
    RLMemo1: TRLMemo;
    RLPanel1: TRLPanel;
    RLPanel2: TRLPanel;
    RLPanel3: TRLPanel;
    RLPanel4: TRLPanel;
    RLPanel5: TRLPanel;
    RLPanel6: TRLPanel;
    RLPanel7: TRLPanel;
    RLPDFFilter1: TRLPDFFilter;
    RLReport1: TRLReport;
    procedure bandCabecalhoBeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure bandInfoCondicionalBeforePrint(Sender: TObject;
      var PrintIt: Boolean);
    procedure bandRodapeBeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure detailDevolvidosNeedData(Sender: TObject; var MoreData: Boolean);
    procedure detailFaturadoNeedData(Sender: TObject; var MoreData: Boolean);
    procedure detailPendenteNeedData(Sender: TObject; var MoreData: Boolean);
    procedure RLBand2BeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure RLBand3BeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure RLBand5BeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure RLPanel2BeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure RLPanel3BeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure RLPanel4BeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure RLReport1BeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure RLReport1DataRecord(Sender: TObject; RecNo: Integer;
      CopyNo: Integer; var Eof: Boolean; var RecordAction: TRLRecordAction);
  private
    _itemPendentes,_itemDevolvidos,_itemFaturados : Integer;
    _rowPendentes,_rowDevolvidos,_RowFaturados : Integer;
    _objeto : TJsonObject;
    _total : Currency;
  public
       Procedure GetCondicionalReport(_dados: TJsonObject);
  end;

var
  report_condicional: Treport_condicional;


implementation

{$R *.lfm}

uses classe.utils;



{ Treport_condicional }

procedure Treport_condicional.bandCabecalhoBeforePrint(Sender: TObject;
  var PrintIt: Boolean);
begin
    lNomeFantasia.Lines.Text :=  _objeto['empresa'].AsObject['fantasia'].AsString;
    lUnidade.Lines.Text :=  _objeto['empresa'].AsObject['nomeresumido'].AsString;
    lRazaoSocial.Lines.Text := _objeto['empresa'].AsObject['empresa'].AsString;
    lEndereco.Lines.Text :=  _objeto['empresa'].AsObject['endereco'].AsString+
                             ',' + _objeto['empresa'].AsObject['numero'].AsString;
    lTelefone.Lines.Text :=  _objeto['empresa'].AsObject['telefone'].AsString;
end;

procedure Treport_condicional.bandInfoCondicionalBeforePrint(Sender: TObject;
  var PrintIt: Boolean);
begin
     lblEmissao.Caption:= 'Emissão: '+
     FormatDateTime('dd/mm/yyyy hh:mm',sessao.DateToLocal(_Objeto['data_emissao'].AsString));

     lblCondicionalID.caption := 'Numero: '+_Objeto['id'].AsString;
     lblDadosVendedor.Lines.Text := 'Vendedor(a): ('+_Objeto['vendedor_id'].AsString+
                                             ') '+_Objeto['n_vendedor'].AsString;

     lblDadosCliente.Lines.Text := 'Cliente: ('+_Objeto['cliente_id'].AsString+
                                          ') '+_Objeto['n_cliente'].AsString
end;

procedure Treport_condicional.bandRodapeBeforePrint(Sender: TObject;
  var PrintIt: Boolean);
begin
    qrcode.Caption := FormatFloat('00000000000',_Objeto['id'].AsInteger);
    lblData.Caption:= 'Usuario: '+ sessao.usuarioName
                      +' - Impresso em :'+ FormatDateTime('dd/mm/yyyy hh:mm', now);
end;

procedure Treport_condicional.detailDevolvidosNeedData(Sender: TObject;
  var MoreData: Boolean);
begin
  if _rowDevolvidos = 1 then
     _total := 0;
  MoreData:= _rowDevolvidos <= _itemDevolvidos;
end;

procedure Treport_condicional.detailFaturadoNeedData(Sender: TObject;
  var MoreData: Boolean);
begin
  if _RowFaturados = 1 then
     _total := 0;
  MoreData:= _RowFaturados <= _itemFaturados;
end;

procedure Treport_condicional.detailPendenteNeedData(Sender: TObject;
  var MoreData: Boolean);
begin
  if _rowPendentes = 1 then
     _total := 0;
  MoreData:= _rowPendentes <= _itemPendentes;
end;

procedure Treport_condicional.RLBand2BeforePrint(Sender: TObject;
  var PrintIt: Boolean);
begin
  with _Objeto['itens'].AsArray.Items[_RowPendentes-1] do
  Begin
    lblCodigoPendente.Caption:= AsObject['produto_id'].AsString;
    lblDescricaoPendente.Caption:= AsObject['descricao'].AsString;;
    lblValorPendente.Caption:= FormatFloat('#0.00,',AsObject['valor_final'].AsNumber);
    _total := _total + AsObject['valor_final'].AsNumber;
    inc(_RowPendentes);
  end;
end;

procedure Treport_condicional.RLBand3BeforePrint(Sender: TObject;
  var PrintIt: Boolean);
begin
  with _Objeto['devolvido'].AsArray.Items[_rowDevolvidos-1] do
  Begin
    lblCodigoDevolvido.Caption:= AsObject['produto_id'].AsString;
    lblDescricaoDevolvido.Caption:= AsObject['descricao'].AsString;;
    lblValorDevolvido.Caption:= FormatFloat('#0.00,',AsObject['valor_final'].AsNumber);
    _total := _total + AsObject['valor_final'].AsNumber;
    inc(_rowDevolvidos);
  end;
end;

procedure Treport_condicional.RLBand5BeforePrint(Sender: TObject;
  var PrintIt: Boolean);
begin
  try
      with _Objeto['faturado'].AsArray.Items[_rowFaturados-1] do
      Begin
        lblCodigoFaturado.Caption:= AsObject['produto_id'].AsString;
        lblDescricaoFaturado.Caption:= AsObject['descricao'].AsString;;
        lblValorFaturado.Caption:= FormatFloat('#0.00,',AsObject['valor_final'].AsNumber);
        _total := _total + AsObject['valor_final'].AsNumber;
        inc(_rowFaturados);
      end;
  except

  end;
end;

procedure Treport_condicional.RLPanel2BeforePrint(Sender: TObject;
  var PrintIt: Boolean);
begin
  lblItensPendente.Caption:= IntToStr(_itemPendentes);
  lblSubTotalPendente.Caption:= FormatFloat('#0.00,',_total);
end;

procedure Treport_condicional.RLPanel3BeforePrint(Sender: TObject;
  var PrintIt: Boolean);
begin
  lblItensDevolvido.Caption:= IntToStr(_itemDevolvidos);
  lblSubTotalDevolvido.Caption:= FormatFloat('#0.00,',_total);
end;

procedure Treport_condicional.RLPanel4BeforePrint(Sender: TObject;
  var PrintIt: Boolean);
begin
  lblItensFaturado.Caption:= IntToStr(_itemFaturados);
  lblSubTotalFaturado.Caption:= FormatFloat('#0.00,',_total);
end;

procedure Treport_condicional.RLReport1BeforePrint(Sender: TObject;
  var PrintIt: Boolean);
begin

end;

procedure Treport_condicional.RLReport1DataRecord(Sender: TObject;
  RecNo: Integer; CopyNo: Integer; var Eof: Boolean;
  var RecordAction: TRLRecordAction);
begin
  Eof := (RecNo > 1);
end;

procedure Treport_condicional.GetCondicionalReport(_dados: TJsonObject);
var i : Integer;
 _status: String;
begin
    _objeto := _dados;
    _itemPendentes:= _Objeto['itens'].AsArray.Count;
    _itemDevolvidos:= _Objeto['devolvido'].AsArray.Count;
    _itemFaturados:= _Objeto['faturado'].AsArray.Count;

    detailPendente.Visible:= _itemPendentes > 0;
    detailDevolvidos.Visible:= _itemDevolvidos > 0;
    detailFaturado.Visible:= _itemFaturados > 0;

    _rowPendentes := 1; _rowDevolvidos := 1; _rowfaturados := 1;

    RLReport1.PageBreaking := pbNone;
    RLReport1.PageSetup.PaperSize   := fpCustom ;
    RLReport1.UnlimitedHeight:= false;
    RLReport1.PreviewModal;
end;

end.

