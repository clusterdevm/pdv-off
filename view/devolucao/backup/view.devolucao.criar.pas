unit view.devolucao.criar;

{$mode delphi}

interface

uses
  Classes, SysUtils, fphttpclient, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ActnList, Buttons, DBGrids, ACBrEnterTab, BCImageButton,
  ColorSpeedButton, BCComboBox, BGRASpeedButton, BCButton, frame.empresa,
  frame.cliente.localiza, controller.condicional, classe.utils, BufDataset, DB,
  controller.devolucao, jsons;

type

  { Tf_devolucaoCriar }

  Tf_devolucaoCriar = class(TForm)
    ACBrEnterTab1: TACBrEnterTab;
    ac_incluir: TAction;
    ac_busca: TAction;
    ac_sair: TAction;
    ac_confirmar: TAction;
    ActionList1: TActionList;
    BCButton2: TBCButton;
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
    img_16: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    edt_totalDevolucao: TLabeledEdit;
    ed_totaPecas: TLabeledEdit;
    mObs: TMemo;
    pnlBotao: TPanel;
    pnlTitle: TPanel;
    pnlBanner: TPanel;
    Panel4: TPanel;
    pnlTotal: TPanel;
    pnlLinha2: TPanel;
    pnlLinha1: TPanel;
    pnlDadosCliente: TPanel;
    SpeedButton2: TSpeedButton;
    procedure ac_buscaExecute(Sender: TObject);
    procedure ac_incluirExecute(Sender: TObject);
    procedure ac_sairExecute(Sender: TObject);
    procedure ac_confirmarExecute(Sender: TObject);
    procedure EditIDEnter(Sender: TObject);
    procedure ed_protocoloEnter(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
        _objeto : TDevolucao;
        Procedure SetLayout;
  public
      _temp : string;

  end;

var
  f_devolucaoCriar: Tf_devolucaoCriar;

implementation

{$R *.lfm}



procedure Tf_devolucaoCriar.EditIDEnter(Sender: TObject);
begin
  _temp := (sender as TEdit).Text;
end;

procedure Tf_devolucaoCriar.ed_protocoloEnter(Sender: TObject);
begin
   _temp := ed_protocolo.Text;
end;

procedure Tf_devolucaoCriar.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  FreeAndNil(_objeto);
end;

procedure Tf_devolucaoCriar.FormCreate(Sender: TObject);
begin
  _objeto := TDevolucao.Create;
  cds_itens.CreateDataset;
  cds_itens.Open;
end;

procedure Tf_devolucaoCriar.ac_sairExecute(Sender: TObject);
begin
    f_devolucaoCriar.Close;
end;

procedure Tf_devolucaoCriar.ac_buscaExecute(Sender: TObject);
begin
   if (_temp <> ed_protocolo.Text) then
   Begin
       if _objeto.GetVendaDevolucao(ed_protocolo.Text) then
       Begin
            SetLayout;
            pnlTitle.Visible:= false;
            pnlBanner.visible := true;
            pnlDadosCliente.Visible:= true;
            Panel4.Visible:= true;
            ac_confirmar.Enabled:= true;
            _objeto.Seleciona;
            SetLayout;
       end else
       Begin
           ed_protocolo.Clear;
           ed_protocolo.SetFocus;
           Abort;
       end;
   end;
end;

procedure Tf_devolucaoCriar.ac_incluirExecute(Sender: TObject);
begin
   _objeto.GetVendaDevolucao(ed_protocolo.Text);
   _objeto.seleciona;
   SetLayout;
end;

procedure Tf_devolucaoCriar.ac_confirmarExecute(Sender: TObject);
begin
   _objeto.Observacao:= mObs.Text;
   if _objeto.Concluir then
      self.Close;;
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

   {GRID}
   DBGrid1.Columns[0].Width:= trunc((pnlDadosCliente.Width * 0.086));
   DBGrid1.Columns[1].Width:= trunc((pnlDadosCliente.Width * 0.07));
   DBGrid1.Columns[2].Width:= trunc((pnlDadosCliente.Width * 0.05));
   DBGrid1.Columns[4].Width:= trunc((pnlDadosCliente.Width * 0.089));
   DBGrid1.Columns[5].Width:= trunc((pnlDadosCliente.Width * 0.09));
   DBGrid1.Columns[6].Width:= trunc((pnlDadosCliente.Width * 0.05));
   DBGrid1.Columns[7].Width:= trunc((pnlDadosCliente.Width * 0.09));
   DBGrid1.Columns[8].Width:= trunc((pnlDadosCliente.Width * 0.1));

   DBGrid1.Columns[3].Width:= DBGrid1.Width - ( DBGrid1.Columns[0].Width +
                                                DBGrid1.Columns[1].Width +
                                                DBGrid1.Columns[2].Width +
                                                DBGrid1.Columns[4].Width +
                                                DBGrid1.Columns[5].Width +
                                                DBGrid1.Columns[6].Width +
                                                DBGrid1.Columns[7].Width +
                                                DBGrid1.Columns[8].Width +
                                                30
                                                );

end;

procedure Tf_devolucaoCriar.SetLayout;
var i : Integer;
  _item : TJsonObject;
begin

   //DBGrid1.Columns[1].DisplayFormat:= Sessao.datetimeformat;
   //DBGrid1.Columns[2].DisplayFormat:= Sessao.datetimeformat;
   //DBGrid1.Columns[3].DisplayFormat:= Sessao.datetimeformat;

   DBGrid1.Columns[1].DisplayFormat:=Sessao.formatquantidade;
   DBGrid1.Columns[5].DisplayFormat:=Sessao.formatunitario;
   DBGrid1.Columns[6].DisplayFormat:=Sessao.formatAliquota;
   DBGrid1.Columns[7].DisplayFormat:=Sessao.formatunitario;
   DBGrid1.Columns[8].DisplayFormat:=Sessao.formatsubtotal;


   ed_dataEmissao.Text:= FormatDateTime('dd/mm/yyyy hh:mm',getDataBanco(_objeto.venda['data_emissao'].AsString));
   ed_documento.Text:= _objeto.venda['documento'].AsString;
   ed_tipoDocumento.Text:= _objeto.venda['n_modelo_documento'].AsString;
   ed_prazoPagamento.Text:= _objeto.venda['n_prazo'].AsString;
   ed_meioPagamento.Text:= _objeto.venda['n_meio_pagamento'].AsString;
   ed_ValorVenda.Text:= FormatFloat(sessao.formatsubtotal,_objeto.venda['total_nota'].AsNumber);
   ed_nomeCliente.Text:= _objeto.venda['n_cliente'].AsString;
   ed_vendedor.Text:= _objeto.venda['n_vendedor'].AsString;
   ed_loja.Text:= _objeto.venda['n_unidade'].AsString;

   edt_totalDevolucao.Text:= FormatFloat(sessao.formatsubtotal,
                                _objeto.venda['total'].AsObject['selecionado'].AsNumber);
   ed_totaPecas.Text:= FormatFloat(sessao.formatquantidade,
                             _objeto.venda['total'].AsObject['registro'].AsNumber);

   ed_loja.Text:= _objeto.venda['n_unidade'].AsString;

   Limpa(cds_itens);
   cds_itens.DisableControls;
   for i := 0 to _objeto.venda['selecionado'].AsArray.Count-1 do
   Begin
       _item := _objeto.venda['selecionado'].AsArray.Items[i].AsObject;

       cds_itens.Append;
       cds_itensproduto_id.Value:= _item['produto_id'].AsInteger;
       cds_itensn_marca.value := _item['n_marca'].AsString;
       cds_itensdescricao.Value:= _item['descricao'].AsString;
       cds_itensn_unidade.Value:= _item['n_unidade'].AsString;
       cds_itensquantidade.Value:= _item['quantidade'].AsNumber;
       cds_itensvalor_unitario.Value:= _item['valor_unitario'].AsNumber;
       cds_itensvalor_final.Value:= _item['valor_final'].AsNumber;
       cds_itensaliq_desconto.Value:= _item['aliq_desconto'].AsNumber;
       cds_itensvl_desconto.Value:= _item['vl_desconto'].AsNumber;
       cds_itenssub_total.Value:= _item['sub_total'].AsNumber;
       cds_itens.Post;
   end;
   cds_itens.First;
   cds_itens.EnableControls;
end;

end.

