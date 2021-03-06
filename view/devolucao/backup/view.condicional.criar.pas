unit view.condicional.criar;

{$mode delphi}

interface

uses
  Classes, SysUtils, fphttpclient, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ActnList, ACBrEnterTab, BCImageButton, ColorSpeedButton, BCComboBox,
  BGRASpeedButton, frame.empresa, frame.cliente.localiza,
  controller.condicional, classe.utils;

type

  { TfrmCondicionalCriar }

  TfrmCondicionalCriar = class(TForm)
    ACBrEnterTab1: TACBrEnterTab;
    Action1: TAction;
    Action2: TAction;
    ac_cliente: TAction;
    ac_iniciar: TAction;
    ActionList1: TActionList;
    BGRASpeedButton1: TBGRASpeedButton;
    Frame1_1: TFrame1;
    frame_cliente: TframePessoaGet;
    frame_vendedor: TframePessoaGet;
    Panel1: TPanel;
    procedure Action1Execute(Sender: TObject);
    procedure ac_clienteExecute(Sender: TObject);
    procedure ac_iniciarExecute(Sender: TObject);
    procedure EditIDEnter(Sender: TObject);
    procedure EditIDExit(Sender: TObject);
    procedure EditIDKeyPress(Sender: TObject; var Key: char);
    procedure EditIDVENDEDORKeyPress(Sender: TObject; var Key: char);
    procedure FormShow(Sender: TObject);
  private

  public
      _temp : string;

  end;

var
  frmCondicionalCriar: TfrmCondicionalCriar;

implementation

{$R *.lfm}

{ TfrmCondicionalCriar }

procedure TfrmCondicionalCriar.FormShow(Sender: TObject);
begin
  Frame1_1.carregaEmpresa;
  frame_vendedor.EditID.SetFocus;
end;

procedure TfrmCondicionalCriar.EditIDEnter(Sender: TObject);
begin
  _temp := (sender as TEdit).Text;
end;

procedure TfrmCondicionalCriar.Action1Execute(Sender: TObject);
begin
    frmCondicionalCriar.Close;
end;

procedure TfrmCondicionalCriar.ac_clienteExecute(Sender: TObject);
begin
  if (_temp <> (Sender as TEdit).Text) or (trim(_temp) = '') then
  Begin
       if not frame_cliente.Localiza then
       Begin
          (Sender as TEdit).SetFocus;
          Abort;
       end;
  end;
end;

procedure TfrmCondicionalCriar.ac_iniciarExecute(Sender: TObject);
var _condicional : Tcondicional ;
  aux : string;
begin
   try
     _condicional:= Tcondicional.Create;
     _condicional.empresa_id:= StrToInt(Frame1_1.GetItem);

     _condicional.vendedor_id :=frame_vendedor.getID;
     _condicional.cliente_id := frame_cliente.getID;
     _condicional.operador_id := Sessao.usuario_id;
     if _condicional.Iniciar then
        self.Close;
   finally
     FreeAndNil(_condicional);
   end;
end;

procedure TfrmCondicionalCriar.EditIDExit(Sender: TObject);
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

procedure TfrmCondicionalCriar.EditIDKeyPress(Sender: TObject; var Key: char);
begin

end;

procedure TfrmCondicionalCriar.EditIDVENDEDORKeyPress(Sender: TObject;
  var Key: char);
begin

end;




end.

