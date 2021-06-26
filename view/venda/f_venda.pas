unit f_venda;

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Buttons, Menus, ComCtrls, DBGrids, ActnList, Grids, view.condicional.filtrar,
  view.devolucao.filtrar, uf_crediario, VTHeaderPopup, BGRAShape,
  atshapelinebgra, BGRAResizeSpeedButton, BCButton, ColorSpeedButton;

type

  { Tform_venda }

  Tform_venda = class(TForm)
    ac_recebimento: TAction;
    ac_devolucao: TAction;
    ac_condicional: TAction;
    ac_suprimento: TAction;
    ac_sangria: TAction;
    ac_fechaCaixa: TAction;
    ac_abreCaixa: TAction;
    ac_sair: TAction;
    ActionList1: TActionList;
    BCButton1: TBCButton;
    BCButton10: TBCButton;
    BCButton11: TBCButton;
    BCButton2: TBCButton;
    BCButton3: TBCButton;
    BCButton4: TBCButton;
    BCButton5: TBCButton;
    BCButton6: TBCButton;
    BCButton8: TBCButton;
    BCButton9: TBCButton;
    gridItens: TDBGrid;
    Image1: TImage;
    Image2: TImage;
    ImageList1: TImageList;
    lblUsuario: TLabel;
    Label2: TLabel;
    lblCodigo: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    ed_cliente: TLabeledEdit;
    ed_vendedor: TLabeledEdit;
    ed_cpf: TLabeledEdit;
    lblDadosEmpresa: TLabel;
    MenuItem1: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    pnlBase: TPanel;
    Panel11: TPanel;
    pnlBotoes: TPanel;
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
    SpeedButton1: TSpeedButton;
    TabControl1: TTabControl;
    VTHeaderPopupMenu1: TVTHeaderPopupMenu;
    procedure ac_abreCaixaExecute(Sender: TObject);
    procedure ac_condicionalExecute(Sender: TObject);
    procedure ac_devolucaoExecute(Sender: TObject);
    procedure ac_fechaCaixaExecute(Sender: TObject);
    procedure ac_recebimentoExecute(Sender: TObject);
    procedure ac_sairExecute(Sender: TObject);
    procedure ac_sangriaExecute(Sender: TObject);
    procedure ac_suprimentoExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Panel11Click(Sender: TObject);
    procedure pnlBotoesClick(Sender: TObject);
    procedure pnlDireitoClick(Sender: TObject);
    procedure pnlGridClick(Sender: TObject);
    procedure pnlGridVendasClick(Sender: TObject);
    procedure pnlLateralClick(Sender: TObject);
    procedure Shape1ChangeBounds(Sender: TObject);
    procedure Shape3Resize(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
        Procedure LimpaTela;
        Procedure GetVendasAndamento;
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

         Procedure SetVendaLayout(_venda : Integer);

  end;

var
  form_venda: Tform_venda;

implementation

{$R *.lfm}

uses classe.utils;

procedure Tform_venda.SpeedButton1Click(Sender: TObject);
begin
  PopupMenu1.PopUp(mouse.CursorPos.X-120, mouse.CursorPos.y-20);
end;

procedure Tform_venda.LimpaTela;
begin
    pnlTotal.Caption:= FormatFloat(sessao.formatsubtotal,0);
    ed_cliente.Text:=  'Consumidor';
    ed_vendedor.Text:=  'Não Definido';
    ed_cpf.Text:= '';
    lblCodigo.Caption:= '';
    pnlBase.Visible:= sessao.GetCaixa <> '';

    pnlCodigo.Visible:= false;
    pnlImagem.Visible:= false;
    pnlDireito.Visible:= false;
end;

procedure Tform_venda.GetVendasAndamento;
begin
   LimpaTela;
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
    pnlCodigo.Height:= pnlLateral.Height - pnlImagem.Height;

    pnlGridVendas.Height:= trunc((pnlDireito.Height * 0.80));

    pnlTotal.Width:= trunc((pnlTotalizador.Width * 0.35));
    PnlCadatro.Width:= trunc((pnlTotalizador.Width * 0.30));




    //gridItens.Columns[1].Width:= gridItens.Width -( gridItens.Columns[0].Width +
    //                                                gridItens.Columns[2].Width +
    //                                                gridItens.Columns[3].Width +
    //                                                gridItens.Columns[4].Width
    //                                               );
end;

procedure Tform_venda.FormShow(Sender: TObject);
begin
  TabControl1.Tabs.Clear;
  lblUsuario.Caption:= 'Usuario: '+ Sessao.usuarioName;
  lblDadosEmpresa.Caption:= sessao.cidade+'  '+FormatDateTime('dddd "de" mmmm "de" yyyy',Now) +'   ('+
                             sessao.n_unidade+')';
  GetVendasAndamento;
end;

procedure Tform_venda.ac_sairExecute(Sender: TObject);
begin
    form_venda.Close;
end;

procedure Tform_venda.ac_sangriaExecute(Sender: TObject);
begin
    sessao.Sangria;
end;

procedure Tform_venda.ac_suprimentoExecute(Sender: TObject);
begin
  //
  sessao.suprimento;
end;

procedure Tform_venda.ac_abreCaixaExecute(Sender: TObject);
begin
    if pnlBase.Visible  = false then
    Begin
        sessao.AbreCaixa;
        GetVendasAndamento;
    end else
    Begin
         messagedlg('Ja Existe um caixa aberto em andamento',mtWarning,[mbok],0);
    end;
end;

procedure Tform_venda.ac_condicionalExecute(Sender: TObject);
begin
  CriarForm(Tfrm_CondicionalFIltrar);
end;

procedure Tform_venda.ac_devolucaoExecute(Sender: TObject);
begin
  CriarForm(Tf_devolucaoFiltrar);
end;

procedure Tform_venda.ac_fechaCaixaExecute(Sender: TObject);
begin
    if pnlBase.Visible  = false then
        messagedlg('Este Checkout não possui caixa em aberto',mtWarning,[mbok],0)
    else
    Begin
        sessao.FechaCaixa;
        GetVendasAndamento;
    end;


end;

procedure Tform_venda.ac_recebimentoExecute(Sender: TObject);
begin
  CriarForm(Tf_crediario);
end;

procedure Tform_venda.FormCreate(Sender: TObject);
begin

end;

procedure Tform_venda.FormKeyPress(Sender: TObject; var Key: char);
begin

  if pnlBase.Visible = false then

      exit;

  if Key = '.' then
    Key := ',';

  if Key = #13 then
  Begin
      Key := #0;
      if Length(lblCodigo.Caption) > 0 then
        // RegistraItem;

  end
  else if Key = #08 then
  begin
    Key := #0;
    lblCodigo.Caption := Copy(lblCodigo.Caption, 0, Length(lblCodigo.Caption) - 1);
  end
  else if Key = #27 then
  begin
    Key := #0;
    if trim(lblCodigo.Caption) <> '' then
      lblCodigo.Caption := ''
  end
  else
  Begin
    if not(Key in ['0' .. '9', Chr(8), 'A'..'Z','a'..'z', '*', ',']) then
      Key := #0
    else
      lblCodigo.Caption := lblCodigo.Caption + Key;

    Key := #0;
  End;

  if TabControl1.Tabs.Count = 0  then
     pnlCodigo.Visible := trim(lblCodigo.Caption) <> '';
end;

procedure Tform_venda.Panel11Click(Sender: TObject);
begin

end;

procedure Tform_venda.pnlBotoesClick(Sender: TObject);
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

procedure Tform_venda.SetVendaLayout(_venda: Integer);
begin
   if _venda = 0 then
     LimpaTela;
end;

end.

