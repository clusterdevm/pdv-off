unit view.condicional.criar;

{$mode delphi}

interface

uses
  Classes, SysUtils, fphttpclient, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ActnList, MaskEdit, ACBrEnterTab, BCImageButton, ColorSpeedButton,
  BCComboBox, BGRASpeedButton, frame.empresa, frame.cliente.localiza,
  frame.tabelaPrecos, controller.condicional, ems.utils;

type

  { TfrmCondicionalCriar }

  TfrmCondicionalCriar = class(TForm)
    ACBrEnterTab1: TACBrEnterTab;
    Action1: TAction;
    Action2: TAction;
    ac_vendedor: TAction;
    ac_iniciar: TAction;
    ActionList1: TActionList;
    BGRASpeedButton1: TBGRASpeedButton;
    Button1: TButton;
    Button2: TButton;
    frame_Cliente: TframePessoaGet;
    frame_vendedor: TframePessoaGet;
    frame_tabelasPrecos1: Tframe_tabelasPrecos;
    Label1: TLabel;
    edtDataEntrega: TMaskEdit;
    pnlBase: TPanel;
    pnlInicia: TPanel;
    pnlOperacao: TPanel;
    procedure Action1Execute(Sender: TObject);
    procedure ac_iniciarExecute(Sender: TObject);
    procedure ac_vendedorExecute(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure EditIDEnter(Sender: TObject);
    procedure EditIDExit(Sender: TObject);
  private
       _Operacao : Integer;

       Procedure Ativa(_tipo:integer);
  public
      _temp : string;

  end;

var
  frmCondicionalCriar: TfrmCondicionalCriar;

implementation

{$R *.lfm}

{ TfrmCondicionalCriar }

procedure TfrmCondicionalCriar.Ativa(_tipo: integer);
begin
   _Operacao:= _tipo;
   frame_tabelasPrecos1.Carrega;
   edtDataEntrega.Text:= FormatDateTime('dd/mm/yyyy',now + 7);

   pnlInicia.Visible:= true;
   pnlOperacao.Visible:= false;
   pnlBase.Visible:= true;
   frame_Cliente.EditID.SetFocus;
   frame_vendedor.onlyColaborador:= true;
   frame_Cliente.onlyColaborador:= false;

   frmCondicionalCriar.Height := frmCondicionalCriar.Height - pnlOperacao.Height;
end;

procedure TfrmCondicionalCriar.EditIDEnter(Sender: TObject);
begin
  _temp := (sender as TEdit).Text;
end;

procedure TfrmCondicionalCriar.EditIDExit(Sender: TObject);
begin
   if (_temp <> (Sender as TEdit).Text) or (trim(_temp) = '') then
   Begin
        if not frame_Cliente.Localiza then
        Begin
           (Sender as TEdit).SetFocus;
            Abort;
        end;
   end;
end;

procedure TfrmCondicionalCriar.Action1Execute(Sender: TObject);
begin
    frmCondicionalCriar.Close;
end;

procedure TfrmCondicionalCriar.ac_iniciarExecute(Sender: TObject);
var _condicional : Tcondicional ;
  aux : string;
begin
   if not pnlInicia.Visible then
      exit;

   try
     _condicional:= Tcondicional.Create;
     _condicional.empresa_id:= sessao.empresalogada;
     _condicional.tipo_operacao := _Operacao;
     _condicional.tabela_preco_id := frame_tabelasPrecos1.getID;

     _condicional.vendedor_id :=frame_vendedor.getID;
     _condicional.cliente_id := frame_cliente.getID;
     _condicional.operador_id := Sessao.usuario_id;
     if _condicional.Iniciar then
        self.Close;
   finally
     FreeAndNil(_condicional);
   end;
end;

procedure TfrmCondicionalCriar.ac_vendedorExecute(Sender: TObject);
begin
   if (_temp <> (Sender as TEdit).Text) or (trim(_temp) = '') then
   Begin
        if not frame_vendedor.Localiza then
        Begin
           (Sender as TEdit).SetFocus;
            Abort;
        end;
   end;
end;

procedure TfrmCondicionalCriar.Button1Click(Sender: TObject);
begin
    Ativa(1);
end;

procedure TfrmCondicionalCriar.Button2Click(Sender: TObject);
begin
   Ativa(2);
end;

end.

