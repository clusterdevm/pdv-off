unit view.condicional;

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  ComCtrls, DBGrids, StdCtrls, ActnList, frame.produto.localiza,
  ems.utils, jsons, BufDataset, DB, clipbrd;

type

  { Tf_condicional }

  Tf_condicional = class(TForm)
    Action1: TAction;
    Action2: TAction;
    ac_gravar: TAction;
    ac_cancelar: TAction;
    ac_sair: TAction;
    ActionList1: TActionList;
    cds_canceladodata_estorno: TDateTimeField;
    cds_canceladogradeamento_id: TStringField;
    cds_canceladoproduto_id: TLongintField;
    cds_itens: TBufDataset;
    cds_cancelado: TBufDataset;
    cds_itensdata_registro: TDateTimeField;
    cds_canceladodata_registro: TDateTimeField;
    cds_itensdescricao: TStringField;
    cds_canceladodescricao: TStringField;
    cds_itensgradeamento_id: TStringField;
    cds_itensid: TLongintField;
    cds_canceladoid: TLongintField;
    cds_itensproduto_id: TLongintField;
    cds_itensquantidade: TCurrencyField;
    cds_canceladoquantidade: TCurrencyField;
    cds_itensstatus: TStringField;
    cds_canceladostatus: TStringField;
    cds_itensvalor: TCurrencyField;
    cds_canceladovalor: TCurrencyField;
    DBGridCancelado: TDBGrid;
    DBGrid3: TDBGrid;
    dsItens: TDataSource;
    DBGrid1: TDBGrid;
    dCancelado: TDataSource;
    ed_totalPecas: TEdit;
    edt_valor: TEdit;
    ed_ProdutoID: TEdit;
    ed_ProdutoDescricao: TEdit;
    edt_IDCondicional: TEdit;
    EdtDataEmissao: TEdit;
    edt_Cliente: TEdit;
    edt_status: TEdit;
    edt_vendedor: TEdit;
    edt_unidade: TEdit;
    Label10: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    pnlBotoesCentro: TPanel;
    pnlBotoes: TPanel;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    procedure Action2Execute(Sender: TObject);
    procedure ac_cancelarExecute(Sender: TObject);
    procedure ac_gravarExecute(Sender: TObject);
    procedure ac_sairExecute(Sender: TObject);
    procedure ed_ProdutoIDKeyPress(Sender: TObject; var Key: char);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
        Procedure SetLayout;
  public
      dadosJson : TJsonObject;
  end;

var
  f_condicional: Tf_condicional;

implementation

uses controller.condicional;

{$R *.lfm}

{ Tf_condicional }

procedure Tf_condicional.FormResize(Sender: TObject);
begin
    pnlBotoesCentro.Align:= alNone ;
    pnlBotoesCentro.left := (pnlBotoes.Width div 2) - (pnlBotoesCentro.width div 2);
end;

procedure Tf_condicional.FormCreate(Sender: TObject);
begin
  dadosJson := TJsonObject.Create;

  cds_itens.CreateDataset;
  cds_itens.Open;

  cds_cancelado.CreateDataset;
  cds_cancelado.Open;
end;

procedure Tf_condicional.ac_sairExecute(Sender: TObject);
begin
     self.Close;
end;

procedure Tf_condicional.ed_ProdutoIDKeyPress(Sender: TObject; var Key: char);
var _Object : TCondicional;
begin
  if key = #13 then
  Begin
      key := #0;

      try
         _Object := TCondicional.Create;
         _Object.id := StrToInt(edt_IDCondicional.text);
         if _Object.FindProduto(ed_ProdutoID.Text) then
         Begin
             dadosJson.Parse(_Object._ResponseContent);
             SetLayout;
             ed_ProdutoID.Clear;
             ed_ProdutoDescricao.Clear;
         end;

         ed_ProdutoID.SetFocus;
      finally
          FreeAndNil(_Object);
      end;
  end;
end;

procedure Tf_condicional.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
   FreeAndNIl(dadosJson);
   f_condicional.Release;
   f_condicional := nil;
end;

procedure Tf_condicional.Action2Execute(Sender: TObject);
var _condicional : TCondicional;
begin
  if DBGrid1.Focused then
  Begin
     if cds_itens.RecordCount > 0 then
     Begin
        if messagedlg('Deletar Registro?',mtWarning,[mbno,mbyes],0)=mryes then
        Begin
              try
                 _condicional:= TCondicional.Create;
                  _condicional.id := StrToInt(edt_IDCondicional.Text);
                 if _condicional.estorna(cds_itensid.AsInteger) then
                 Begin
                    dadosJson.Parse(_condicional._ResponseContent);
                    SetLayout;
                 end;
              finally
                 FreeAndNil(_condicional);
              end;
        end;
     end;
  end ;
