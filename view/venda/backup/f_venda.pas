unit f_venda;

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Buttons, Menus, ComCtrls, DBGrids, ActnList, Grids, BGRAShape,
  atshapelinebgra, BGRAResizeSpeedButton, BCButton, ColorSpeedButton;

type

  { Tform_venda }

  Tform_venda = class(TForm)
    ac_sair: TAction;
    ActionList1: TActionList;
    BCButton1: TBCButton;
    gridItens: TDBGrid;
    Image1: TImage;
    Image2: TImage;
    ImageList1: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    LabeledEdit3: TLabeledEdit;
    lblnome: TLabel;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    Panel1: TPanel;
    Panel11: TPanel;
    Panel2: TPanel;
    pnlTitle: TPanel;
    pnlGrid: TPanel;
    pnlColCodigo: TPanel;
    pnlColQuantidade: TPanel;
    pnlColUnitario: TPanel;
    pnlColDescricao: TPanel;
    pnlColUnitario1: TPanel;
    pnlTotal: TPanel;
    PnlCadatro: TPanel;
    pnlTotalizador: TPanel;
    pnlDireito: TPanel;
    pnlGridVendas: TPanel;
    pnlVendas: TPanel;
    pnlLateral: TPanel;
    pnlCodigo: TPanel;
    pnlImagem: TPanel;
    PopupMenu1: TPopupMenu;
    Shape1: TShape;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    Shape5: TShape;
    TabControl1: TTabControl;
    procedure ac_sairExecute(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Panel11Click(Sender: TObject);
    procedure pnlDireitoClick(Sender: TObject);
    procedure pnlGridClick(Sender: TObject);
    procedure pnlGridVendasClick(Sender: TObject);
    procedure pnlLateralClick(Sender: TObject);
    procedure Shape1ChangeBounds(Sender: TObject);
    procedure Shape3Resize(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private

  public
         Procedure ShowCliente;
         Procedure ShowCondicional;
         Procedure ShowInfProduto;
         Procedure ShowDevolucao;
         Procedure AbreCaixa;
         Procedure FechaCaixa;
         Procedure BuscaItem;
         Procedure ShowVenda(_id:string);
         Procedure listaOperacoes;
         Procedure GerarSangria;
         Procedure GerarSuprimento;
         Procedure ShowRecebimento;
         Procedure ShowPrevenda;
         Procedure ShowDelivery;
  end;

var
  form_venda: Tform_venda;

implementation

{$R *.lfm}

{ Tform_venda }

procedure Tform_venda.SpeedButton1Click(Sender: TObject);
begin

end;

procedure Tform_venda.pnlLateralClick(Sender: TObject);
begin

end;

procedure Tform_venda.Shape1ChangeBounds(Sender: TObject);
begin

end;

procedure Tform_venda.Shape3Resize(Sender: TObject);
begin
    gridItens.DefaultRowHeight:= trunc((Shape3.Height * 0.08));
    pnlTitle.Height:= gridItens.DefaultRowHeight;

    gridItens.Columns[0].Width:= trunc((Shape3.Width * 0.145));
    gridItens.Columns[1].Width:= trunc((Shape3.Width * 0.37));
    gridItens.Columns[2].Width:= trunc((Shape3.Width * 0.11));
    gridItens.Columns[3].Width:= trunc((Shape3.Width * 0.175));
    gridItens.Columns[4].Width:= trunc((Shape3.Width * 0.175));
    gridItens.TitleFont.Size := trunc((Shape3.Height * 0.030));


    pnlColCodigo.Width:= trunc((Shape3.Width * 0.145));
    pnlColDescricao.Width:= trunc((Shape3.Width * 0.37));
    pnlColQuantidade.Width:= trunc((Shape3.Width * 0.11));
    pnlColUnitario.Width:= trunc((Shape3.Width * 0.175));
    pnlColUnitario1.Width := trunc((Shape3.Width * 0.175));



    if  gridItens.TitleFont.Size < 12 then
      gridItens.TitleFont.Size := 12;

    pnlColCodigo.Font.Size:= gridItens.TitleFont.Size ;
    pnlColDescricao.Font.Size:= gridItens.TitleFont.Size ;
    pnlColQuantidade.Font.Size:= gridItens.TitleFont.Size ;
    pnlColUnitario.Font.Size:= gridItens.TitleFont.Size ;
    pnlColUnitario1.Font.Size := gridItens.TitleFont.Size ;
end;

procedure Tform_venda.FormResize(Sender: TObject);
begin
    pnlLateral.Width:= trunc((pnlVendas.Width * 0.35));

    pnlImagem.Height:= trunc((pnlLateral.Height * 0.80));
    pnlGridVendas.Height:= trunc((pnlDireito.Height * 0.80));

    pnlTotal.Width:= trunc((pnlTotalizador.Width * 0.35));
    PnlCadatro.Width:= trunc((pnlTotalizador.Width * 0.30));




    //gridItens.Columns[1].Width:= gridItens.Width -( gridItens.Columns[0].Width +
    //                                                gridItens.Columns[2].Width +
    //                                                gridItens.Columns[3].Width +
    //                                                gridItens.Columns[4].Width
    //                                               );
end;

procedure Tform_venda.ac_sairExecute(Sender: TObject);
begin
    form_venda.Close;
end;

procedure Tform_venda.Panel11Click(Sender: TObject);
begin

end;

procedure Tform_venda.pnlDireitoClick(Sender: TObject);
begin

end;

procedure Tform_venda.pnlGridClick(Sender: TObject);
begin

end;

procedure Tform_venda.pnlGridVendasClick(Sender: TObject);
begin

end;

procedure Tform_venda.ShowCliente;
begin

end;

procedure Tform_venda.ShowCondicional;
begin

end;

procedure Tform_venda.ShowInfProduto;
begin

end;

procedure Tform_venda.ShowDevolucao;
begin

end;

procedure Tform_venda.AbreCaixa;
begin

end;

procedure Tform_venda.FechaCaixa;
begin

end;

procedure Tform_venda.BuscaItem;
begin

end;

procedure Tform_venda.ShowVenda(_id: string);
begin

end;

procedure Tform_venda.listaOperacoes;
begin

end;

procedure Tform_venda.GerarSangria;
begin

end;

procedure Tform_venda.GerarSuprimento;
begin

end;

procedure Tform_venda.ShowRecebimento;
begin

end;

procedure Tform_venda.ShowPrevenda;
begin

end;

procedure Tform_venda.ShowDelivery;
begin

end;

end.

