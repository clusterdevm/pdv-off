unit uf_saidaCaixa;

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ActnList,
  ExtCtrls, Spin, SpinEx, frame.cliente.localiza, report.sangria, jsons,
  ACBrEnterTab;

type

  { Tf_saidaCaixa }

  Tf_saidaCaixa = class(TForm)
    ACBrEnterTab1: TACBrEnterTab;
    ac_cancelar: TAction;
    ac_confirma: TAction;
    ActionList1: TActionList;
    Button1: TButton;
    Button2: TButton;
    ed_valor: TFloatSpinEditEx;
    framePessoa: TframePessoaGet;
    Label1: TLabel;
    Label2: TLabel;
    m_obs: TMemo;
    procedure ac_cancelarExecute(Sender: TObject);
    procedure ac_confirmaExecute(Sender: TObject);
    procedure EditIDEnter(Sender: TObject);
    procedure EditIDExit(Sender: TObject);
    procedure EditIDKeyPress(Sender: TObject; var Key: char);
    procedure FormShow(Sender: TObject);
  private

  public
       _endpoint, _caixaID : String;
       _temp : string;

  end;

var
  f_saidaCaixa: Tf_saidaCaixa;

implementation

{$R *.lfm}

uses model.request.http, classe.utils;

{ Tf_saidaCaixa }

procedure Tf_saidaCaixa.FormShow(Sender: TObject);
begin
  m_obs.Lines.Clear;
  framePessoa.EditID.SetFocus;
end;

procedure Tf_saidaCaixa.ac_cancelarExecute(Sender: TObject);
begin
  f_saidaCaixa.Close;
end;

procedure Tf_saidaCaixa.ac_confirmaExecute(Sender: TObject);
var _api : TRequisicao;
    _body : TJsonObject;
begin
   try
       WCursor.SetWait;
      _api := TRequisicao.Create;
      _body := TJsonObject.Create;
      _body.Put('pessoa_id',framePessoa.getID);
      _body.Put('valor',GetFloat(ed_valor.Text));
      _body.Put('obs',m_obs.Text);
      _body.Put('empresa_id',sessao.empresalogada);
      with _Api do
      Begin
          Metodo:='post';
          Body.Text:= _body.Stringify;
          tokenBearer := GetBearerEMS;
          webservice := getEMS_Webservice(mFinanceiro);
          rota:='financeiro/checkout';
          endpoint:=_caixaID+'/'+_endpoint;
          Execute;

          if (ResponseCode in [200..207]) then
          Begin
             try
                f_sangriaReport := Tf_sangriaReport.Create(self);
                f_sangriaReport.GetSangriaReport(_api.Return,_endpoint ='sangria');
             finally
                FreeAndNil(f_sangriaReport);
             end;
             self.Close;
          end
          else
             messagedlg('#150 Contate suporte: '+_Api.response,mtError,[mbok],0);
      end;

   finally
      WCursor.SetNormal;
      FreeAndNil(_body);
      FreeAndNil(_api);
   end;
end;

procedure Tf_saidaCaixa.EditIDEnter(Sender: TObject);
begin
  _temp:= framePessoa.EditID.Text;
end;

procedure Tf_saidaCaixa.EditIDExit(Sender: TObject);
begin
    if (_temp <> framePessoa.EditID.Text) or (_temp = '' ) then
       if not framePessoa.Localiza then
       Begin
          (Sender as TEdit).SetFocus;
          Abort;
       end;
end;

procedure Tf_saidaCaixa.EditIDKeyPress(Sender: TObject; var Key: char);
begin
  if key= #13 then
  Begin
     key := #0;
     if framePessoa._avancar then
        PerformTab(true)//Perform(WM_NEXTDLGCTL,0,0);
  end;
end;

end.

