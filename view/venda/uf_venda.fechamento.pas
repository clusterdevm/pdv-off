unit uf_venda.fechamento;

{$mode delphi}

interface

uses
  Classes, SysUtils, BufDataset, DB, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, DBGrids, StdCtrls, BCButton, clipbrd, frame.pagamento;

type

  { Tf_fechamento }

  Tf_fechamento = class(TForm)
    BCButton4: TBCButton;
    CheckBox1: TCheckBox;
    framePagamento1: TframePagamento;
    gridPrazo: TDBGrid;
    dsPagamento: TDataSource;
    ed_entrega: TEdit;
    ed_entrega1: TEdit;
    ed_entrega2: TEdit;
    ed_entrega3: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    lTotalGeral: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Memo1: TMemo;
    Panel1: TPanel;
    Panel10: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    qPagamento: TBufDataset;
    Panel2: TPanel;
    qPagamentoaliq_desconto: TFloatField;
    qPagamentodescricao: TStringField;
    qPagamentoid: TLongintField;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Panel1Click(Sender: TObject);
    procedure Panel9Click(Sender: TObject);
  private
        Procedure LoadPrazo;
        Function CalculaValor : Currency;
        Function CalculaValorStr : string;
  public
      _valor : Currency;
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
end;

procedure Tf_fechamento.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin

end;

procedure Tf_fechamento.FormShow(Sender: TObject);
begin
    _valor := 1000;
   LoadPrazo;
end;

procedure Tf_fechamento.Panel1Click(Sender: TObject);
begin

end;

procedure Tf_fechamento.Panel9Click(Sender: TObject);
begin

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
              qPagamentodescricao.Value:= FieldByName('descricao').AsString +' ('+CalculaValorStr+')';
              qPagamentoaliq_desconto.Value:= FieldByName('aliq_desconto').AsFloat;
              qPagamento.Post;

              Next;
         end;

     end;
  finally
    FreeAndNil(_db);
  end;
end;

function Tf_fechamento.CalculaValor: Currency;
begin
   if qPagamentoaliq_desconto.Value > 0 then
      Result := _valor - (_valor * qPagamentoaliq_desconto.Value)/100
   else
      Result := _valor;
end;

function Tf_fechamento.CalculaValorStr: string;
begin
   Result  := FormatFloat(Sessao.formatsubtotal(true),CalculaValor);
end;

end.

