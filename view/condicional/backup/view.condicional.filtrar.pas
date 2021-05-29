unit view.condicional.filtrar;

{$mode delphi}

interface

uses
  Classes, SysUtils, DB, BufDataset, Forms, Controls, Graphics, Dialogs,
  ComCtrls, ExtCtrls, Buttons, ActnList, DBGrids, StdCtrls, ComboEx,
  ACBrEnterTab, uf_base, view.condicional.criar, controller.condicional,
  classe.utils, frame.empresa, frame.status, LCLType, Menus, EditBtn;

type

  { Tfrm_CondicionalFIltrar }

  Tfrm_CondicionalFIltrar = class(TForm1)
    ACBrEnterTab1: TACBrEnterTab;
    acBuscar: TAction;
    acNovo: TAction;
    Action1: TAction;
    acEditar: TAction;
    acInativar: TAction;
    ActionList1: TActionList;
    cds_condicional: TBufDataset;
    cds_condicionalcli_nome: TStringField;
    cds_condicionaldataatualizacao: TDateTimeField;
    cds_condicionaldata_conclusao: TDateTimeField;
    cds_condicionaldata_emissao: TDateTimeField;
    cds_condicionalid: TLongintField;
    cds_condicionalnomeresumido: TStringField;
    cds_condicionalstatus: TStringField;
    cds_condicionaltotal_pendente: TCurrencyField;
    cds_condicionaltotal_vendido: TCurrencyField;
    cds_condicionalvend_nome: TStringField;
    DBGrid1: TDBGrid;
    ds_condicional: TDataSource;
    edt_nome: TEdit;
    ed_emissao_final: TDateEdit;
    ed_conclusao_final: TDateEdit;
    ed_emissao_inicial: TDateEdit;
    ed_conclusao_inicial: TDateEdit;
    Frame1_1: TFrame1;
    Frame2_1: TFrame2;
    Label1: TLabel;
    anel2: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    PopupMenu1: TPopupMenu;
    procedure acInativarExecute(Sender: TObject);
    procedure acNovoExecute(Sender: TObject);
    procedure Action1Execute(Sender: TObject);
    procedure ac_buscarExecute(Sender: TObject);
    procedure acEditarExecute(Sender: TObject);
    procedure cb_statusChange(Sender: TObject);
    procedure DBGrid1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edt_nomeKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
      );
    procedure ed_conclusao_inicialChange(Sender: TObject);
    procedure ed_emissao_finalChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Label4Click(Sender: TObject);
  private

  public

  end;

var
  frm_CondicionalFIltrar: Tfrm_CondicionalFIltrar;

implementation

{$R *.lfm}

{ Tfrm_CondicionalFIltrar }

procedure Tfrm_CondicionalFIltrar.ac_buscarExecute(Sender: TObject);
var condicional : TCondicional;
begin
  try
     condicional := TCondicional.Create;
     condicional.nome:= edt_nome.text;

     condicional.Filtrar(cds_condicional,
                         Frame2_1.GetArray,
                         Frame1_1.GetArray,
                         ed_emissao_inicial.Text,
                         ed_emissao_final.Text,
                         ed_conclusao_inicial.Text,
                         ed_conclusao_final.Text
                         );

     DBGrid1.Columns[2].Visible := trim(LowerCase(Frame2_1.cb_status.Text)) = 'faturada';
     DBGrid1.Columns[3].Visible := not DBGrid1.Columns[2].Visible;

  finally
    StatusBar1.Panels[0].Text:='Registro(s) Encontrado(s):'+IntToStr(cds_condicional.RecordCount) ;
    FreeAndNil(condicional);
  end;
end;

procedure Tfrm_CondicionalFIltrar.acEditarExecute(Sender: TObject);
var condicional : TCondicional;
begin
   try
      condicional := TCondicional.Create;
      condicional.id := cds_condicionalid.AsInteger;
      Condicional.Get;
   finally
     FreeAndNil(condicional);
   end;
end;

