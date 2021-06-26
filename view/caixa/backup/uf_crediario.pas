unit uf_crediario;

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, DBGrids,
  ActnList, StdCtrls, frame.cliente.localiza, BCButton;

type

  { Tf_crediario }

  Tf_crediario = class(TForm)
    ac_pendencia: TAction;
    ac_ImpVenda: TAction;
    ac_cancelar: TAction;
    ac_concluir: TAction;
    ActionList1: TActionList;
    BCButton10: TBCButton;
    BCButton11: TBCButton;
    BCButton12: TBCButton;
    BCButton3: TBCButton;
    DBGrid1: TDBGrid;
    ed_geral: TEdit;
    ed_pago: TEdit;
    ed_acrescimo: TEdit;
    ed_pendente: TEdit;
    framePessoaGet1: TframePessoaGet;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    procedure EditIDEnter(Sender: TObject);
    procedure EditIDExit(Sender: TObject);
  private
       _temp : string;
  public

  end;

var
  f_crediario: Tf_crediario;

implementation

{$R *.lfm}

{ Tf_crediario }

procedure Tf_crediario.EditIDEnter(Sender: TObject);
begin
    _temp := (sender as TEdit).Text;
end;

procedure Tf_crediario.EditIDExit(Sender: TObject);
begin
  if (_temp <> (Sender as TEdit).Text) or (trim(_temp) = '') then
  Begin
       if not framePessoaGet1.Localiza then
       Begin
          (Sender as TEdit).SetFocus;
           Abort;
       end;
  end;
end;

end.

