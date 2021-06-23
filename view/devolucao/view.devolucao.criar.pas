unit view.devolucao.criar;

{$mode delphi}

interface

uses
  Classes, SysUtils, fphttpclient, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ActnList, Buttons, DBGrids, ACBrEnterTab, BCImageButton,
  ColorSpeedButton, BCComboBox, BGRASpeedButton, frame.empresa,
  frame.cliente.localiza, controller.condicional, classe.utils, BufDataset, DB;

type

  { Tf_devolucaoCriar }

  Tf_devolucaoCriar = class(TForm)
    ACBrEnterTab1: TACBrEnterTab;
    ac_sair: TAction;
    ac_confirmar: TAction;
    ActionList1: TActionList;
    BGRASpeedButton1: TBGRASpeedButton;
    BGRASpeedButton2: TBGRASpeedButton;
    cds_itens: TBufDataset;
    cds_itensaliq_desconto: TFloatField;
    cds_itensdescricao: TStringField;
    cds_itensid: TLongintField;
    cds_itensn_marca: TStringField;
    cds_itensn_unidade: TStringField;
    cds_itensproduto_id: TLongintField;
    cds_itensquantidade: TFloatField;
    cds_itenssub_total: TFloatField;
    cds_itensvalor_final: TFloatField;
    cds_itensvalor_unitario: TFloatField;
    cds_itensvl_desconto: TFloatField;
    DBGrid1: TDBGrid;
    ds_itens: TDataSource;
    ed_dataEmissao: TLabeledEdit;
    ed_documento: TLabeledEdit;
    ed_loja: TLabeledEdit;
    ed_meioPagamento: TLabeledEdit;
    ed_nomeCliente: TLabeledEdit;
    ed_prazoPagamento: TLabeledEdit;
    ed_protocolo: TEdit;
    ed_produtoID: TEdit;
    ed_tipoDocumento: TLabeledEdit;
    ed_ValorVenda: TLabeledEdit;
    ed_vendedor: TLabeledEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    edt_totalDevolucao: TLabeledEdit;
    ed_totaPecas: TLabeledEdit;
    pnlBotao: TPanel;
    pnlTitle: TPanel;
    pnlBanner: TPanel;
    Panel4: TPanel;
    pnlTotal: TPanel;
    pnlLinha2: TPanel;
    pnlLinha1: TPanel;
    pnlDadosCliente: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    procedure ac_sairExecute(Sender: TObject);
    procedure ac_confirmarExecute(Sender: TObject);
    procedure EditIDEnter(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private

  public
      _temp : string;

  end;

var
  f_devolucaoCriar: Tf_devolucaoCriar;

implementation

{$R *.lfm}

{ Tf_devolucaoCriar }

procedure Tf_devolucaoCriar.EditIDEnter(Sender: TObject);
begin
  _temp := (sender as TEdit).Text;
end;

procedure Tf_devolucaoCriar.ac_sairExecute(Sender: TObject);
begin
    f_devolucaoCriar.Close;
end;

procedure Tf_devolucaoCriar.ac_confirmarExecute(Sender: TObject);
begin
   // Confirmar
end;

procedure Tf_devolucaoCriar.FormResize(Sender: TObject);
var _size, _variacao : Double;
begin
  // 1156    h: 618
   _variacao := (((f_devolucaoCriar.Width + f_devolucaoCriar.Height) / 1774)*100)- 100;

   _size  := 10;
   if _variacao <> 0 then
     _size := ((10 * _variacao) /100)+10;

   if _size < 10 then _size := 10;

   pnlBanner.Height:= trunc((f_devolucaoCriar.Height * 0.049));
   pnlBanner.Font.Size:= trunc(_size);

   pnlTitle.Height:= trunc((f_devolucaoCriar.Height * 0.12));
   pnlTotal.Height:= trunc((f_devolucaoCriar.Height * 0.09));
   pnlBotao.Height:= trunc((f_devolucaoCriar.Height * 0.08));

   pnlDadosCliente.Height:= trunc((f_devolucaoCriar.Height * 0.207));
   pnlLinha1.Height:= trunc((pnlDadosCliente.Height /2));
   pnlLinha2.Height:= trunc((pnlDadosCliente.Height /2));



   {Linha 1}
   ed_dataEmissao.Width:= trunc((pnlDadosCliente.Width * 0.147));
   ed_documento.Width:= trunc((pnlDadosCliente.Width * 0.147));
   ed_tipoDocumento.Width:= trunc((pnlDadosCliente.Width * 0.147));
   ed_prazoPagamento.Width:= trunc((pnlDadosCliente.Width * 0.147));
   ed_meioPagamento.Width:= trunc((pnlDadosCliente.Width * 0.147));
   ed_ValorVenda.Width:= trunc((pnlDadosCliente.Width * 0.147));

   ed_dataEmissao.Height:= trunc((pnlLinha1.Height * 0.60));
   ed_documento.Height:= trunc((pnlLinha1.Height * 0.60));
   ed_tipoDocumento.Height:= trunc((pnlLinha1.Height * 0.60));
   ed_prazoPagamento.Height:= trunc((pnlLinha1.Height * 0.60));
   ed_meioPagamento.Height:= trunc((pnlLinha1.Height * 0.60));
   ed_ValorVenda.Height:= trunc((pnlLinha1.Height * 0.60));

   ed_documento.Left:= ed_dataEmissao.Left + ed_dataEmissao.Width + 10;
   ed_tipoDocumento.Left:= ed_documento.Left + ed_documento.Width + 10;
   ed_prazoPagamento.Left:= ed_tipoDocumento.Left + ed_tipoDocumento.Width + 10;
   ed_meioPagamento.Left:= ed_prazoPagamento.Left + ed_prazoPagamento.Width + 10;
   ed_ValorVenda.Left:= ed_meioPagamento.Left + ed_meioPagamento.Width + 10;

   ed_dataEmissao.Font.Size:= trunc(_size);
   ed_documento.Font.Size:= trunc(_size);
   ed_tipoDocumento.Font.Size:= trunc(_size);
   ed_prazoPagamento.Font.Size:= trunc(_size);
   ed_meioPagamento.Font.Size:= trunc(_size);
   ed_ValorVenda.Font.Size:= trunc(_size);

   {Linha 2}
   ed_nomeCliente.Width:= trunc((pnlDadosCliente.Width * 0.3027));
   ed_vendedor.Width:= trunc((pnlDadosCliente.Width * 0.3027));
   ed_loja.Width:= trunc((pnlDadosCliente.Width * 0.3027));

   ed_nomeCliente.Height:= trunc((pnlLinha2.Height * 0.60));
   ed_vendedor.Height:= trunc((pnlLinha2.Height * 0.60));
   ed_loja.Height:= trunc((pnlLinha2.Height * 0.60));

   ed_vendedor.Left:= ed_nomeCliente.Left + ed_nomeCliente.Width + 10;
   ed_loja.Left:= ed_vendedor.Left + ed_vendedor.Width + 10;

   ed_nomeCliente.Font.Size:= trunc(_size);
   ed_vendedor.Font.Size:= trunc(_size);
   ed_loja.Font.Size:= trunc(_size);


   {Panel Title }
   ed_nomeCliente.Width:= trunc((pnlDadosCliente.Width * 0.3027));
   ed_vendedor.Width:= trunc((pnlDadosCliente.Width * 0.3027));
   ed_loja.Width:= trunc((pnlDadosCliente.Width * 0.3027));

   ed_nomeCliente.Height:= trunc((pnlLinha2.Height * 0.60));
   ed_vendedor.Height:= trunc((pnlLinha2.Height * 0.60));
   ed_loja.Height:= trunc((pnlLinha2.Height * 0.60));

   ed_vendedor.Left:= ed_nomeCliente.Left + ed_nomeCliente.Width + 10;
   ed_loja.Left:= ed_vendedor.Left + ed_vendedor.Width + 10;

   ed_nomeCliente.Font.Size:= trunc(_size);
   ed_vendedor.Font.Size:= trunc(_size);
   ed_loja.Font.Size:= trunc(_size);
end;

end.

