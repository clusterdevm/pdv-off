unit view.condicional.filtrar;

{$mode delphi}

interface

uses
  Classes, SysUtils, DB, BufDataset, Forms, Controls, Graphics, Dialogs,
  ComCtrls, ExtCtrls, Buttons, ActnList, DBGrids, StdCtrls, ComboEx,
  ACBrEnterTab, uf_base, view.condicional.criar, controller.condicional,
  classe.utils, frame.empresa, frame.status, LCLType, Menus;

type

  { Tfrm_CondicionalFIltrar }

  Tfrm_CondicionalFIltrar = class(TForm1)
    ACBrEnterTab1: TACBrEnterTab;
    acBuscar: TAction;
    acNovo: TAction;
    Action1: TAction;
    ac_editar: TAction;
    ActionList1: TActionList;
    cds_condicional: TBufDataset;
    cds_condicionalcli_nome: TStringField;
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
    Frame1_1: TFrame1;
    Frame2_1: TFrame2;
    Label1: TLabel;
    anel2: TPanel;
    procedure acNovoExecute(Sender: TObject);
    procedure Action1Execute(Sender: TObject);
    procedure ac_buscarExecute(Sender: TObject);
    procedure ac_editarExecute(Sender: TObject);
    procedure DBGrid1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edt_nomeKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
      );
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
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
     condicional.Filtrar(cds_condicional,Frame2_1.GetArray,Frame1_1.GetArray,'','','','');
  finally
    StatusBar1.Panels[0].Text:='Registro(s) Encontrado(s):'+IntToStr(cds_condicional.RecordCount-1) ;
    FreeAndNil(condicional);
  end;
end;

procedure Tfrm_CondicionalFIltrar.ac_editarExecute(Sender: TObject);
var condicional : TCondicional;
begin
   try
      condicional := TCondicional.Create;
      condicional.id := cds_condicionalid.AsInteger;
      Condicional.Editar;
   finally
     FreeAndNil(condicional);
   end;
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

procedure Tfrm_CondicionalFIltrar.acNovoExecute(Sender: TObject);
begin
    frmCondicionalCriar := TfrmCondicionalCriar.Create(self);
    frmCondicionalCriar.ShowModal;
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
     Add('Cancelado');
     Add('Faturada');
     Add('Pendente');
  end;
  Frame2_1.cb_status.ItemIndex:=0;

  Frame1_1.carregaEmpresa;

  DBGrid1.Columns[1].DisplayFormat:= Sessao.datetimeformat;
  DBGrid1.Columns[2].DisplayFormat:= Sessao.datetimeformat;

  DBGrid1.Columns[5].DisplayFormat:=Sessao.formatsubtotal;
  DBGrid1.Columns[6].DisplayFormat:=Sessao.formatsubtotal;
end;

procedure Tfrm_CondicionalFIltrar.FormShow(Sender: TObject);
begin
     edt_nome.SetFocus;
     ac_buscarExecute(self);
end;

end.

