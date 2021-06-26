unit view.devolucao.filtrar;

{$mode delphi}

interface

uses
  Classes, SysUtils, DB, BufDataset, Forms, Controls, Graphics, Dialogs,
  ComCtrls, ExtCtrls, Buttons, ActnList, DBGrids, StdCtrls, ComboEx,
  ACBrEnterTab, uf_base, view.devolucao.criar,
  classe.utils, frame.empresa, frame.status, LCLType, Menus, EditBtn, Grids;

type

  { Tf_devolucaoFiltrar }

  Tf_devolucaoFiltrar = class(TForm1)
    ACBrEnterTab1: TACBrEnterTab;
    acBuscar: TAction;
    acNovo: TAction;
    Action1: TAction;
    acInativar: TAction;
    acImprimir: TAction;
    ActionList1: TActionList;
    b_localizar1: TSpeedButton;
    cds_devolucao: TBufDataset;
    cds_devolucaodata_emissao: TDateTimeField;
    cds_devolucaoid: TLongintField;
    cds_devolucaon_cliente: TStringField;
    cds_devolucaon_empresa_devolucao: TStringField;
    cds_devolucaon_empresa_venda: TStringField;
    cds_devolucaon_operador: TStringField;
    cds_devolucaon_vendedor: TStringField;
    cds_devolucaototal_devolucao: TCurrencyField;
    DBGrid1: TDBGrid;
    ds_devolucao: TDataSource;
    edt_nome: TEdit;
    edt_credito: TEdit;
    ed_emissao_final: TDateEdit;
    ed_emissao_inicial: TDateEdit;
    Frame1_1: TFrame1;
    Frame2_1: TFrame2;
    Label1: TLabel;
    anel2: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    PopupMenu1: TPopupMenu;
    Timer1: TTimer;
    procedure acImprimirExecute(Sender: TObject);
    procedure acInativarExecute(Sender: TObject);
    procedure acNovoExecute(Sender: TObject);
    procedure Action1Execute(Sender: TObject);
    procedure ac_buscarExecute(Sender: TObject);
    procedure cb_statusChange(Sender: TObject);
    procedure DBGrid1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edt_nomeChange(Sender: TObject);
    procedure edt_nomeKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
      );
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
     var  a , b : Integer;
      _Load : boolean ;
  public

  end;

var
  f_devolucaoFiltrar: Tf_devolucaoFiltrar;

implementation

{$R *.lfm}

uses controller.devolucao;

procedure Tf_devolucaoFiltrar.ac_buscarExecute(Sender: TObject);
var devolucao : TDevolucao;
begin
  if not _Load then
     exit;

  try

     DBGrid1.Columns[1].DisplayFormat:= Sessao.datetimeformat;
     DBGrid1.Columns[6].DisplayFormat:=Sessao.formatsubtotal;

     devolucao := TDevolucao.Create;
     devolucao.n_cliente:= edt_nome.text;
     devolucao.ativo := Frame2_1.cb_status.ItemIndex = 0 ;
     devolucao.emissao_inicial:= ed_emissao_inicial.Text;
     devolucao.emissao_final:= ed_emissao_final.Text;
     devolucao.credito_id:= edt_credito.Text;
     devolucao.empresa_devolucao:= Frame1_1.GetArray;
     devolucao.Filtrar(cds_devolucao);
  finally
    StatusBar1.Panels[0].Text:='Registro(s) Encontrado(s):'+IntToStr(cds_devolucao.RecordCount) ;
    StatusBar1.Panels[1].Text:='Registro(s) devolução(s):'+  FormatFloat(sessao.formatsubtotal,devolucao.total_devolucao) ;
    FreeAndNil(devolucao);
  end;
end;

procedure Tf_devolucaoFiltrar.cb_statusChange(Sender: TObject);
begin
  ac_buscarExecute(self);
end;

procedure Tf_devolucaoFiltrar.DBGrid1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if key = VK_UP then
  Begin
      if cds_devolucao.RecordCount > 0 then
      Begin
           if cds_devolucao.RecNo = 1 then
              edt_nome.SetFocus;
      end;
  end;
end;

procedure Tf_devolucaoFiltrar.edt_nomeChange(Sender: TObject);
begin
  a := Length(edt_nome.Text) ;
  Timer1.Enabled:=true;
end;

procedure Tf_devolucaoFiltrar.edt_nomeKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  IF key = vk_down then
     DBGrid1.SetFocus;
end;

procedure Tf_devolucaoFiltrar.acNovoExecute(Sender: TObject);
begin
   CriarForm(Tf_devolucaoCriar);
  //f_devolucaoCriar := Tf_devolucaoCriar.Create(nil);
  //f_devolucaoCriar.ShowModal;
  //f_devolucaoCriar.Release;
  //f_devolucaoCriar := nil;

   edt_nome.SetFocus;
   ac_buscarExecute(self);
end;

procedure Tf_devolucaoFiltrar.acInativarExecute(Sender: TObject);
var devolucao : Tdevolucao;
begin
   try
      devolucao := Tdevolucao.Create;
      devolucao.id := cds_devolucaoid.AsInteger;
      devolucao.Cancelar;
      ac_buscarExecute(Self);
      edt_nome.SetFocus;
   finally
     FreeAndNil(devolucao);
   end;
end;

procedure Tf_devolucaoFiltrar.acImprimirExecute(Sender: TObject);
var devolucao : Tdevolucao;
begin
  try
     devolucao := Tdevolucao.Create;
     devolucao.id:= cds_devolucaoid.AsInteger;
     devolucao.Report();
  finally
      FreeAndNil(devolucao);
  end;
end;

procedure Tf_devolucaoFiltrar.Action1Execute(Sender: TObject);
begin
   self.Close;
end;

procedure Tf_devolucaoFiltrar.FormCreate(Sender: TObject);
begin
  cds_devolucao.CreateDataset;
  cds_devolucao.Open;

  _Load:= false;

  Frame2_1.cb_status.Clear;
  with Frame2_1.cb_status.Items do
  Begin
     Add('Ativo');
     Add('Cancelada');
  end;
  Frame2_1.cb_status.ItemIndex:=0;

  Frame1_1.carregaEmpresa;
end;

procedure Tf_devolucaoFiltrar.FormShow(Sender: TObject);
begin
    b_novo.Visible := true;
    b_novo.Action := acNovo;
    b_editar.Visible := false;
    b_Inativar.Visible:= true;
    b_Inativar.Action := acInativar;
    b_localizar.Action := acBuscar;
    b_localizar1.Action := acImprimir;
    b_localizar1.Visible:= true;
    ed_emissao_inicial.Text:= FormatDateTime('dd/mm/yyyy',now);
    ed_emissao_final.Text:= FormatDateTime('dd/mm/yyyy',now);

    edt_nome.SetFocus;
    a:= 0; b:= 0;
   Timer1.Enabled:=true;
end;

procedure Tf_devolucaoFiltrar.Timer1Timer(Sender: TObject);
begin
  if a = b then
  Begin
      Timer1.Enabled:= false;
      _Load:= true;
      ac_buscarExecute(self);
  end else
     b:=Length(edt_nome.Text);
end;

end.