procedure Tfrm_CondicionalFIltrar.cb_statusChange(Sender: TObject);
begin
 try
    ed_conclusao_inicial.OnChange:= nil;
    ed_conclusao_final.OnChange:= nil;

    ed_conclusao_inicial.Enabled:= false;
    ed_conclusao_final.Enabled:= false;

      if Frame2_1.GetString = 'faturada' then
      Begin
           ed_conclusao_inicial.Enabled:= true;
           ed_conclusao_final.Enabled:= true;
           if (ed_conclusao_inicial.Text='') and (ed_conclusao_final.Text = '') then
           Begin
                ed_conclusao_inicial.Text:= FormatDateTime('dd/mm/yyyy',now);
                ed_conclusao_final.Text:= FormatDateTime('dd/mm/yyyy',now);
           end;
      end else
      Begin
          ed_conclusao_inicial.Text:= '';
          ed_conclusao_final.Text:= '';
      end;
  finally
     ed_conclusao_inicial.OnChange:= ac_buscarExecute();
     ed_conclusao_final.OnChange:= ac_buscarExecute();
  end;
  ac_buscarExecute(self);
end;

procedure Tfrm_CondicionalFIltrar.DBGrid1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if key = VK_UP then
  Begin
      if cds_condicional.RecordCount > 0 then
      Begin
           if cds_condicional.RecNo = 1 then
              edt_nome.SetFocus;
      end;
  end;
end;

procedure Tfrm_CondicionalFIltrar.edt_nomeKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  IF key = vk_down then
     DBGrid1.SetFocus;
end;

procedure Tfrm_CondicionalFIltrar.ed_conclusao_inicialChange(Sender: TObject);
begin

end;

procedure Tfrm_CondicionalFIltrar.ed_emissao_finalChange(Sender: TObject);
begin

end;

procedure Tfrm_CondicionalFIltrar.acNovoExecute(Sender: TObject);
begin
    frmCondicionalCriar := TfrmCondicionalCriar.Create(self);
    frmCondicionalCriar.ShowModal;
    edt_nome.SetFocus;
    ac_buscarExecute(self);
end;

procedure Tfrm_CondicionalFIltrar.acInativarExecute(Sender: TObject);
var condicional : TCondicional;
begin
   try
      condicional := TCondicional.Create;
      condicional.id := cds_condicionalid.AsInteger;
      Condicional.Cancelar;
      ac_buscarExecute(Self);
      edt_nome.SetFocus;
   finally
     FreeAndNil(condicional);
   end;
end;

procedure Tfrm_CondicionalFIltrar.Action1Execute(Sender: TObject);
begin
   self.Close;
end;

procedure Tfrm_CondicionalFIltrar.FormCreate(Sender: TObject);
begin
  cds_condicional.CreateDataset;
  cds_condicional.Open;

  Frame2_1.cb_status.Clear;
  with Frame2_1.cb_status.Items do
  Begin
     Add('Rascunho');
     Add('Cancelada');
     Add('Faturada');
     Add('Pendente');
  end;
  Frame2_1.cb_status.ItemIndex:=0;

  Frame1_1.carregaEmpresa;

  DBGrid1.Columns[1].DisplayFormat:= Sessao.datetimeformat;
  DBGrid1.Columns[2].DisplayFormat:= Sessao.datetimeformat;
  DBGrid1.Columns[3].DisplayFormat:= Sessao.datetimeformat;

  DBGrid1.Columns[5].DisplayFormat:=Sessao.formatsubtotal;
  DBGrid1.Columns[6].DisplayFormat:=Sessao.formatsubtotal;
end;

procedure Tfrm_CondicionalFIltrar.FormShow(Sender: TObject);
begin
    b_novo.Visible := true;
    b_novo.Action := acNovo;
    b_editar.Visible := true;
    b_editar.Action := acEditar;
    b_Inativar.Visible:= true;
    b_Inativar.Action := acInativar;
    b_localizar.Action := acBuscar;
    edt_nome.SetFocus;
    ac_buscarExecute(self);
end;

procedure Tfrm_CondicionalFIltrar.Label4Click(Sender: TObject);
begin

end;

end.