end;

procedure Tf_condicional.ac_cancelarExecute(Sender: TObject);
begin
  f_condicional.close;
end;

procedure Tf_condicional.ac_gravarExecute(Sender: TObject);
var _condicional : TCondicional;
begin
   try
        _condicional := TCondicional.Create;
        _condicional.id:= StrToInt(edt_IDCondicional.text);
        if _condicional.Gravar then
           f_condicional.Close;
   finally
       FreeAndNil(_condicional);
   end;
end;

procedure Tf_condicional.FormShow(Sender: TObject);
begin
  Caption := 'Cluster Sistemas : Condicional';
  PageControl1.ActivePage := TabSheet1;
  SetLayout;
  SpeedButton4.Action := ac_cancelar;
end;

procedure Tf_condicional.SetLayout;
var i : Integer;
  _item : TJsonObject;
begin

  EdtDataEmissao.Text := FormatDateTime('dd/mm/yyyy hh:mm',getDataBanco(dadosJson['data_emissao'].AsString));
  edt_vendedor.Text:= FormatFloat('000000',dadosJson['vendedor_id'].AsInteger)+' ' +
                       dadosjson['n_vendedor'].AsString;
  edt_Cliente.Text:= FormatFloat('000000',dadosJson['cliente_id'].AsInteger) + ' '+
                       dadosjson['n_cliente'].AsString;
  edt_status.Text:= dadosJson['status'].AsString;
  edt_IDCondicional.Text:= dadosjson['id'].AsString;
  edt_unidade.Text:= FormatFloat('000000',dadosJson['empresa_id'].AsInteger)+' '+
                      dadosJson['nomeunidade'].AsString;

  if dadosJson['tipo_operacao'].AsInteger = 1  then
      self.Caption:= 'Cluster Sistemas : Condicional '
  else
      self.Caption:= 'Cluster Sistemas : Reserva '

  Limpa(cds_itens);
  Limpa(cds_cancelado);

 try
  cds_itens.DisableControls;
  cds_cancelado.DisableControls;

  for i := 0 to dadosJson['itens'].AsArray.Count-1 do
  Begin
       _item := dadosJson['itens'].AsArray.Items[i].AsObject;
       cds_itens.Append;
       cds_itensid.AsString:= _item['id'].AsString;

       cds_itensproduto_id.AsString:= _item['produto_id'].AsString;
       cds_itensgradeamento_id.Value:= _item['gradeamento_id'].AsString;

       cds_itensdescricao.Value:= _item['descricao'].AsString;
       cds_itensquantidade.Value:= _item['quantidade'].AsNumber;
       cds_itensstatus.Value:= _item['status'].AsString;
       cds_itensvalor.Value:= _item['valor_final'].AsNumber;
       cds_itensdata_registro.AsDateTime:= getDataBanco(_item['data_inclusao'].AsString);
       cds_itens.Post;
  end;

  for i := 0 to dadosJson['devolvido'].AsArray.Count-1 do
  Begin
       _item := dadosJson['devolvido'].AsArray.Items[i].AsObject;
       cds_cancelado.Append;

       cds_canceladoproduto_id.AsString:= _item['produto_id'].AsString;
       cds_canceladogradeamento_id.Value:= _item['gradeamento_id'].AsString;

       cds_canceladoid.Value:= _item['id'].AsInteger;
       cds_canceladodescricao.Value:= _item['descricao'].AsString;
       cds_canceladoquantidade.Value:= _item['quantidade'].AsNumber;
       cds_canceladostatus.Value:= _item['status'].AsString;
       cds_canceladovalor.Value:= _item['valor'].AsNumber;
       cds_canceladodata_registro.AsDateTime:= getDataBanco(_item['data_inclusao'].AsString);
       cds_canceladodata_estorno.AsDateTime:= getDataBanco(_item['data_estorno'].AsString);
       cds_cancelado.Post;
  end;

 finally
    cds_itens.EnableControls;
    cds_cancelado.EnableControls;
    ed_totalPecas.Text:= IntToStr(cds_itens.RecordCount);
    edt_valor.Text:= FormatFloat(Sessao.formatsubtotal,dadosJson['total_pendente'].AsNumber);
    ed_ProdutoID.SetFocus;
 end;
end;

end.

