unit view.devolucao.selecao;

{$mode delphi}

interface

uses
  Classes, SysUtils, DB, BufDataset, Forms, Controls, Graphics, Dialogs,
  ComCtrls, ExtCtrls, DBGrids, StdCtrls, ActnList, controller.devolucao, jsons, Grids;

type

  { Tf_devolucaoSeleciona }

  Tf_devolucaoSeleciona = class(TForm)
    Action1: TAction;
    ac_confirma: TAction;
    ActionList1: TActionList;
    Button1: TButton;
    cds_devolvidosaliq_desconto: TFloatField;
    cds_devolvidosdata_devolucao: TDateTimeField;
    cds_devolvidosdescricao: TStringField;
    cds_devolvidosdevolucao_id: TLongintField;
    cds_devolvidosn_marca: TStringField;
    cds_devolvidosn_unidade: TStringField;
    cds_devolvidosproduto_id: TLongintField;
    cds_devolvidosquantidade: TFloatField;
    cds_devolvidossub_total: TFloatField;
    cds_devolvidosvalor_final: TFloatField;
    cds_devolvidosvalor_unitario: TFloatField;
    cds_selecao: TBufDataset;
    cds_devolvidos: TBufDataset;
    cds_selecaocheck: TBooleanField;
    cds_selecaodescricao: TStringField;
    cds_selecaodevolver: TFloatField;
    cds_selecaon_unidade: TStringField;
    cds_selecaoproduto_id: TLongintField;
    cds_selecaoquantidade: TFloatField;
    cds_selecaovalor_unitario: TFloatField;
    DBGrid1: TDBGrid;
    ds_devolvidos: TDataSource;
    gridDevolvidos: TDBGrid;
    ds_selecao: TDataSource;
    PageControl1: TPageControl;
    Panel1: TPanel;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    procedure Action1Execute(Sender: TObject);
    procedure ac_confirmaExecute(Sender: TObject);
    procedure cds_selecaoBeforePost(DataSet: TDataSet);
    procedure DBGrid1CellClick(Column: TColumn);
    procedure DBGrid1ColExit(Sender: TObject);
    procedure DBGrid1KeyPress(Sender: TObject; var Key: char);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public
       _devolucao : Tdevolucao ;
       Procedure SetLayout(_Object : Tdevolucao);
  end;

var
  f_devolucaoSeleciona: Tf_devolucaoSeleciona;

implementation

{$R *.lfm}

uses ems.utils;

procedure Tf_devolucaoSeleciona.FormCreate(Sender: TObject);
begin
    cds_selecao.CreateDataset;
    cds_selecao.Open;

    cds_devolvidos.CreateDataset;
    cds_devolvidos.Open;

    DBGrid1.Columns[2].DisplayFormat:=Sessao.formatquantidade;
    DBGrid1.Columns[3].DisplayFormat:=Sessao.formatquantidade;
    DBGrid1.Columns[6].DisplayFormat:= Sessao.formatunitario;

    gridDevolvidos.Columns[0].DisplayFormat:= Sessao.datetimeformat;
    gridDevolvidos.Columns[2].DisplayFormat:=Sessao.formatquantidade;
    gridDevolvidos.Columns[5].DisplayFormat:= Sessao.formatunitario;

end;

procedure Tf_devolucaoSeleciona.FormResize(Sender: TObject);
begin
  DBGrid1.Columns[5].Width:= DBGrid1.Width - ( DBGrid1.Columns[0].Width +
                                               DBGrid1.Columns[1].Width +
                                               DBGrid1.Columns[2].Width +
                                               DBGrid1.Columns[3].Width +
                                               DBGrid1.Columns[4].Width +
                                               DBGrid1.Columns[6].Width +
                                               30
                                               );
end;

procedure Tf_devolucaoSeleciona.FormShow(Sender: TObject);
begin
  PageControl1.ActivePage:= TabSheet1;
end;

procedure Tf_devolucaoSeleciona.ac_confirmaExecute(Sender: TObject);
var _lista : TJsonObject;
    _item : TJsonObject;
