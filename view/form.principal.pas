unit form.principal;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  ActnList, StdCtrls, DTAnalogClock,
  view.condicional.filtrar, f_venda, model.sinc.down, classe.utils;

type

  { TfrmPrincipal }

  TfrmPrincipal = class(TForm)
    ac_venda: TAction;
    ac_sair: TAction;
    ac_condicional: TAction;
    ActionList1: TActionList;
    DTAnalogClock1: TDTAnalogClock;
    Image2: TImage;
    lblUsuario: TLabel;
    lblCNPJ2: TLabel;
    lblCNPJ: TLabel;
    lblUnidade2: TLabel;
    lblUnidade: TLabel;
    Panel1: TPanel;
    pnlLoja: TPanel;
    pnlButton: TPanel;
    pnlButtonCenter: TPanel;
    pnl_opcoes: TPanel;
    pnl_menu: TPanel;
    Panel3: TPanel;
    pnlCluster: TPanel;
    pnlRodape: TPanel;
    pnl_sair: TPanel;
    ScrollBox1: TScrollBox;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    procedure ac_condicionalExecute(Sender: TObject);
    procedure ac_sairExecute(Sender: TObject);
    procedure ac_vendaExecute(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure pnl_menuClick(Sender: TObject);
    procedure pnl_menuMouseEnter(Sender: TObject);
    procedure pnl_menuMouseLeave(Sender: TObject);
    procedure pnl_sairMouseEnter(Sender: TObject);
    procedure pnl_sairMouseLeave(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
  private
       Procedure AtivaBusca;
  public

  end;

var
  frmPrincipal: TfrmPrincipal;

implementation


{$R *.lfm}

{ TfrmPrincipal }

procedure TfrmPrincipal.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin

  canclose := false;

  if messagedlg('Sair do Sistema?',mtWarning,[mbno,mbyes],0)= mryes then
  Begin
     FreeAndNil(Sessao);
     FreeAndNil(WCursor);
     CanClose:=true;
     Application.Terminate;
  end;
end;

procedure TfrmPrincipal.FormResize(Sender: TObject);
begin
  pnlCluster.top := (self.Height div 2) - (pnlCluster.height div 2);
  pnlCluster.left := (self.Width div 2) - (pnlCluster.width div 2);

  pnlButtonCenter.left := (pnlButton.Width div 2) - (pnlButtonCenter.width div 2);
end;

procedure TfrmPrincipal.ac_condicionalExecute(Sender: TObject);
begin
  sessao.ShowForm(Tfrm_CondicionalFIltrar,frm_CondicionalFIltrar);
end;

procedure TfrmPrincipal.ac_sairExecute(Sender: TObject);
begin
  frmPrincipal.Close;
end;

procedure TfrmPrincipal.ac_vendaExecute(Sender: TObject);
begin
  sessao.ShowForm(Tform_venda, form_venda);
end;

procedure TfrmPrincipal.FormActivate(Sender: TObject);
begin
    pnlLoja.Caption:= '    '+sessao.nomeFantasia;
    lblCNPJ.Caption:= (FormataCNPJ(sessao.cnpj));
    lblUnidade.Caption:= Sessao.n_unidade;

    lblUsuario.Caption:= ' Usuario: '+ sessao.usuarioName ;
end;

procedure TfrmPrincipal.FormShow(Sender: TObject);
begin
  AtivaBusca;
end;

procedure TfrmPrincipal.pnl_menuClick(Sender: TObject);
begin
  if not (pnl_opcoes.Visible) then
  Begin
       pnl_opcoes.Visible:= true;
  end else
     pnl_opcoes.Visible:= false;
end;

procedure TfrmPrincipal.pnl_menuMouseEnter(Sender: TObject);
begin
  pnl_menu.BevelInner:=  bvRaised;
end;

procedure TfrmPrincipal.pnl_menuMouseLeave(Sender: TObject);
begin
    pnl_menu.BevelInner:=  bvNone;
end;

procedure TfrmPrincipal.pnl_sairMouseEnter(Sender: TObject);
begin
  pnl_sair.BevelInner:=  bvRaised;
end;

procedure TfrmPrincipal.pnl_sairMouseLeave(Sender: TObject);
begin
  pnl_sair.BevelInner:=  bvNone;
end;

procedure TfrmPrincipal.SpeedButton4Click(Sender: TObject);
begin

end;

procedure TfrmPrincipal.AtivaBusca;
var _sincronizar : TSincDownload;
begin
  _sincronizar := TSincDownload.Create(true,
                                 pnlRodape ,
                                 sessao.token
                               );
  _sincronizar.Start;
end;

end.

