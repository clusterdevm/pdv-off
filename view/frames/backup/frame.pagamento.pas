unit frame.pagamento;

{$mode delphi}

interface

uses
  Classes, SysUtils, BufDataset, DB, Forms, Controls, ExtCtrls, StdCtrls,
  DBGrids, ComCtrls, DBCtrls, Dialogs, Spin, SpinEx, Grids, Graphics;

type

  { TframePagamento }

  TframePagamento = class(TFrame)
    Button1: TButton;
    dsQuitacao: TDataSource;
    ed_valorDinheiro: TFloatSpinEditEx;
    Panel5: TPanel;
    Panel6: TPanel;
    qQuitacao: TBufDataset;
    DBLookupComboBox1: TDBLookupComboBox;
    dsmoeda: TDataSource;
    qMoeda: TBufDataset;
    gridValores: TDBGrid;
    DBGrid2: TDBGrid;
    Label1: TLabel;
    Label2: TLabel;
    ListBox1: TListBox;
    PageControl1: TPageControl;
    Panel1: TPanel;
    pnlDisplay: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    qMoedacambio: TFloatField;
    qMoedadescricao: TStringField;
    qMoedaid: TLongintField;
    qQuitacaocambio: TFloatField;
    qQuitacaocodigo_vale: TLongintField;
    qQuitacaodisplay: TStringField;
    qQuitacaomoeda_id: TLongintField;
    qQuitacaon_autorizacao: TStringField;
    qQuitacaon_parcelas: TLongintField;
    qQuitacaotipo: TStringField;
    qQuitacaovalor: TFloatField;
    qQuitacaovalor_moeda: TFloatField;
    tabDinheiro: TTabSheet;
    tabCredito: TTabSheet;
    tabDebito: TTabSheet;
    tabCheque: TTabSheet;
    tabNeutra: TTabSheet;
    tabTEF: TTabSheet;
    tabValeCredito: TTabSheet;
    procedure Button1Click(Sender: TObject);
    procedure gridValoresDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure ListBox1SelectionChange(Sender: TObject; User: boolean);
  private
        TotalPagar,TotalPago : Currency;
        Function SelecionadoItem : Integer;
        Procedure CarregaMoeda;
        Procedure Calcula;
  public
      Procedure Inicializa(_valorPagar : currency);
      function Quitado : boolean;
  end;

implementation

{$R *.lfm}

uses model.conexao, classe.utils;

procedure TframePagamento.ListBox1SelectionChange(Sender: TObject; User: boolean
  );
begin
     case SelecionadoItem of
        0 : PageControl1.PageIndex:= 0;
        1 : PageControl1.PageIndex:= 1;
        2 : PageControl1.PageIndex:= 2;
        3 : PageControl1.PageIndex:= 3;
        4 : PageControl1.PageIndex:= 4;
        5 : PageControl1.PageIndex:= 5
        else PageControl1.PageIndex:= 6;
     end;
end;

procedure TframePagamento.Button1Click(Sender: TObject);
begin
     qQuitacao.Append;
     if sessao.GetmoedaPadrao = DBLookupComboBox1.KeyValue then
        qQuitacaodisplay.Value:= 'Efetivo'
     else
     Begin
         qQuitacaodisplay.Value:= 'Efetivo (' + DBLookupComboBox1.Text + ')';
     end;
     qQuitacaovalor.Value:= ToValor(ed_valorDinheiro.Text);
     qQuitacaomoeda_id.Value:= DBLookupComboBox1.KeyValue;
     qQuitacaotipo.Value:= 'efetivo';
     qQuitacao.Post;

     ed_valorDinheiro.Value:= 0;
     ListBox1.SetFocus;
     ListBox1.Selected[0] := true;
end;

procedure TframePagamento.gridValoresDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
     if gdSelected in State then
     begin
        TDBGrid( Sender ).Canvas.Brush.Color := $00EAE3DA;
        TDBGrid( Sender ).Canvas.Font.Color  := clBlack;
        //TDBGrid( Sender ).Canvas.Pen.Color := Brush.Color;
     end;
     TDBGrid( Sender ).DefaultDrawColumnCell( Rect, DataCol, Column, State );
end;

function TframePagamento.SelecionadoItem: Integer;
var i : Integer;
begin
  Result := -1;

  for I := 0 to Listbox1.Items.Count - 1 do
    if ListBox1.Selected[I] then
      result := i;
end;

procedure TframePagamento.CarregaMoeda;
var _db : TConexao;
    _pos : integer;
begin
   try
       _db := TConexao.Create;
       with _db.Query do
       Begin
             Close;
             Sql.Clear;
             Sql.add('select * from moeda');
             Sql.Add(' where ativo = '+QuotedStr('true'));
             Sql.Add(' order by descricao ');
             open;

             qMoeda.CreateDataset;
             qMoeda.Open;
             _pos:= 0;
             while not eof do
             Begin
                 qMoeda.Append;
                 qMoedaid.Value:= FieldBYName('id').AsInteger;
                 qMoedadescricao.Value:= trim(FieldByName('descricao').AsString);
                 qMoeda.Post;
                 Next;
             end;
             DBLookupComboBox1.KeyValue:= sessao.GetmoedaPadrao;
       end;
   finally
       FreeAndNil(_db);
   end;
end;

procedure TframePagamento.Calcula;
begin
  //$00AB9DF5  red

  qQuitacao.First;
  TotalPago:= 0;
  while not qQuitacao.EOF do
  Begin
        TotalPago:= TotalPago + qQuitacaovalor.Value;
        qQuitacao.Next;
  end;

  if TotalPagar > TotalPago  then
    pnlDisplay.Caption:= 'Falta pagar '+FormatFloat(sessao.formatsubtotal(),TotalPagar-TotalPago)
  else
  if TotalPagar < TotalPago  then
    pnlDisplay.Caption:= 'Troco '+FormatFloat(sessao.formatsubtotal(),TotalPago-TotalPagar)
  else pnlDisplay.Caption:= 'Pago';



end;

procedure TframePagamento.Inicializa(_valorPagar : currency);
begin
     PageControl1.ShowTabs:= false;
     PageControl1.TabIndex:= 6;

     qQuitacao.CreateDataset;
     qQuitacao.Open;

     gridValores.SelectedColor:= clwhite; //$00EAE3DA
     gridValores.Columns[1].DisplayFormat:= sessao.formatsubtotal();
     CarregaMoeda;
     TotalPagar:= _valorPagar;
     Calcula;
end;

function TframePagamento.Quitado: boolean;
begin
   result := TotalPagar <= TotalPago;

   if not result then
      messagedlg('Valor Pago Insuficiente',mtConfirmation,[mbok],0);
end;

end.

