unit view.condicional;

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  ComCtrls, DBGrids, StdCtrls, ActnList, frame.produto.localiza,
  classe.utils, jsons, BufDataset, DB;

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
    cds_itens: TBufDataset;
    cds_cancelado: TBufDataset;
    cds_itensdata_registro: TDateTimeField;
    cds_canceladodata_registro: TDateTimeField;
    cds_itensdescricao: TStringField;
    cds_canceladodescricao: TStringField;
    cds_itensid: TLongintField;
    cds_canceladoid: TLongintField;
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
    edt_IDCondicional: TEdit;
    EdtDataEmissao: TEdit;
    edt_Cliente: TEdit;
    edt_status: TEdit;
    edt_vendedor: TEdit;
    edt_unidade: TEdit;
    frameProdutoGet1: TframeProdutoGet;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
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
    procedure ac_sairExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

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
                     cds_cancelado.Append;
                     cds_canceladoid.Value:= cds_itensid.value;
                     cds_canceladodescricao.Value:= cds_itensdescricao.Value;
                     cds_canceladoquantidade.Value:= 1;
                     cds_canceladostatus.Value:= cds_itensstatus.value;
                     cds_canceladovalor.Value:= cds_itensvalor.Value;
                     cds_canceladodata_registro.AsDateTime:= cds_itensdata_registro.Value;
                     cds_canceladodata_estorno.AsDateTime:= Now;
                     cds_cancelado.Post;
                     cds_itens.Delete;
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

procedure Tf_condicional.FormShow(Sender: TObject);
var i : Integer;
  _item : TJsonObject;
begin
  Caption := 'Cluster Sistemas : Condicional';

  PageControl1.ActivePage := TabSheet1;

  EdtDataEmissao.Text := FormatDateTime('dd/mm/yyyy hh:mm',GetData(dadosJson['data_emissao'].AsString));
  edt_vendedor.Text:= FormatFloat('000000',dadosJson['vendedor_id'].AsInteger)+' ' +
                       dadosjson['n_vendedor'].AsString;
  edt_Cliente.Text:= FormatFloat('000000',dadosJson['cliente_id'].AsInteger) + ' '+
                       dadosjson['n_cliente'].AsString;
  edt_status.Text:= dadosJson['status'].AsString;
  edt_IDCondicional.Text:= dadosjson['id'].AsString;
  edt_unidade.Text:= FormatFloat('000000',dadosJson['empresa_id'].AsInteger)+' '+
                      dadosJson['nomeunidade'].AsString;



  for i := 0 to dadosJson['itens'].AsArray.Count-1 do
  Begin
       _item := dadosJson['itens'].AsArray.Items[i].AsObject;

       if (_item['status'].AsString = 'cancelado') or
          (_item['status'].AsString = 'devolvido')
       then
       Begin
           cds_cancelado.Append;
           cds_canceladoid.Value:= _item['id'].AsInteger;
           cds_canceladodescricao.Value:= _item['descricao'].AsString;
           cds_canceladoquantidade.Value:= _item['quantidade'].AsNumber;
           cds_canceladostatus.Value:= _item['status'].AsString;
           cds_canceladovalor.Value:= _item['valor'].AsNumber;
           cds_canceladodata_registro.AsDateTime:= GetData(_item['data_inclusao'].AsString);
           cds_canceladodata_estorno.AsDateTime:= GetData(_item['data_estorno'].AsString);
           cds_cancelado.Post;
       end else
       if (_item['status'].AsString = 'rascunho') or
          (_item['status'].AsString = 'pendente')
       then
       Begin
           cds_itens.Append;
           cds_itensid.Value:= _item['id'].AsInteger;
           cds_itensdescricao.Value:= _item['descricao'].AsString;
           cds_itensquantidade.Value:= _item['quantidade'].AsNumber;
           cds_itensstatus.Value:= _item['status'].AsString;
           cds_itensvalor.Value:= _item['valor'].AsNumber;
           cds_itensdata_registro.AsDateTime:= GetData(_item['data_inclusao'].AsString);
           cds_itens.Post;
       end else
       Begin

       end;

       cds_itens.First;
       cds_cancelado.First;

       frameProdutoGet1.EditID.SetFocus;
  end;
   SpeedButton4.Action := ac_cancelar;

end;

end.

