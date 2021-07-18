unit frame.pagamento;

{$mode delphi}

interface

uses
  Classes, SysUtils, BufDataset, DB, Forms, Controls, ExtCtrls, StdCtrls,
  DBGrids, ComCtrls, DBCtrls, Dialogs, Spin, SpinEx, Grids, Graphics, LCLType,
  DataSet.Serialize,DataSet.Serialize.Config;

type

  { TframePagamento }

  TframePagamento = class(TFrame)
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    cbDebito: TDBLookupComboBox;
    dsCredito: TDataSource;
    dsDebito: TDataSource;
    cbCredito: TDBLookupComboBox;
    edtValeCredito: TEdit;
    ed_autorizacaoCredito: TEdit;
    ed_autorizacaoDebito: TEdit;
    ed_valorCredito: TFloatSpinEditEx;
    ed_valorDebito: TFloatSpinEditEx;
    Label10: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    qCredito: TBufDataset;
    Button1: TButton;
    dsQuitacao: TDataSource;
    ed_valorDinheiro: TFloatSpinEditEx;
    Panel5: TPanel;
    Panel6: TPanel;
    qCreditodescricao: TStringField;
    qCreditoid: TLongintField;
    qDebito: TBufDataset;
    qDebitodescricao: TStringField;
    qDebitoid: TLongintField;
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
    qQuitacaotipo_liquidacao: TStringField;
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
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure ed_valorDinheiroEnter(Sender: TObject);
    procedure ed_valorDinheiroKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ed_valorDinheiroKeyPress(Sender: TObject; var Key: char);
    procedure gridValoresDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure ListBox1SelectionChange(Sender: TObject; User: boolean);
  private
        TotalPagar,TotalPago : Currency;
        NumeroParcelas : Integer;
        Function SelecionadoItem : Integer;
        Procedure CarregaMoeda;
        Procedure CarregaCredito;
        Procedure CarregaDebito;
        Procedure Calcula;
  public
      Procedure Inicializa(_valorPagar : Extended;n_parcelas:integer);
      function Quitado : boolean;

      Function GetBaixa : String;
  end;

implementation

{$R *.lfm}

uses ems.conexao, ems.utils, model.request.http;

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

    if StrToFloatDef(ed_valorDinheiro.Text,0) = 0 then
       exit

     qQuitacao.Append;
     if sessao.GetmoedaPadrao = DBLookupComboBox1.KeyValue then
        qQuitacaodisplay.Value:= 'Efetivo'
     else
     Begin
         qQuitacaodisplay.Value:= 'Efetivo (' + DBLookupComboBox1.Text + ')';
     end;
     qQuitacaovalor.Value:= ToValor(ed_valorDinheiro.Text);
     qQuitacaomoeda_id.Value:= DBLookupComboBox1.KeyValue;
     qQuitacaotipo_liquidacao.Value:= 'efetivo';
     qQuitacao.Post;

     ed_valorDinheiro.Value:= 0;
     ListBox1.SetFocus;
     ListBox1.Selected[0] := true;

     Calcula;
end;

procedure TframePagamento.Button2Click(Sender: TObject);
begin
  qQuitacao.Append;
  qQuitacaodisplay.Value:= 'Crédito('+cbCredito.Text+') ';
  qQuitacaovalor.Value:= ToValor(ed_valorCredito.Text);
  qQuitacaon_autorizacao.Value:= ed_autorizacaoCredito.Text ;
  qQuitacaon_parcelas.Value:= NumeroParcelas;
  qQuitacaotipo_liquidacao.Value:= 'credito';
  qQuitacao.Post;

  ed_valorCredito.Value:= 0;
  ed_autorizacaoCredito.Text := '';
  cbCredito.KeyValue:=0;
  ListBox1.SetFocus;
  ListBox1.Selected[0] := true;

  Calcula;
end;

procedure TframePagamento.Button3Click(Sender: TObject);
begin
  qQuitacao.Append;
  qQuitacaodisplay.Value:= 'Débito('+cbDebito.Text+') ';
  qQuitacaovalor.Value:= ToValor(ed_valorDebito.Text);
  qQuitacaon_autorizacao.Value:= ed_autorizacaoDebito.Text ;
  qQuitacaon_parcelas.Value:= NumeroParcelas;
  qQuitacaotipo_liquidacao.Value:= 'debito';
  qQuitacao.Post;

  ed_valorDebito.Value:= 0;
  ed_autorizacaoDebito.Text := '';
  cbDebito.KeyValue:=0;
  ListBox1.SetFocus;
  ListBox1.Selected[0] := true;

  Calcula;
end;

procedure TframePagamento.Button4Click(Sender: TObject);
var _api : TRequisicao;
    _valorStr : String;
