unit uf_venda.fechamento;

{$mode delphi}

interface

uses
  Classes, SysUtils, BufDataset, DB, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, DBGrids, StdCtrls, BCButton, clipbrd, ComCtrls,
  ActnList, EditBtn, Spin, ACBrEnterTab, RTTICtrls, SynEdit, SpinEx,
  frame.pagamento, math, jsons, Types, Grids,LCLProc,LCLtype,
  DateUtils;

type

  { Tf_fechamento }

  Tf_fechamento = class(TForm)
    ACBrEnterTab1: TACBrEnterTab;
    ac_fechar: TAction;
    ActionList1: TActionList;
    BCButton4: TBCButton;
    dsCrediario: TDataSource;
    pnlLabelCrediario: TPanel;
    qCrediario: TBufDataset;
    CheckBox1: TCheckBox;
    gridCrediario: TDBGrid;
    DBGrid2: TDBGrid;
    dsPagamento: TDataSource;
    ed_entrega: TEdit;
    ed_AliqDesconto: TEdit;
    ed_valorDesconto: TEdit;
    ed_acrescimo: TEdit;
    ed_valorEntrada: TEdit;
    gridPrazo: TDBGrid;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    lCondicoes: TLabel;
    Label6: TLabel;
    lCliente: TLabel;
    lVendedor: TLabel;
    lShape1: TLabel;
    lShape2: TLabel;
    lShape3: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    lTotalPagar: TLabel;
    Label7: TLabel;
    lPromocao: TLabel;
    Label9: TLabel;
    lTotalGeral: TLabel;
    lCPF: TLabel;
    lTotal: TLabel;
    lDesconto: TLabel;
    lAcrescimo: TLabel;
    lEntrega: TLabel;
    lEntrada: TLabel;
    lTotalVenda: TLabel;
    Memo1: TMemo;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel10: TPanel;
    Panel11: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    qCrediarioDocumento: TStringField;
    qCrediarioParcela: TLongintField;
    qCrediariovalor: TFloatField;
    qCrediarioVencimento: TDateField;
    qPagamento: TBufDataset;
    qPagamentoaliq_desconto: TFloatField;
    qPagamentoaliq_desconto1: TFloatField;
    qPagamentocrediario: TBooleanField;
    qPagamentodescricao: TStringField;
    qPagamentodescricao1: TStringField;
    qPagamentodisplay_resumo: TStringField;
    qPagamentoid: TLongintField;
    qPagamentoid1: TLongintField;
    qPagamenton_parcelas: TLongintField;
    qPagamentoprimeiro_vencimento: TLongintField;
    qPagamentovenciveis_de: TLongintField;
    Shape1: TShape;
    ShapeBarra: TShape;
    nextShape1: TShape;
    nextShape2: TShape;
    nextShape3: TShape;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    procedure ac_fecharExecute(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure ed_AliqDescontoEnter(Sender: TObject);
    procedure ed_AliqDescontoExit(Sender: TObject);
    procedure ed_entregaExit(Sender: TObject);
    procedure ed_valorDescontoEnter(Sender: TObject);
    procedure ed_valorDescontoExit(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure gridPrazoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure gridPrazoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState
      );
    procedure gridPrazoMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure gridPrazoMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PageControl1Change(Sender: TObject);
    procedure PageControl1Changing(Sender: TObject; var AllowChange: Boolean);
  private
        _temp : currency;
        _aliquota : boolean;

        Frame : TframePagamento;
        Procedure LoadPrazo;
        Function CalculaValor : Currency;
        Function CalculaValorStr : string;

        Procedure LoadShape(posicao:integer);

        Procedure SetResumo;
  public
      _valorBruto, _valorPromocao, _valorDesconto, _valorDescontoExtra,
        _valorEntrada, _ValorRecebimento, _totalVenda, _totalCrediario : Extended;

      _vendaID, _vendaUUID : string;
  end;

var
  f_fechamento: Tf_fechamento;

implementation

{$R *.lfm}

uses ems.conexao, ems.utils, f_venda, model.vendas.imposto;

procedure Tf_fechamento.FormCreate(Sender: TObject);
begin
   qPagamento.CreateDataset;
   qPagamento.Open;

   qCrediario.CreateDataset;
   qCrediario.Open;

   _aliquota:= false;

   Frame := TframePagamento.Create(f_fechamento);
   frame.Parent := Panel10;
   Frame.Align:= alClient;

   ed_entrega.Text:= FormatFloat(sessao.formatsubtotal(false),0);
   ed_acrescimo.Text:= FormatFloat(sessao.formatsubtotal(false),0);
   ed_AliqDesconto.Text:= FormatFloat(sessao.formatAliquota(false),0);
   ed_valorDesconto.Text:= FormatFloat(sessao.formatsubtotal(false),0);
   ed_valorEntrada.Text:= FormatFloat(sessao.formatsubtotal(false),0);
end;

procedure Tf_fechamento.ac_fecharExecute(Sender: TObject);
var _avancar : boolean;
  _nota : TJsonObject;
begin
  SetResumo;
  case PageControl1.PageIndex of
   0 : Begin
       if _ValorRecebimento > 0 then
       Begin
           PageControl1.PageIndex:= 1;
           Frame.Inicializa(_ValorRecebimento,qPagamenton_parcelas.Value);
           Frame.ListBox1.SetFocus;
           Frame.ListBox1.Selected[0] := True;
           ac_fechar.Caption:= 'Proximo (F6)';
           LoadShape(2);
       end
       else
       Begin
           PageControl1.PageIndex:= 2;
           ac_fechar.Caption:= 'Concluir (F6)';
           LoadShape(3);
       end;

   end;
   1 : Begin
       if _ValorRecebimento > 0 then
       Begin
           if (CheckBox1.Checked) or (Frame.Quitado)  then
           Begin
               PageControl1.PageIndex:= 2;
               ac_fechar.Caption:= 'Concluir (F6)';
               LoadShape(3);
           end;
       end;
   end;
   2 : Begin
       LoadShape(4);
       SetVendaTotalizador(_vendaUUID,_vendaID, true);
       self.Close;
   end;
end;
end;

procedure Tf_fechamento.CheckBox1Change(Sender: TObject);
begin
  frame.Visible:= not (CheckBox1.Checked);

  if CheckBox1.Checked = false then
     frame.ListBox1.SetFocus;
end;

procedure Tf_fechamento.ed_AliqDescontoEnter(Sender: TObject);
begin
  _temp := ToValor(ed_AliqDesconto.Text);
end;

procedure Tf_fechamento.ed_AliqDescontoExit(Sender: TObject);
begin
  if _temp <> ToValor(ed_AliqDesconto.Text) then
    _aliquota := true;

  CalculaValor;
end;

procedure Tf_fechamento.ed_entregaExit(Sender: TObject);
begin
   CalculaValor;
end;

procedure Tf_fechamento.ed_valorDescontoEnter(Sender: TObject);
begin
    _temp := ToValor(ed_valorDesconto.Text);
end;

procedure Tf_fechamento.ed_valorDescontoExit(Sender: TObject);
begin
  if _temp <> ToValor(ed_valorDesconto.Text) then
    _aliquota := false;

  CalculaValor;
end;

procedure Tf_fechamento.FormShow(Sender: TObject);
begin
    _valorEntrada:= 0;
    _valorDescontoExtra:= 0;

    PageControl1.TabIndex:= 0;
    PageControl1.ShowTabs:= false;
    LoadPrazo;
    LoadShape(1);
end;

procedure Tf_fechamento.gridPrazoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    CalculaValor;

   If key = vk_return then
     ed_entrega.SetFocus;

end;

procedure Tf_fechamento.gridPrazoKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
      CalculaValor;
end;

procedure Tf_fechamento.gridPrazoMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
      CalculaValor;
end;

procedure Tf_fechamento.gridPrazoMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
      CalculaValor;
end;

procedure Tf_fechamento.PageControl1Change(Sender: TObject);
begin
    LoadShape(PageControl1.PageIndex+1);
end;

procedure Tf_fechamento.PageControl1Changing(Sender: TObject;
  var AllowChange: Boolean);
begin
   LoadShape(PageControl1.PageIndex+1);

end;

procedure Tf_fechamento.LoadPrazo;
var _db : TConexao;
begin
  try
     _db := TConexao.Create;
     with _db.qrySelect do
     Begin
         Close;
         Sql.Clear;
         Sql.Add('select * from prazo_pagamento pp ');
         Sql.Add(' where ativo = ''true''');
         Sql.Add(' order by descricao');
         open;
         first;

         qPagamento.Close;
         qPagamento.Open;

         while not eof do
         Begin
              qPagamento.Append;
              qPagamentoaliq_desconto.Value:= FieldByName('aliq_desconto').AsFloat;
              qPagamentodescricao.Value:= FieldByName('descricao').AsString +' ('+CalculaValorStr+')';

              if _valorPromocao > 0 then ;
                 qPagamentodescricao.Value := qPagamentodescricao.Value + '(Promocao '+FormatFloat(sessao.formatsubtotal(),_valorPromocao)+')';

              qPagamentocrediario.Value:= trim(FieldByName('tipo_forma').AsString) = 'crediario';
              qPagamentodisplay_resumo.Value:= FieldByName('descricao').AsString;
              qPagamentovenciveis_de.Value:= FieldByName('venciveis_de').AsInteger;
              qPagamenton_parcelas.Value:= FieldByName('qtde_parcela').AsInteger;
              qPagamentoprimeiro_vencimento.Value:= FieldByName('primeiro_vencimento').AsInteger;
              qPagamento.Post;

              Next;
         end;
         qPagamento.First;
         gridPrazo.SetFocus;
     end;
  finally
    FreeAndNil(_db);
  end;
end;

function Tf_fechamento.CalculaValor: Currency;

begin

   if qPagamentoaliq_desconto.Value > 0 then
      _valorDesconto := ((_valorBruto * qPagamentoaliq_desconto.AsFloat)/100)
   else
      _valorDesconto:= 0;

   result := _valorBruto - _valorDesconto;

   ed_valorEntrada.Enabled := qPagamentocrediario.Value;

   if qPagamentocrediario.Value then
      _valorEntrada:= ToValor(ed_valorEntrada.Text)
   else
      _valorEntrada:= 0;


   // Calculando Descontro Extra
   if _aliquota then
   Begin
       ed_valorDesconto.Text:= FormatFloat(sessao.formatsubtotal(false) ,
                          GetValorAliquota((_valorBruto-_valorDesconto),ToValor(ed_AliqDesconto.Text)
                                                ));
   end else
       ed_AliqDesconto.Text:= FormatFloat(sessao.formatAliquota(false) ,
                          GetAliquota((_valorBruto-_valorDesconto),ToValor(ed_valorDesconto.Text)
                                                ));

   ed_entrega.Text:= FormatFloat(sessao.formatsubtotal(false),ToValor(ed_entrega.Text));
   ed_acrescimo.Text:= FormatFloat(sessao.formatsubtotal(false),ToValor(ed_acrescimo.Text));
   ed_valorDesconto.Text:= FormatFloat(sessao.formatsubtotal(false),ToValor(ed_valorDesconto.Text));
   ed_valorEntrada.Text:= FormatFloat(sessao.formatsubtotal(false),ToValor(ed_valorEntrada.Text));

   _totalCrediario := Decimal(Result +
                       ToValor(ed_acrescimo.Text)+
                       ToValor(ed_entrega.Text) +
                       _valorPromocao
                       ) -
                       (ToValor(ed_valorDesconto.Text)+
                        _valorEntrada
                       );

   lTotalGeral.Caption:= FormatFloat(sessao.formatsubtotal(),_valorBruto);
   lPromocao.Caption:= FormatFloat(sessao.formatsubtotal(),_valorPromocao);

   lTotalPagar.Caption:= FormatFloat(sessao.formatsubtotal(),_totalCrediario);

   _ValorRecebimento := 0;
   if qPagamentocrediario.Value = true  then
      _ValorRecebimento   := _valorEntrada
   else
       _ValorRecebimento:= (Result +
                           ToValor(ed_acrescimo.Text)+
                           ToValor(ed_entrega.Text) +
                           _valorPromocao
                           ) -
                           (ToValor(ed_valorDesconto.Text)+
                            _valorEntrada
                           );

   _totalVenda:= (_valorBruto+_valorPromocao) -
                 (_valorDesconto+_valorDescontoExtra);


end;

function Tf_fechamento.CalculaValorStr: string;
begin
   Result  := FormatFloat(Sessao.formatsubtotal(true),CalculaValor);
end;

procedure Tf_fechamento.LoadShape(posicao: integer);
begin
  case posicao of
     1: Begin
         lShape1.Font.Color:= clYellow;
         lShape2.Font.Color:= clGray;
         lShape3.Font.Color:= clGray;
         nextShape1.Brush.Color := clGreen;
         nextShape2.Brush.Color := clWhite;
         nextShape2.Pen.Color := clWhite;
         nextShape3.Brush.Color := clWhite;
         nextShape3.Pen.Color := clWhite;
     end;
     2 : Begin
         lShape1.Font.Color:= clBlack;
         lShape2.Font.Color:= clYellow;
         lShape3.Font.Color:= clGray;
         //lShape2.Caption := '2';
         nextShape1.Brush.Color := clGreen;
         nextShape2.Brush.Color := clGreen;
         nextShape2.Pen.Color := clGreen;
         nextShape3.Brush.Color := clWhite;
     end;
     3 : Begin
         lShape1.Font.Color:= clBlack;
         lShape2.Font.Color:= clBlack;
         lShape3.Font.Color:= clYellow;
         nextShape3.Pen.Color := clGreen;
         //lShape2.Caption := '3';
         nextShape1.Brush.Color := clGreen;
         nextShape2.Brush.Color := clGreen;
         nextShape3.Brush.Color := clGreen;
     end;
     4 : Begin
         lShape1.Font.Color:= clBlack;
         lShape2.Font.Color:= clBlack;
         lShape3.Font.Color:= clBlack;
         nextShape1.Brush.Color := clGreen;
         nextShape2.Brush.Color := clGreen;
         nextShape3.Brush.Color := clGreen;
     end;
  end;
end;

procedure Tf_fechamento.SetResumo;
var _vencimento : TDate;
    _valor, _acumulado : Currency;
     i : Integer;
begin
    lCondicoes.Caption:= qPagamentodisplay_resumo.Value;
    lVendedor.Caption:= form_venda.ed_vendedor.Text;
    lCliente.Caption:= form_venda.ed_cliente.Text;
    lCPF.Caption:= form_venda.ed_cpf.Text;

    lTotal.Caption:= FormatFloat(sessao.formatsubtotal(),_valorBruto+_valorPromocao);
    lDesconto.Caption:= FormatFloat(sessao.formatsubtotal(),_valorDesconto+_valorDescontoExtra);
    lAcrescimo.Caption:= FormatFloat(sessao.formatsubtotal(),0);
    lEntrega.Caption:= FormatFloat(sessao.formatsubtotal(),ToValor(ed_entrega.Text));
    lEntrada.Caption:=FormatFloat(sessao.formatsubtotal(),_valorEntrada);
    lTotalVenda.Caption:=FormatFloat(sessao.formatsubtotal(),_totalVenda);

    pnlLabelCrediario.Visible:= false;
    gridCrediario.Visible:= false;

    if qPagamentocrediario.Value = true  then
    Begin
        pnlLabelCrediario.Visible:= true;
        gridCrediario.Visible:= true;
        _vencimento:= IncDay(sessao.DataServidor + qPagamentoprimeiro_vencimento.Value);

        if qPagamenton_parcelas.Value > 0  then
            _valor := Decimal(_totalCrediario / qPagamenton_parcelas.Value);


        qCrediario.Close;
        qCrediario.Open;
        gridCrediario.Columns[3].DisplayFormat:= sessao.formatsubtotal();
        _acumulado:= 0;

        for i := 1 to qPagamenton_parcelas.Value do
        Begin
            qCrediario.Append;
            qCrediarioDocumento.Value:= _vendaID;
            qCrediarioParcela.Value:= i;
            qCrediariovalor.Value:=_valor;
            qCrediarioVencimento.Value:= _vencimento;
            qCrediario.Post;
            _acumulado:= _acumulado + _valor;
            _vencimento:= IncDay(sessao.DataServidor + qPagamentovenciveis_de.Value);;
        end;

        if _acumulado <> _totalCrediario then
        Begin
             qCrediario.First;
             qCrediario.Edit;
             if _acumulado > _totalCrediario then
                qCrediariovalor.Value := qCrediariovalor.Value- (_acumulado-_totalCrediario)
             else
                 qCrediariovalor.Value := qCrediariovalor.Value + (_totalCrediario-_acumulado);
             qCrediario.Post;
        end;

    end;
end;

end.

