unit uf_venda.fechamento;

{$mode delphi}

interface

uses
  Classes, SysUtils, BufDataset, DB, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, DBGrids, StdCtrls, BCButton, JvBaseEdits, clipbrd, ComCtrls,
  ActnList, EditBtn, Spin, ACBrEnterTab, RTTICtrls, SynEdit, SpinEx,
  frame.pagamento, math, jsons, Types, Grids,LCLProc,LCLtype;

type

  { Tf_fechamento }

  Tf_fechamento = class(TForm)
    ACBrEnterTab1: TACBrEnterTab;
    ac_fechar: TAction;
    ActionList1: TActionList;
    BCButton4: TBCButton;
    CheckBox1: TCheckBox;
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
    Label6: TLabel;
    lShape1: TLabel;
    lShape2: TLabel;
    lShape3: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    lTotalPagar: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lTotalGeral: TLabel;
    Memo1: TMemo;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel10: TPanel;
    Panel11: TPanel;
    Panel12: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    qPagamento: TBufDataset;
    qPagamentoaliq_desconto: TFloatField;
    qPagamentoaliq_desconto1: TFloatField;
    qPagamentocrediario: TBooleanField;
    qPagamentodescricao: TStringField;
    qPagamentodescricao1: TStringField;
    qPagamentoid: TLongintField;
    qPagamentoid1: TLongintField;
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

  public
      _valorBruto, _valorPromocao, _valorDesconto, _valorDescontoExtra, _valorEntrada, _ValorRecebimento : Currency;
  end;

var
  f_fechamento: Tf_fechamento;

implementation

{$R *.lfm}

uses model.conexao, classe.utils;

procedure Tf_fechamento.FormCreate(Sender: TObject);
begin
   qPagamento.CreateDataset;
   qPagamento.Open;
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
begin
  case PageControl1.PageIndex of
   0 : Begin
       PageControl1.PageIndex:= 1;
       Frame.Inicializa(_ValorRecebimento);
       Frame.ListBox1.SetFocus;
       Frame.ListBox1.Selected[0] := True
       ;
       ac_fechar.Caption:= 'Proximo (F6)';
       LoadShape(2);
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
      Showmessage('concluir');
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
    _valorBruto := 1000;
    _valorEntrada:= 0;
    _valorDescontoExtra:= 0;
    _valorDesconto:= 0;
    _valorPromocao:= 0;

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
     with _db.Query do
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
              qPagamentocrediario.Value:= trim(FieldByName('tipo_forma').AsString) = 'crediario';
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

   lTotalGeral.Caption:= FormatFloat(sessao.formatsubtotal(),Result);
   lTotalPagar.Caption:= FormatFloat(sessao.formatsubtotal(),(Result +
                                                             ToValor(ed_acrescimo.Text)+
                                                             ToValor(ed_entrega.Text) +
                                                             _valorPromocao
                                                             ) -
                                                             (ToValor(ed_valorDesconto.Text)+
                                                              _valorEntrada
                                                             )
                                                             );

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

end.

