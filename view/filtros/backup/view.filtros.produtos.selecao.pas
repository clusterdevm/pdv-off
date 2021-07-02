unit view.filtros.produtos.selecao;

{$mode delphi}

interface

uses
  Classes, SysUtils, BufDataset, DB, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, ComCtrls, DBGrids, LCLType;

type

  { Tf_produtosPesquisaSelecao }

  Tf_produtosPesquisaSelecao = class(TForm)
    ds: TDataSource;
    gridProdutos: TDBGrid;
    qItens: TBufDataset;
    qItensdescricao: TStringField;
    qItensgrade_id: TLongintField;
    qItensid: TLongintField;
    qItensn_marca: TStringField;
    qItenssaldo: TFloatField;
    qItensun_medida: TStringField;
    qItensvalor: TFloatField;
    StatusBar1: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure gridProdutosDblClick(Sender: TObject);
    procedure gridProdutosKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private

  public

  end;

var
  f_produtosPesquisaSelecao: Tf_produtosPesquisaSelecao;

implementation

{$R *.lfm}

uses ems.utils;

{ Tf_produtosPesquisaSelecao }

procedure Tf_produtosPesquisaSelecao.FormCreate(Sender: TObject);
begin
    qItens.CreateDataset;
    qItens.IsEmpty;
end;

procedure Tf_produtosPesquisaSelecao.gridProdutosDblClick(Sender: TObject);
begin
  if (ds.DataSet.RecordCount > 0) then
   Begin
         sessao.getID := ds.DataSet.FieldByName('id').AsString;
         sessao.gradeID := ds.DataSet.FieldByName('grade_id').AsString;
         self.Close;
   end;
end;

procedure Tf_produtosPesquisaSelecao.gridProdutosKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
    if key = vk_return then
     Begin
            key := 0;
            gridProdutosDblClick(self);
     end;
end;

end.