begin
   try
       _lista := TJsonObject.Create();
       cds_selecao.DisableControls;
       cds_selecao.First;
       while not cds_selecao.EOF do
       Begin
           if cds_selecaocheck.Value then
           Begin
               _item := TJsonObject.Create();
               _item['produto_id'].AsInteger:= cds_selecaoproduto_id.Value;
               _item['quantidade'].AsNumber:= cds_selecaodevolver.Value;

               with _lista['itens'].AsArray do
                  Put(_item);
           end;
           cds_selecao.Next;
       end;

       if _lista.Count > 0 then
          _devolucao.devolve(_lista);

       self.Close;

   finally
       FreeAndNil(_lista);
       cds_selecao.First;
       cds_selecao.EnableControls;
   end;
end;

procedure Tf_devolucaoSeleciona.cds_selecaoBeforePost(DataSet: TDataSet);
begin
   cds_selecaocheck.Value := cds_selecaodevolver.Value > 0;
end;

procedure Tf_devolucaoSeleciona.DBGrid1CellClick(Column: TColumn);
begin
  if DBGrid1.DataSource.State in [dsInsert, dsEdit] then
  Begin
      if cds_selecaocheck.Value then
      Begin
           if cds_selecaodevolver.Value = 0 then
              cds_selecaodevolver.Value:= cds_selecaoquantidade.Value;
      end else
         cds_selecaodevolver.Value:= 0;

      DBGrid1.DataSource.DataSet.Post;
  end;
end;

procedure Tf_devolucaoSeleciona.DBGrid1ColExit(Sender: TObject);
begin
    if DBGrid1.DataSource.State in [dsInsert, dsEdit] then
       DBGrid1.DataSource.DataSet.Post;
end;

procedure Tf_devolucaoSeleciona.DBGrid1KeyPress(Sender: TObject; var Key: char);
begin
  if key = #13 Then
  Begin
        Key := #0;
        if DBGrid1.DataSource.State in [dsInsert, dsEdit] then
           DBGrid1.DataSource.DataSet.Post;
  end;
end;

procedure Tf_devolucaoSeleciona.Action1Execute(Sender: TObject);
begin
  self.close;
end;

procedure Tf_devolucaoSeleciona.SetLayout(_Object: Tdevolucao);
var i : Integer;
   _item : TJsonObject;
begin
    _devolucao := _Object;
    for i := 0 to _object.venda['disponivel'].AsArray.Count-1 do
    Begin
        _item := _object.venda['disponivel'].AsArray.Items[i].AsObject;
        cds_selecao.Append;
        cds_selecaocheck.AsBoolean:= false;
        cds_selecaodescricao.Value:= _item['descricao'].AsString;
        cds_selecaodevolver.Value:= 0;
        cds_selecaon_unidade.value := _item['medida_descricao'].AsString;
        cds_selecaoproduto_id.value := _item['produto_id'].AsInteger;
        cds_selecaoquantidade.Value:= _item['quantidade'].AsNumber;
        cds_selecaovalor_unitario.Value:= _item['valor_final'].AsNumber;
        cds_selecao.Post;
    end;
    cds_selecao.First;


    for i := 0 to _object.venda['devolvidos'].AsArray.Count-1 do
    Begin
        _item := _object.venda['devolvidos'].AsArray.Items[i].AsObject;

        cds_devolvidos.Append;
        cds_devolvidosdevolucao_id.Value:= _item['devolucao_id'].AsInteger;
        cds_devolvidosdata_devolucao.AsDateTime:= getDataBanco(_item['data_emissao'].AsString);
        cds_devolvidosproduto_id.Value := _item['produto_id'].AsInteger;
        cds_devolvidosn_marca.Value:= _item['n_marca'].AsString;
        cds_devolvidosn_unidade.Value:= _item['n_unidade'].AsString;
        cds_devolvidosquantidade.Value:= _item['quantidade'].AsNumber;
        cds_devolvidosvalor_unitario.Value:= _item['valor_unitario'].AsNumber;
        cds_devolvidosaliq_desconto.Value:= _item['aliq_desconto'].AsNumber;
        cds_devolvidosvalor_final.Value:= _item['valor_final'].AsNumber;
        cds_devolvidossub_total.Value:= _item['sub_total'].AsNumber;
        cds_devolvidosdescricao.Value:= _item['descricao'].AsString;
        cds_devolvidos.Post;
    end;
    cds_devolvidos.First;
end;

end.

