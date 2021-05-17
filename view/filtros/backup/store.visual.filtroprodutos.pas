unit store.visual.filtroProdutos;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Buttons, DBGrids, ActnList, JSONPropStorage, uRESTDWPoolerDB, uRESTDWBase,
  uDWResponseTranslator, uDWDataset, obj.cadastro.pessoa, utils, mvc.aguarde,
  db, Grids, LCLType, ACBrEnterTab;

type

  { TfrmFiltroProdutos }

  TfrmFiltroProdutos = class(TForm)
    ACBrEnterTab1: TACBrEnterTab;
    Action1: TAction;
    Action2: TAction;
    ac_filtrar: TAction;
    ActionList1: TActionList;
    ComboBox1: TComboBox;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    edt_CNPJ1: TEdit;
    edt_razao: TEdit;
    edt_telefone: TEdit;
    edt_CNPJ: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    lblRegistroEncontrados: TLabel;
    lblTempoBusca: TLabel;
    Panel2: TPanel;
    Panel6: TPanel;
    pnlFiltro: TPanel;
    pnlFiltro1: TPanel;
    pnlFiltro2: TPanel;
    pnlFiltro3: TPanel;
    RadioGroup1: TRadioGroup;
    rest_dataset: TRESTDWClientSQL;
    rest_datasetatacado: TCurrencyField;
    rest_datasetdescricao: TStringField;
    rest_datasetid: TLongintField;
    rest_datasetmarca: TStringField;
    rest_datasetncm: TStringField;
    rest_datasetreferencia: TStringField;
    rest_datasetsaldo: TCurrencyField;
    rest_datasetunidade: TStringField;
    rest_datasetvarejo: TCurrencyField;
    sped_filtrar: TSpeedButton;
    Timer1: TTimer;
    procedure Action1Execute(Sender: TObject);
    procedure Action2Execute(Sender: TObject);
    procedure ac_filtrarExecute(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure DBGrid1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
      );
    procedure DWClientRESTCidadeBeforePost(var AUrl: String;
      var AHeaders: TStringList);
    procedure edt_CNPJKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
      );
    procedure edt_razaoChange(Sender: TObject);
    procedure edt_razaoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edt_telefoneKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sped_filtrarClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
        a , b : Integer;
        automatica : Boolean;
  public

  end;

var
  frmFiltroProdutos: TfrmFiltroProdutos;

implementation

{$R *.lfm}

{ TfrmFiltroProdutos }

procedure TfrmFiltroProdutos.Action1Execute(Sender: TObject);
begin
    frmFiltroProdutos.Close;
end;

procedure TfrmFiltroProdutos.Action2Execute(Sender: TObject);
begin
    frmFiltroProdutos.Close;
end;

procedure TfrmFiltroProdutos.ac_filtrarExecute(Sender: TObject);
var Objeto : TClassPessoa;
begin
    try

        if not automatica then
        Begin
             edt_razao.SetFocus;
             edt_razao.SelectAll
        end else
             automatica := false;

        Objeto := TClassPessoa.Create;
        Objeto.Filtro.documento := edt_CNPJ.Text;
        Objeto.Filtro.fantasia  := '';
        Objeto.Filtro.razao     := edt_razao.Text;
        Objeto.Filtro.id        := '';
        Objeto.Filtro.telefone  := edt_telefone.Text;
        objeto.Filtro.tipo      := '';
        DataSource1.DataSet     := rest_dataset;
        objeto.Filtra(rest_dataset);


    finally
         lblTempoBusca.Caption          := Objeto.TimeRequest;
         lblRegistroEncontrados.Caption := RegistroEncontrado(rest_dataset.RecordCount);
         Objeto.Free;
    end;
end;

procedure TfrmFiltroProdutos.DBGrid1DblClick(Sender: TObject);
begin
     if rest_dataset.RecordCount > 0 then
     Begin
          const_idfiltro := rest_datasetID.AsString;
          frmFiltroProdutos.Close;
     end;
end;

procedure TfrmFiltroProdutos.DBGrid1DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
{    IF gdRowHighlight IN state then
    Begin
         with DBGrid1.Canvas do
         Begin
              //Brush.Color  := $3333338;
              font.Color   := clYellow;
              font.Bold    := true;
              FillRect(Rect);
         end;
    end;     }

end;

procedure TfrmFiltroProdutos.DBGrid1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if key = VK_UP then
    Begin
         KEY := 0;
         if (rest_dataset.RecNo = 1) or (rest_dataset.IsEmpty) then
           edt_razao.SetFocus
         else
           rest_dataset.Prior;
    end;

    if key = VK_RETURN then
    Begin
         key := 0;
         DBGrid1DblClick(self);
    end;
end;

procedure TfrmFiltroProdutos.DWClientRESTCidadeBeforePost(var AUrl: String;
  var AHeaders: TStringList);
begin

end;

procedure TfrmFiltroProdutos.edt_CNPJKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
     if key = VK_DOWN then
     bEGIN
          key := 0;
          DBGrid1.SetFocus
     end
     else
     if key = VK_LEFT then
     Begin
          key := 0;
          edt_telefone.SetFocus;
     end;

end;

procedure TfrmFiltroProdutos.edt_razaoChange(Sender: TObject);
begin
    a := Length(edt_CNPJ.Text) +
         Length(edt_razao.Text) +
         Length(edt_telefone.Text);
    Timer1.Enabled:=true;
end;

procedure TfrmFiltroProdutos.edt_razaoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    IF key = VK_DOWN THEN
    bEGIN
       KEY := 0;
       DBGrid1.SetFocus
    end
    else
    if key = VK_RIGHT then
    bEGIN
       KEY := 0;
       edt_telefone.SetFocus;
    end;
end;

procedure TfrmFiltroProdutos.edt_telefoneKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
     if key = VK_DOWN then
     bEGIN
          KEY := 0;
          DBGrid1.SetFocus
     end
     else
     if key = VK_LEFT then
     bEGIN
         KEY := 0;
         edt_razao.SetFocus
     end
     else
     if key = VK_RIGHT then
     bEGIN
         KEY := 0;
         edt_CNPJ.SetFocus;
     end;
end;

procedure TfrmFiltroProdutos.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
    frmFiltroProdutos.Release;
    frmFiltroProdutos := nil;
end;

procedure TfrmFiltroProdutos.FormCreate(Sender: TObject);
begin
   Caption := 'Store :: Filtro de Clientes';

   lblTempoBusca.Caption := '';
   lblRegistroEncontrados.Caption := '';

   a := 1;
   b := 0;
   Timer1.Enabled:=TRUE;
end;

procedure TfrmFiltroProdutos.FormShow(Sender: TObject);
begin
    edt_razao.SetFocus;
end;

procedure TfrmFiltroProdutos.sped_filtrarClick(Sender: TObject);
begin

end;

procedure TfrmFiltroProdutos.Timer1Timer(Sender: TObject);
begin
    if a = b then
    Begin
        Timer1.Enabled:= false;
        automatica:=true;
        ac_filtrarExecute(self);
    end;

    b:= a;

end;

end.

