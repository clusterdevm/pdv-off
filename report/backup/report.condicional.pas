unit report.condicional;

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, RLReport;

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
    lNomeFantasia: TRLMemo;
    lRazaoSocial: TRLMemo;
    lSistema: TRLLabel;
    lSistema1: TRLLabel;
    lTelefone: TRLMemo;
    lUnidade: TRLMemo;
    RLBand1: TRLBand;
    RLBand10: TRLBand;
    RLBand2: TRLBand;
    RLBand3: TRLBand;
    RLBand4: TRLBand;
    RLBand5: TRLBand;
    RLBand6: TRLBand;
    RLBand8: TRLBand;
    RLBand9: TRLBand;
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
    RLPanel1: TRLPanel;
    RLPanel2: TRLPanel;
    RLPanel3: TRLPanel;
    RLPanel4: TRLPanel;
    RLPanel5: TRLPanel;
    RLReport1: TRLReport;
    procedure bandCabecalhoBeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure bandInfoCondicionalBeforePrint(Sender: TObject;
      var PrintIt: Boolean);
    procedure bandRodapeBeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure detailDevolvidosBeforePrint(Sender: TObject; var PrintIt: Boolean
      );
    procedure detailDevolvidosNeedData(Sender: TObject; var MoreData: Boolean);
    procedure detailFaturadoNeedData(Sender: TObject; var MoreData: Boolean);
    procedure detailPendenteNeedData(Sender: TObject; var MoreData: Boolean);
    procedure RLBand2BeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure RLBand3BeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure RLBand6BeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure RLPanel3BeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure RLPanel4BeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure RLReport1DataRecord(Sender: TObject; RecNo: Integer;
      CopyNo: Integer; var Eof: Boolean; var RecordAction: TRLRecordAction);
  private
    _itemPendentes,_itemDevolvidos,_itemFaturados : Integer;
    _rowPendentes,_rowDevolvidos,_RowFaturados : Integer;
    _total : Currency;
  public
       Procedure GetCondicionalReport;
  end;

var
  report_condicional: Treport_condicional;


implementation

{$R *.lfm}

{ Treport_condicional }

procedure Treport_condicional.bandCabecalhoBeforePrint(Sender: TObject;
  var PrintIt: Boolean);
begin
    lNomeFantasia.Lines.Text :=  _jwt.fantasia;
    lUnidade.Lines.Text :=  _jwt.unidade;
    lRazaoSocial.Lines.Text :=  _jwt.razao;
    lEndereco.Lines.Text :=  _jwt.endereco;
    lTelefone.Lines.Text :=  _jwt.telefone;
end;

procedure Treport_condicional.bandInfoCondicionalBeforePrint(Sender: TObject;
  var PrintIt: Boolean);
begin
    lblEmissao.Caption:= 'Emissão: '+
    FormatDateTime('dd/mm/yyyy hh:mm',GetData(_Objeto['data_emissao'].AsString));

    lblCondicionalID.caption := 'Numero: '+_Objeto['id'].AsString;
    lblDadosVendedor.Lines.Text := 'Vendedor(a): ('+_Objeto['vendedor_id'].AsString+
                                            ') '+_Objeto['n_vendedor'].AsString;

    lblDadosCliente.Lines.Text := 'Cliente: ('+_Objeto['cliente_id'].AsString+
                                         ') '+_Objeto['n_cliente'].AsString
end;

procedure Treport_condicional.bandRodapeBeforePrint(Sender: TObject;
  var PrintIt: Boolean);
begin
    lblData.Caption:= 'Usuario: '+ _jwt.UsuarioNome
                        +' - Impresso em :'+ FormatDateTime('dd/mm/yyyy hh:mm', now);
end;

procedure Treport_condicional.detailDevolvidosBeforePrint(Sender: TObject;
  var PrintIt: Boolean);
begin

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
  with _Objeto['itens_pendente'].AsArray.Items[_RowPendentes-1] do
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
  with _Objeto['itens_devolvido'].AsArray.Items[_rowDevolvidos-1] do
  Begin
    lblCodigoDevolvido.Caption:= AsObject['produto_id'].AsString;
    lblDescricaoDevolvido.Caption:= AsObject['descricao'].AsString;;
    lblValorDevolvido.Caption:= FormatFloat('#0.00,',AsObject['valor_final'].AsNumber);
    _total := _total + AsObject['valor_final'].AsNumber;
    inc(_rowDevolvidos);
  end;

end;

procedure Treport_condicional.RLBand6BeforePrint(Sender: TObject;
  var PrintIt: Boolean);
begin
  with _Objeto['itens_faturado'].AsArray.Items[_rowFaturados-1] do
  Begin
    lblCodigoFaturado.Caption:= AsObject['produto_id'].AsString;
    lblDescricaoFaturado.Caption:= AsObject['descricao'].AsString;;
    lblValorFaturado.Caption:= FormatFloat('#0.00,',AsObject['valor_final'].AsNumber);
    _total := _total + AsObject['valor_final'].AsNumber;
    inc(_rowFaturados);
  end;
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

procedure Treport_condicional.RLReport1DataRecord(Sender: TObject;
  RecNo: Integer; CopyNo: Integer; var Eof: Boolean;
  var RecordAction: TRLRecordAction);
begin
  Eof := (RecNo > 1);
end;

procedure Treport_condicional.GetCondicionalReport;
var i : Integer;
 _status: String;
begin
    for i :=  0 to _Objeto['itens'].AsArray.Count-1 do
    Begin
         _status := _Objeto['itens'].AsArray.Items[i].AsObject['status'].AsString;

         if  (_status ='rascunho') or (_status ='pendente')  then
         Begin
              with _Objeto['itens_pendente'].AsArray do
                 Put(_Objeto['itens'].AsArray.Items[i].AsObject);
         end else

         if  (_status ='devolvido') or (_status ='cancelado')  then
         Begin
              with _Objeto['itens_devolvido'].AsArray do
                 Put(_Objeto['itens'].AsArray.Items[i].AsObject);
         end else

         Begin
              with _Objeto['itens_faturado'].AsArray do
                 Put(_Objeto['itens'].AsArray.Items[i].AsObject);
         end;
    end;

    _itemPendentes:= _Objeto['itens_pendente'].AsArray.Count;
    _itemDevolvidos:= _Objeto['itens_devolvido'].AsArray.Count;
    _itemFaturados:= _Objeto['itens_faturado'].AsArray.Count;

    detailPendente.Visible:= _itemPendentes > 0;
    detailDevolvidos.Visible:= _itemDevolvidos > 0;
    detailFaturado.Visible:= _itemFaturados > 0;

    _rowPendentes := 1; _rowDevolvidos := 1; _rowfaturados := 1;

    RLReport1.PageBreaking := pbNone;
    RLReport1.PageSetup.PaperSize   := fpCustom ;
    RLReport1.UnlimitedHeight:= true;

    RLReport1.Show;

end;

end.

