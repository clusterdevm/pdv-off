unit view.filtros.cliente;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Buttons, DBGrids, ActnList, db, Grids, LCLType, ComCtrls, ZDataset,
  classe.utils, model.conexao, model.pessoa;

type

  { TfrmFiltroCliente }

  TfrmFiltroCliente = class(TForm)
    Action1: TAction;
    Action2: TAction;
    ac_filtrar: TAction;
    ActionList1: TActionList;
    Button1: TButton;
    dsCliente: TDataSource;
    DBGrid1: TDBGrid;
    edt_razao: TEdit;
    edt_telefone: TEdit;
    edt_CNPJ: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    lblTempoBusca: TLabel;
    Panel2: TPanel;
    pnlFiltro: TPanel;
    pnlFiltro1: TPanel;
    pnlFiltro2: TPanel;
    StatusBar1: TStatusBar;
    Timer1: TTimer;
    ZQuery1: TZQuery;
    ZQuery1nome: TStringField;
    procedure Action1Execute(Sender: TObject);
    procedure Action2Execute(Sender: TObject);
    procedure ac_filtrarExecute(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure DBGrid1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
      );
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
    procedure Timer1Timer(Sender: TObject);
  private
        a , b : Integer;
        _db : TConexao;
  public
    _FiltroID : Boolean;
    _OnlyCustomer : Boolean;
  end;

var
  frmFiltroCliente: TfrmFiltroCliente;

implementation

{$R *.lfm}

{ TfrmFiltroCliente }

procedure TfrmFiltroCliente.Action1Execute(Sender: TObject);
begin
    frmFiltroCliente.Close;
end;

procedure TfrmFiltroCliente.Action2Execute(Sender: TObject);
begin
    frmFiltroCliente.Close;
end;

procedure TfrmFiltroCliente.ac_filtrarExecute(Sender: TObject);
var _objeto : TPessoa;
begin
   try
      _objeto := TPessoa.Create;
      with _objeto do
      Begin
          razao:= edt_razao.Text;
          telefone:= edt_telefone.Text;
          documento:= edt_CNPJ.Text;
          onlyColaborador:= self._OnlyCustomer;
      end;
      _objeto.Listar(_db);

      StatusBar1.Panels[0].Text:= 'Registro(s) Encontrado(s):' +IntToStr(_db.Query.RecordCount);
   finally
        FreeAndNil(_objeto);
   end;
end;

procedure TfrmFiltroCliente.DBGrid1DblClick(Sender: TObject);
begin

    if (dsCliente.DataSet.RecordCount > 0) and (_FiltroID) then
    Begin
          sessao.getID := dsCliente.DataSet.FieldByName('id').AsString;
          frmFiltroCliente.Close;
    end;
end;

procedure TfrmFiltroCliente.DBGrid1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if key = VK_UP then
    Begin
        KEY := 0;
        if (dsCliente.DataSet.RecNo = 1) or (dsCliente.DataSet.IsEmpty) then
           edt_razao.SetFocus
         else
           dsCliente.DataSet.Prior;
    end;

    if key = VK_RETURN then
    Begin
        key := 0;
        DBGrid1DblClick(self);
    end;
end;

procedure TfrmFiltroCliente.edt_CNPJKeyDown(Sender: TObject; var Key: Word;
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

procedure TfrmFiltroCliente.edt_razaoChange(Sender: TObject);
begin
    a := Length(edt_CNPJ.Text) +
         Length(edt_razao.Text) +
         Length(edt_telefone.Text);
    Timer1.Enabled:=true;
end;

procedure TfrmFiltroCliente.edt_razaoKeyDown(Sender: TObject; var Key: Word;
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

procedure TfrmFiltroCliente.edt_telefoneKeyDown(Sender: TObject; var Key: Word;
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

procedure TfrmFiltroCliente.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
    FreeAndNil(_db);
    _OnlyCustomer:= false;
    frmFiltroCliente.Release;
    frmFiltroCliente := nil;
end;

procedure TfrmFiltroCliente.FormCreate(Sender: TObject);
begin
   Caption := 'Store :: Filtro de Clientes';

   lblTempoBusca.Caption := '';

   a := 1;
   b := 0;
   Timer1.Enabled:=TRUE;

   _FiltroID := false;
   _db := TConexao.Create;
   dsCliente.DataSet := _db.Query;


   _db.Query.FieldDefs.Add('id', ftInteger);
   _db.Query.FieldDefs.Add('nome', ftString,100);
   _db.Query.FieldDefs.Add('fantasia', ftString,100);
   _db.Query.FieldDefs.Add('cpf_cnpj', ftString,20);
end;

procedure TfrmFiltroCliente.FormShow(Sender: TObject);
begin
    edt_razao.SetFocus;
end;

procedure TfrmFiltroCliente.Timer1Timer(Sender: TObject);
begin
    if a = b then
        Timer1.Enabled:= false;

    b:= a;

end;

end.

