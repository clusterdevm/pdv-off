unit uf_fechamentoCaixa;

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ActnList, Spin, ACBrEnterTab, SpinEx;

type

  { Tf_fechamentoCaixa }

  Tf_fechamentoCaixa = class(TForm)
    ACBrEnterTab1: TACBrEnterTab;
    Action1: TAction;
    Action2: TAction;
    ActionList1: TActionList;
    Button1: TButton;
    Button2: TButton;
    ed_credito: TFloatSpinEditEx;
    ed_efetivo: TFloatSpinEditEx;
    ed_debito: TFloatSpinEditEx;
    ed_vale: TFloatSpinEditEx;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    mObsCaixa: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    procedure Action1Execute(Sender: TObject);
    procedure Action2Execute(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  f_fechamentoCaixa: Tf_fechamentoCaixa;

implementation

{$R *.lfm}

{ Tf_fechamentoCaixa }

uses ems.conexao, ems.utils;

procedure Tf_fechamentoCaixa.FormShow(Sender: TObject);
begin
    ed_efetivo.SetFocus;
end;

procedure Tf_fechamentoCaixa.Action1Execute(Sender: TObject);
begin
  self.Close;
end;

procedure Tf_fechamentoCaixa.Action2Execute(Sender: TObject);
var _db : TConexao;
begin
try
   try
        _db := TConexao.Create;
        with _db.qryPost do
        Begin
            Close;
            Sql.Clear;
            Sql.Add('update financeiro_caixa set status = ''F'' ');
            Sql.add(', sinc_pendente = ''S'' ');
            Sql.Add(', data_fechamento = '+QuotedStr(getDataUTC));
            Sql.Add(', inf_caixa = '+QuotedStr(mObsCaixa.Text));
            Sql.Add(', saldo_fechamento = '+QuotedStr(prepara_valor(GetFloat(ed_efetivo.text))));
            Sql.Add(', saldo_fechamentocredito = '+QuotedStr(prepara_valor(GetFloat(ed_credito.text))));
            Sql.Add(', saldo_fechamentodebito = '+QuotedStr(prepara_valor(GetFloat(ed_debito.text))));
            Sql.Add(', saldo_fechamentovale = '+QuotedStr(prepara_valor(GetFloat(ed_vale.text))));
            Sql.add(' where hibrido_id = '+QuotedStr(IntToStr(sessao.GetCaixa));
            ExecSQL;

            messagedlg('Caixa Fechado',mtInformation,[mbok],0);
            self.Close;
        end;
   finally
        FreeAndNil(_db);
   end;

except
  on e:exception do
  Begin
       RegistraLogErro('Fechamento caixa : '+e.message);
  end;
end;
end;

end.

