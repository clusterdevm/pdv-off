unit uf_liquidacao;

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ActnList, frame.pagamento, jsons, ACBrEnterTab, DB;

type

  { Tf_liquidacao }

  Tf_liquidacao = class(TForm)
    ACBrEnterTab1: TACBrEnterTab;
    ac_receber: TAction;
    ac_Fechar: TAction;
    ActionList1: TActionList;
    Button1: TButton;
    framePagamento1: TframePagamento;
    Panel1: TPanel;
    qQuitacaotipo: TStringField;
    procedure ac_FecharExecute(Sender: TObject);
    procedure ac_receberExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public
       _valor : Extended;
       _liquidado : Boolean;
       _liquidacao : TJsonArray;
  end;

var
  f_liquidacao: Tf_liquidacao;

implementation

{$R *.lfm}

uses ems.utils;

procedure Tf_liquidacao.ac_FecharExecute(Sender: TObject);
begin
   self.Close;
end;

procedure Tf_liquidacao.ac_receberExecute(Sender: TObject);
begin
  _liquidado:= framePagamento1.Quitado;

  if _liquidado then
  Begin
    _liquidacao.Parse(framePagamento1.GetBaixa);
     Self.Close;
  end;
end;

procedure Tf_liquidacao.FormCreate(Sender: TObject);
begin
   _liquidado:= false;
   _liquidacao := TJsonArray.Create();


end;

procedure Tf_liquidacao.FormShow(Sender: TObject);
begin
    framePagamento1.Inicializa(_valor, 1);
    framePagamento1.ListBox1.SetFocus;
    framePagamento1.ListBox1.Selected[0] := True;
end;

end.