begin

  if trim(edtValeCredito.Text)= '' then
  Begin
     Messagedlg('Numero do vale não informado',mtWarning,[mbok],0);
     exit;
  end;

   try
        _api := TRequisicao.Create;
        _api.Metodo:='get';
        _api.tokenBearer:= GetBearerEMS;;
        _api.webservice:= getEMS_Webservice(mFinanceiro);
        _api.rota:='vale_credito';
        _api.endpoint:=edtValeCredito.Text;
        _api.Execute;

        _valorStr := FormatFloat(sessao.formatsubtotal,
        _api.Return['resultado'].AsObject['valor'].AsNumber);

        if _api.ResponseCode in [200..207] then
        Begin
           if messagedlg('Registrar Vale'+#13+
                         'Valor:'+_valorStr
                         ,mtInformation,[mbno,mbyes],0)=mryes then
           Begin
              qQuitacao.Append;
              qQuitacaodisplay.Value:= 'Vale Credito '+edtValeCredito.Text;
              qQuitacaovalor.Value:= _api.Return['resultado'].AsObject['valor'].AsNumber;
              qQuitacaotipo_liquidacao.Value:= 'vale';
              qQuitacaocodigo_vale.Value := StrToIntDef(edtValeCredito.Text,0);
              qQuitacao.Post;
           end
        end else
           messagedlg('Vale Invalido',mtWarning,[mbok],0);

        edtValeCredito.Text := '';
        ListBox1.SetFocus;
        ListBox1.Selected[0] := true;
        Calcula;

   finally
       FreeAndNil(_api);
   end;
end;

procedure TframePagamento.ed_valorDinheiroEnter(Sender: TObject);
begin
  ed_valorCredito.SelectAll;
end;

procedure TframePagamento.ed_valorDinheiroKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if key = VK_RETURN then
     Button1Click(self);
end;

procedure TframePagamento.ed_valorDinheiroKeyPress(Sender: TObject;
  var Key: char);
begin

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

       if not _db.TabelaExists('moeda') then
          exit;

       with _db.qrySelect do
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

procedure TframePagamento.CarregaCredito;
var _db : TConexao;
begin
   try
       _db := TConexao.Create;

       if not _db.TabelaExists('bandeira_cartao') then
          exit;

       with _db.qrySelect do
       Begin
             Close;
             Sql.Clear;
             Sql.add('select * from bandeira_cartao');
             Sql.Add(' where ativo = '+QuotedStr('true'));
             Sql.Add(' and prazo_credito > 0 ');
             Sql.Add(' order by descricao ');
             open;

             qCredito.CreateDataset;
             qCredito.Open;
             while not eof do
             Begin
                 qCredito.Append;
                 qCreditoid.Value:= FieldBYName('id').AsInteger;
                 qCreditodescricao.Value:= trim(FieldByName('descricao').AsString);
                 qCredito.Post;
                 Next;
             end;
             //DBLookupComboBox1.KeyValue:= sessao.GetmoedaPadrao;
       end;
   finally
       FreeAndNil(_db);
   end;
end;

procedure TframePagamento.CarregaDebito;
var _db : TConexao;
begin
   try
       _db := TConexao.Create;

       if not _db.TabelaExists('bandeira_cartao') then
          exit;

       with _db.qrySelect do
       Begin
             Close;
             Sql.Clear;
             Sql.add('select * from bandeira_cartao');
             Sql.Add(' where ativo = '+QuotedStr('true'));
             Sql.Add(' and prazo_debito > 0 ');
             Sql.Add(' order by descricao ');
             open;

             qDebito.CreateDataset;
             qDebito.Open;
             while not eof do
             Begin
                 qDebito.Append;
                 qDebitoid.Value:= FieldBYName('id').AsInteger;
                 qDebitodescricao.Value:= trim(FieldByName('descricao').AsString);
                 qDebito.Post;
                 Next;
             end;
             //DBLookupComboBox1.KeyValue:= sessao.GetmoedaPadrao;
       end;
   finally
       FreeAndNil(_db);
   end;
end;

procedure TframePagamento.Calcula;
begin
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

procedure TframePagamento.Inicializa(_valorPagar : Extended;n_parcelas:integer);
begin
     PageControl1.ShowTabs:= false;
     PageControl1.TabIndex:= 6;

     qQuitacao.CreateDataset;
     qQuitacao.Open;

     gridValores.SelectedColor:= clwhite; //$00EAE3DA
     gridValores.Columns[1].DisplayFormat:= sessao.formatsubtotal();
     CarregaMoeda;
     CarregaCredito;
     CarregaDebito;
     TotalPagar:= Decimal(_valorPagar,2);
     NumeroParcelas := n_parcelas;
     Calcula;

     TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndNone;
     TDataSetSerializeConfig.GetInstance.DateInputIsUTC:=true;
     TDataSetSerializeConfig.GetInstance.Export.FormatDateTime := 'yyyy-mm-dd hh:nn:ss.zzz';
end;

function TframePagamento.Quitado: boolean;
begin
   result := Decimal(TotalPagar,2) <= Decimal(TotalPago,2);

   if not result then
      messagedlg('Valor Pago Insuficiente',mtConfirmation,[mbok],0);
end;

function TframePagamento.GetBaixa: String;
begin

   if TotalPagar < TotalPago  then
   Begin
     qQuitacao.Append;
     qQuitacaodisplay.Value:= 'troco';
     qQuitacaovalor.Value:= Decimal(Decimal(TotalPagar,2)- Decimal(TotalPago,2),2);
     qQuitacaotipo_liquidacao.Value:= 'troco';
     qQuitacao.Post;
   end;

    result := qQuitacao.ToJSONArrayString();


end;

end.

